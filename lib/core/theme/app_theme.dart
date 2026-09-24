import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_palettes.dart';

/// Bento theming — builds Material 3 ThemeData from the selected [AppPalette].
/// All component colors come from scheme roles so every palette stays consistent.
class AppTheme {
  static ThemeData lightFor(AppPalette palette) => _build(palette.lightScheme);

  static ThemeData darkFor(AppPalette palette) => _build(palette.darkScheme);

  static ThemeData _build(ColorScheme scheme) {
    final base = ThemeData(useMaterial3: true, brightness: scheme.brightness);
    final isLight = scheme.brightness == Brightness.light;
    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).copyWith(
        displaySmall: GoogleFonts.dmSans(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        titleLarge: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
        titleMedium: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: scheme.primary,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: scheme.surfaceContainerLow,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        elevation: isLight ? 1 : 0,
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.secondaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: GoogleFonts.dmSans(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: scheme.onSecondaryContainer,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: GoogleFonts.dmSans(color: scheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
