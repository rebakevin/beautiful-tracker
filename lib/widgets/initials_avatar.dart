import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Round avatar showing a person's initials.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.initials,
    this.size = 48,
    this.background = AppColors.primary,
    this.foreground = Colors.white,
  });

  final String initials;
  final double size;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Text(
        initials,
        style: TextStyle(
          color: foreground,
          fontSize: size * 0.35,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
