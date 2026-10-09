import 'package:flutter/material.dart';

import '../core/theme/app_palette.dart';

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  const CircleIconButton.back({super.key, this.onPressed})
    : icon = Icons.chevron_left_rounded,
      tooltip = 'Back';

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: palette.surface,
        shape: CircleBorder(side: BorderSide(color: palette.border)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed ?? () => Navigator.of(context).maybePop(),
          child: SizedBox.square(
            dimension: 42,
            child: Icon(icon, size: 22, color: palette.ink),
          ),
        ),
      ),
    );
  }
}
