import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scan/core/storage/storage_location.dart';

import 'tool_state.dart';

/// Generic controller for file→options→progress→result flow.
/// Each tool provides a `process` callback that calls the FFI engine
/// repository or native `pdf`-package logic.
///
/// When [persistenceKey] is set, picked input files are mirrored to
/// SharedPreferences and restored on next launch — so a picked document
/// survives Android killing the app while a picker/scanner activity is in
/// front. Passwords and other options are never persisted.
class ToolController extends StateNotifier<ToolState> {
  ToolController({this.processFn, this.persistenceKey})
    : super(const ToolState()) {
    if (persistenceKey != null) _hydrate();
  }

  final Future<List<File>> Function(List<File> inputs, ToolController ctrl)?
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
      if (existing.isNotEmpty && mounted) {
        state = state.copyWith(files: existing.map(File.new).toList());
      } else if (existing.length != paths.length) {
        // Drop stale entries pointing at deleted files.
        await prefs.setStringList(_prefsKey, existing);
      }
    } catch (_) {}
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
    } catch (_) {}
  }

  /// File name chosen in the rename dialog before running. Read by each
  /// tool's `processFn` and forwarded to the repository as `outputName`.
  /// Persists across retries until files change or it is set again.
  String? outputName;

  void setFiles(List<File> files) {
    state = state.copyWith(
      files: files,
      status: ToolStatus.idle,
      message: null,
      resultFiles: [],
    );
    _persist();
  }

  void addFiles(List<File> files) {
    state = state.copyWith(
      files: [...state.files, ...files],
      status: ToolStatus.idle,
    );
    _persist();
  }

  void clearFiles() {
    state = const ToolState();
    _persist();
  }

  void setError(String msg) {
    state = state.copyWith(status: ToolStatus.error, message: msg);
  }

  void setProgress(double? p, String msg) {
    state = state.copyWith(
      status: ToolStatus.processing,
      progress: p,
      message: msg,
    );
  }

  Future<void> pickFiles({
    bool allowMultiple = false,
    List<String>? allowedExtensions,
  }) async {
    state = state.copyWith(status: ToolStatus.picking);
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: allowMultiple,
      type: allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: allowedExtensions,
    );
    if (result == null) {
      state = state.copyWith(status: ToolStatus.idle);
      return;
    }
    final files = result.paths.whereType<String>().map(File.new).toList();
    if (allowMultiple) {
      addFiles(files);
    } else {
      setFiles(files);
    }
  }

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
      state = state.copyWith(
        status: ToolStatus.success,
        message: 'Done (placeholder — engine bundle not yet built)',
        resultFiles: [out],
        progress: 1,
      );
      return;
    }
    setProgress(null, 'Processing…');
    try {
      final results = await processFn!(state.files, this);
      state = state.copyWith(
        status: ToolStatus.success,
        resultFiles: results,
        message: 'Done',
        progress: 1,
      );
    } catch (e) {
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
      } catch (_) {
        // Shared storage blocked (scoped storage) — fall back to app documents.
        final docs = await getApplicationDocumentsDirectory();
        await f.copy('${docs.path}/$name');
        actualDir = docs.path;
      }
    }
    state = state.copyWith(message: 'Saved to $actualDir');
  }
}
