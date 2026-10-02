import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:pdf_manipulator/io.dart';
import 'package:pdf_manipulator/pdf_manipulator.dart';

import '../../../core/storage/storage_location.dart';
import 'images_to_pdf_builder.dart';

/// Parses UI range specs like "1-3, 5, 7-end" (1-based, "end" = last page)
/// into 0-based page-index chunks. Throws [FormatException] on bad input.
List<List<int>> parsePageRanges(String spec, int pageCount) {
  final chunks = <List<int>>[];
  for (final rawPart in spec.split(',')) {
    final part = rawPart.trim().toLowerCase();
    if (part.isEmpty) continue;
    if (part.contains('-')) {
      final bounds = part.split('-');
      if (bounds.length != 2) {
        throw FormatException('Bad range "$rawPart" — use like 1-3');
      }
      final start = _parsePageNumber(bounds[0].trim(), pageCount, rawPart) - 1;
      final end = bounds[1].trim() == 'end'
          ? pageCount
          : _parsePageNumber(bounds[1].trim(), pageCount, rawPart);
      if (start < 0 || end > pageCount || start >= end) {
        throw FormatException('Range "$rawPart" is outside 1-$pageCount');
      }
      chunks.add([for (var i = start; i < end; i++) i]);
    } else {
      final page = _parsePageNumber(part, pageCount, rawPart) - 1;
      chunks.add([page]);
    }
  }
  if (chunks.isEmpty) {
    throw const FormatException('Enter at least one range, e.g. 1-2, 3, 4-end');
  }
  return chunks;
}

int _parsePageNumber(String token, int pageCount, String rawPart) {
  final n = int.tryParse(token);
  if (n == null || n < 1 || n > pageCount) {
    throw FormatException('"$rawPart" is outside 1-$pageCount');
  }
  return n;
}

/// Native PDF engine backed by a Rust core
/// over FFI — no WebView, no JS, no WASM. One shared [Pdf] instance, every
/// operation already runs off the main thread inside the engine.
abstract class PdfEngineDataSource {
  Future<int> pageCount(File input, {String? password});
  Future<File> merge(List<File> inputs, {String? outputName});
  Future<List<File>> split(File input, String rangesSpec, {String? baseName});
  Future<File> extract(File input, List<int> pages, {String? outputName});
  Future<File> organize(
    File input, {
    Set<int> delete = const {},
    Map<int, int> rotations = const {},
    List<int>? order,
    String? outputName,
  });
  Future<File> compress(
    File input,
    PdfImagePolicy policy, {
    String? outputName,
  });
  Future<File> imagesToPdf(List<File> images, {String? outputName});
  Future<List<File>> renderPages(
    File input, {
    int maxSize = 1440,
    String? outputName,
  });

  /// Small page previews for the Organize grid. Written to temp (never shown
  /// in Files) and keyed by original page index order.
  Future<List<File>> renderThumbnails(File input, {int maxSize = 360});
  Future<File> signPdf(
    File input, {
    required Uint8List signaturePng,
    required int page,
    double widthPts = 140,
    String? outputName,
  });
  Future<File> protectPdf(
    File input, {
    required String userPassword,
    String? ownerPassword,
    String? outputName,
  });
  Future<File> unlockPdf(
    File input, {
    required String password,
    String? outputName,
  });
  Future<void> saveToCustomLocation(File file);
}

class PdfEngineDataSourceImpl implements PdfEngineDataSource {
  /// Shared engine instance reused everywhere (per package guidance).
  static final Pdf _pdf = Pdf();

  Future<File> _outputFile(
    String prefix, {
    String? name,
    String extension = 'pdf',
  }) async {
    final dir = (await getSaveDirectory()).path;
    String base = (name?.trim().isNotEmpty ?? false
        ? name!.trim()
        : '${prefix}_${DateTime.now().millisecondsSinceEpoch}');
    if (!base.toLowerCase().endsWith('.$extension')) base = '$base.$extension';
    base = base.replaceAll(RegExp(r'[^\w\-. ]'), '_');
    var out = File('$dir/$base');
    var counter = 1;
    while (await out.exists()) {
      final stem = base.replaceAll(
        RegExp('\\.$extension\$', caseSensitive: false),
        '',
      );
      out = File('$dir/${stem}_$counter.$extension');
      counter++;
    }
    return out;
  }

  /// Re-opens an engine output and proves it decodes: non-empty file,
  /// expected page count, first page renders. Deletes corrupt output and
  /// throws instead of handing a broken file to the user. Pass [password]
  /// when the output itself is encrypted (Protect PDF).
  Future<void> _verifyPdf(
    File file, {
    required int expectedPages,
    String? password,
  }) async {
    final len = await file.length();
    if (len == 0) {
      try {
        await file.delete();
      } on Exception catch (_) {}
      throw Exception('Engine produced an empty file — please retry');
    }
    PdfDoc? doc;
    try {
      doc = await _pdf.open(FileSource(file), password: password);
      if (doc.pageCount != expectedPages) {
        throw Exception(
          'Output has ${doc.pageCount} pages, expected $expectedPages — please retry',
        );
      }
      var rendered = false;
      await for (final page in doc.render(
        pages: PdfPages.single(0),
        size: const PdfRenderSize.thumbnail(200),
      )) {
        if (page.data.isEmpty) {
          throw Exception('Output failed a render check — please retry');
        }
        rendered = true;
      }
      if (!rendered) {
        throw Exception('Output failed a render check — please retry');
      }
      debugPrint(
        '[PdfEngine] verified ${file.path.split('/').last}: $len bytes, $expectedPages pages',
      );
    } finally {
      await doc?.dispose();
    }
  }

  Never _wrap(Object e) {
    if (e is PdfPasswordRequired) {
      throw Exception('This PDF is password-protected — unlock it first');
    }
    if (e is PdfWrongPassword) {
      throw Exception('Wrong password for this PDF');
    }
    if (e is PdfCorrupted) {
      throw Exception('This file is not a valid PDF (corrupted)');
    }
    if (e is PdfError) {
      // The 5.x bridge surfaces crypto failures as PdfEngineError with Rust
      // messages ("password required: …", "wrong password") rather than the
      // typed PdfPasswordRequired/PdfWrongPassword — match on text.
      final msg = e.message.toLowerCase();
      if (msg.contains('password required') ||
          msg.contains('password-protected')) {
        throw Exception('This PDF is password-protected — unlock it first');
      }
      if (msg.contains('wrong password') ||
          msg.contains('incorrect password') ||
          msg.contains('invalid password')) {
        throw Exception('Wrong password for this PDF');
      }
      throw Exception(e.message);
    }
    throw Exception(e.toString().replaceFirst('Exception: ', ''));
  }

  @override
  Future<int> pageCount(File input, {String? password}) async {
    try {
      final doc = await _pdf.open(FileSource(input), password: password);
      try {
        return doc.pageCount;
      } finally {
        await doc.dispose();
      }
    } on Exception catch (e) {
      _wrap(e);
    }
  }

  @override
  Future<File> merge(List<File> inputs, {String? outputName}) async {
    if (inputs.length < 2) throw Exception('Pick at least 2 PDFs to merge');
    var total = 0;
    for (final f in inputs) {
      total += await pageCount(f);
    }
    final out = await _outputFile('merged', name: outputName);
    final sink = await FileSink.create(out);
    try {
      await _pdf.merge(inputs.map(FileSource.new).toList(), sink);
    } on Exception catch (e) {
      _wrap(e);
    } finally {
      await sink.close();
    }
    await _verifyPdf(out, expectedPages: total);
    return out;
  }

  @override
  Future<List<File>> split(
    File input,
    String rangesSpec, {
    String? baseName,
  }) async {
    final count = await pageCount(input);
    final chunks = parsePageRanges(rangesSpec, count);
    final stem =
        (baseName?.trim().isNotEmpty ?? false
                ? baseName!.trim()
                : input.path
                      .split('/')
                      .last
                      .replaceAll(RegExp(r'\.pdf$', caseSensitive: false), ''))
            .replaceAll(RegExp(r'[^\w\-. ]'), '_');
    final results = <File>[];
    for (var i = 0; i < chunks.length; i++) {
      final out = await _outputFile('${stem}_part${i + 1}');
      final sink = await FileSink.create(out);
      try {
        await _pdf.extractPages(FileSource(input), sink, pages: chunks[i]);
      } on Exception catch (e) {
        _wrap(e);
      } finally {
        await sink.close();
      }
      await _verifyPdf(out, expectedPages: chunks[i].length);
      results.add(out);
    }
    return results;
  }

  @override
  Future<File> extract(
    File input,
    List<int> pages, {
    String? outputName,
  }) async {
    if (pages.isEmpty) throw Exception('Select at least one page to extract');
    final count = await pageCount(input);
    final valid = pages.where((p) => p >= 0 && p < count).toList();
    if (valid.isEmpty) {
      throw Exception(
        'Selected pages are outside this $count-page PDF — reselect and retry',
      );
    }
    final sorted = [...valid]..sort();
    final out = await _outputFile('extracted', name: outputName);
    final sink = await FileSink.create(out);
    try {
      await _pdf.extractPages(FileSource(input), sink, pages: sorted);
    } on Exception catch (e) {
      _wrap(e);
    } finally {
      await sink.close();
    }
    await _verifyPdf(out, expectedPages: sorted.length);
    return out;
  }

  @override
  Future<File> organize(
    File input, {
    Set<int> delete = const {},
    Map<int, int> rotations = const {},
    List<int>? order,
    String? outputName,
  }) async {
    final count = await pageCount(input);
    // Final order in original indices: explicit order (minus deleted) or natural.
    final natural = [for (var i = 0; i < count; i++) i];
    final finalOrder = (order ?? natural)
        .where((i) => !delete.contains(i))
        .toList();
    if (finalOrder.isEmpty) {
      throw Exception('Deleting every page would leave an empty PDF');
    }
    // Remap rotations (tracked on original indices) into working-list
    // positions. Every copy of a rotated page rotates, including duplicates.
    final newRotations = <int, int>{};
    for (var pos = 0; pos < finalOrder.length; pos++) {
      final deg = (rotations[finalOrder[pos]] ?? 0) % 360;
      if (deg != 0) newRotations[pos] = deg;
    }
    final out = await _outputFile('organized', name: outputName);
    final sink = await FileSink.create(out);
    PdfEditor? editor;
    try {
      editor = await _pdf.edit(FileSource(input));
      if (finalOrder.length != count || !_isNaturalOrder(finalOrder, count)) {
        await editor.selectPages(finalOrder);
      } else if (delete.isNotEmpty) {
        await editor.selectPages(finalOrder);
      }
      for (final entry in newRotations.entries) {
        await editor.rotatePage(entry.key, degrees: entry.value % 360);
      }
      await editor.save(sink);
    } on Exception catch (e) {
      _wrap(e);
    } finally {
      await editor?.dispose();
      await sink.close();
    }
    await _verifyPdf(out, expectedPages: finalOrder.length);
    return out;
  }

  bool _isNaturalOrder(List<int> order, int count) {
    if (order.length != count) return false;
    for (var i = 0; i < count; i++) {
      if (order[i] != i) return false;
    }
    return true;
  }

  @override
  Future<File> compress(
    File input,
    PdfImagePolicy policy, {
    String? outputName,
  }) async {
    final count = await pageCount(input);
    final out = await _outputFile('compressed', name: outputName);
    final sink = await FileSink.create(out);
    try {
      await _pdf.compress(FileSource(input), sink, images: policy);
    } on Exception catch (e) {
      _wrap(e);
    } finally {
      await sink.close();
    }
    await _verifyPdf(out, expectedPages: count);
    return out;
  }

  @override
  Future<File> imagesToPdf(List<File> images, {String? outputName}) async {
    if (images.isEmpty) throw Exception('Pick at least one image');
    // A4 pages with contain-fit at the PDF layout level (white margins,
    // never stretched): no pixel decode/resize, so this stays fast for
    // full-res photos. Unreadable files are skipped, like the Scan export.
    // File handles can't cross the isolate boundary — only paths can.
    final srcPaths = images.map((f) => f.path).toList();
    ({Uint8List bytes, int pages}) built;
    try {
      built = await Isolate.run(() => buildImagesToA4Pdf(srcPaths));
    } catch (e) {
      _wrap(e);
    }
    final out = await _outputFile('images', name: outputName);
    await out.writeAsBytes(built.bytes, flush: true);
    await _verifyPdf(out, expectedPages: built.pages);
    return out;
  }

  @override
  Future<List<File>> renderPages(
    File input, {
    int maxSize = 1440,
    String? outputName,
  }) async {
    final rawStem =
        (outputName?.trim().isNotEmpty ?? false
                ? outputName!.trim()
                : input.path.split('/').last)
            .replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '');
    final sanitized = rawStem.replaceAll(RegExp(r'[^\w\-. ]'), '_');
    final safeStem = sanitized.isEmpty ? 'pdf_images' : sanitized;
    final baseDir = (await getSaveDirectory()).path;
    // One folder per PDF: <saveDir>/<pdf-name>/p1.png, p2.png, …
    var folder = Directory('$baseDir/$safeStem');
    var folderCounter = 1;
    while (await folder.exists()) {
      folder = Directory('$baseDir/${safeStem}_$folderCounter');
      folderCounter++;
    }
    await folder.create(recursive: true);
    try {
      return await _renderInto(folder, input, maxSize: maxSize, prefix: 'p');
    } on Exception catch (_) {
      // Never leave empty folders behind on total failure.
      try {
        final leftovers = await folder.list().toList();
        if (leftovers.isEmpty) await folder.delete(recursive: true);
      } on Exception catch (_) {}
      rethrow;
    }
  }

  @override
  Future<List<File>> renderThumbnails(File input, {int maxSize = 360}) async {
    final temp = await getTemporaryDirectory();
    final folder = Directory(
      '${temp.path}/bento_thumbs_${DateTime.now().millisecondsSinceEpoch}',
    );
    await folder.create(recursive: true);
    try {
      return await _renderInto(folder, input, maxSize: maxSize, prefix: 't');
    } on Exception catch (_) {
      try {
        await folder.delete(recursive: true);
      } on Exception catch (_) {}
      rethrow;
    }
  }

  /// Renders every page of [input] as PNGs into [folder], one bad page at a
  /// time so a single failure can't poison the whole batch. Never writes
  /// 0-byte files.
  Future<List<File>> _renderInto(
    Directory folder,
    File input, {
    required int maxSize,
    required String prefix,
  }) async {
    final doc = await _pdf.open(FileSource(input));
    final results = <File>[];
    final failures = <int>[];
    try {
      final count = doc.pageCount;
      if (count < 1) throw Exception('This PDF has no pages');
      for (var i = 0; i < count; i++) {
        try {
          var rendered = false;
          await for (final page in doc.render(
            pages: PdfPages.single(i),
            size: PdfRenderSize(maxWidth: maxSize, maxHeight: maxSize),
          )) {
            if (page.data.isEmpty) {
              throw Exception('renderer returned no data');
            }
            final out = File('${folder.path}/$prefix${i + 1}.png');
            await out.writeAsBytes(page.data, flush: true);
            final len = await out.length();
            if (len == 0) {
              try {
                await out.delete();
              } on Exception catch (_) {}
              throw Exception('write produced an empty file');
            }
            debugPrint(
              '[PdfEngine] rendered page ${i + 1}/$count: ${page.width}x${page.height}, $len bytes',
            );
            results.add(out);
            rendered = true;
          }
          if (!rendered) throw Exception('renderer returned no pages');
        } on Exception catch (e) {
          debugPrint('[PdfEngine] page ${i + 1} failed: $e');
          failures.add(i + 1);
        }
      }
    } on Exception catch (e) {
      _wrap(e);
    } finally {
      await doc.dispose();
    }
    if (results.isEmpty) {
      if (failures.isNotEmpty) {
        throw Exception(
          'Could not render page(s) ${failures.join(', ')} from this PDF',
        );
      }
      throw Exception('No pages could be rendered from this PDF');
    }
    return results;
  }

  @override
  Future<File> signPdf(
    File input, {
    required Uint8List signaturePng,
    required int page,
    double widthPts = 140,
    String? outputName,
  }) async {
    final count = await pageCount(input);
    final targetPage = page.clamp(0, count - 1);
    // Preserve the drawn aspect ratio so the signature never stretches.
    var aspect = 2.0;
    try {
      final decoded = img.decodeImage(signaturePng);
      if (decoded != null && decoded.height > 0) {
        aspect = decoded.width / decoded.height;
      }
    } on Exception catch (_) {}
    final out = await _outputFile('signed', name: outputName);
    final sink = await FileSink.create(out);
    PdfEditor? editor;
    try {
      editor = await _pdf.edit(FileSource(input));
      final media = await editor.pageMediaBox(targetPage);
      final w = widthPts;
      final h = w / aspect;
      const margin = 36.0;
      await editor.addImageStamp(
        targetPage,
        MemorySource(signaturePng),
        rect: PdfRect(
          x: (media.x + media.width - margin - w)
              .clamp(0.0, media.width)
              .toDouble(),
          y: media.y + margin,
          width: w,
          height: h,
        ),
      );
      await editor.save(sink);
    } on Exception catch (e) {
      _wrap(e);
    } finally {
      await editor?.dispose();
      await sink.close();
    }
    await _verifyPdf(out, expectedPages: count);
    return out;
  }

  @override
  Future<File> protectPdf(
    File input, {
    required String userPassword,
    String? ownerPassword,
    String? outputName,
  }) async {
    if (userPassword.isEmpty) {
      throw Exception('Enter a password to protect this PDF');
    }
    final count = await pageCount(input);
    // A distinct owner password locks usage down (no printing, copying,
    // modifying, annotating); without one the file just needs the user
    // password to open. Owner falls back to the user password so the file
    // is never left owner-less.
    final owner = (ownerPassword?.isNotEmpty ?? false)
        ? ownerPassword!
        : userPassword;
    final restricted = owner != userPassword;
    final out = await _outputFile('protected', name: outputName);
    final sink = await FileSink.create(out);
    PdfEditor? editor;
    try {
      editor = await _pdf.edit(FileSource(input));
      await editor.save(
        sink,
        options: PdfSaveOptions.fullRewrite(
          encryption: PdfEncryption.config(
            ownerPassword: owner,
            userPassword: userPassword,
            algorithm: PdfEncryptionAlgorithm.aes256,
            permissions: restricted
                ? const PdfPermissions.readOnly()
                : const PdfPermissions.all(),
          ),
        ),
      );
    } on Exception catch (e) {
      _wrap(e);
    } finally {
      await editor?.dispose();
      await sink.close();
    }
    await _verifyPdf(out, expectedPages: count, password: userPassword);
    return out;
  }

  @override
  Future<File> unlockPdf(
    File input, {
    required String password,
    String? outputName,
  }) async {
    if (password.isEmpty) throw Exception('Enter the password for this PDF');
    final count = await pageCount(input, password: password);
    final out = await _outputFile('unlocked', name: outputName);
    final sink = await FileSink.create(out);
    PdfEditor? editor;
    try {
      editor = await _pdf.edit(FileSource(input), password: password);
      await editor.save(
        sink,
        options: const PdfSaveOptions.fullRewrite(
          encryption: PdfEncryption.remove(),
        ),
      );
    } on Exception catch (e) {
      _wrap(e);
    } finally {
      await editor?.dispose();
      await sink.close();
    }
    await _verifyPdf(out, expectedPages: count);
    return out;
  }

  @override
  Future<void> saveToCustomLocation(File file) async {
    final target = (await getSaveDirectory()).path;
    final dest = '$target/${file.path.split('/').last}';
    if (dest != file.path) {
      await file.copy(dest);
    }
  }
}
