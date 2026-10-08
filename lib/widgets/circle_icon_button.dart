import 'package:flutter/material.dart';

import '../core/theme/app_palette.dart';

/// 42 x 42 round outlined icon button, e.g. the back button on sub-pages.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  /// Back button that pops the current route.
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
