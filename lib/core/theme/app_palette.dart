import 'package:flutter/material.dart';

/// Theme-dependent colors (light / dark) from design/design.html.
///
/// Read it in widgets with `context.palette` so they follow dark mode.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.ground,
    required this.surface,
    required this.ink,
    required this.ink2,
    required this.muted,
    required this.hairline,
    required this.border,
    required this.tint,
    required this.wash,
    required this.deep,
    required this.navPill,
    required this.accent,
  });

  /// App background.
  final Color ground;

  /// Cards, inputs, navigation, sheets.
  final Color surface;

  /// Primary text and icons.
  final Color ink;

  /// Labels, secondary text.
  final Color ink2;

  /// Captions, descriptions, inactive tab.
  final Color muted;

  /// Card borders, dividers.
  final Color hairline;

  /// Input and button borders.
  final Color border;

  /// Selected chip fill, success card.
  final Color tint;

  /// Row hover / pressed fill.
  final Color wash;

  /// Deep text on green tints.
  final Color deep;

  /// Selected tab pill.
  final Color navPill;

  /// Green used for text, icons, links and the logo.
  final Color accent;

  static const light = AppPalette(
    ground: Color(0xFFF7F7F8),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF16171A),
    ink2: Color(0xFF4A4E55),
    muted: Color(0xFF6B6F76),
    hairline: Color(0xFFECECEF),
    border: Color(0xFFE3E3E8),
    tint: Color(0xFFE1F3EA),
    wash: Color(0xFFF3FBF7),
    deep: Color(0xFF075F47),
    navPill: Color(0xFFFFE9AD),
    accent: Color(0xFF0A7A5C),
  );

  static const dark = AppPalette(
    ground: Color(0xFF111214),
    surface: Color(0xFF1B1C1F),
    ink: Color(0xFFF2F2F3),
    ink2: Color(0xFFC9CBD0),
    muted: Color(0xFF9A9EA6),
    hairline: Color(0xFF2A2C30),
    border: Color(0xFF36383D),
    tint: Color(0xFF16352B),
    wash: Color(0xFF1A2420),
    deep: Color(0xFF7FD8B6),
    navPill: Color(0xFF3B3210),
    accent: Color(0xFF4FD1A0),
  );

  @override
  AppPalette copyWith({
    Color? ground,
    Color? surface,
    Color? ink,
    Color? ink2,
    Color? muted,
    Color? hairline,
    Color? border,
    Color? tint,
    Color? wash,
    Color? deep,
    Color? navPill,
    Color? accent,
  }) {
    return AppPalette(
      ground: ground ?? this.ground,
      surface: surface ?? this.surface,
      ink: ink ?? this.ink,
      ink2: ink2 ?? this.ink2,
      muted: muted ?? this.muted,
      hairline: hairline ?? this.hairline,
      border: border ?? this.border,
      tint: tint ?? this.tint,
      wash: wash ?? this.wash,
      deep: deep ?? this.deep,
      navPill: navPill ?? this.navPill,
      accent: accent ?? this.accent,
    );
  }

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      ground: Color.lerp(ground, other.ground, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      ink2: Color.lerp(ink2, other.ink2, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      border: Color.lerp(border, other.border, t)!,
      tint: Color.lerp(tint, other.tint, t)!,
      wash: Color.lerp(wash, other.wash, t)!,
      deep: Color.lerp(deep, other.deep, t)!,
      navPill: Color.lerp(navPill, other.navPill, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
