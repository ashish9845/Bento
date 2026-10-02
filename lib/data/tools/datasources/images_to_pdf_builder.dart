import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Builds an A4 PDF (one page per image) from image [paths], shared by the
/// Scan export flow and the Image → PDF tool so the two can't drift apart.
///
/// Pages are A4 with the image fitted via contain: aspect ratio is kept
/// (white margins, never stretched) with zero pixel work — camera JPEGs are
/// embedded untouched (`/DCTDecode`, no decode/re-encode), so this is IO-bound
/// and fast even for full-res photos. Undecodable files are skipped; when
/// none of the inputs is readable it throws.
///
/// Top-level so callers can run it in a background isolate via `Isolate.run`.
/// Pure Dart file IO + PDF build — no platform channels in here.
Future<({Uint8List bytes, int pages})> buildImagesToA4Pdf(
  List<String> paths,
) async {
  final pdf = pw.Document();
  var added = 0;
  for (final path in paths) {
    final bytes = await File(path).readAsBytes();
    // JPEGs embed directly; only non-JPEGs pay for a full decode check.
    // decodeImage can throw Errors (not just Exceptions) on garbage input,
    // so guard broadly: anything unreadable is skipped, never fatal.
    var readable = false;
    try {
      readable =
          img.JpegDecoder().isValidFile(bytes) ||
          img.decodeImage(bytes) != null;
    } on Exception catch (_) {
      readable = false;
      // Deliberate: format sniffing throws Errors (e.g. RangeError) on
      // garbage input, and an unreadable file must skip, never crash.
      // ignore: avoid_catching_errors
    } on Error catch (_) {
      readable = false;
    }
    if (!readable) continue; // Skip instead of failing the whole export.
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => pw.Center(
          child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.contain),
        ),
      ),
    );
    added++;
  }
  if (added == 0) {
    throw Exception('Could not read any of the selected images');
  }
  return (bytes: await pdf.save(), pages: added);
}
