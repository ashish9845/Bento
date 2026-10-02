import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Single funnel for errors in the app, split in two on purpose:
///
/// * [log] prints to the console only (`adb logcat` / Xcode console) and
///   never touches Sentry. Use it for routine/best-effort catches.
/// * [report] sends to Sentry (plus a console line) for fatal or
///   genuinely unexpected failures. Pass `--dart-define=SENTRY_DSN=…` at
///   build time to enable sending; empty DSN disables it and the Sentry
///   call below no-ops. Sentry caches envelopes offline and uploads when
///   connectivity returns, so reporting degrades gracefully on this
///   offline-first app.
abstract final class ErrorReporting {
  /// Master switch for Sentry sending, driven by the crash-reporting
  /// opt-in cubit in Settings. Defaults to false (opt-in): console logging
  /// always works, but nothing is uploaded until the user enables crash
  /// reporting in Settings.
  static bool sentryEnabled = false;

  /// Console only. Never sends to Sentry.
  static void log(
    Object error,
    StackTrace? stackTrace, {
    String context = 'app',
  }) {
    debugPrint('[Error:$context] $error');
    debugPrint('${stackTrace ?? StackTrace.current}');
  }

  /// Sentry (+ console). Reserved for fatal/unexpected failures. No-op for
  /// sending when the user has not opted in via Settings → Privacy.
  static void report(
    Object error,
    StackTrace? stackTrace, {
    String context = 'app',
    bool fatal = false,
  }) {
    debugPrint('[Error:$context] $error');
    final stack = stackTrace ?? StackTrace.current;
    debugPrint('$stack');
    if (!sentryEnabled) return;
    Sentry.captureException(
      error,
      stackTrace: stack,
      withScope: (scope) async {
        await scope.setTag('context', context);
        scope.level = fatal ? SentryLevel.fatal : SentryLevel.error;
      },
    ).ignore();
  }
}
