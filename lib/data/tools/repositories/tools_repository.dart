import 'dart:io';
import 'dart:typed_data';

import 'package:pdf_manipulator/pdf_manipulator.dart';

abstract class ToolsRepository {
  Future<int> pageCount(File input);
  Future<File> mergePdfs(List<File> inputs);
  Future<List<File>> splitPdf(File input, String rangesSpec);
  Future<File> extractPages(File input, List<int> pages);
  Future<File> organizePdf(
    File input, {
    Set<int> delete,
    Map<int, int> rotations,
    List<int>? order,
  });
  Future<File> compressPdf(File input, PdfImagePolicy policy);
  Future<File> imageToPdf(List<File> images, {String? outputName});
  Future<List<File>> renderPages(File input);
  Future<File> signPdf(
    File input, {
    required Uint8List signaturePng,
    required int page,
    double widthPts,
  });
  Future<void> saveFile(File file);
}
