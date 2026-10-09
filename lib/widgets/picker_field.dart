import 'package:flutter/material.dart';

import '../core/theme/app_palette.dart';
import '../core/theme/app_spacing.dart';

/// A label above any form control (the label style of [LabeledTextField]).
class LabeledField extends StatelessWidget {
  const LabeledField({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.xs),
        child,
      ],
    );
  }
}

/// Looks like a text box but opens a picker (sheet or dialog) when tapped.
class PickerField extends StatelessWidget {
  const PickerField({
    super.key,
    required this.text,
    required this.onTap,
    this.isPlaceholder = false,
    this.errorText,
    this.icon = Icons.keyboard_arrow_down,
  });

  final String text;
  final VoidCallback onTap;

  /// Shows [text] in the muted hint color.
  final bool isPlaceholder;
  final String? errorText;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.field),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          suffixIcon: Icon(icon),
          errorText: errorText,
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: isPlaceholder ? palette.muted : palette.ink,
          ),
        ),
      ),
    );
  }
}
