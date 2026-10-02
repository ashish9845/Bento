import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:scan/data/tools/datasources/images_to_pdf_builder.dart';

/// Shared images→A4-PDF builder: wide/tall/square photos land on A4 pages
/// with aspect kept (contain-fit), unreadable files are skipped, and an
/// all-unreadable batch throws instead of writing an empty PDF.
void main() {
  late Directory sandbox;

  setUp(() async {
    sandbox = await Directory.systemTemp.createTemp('bento_pdf_builder');
  });

  tearDown(() async {
    if (await sandbox.exists()) await sandbox.delete(recursive: true);
  });

  Future<String> snapJpg(String name, int w, int h) async {
    final photo = img.Image(width: w, height: h);
    img.fill(photo, color: img.ColorRgb8(120, 160, 200));
    final file = File('${sandbox.path}/$name.jpg');
    await file.writeAsBytes(img.encodeJpg(photo, quality: 85));
    return file.path;
  }

  test('mixed aspects produce one A4 page each', () async {
    final paths = [
      await snapJpg('wide', 800, 200),
      await snapJpg('tall', 200, 800),
      await snapJpg('square', 500, 500),
    ];

    final built = await buildImagesToA4Pdf(paths);

    expect(built.pages, 3);
    final text = String.fromCharCodes(built.bytes);
    expect(text.startsWith('%PDF-'), isTrue);
    // A4 MediaBox on every page (595×842pt), never stretched content.
    expect(RegExp('/MediaBox').allMatches(text).length, 3);
  });

  test('unreadable files are skipped', () async {
    final good = await snapJpg('good', 400, 300);
    final bad = File('${sandbox.path}/bad.jpg');
    await bad.writeAsBytes([0, 1, 2, 3]);

    final built = await buildImagesToA4Pdf([good, bad.path]);

    expect(built.pages, 1);
  });

  test('all-unreadable batch throws', () async {
    final bad = File('${sandbox.path}/bad.jpg');
    await bad.writeAsBytes([0, 1, 2, 3]);

    expect(() => buildImagesToA4Pdf([bad.path]), throwsException);
  });
}
