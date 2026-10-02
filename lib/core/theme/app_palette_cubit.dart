import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_palettes.dart';

const _paletteKey = 'app_palette';

/// Selected palette, persisted. Defaults to [AppPalette.defaultPalette];
/// unknown stored names (e.g. retired palettes) fall back to it.
class AppPaletteCubit extends Cubit<AppPalette> {
  new() : super(AppPalette.defaultPalette) {
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_paletteKey);
      if (name != null) {
        emit(
          AppPalette.values.firstWhere(
            (p) => p.name == name,
            orElse: () => AppPalette.defaultPalette,
          ),
        );
      }
    } on Exception catch (e, s) {
      addError(e, s);
    }
  }

  Future<void> setPalette(AppPalette palette) async {
    emit(palette);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_paletteKey, palette.name);
    } on Exception catch (e, s) {
      addError(e, s);
    }
  }
}
