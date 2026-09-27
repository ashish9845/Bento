import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:pdf/widgets.dart' as pw;
import 'package:scan/core/storage/storage_location.dart';

/// Composes scanned page images into a PDF via `pdf` + `image`
/// (native, no engine) — off main thread for 60fps.
/// Page capture itself is handled by the OpenScan capture screen, which
/// returns ready JPEG paths consumed by the Scan review flow.
class ScannerService {
  /// Compose image paths to PDF via `pdf` + `image` (native, no engine) — off main thread for 60fps.
  /// Saves once to the save directory (custom/default Documents) with [outputName].
  Future<File> imagesToPdf(
    List<String> imagePaths, {
    String? outputName,
  }) async {
    // Run heavy work in isolate when many/large images to avoid jank
    Future<Uint8List> buildPdf() async {
      if (imagePaths.length > 2) {
        return await Isolate.run(() async {
          final pdf = pw.Document();
          for (final path in imagePaths) {
            final b = await File(path).readAsBytes();
            final decoded = img.decodeImage(b);
            if (decoded == null) continue;
            final image = pw.MemoryImage(b);
            pdf.addPage(
              pw.Page(
                build: (ctx) =>
                    pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
              ),
            );
          }
          return await pdf.save();
        });
      }
      final pdf = pw.Document();
      for (final path in imagePaths) {
        final bytes = await File(path).readAsBytes();
        final decoded = img.decodeImage(bytes);
        if (decoded == null) continue;
        final image = pw.MemoryImage(bytes);
        pdf.addPage(
          pw.Page(
            build: (ctx) =>
                pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
          ),
        );
      }
      return await pdf.save();
    }

    final outBytes = await buildPdf();
    final saveDir = (await getSaveDirectory()).path;
    var baseName =
        outputName?.trim() ?? 'scan_${DateTime.now().millisecondsSinceEpoch}';
    if (!baseName.toLowerCase().endsWith('.pdf')) baseName = '$baseName.pdf';
    baseName = baseName.replaceAll(RegExp(r'[^\w\-. ]'), '_');
    var outFile = File('$saveDir/$baseName');
    var counter = 1;
    while (await outFile.exists()) {
      final nameNoExt = baseName.replaceAll(
        RegExp(r'\.pdf$', caseSensitive: false),
        '',
      );
      outFile = File('$saveDir/${nameNoExt}_$counter.pdf');
      counter++;
    }
    await outFile.writeAsBytes(outBytes);
    return outFile;
  }
}
