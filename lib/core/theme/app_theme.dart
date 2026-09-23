import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bento — warm, bento-inspired design system per SKILL.md
/// Phase 1-2: Widget composition, responsive, branded palette from bento icon.

class AppTheme {
  // Brand palette extracted from bento icon: brown, beige, green, red, yellow
  static const _bentoBrown = Color(0xFF5C3A21);
  static const _bentoBeige = Color(0xFFF5D6A0);
  static const _bentoBeigeDark = Color(0xFFE8C99A);
  static const _bentoGreen = Color(0xFF2E7D48);
  static const _bentoRed = Color(0xFFD6453A);
  static const _surfaceWarm = Color(0xFFFFFBF0);
  static const _seedWarm = Color(0xFF8B5A2B);

  static ThemeData get light {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    final scheme = ColorScheme.fromSeed(
      seedColor: _seedWarm,
      primary: _bentoBrown,
      secondary: _bentoBeigeDark,
      tertiary: _bentoGreen,
      error: _bentoRed,
      surface: _surfaceWarm,
      brightness: Brightness.light,
    );
    return base.copyWith(
      colorScheme: scheme,
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).copyWith(
        displaySmall: GoogleFonts.dmSans(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        titleLarge: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
        titleMedium: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _surfaceWarm,
        foregroundColor: _bentoBrown,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w800, color: _bentoBrown),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: _bentoBeige,
        elevation: 2,
        labelTextStyle: WidgetStatePropertyAll(GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 12)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _bentoBrown,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _bentoBeige.withValues(alpha: 0.6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }

  static ThemeData get dark {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.dark);
    final scheme = ColorScheme.fromSeed(
      seedColor: _seedWarm,
      primary: _bentoBeige,
      secondary: _bentoBrown,
      tertiary: const Color(0xFF6BB98A),
      surface: const Color(0xFF1A120E),
      brightness: Brightness.dark,
    );
    return base.copyWith(
      colorScheme: scheme,
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1A120E),
        foregroundColor: _bentoBeige,
        elevation: 0,
        titleTextStyle: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w800, color: _bentoBeige),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: const Color(0xFF2A1F1A),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF1A120E),
        indicatorColor: _bentoBrown.withValues(alpha: 0.4),
        labelTextStyle: WidgetStatePropertyAll(GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
