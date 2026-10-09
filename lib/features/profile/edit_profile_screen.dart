import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/session/session_scope.dart';
import '../../core/utils/validators.dart';
import '../../data/services/account_service.dart';
import '../../data/services/avatar_storage.dart';
import '../../widgets/form_page.dart';
import '../../widgets/labeled_text_field.dart';
import '../../widgets/toast.dart';
import 'widgets/avatar_editor.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accounts = AccountService();
  final _avatars = const AvatarStorage();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  // Photo choices are applied when the form is saved, not when picked.
  XFile? _newPhoto;
  bool _photoRemoved = false;

  String? _emailError;
  bool _saving = false;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    // Read once to prefill the form; the fields own the values from here on.
    final user = SessionScope.readUser(context);
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _emailError = null;
      _autovalidate = AutovalidateMode.onUserInteraction;
    });
    if (!_formKey.currentState!.validate()) return;

    final user = SessionScope.readUser(context);
    final controller = SessionScope.controllerOf(context);
    setState(() => _saving = true);
    String? savedPhoto;
    try {
      final newPhoto = _newPhoto;
      if (newPhoto != null) {
        savedPhoto = await _avatars.save(newPhoto, userId: user.id!);
      }
      final avatarPath = savedPhoto ?? (_photoRemoved ? null : user.avatarPath);
      final updated = await _accounts.updateProfile(
        user,
        name: _nameController.text,
        email: _emailController.text,
        avatarPath: avatarPath,
      );
      if (avatarPath != user.avatarPath) await _avatars.delete(user.avatarPath);
      if (!mounted) return;
      controller.userUpdated(updated);
      showToast(context, 'Profile updated');
      Navigator.of(context).pop();
    } on AccountException catch (e) {
      await _avatars.delete(savedPhoto);
      setState(() => _emailError = e.message);
    } catch (e) {
      await _avatars.delete(savedPhoto);
      debugPrint('Profile update failed: $e');
      if (mounted) showToast(context, 'Could not save. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = SessionScope.readUser(context);
    final photoPath =
        _newPhoto?.path ?? (_photoRemoved ? null : user.avatarPath);

    return Form(
      key: _formKey,
      autovalidateMode: _autovalidate,
      child: FormPage(
        title: 'Edit Profile',
        onSave: _save,
        saving: _saving,
        children: [
          AvatarEditor(
            initials: user.initials,
            imagePath: photoPath,
            onPicked: (photo) => setState(() {
              _newPhoto = photo;
              _photoRemoved = false;
            }),
            onRemoved: () => setState(() {
              _newPhoto = null;
              _photoRemoved = true;
            }),
          ),
          LabeledTextField(
            label: 'Name',
            controller: _nameController,
            validator: Validators.name,
            textCapitalization: TextCapitalization.words,
          ),
          LabeledTextField(
            label: 'Email',
            controller: _emailController,
            validator: Validators.email,
            errorText: _emailError,
            onChanged: (_) {
              if (_emailError != null) setState(() => _emailError = null);
            },
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _save(),
          ),
        ],
      ),
    );
  }
}
