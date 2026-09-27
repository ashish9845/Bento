import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scan/core/storage/storage_location.dart';
import 'package:scan/data/tools/repositories/tools_repository.dart';

import 'tool_state.dart';

/// Generic cubit for file→options→progress→result flow.
/// Each tool provides a `process` callback that calls the FFI engine
/// repository or native `pdf`-package logic.
///
/// When [persistenceKey] is set, picked input files are mirrored to
/// SharedPreferences and restored on next launch — so a picked document
/// survives Android killing the app while a picker/scanner activity is in
/// front. Passwords and other options are never persisted.
class ToolCubit extends Cubit<ToolState> {
  new({required this.repository, this.processFn, this.persistenceKey})
    : super(const ToolState()) {
    if (persistenceKey != null) unawaited(_hydrate());
  }

  final ToolsRepository repository;

  final Future<List<File>> Function(List<File> inputs, ToolCubit ctrl)?
  processFn;

  /// Stable id per tool ('merge', 'split', …). Null disables persistence.
  final String? persistenceKey;

  /// Max restored paths — guards against unbounded growth.
  static const _maxPersisted = 20;

  String get _prefsKey => 'pending_tool_files_$persistenceKey';

  Future<void> _hydrate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final paths = prefs.getStringList(_prefsKey) ?? const [];
      final existing = paths
          .where((p) => p.isNotEmpty && File(p).existsSync())
          .take(_maxPersisted)
          .toList();
      if (isClosed) return;
      if (existing.isNotEmpty) {
        emit(state.copyWith(files: existing.map(File.new).toList()));
      } else if (existing.length != paths.length) {
        // Drop stale entries pointing at deleted files.
        await prefs.setStringList(_prefsKey, existing);
      }
    } on Exception catch (_) {}
  }

  Future<void> _persist() async {
    final key = persistenceKey;
    if (key == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _prefsKey,
        state.files.map((f) => f.path).take(_maxPersisted).toList(),
      );
    } on Exception catch (_) {}
  }

  /// File name chosen in the rename dialog before running. Read by each
  /// tool's `processFn` and forwarded to the repository as `outputName`.
  /// Persists across retries until files change or it is set again.
  String? outputName;

  void setFiles(List<File> files) {
    emit(
      state.copyWith(
        files: files,
        status: ToolStatus.idle,
        message: null,
        resultFiles: [],
      ),
    );
    unawaited(_persist());
  }

  void addFiles(List<File> files) {
    emit(
      state.copyWith(
        files: [...state.files, ...files],
        status: ToolStatus.idle,
      ),
    );
    unawaited(_persist());
  }

  void clearFiles() {
    emit(const ToolState());
    unawaited(_persist());
  }

  void setError(String msg) {
    emit(state.copyWith(status: ToolStatus.error, message: msg));
  }

  void setProgress(double? p, String msg) {
    emit(
      state.copyWith(status: ToolStatus.processing, progress: p, message: msg),
    );
  }

  Future<void> pickFiles({
    bool allowMultiple = false,
    List<String>? allowedExtensions,
  }) async {
    emit(state.copyWith(status: ToolStatus.picking));
    final type = allowedExtensions != null ? FileType.custom : FileType.any;
    if (allowMultiple) {
      final picked = await FilePicker.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
      );
      if (isClosed) return;
      if (picked.isEmpty) {
        emit(state.copyWith(status: ToolStatus.idle));
        return;
      }
      addFiles(_toFiles(picked));
    } else {
      final picked = await FilePicker.pickFile(
        type: type,
        allowedExtensions: allowedExtensions,
      );
      if (isClosed) return;
      final path = picked?.path;
      if (path == null || path.isEmpty) {
        emit(state.copyWith(status: ToolStatus.idle));
        return;
      }
      setFiles([File(path)]);
    }
  }

  static List<File> _toFiles(List<PlatformFile> picked) {
    return picked
        .where((f) => f.path != null && f.path!.isNotEmpty)
        .map((f) => File(f.path!))
        .toList();
  }

  /// Real page count for a picked PDF.
  Future<int> pageCount(File file) => repository.pageCount(file);

  /// Real page thumbnails (temp PNGs, original-page order) for grids.
  Future<List<File>> thumbnails(File file) => repository.renderThumbnails(file);

  Future<void> run() async {
    if (state.files.isEmpty) {
      setError('Pick a file first');
      return;
    }
    if (processFn == null) {
      // No engine yet — simulate placeholder result by copying first file to temp.
      setProgress(null, 'Processing (placeholder engine)…');
      await Future<void>.delayed(const Duration(milliseconds: 700));
      final temp = await getTemporaryDirectory();
      final out = File(
        '${temp.path}/result_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await state.files.first.copy(out.path);
      emit(
        state.copyWith(
          status: ToolStatus.success,
          message: 'Done (placeholder — engine bundle not yet built)',
          resultFiles: [out],
          progress: 1,
        ),
      );
      return;
    }
    setProgress(null, 'Processing…');
    try {
      final results = await processFn!(state.files, this);
      emit(
        state.copyWith(
          status: ToolStatus.success,
          resultFiles: results,
          message: 'Done',
          progress: 1,
        ),
      );
    } on Exception catch (e) {
      setError(e.toString());
    }
  }

  Future<void> shareResult() async {
    if (state.resultFiles.isEmpty) return;
    final xFiles = state.resultFiles.map((f) => XFile(f.path)).toList();
    await SharePlus.instance.share(ShareParams(files: xFiles));
  }

  Future<void> saveToDocuments() async {
    if (state.resultFiles.isEmpty) return;
    final targetDir = await getSaveDirectory();
    var actualDir = targetDir.path;
    for (final f in state.resultFiles) {
      final name = f.path.split('/').last;
      try {
        await f.copy('${targetDir.path}/$name');
      } on Exception catch (_) {
        // Shared storage blocked (scoped storage) — fall back to app documents.
        final docs = await getApplicationDocumentsDirectory();
        await f.copy('${docs.path}/$name');
        actualDir = docs.path;
      }
    }
    emit(state.copyWith(message: 'Saved to $actualDir'));
  }
}
