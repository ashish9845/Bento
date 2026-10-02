import 'package:flutter_test/flutter_test.dart';
import 'package:scan/core/error/error_reporting.dart';
import 'package:scan/features/settings/cubit/crash_reporting_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  tearDown(() {
    ErrorReporting.sentryEnabled = false;
  });

  test('defaults to off and keeps Sentry disabled', () async {
    SharedPreferences.setMockInitialValues({});
    final cubit = CrashReportingCubit();
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isFalse);
    expect(ErrorReporting.sentryEnabled, isFalse);
  });

  test('loads a persisted opt-in and enables Sentry', () async {
    SharedPreferences.setMockInitialValues({
      CrashReportingCubit.prefsKey: true,
    });
    final cubit = CrashReportingCubit();
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isTrue);
    expect(ErrorReporting.sentryEnabled, isTrue);
  });

  test('setEnabled persists and flips the gate both ways', () async {
    SharedPreferences.setMockInitialValues({});
    final cubit = CrashReportingCubit();
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);

    await cubit.setEnabled(true);
    expect(cubit.state, isTrue);
    expect(ErrorReporting.sentryEnabled, isTrue);

    await cubit.setEnabled(false);
    expect(cubit.state, isFalse);
    expect(ErrorReporting.sentryEnabled, isFalse);
    expect(
      (await SharedPreferences.getInstance())
          .getBool(CrashReportingCubit.prefsKey),
      isFalse,
    );
  });
}
