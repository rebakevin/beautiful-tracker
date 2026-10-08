import 'package:flutter/material.dart';

import '../../core/session/session_scope.dart';
import '../../core/utils/validators.dart';
import '../../data/services/account_service.dart';
import '../../widgets/form_page.dart';
import '../../widgets/labeled_text_field.dart';
import '../../widgets/toast.dart';

/// Change the signed-in user's name and email.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accounts = AccountService();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

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
    try {
      final updated = await _accounts.updateProfile(
        user,
        name: _nameController.text,
        email: _emailController.text,
      );
      if (!mounted) return;
      controller.userUpdated(updated);
      showToast(context, 'Profile updated');
      Navigator.of(context).pop();
    } on AccountException catch (e) {
      setState(() => _emailError = e.message);
    } catch (e) {
      debugPrint('Profile update failed: $e');
      if (mounted) showToast(context, 'Could not save. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: _autovalidate,
      child: FormPage(
        title: 'Edit Profile',
        onSave: _save,
        saving: _saving,
        children: [
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
