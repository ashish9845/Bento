import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scan/data/tools/datasources/pdf_engine_data_source.dart';
import 'package:scan/features/scan/scanner_service.dart';

/// On-device benchmark for both images→PDF paths. Run with:
/// `flutter test integration_test/images_to_pdf_perf_test.dart -d <device>`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  test('time scan-export + engine imagesToPdf on large photos', () async {
    final tmp = await getTemporaryDirectory();
    final dir = Directory('${tmp.path}/perf_${DateTime.now().millisecondsSinceEpoch}');
    await dir.create(recursive: true);

    // 12 MP photos with texture (flat fills compress unrealistically well).
    final paths = <String>[];
    for (var i = 0; i < 3; i++) {
      final photo = img.Image(width: 4000, height: 3000);
      img.fill(photo, color: img.ColorRgb8(170, 185, 200));
      for (var r = 0; r < 400; r++) {
        img.fillRect(
          photo,
          x1: (r * 7919) % 3800,
          y1: (r * 4799) % 2800,
          x2: (r * 7919) % 3800 + 200,
          y2: (r * 4799) % 2800 + 200,
          color: img.ColorRgb8((r * 37) % 256, (r * 91) % 256, (r * 53) % 256),
        );
      }
      final f = File('${dir.path}/photo_$i.jpg');
      await f.writeAsBytes(img.encodeJpg(photo, quality: 92));
      paths.add(f.path);
    }
    final sizes = [for (final p in paths) await File(p).length()];
    // Benchmark output.
    // ignore: avoid_print
    print('PERF input sizes: $sizes');

    final sw = Stopwatch()..start();
    final scanPdf = await ScannerService().imagesToPdf(
      paths,
      outputName: 'perf_scan',
    );
    // Benchmark output.
    // ignore: avoid_print
    print(
      'PERF scan-export: ${sw.elapsedMilliseconds}ms '
      'out=${await scanPdf.length()}',
    );

    sw
      ..reset()
      ..start();
    final enginePdf = await PdfEngineDataSourceImpl().imagesToPdf(
      paths.map(File.new).toList(),
      outputName: 'perf_engine',
    );
    // Benchmark output.
    // ignore: avoid_print
    print(
      'PERF engine imagesToPdf: ${sw.elapsedMilliseconds}ms '
      'out=${await enginePdf.length()}',
    );

    await dir.delete(recursive: true);
  }, timeout: const Timeout(Duration(minutes: 15)));
}
