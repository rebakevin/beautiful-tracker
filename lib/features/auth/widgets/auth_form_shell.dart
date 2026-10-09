import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';

/// Page frame shared by the sign-in and sign-up screens: a scrollable, padded
/// [Form] with autofill. Content fills at least the screen height, so a
/// [Spacer] in [children] pins what follows to the bottom.
class AuthFormShell extends StatelessWidget {
  const AuthFormShell({
    super.key,
    required this.formKey,
    required this.autovalidateMode,
    required this.children,
    this.topPadding = AppSpacing.cardPadding,
  });

  final GlobalKey<FormState> formKey;
  final AutovalidateMode autovalidateMode;
  final List<Widget> children;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.auth,
              topPadding,
              AppSpacing.auth,
              AppSpacing.auth,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - topPadding - AppSpacing.auth,
              ),
              child: IntrinsicHeight(
                child: Form(
                  key: formKey,
                  autovalidateMode: autovalidateMode,
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: children,
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
