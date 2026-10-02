import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/widgets.dart' as pw;
import 'package:scan/core/storage/storage_location.dart';

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
    final sw = Stopwatch()..start();
    final outBytes = await Isolate.run(() => _buildPdf(imagePaths));
    debugPrint(
      '[Scan] imagesToPdf: built ${imagePaths.length} page(s) in '
      '${sw.elapsedMilliseconds}ms (isolate)',
    );
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

/// Builds the PDF bytes from image [paths] — top-level so it runs in a
/// background isolate via [Isolate.run]. Pure Dart file IO + embed; no
/// platform channels in here.
///
/// Speed matters here: camera JPEGs are embedded untouched (`/DCTDecode`,
/// no decode/re-encode — same as `PdfImage.file`), so validity is a
/// microsecond header check, not a full decode. A full multi-MP decode
/// per photo is what made this step take 6x longer than the old inline
/// version; only non-JPEG files pay for `decodeImage`.
Future<Uint8List> _buildPdf(List<String> paths) async {
  final pdf = pw.Document();
  for (final path in paths) {
    final bytes = await File(path).readAsBytes();
    if (!img.JpegDecoder().isValidFile(bytes) &&
        img.decodeImage(bytes) == null) {
      continue; // Undecodable — skip instead of failing the whole export.
    }
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
