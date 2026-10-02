import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scan/features/scan/cubit/scan_cubit.dart';

/// Scan recovery: the native stash written when the OS kills Bento mid-scan
/// and the ML Kit result is delivered to the recreated activity.
class _FakeMlKitScanner implements MlKitScannerGateway {
  new({this.scanResult, this.recovered = const []});

  List<String>? scanResult;
  List<String> recovered;
  int clearCalls = 0;

  @override
  Future<List<String>?> scan() async => scanResult;

  @override
  Future<List<String>> consumeRecoveredScan() async => recovered;

  @override
  Future<void> clearRecoveredScan() async {
    clearCalls++;
  }
}

void main() {
  test('recoverInterruptedScan keeps only paths that still exist', () async {
    final dir = await Directory.systemTemp.createTemp('bento_scan_recovery');
    addTearDown(() => dir.delete(recursive: true));
    final existing = File('${dir.path}/page_1.jpg')
      ..writeAsBytesSync([1, 2, 3]);
    final missing = File('${dir.path}/gone.jpg');
    final fake = _FakeMlKitScanner(
      recovered: [existing.path, missing.path, ''],
    );
    final cubit = ScanCubit(mlKitScanner: fake);
    addTearDown(cubit.close);

    expect(await cubit.recoverInterruptedScan(), [existing.path]);
  });

  test('recoverInterruptedScan is empty when nothing was stashed', () async {
    final fake = _FakeMlKitScanner();
    final cubit = ScanCubit(mlKitScanner: fake);
    addTearDown(cubit.close);

    expect(await cubit.recoverInterruptedScan(), isEmpty);
  });

  test('scanWithMlKit success emits the scanned pages', () async {
    final fake = _FakeMlKitScanner(scanResult: ['/a.jpg', '/b.jpg']);
    final cubit = ScanCubit(mlKitScanner: fake);
    addTearDown(cubit.close);

    await cubit.scanWithMlKit();

    expect(cubit.state.status, ScanStatus.success);
    expect(cubit.state.pages, ['/a.jpg', '/b.jpg']);
  });

  test('gateway clears the native stash after a normal scan', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final calls = <String>[];
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('com.benopdf.scan/scan_recovery'),
      (call) async {
        calls.add(call.method);
        return null;
      },
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('google_mlkit_document_scanner'),
      (call) async {
        if (call.method == 'vision#startDocumentScanner') {
          return <String, dynamic>{
            'images': ['/a.jpg'],
            'pdf': null,
          };
        }
        return null;
      },
    );
    addTearDown(() {
      messenger.setMockMethodCallHandler(
        const MethodChannel('com.benopdf.scan/scan_recovery'),
        null,
      );
      messenger.setMockMethodCallHandler(
        const MethodChannel('google_mlkit_document_scanner'),
        null,
      );
    });

    final pages = await MlKitScannerGatewayImpl().scan();

    expect(pages, ['/a.jpg']);
    expect(
      calls,
      containsAll(['beginScanSession', 'endScanSession', 'clearRecoveredScan']),
    );
  });

  test('gateway maps recovered pages from the native channel', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('com.benopdf.scan/scan_recovery'),
      (call) async => call.method == 'consumeRecoveredScan' ? ['/x.jpg'] : null,
    );
    addTearDown(() {
      messenger.setMockMethodCallHandler(
        const MethodChannel('com.benopdf.scan/scan_recovery'),
        null,
      );
    });

    expect(await MlKitScannerGatewayImpl().consumeRecoveredScan(), ['/x.jpg']);
  });
}
