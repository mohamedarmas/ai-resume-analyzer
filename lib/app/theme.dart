import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const background = Color(0xFFF4EFE6);
  const surface = Color(0xFFFFFCF6);
  const primary = Color(0xFF0E4C5C);
  const secondary = Color(0xFFC06C4E);
  const tertiary = Color(0xFF718A5A);
  const outline = Color(0xFFDACFBE);

  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        surface: surface,
        outline: outline,
      );

  final baseTheme = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: background,
    fontFamily: 'Georgia',
  );

  final textTheme = baseTheme.textTheme.copyWith(
    displayLarge: baseTheme.textTheme.displayLarge?.copyWith(
      fontWeight: FontWeight.w700,
      height: 0.96,
      letterSpacing: -1.4,
      color: primary,
    ),
    displayMedium: baseTheme.textTheme.displayMedium?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.8,
      color: primary,
    ),
    headlineLarge: baseTheme.textTheme.headlineLarge?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.6,
      color: primary,
    ),
    titleLarge: baseTheme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
      color: primary,
    ),
    titleMedium: baseTheme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: primary,
    ),
    bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(
      height: 1.55,
      color: const Color(0xFF283039),
    ),
    bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(
      height: 1.5,
      color: const Color(0xFF4B5560),
    ),
    labelLarge: baseTheme.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
    ),
  );

  return baseTheme.copyWith(
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: primary,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: outline),
      ),
    ),
    chipTheme: baseTheme.chipTheme.copyWith(
      backgroundColor: const Color(0xFFE8E0D2),
      side: const BorderSide(color: outline),
      labelStyle: textTheme.labelMedium?.copyWith(
        color: primary,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        side: const BorderSide(color: outline),
        foregroundColor: primary,
        textStyle: textTheme.labelLarge,
      ),
    ),
  );
}
