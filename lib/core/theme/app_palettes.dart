import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Selectable color themes. Neutral blue is the default; every scheme uses
/// explicit roles with ≥4.5:1 text contrast (no seed-generated surprises).
enum AppPalette {
  neutralBlue('Ocean Blue', Icons.water_drop_rounded),
  teal('Deep Teal', Icons.spa_rounded),
  orange('Warm Orange', Icons.wb_sunny_rounded),
  purple('Royal Purple', Icons.auto_awesome_rounded),
  bentoWarm('Bento Warm', Icons.lunch_dining_rounded);

  const AppPalette(this.label, this.icon);
  final String label;
  final IconData icon;

  ColorScheme get lightScheme {
    switch (this) {
      case AppPalette.neutralBlue:
        return const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF0B57D0),
          onPrimary: Color(0xFFFFFFFF),
          primaryContainer: Color(0xFFD3E3FD),
          onPrimaryContainer: Color(0xFF041E49),
          secondary: Color(0xFF3B5B92),
          onSecondary: Color(0xFFFFFFFF),
          secondaryContainer: Color(0xFFD3E3FD),
          onSecondaryContainer: Color(0xFF0A1F44),
          tertiary: Color(0xFF146C2E),
          onTertiary: Color(0xFFFFFFFF),
          tertiaryContainer: Color(0xFFC4EED0),
          onTertiaryContainer: Color(0xFF072711),
          error: Color(0xFFB3261E),
          onError: Color(0xFFFFFFFF),
          errorContainer: Color(0xFFF9DEDC),
          onErrorContainer: Color(0xFF410E0B),
          surface: Color(0xFFF7F9FC),
          onSurface: Color(0xFF1A1C1E),
          onSurfaceVariant: Color(0xFF44474A),
          surfaceContainerLowest: Color(0xFFFFFFFF),
          surfaceContainerLow: Color(0xFFFFFFFF),
          surfaceContainer: Color(0xFFEDEFF2),
          surfaceContainerHigh: Color(0xFFE7E9EC),
          surfaceContainerHighest: Color(0xFFDFE2E5),
          outline: Color(0xFF74777A),
          outlineVariant: Color(0xFFC4C7C5),
          shadow: Color(0xFF000000),
          scrim: Color(0xFF000000),
          inverseSurface: Color(0xFF2F3033),
          onInverseSurface: Color(0xFFF2F0F4),
          inversePrimary: Color(0xFFA8C7FA),
          surfaceTint: Color(0xFF0B57D0),
        );
      case AppPalette.teal:
        return const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF006A60),
          onPrimary: Color(0xFFFFFFFF),
          primaryContainer: Color(0xFF70F7E4),
          onPrimaryContainer: Color(0xFF00201C),
          secondary: Color(0xFF2F6560),
          onSecondary: Color(0xFFFFFFFF),
          secondaryContainer: Color(0xFF70F7E4),
          onSecondaryContainer: Color(0xFF06201C),
          tertiary: Color(0xFF33690E),
          onTertiary: Color(0xFFFFFFFF),
          tertiaryContainer: Color(0xFFC4EED0),
          onTertiaryContainer: Color(0xFF0B2800),
          error: Color(0xFFB3261E),
          onError: Color(0xFFFFFFFF),
          errorContainer: Color(0xFFF9DEDC),
          onErrorContainer: Color(0xFF410E0B),
          surface: Color(0xFFF5FAF8),
          onSurface: Color(0xFF171D1C),
          onSurfaceVariant: Color(0xFF3F4948),
          surfaceContainerLowest: Color(0xFFFFFFFF),
          surfaceContainerLow: Color(0xFFFFFFFF),
          surfaceContainer: Color(0xFFEBF1EE),
          surfaceContainerHigh: Color(0xFFE5EBE8),
          surfaceContainerHighest: Color(0xFFDDE4E0),
          outline: Color(0xFF6F7978),
          outlineVariant: Color(0xFFBEC9C6),
          shadow: Color(0xFF000000),
          scrim: Color(0xFF000000),
          inverseSurface: Color(0xFF2C3231),
          onInverseSurface: Color(0xFFEFF5F3),
          inversePrimary: Color(0xFF4EDAC5),
          surfaceTint: Color(0xFF006A60),
        );
      case AppPalette.orange:
        return const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFFA23C00),
          onPrimary: Color(0xFFFFFFFF),
          primaryContainer: Color(0xFFFFDBCA),
          onPrimaryContainer: Color(0xFF341100),
          secondary: Color(0xFF6B4B2C),
          onSecondary: Color(0xFFFFFFFF),
          secondaryContainer: Color(0xFFFFDBCA),
          onSecondaryContainer: Color(0xFF331505),
          tertiary: Color(0xFF4C662B),
          onTertiary: Color(0xFFFFFFFF),
          tertiaryContainer: Color(0xFFCDEDA3),
          onTertiaryContainer: Color(0xFF102000),
          error: Color(0xFFB3261E),
          onError: Color(0xFFFFFFFF),
          errorContainer: Color(0xFFF9DEDC),
          onErrorContainer: Color(0xFF410E0B),
          surface: Color(0xFFFDF8F2),
          onSurface: Color(0xFF201A12),
          onSurfaceVariant: Color(0xFF504539),
          surfaceContainerLowest: Color(0xFFFFFFFF),
          surfaceContainerLow: Color(0xFFFFFFFF),
          surfaceContainer: Color(0xFFF5EBDD),
          surfaceContainerHigh: Color(0xFFEFE2CE),
          surfaceContainerHighest: Color(0xFFE7D7BC),
          outline: Color(0xFF817567),
          outlineVariant: Color(0xFFD1C0A5),
          shadow: Color(0xFF000000),
          scrim: Color(0xFF000000),
          inverseSurface: Color(0xFF352E24),
          onInverseSurface: Color(0xFFF8EFE2),
          inversePrimary: Color(0xFFFFB787),
          surfaceTint: Color(0xFFA23C00),
        );
      case AppPalette.purple:
        return const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF6750A4),
          onPrimary: Color(0xFFFFFFFF),
          primaryContainer: Color(0xFFEADDFF),
          onPrimaryContainer: Color(0xFF21005D),
          secondary: Color(0xFF4A4A68),
          onSecondary: Color(0xFFFFFFFF),
          secondaryContainer: Color(0xFFEADDFF),
          onSecondaryContainer: Color(0xFF1D1B4B),
          tertiary: Color(0xFF146C2E),
          onTertiary: Color(0xFFFFFFFF),
          tertiaryContainer: Color(0xFFC4EED0),
          onTertiaryContainer: Color(0xFF072711),
          error: Color(0xFFB3261E),
          onError: Color(0xFFFFFFFF),
          errorContainer: Color(0xFFF9DEDC),
          onErrorContainer: Color(0xFF410E0B),
          surface: Color(0xFFF8F6FC),
          onSurface: Color(0xFF1D1B20),
          onSurfaceVariant: Color(0xFF49454F),
          surfaceContainerLowest: Color(0xFFFFFFFF),
          surfaceContainerLow: Color(0xFFFFFFFF),
          surfaceContainer: Color(0xFFECEAF1),
          surfaceContainerHigh: Color(0xFFE6E3EB),
          surfaceContainerHighest: Color(0xFFE0DCE5),
          outline: Color(0xFF79747E),
          outlineVariant: Color(0xFFCAC4D0),
          shadow: Color(0xFF000000),
          scrim: Color(0xFF000000),
          inverseSurface: Color(0xFF322F35),
          onInverseSurface: Color(0xFFF5EFF7),
          inversePrimary: Color(0xFFD0BCFF),
          surfaceTint: Color(0xFF6750A4),
        );
      case AppPalette.bentoWarm:
        return AppThemeWarm.lightScheme;
    }
  }

  ColorScheme get darkScheme {
    switch (this) {
      case AppPalette.neutralBlue:
        return const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFFA8C7FA),
          onPrimary: Color(0xFF003258),
          primaryContainer: Color(0xFF004A77),
          onPrimaryContainer: Color(0xFFD3E3FD),
          secondary: Color(0xFFA9BCD6),
          onSecondary: Color(0xFF1B3351),
          secondaryContainer: Color(0xFF004A77),
          onSecondaryContainer: Color(0xFFD3E3FD),
          tertiary: Color(0xFF7ED9A8),
          onTertiary: Color(0xFF063A22),
          tertiaryContainer: Color(0xFF0F4D26),
          onTertiaryContainer: Color(0xFFA8F0BD),
          error: Color(0xFFF2B8B5),
          onError: Color(0xFF601410),
          errorContainer: Color(0xFF8C1D18),
          onErrorContainer: Color(0xFFF9DEDC),
          surface: Color(0xFF131314),
          onSurface: Color(0xFFE3E3E3),
          onSurfaceVariant: Color(0xFFC4C7C5),
          surfaceContainerLowest: Color(0xFF0D0D0E),
          surfaceContainerLow: Color(0xFF1B1B1C),
          surfaceContainer: Color(0xFF1F2022),
          surfaceContainerHigh: Color(0xFF26272A),
          surfaceContainerHighest: Color(0xFF333537),
          outline: Color(0xFF8E9193),
          outlineVariant: Color(0xFF444746),
          shadow: Color(0xFF000000),
          scrim: Color(0xFF000000),
          inverseSurface: Color(0xFFE3E3E3),
          onInverseSurface: Color(0xFF2F3033),
          inversePrimary: Color(0xFF0B57D0),
          surfaceTint: Color(0xFFA8C7FA),
        );
      case AppPalette.teal:
        return const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFF4EDAC5),
          onPrimary: Color(0xFF003730),
          primaryContainer: Color(0xFF005047),
          onPrimaryContainer: Color(0xFF70F7E4),
          secondary: Color(0xFFA4CEC8),
          onSecondary: Color(0xFF173935),
          secondaryContainer: Color(0xFF005047),
          onSecondaryContainer: Color(0xFF70F7E4),
          tertiary: Color(0xFF7ED9A8),
          onTertiary: Color(0xFF063A22),
          tertiaryContainer: Color(0xFF0F4D26),
          onTertiaryContainer: Color(0xFFA8F0BD),
          error: Color(0xFFF2B8B5),
          onError: Color(0xFF601410),
          errorContainer: Color(0xFF8C1D18),
          onErrorContainer: Color(0xFFF9DEDC),
          surface: Color(0xFF101414),
          onSurface: Color(0xFFDFE5E3),
          onSurfaceVariant: Color(0xFFBFC9C6),
          surfaceContainerLowest: Color(0xFF0B0E0D),
          surfaceContainerLow: Color(0xFF181C1B),
          surfaceContainer: Color(0xFF1C2020),
          surfaceContainerHigh: Color(0xFF242828),
          surfaceContainerHighest: Color(0xFF2F3533),
          outline: Color(0xFF899392),
          outlineVariant: Color(0xFF3F4948),
          shadow: Color(0xFF000000),
          scrim: Color(0xFF000000),
          inverseSurface: Color(0xFFDFE5E3),
          onInverseSurface: Color(0xFF2C3231),
          inversePrimary: Color(0xFF006A60),
          surfaceTint: Color(0xFF4EDAC5),
        );
      case AppPalette.orange:
        return const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFFFFB787),
          onPrimary: Color(0xFF512300),
          primaryContainer: Color(0xFF743100),
          onPrimaryContainer: Color(0xFFFFDBCA),
          secondary: Color(0xFFE2B98D),
          onSecondary: Color(0xFF40290A),
          secondaryContainer: Color(0xFF743100),
          onSecondaryContainer: Color(0xFFFFDBCA),
          tertiary: Color(0xFFB1D18A),
          onTertiary: Color(0xFF223600),
          tertiaryContainer: Color(0xFF354E16),
          onTertiaryContainer: Color(0xFFCDF0A3),
          error: Color(0xFFF2B8B5),
          onError: Color(0xFF601410),
          errorContainer: Color(0xFF8C1D18),
          onErrorContainer: Color(0xFFF9DEDC),
          surface: Color(0xFF161310),
          onSurface: Color(0xFFE9E1D9),
          onSurfaceVariant: Color(0xFFCFC0B0),
          surfaceContainerLowest: Color(0xFF0E0C0A),
          surfaceContainerLow: Color(0xFF1D1A16),
          surfaceContainer: Color(0xFF211D18),
          surfaceContainerHigh: Color(0xFF2A251F),
          surfaceContainerHighest: Color(0xFF363027),
          outline: Color(0xFF99897D),
          outlineVariant: Color(0xFF4E4439),
          shadow: Color(0xFF000000),
          scrim: Color(0xFF000000),
          inverseSurface: Color(0xFFE9E1D9),
          onInverseSurface: Color(0xFF352E24),
          inversePrimary: Color(0xFFA23C00),
          surfaceTint: Color(0xFFFFB787),
        );
      case AppPalette.purple:
        return const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFFD0BCFF),
          onPrimary: Color(0xFF381E72),
          primaryContainer: Color(0xFF4F378B),
          onPrimaryContainer: Color(0xFFEADDFF),
          secondary: Color(0xFFC4C0E0),
          onSecondary: Color(0xFF2D2D4D),
          secondaryContainer: Color(0xFF4F378B),
          onSecondaryContainer: Color(0xFFEADDFF),
          tertiary: Color(0xFF7ED9A8),
          onTertiary: Color(0xFF063A22),
          tertiaryContainer: Color(0xFF0F4D26),
          onTertiaryContainer: Color(0xFFA8F0BD),
          error: Color(0xFFF2B8B5),
          onError: Color(0xFF601410),
          errorContainer: Color(0xFF8C1D18),
          onErrorContainer: Color(0xFFF9DEDC),
          surface: Color(0xFF141218),
          onSurface: Color(0xFFE6E0E9),
          onSurfaceVariant: Color(0xFFCAC4D0),
          surfaceContainerLowest: Color(0xFF0F0D13),
          surfaceContainerLow: Color(0xFF1D1B20),
          surfaceContainer: Color(0xFF211F26),
          surfaceContainerHigh: Color(0xFF2B2930),
          surfaceContainerHighest: Color(0xFF36343B),
          outline: Color(0xFF938F99),
          outlineVariant: Color(0xFF49454F),
          shadow: Color(0xFF000000),
          scrim: Color(0xFF000000),
          inverseSurface: Color(0xFFE6E0E9),
          onInverseSurface: Color(0xFF322F35),
          inversePrimary: Color(0xFF6750A4),
          surfaceTint: Color(0xFFD0BCFF),
        );
      case AppPalette.bentoWarm:
        return AppThemeWarm.darkScheme;
    }
  }
}

/// Kept for the warm option — the previous hand-tuned bento schemes.
abstract class AppThemeWarm {
  static const lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF5C3A21),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFF3DDB8),
    onPrimaryContainer: Color(0xFF33200E),
    secondary: Color(0xFF7A5C3A),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFEAD9B8),
    onSecondaryContainer: Color(0xFF33200E),
    tertiary: Color(0xFF2E7D48),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFCDE9D4),
    onTertiaryContainer: Color(0xFF0B3D20),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFF9DEDC),
    onErrorContainer: Color(0xFF410E0B),
    surface: Color(0xFFFFF8EE),
    onSurface: Color(0xFF221A10),
    onSurfaceVariant: Color(0xFF524639),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFFFFDF7),
    surfaceContainer: Color(0xFFF7EDDC),
    surfaceContainerHigh: Color(0xFFF1E4CC),
    surfaceContainerHighest: Color(0xFFE9D9BE),
    outline: Color(0xFF85736A),
    outlineVariant: Color(0xFFD3C2A6),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF362E24),
    onInverseSurface: Color(0xFFF9EFE2),
    inversePrimary: Color(0xFFE5BE8A),
    surfaceTint: Color(0xFF5C3A21),
  );

  static const darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFF5D6A0),
    onPrimary: Color(0xFF3A2410),
    primaryContainer: Color(0xFF5C3A21),
    onPrimaryContainer: Color(0xFFF3DDB8),
    secondary: Color(0xFFE8C99A),
    onSecondary: Color(0xFF3A2410),
    secondaryContainer: Color(0xFF5C3A21),
    onSecondaryContainer: Color(0xFFF3DDB8),
    tertiary: Color(0xFF6BB98A),
    onTertiary: Color(0xFF0B3D20),
    tertiaryContainer: Color(0xFF1E4A2E),
    onTertiaryContainer: Color(0xFFCDE9D4),
    error: Color(0xFFF2B8B5),
    onError: Color(0xFF601410),
    errorContainer: Color(0xFF8C1D18),
    onErrorContainer: Color(0xFFF9DEDC),
    surface: Color(0xFF1A120E),
    onSurface: Color(0xFFF5E9D8),
    onSurfaceVariant: Color(0xFFD3C2A6),
    surfaceContainerLowest: Color(0xFF120D09),
    surfaceContainerLow: Color(0xFF2A1F1A),
    surfaceContainer: Color(0xFF2E241C),
    surfaceContainerHigh: Color(0xFF383026),
    surfaceContainerHighest: Color(0xFF453A2C),
    outline: Color(0xFF99897D),
    outlineVariant: Color(0xFF4E4439),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFF5E9D8),
    onInverseSurface: Color(0xFF362E24),
    inversePrimary: Color(0xFF5C3A21),
    surfaceTint: Color(0xFFF5D6A0),
  );
}

const _paletteKey = 'app_palette';

/// Selected palette, persisted. Defaults to neutral blue.
final appPaletteProvider = StateNotifierProvider<AppPaletteNotifier, AppPalette>((ref) {
  return AppPaletteNotifier();
});

class AppPaletteNotifier extends StateNotifier<AppPalette> {
  AppPaletteNotifier() : super(AppPalette.neutralBlue) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_paletteKey);
      if (name != null) {
        state = AppPalette.values.firstWhere(
          (p) => p.name == name,
          orElse: () => AppPalette.neutralBlue,
        );
      }
    } catch (_) {}
  }

  Future<void> setPalette(AppPalette palette) async {
    state = palette;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_paletteKey, palette.name);
    } catch (_) {}
  }
}
