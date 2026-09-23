# Scanner Plugin Evaluation — Phase 4

Date: 2026-09-23. Target: Android minSdk 24 (GMS) + iOS 13+ (VisionKit). Requires returns image paths or PDF path on both platforms.

## Candidates evaluated (pub.dev 2026-09)

### 1. cunning_document_scanner ( https://pub.dev/packages/cunning_document_scanner )
- Wraps ML Kit GMS Document Scanner (Android) + VNDocumentCameraViewController (iOS) exactly as required.
- API: `CunningDocumentScanner.getPictures()` → `List<String>?` paths (temp JPEGs). Maintained, null-safe, ~monthly releases. Supports pageLimit/galleryImport.
- MinSdk 21 (ours 24 ok), iOS 13+ (VisionKit). Returns images → need `ScannerService.imagesToPdf` via `pdf`+`image`.
- **Verdict: PREFERRED for Phase 4 spike.** Single API, both platforms, matches TODO.md Phase 4 fallback spec. Install with `flutter pub add cunning_document_scanner` and swap `PluginScannerService` to delegate.

### 2. flutter_doc_scanner ( https://pub.dev/packages/flutter_doc_scanner )
- Similar wrap but Android-only ML Kit, iOS returns via different method channel; iOS VisionKit support was added late and less stable per issues.
- API differs per platform, requires branching. Less maintained.
- **Verdict: backup.**

### 3. document_scanner ( https://pub.dev/packages/document_scanner )
- Unmaintained (last 2023), not null-safe. Exclude.

## Fallback implemented (already in repo)

`lib/features/scan/scanner_service.dart` + native:

- `PluginScannerService` stub (swap to cunning_document_scanner call when installed)
- `PlatformChannelScannerService` `com.benopdf.scan/scanner` — `android/app/src/main/kotlin/.../MainActivity.kt` (GmsDocumentScanner, RESULT_FORMAT_JPEG, SCANNER_MODE_FULL, request 1001) and `ios/Runner/AppDelegate.swift` (VNDocumentCameraViewController, jpegData 0.9 → temp). Both wired to MethodChannel, currently return `[]` or temp JPEG paths until full URI-to-file copy is completed.

## Next step to wire cunning_document_scanner (one-line)

```dart
// lib/features/scan/scanner_service.dart
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
class PluginScannerService implements ScannerService {
  Future<List<String>> scanDocument() async =>
    await CunningDocumentScanner.getPictures() ?? [];
}
```

Then `ref.read(scannerServiceProvider)` in `ScanScreen` will receive real images → `imagesToPdf` composes PDF natively, `SharePlus` + `SendToToolSheet` already wired.

## Test plan

- Android 7 (API 24) + iOS 13 device, airplane mode, scan 1-5 pages, verify crop correctness, gallery import, multi-page reorder in `ScanScreen` grid (coming), per-page filter via `image` package (grayscale).
