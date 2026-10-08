import 'package:flutter/material.dart';

/// Fixed color tokens from design/design-system.html that look the same in
/// light and dark mode. Colors that change with the theme live in
/// [AppPalette].
class AppColors {
  AppColors._();

  // Primary — green
  static const primary = Color(0xFF0A7A5C);
  static const primaryHover = Color(0xFF075F47);
  static const primaryPressed = Color(0xFF054A38);

  // Secondary — warm yellow
  static const yellow400 = Color(0xFFFFD84A);
  static const yellow200 = Color(0xFFFFE29A);
  static const yellow100 = Color(0xFFFFE9AD);
  static const brownInk = Color(0xFF4A3500);

  // SLA badges (fill / text)
  static const onTrackBg = Color(0xFFE6F5EC);
  static const onTrackFg = Color(0xFF17714A);
  static const atRiskBg = Color(0xFFFFF0D2);
  static const atRiskFg = Color(0xFF8A5200);
  static const overdueBg = Color(0xFFFDE6E5);
  static const overdueFg = Color(0xFFB42B25);
  static const completedBg = Color(0xFFECEEF1);
  static const completedFg = Color(0xFF555B63);

  // Feedback & charts
  static const danger = Color(0xFFC0302B);
  static const chartCompleted = Color(0xFF2F9E78);
  static const chartInProgress = Color(0xFFE0A800);

  // Toast background and dialog/sheet scrim base
  static const scrim = Color(0xFF16171A);

  // Switch track when off
  static const switchOff = Color(0xFFC9CBD0);
}
