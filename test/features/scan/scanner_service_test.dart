import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:scan/features/scan/scanner_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Scan export: composing JPEGs to PDF must complete off the UI thread and
/// produce a valid file — even for a single page (the old code built
/// ≤2-page PDFs inline, hanging the UI on full-res camera photos).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory sandbox;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sandbox = await Directory.systemTemp.createTemp('bento_scan_export');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => sandbox.path,
        );
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
    if (await sandbox.exists()) await sandbox.delete(recursive: true);
  });

  Future<String> snapPhoto(int seed) async {
    final photo = img.Image(width: 800, height: 1000);
    img.fill(photo, color: img.ColorRgb8(200 + seed, 200, 200));
    img.drawString(
      photo,
      'page $seed',
      font: img.arial14,
      x: 40,
      y: 40,
      color: img.ColorRgb8(20, 20, 20),
    );
    final file = File('${sandbox.path}/photo_$seed.jpg');
    await file.writeAsBytes(img.encodeJpg(photo, quality: 90));
    return file.path;
  }

  test('single page composes to a valid PDF', () async {
    final paths = [await snapPhoto(1)];

    final pdf = await ScannerService().imagesToPdf(paths, outputName: 'one');

    expect(pdf.path.endsWith('.pdf'), isTrue);
    final bytes = await pdf.readAsBytes();
    expect(bytes.length, greaterThan(1000));
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  test('undecodable files are skipped without failing the export', () async {
    final good = await snapPhoto(1);
    final bad = File('${sandbox.path}/photo_bad.jpg');
    await bad.writeAsBytes([0, 1, 2, 3, 4, 5]);

    final pdf = await ScannerService().imagesToPdf(
      [good, bad.path],
      outputName: 'mixed',
    );

    final bytes = await pdf.readAsBytes();
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    final markers = RegExp(r'/Type\s*/Page[^s]').allMatches(
      String.fromCharCodes(bytes),
    );
    expect(markers.length, 1);
  });

  test('multi-page composes all pages in order', () async {
    final paths = [await snapPhoto(1), await snapPhoto(2), await snapPhoto(3)];

    final pdf = await ScannerService().imagesToPdf(paths, outputName: 'three');

    final bytes = await pdf.readAsBytes();
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    // One /Type /Page per input image (plus the /Pages tree object).
    final markers = RegExp(r'/Type\s*/Page[^s]').allMatches(
      String.fromCharCodes(bytes),
    );
    expect(markers.length, 3);
  });
}
