import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Compact top bar used by sub-screens: a circular back button on the left
/// and a centered title, balanced by an equal-width spacer on the right.
class ScreenTopBar extends StatelessWidget {
  const ScreenTopBar({super.key, required this.title, this.onBack});

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      child: Row(
        children: [
          _BackButton(onTap: onBack ?? () => Navigator.of(context).pop()),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: GoogleFonts.barlow(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
          const SizedBox(width: _BackButton.size),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  static const double size = 42;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(
        side: BorderSide(color: AppColors.hairline),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: const Icon(
            Icons.chevron_left,
            size: 24,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }
}
