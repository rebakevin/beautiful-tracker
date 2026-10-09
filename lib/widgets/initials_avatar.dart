import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Circle showing the photo at [imagePath] when there is one, otherwise the
/// [initials]. Photos are device files, so on web it always shows initials.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.initials,
    this.imagePath,
    this.size = 48,
    this.background = AppColors.primary,
    this.foreground = Colors.white,
  });

  final String initials;
  final String? imagePath;
  final double size;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final fallback = _initials();
    final path = imagePath;
    if (path == null || kIsWeb) return fallback;

    return ClipOval(
      child: Image.file(
        File(path),
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
        // A deleted or unreadable file falls back to the initials.
        errorBuilder: (_, _, _) => fallback,
      ),
    );
  }

  Widget _initials() {
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
