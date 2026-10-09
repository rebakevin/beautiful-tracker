import 'package:flutter/material.dart';

import '../../core/session/session_scope.dart';
import '../../core/utils/validators.dart';
import '../../data/services/account_service.dart';
import '../../widgets/form_page.dart';
import '../../widgets/labeled_text_field.dart';
import '../../widgets/toast.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accounts = AccountService();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  String? _currentError;
  String? _newError;
  bool _saving = false;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _currentError = null;
      _newError = null;
      _autovalidate = AutovalidateMode.onUserInteraction;
    });
    if (!_formKey.currentState!.validate()) return;

    final user = SessionScope.readUser(context);
    final controller = SessionScope.controllerOf(context);
    setState(() => _saving = true);
    try {
      final updated = await _accounts.changePassword(
        user,
        currentPassword: _currentController.text,
        newPassword: _newController.text,
      );
      if (!mounted) return;
      controller.userUpdated(updated);
      showToast(context, 'Password updated');
      Navigator.of(context).pop();
    } on AccountException catch (e) {
      setState(() {
        if (e.field == AccountField.currentPassword) {
          _currentError = e.message;
        } else {
          _newError = e.message;
        }
      });
    } catch (e) {
      debugPrint('Password change failed: $e');
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
        title: 'Change Password',
        onSave: _save,
        saving: _saving,
        children: [
          LabeledTextField(
            label: 'Current password',
            controller: _currentController,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Password is required' : null,
            errorText: _currentError,
            onChanged: (_) {
              if (_currentError != null) setState(() => _currentError = null);
            },
            obscureText: true,
            autofillHints: const [AutofillHints.password],
          ),
          LabeledTextField(
            label: 'New password',
            controller: _newController,
            hint: 'At least 6 characters',
            validator: Validators.password,
            errorText: _newError,
            onChanged: (_) {
              if (_newError != null) setState(() => _newError = null);
            },
            obscureText: true,
            autofillHints: const [AutofillHints.newPassword],
          ),
          LabeledTextField(
            label: 'Confirm new password',
            controller: _confirmController,
            hint: 'Repeat new password',
            validator: Validators.confirmPassword(() => _newController.text),
            obscureText: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _save(),
          ),
        ],
      ),
    );
  }
}
