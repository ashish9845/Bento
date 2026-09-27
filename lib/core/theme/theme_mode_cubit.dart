import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'theme_mode';

/// In-app theme choice, persisted. Defaults to system.
class ThemeModeCubit extends Cubit<ThemeMode> {
  new() : super(ThemeMode.system) {
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      emit(_fromString(prefs.getString(_key)));
    } on Exception catch (_) {}
  }

  Future<void> setMode(ThemeMode mode) async {
    emit(mode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, _toString(mode));
    } on Exception catch (_) {}
  }

  static ThemeMode _fromString(String? v) {
    switch (v) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _toString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
