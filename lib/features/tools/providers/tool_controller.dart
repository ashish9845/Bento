import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

import 'tool_state.dart';

/// Generic controller for file→options→progress→result flow.
/// Each tool provides a `process` callback that may call EngineBridge or native pdf logic.
class ToolController extends StateNotifier<ToolState> {
  ToolController({this.processFn}) : super(const ToolState());

  final Future<List<File>> Function(List<File> inputs, ToolController ctrl)? processFn;

  void setFiles(List<File> files) {
    state = state.copyWith(files: files, status: ToolStatus.idle, message: null, resultFiles: []);
  }

  void addFiles(List<File> files) {
    state = state.copyWith(files: [...state.files, ...files], status: ToolStatus.idle);
  }

  void clearFiles() {
    state = const ToolState();
  }

  void setError(String msg) {
    state = state.copyWith(status: ToolStatus.error, message: msg);
  }

  void setProgress(double? p, String msg) {
    state = state.copyWith(status: ToolStatus.processing, progress: p, message: msg);
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
      final out = File('${temp.path}/result_${DateTime.now().millisecondsSinceEpoch}.pdf');
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
      state = state.copyWith(status: ToolStatus.success, resultFiles: results, message: 'Done', progress: 1);
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
    String targetDir;
    try {
      final prefs = await SharedPreferences.getInstance();
      final custom = prefs.getString('storage_location');
      if (custom != null && await Directory(custom).exists()) {
        targetDir = custom;
      } else {
        targetDir = (await getApplicationDocumentsDirectory()).path;
      }
    } catch (_) {
      targetDir = (await getApplicationDocumentsDirectory()).path;
    }
    for (final f in state.resultFiles) {
      final name = f.path.split('/').last;
      await f.copy('$targetDir/$name');
    }
    state = state.copyWith(message: 'Saved to $targetDir');
  }
}
