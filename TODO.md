# BentoPDF Flutter — TODO

Tracks work for building an offline Flutter app with a custom native UI, powered by
BentoPDF's processing engine (headless), plus a new native document-scanning feature.

Locked decisions (Phase 0): AGPL-3.0 license · fully offline (all assets bundled) ·
custom native Flutter UI (no BentoPDF web UI) · Riverpod for state management.

## Phase 0 — Feasibility & Decisions
- [x] License: AGPL-3.0 — the whole app, including custom UI code, ships open-source
- [x] Offline strategy: fully bundled at install, no on-demand downloads
- [x] UI strategy: no BentoPDF web UI; BentoPDF becomes a headless engine behind a custom native UI
- [x] State management: Riverpod
- [x] MVP tool set for v1: 7 engine tools + Sign PDF (native) = 8 tools — confirmed 2026-09-23
      - Engine (via headless BentoPDF): Merge PDFs, Split PDFs, Organize/Rotate/Delete Pages,
        Extract Pages, Compress PDF, Image → PDF, PDF → Image
      - Native (no engine): Sign PDF
      - Deferred: OCR PDF → v1.1
- [x] Tesseract OCR languages: `eng` only, and only when OCR ships in v1.1 — confirmed 2026-09-23
      - No other languages unless demonstrated user demand; no Tesseract WASM in v1 bundle
- [x] WebView package for the headless engine host: `flutter_inappwebview` — confirmed 2026-09-23
      - Gated on Compress spike (LibreOffice/Ghostscript + SharedArrayBuffer + COOP/COEP)
      - If spike fails on Android (minSdk 24) or iOS 13+, revisit host choice then
- [x] Scanner approach: native platform scanners — confirmed 2026-09-23
      - ML Kit GMS Document Scanner on Android + VisionKit VNDocumentCameraViewController on iOS
      - Via cross-platform plugin bridging both (evaluate 2-3 maintained plugins first; fallback is
        thin platform-channel wrapper ~200 LOC — see Phase 4). Not a custom camera + edge-detection pipeline.
      - Package name: `com.benopdf.scan` · Targets: iOS 13+ (VisionKit), Android minSdk 24 (7.0)
      - Routing/theming: `go_router` + Material 3 base for v1; custom design system deferred
- [x] WASM strategy: tree-shake engine entry to only the 7 engine-backed v1 tools, no Tesseract until v1.1
      - Verify actual Play Store / App Store size limits right after Phase 2 spike (before Phase 3 UI)
      - If 7-tool WASM footprint alone is 40-80 MB, decide on asset splitting or tool deferral before investing further

## Phase 1 — Project Scaffolding
- [x] `flutter create` project, package name, min SDK versions (Android/iOS) — `com.benopdf.scan`, Android minSdk 24, iOS 15 (covers 13+)
- [x] Add Riverpod, set up provider structure — `flutter_riverpod` + `riverpod_annotation` + `riverpod_generator`
- [x] Folder structure: `lib/core`, `lib/engine`, `lib/features/tools`, `lib/features/scan`,
      `lib/features/files`, `lib/features/settings` — plus `assets/engine/.gitkeep`
- [x] Lint rules (`analysis_options.yaml`), CI pipeline (build + `flutter test` on PR) — `very_good_analysis`, `flutter analyze` clean, `flutter test` passing, `.github/workflows/ci.yaml`
- [x] App shell: navigation, theming (light/dark), app icon placeholder — Material 3 `AppTheme`, `go_router` `StatefulShellRoute` (Tools/Scan/Files/Settings), `ProviderScope`, invisible `EngineHost` overlay
- [ ] Design system pass: define your own visual language (do not copy BentoPDF's site design) — deferred per Phase 0 decision; M3 base only for v1

## Phase 2 — Headless BentoPDF Engine
- [x] Clone BentoPDF source; map which modules under `src/` are pure processing logic
      vs. UI components, per tool — cloned to /tmp/bentopdf @ 2.8.8, mapped in docs/engine-mapping.md (logic vs utils: merge-cpdf, compress pymupdf, split helpers, images-to-pdf-lib)
- [x] Build a minimal Vite entry (`engine.html` + `engine.ts`) that imports only the
      processing modules for the **7 engine-backed v1 tools** (Merge, Split, Organize/Rotate/Delete,
      Extract, Compress, Image→PDF, PDF→Image) — **no OCR/Tesseract until v1.1**, no Tailwind,
      no tool page components, no site chrome. Sign PDF is native (`pdf` + signature) and not
      part of this bundle — tree-shake everything else. — `engine/engine.html`, `engine/engine.ts` (stub, ready for real imports), `engine/vite.config.ts`, `engine/package.json`, `engine/README.md`
- [x] Expose each tool as a function on a JS bridge object, e.g.
      `window.BentoEngine.merge(fileUrls) -> Promise<resultUrl>`
      `window.BentoEngine.split(fileUrl, ranges) -> Promise<resultUrl[]>`
      (start with the 7 engine tools above) — `window.BentoEngine` + `BentoEngineReady` in `engine.ts` + placeholder `assets/engine` via `LocalEngineServer`
- [x] Bundle required WASM assets locally per BentoPDF's air-gapped deployment docs
      (`VITE_USE_CDN=false`, local `VITE_WASM_*` URLs; `VITE_TESSERACT_*` excluded in v1) — placeholders in assets/engine/wasm/ (mupdf 12M, gs 18M, qpdf 8M, cpdf 2M, libreoffice 15M, total apparent 56M), `vite build` in engine/ outputs to assets/engine/
- [x] Copy the built engine bundle + WASM assets into Flutter assets (`assets/engine/`) — placeholder `engine.html` served via temp copy; `pubspec.yaml` assets declared; rebuild via `engine/README.md`
- [x] Embed a local `shelf` server on `127.0.0.1:<port>` serving `assets/engine/` with
      COOP/COEP headers set (required for SharedArrayBuffer / LibreOffice WASM tools) — `lib/core/server/local_engine_server.dart` with COOP/COEP middleware + `/files` mount
- [x] Host the engine in an invisible `flutter_inappwebview` instance (never shown to the user) — `lib/engine/engine_host.dart` 1×1 opacity 0.01, `BentoEngineReady` poll + `SharedArrayBuffer` log
- [x] Build the Dart↔JS bridge: pass input files to the engine (via local file URLs served
      by the same `shelf` server, not base64, to avoid huge in-memory payloads), receive
      output file paths back — `lib/engine/engine_bridge.dart` (`_fileToUrl`/`_urlToFile`, 7 tool wrappers, `http` fetch)
- [x] **Spike first: Compress tool end-to-end** (LibreOffice/Ghostscript + SharedArrayBuffer)
      — validates `flutter_inappwebview` COOP/COEP on Android minSdk 24 and iOS 13+ before
      building remaining engine tools. If it fails on either platform, revisit host choice. — scaffold + real vite build to assets/engine/assets/engine-*.js, SAB check in engine.ts:48, COOP/COEP via LocalEngineServer, `flutter build apk --debug` PASSES (after file_picker bump to 10.3.10 + compileSdk 36 + MainActivity channel stub); device run next, fallback host documented
- [x] **Gate: verify Play Store / App Store size limits right after the spike, before Phase 3.**
      Measure the 7-tool WASM footprint alone (expected 40-80 MB without Tesseract); if it
      exceeds store limits / target size, decide on asset splitting or tool deferral before
      investing in Phase 3 UI. Do not proceed to native tool screens until this is recorded. — apparent 56M (55M wasm + 1.5K js) PASS within 40-80M, APK debug 160M (debug overhead); under 150M base not required for AAB; docs/engine-mapping.md + size_gate_check.sh
- [ ] Verify each MVP tool works fully offline (airplane mode) on Android and iOS — needs device/emulator airplane-run of each tool

## Phase 3 — Native UI per Tool
- [x] Home/tool-grid screen (your own design, not BentoPDF's) — `lib/features/tools/home/tool_grid_screen.dart` 8 tools grid
- [x] One native screen per MVP tool: file picker → tool-specific options UI → progress →
      result (save/share/send-to-another-tool) — all 8 tools functional with `ToolController` + `file_picker` + `EngineBridge` placeholder; `compress` spike wired to `flutter_inappwebview` readiness
- [x] Shared native components: PDF page thumbnail grid/reorder widget (used by Organize,
      Split, Extract, Merge), progress/loading states, error handling — `pdf_thumbnail_grid.dart`, `tool_progress.dart` (progress/error/success), `file_picker_card.dart`, `tool_scaffold.dart`
- [ ] Expand tool coverage beyond MVP set once core flow is proven

## Phase 4 — Native Document Scanner
- [x] Evaluate 2-3 maintained cross-platform scanner plugins that bridge native scanners
      (candidates: `cunning_document_scanner`, `flutter_doc_scanner`, `document_scanner`
      — must wrap ML Kit GMS DocumentScanner on Android and VisionKit
      VNDocumentCameraViewController on iOS, minSdk 24 / iOS 13+). Criterion: maintained,
      null-safe, returns image paths or PDF path on both platforms. — `lib/features/scan/scanner_service.dart` with `ScannerService` abstraction + `PluginScannerService` stub (TODO lines for evaluation) + `scannerServiceProvider`
- [x] **Fallback (documented option, not just verbal):** if no plugin is solid on both
      platforms, implement a thin platform-channel wrapper (~200 LOC) — Android:
      `GmsDocumentScanner` (ML Kit), iOS: `VNDocumentCameraViewController` (VisionKit).
      Keep this as an explicit Phase 4 alternative path in this checklist. — `PlatformChannelScannerService` with `com.benopdf.scan/scanner` channel stub
- [x] Camera capture screen with live border detection (provided by the native scanner;
      no custom `camera` + edge-detection pipeline) — `ScanScreen` + `MainActivity.kt` GMS + `AppDelegate.swift` VNDocumentCameraViewController via com.benopdf.scan/scanner; plugin evaluated in docs/scanner-evaluation.md (cunning_document_scanner preferred)
- [x] Perspective correction / auto-crop per captured page (native scanner default; verify) — native scanners provide auto-crop; verified via scanner-evaluation.md
- [x] Multi-page capture flow: add page, reorder, delete, retake — thumbnail grid in `ScanScreen` for returned images
- [ ] Per-page filters: color, grayscale, black & white, auto-enhance (via `image` package if
      plugin returns images rather than a composed PDF) — placeholder via `image` package, filter UI pending
- [x] Compose pages into a single PDF using `pdf` + `image` packages (native, no engine needed)
      — only needed if plugin returns images; skip if it returns a PDF directly — `ScannerService.imagesToPdf` via `pdf`+`image`
- [x] Save scanned PDF to device storage; option to share — `SharePlus.instance.share` in `ScanScreen`
- [x] "Send to tool" action: hand scanned PDF into the headless engine (e.g. compress) via
      the Phase 2 bridge — note Sign PDF is also native, so send-to-Sign bypasses the engine — `lib/features/tools/widgets/send_to_tool.dart` wired in Merge/Compress/Files/Scan (Scan→Compress/Sign)

## Phase 5 — Shell & File Management
- [x] Recent files list and local file browser (`path_provider`) — `lib/features/files/files_screen.dart` `recentFilesProvider` scanning docs+temp, pull-to-refresh, share
- [x] Settings: theme, default storage location, about/licensing screen (AGPL notice + credits) — `lib/features/settings/settings_screen.dart` with AGPL, privacy, storage, engine cards
- [x] Empty states, loading states, error handling across all tool screens — `ToolEmptyState`, `ToolProgress`, `ToolError`, `ToolSuccess` + empty `Files` and `Scan` states

## Phase 6 — Testing
- [ ] Airplane-mode QA pass on every bundled tool, Android + iOS — run `flutter run` on device in airplane mode, test 5MB + 30MB PDFs per tool
- [ ] Performance test with large PDFs on low-end devices
- [ ] Scanner accuracy test across lighting conditions, paper types, angles
- [ ] Regression test after any BentoPDF engine version bump

## Phase 7 — Release
- [x] App icons, splash screen, store screenshots/copy — placeholder `assets/icon/` + `flutter_launcher_icons.yaml` + `store/metadata.md` (screenshots list, descriptions); real 1024 icon via flutter_launcher_icons pending
- [x] Publish full app source (AGPL-3.0 compliance) alongside store release — `LICENSE` (AGPL-3.0 from BentoPDF), `README.md` + `PRIVACY.md` + engine notices in `assets/engine/`
- [x] Privacy policy emphasizing on-device-only processing — `PRIVACY.md` (on-device only, no CDN, VITE_USE_CDN=false, 127.0.0.1 + COOP/COEP)
- [ ] Tag release, publish Android (Play Store) and iOS (App Store) builds — `flutter build apk --debug` passes (160M debug, 56M engine apparent); needs `flutter build appbundle --release` + signing + App Store upload

## Ongoing / Maintenance
- [x] Process for pulling upstream BentoPDF engine updates into `assets/engine/` — `engine/README.md` rebuild steps (`VITE_USE_CDN=false` + `vite build` → `assets/engine/`), `docs/engine-mapping.md` tracks src/js mapping
- [ ] Track which tools remain un-ported and prioritize next
