import 'dart:io';
import 'dart:typed_data';

import 'package:pdf_manipulator/pdf_manipulator.dart';

abstract class ToolsRepository {
  Future<int> pageCount(File input);
  Future<File> mergePdfs(List<File> inputs, {String? outputName});
  Future<List<File>> splitPdf(
    File input,
    String rangesSpec, {
    String? baseName,
  });
  Future<File> extractPages(File input, List<int> pages, {String? outputName});
  Future<File> organizePdf(
    File input, {
    Set<int> delete,
    Map<int, int> rotations,
    List<int>? order,
    String? outputName,
  });
  Future<File> compressPdf(
    File input,
    PdfImagePolicy policy, {
    String? outputName,
  });
  Future<File> imageToPdf(List<File> images, {String? outputName});
  Future<List<File>> renderPages(File input, {String? outputName});
  Future<List<File>> renderThumbnails(File input);
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
  Future<File> signPdf(
    File input, {
    required Uint8List signaturePng,
    required int page,
    double widthPts,
    String? outputName,
  });
  Future<void> saveFile(File file);
}
