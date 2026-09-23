import 'dart:io';

enum ToolStatus { idle, picking, processing, success, error }

class ToolState {
  const ToolState({
    this.files = const [],
    this.status = ToolStatus.idle,
    this.message,
    this.resultFiles = const [],
    this.progress,
  });

  final List<File> files;
  final ToolStatus status;
  final String? message;
  final List<File> resultFiles;
  final double? progress;

  bool get isProcessing => status == ToolStatus.processing;
  bool get hasResult => resultFiles.isNotEmpty;
  bool get hasError => status == ToolStatus.error;

  ToolState copyWith({
    List<File>? files,
    ToolStatus? status,
    String? message,
    List<File>? resultFiles,
    double? progress,
  }) =>
      ToolState(
        files: files ?? this.files,
        status: status ?? this.status,
        message: message,
        resultFiles: resultFiles ?? this.resultFiles,
        progress: progress ?? this.progress,
      );
}
