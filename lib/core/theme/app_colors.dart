import 'package:flutter/material.dart';

/// Fixed color tokens from design/design-system.html that look the same in
/// light and dark mode. Colors that change with the theme live in
/// [AppPalette].
class AppColors {
  AppColors._();

  static const primary = Color(0xFF0A7A5C);
  static const primaryHover = Color(0xFF075F47);
  static const primaryPressed = Color(0xFF054A38);
  static const primaryTint = Color(0xFFE1F3EA);
  static const primaryWash = Color(0xFFF3FBF7);
  static const primaryBorder = Color(0xFFB7E0CF);

  static const yellow400 = Color(0xFFFFD84A);
  static const yellow200 = Color(0xFFFFE29A);
  static const yellow100 = Color(0xFFFFE9AD);
  static const brownInk = Color(0xFF4A3500);

  // Neutrals — light-mode values only. These do not change in dark mode;
  // new code should use context.palette (ink, muted, hairline, ...) instead.
  static const ink = Color(0xFF16171A);
  static const ink2 = Color(0xFF4A4E55);
  static const muted = Color(0xFF6B6F76);
  static const border = Color(0xFFE3E3E8);
  static const hairline = Color(0xFFECECEF);
  static const ground = Color(0xFFF7F7F8);
  static const surface = Color(0xFFFFFFFF);

  static const onTrackBg = Color(0xFFE6F5EC);
  static const onTrackFg = Color(0xFF17714A);
  static const atRiskBg = Color(0xFFFFF0D2);
  static const atRiskFg = Color(0xFF8A5200);
  static const overdueBg = Color(0xFFFDE6E5);
  static const overdueFg = Color(0xFFB42B25);
  static const completedBg = Color(0xFFECEEF1);
  static const completedFg = Color(0xFF555B63);

  static const danger = Color(0xFFC0302B);
  static const chartCompleted = Color(0xFF2F9E78);
  static const chartInProgress = Color(0xFFE0A800);

  static const scrim = Color(0xFF16171A);

  static const switchOff = Color(0xFFC9CBD0);
}
