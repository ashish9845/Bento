import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan/data/tools/datasources/pdf_engine_data_source.dart';
import 'package:scan/data/tools/repositories/tools_repository.dart';
import 'package:scan/data/tools/repositories/tools_repository_impl.dart';

/// Shared FFI engine repository for the Riverpod tool screens.
/// Presentation (Bloc) screens get theirs per-route from `core/router/app_router.dart`.
final toolsRepositoryProvider = Provider<ToolsRepository>((ref) {
  return ToolsRepositoryImpl(PdfEngineDataSourceImpl());
});

/// Real page count for a picked PDF, keyed by file path.
final pdfPageCountProvider = FutureProvider.family<int, String>((ref, path) async {
  final repo = ref.watch(toolsRepositoryProvider);
  return repo.pageCount(File(path));
});
