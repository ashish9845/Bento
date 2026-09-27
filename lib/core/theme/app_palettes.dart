// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Theme system ported from mpvRx (app.gyrolet.mpvrx, AGPL-3.0-or-later):
// the same 32-theme table and the same scheme-derivation rules (alpha
// composites over tinted backgrounds, 4.5:1 minimum-contrast enforcement).
// Only the mechanics are ported — no mpvRx code is copied verbatim.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Selectable color themes. [dynamic] follows the OS Material You palette
/// and falls back to [defaultPalette] where unsupported; everything else is
/// generated from its 8 seed colors by [_ThemeGenerator].
enum AppPalette {
  defaultPalette('Default', Icons.palette_rounded),
  dynamic('Dynamic', Icons.wallpaper_rounded),
  catppuccin('Catppuccin', Icons.cookie_rounded),
  aurora('Aurora', Icons.north_rounded),
  cloudflare('Cloudflare', Icons.cloud_rounded),
  cottonCandy('Cotton Candy', Icons.cake_rounded),
  doom('Doom', Icons.whatshot_rounded),
  greenApple('Green Apple', Icons.eco_rounded),
  gruvbox('Gruvbox', Icons.texture_rounded),
  kanagawa('Kanagawa', Icons.waves_rounded),
  lavender('Lavender', Icons.local_florist_rounded),
  midnight('Midnight', Icons.nights_stay_rounded),
  mocha('Mocha', Icons.coffee_rounded),
  strawberry('Strawberry', Icons.favorite_rounded),
  tidal('Tidal', Icons.water_rounded),
  nord('Nord', Icons.ac_unit_rounded),
  rosePine('Rose Pine', Icons.park_rounded),
  takoGreen('Tako Green', Icons.forest_rounded),
  tokyoNight('Tokyo Night', Icons.location_city_rounded),
  yinYang('Yin Yang', Icons.contrast_rounded),
  yotsuba('Yotsuba', Icons.wb_sunny_rounded),
  sapphire('Sapphire', Icons.diamond_rounded),
  sunset('Sunset', Icons.wb_twilight_rounded),
  ocean('Ocean', Icons.sailing_rounded),
  forest('Forest', Icons.nature_rounded),
  roseGold('Rose Gold', Icons.watch_rounded),
  violet('Violet', Icons.blur_on_rounded),
  amber('Amber', Icons.lightbulb_rounded),
  coral('Coral', Icons.beach_access_rounded),
  slate('Slate', Icons.view_quilt_rounded),
  dracula('Dracula', Icons.dark_mode_rounded),
  monochrome('Monochrome', Icons.circle_rounded);

  const AppPalette(this.label, this.icon);
  final String label;
  final IconData icon;

  /// Static scheme for [brightness]. Dynamic resolves via [resolve] instead
  /// (needs the OS-provided scheme).
  ColorScheme _schemeFor(Brightness brightness) =>
      brightness == Brightness.light
      ? _ThemeGenerator.lightScheme(_themeTable[this]!)
      : _ThemeGenerator.darkScheme(_themeTable[this]!);

  /// Resolve this palette to a concrete scheme, applying the OS dynamic
  /// scheme when this is [dynamic] and one is available.
  ColorScheme resolve(Brightness brightness, {ColorScheme? dynamicScheme}) {
    if (this == AppPalette.dynamic) {
      if (dynamicScheme != null) return dynamicScheme;
      return AppPalette.defaultPalette._schemeFor(brightness);
    }
    return _schemeFor(brightness);
  }

  ColorScheme get lightScheme => _schemeFor(Brightness.light);
  ColorScheme get darkScheme => _schemeFor(Brightness.dark);
}

/// The 8 seed colors per theme: primary/secondary/tertiary/background,
/// each in light and dark variants.
class _ThemeColors {
  const _ThemeColors({
    required this.primaryLight,
    required this.primaryDark,
    required this.secondaryLight,
    required this.secondaryDark,
    required this.tertiaryLight,
    required this.tertiaryDark,
    required this.backgroundLight,
    required this.backgroundDark,
  });

  final Color primaryLight;
  final Color primaryDark;
  final Color secondaryLight;
  final Color secondaryDark;
  final Color tertiaryLight;
  final Color tertiaryDark;
  final Color backgroundLight;
  final Color backgroundDark;
}

const _themeTable = <AppPalette, _ThemeColors>{
  AppPalette.defaultPalette: _ThemeColors(
    primaryLight: Color(0xFF794F81),
    primaryDark: Color(0xFFE8B5EF),
    secondaryLight: Color(0xFF6A596C),
    secondaryDark: Color(0xFFD6C0D6),
    tertiaryLight: Color(0xFF82524D),
    tertiaryDark: Color(0xFFF5B7B0),
    backgroundLight: Color(0xFFF7F5F8),
    backgroundDark: Color(0xFF161217),
  ),
  AppPalette.dynamic: _ThemeColors(
    primaryLight: Color(0xFF6750A4),
    primaryDark: Color(0xFFD0BCFF),
    secondaryLight: Color(0xFF625B71),
    secondaryDark: Color(0xFFCCC2DC),
    tertiaryLight: Color(0xFF7D5260),
    tertiaryDark: Color(0xFFEFB8C8),
    backgroundLight: Color(0xFFFFFBFF),
    backgroundDark: Color(0xFF1C1B1F),
  ),
  AppPalette.catppuccin: _ThemeColors(
    primaryLight: Color(0xFF4C6B9A),
    primaryDark: Color(0xFF9BA8CF),
    secondaryLight: Color(0xFFB76B8F),
    secondaryDark: Color(0xFFD4A5B8),
    tertiaryLight: Color(0xFFB8763E),
    tertiaryDark: Color(0xFF8AB8A8),
    backgroundLight: Color(0xFFEFF1F5),
    backgroundDark: Color(0xFF1E1E2E),
  ),
  AppPalette.aurora: _ThemeColors(
    primaryLight: Color(0xFF0B3FA0),
    primaryDark: Color(0xFF5B93FF),
    secondaryLight: Color(0xFF5C6B8C),
    secondaryDark: Color(0xFF9FAEC9),
    tertiaryLight: Color(0xFF3648A6),
    tertiaryDark: Color(0xFF97A8FF),
    backgroundLight: Color(0xFFF3F6FF),
    backgroundDark: Color(0xFF04070F),
  ),
  AppPalette.cloudflare: _ThemeColors(
    primaryLight: Color(0xFFF6821F),
    primaryDark: Color(0xFFFFB77C),
    secondaryLight: Color(0xFF6B5E4C),
    secondaryDark: Color(0xFFD6C5AC),
    tertiaryLight: Color(0xFF855316),
    tertiaryDark: Color(0xFFFABD71),
    backgroundLight: Color(0xFFFFFBF7),
    backgroundDark: Color(0xFF1A1612),
  ),
  AppPalette.cottonCandy: _ThemeColors(
    primaryLight: Color(0xFFE993C1),
    primaryDark: Color(0xFFFFB1D5),
    secondaryLight: Color(0xFF70A2C2),
    secondaryDark: Color(0xFF9ED0EF),
    tertiaryLight: Color(0xFF9C68AC),
    tertiaryDark: Color(0xFFDEB0E9),
    backgroundLight: Color(0xFFFFF8FA),
    backgroundDark: Color(0xFF1A1418),
  ),
  AppPalette.doom: _ThemeColors(
    primaryLight: Color(0xFFBB2929),
    primaryDark: Color(0xFFFF6B6B),
    secondaryLight: Color(0xFF6B5353),
    secondaryDark: Color(0xFFD6BABA),
    tertiaryLight: Color(0xFF8C4A4A),
    tertiaryDark: Color(0xFFFFB4AB),
    backgroundLight: Color(0xFFFFF8F7),
    backgroundDark: Color(0xFF1A1010),
  ),
  AppPalette.greenApple: _ThemeColors(
    primaryLight: Color(0xFF2E7D32),
    primaryDark: Color(0xFF81C784),
    secondaryLight: Color(0xFF4A6349),
    secondaryDark: Color(0xFFB0CFB1),
    tertiaryLight: Color(0xFF3D7B5F),
    tertiaryDark: Color(0xFF8FD5B7),
    backgroundLight: Color(0xFFF6FFF6),
    backgroundDark: Color(0xFF0F1A0F),
  ),
  AppPalette.gruvbox: _ThemeColors(
    primaryLight: Color(0xFF9D5B3F),
    primaryDark: Color(0xFFD89B6A),
    secondaryLight: Color(0xFF7A7556),
    secondaryDark: Color(0xFFB0AE8A),
    tertiaryLight: Color(0xFF4A7B7C),
    tertiaryDark: Color(0xFF8AAFA8),
    backgroundLight: Color(0xFFFBF1C7),
    backgroundDark: Color(0xFF282828),
  ),
  AppPalette.kanagawa: _ThemeColors(
    primaryLight: Color(0xFF5A7785),
    primaryDark: Color(0xFF7E9CD8),
    secondaryLight: Color(0xFF8A7A6E),
    secondaryDark: Color(0xFFDCA561),
    tertiaryLight: Color(0xFF6A8E7F),
    tertiaryDark: Color(0xFF98BB6C),
    backgroundLight: Color(0xFFF2ECBC),
    backgroundDark: Color(0xFF1F1F28),
  ),
  AppPalette.lavender: _ThemeColors(
    primaryLight: Color(0xFF7C5AB8),
    primaryDark: Color(0xFFCFBCFF),
    secondaryLight: Color(0xFF635B70),
    secondaryDark: Color(0xFFCBC3DA),
    tertiaryLight: Color(0xFF7E525A),
    tertiaryDark: Color(0xFFF2B8C1),
    backgroundLight: Color(0xFFFCF8FF),
    backgroundDark: Color(0xFF16121A),
  ),
  AppPalette.midnight: _ThemeColors(
    primaryLight: Color(0xFF0D47A1),
    primaryDark: Color(0xFF90CAF9),
    secondaryLight: Color(0xFF455A64),
    secondaryDark: Color(0xFFB0BEC5),
    tertiaryLight: Color(0xFF1565C0),
    tertiaryDark: Color(0xFF64B5F6),
    backgroundLight: Color(0xFFF5F9FF),
    backgroundDark: Color(0xFF0D1117),
  ),
  AppPalette.mocha: _ThemeColors(
    primaryLight: Color(0xFF795548),
    primaryDark: Color(0xFFBCAAA4),
    secondaryLight: Color(0xFF5D4037),
    secondaryDark: Color(0xFFA1887F),
    tertiaryLight: Color(0xFF6D4C41),
    tertiaryDark: Color(0xFFD7CCC8),
    backgroundLight: Color(0xFFFFF9F5),
    backgroundDark: Color(0xFF1A1512),
  ),
  AppPalette.strawberry: _ThemeColors(
    primaryLight: Color(0xFFD81B60),
    primaryDark: Color(0xFFF48FB1),
    secondaryLight: Color(0xFF6B4958),
    secondaryDark: Color(0xFFD6B0C1),
    tertiaryLight: Color(0xFFC2185B),
    tertiaryDark: Color(0xFFF8BBD9),
    backgroundLight: Color(0xFFFFF5F8),
    backgroundDark: Color(0xFF1A1015),
  ),
  AppPalette.tidal: _ThemeColors(
    primaryLight: Color(0xFF00796B),
    primaryDark: Color(0xFF80CBC4),
    secondaryLight: Color(0xFF4A635E),
    secondaryDark: Color(0xFFB0CFC9),
    tertiaryLight: Color(0xFF00897B),
    tertiaryDark: Color(0xFF4DB6AC),
    backgroundLight: Color(0xFFF2FFFD),
    backgroundDark: Color(0xFF0F1A18),
  ),
  AppPalette.nord: _ThemeColors(
    primaryLight: Color(0xFF5E81AC),
    primaryDark: Color(0xFF88C0D0),
    secondaryLight: Color(0xFF4C566A),
    secondaryDark: Color(0xFFD8DEE9),
    tertiaryLight: Color(0xFFB48EAD),
    tertiaryDark: Color(0xFFD8A9C4),
    backgroundLight: Color(0xFFECEFF4),
    backgroundDark: Color(0xFF2E3440),
  ),
  AppPalette.rosePine: _ThemeColors(
    primaryLight: Color(0xFF907AA9),
    primaryDark: Color(0xFFC4A7E7),
    secondaryLight: Color(0xFFB4637A),
    secondaryDark: Color(0xFFEBBCBA),
    tertiaryLight: Color(0xFF7A9A8A),
    tertiaryDark: Color(0xFF9CCFD8),
    backgroundLight: Color(0xFFFAF4ED),
    backgroundDark: Color(0xFF232136),
  ),
  AppPalette.takoGreen: _ThemeColors(
    primaryLight: Color(0xFF66BB6A),
    primaryDark: Color(0xFFA5D6A7),
    secondaryLight: Color(0xFF546E7A),
    secondaryDark: Color(0xFF90A4AE),
    tertiaryLight: Color(0xFF43A047),
    tertiaryDark: Color(0xFF81C784),
    backgroundLight: Color(0xFFF5FFF5),
    backgroundDark: Color(0xFF121A12),
  ),
  AppPalette.tokyoNight: _ThemeColors(
    primaryLight: Color(0xFF3D5A80),
    primaryDark: Color(0xFF7D9BC1),
    secondaryLight: Color(0xFF6B5B95),
    secondaryDark: Color(0xFFA89DC9),
    tertiaryLight: Color(0xFF4A6B5C),
    tertiaryDark: Color(0xFF8AB4A3),
    backgroundLight: Color(0xFFF0F1F5),
    backgroundDark: Color(0xFF1A1B26),
  ),
  AppPalette.yinYang: _ThemeColors(
    primaryLight: Color(0xFF424242),
    primaryDark: Color(0xFFBDBDBD),
    secondaryLight: Color(0xFF616161),
    secondaryDark: Color(0xFFE0E0E0),
    tertiaryLight: Color(0xFF757575),
    tertiaryDark: Color(0xFFEEEEEE),
    backgroundLight: Color(0xFFFAFAFA),
    backgroundDark: Color(0xFF121212),
  ),
  AppPalette.yotsuba: _ThemeColors(
    primaryLight: Color(0xFFFF8A65),
    primaryDark: Color(0xFFFFAB91),
    secondaryLight: Color(0xFF6D5D5B),
    secondaryDark: Color(0xFFD6C4C2),
    tertiaryLight: Color(0xFFFF7043),
    tertiaryDark: Color(0xFFFFCCBC),
    backgroundLight: Color(0xFFFFF8F5),
    backgroundDark: Color(0xFF1A1412),
  ),
  AppPalette.sapphire: _ThemeColors(
    primaryLight: Color(0xFF1E88E5),
    primaryDark: Color(0xFF64B5F6),
    secondaryLight: Color(0xFF5C6BC0),
    secondaryDark: Color(0xFF9FA8DA),
    tertiaryLight: Color(0xFF0288D1),
    tertiaryDark: Color(0xFF4FC3F7),
    backgroundLight: Color(0xFFF3F8FF),
    backgroundDark: Color(0xFF0D1620),
  ),
  AppPalette.sunset: _ThemeColors(
    primaryLight: Color(0xFFE65100),
    primaryDark: Color(0xFFFF9E80),
    secondaryLight: Color(0xFFEF6C00),
    secondaryDark: Color(0xFFFFCC80),
    tertiaryLight: Color(0xFFF4511E),
    tertiaryDark: Color(0xFFFF8A65),
    backgroundLight: Color(0xFFFFF5F0),
    backgroundDark: Color(0xFF1A120D),
  ),
  AppPalette.ocean: _ThemeColors(
    primaryLight: Color(0xFF006064),
    primaryDark: Color(0xFF4DD0E1),
    secondaryLight: Color(0xFF00838F),
    secondaryDark: Color(0xFF80DEEA),
    tertiaryLight: Color(0xFF0097A7),
    tertiaryDark: Color(0xFF26C6DA),
    backgroundLight: Color(0xFFF0FFFF),
    backgroundDark: Color(0xFF0A1A1C),
  ),
  AppPalette.forest: _ThemeColors(
    primaryLight: Color(0xFF1B5E20),
    primaryDark: Color(0xFF66BB6A),
    secondaryLight: Color(0xFF33691E),
    secondaryDark: Color(0xFF9CCC65),
    tertiaryLight: Color(0xFF2E7D32),
    tertiaryDark: Color(0xFFA5D6A7),
    backgroundLight: Color(0xFFF1F8E9),
    backgroundDark: Color(0xFF0D1A0D),
  ),
  AppPalette.roseGold: _ThemeColors(
    primaryLight: Color(0xFFB76E79),
    primaryDark: Color(0xFFE8A9B0),
    secondaryLight: Color(0xFFAD8075),
    secondaryDark: Color(0xFFDDBFB8),
    tertiaryLight: Color(0xFFD4A5A5),
    tertiaryDark: Color(0xFFF5D5D5),
    backgroundLight: Color(0xFFFFF5F5),
    backgroundDark: Color(0xFF1A1315),
  ),
  AppPalette.violet: _ThemeColors(
    primaryLight: Color(0xFF6A1B9A),
    primaryDark: Color(0xFFCE93D8),
    secondaryLight: Color(0xFF7B1FA2),
    secondaryDark: Color(0xFFE1BEE7),
    tertiaryLight: Color(0xFF8E24AA),
    tertiaryDark: Color(0xFFBA68C8),
    backgroundLight: Color(0xFFFCF5FF),
    backgroundDark: Color(0xFF150D1A),
  ),
  AppPalette.amber: _ThemeColors(
    primaryLight: Color(0xFFFF8F00),
    primaryDark: Color(0xFFFFCA28),
    secondaryLight: Color(0xFFFFA000),
    secondaryDark: Color(0xFFFFD54F),
    tertiaryLight: Color(0xFFFFB300),
    tertiaryDark: Color(0xFFFFE082),
    backgroundLight: Color(0xFFFFFBF0),
    backgroundDark: Color(0xFF1A1508),
  ),
  AppPalette.coral: _ThemeColors(
    primaryLight: Color(0xFFFF5252),
    primaryDark: Color(0xFFFF8A80),
    secondaryLight: Color(0xFFFF6E40),
    secondaryDark: Color(0xFFFFAB91),
    tertiaryLight: Color(0xFFFF7043),
    tertiaryDark: Color(0xFFFFCCBC),
    backgroundLight: Color(0xFFFFF5F5),
    backgroundDark: Color(0xFF1A1010),
  ),
  AppPalette.slate: _ThemeColors(
    primaryLight: Color(0xFF455A64),
    primaryDark: Color(0xFF90A4AE),
    secondaryLight: Color(0xFF546E7A),
    secondaryDark: Color(0xFFB0BEC5),
    tertiaryLight: Color(0xFF607D8B),
    tertiaryDark: Color(0xFFCFD8DC),
    backgroundLight: Color(0xFFF5F7F8),
    backgroundDark: Color(0xFF151A1C),
  ),
  AppPalette.dracula: _ThemeColors(
    primaryLight: Color(0xFF6272A4),
    primaryDark: Color(0xFFBD93F9),
    secondaryLight: Color(0xFF44475A),
    secondaryDark: Color(0xFFFF79C6),
    tertiaryLight: Color(0xFF50FA7B),
    tertiaryDark: Color(0xFF8BE9FD),
    backgroundLight: Color(0xFFF8F8F2),
    backgroundDark: Color(0xFF282A36),
  ),
  AppPalette.monochrome: _ThemeColors(
    primaryLight: Color(0xFF212121),
    primaryDark: Color(0xFFE0E0E0),
    secondaryLight: Color(0xFF424242),
    secondaryDark: Color(0xFFBDBDBD),
    tertiaryLight: Color(0xFF616161),
    tertiaryDark: Color(0xFF9E9E9E),
    backgroundLight: Color(0xFFFFFFFF),
    backgroundDark: Color(0xFF0A0A0A),
  ),
};

/// Scheme derivation ported from mpvRx: containers and surfaces are alpha
/// composites of the accents over the background, accents are nudged until
/// they hit 4.5:1 contrast against every surface they sit on.
abstract class _ThemeGenerator {
  static const _softOn = Color(0xFFFFF9FC);

  static ColorScheme lightScheme(_ThemeColors t) {
    final bgL = t.backgroundLight;
    final primaryContainer = _over(t.primaryLight.withValues(alpha: 0.22), bgL);
    final secondaryContainer = _over(
      t.secondaryLight.withValues(alpha: 0.22),
      bgL,
    );
    final tertiaryContainer = _over(
      t.tertiaryLight.withValues(alpha: 0.22),
      bgL,
    );
    final surfaceVariant = _over(
      t.primaryLight.withValues(alpha: 0.10),
      _darken(bgL, 0.035),
    );
    final surfaceDim = _darken(bgL, 0.075);
    final surfaceBright = _lighten(bgL, 0.012);
    final lowest = _lighten(bgL, 0.018);
    final low = _over(t.primaryLight.withValues(alpha: 0.030), bgL);
    final container = _over(t.primaryLight.withValues(alpha: 0.050), bgL);
    final high = _over(t.primaryLight.withValues(alpha: 0.075), bgL);
    final highest = _over(t.primaryLight.withValues(alpha: 0.105), bgL);
    final accentSurfaces = [
      bgL,
      surfaceVariant,
      surfaceDim,
      surfaceBright,
      lowest,
      low,
      container,
      high,
      highest,
    ];
    final primary = _minContrast(t.primaryLight, accentSurfaces);
    final secondary = _minContrast(t.secondaryLight, accentSurfaces);
    final tertiary = _minContrast(t.tertiaryLight, accentSurfaces);
    return ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: _contentFor(primary),
      primaryContainer: primaryContainer,
      onPrimaryContainer: _contentFor(primaryContainer),
      secondary: secondary,
      onSecondary: _contentFor(secondary),
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: _contentFor(secondaryContainer),
      tertiary: tertiary,
      onTertiary: _contentFor(tertiary),
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: _contentFor(tertiaryContainer),
      error: const Color(0xFFBA1A1A),
      onError: _softOn,
      errorContainer: const Color(0xFFFFDAD6),
      onErrorContainer: const Color(0xFF93000A),
      surface: bgL,
      onSurface: const Color(0xFF1C1B1F),
      surfaceDim: surfaceDim,
      surfaceBright: surfaceBright,
      surfaceContainerLowest: lowest,
      surfaceContainerLow: low,
      surfaceContainer: container,
      surfaceContainerHigh: high,
      surfaceContainerHighest: highest,
      onSurfaceVariant: const Color(0xFF49454F),
      outline: _over(
        t.secondaryLight.withValues(alpha: 0.6),
        const Color(0xFF79747E),
      ),
      outlineVariant: _over(
        t.primaryLight.withValues(alpha: 0.20),
        const Color(0xFFCAC4D0),
      ),
      shadow: const Color(0xFF000000),
      scrim: const Color(0xFF000000),
      inverseSurface: t.backgroundDark,
      onInverseSurface: const Color(0xFFF4EFF4),
      inversePrimary: _minContrast(t.primaryDark, [t.backgroundDark]),
      surfaceTint: primary,
      // ignore: deprecated_member_use
      background: bgL,
      // ignore: deprecated_member_use
      onBackground: const Color(0xFF1C1B1F),
      // ignore: deprecated_member_use
      surfaceVariant: surfaceVariant,
    );
  }

  static ColorScheme darkScheme(_ThemeColors t) {
    const darkBase = Color(0xFF2A2A2A);
    final bgD = t.backgroundDark;
    final primaryContainer = _darken(t.primaryLight, 0.2);
    final secondaryContainer = _darken(t.secondaryLight, 0.2);
    final tertiaryContainer = _darken(t.tertiaryLight, 0.2);
    final surfaceVariant = _over(
      t.primaryDark.withValues(alpha: 0.18),
      darkBase,
    );
    final lowest = _darken(bgD, 0.2);
    final low = _over(t.primaryDark.withValues(alpha: 0.08), bgD);
    final container = _over(t.primaryDark.withValues(alpha: 0.08), bgD);
    final high = _over(t.primaryDark.withValues(alpha: 0.12), bgD);
    final highest = _over(t.primaryDark.withValues(alpha: 0.16), bgD);
    final accentSurfaces = [
      bgD,
      surfaceVariant,
      lowest,
      low,
      container,
      high,
      highest,
    ];
    final primary = _minContrast(t.primaryDark, accentSurfaces);
    final secondary = _minContrast(t.secondaryDark, accentSurfaces);
    final tertiary = _minContrast(t.tertiaryDark, accentSurfaces);
    return ColorScheme(
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: _contentFor(primary),
      primaryContainer: primaryContainer,
      onPrimaryContainer: _contentFor(primaryContainer),
      secondary: secondary,
      onSecondary: _contentFor(secondary),
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: _contentFor(secondaryContainer),
      tertiary: tertiary,
      onTertiary: _contentFor(tertiary),
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: _contentFor(tertiaryContainer),
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
      errorContainer: const Color(0xFF93000A),
      onErrorContainer: const Color(0xFFFFDAD6),
      surface: bgD,
      onSurface: const Color(0xFFE6E1E5),
      surfaceDim: bgD,
      surfaceBright: _over(
        t.primaryDark.withValues(alpha: 0.06),
        const Color(0xFF2A2A2A),
      ),
      surfaceContainerLowest: lowest,
      surfaceContainerLow: low,
      surfaceContainer: container,
      surfaceContainerHigh: high,
      surfaceContainerHighest: highest,
      onSurfaceVariant: const Color(0xFFCAC4D0),
      outline: _over(
        t.secondaryDark.withValues(alpha: 0.5),
        const Color(0xFF938F99),
      ),
      outlineVariant: _over(
        t.primaryDark.withValues(alpha: 0.22),
        const Color(0xFF49454F),
      ),
      shadow: const Color(0xFF000000),
      scrim: const Color(0xFF000000),
      inverseSurface: t.backgroundLight,
      onInverseSurface: const Color(0xFF313033),
      inversePrimary: _minContrast(t.primaryLight, [t.backgroundLight]),
      surfaceTint: primary,
      // ignore: deprecated_member_use
      background: bgD,
      // ignore: deprecated_member_use
      onBackground: const Color(0xFFE6E1E5),
      // ignore: deprecated_member_use
      surfaceVariant: surfaceVariant,
    );
  }

  /// fg.compositeOver(bg) — identical to Color.alphaBlend.
  static Color _over(Color fg, Color bg) => Color.alphaBlend(fg, bg);

  static Color _darken(Color c, double factor) => Color.from(
    alpha: c.a,
    red: (c.r * (1 - factor)).clamp(0.0, 1.0),
    green: (c.g * (1 - factor)).clamp(0.0, 1.0),
    blue: (c.b * (1 - factor)).clamp(0.0, 1.0),
  );

  static Color _lighten(Color c, double factor) => Color.from(
    alpha: c.a,
    red: (c.r + (1 - c.r) * factor).clamp(0.0, 1.0),
    green: (c.g + (1 - c.g) * factor).clamp(0.0, 1.0),
    blue: (c.b + (1 - c.b) * factor).clamp(0.0, 1.0),
  );

  static double _ratio(Color a, Color b) {
    final l1 = a.computeLuminance();
    final l2 = b.computeLuminance();
    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Pure black or pure white, whichever contrasts more.
  static Color _contentFor(Color c) =>
      _ratio(Color(0xFF000000), c) >= _ratio(Color(0xFFFFFFFF), c)
      ? const Color(0xFF000000)
      : const Color(0xFFFFFFFF);

  /// Bisect toward black/white until [c] hits 4.5:1 against every surface.
  static Color _minContrast(Color c, List<Color> backgrounds) {
    bool ok(Color x) => backgrounds.every((bg) => _ratio(x, bg) >= 4.5);
    if (ok(c)) return c;
    final blackOk = backgrounds
        .map((bg) => _ratio(const Color(0xFF000000), bg))
        .reduce((a, b) => a < b ? a : b);
    final whiteOk = backgrounds
        .map((bg) => _ratio(const Color(0xFFFFFFFF), bg))
        .reduce((a, b) => a < b ? a : b);
    final target = blackOk >= whiteOk
        ? const Color(0xFF000000)
        : const Color(0xFFFFFFFF);
    var lo = 0.0;
    var hi = 1.0;
    for (var i = 0; i < 12; i++) {
      final mid = (lo + hi) / 2;
      if (ok(Color.lerp(c, target, mid)!)) {
        hi = mid;
      } else {
        lo = mid;
      }
    }
    return Color.lerp(c, target, hi)!;
  }
}

const _paletteKey = 'app_palette';

/// Selected palette, persisted. Defaults to [AppPalette.defaultPalette];
/// unknown stored names (e.g. retired palettes) fall back to it.
final appPaletteProvider =
    StateNotifierProvider<AppPaletteNotifier, AppPalette>((ref) {
      return AppPaletteNotifier();
    });

class AppPaletteNotifier extends StateNotifier<AppPalette> {
  AppPaletteNotifier() : super(AppPalette.defaultPalette) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_paletteKey);
      if (name != null) {
        state = AppPalette.values.firstWhere(
          (p) => p.name == name,
          orElse: () => AppPalette.defaultPalette,
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
