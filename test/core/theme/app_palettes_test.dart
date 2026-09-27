import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scan/core/theme/app_palette_cubit.dart';
import 'package:scan/core/theme/app_palettes.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AppPalette', () {
    test('all 32 palettes have labels and valid light/dark schemes', () {
      expect(AppPalette.values.length, 32);
      expect(
        AppPalette.values.map((p) => p.name),
        containsAll([
          'defaultPalette',
          'dynamic',
          'catppuccin',
          'lavender',
          'mocha',
          'dracula',
          'nord',
          'gruvbox',
          'kanagawa',
          'monochrome',
        ]),
      );
      for (final p in AppPalette.values) {
        expect(p.label.isNotEmpty, isTrue, reason: '${p.name} label');
        expect(
          p.lightScheme.brightness,
          Brightness.light,
          reason: '${p.name} light',
        );
        expect(
          p.darkScheme.brightness,
          Brightness.dark,
          reason: '${p.name} dark',
        );
      }
    });

    test('dynamic resolves to Default without an OS scheme', () {
      expect(
        AppPalette.dynamic.resolve(Brightness.light),
        AppPalette.defaultPalette.lightScheme,
      );
      expect(
        AppPalette.dynamic.resolve(Brightness.dark),
        AppPalette.defaultPalette.darkScheme,
      );
    });

    test('dynamic resolves to the OS scheme when provided', () {
      const os = ColorScheme.light(primary: Color(0xFF123456));
      expect(
        AppPalette.dynamic.resolve(Brightness.light, dynamicScheme: os),
        os,
      );
    });

    test('static palettes ignore any OS scheme', () {
      const os = ColorScheme.light(primary: Color(0xFF123456));
      expect(
        AppPalette.lavender.resolve(Brightness.light, dynamicScheme: os),
        AppPalette.lavender.lightScheme,
      );
    });

    test('cubit defaults to Default', () async {
      // The cubit hydrates from SharedPreferences on construction, which
      // needs a binding + mock store even though this test only asserts the
      // synchronous initial state (an un-awaited prefs lookup would otherwise
      // surface as an unhandled async error).
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      expect(AppPaletteCubit().state, AppPalette.defaultPalette);
      await Future<void>.delayed(Duration.zero);
    });
  });
}
