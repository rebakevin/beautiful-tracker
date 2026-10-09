import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';

class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  final String title;
  final Widget child;

  final Widget? actions;

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
            if (actions == null)
              Text(title, style: Theme.of(context).textTheme.headlineMedium)
            else
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  actions!,
                ],
              ),
            const SizedBox(height: AppSpacing.section),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
