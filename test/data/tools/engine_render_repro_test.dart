import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_manipulator/pdf_manipulator.dart';

void main() {
  test('render image-heavy PDF reports data sizes', () async {
    // Build a PDF with a large JPEG photo page (like a scanned document)
    final photo = img.Image(width: 1200, height: 1600);
    img.fill(photo, color: img.ColorRgb8(200, 210, 220));
    img.drawLine(
      photo,
      x1: 0,
      y1: 0,
      x2: 1199,
      y2: 1599,
      color: img.ColorRgb8(30, 30, 30),
      thickness: 8,
    );
    final jpg = Uint8List.fromList(img.encodeJpg(photo, quality: 85));

    final doc = pw.Document();
    doc.addPage(
      pw.Page(build: (_) => pw.Center(child: pw.Image(pw.MemoryImage(jpg)))),
    );
    doc.addPage(pw.Page(build: (_) => pw.Center(child: pw.Text('text page'))));
    final bytes = await doc.save();

    final pdf = Pdf();
    try {
      final handle = await pdf.open(MemorySource(bytes));
      try {
        expect(handle.pageCount, 2);
        await for (final page in handle.render(
          pages: PdfPages.all(),
          size: const PdfRenderSize(maxWidth: 1440, maxHeight: 1440),
        )) {
          // Repro diagnostics: visible render output helps triage engine failures.
          debugPrint(
            'RENDERED ${page.width}x${page.height} data=${page.data.length} bytes',
          );
          expect(page.data.isNotEmpty, isTrue);
        }
        // Per-page render (the production export path): every page must
        // yield non-empty PNG bytes on its own.
        for (var i = 0; i < 2; i++) {
          var got = false;
          await for (final page in handle.render(
            pages: PdfPages.single(i),
            size: const PdfRenderSize(maxWidth: 1440, maxHeight: 1440),
          )) {
            expect(page.data.isNotEmpty, isTrue);
            got = true;
          }
          expect(got, isTrue, reason: 'page $i rendered nothing');
        }
      } finally {
        await handle.dispose();
      }
    } finally {
      await pdf.dispose();
    }
  });
}
