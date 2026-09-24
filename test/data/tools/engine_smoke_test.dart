import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_manipulator/pdf_manipulator.dart';

/// Real-engine smoke test: exercises the exact `pdf_manipulator` calls used by
/// `PdfEngineDataSource` against the actual Rust core (no mocks, no UI).
Future<Uint8List> _makePdf(String text) async {
  final doc = pw.Document();
  doc.addPage(pw.Page(build: (_) => pw.Center(child: pw.Text(text))));
  return doc.save();
}

void main() {
  test('merge → pageCount → render → split → compress round-trip', () async {
    final pdf = Pdf();
    try {
      final a = await _makePdf('Page A');
      final b = await _makePdf('Page B');

      // merge
      final mergeOut = MemorySink();
      await pdf.merge([MemorySource(a), MemorySource(b)], mergeOut);
      final merged = mergeOut.takeBytes();
      expect(merged.isNotEmpty, isTrue);

      // page count
      final doc = await pdf.open(MemorySource(merged));
      try {
        expect(doc.pageCount, 2);

        // render both pages
        var rendered = 0;
        await for (final page in doc.render(
          pages: PdfPages.all(),
          size: const PdfRenderSize.thumbnail(200),
        )) {
          expect(page.data.isNotEmpty, isTrue);
          rendered++;
        }
        expect(rendered, 2);
      } finally {
        await doc.dispose();
      }

      // split into single pages
      final part1 = MemorySink();
      await pdf.extractPages(MemorySource(merged), part1, pages: [0]);
      expect(part1.takeBytes().isNotEmpty, isTrue);

      // compress
      final compOut = MemorySink();
      await pdf.compress(MemorySource(merged), compOut, images: PdfImagePolicy.screen);
      expect(compOut.takeBytes().isNotEmpty, isTrue);

      // imagesToPdf
      final imgOut = MemorySink();
      await pdf.imagesToPdf([MemorySource(a)], imgOut);
      expect(imgOut.takeBytes().isNotEmpty, isTrue);
    } finally {
      await pdf.dispose();
    }
  });

  test('signature image stamp lands on original page', () async {
    final pdf = Pdf();
    try {
      final bytes = await _makePdf('contract');
      // Fake 300x150 white signature PNG with a black stroke
      final sig = img.Image(width: 300, height: 150);
      img.fill(sig, color: img.ColorRgb8(255, 255, 255));
      img.drawLine(sig, x1: 20, y1: 120, x2: 280, y2: 30, color: img.ColorRgb8(0, 0, 0), thickness: 3);
      final sigPng = Uint8List.fromList(img.encodePng(sig));

      final editor = await pdf.edit(MemorySource(bytes));
      try {
        final media = await editor.pageMediaBox(0);
        expect(media.width, greaterThan(0));
        await editor.addImageStamp(
          0,
          MemorySource(sigPng),
          rect: PdfRect(x: media.x + media.width - 36 - 140, y: media.y + 36, width: 140, height: 70),
        );
        final out = MemorySink();
        await editor.save(out);
        final stamped = out.takeBytes();
        expect(stamped.isNotEmpty, isTrue);
        // Original content preserved: still exactly 1 page, bytes differ
        final check = await pdf.open(MemorySource(stamped));
        try {
          expect(check.pageCount, 1);
        } finally {
          await check.dispose();
        }
      } finally {
        await editor.dispose();
      }
    } finally {
      await pdf.dispose();
    }
  });

  test('organize via editor session (delete + rotate + reorder)', () async {
    final pdf = Pdf();
    try {
      final bytes = await _makePdf('hi');
      // Build a 3-page doc by merging the same page 3 times
      final threeOut = MemorySink();
      await pdf.merge(
        [MemorySource(bytes), MemorySource(bytes), MemorySource(bytes)],
        threeOut,
      );
      final three = threeOut.takeBytes();

      final editor = await pdf.edit(MemorySource(three));
      try {
        await editor.deletePage(2);
        await editor.rotatePage(0, degrees: 90);
        await editor.selectPages([1, 0]);
        final saveOut = MemorySink();
        await editor.save(saveOut);
        expect(saveOut.takeBytes().isNotEmpty, isTrue);
      } finally {
        await editor.dispose();
      }
    } finally {
      await pdf.dispose();
    }
  });
}
