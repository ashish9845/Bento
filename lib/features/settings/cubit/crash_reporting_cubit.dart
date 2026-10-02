import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/error/error_reporting.dart';

/// Crash-reporting opt-in. The user has full control over whether fatal
/// errors are sent to Sentry.
///
/// Defaults to OFF: nothing leaves the device until the user flips the
/// switch in Settings → Privacy. The choice persists in SharedPreferences
/// and is pushed into [ErrorReporting] so the sync `report()` path can
/// honor it without awaiting prefs on every crash. Console logging
/// (`ErrorReporting.log`, BlocObserver) is unaffected and always stays on.
class CrashReportingCubit extends Cubit<bool> {
  new() : super(false) {
    unawaited(_load());
  }

  static const prefsKey = 'crash_reporting_enabled';

  Future<void> _load() async {
    try {
      final enabled =
          (await SharedPreferences.getInstance()).getBool(prefsKey) ?? false;
      ErrorReporting.sentryEnabled = enabled;
      if (!isClosed) emit(enabled);
    } on Exception catch (e, s) {
      addError(e, s);
    }
  }

  Future<void> setEnabled(bool enabled) async {
    ErrorReporting.sentryEnabled = enabled;
    if (!isClosed) emit(enabled);
    try {
      await (await SharedPreferences.getInstance()).setBool(prefsKey, enabled);
    } on Exception catch (e, s) {
      addError(e, s);
    }
  }
}
