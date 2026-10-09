import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

class MemberAvatar extends StatelessWidget {
  const MemberAvatar({super.key, required this.initials, this.size = 48});

  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.yellow200,
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        style: GoogleFonts.barlow(
          fontSize: size * 0.34,
          fontWeight: FontWeight.w700,
          color: AppColors.brownInk,
        ),
      ),
    );
  }
}
