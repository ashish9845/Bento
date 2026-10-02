/// Build-time flags, injected via `--dart-define`.
///
/// Unlike `kDebugMode` (true for every debug build), these are explicit
/// per-invocation opt-ins, e.g. `flutter run --dart-define=IS_DEBUG=true`.
/// Everything here is `const`, so disabled branches tree-shake out of
/// release builds entirely.
abstract final class AppConfig {
  /// Shows debug-only tooling such as the Settings Sentry probe button.
  /// Defaults to false — never on unless explicitly passed.
  static const isDebug = bool.fromEnvironment(
    'IS_DEBUG',
    defaultValue: false,
  );
}
