import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';

import '../../../core/error/error_reporting.dart';

/// Next step after [ScanCubit.prepareScan] resolves the platform.
///
/// UI switches on this — it never imports `dart:io` Platform or
/// ML Kit types directly. Scanning is Android-only (ML Kit); other
/// platforms get [ScanAction.unsupported].
enum ScanAction { mlKit, unsupported, blocked }

enum ScanStatus { idle, scanning, success, cancelled, error }

/// Capture state for the Scan flow (ML Kit on Android).
///
/// BLOC-layer owner of `DocumentScanner.scanDocument` + `close` + error
/// mapping. UI dispatches `prepareScan`/`scanWithMlKit` and renders
/// `ScanState` — it never touches scanner or platform APIs directly.
class ScanState {
  const new({
    this.status = ScanStatus.idle,
    this.error,
    this.errorDetails,
    this.pages = const [],
  });

  final ScanStatus status;
  final String? error;

  /// Full technical detail (code/message/details/stack) for Copy details.
  final String? errorDetails;
  final List<String> pages;

  bool get isScanning => status == ScanStatus.scanning;

  ScanState copyWith({
    ScanStatus? status,
    String? error,
    String? errorDetails,
    List<String>? pages,
  }) => ScanState(
    status: status ?? this.status,
    error: error,
    errorDetails: errorDetails,
    pages: pages ?? this.pages,
  );
}

/// ML Kit scanner gateway (Android path). Injected for tests so UI/cubit
/// tests never construct [DocumentScanner] directly.
abstract class MlKitScannerGateway {
  /// Returns scanned JPEG paths, or null when the user cancels.
  Future<List<String>?> scan();

  /// Pages the native side stashed when the OS killed Bento while the
  /// scanner owned the foreground. Consumes the stash; empty when there is
  /// nothing to recover.
  Future<List<String>> consumeRecoveredScan();

  /// Drops any stashed result. Called after a normal scan completes so a
  /// later interruption check can never replay pages that already arrived.
  Future<void> clearRecoveredScan();
}

class MlKitScannerException implements Exception {
  new(this.message, {this.details});
  final String message;
  final String? details;
  @override
  String toString() => details == null ? message : '$message\n$details';
}

class MlKitScannerGatewayImpl implements MlKitScannerGateway {
  /// Native side channel backed by MainActivity: survives process death
  /// (the ML Kit plugin's own channel result does not).
  static const _recoveryChannel = MethodChannel(
    'com.benopdf.scan/scan_recovery',
  );

  @override
  Future<List<String>?> scan() async {
    // Full mode: filters + enhancements. (A BASE-mode workaround was tried
    // 2026-09-25 for release-build NPEs, but dex forensics proved the NPE
    // came from R8 stripping ML Kit constructors in release builds, not
    // from the scanner mode. R8 is now disabled via shrink=false, so FULL
    // is safe again.)
    final scanner = DocumentScanner(
      options: DocumentScannerOptions(
        documentFormats: {DocumentFormat.jpeg},
        pageLimit: 10,
        mode: ScannerMode.full,
        isGalleryImport: true,
      ),
    );
    try {
      // Shed image memory before the GMS scanner activity takes the
      // foreground — lowers the odds of an LMK kill while we're away
      // (notably MIUI). Best effort; never blocks the scan.
      try {
        PaintingBinding.instance.imageCache
          ..clear()
          ..clearLiveImages();
      } on Exception catch (e, s) {
        ErrorReporting.log(e, s, context: 'scan');
      }
      // Foreground guard: keeps the process out of the cached-app bucket
      // while the scanner owns the foreground, so MIUI/ColorOS don't kill
      // Bento mid-scan. Best effort — recovery still covers a kill.
      await _beginScanSession();
      final res = await scanner.scanDocument();
      return res.images?.whereType<String>().toList() ?? [];
    } on PlatformException catch (e, s) {
      // The native side reports user cancellation as an error.
      if ((e.message ?? '').toLowerCase().contains('cancel')) return null;
      // Capture everything — code, message, native details, Dart stack —
      // so the exact cause can be read off the device via Copy details
      // (e.g. "Failed to start document scanner" when Play Services
      // can't provision the ML Kit module).
      final full = StringBuffer()
        ..writeln('Scanner: ML Kit document scanner')
        ..writeln('Code: ${e.code}')
        ..writeln('Message: ${e.message}')
        ..writeln('Details: ${e.details}')
        ..writeln('Dart stack: $s')
        ..writeln(
          'Platform: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
        );
      debugPrint('[Scan] ML Kit failed:\n$full');
      throw MlKitScannerException(
        'ML Kit scanner failed [${e.code}]: ${e.message ?? e.details?.toString() ?? 'unknown error'}',
        details: full.toString(),
      );
    } finally {
      // Closed separately so a close-time failure can never mask the result.
      try {
        await scanner.close();
      } on Exception catch (e, s) {
        ErrorReporting.log(e, s, context: 'scan');
      }
      // The process is alive, so the result reached Dart (or the user
      // cancelled): drop the guard + the now-redundant stash. On process
      // death this finally never runs — that is what leaves the stash for
      // recovery (and the guard dies with the process).
      await _endScanSession();
      await clearRecoveredScan();
    }
  }

  Future<void> _beginScanSession() async {
    try {
      await _recoveryChannel.invokeMethod<void>('beginScanSession');
    } on Exception catch (e, s) {
      ErrorReporting.log(e, s, context: 'scan');
    }
  }

  Future<void> _endScanSession() async {
    try {
      await _recoveryChannel.invokeMethod<void>('endScanSession');
    } on Exception catch (e, s) {
      ErrorReporting.log(e, s, context: 'scan');
    }
  }

  @override
  Future<List<String>> consumeRecoveredScan() async {
    try {
      final pages = await _recoveryChannel.invokeListMethod<String>(
        'consumeRecoveredScan',
      );
      return pages ?? const [];
    } on Exception catch (e, s) {
      ErrorReporting.log(e, s, context: 'scan');
      return const [];
    }
  }

  @override
  Future<void> clearRecoveredScan() async {
    try {
      await _recoveryChannel.invokeMethod<void>('clearRecoveredScan');
    } on Exception catch (e, s) {
      ErrorReporting.log(e, s, context: 'scan');
    }
  }
}

class ScanCubit extends Cubit<ScanState> {
  new({MlKitScannerGateway? mlKitScanner})
    : _mlKitScanner = mlKitScanner ?? MlKitScannerGatewayImpl(),
      super(const ScanState());

  final MlKitScannerGateway _mlKitScanner;

  /// Platform routing. Scanning is Android-only (ML Kit document scanner);
  /// other platforms get [ScanAction.unsupported] with an error state for
  /// the UI error card.
  Future<ScanAction> prepareScan() async {
    if (Platform.isAndroid) return ScanAction.mlKit;
    if (!isClosed) {
      emit(
        state.copyWith(
          status: ScanStatus.error,
          error: 'Document scanning is only available on Android.',
        ),
      );
    }
    return ScanAction.unsupported;
  }

  /// Android ML Kit path: emits scanning → success(pages)/cancelled/error.
  /// UI listens for success and appends pages to its session cubit.
  Future<void> scanWithMlKit() async {
    if (state.isScanning || isClosed) return;
    emit(state.copyWith(status: ScanStatus.scanning));
    try {
      final images = await _mlKitScanner.scan();
      if (isClosed) return;
      if (images == null || images.isEmpty) {
        emit(state.copyWith(status: ScanStatus.cancelled, pages: []));
        return;
      }
      emit(state.copyWith(status: ScanStatus.success, pages: images));
    } on MlKitScannerException catch (e, s) {
      addError(e, s);
      if (!isClosed) {
        emit(
          state.copyWith(
            status: ScanStatus.error,
            error: e.message,
            errorDetails: e.details,
          ),
        );
      }
    } on Exception catch (e, s) {
      addError(e, s);
      if (!isClosed) {
        emit(
          state.copyWith(
            status: ScanStatus.error,
            error: e.toString().replaceFirst('Exception: ', ''),
          ),
        );
      }
    }
  }

  /// Pages the native side stashed when the OS killed Bento mid-scan.
  /// Returns only paths that still exist on disk; empty when nothing is
  /// recoverable (cancel, pre-result kill, or non-Android).
  Future<List<String>> recoverInterruptedScan() async {
    final pages = await _mlKitScanner.consumeRecoveredScan();
    return pages.where((p) => p.isNotEmpty && File(p).existsSync()).toList();
  }

  void clearError() {
    if (isClosed) return;
    emit(state.copyWith(status: ScanStatus.idle));
  }
}
