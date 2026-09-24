# Bento — Scan & Tools

Offline-first Flutter app with **fully custom native UI**, powered by a native PDF engine
over FFI (`pdf_manipulator` 5.0.0, MIT Rust core), plus native document scanning.
**AGPL-3.0** — entire app including custom UI ships AGPL-3.0 (see Licensing below).

Package: `com.benopdf.scan` · Android minSdk 24 · iOS 13+ · Riverpod + `go_router` + Material 3.

## MVP v1 — 8 tools (7 engine + 1 native)

- Engine (native FFI, off main thread): Merge, Split, Organize/Rotate/Delete, Extract,
  Compress, Image→PDF, PDF→Image (PNG render)
- Native (`pdf` + signature canvas, no engine): Sign PDF
- Deferred: OCR PDF → v1.1

## Quick start

```bash
flutter pub get
flutter analyze
flutter test
flutter run  # needs Android emulator / iOS simulator, airplane mode works
```

No engine build step — the native library ships with the `pdf_manipulator` package
(build hook downloads it on first build).

## Architecture

```
lib/core/{theme,router,storage}  # themes, go_router table, save-location helpers
lib/data/tools/{datasources,repositories}  # FFI engine data source + ToolsRepository
lib/data/files/...               # Files repository (local docs/tmp/Documents)
lib/presentation/{files,tools}   # Bloc screens (strict Repository → Bloc → UI)
lib/features/tools/{home,split,organize,extract,compress,pdf2image,sign,widgets,providers}
lib/features/scan/  # scanner_service.dart (cunning_document_scanner + fallback com.benopdf.scan/scanner)
lib/features/files|settings
```

## Offline & Licensing

Fully offline, no download-on-first-use. See `PRIVACY.md` and `docs/ffi-engine.md`.
Full source published with every store build.

> Licensing note: the AGPL WASM components (PyMuPDF, Ghostscript, CoherentPDF) were removed
> with the old WebView engine. The current engine is MIT-licensed, so AGPL is no longer
> forced by the engine — the repo still ships AGPL-3.0 until the owner decides otherwise.

## Scanner

Native bridge: ML Kit GMS DocumentScanner (Android) + VisionKit VNDocumentCameraViewController (iOS) via `cunning_document_scanner` preferred; fallback `PlatformChannelScannerService` (~200 LOC) documented in `TODO.md` Phase 4 and `docs/scanner-evaluation.md`.

## CI

`flutter analyze` + `flutter test` on PR via `.github/workflows/ci.yaml`.

## License

AGPL-3.0. See `LICENSE`.
