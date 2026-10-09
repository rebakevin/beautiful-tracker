import 'package:flutter/material.dart';

import '../../core/session/session_scope.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../data/services/account_service.dart';
import '../../widgets/circle_icon_button.dart';
import '../../widgets/labeled_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/toast.dart';
import 'widgets/auth_switch_link.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _accounts = AccountService();

  String? _emailError;
  bool _loading = false;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _emailError = null;
      _autovalidate = AutovalidateMode.onUserInteraction;
    });
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final user = await _accounts.signUp(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      final navigator = Navigator.of(context);
      showToast(context, 'Welcome to Beautiful Tracker, ${user.firstName}');
      SessionScope.controllerOf(context).signedIn(user);
      navigator.popUntil((route) => route.isFirst);
    } on AccountException catch (e) {
      setState(() => _emailError = e.message);
    } catch (e) {
      debugPrint('Sign up failed: $e');
      if (mounted) {
        showToast(context, 'Could not create the account. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.auth,
            AppSpacing.cardPadding,
            AppSpacing.auth,
            AppSpacing.auth,
          ),
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidate,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: CircleIconButton.back(),
                  ),
                  const SizedBox(height: AppSpacing.screen),
                  Text(
                    'Create account',
                    style: AppTheme.brand(size: 38, color: palette.accent),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Join your team on Beautiful Tracker.',
                    style: theme.textTheme.bodyLarge?.copyWith(),
                  ),
                  const SizedBox(height: AppSpacing.section),
                  LabeledTextField(
                    label: 'Full name',
                    controller: _nameController,
                    hint: 'Your name',
                    validator: Validators.name,
                    textCapitalization: TextCapitalization.words,
                    autofillHints: const [AutofillHints.name],
                  ),
                  const SizedBox(height: AppSpacing.cardGap),
                  LabeledTextField(
                    label: 'Email',
                    controller: _emailController,
                    hint: 'you@team.dev',
                    validator: Validators.email,
                    errorText: _emailError,
                    onChanged: (_) {
                      if (_emailError != null) {
                        setState(() => _emailError = null);
                      }
                    },
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                  ),
                  const SizedBox(height: AppSpacing.cardGap),
                  LabeledTextField(
                    label: 'Password',
                    controller: _passwordController,
                    hint: 'At least 6 characters',
                    validator: Validators.password,
                    obscureText: true,
                    autofillHints: const [AutofillHints.newPassword],
                  ),
                  const SizedBox(height: AppSpacing.cardGap),
                  LabeledTextField(
                    label: 'Confirm password',
                    controller: _confirmController,
                    hint: 'Repeat password',
                    validator: Validators.confirmPassword(
                      () => _passwordController.text,
                    ),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: AppSpacing.auth),
                  PrimaryButton(
                    label: 'Create Account',
                    onPressed: _submit,
                    loading: _loading,
                    height: 54,
                    fontSize: 17,
                  ),
                  const SizedBox(height: 18),
                  AuthSwitchLink(
                    prompt: 'Already have an account?',
                    action: 'Sign in',
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
