import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';

/// Shared layout for the main tab pages: a page title followed by scrollable
/// content, padded to the screen margin.
class PageScaffold extends StatelessWidget {
  const PageScaffold({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.screen,
          AppSpacing.screen,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.section),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
