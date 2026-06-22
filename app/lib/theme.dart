import 'package:flutter/material.dart';

/// Partido Socialista de Chile visual identity.
///
/// The party's identity is red over black and white. These tones are tuned for
/// legibility of long legal text on a phone while keeping the militant red as
/// the accent.
class PSColors {
  PSColors._();

  /// Primary socialist red (banner / app bar / call to action).
  static const Color red = Color(0xFFD0021B);
  static const Color redDark = Color(0xFF9C0214);
  static const Color redBright = Color(0xFFE2001A);

  /// Near-black used for text and the portrait line work.
  static const Color ink = Color(0xFF1A1A1A);
  static const Color inkSoft = Color(0xFF4A4A4A);

  /// Warm off-white "paper" background, easier on the eyes than pure white.
  static const Color paper = Color(0xFFF7F3EE);
  static const Color surface = Color(0xFFFFFFFF);

  /// Feedback colors for the quiz.
  static const Color correct = Color(0xFF2E7D32);
  static const Color wrong = Color(0xFFB00020);

  static const Color gold = Color(0xFFE6B800); // accent for progress / stars
}

ThemeData buildPSTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: PSColors.red,
    primary: PSColors.red,
    secondary: PSColors.ink,
    surface: PSColors.surface,
    brightness: Brightness.light,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: PSColors.paper,
    fontFamily: 'Roboto',
  );

  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: PSColors.red,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    ),
    cardTheme: CardThemeData(
      color: PSColors.surface,
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: PSColors.red,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textTheme: base.textTheme.apply(
      bodyColor: PSColors.ink,
      displayColor: PSColors.ink,
    ),
  );
}
