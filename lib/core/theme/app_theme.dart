import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_palette.dart';
import 'app_spacing.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(AppPalette.light, Brightness.light);

  /// Applied only after sign-in; auth screens always use [light].
  static ThemeData get dark => _build(AppPalette.dark, Brightness.dark);

  static ThemeData _build(AppPalette p, Brightness brightness) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.yellow400,
        error: AppColors.danger,
        surface: p.surface,
        onSurface: p.ink,
      ),
      scaffoldBackgroundColor: p.ground,
    );

    final textTheme = GoogleFonts.barlowTextTheme(base.textTheme).copyWith(
      headlineMedium: GoogleFonts.barlow(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: p.ink,
      ),
      headlineSmall: GoogleFonts.barlow(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: p.ink,
      ),
      titleLarge: GoogleFonts.barlow(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: p.ink,
      ),
      titleMedium: GoogleFonts.barlow(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: p.ink,
      ),
      labelLarge: GoogleFonts.barlow(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: p.ink2,
      ),
      bodyLarge: GoogleFonts.barlow(fontSize: 16, color: p.ink),
      bodyMedium: GoogleFonts.barlow(fontSize: 15, color: p.muted),
      bodySmall: GoogleFonts.barlow(fontSize: 13, color: p.muted),
    );

    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.field),
      borderSide: BorderSide(color: p.border, width: 1.5),
    );

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.field),
    );
    final buttonText = GoogleFonts.barlow(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    return base.copyWith(
      textTheme: textTheme,
      extensions: [p],
      dividerTheme: DividerThemeData(color: p.hairline, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        hoverColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPadding,
          vertical: 15,
        ),
        hintStyle: GoogleFonts.barlow(fontSize: 16, color: p.muted),
        errorStyle: GoogleFonts.barlow(fontSize: 13, color: AppColors.danger),
        errorMaxLines: 2,
        border: fieldBorder,
        enabledBorder: fieldBorder,
        focusedBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: p.accent, width: 1.5),
        ),
        errorBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        focusedErrorBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(cursorColor: p.accent),
      filledButtonTheme: FilledButtonThemeData(
        style:
            FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
              disabledForegroundColor: Colors.white,
              minimumSize: const Size(64, 48),
              shape: buttonShape,
              textStyle: buttonText,
            ).copyWith(
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed)) {
                  return AppColors.primaryPressed;
                }
                if (states.contains(WidgetState.hovered)) {
                  return AppColors.primaryHover;
                }
                if (states.contains(WidgetState.disabled)) {
                  return AppColors.primary.withValues(alpha: 0.6);
                }
                return AppColors.primary;
              }),
            ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: p.surface,
          foregroundColor: p.ink,
          minimumSize: const Size(64, 48),
          side: BorderSide(color: p.border, width: 1.5),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: p.accent),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.switchOff,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        thumbIcon: const WidgetStatePropertyAll(null),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        barrierColor: AppColors.scrim.withValues(alpha: 0.45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.dialog),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Colors.white,
      ),
      // Borders, not shadows: surfaces are separated by hairlines.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: p.navPill,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected) ? p.accent : p.muted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => GoogleFonts.barlow(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected) ? p.accent : p.muted,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: p.hairline),
        ),
      ),
    );
  }

  static TextStyle brand({double size = 24, Color? color}) =>
      GoogleFonts.barlowCondensed(
        fontSize: size,
        fontWeight: FontWeight.w700,
        height: 1,
        letterSpacing: -0.3,
        color: color,
      );
}
