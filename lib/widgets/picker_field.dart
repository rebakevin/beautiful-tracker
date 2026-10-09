import 'package:flutter/material.dart';

import '../core/theme/app_palette.dart';
import '../core/theme/app_spacing.dart';

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
