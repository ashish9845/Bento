import 'package:flutter/material.dart';

import 'app_palettes.dart';

/// Bundled app typeface: Google Sans Flex (user-provided files in
/// assets/fonts — NOT an OFL font, do not redistribute the TTFs separately).
/// Regular 400 for body text, SemiBold 600 for headers.
class AppFonts {
  static const family = 'GoogleSansFlex';

  static const regular = TextStyle(fontFamily: family, fontWeight: FontWeight.w400);
  static const semiBold = TextStyle(fontFamily: family, fontWeight: FontWeight.w600);
}

/// Bento theming — builds Material 3 ThemeData from the selected [AppPalette].
/// All component colors come from scheme roles so every palette stays consistent.
class AppTheme {
  /// [dynamicScheme] is the OS Material You scheme (null where unsupported);
  /// it only takes effect when [palette] is [AppPalette.dynamic].
  static ThemeData lightFor(AppPalette palette, {ColorScheme? dynamicScheme}) =>
      _build(palette.resolve(Brightness.light, dynamicScheme: dynamicScheme));

  static ThemeData darkFor(AppPalette palette, {ColorScheme? dynamicScheme}) =>
      _build(palette.resolve(Brightness.dark, dynamicScheme: dynamicScheme));

  static ThemeData _build(ColorScheme scheme) {
    final base = ThemeData(useMaterial3: true, brightness: scheme.brightness);
    final isLight = scheme.brightness == Brightness.light;
    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      // Title colors are pinned to onSurface explicitly (not inherited):
      // inherited colors break under MIUI's text/background adjustments,
      // which left titles invisible white-on-white in light mode.
      textTheme: base.textTheme.apply(fontFamily: AppFonts.family).copyWith(
        displaySmall: base.textTheme.displaySmall?.copyWith(
            fontFamily: AppFonts.family,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: scheme.onSurface),
        titleLarge: base.textTheme.titleLarge?.copyWith(
            fontFamily: AppFonts.family, fontWeight: FontWeight.w700, color: scheme.onSurface),
        titleMedium: base.textTheme.titleMedium?.copyWith(
            fontFamily: AppFonts.family, fontWeight: FontWeight.w600, color: scheme.onSurface),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.family,
          fontSize: 22,
          fontWeight: FontWeight.w600,
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
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontFamily: AppFonts.family, fontWeight: FontWeight.w500, fontSize: 12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontFamily: AppFonts.family, fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.secondaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: TextStyle(
          fontFamily: AppFonts.family,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: scheme.onSecondaryContainer,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(fontFamily: AppFonts.family, color: scheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
