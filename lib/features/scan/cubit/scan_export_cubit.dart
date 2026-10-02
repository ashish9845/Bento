import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../scanner_service.dart';

enum ScanExportStatus { idle, creating, success, error }

/// PDF-export state for the Scan flow. Paths are Strings — UI never holds
/// File handles for the result.
///
/// BLOC-layer owner of `ScannerService.imagesToPdf`. The service is injected
/// (optional override for tests, defaulting to the real service) so UI never
/// constructs `ScannerService` directly.
class ScanExportState {
  const new({this.status = ScanExportStatus.idle, this.pdfPath, this.error});

  final ScanExportStatus status;
  final String? pdfPath;
  final String? error;

  bool get isCreating => status == ScanExportStatus.creating;

  ScanExportState copyWith({
    ScanExportStatus? status,
    String? pdfPath,
    String? error,
  }) => ScanExportState(
    status: status ?? this.status,
    pdfPath: pdfPath,
    error: error,
  );
}

class ScanExportCubit extends Cubit<ScanExportState> {
  new({ScannerService? scannerService})
    : _svc = scannerService ?? ScannerService(),
      super(const ScanExportState());

  final ScannerService _svc;

  /// Builds the PDF from reviewed [imagePaths] under [name]. The rename
  /// dialog shell stays in UI — only the name string crosses the boundary.
  Future<void> createPdf(List<String> imagePaths, String name) async {
    if (imagePaths.isEmpty || isClosed) return;
    emit(const ScanExportState(status: ScanExportStatus.creating));
    try {
      final pdf = await _svc.imagesToPdf(imagePaths, outputName: name);
      if (isClosed) return;
      emit(
        ScanExportState(status: ScanExportStatus.success, pdfPath: pdf.path),
      );
    } on Exception catch (e, s) {
      addError(e, s);
      if (!isClosed) {
        emit(
          ScanExportState(
            status: ScanExportStatus.error,
            error: e.toString().replaceFirst('Exception: ', ''),
          ),
        );
      }
    }
  }

  void clearError() {
    if (isClosed) return;
    emit(state.copyWith(status: ScanExportStatus.idle));
  }
}
