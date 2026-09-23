# Beno PDF — Scan & Tools

Offline-first Flutter app with **fully custom native UI**, powered by the processing engine from **BentoPDF** (https://github.com/alam00000/bentopdf) running headlessly, plus native document scanning. **AGPL-3.0** — entire app including custom UI is AGPL-3.0 due to bundled AGPL WASM (PyMuPDF, Ghostscript, CoherentPDF).

Package: `com.benopdf.scan` · Android minSdk 24 · iOS 13+ · Riverpod + `go_router` + Material 3.

## MVP v1 — 8 tools (7 engine + 1 native)

- Engine (headless BentoPDF via invisible `flutter_inappwebview` on `http://127.0.0.1:<port>` with COOP/COEP): Merge, Split, Organize/Rotate/Delete, Extract, Compress, Image→PDF, PDF→Image
- Native (`pdf` + signature canvas, no engine): Sign PDF
- Deferred: OCR PDF → v1.1 (`eng` only, Tesseract WASM)

## Quick start

```bash
flutter pub get
flutter analyze
flutter test
flutter run  # needs Android emulator / iOS simulator, airplane mode works
```

Rebuild headless engine bundle (Phase 2):

```bash
cat engine/README.md
cd engine && npm ci
VITE_USE_CDN=false vite build  # → assets/engine/
```

Apparent engine size (7 tools, no Tesseract): ~56M (`du --apparent-size assets/engine`). Gate expects 40-80M before Phase 3 polish.

## Architecture

```
lib/core/{theme,routing,server}  # AppTheme, go_router shell, shelf LocalEngineServer
lib/engine/{host,bridge,providers}  # invisible InAppWebView, file-URL bridge (not base64)
lib/features/tools/{home,merge,split,organize,extract,compress,image2pdf,pdf2image,sign,widgets,providers}
lib/features/scan/  # scanner_service.dart (cunning_document_scanner + fallback com.benopdf.scan/scanner)
lib/features/files|settings
assets/engine/  # Vite bundle + wasm (air-gapped, VITE_WASM_*)
engine/  # Vite entry engine.html/engine.ts (tree-shaken to 7 tools)
```

## Offline & AGPL

All WASM + OCR data bundled at install; no download-on-first-use. See `PRIVACY.md` and `docs/engine-mapping.md`. Full source published with every store build.

## Scanner

Native bridge: ML Kit GMS DocumentScanner (Android) + VisionKit VNDocumentCameraViewController (iOS) via `cunning_document_scanner` preferred; fallback `PlatformChannelScannerService` (~200 LOC) documented in `TODO.md` Phase 4 and `docs/scanner-evaluation.md`.

## CI

`flutter analyze` + `flutter test` on PR via `.github/workflows/ci.yaml`.

## License

AGPL-3.0. See `LICENSE` and bundled engine notices in `assets/engine/`.
