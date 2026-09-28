import 'package:flutter_test/flutter_test.dart';
import 'package:scan/features/scan/cubit/scan_session_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The in-flight flag lifecycle behind the scan-interruption recovery:
/// mark → consume reports once; clear/mark ordering never double-reports.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('consume is false with no scan ever started', () async {
    expect(await ScanSessionCubit.consumeInterrupted(), isFalse);
  });

  test('mark then consume reports once, then quiet', () async {
    final cubit = ScanSessionCubit();
    addTearDown(cubit.close);
    // Let the constructor hydrate settle first.
    await Future<void>.delayed(const Duration(milliseconds: 100));

    await cubit.markScanStarted();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(await ScanSessionCubit.consumeInterrupted(), isTrue);
    expect(await ScanSessionCubit.consumeInterrupted(), isFalse);
  });

  test('clear after mark means no interruption', () async {
    final cubit = ScanSessionCubit();
    addTearDown(cubit.close);
    await Future<void>.delayed(const Duration(milliseconds: 100));

    await cubit.markScanStarted();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await cubit.clearScanFlag();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(await ScanSessionCubit.consumeInterrupted(), isFalse);
  });
}
