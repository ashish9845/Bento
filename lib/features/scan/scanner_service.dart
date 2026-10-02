import 'dart:io';
import 'dart:isolate';

import 'package:scan/core/storage/storage_location.dart';
import 'package:scan/data/tools/datasources/images_to_pdf_builder.dart';

/// Composes scanned page images into a PDF via `pdf` + `image`
/// (native, no engine) — off main thread for 60fps.
/// Page capture itself is handled by the ML Kit document scanner, which
/// returns ready JPEG paths consumed by the Scan review flow.
class ScannerService {
  /// Compose image paths to PDF via `pdf` + `image` (native, no engine) — off main thread for 60fps.
  /// Saves once to the save directory (custom/default Documents) with [outputName].
  Future<File> imagesToPdf(
    List<String> imagePaths, {
    String? outputName,
  }) async {
    // JPEG decode + PDF embedding of full-res camera photos takes seconds:
    // always build in a background isolate so the UI never hangs, even for
    // a single page.
    final built = await Isolate.run(() => buildImagesToA4Pdf(imagePaths));
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
    await outFile.writeAsBytes(built.bytes);
    return outFile;
  }
}
