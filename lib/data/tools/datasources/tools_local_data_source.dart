import 'dart:io';
import 'dart:isolate';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/storage/storage_location.dart';

abstract class ToolsLocalDataSource {
  Future<File> mergePdfs(List<File> inputs);
  Future<File> imageToPdf(List<File> images, {String? outputName});
  Future<void> saveToCustomLocation(File file);
}

class ToolsLocalDataSourceImpl implements ToolsLocalDataSource {
  @override
  Future<File> mergePdfs(List<File> inputs) async {
    // Placeholder — real impl delegates to EngineBridge via file URLs.
    // For strict arch demo, we simulate by copying first file.
    final temp = await getTemporaryDirectory();
    final out = File(
      '${temp.path}/merged_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await inputs.first.copy(out.path);
    return out;
  }

  @override
  Future<File> imageToPdf(List<File> images, {String? outputName}) async {
    // Hoisted: File handles can't cross the isolate boundary, only paths can.
    final paths = images.map((f) => f.path).toList();
    final outBytes = await Isolate.run(() async {
      final pdf = pw.Document();
      for (final p in paths) {
        final bytes = await File(p).readAsBytes();
        final image = pw.MemoryImage(bytes);
        pdf.addPage(
          pw.Page(
            build: (ctx) =>
                pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
          ),
        );
      }
      return await pdf.save();
    });
    // Save only once to the chosen location (custom/default Documents) to avoid duplicates in Files tab
    final saveDir = (await getSaveDirectory()).path;
    var baseName =
        outputName?.trim() ?? 'images_${DateTime.now().millisecondsSinceEpoch}';
    if (!baseName.toLowerCase().endsWith('.pdf')) baseName = '$baseName.pdf';
    // sanitize
    baseName = baseName.replaceAll(RegExp(r'[^\w\-. ]'), '_');
    final outFile = File('$saveDir/$baseName');
    // if exists, append counter
    var finalFile = outFile;
    var counter = 1;
    while (await finalFile.exists()) {
      final nameNoExt = baseName.replaceAll(
        RegExp(r'\.pdf$', caseSensitive: false),
        '',
      );
      finalFile = File('$saveDir/${nameNoExt}_$counter.pdf');
      counter++;
    }
    await finalFile.writeAsBytes(outBytes);
    return finalFile;
  }

  @override
  Future<void> saveToCustomLocation(File file) async {
    final target = (await getSaveDirectory()).path;
    await file.copy('$target/${file.path.split('/').last}');
  }
}
