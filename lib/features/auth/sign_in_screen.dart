import 'package:flutter/material.dart';

import '../../core/session/session_scope.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../data/services/account_service.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/labeled_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/toast.dart';
import 'sign_up_screen.dart';
import 'widgets/auth_switch_link.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _accounts = AccountService();

  String? _passwordError;
  bool _loading = false;

  // Validate live only after the first submit, so fields are not red while
  // the user is still typing for the first time.
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _passwordError = null;
      _autovalidate = AutovalidateMode.onUserInteraction;
    });
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final user = await _accounts.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      SessionScope.controllerOf(context).signedIn(user);
    } on AccountException catch (e) {
      setState(() => _passwordError = e.message);
    } catch (e) {
      debugPrint('Sign in failed: $e');
      if (mounted) showToast(context, 'Could not sign in. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openSignUp() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SignUpScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: palette.surface,
      body: SafeArea(
        // LayoutBuilder + minHeight lets the demo hint sit at the bottom on
        // tall screens while the form still scrolls when the keyboard opens.
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.auth,
              48,
              AppSpacing.auth,
              AppSpacing.auth,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 48 - AppSpacing.auth,
              ),
              child: IntrinsicHeight(
                child: Form(
                  key: _formKey,
                  autovalidateMode: _autovalidate,
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(child: AppLogo()),
                        const SizedBox(height: 24),
                        Text(
                          'Beautiful Tracker',
                          textAlign: TextAlign.center,
                          style: AppTheme.brand(
                            size: 46,
                            color: palette.accent,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          "Keep your team's work on track.",
                          textAlign: TextAlign.center,
                          style: text.bodyMedium?.copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 44),
                        LabeledTextField(
                          label: 'Email',
                          controller: _emailController,
                          hint: 'you@team.dev',
                          validator: Validators.email,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                        ),
                        const SizedBox(height: 18),
                        LabeledTextField(
                          label: 'Password',
                          controller: _passwordController,
                          hint: 'At least 6 characters',
                          validator: Validators.password,
                          errorText: _passwordError,
                          onChanged: (_) {
                            if (_passwordError != null) {
                              setState(() => _passwordError = null);
                            }
                          },
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: AppSpacing.auth),
                        PrimaryButton(
                          label: 'Sign In',
                          onPressed: _submit,
                          loading: _loading,
                          height: 54,
                          fontSize: 17,
                        ),
                        const SizedBox(height: 18),
                        AuthSwitchLink(
                          prompt: 'New here?',
                          action: 'Create an account',
                          onTap: _openSignUp,
                        ),
                        const Spacer(),
                        const SizedBox(height: 24),
                        Text(
                          'Demo: any valid email and a 6+ character password.',
                          textAlign: TextAlign.center,
                          style: text.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
