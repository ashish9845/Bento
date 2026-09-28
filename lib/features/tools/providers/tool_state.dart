import 'dart:io';

enum ToolStatus { idle, picking, processing, success, error }

class ToolState {
  const new({
    this.files = const [],
    this.status = ToolStatus.idle,
    this.message,
    this.resultFiles = const [],
    this.progress,
    this.fileSizes = const {},
  });

  final List<File> files;
  final ToolStatus status;
  final String? message;
  final List<File> resultFiles;
  final double? progress;

  /// File sizes in bytes keyed by file path, resolved in the cubit so
  /// widgets stay pure display (no File.length() FutureBuilder in UI).
  /// Absent entry = size not yet resolved.
  final Map<String, int> fileSizes;

  bool get isProcessing => status == ToolStatus.processing;
  bool get hasResult => resultFiles.isNotEmpty;
  bool get hasError => status == ToolStatus.error;

  ToolState copyWith({
    List<File>? files,
    ToolStatus? status,
    String? message,
    List<File>? resultFiles,
    double? progress,
    Map<String, int>? fileSizes,
  }) => ToolState(
    files: files ?? this.files,
    status: status ?? this.status,
    message: message,
    resultFiles: resultFiles ?? this.resultFiles,
    progress: progress ?? this.progress,
    fileSizes: fileSizes ?? this.fileSizes,
  );
}
