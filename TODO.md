# BentoPDF Flutter — TODO

Tracks work for building an offline Flutter app with a custom native UI, powered by
BentoPDF's processing engine (headless), plus a new native document-scanning feature.

Locked decisions (Phase 0): AGPL-3.0 license · fully offline (all assets bundled) ·
custom native Flutter UI (no BentoPDF web UI) · Riverpod for state management.

## Phase 0 — Feasibility & Decisions
- [x] License: AGPL-3.0 — the whole app, including custom UI code, ships open-source
- [x] Offline strategy: fully bundled at install, no on-demand downloads
- [x] UI strategy: no BentoPDF web UI; BentoPDF becomes a headless engine behind a custom native UI (superseded: native FFI engine via `pdf_manipulator`, no BentoPDF code remains — see Phase 2)
- [x] State management: Riverpod
- [x] MVP tool set for v1: 7 engine tools + Sign PDF (native) = 8 tools — confirmed 2026-09-23
      - Engine (via headless BentoPDF): Merge PDFs, Split PDFs, Organize/Rotate/Delete Pages,
        Extract Pages, Compress PDF, Image → PDF, PDF → Image
      - Native (no engine): Sign PDF
      - Deferred: OCR PDF → v1.1
- [x] Tesseract OCR languages: `eng` only, and only when OCR ships in v1.1 — confirmed 2026-09-23
      - No other languages unless demonstrated user demand; no Tesseract WASM in v1 bundle
- [x] WebView package for the headless engine host: `flutter_inappwebview` — confirmed 2026-09-23
      (RETIRED 2026-09-24: whole WebView/JS engine removed in favor of native FFI — no WebView remains)
- [x] Scanner approach: Google ML Kit document scanner (`google_mlkit_document_scanner`) on Android; OpenScan pipeline (custom camera + pure-Dart edge detection) on iOS — switched 2026-09-25
      - Vendored CV core + filters from https://github.com/ethereal-developers/OpenScan (BSD-3-Clause, `third_party/openscan/`)
      - Replaces the earlier ML Kit GMS / VisionKit plan (and its `cunning_document_scanner` plugin + platform-channel fallback, both removed)
      - Package name: `com.benopdf.scan` · Targets: iOS 13+ (VisionKit), Android minSdk 24 (7.0)
      - Routing/theming: `go_router` + Material 3 base for v1; custom design system deferred
- [x] WASM strategy: tree-shake engine entry to only the 7 engine-backed v1 tools, no Tesseract until v1.1
      (RETIRED 2026-09-24 with the WebView engine — native FFI binary ~21 MB ships with the package)

## Phase 1 — Project Scaffolding
- [x] `flutter create` project, package name, min SDK versions (Android/iOS) — `com.benopdf.scan`, Android minSdk 24, iOS 15 (covers 13+)
- [x] Add Riverpod, set up provider structure — `flutter_riverpod` + `riverpod_annotation` + `riverpod_generator`
- [x] Folder structure: `lib/core`, `lib/data/tools`, `lib/features/tools`, `lib/features/scan`,
      `lib/features/files`, `lib/features/settings` (+ `lib/presentation/*` Bloc screens per strict arch)
- [x] Lint rules (`analysis_options.yaml`), CI pipeline (build + `flutter test` on PR) — `very_good_analysis`, `flutter analyze` clean, `flutter test` passing, `.github/workflows/ci.yaml`
- [x] App shell: navigation, theming (light/dark), app icon placeholder — Material 3 `AppTheme`, `go_router` `StatefulShellRoute` (Tools/Scan/Files/Settings), `ProviderScope`, invisible `EngineHost` overlay
- [ ] Design system pass: define your own visual language (do not copy BentoPDF's site design) — deferred per Phase 0 decision; M3 base only for v1

## Phase 2 — Native FFI Engine (replaces the retired WebView/JS plan below)
- [x] Switched to `pdf_manipulator` 5.0.0 (MIT, Rust core over FFI, off main thread) — supports
      Android API 21+ / iOS 13+, typed `PdfError`s, cancellable tasks. No WebView, no JS, no WASM.
- [x] `lib/data/tools/datasources/pdf_engine_data_source.dart` — shared `Pdf()` instance + all 7 ops:
      `merge`, `split` (1-based `1-2, 3, 4-end` specs via `parsePageRanges`), `extract`,
      `organize` (delete + rotate with index remap, order via `selectPages`), `compress`
      (`PdfImagePolicy.screen/ebook/lossless`), `imagesToPdf`, `renderPages` (PNG export);
      outputs go straight to the save directory (custom/default Documents), password-protected
      and corrupted files surface friendly errors
- [x] `ToolsRepository` extended (pageCount/split/extract/organize/compress/render) with `CacheException`
      mapping; unit tests in `test/data/tools/` (range parser + mocked repository, all passing)
- [x] All 8 tool screens call the repository (Riverpod `toolsRepositoryProvider` for legacy screens,
      per-route `ToolsRepositoryImpl(PdfEngineDataSourceImpl())` for Bloc screens); real page counts
      via `pdfPageCountProvider`; Sign stays native (`pdf` package overlay, no engine)
- [x] RETIRED WebView/JS approach (kept for history): Vite entry, `window.BentoEngine` bridge,
      `shelf` 127.0.0.1 server with COOP/COEP, invisible `flutter_inappwebview`, WASM bundle in
      `assets/engine/` — all deleted (`lib/engine/`, `lib/core/server/`, `engine/`, `assets/engine/`,
      `flutter_inappwebview`/`shelf`/`shelf_static` deps). Engine binary (~21 MB native) comes from
      the package build hook; release APK shrank accordingly.
- [ ] Verify each MVP tool works fully offline (airplane mode) on Android and iOS — needs device/emulator airplane-run of each tool

## Phase 3 — Native UI per Tool
- [x] Home/tool-grid screen (your own design, not BentoPDF's) — `lib/features/tools/home/tool_grid_screen.dart` 8 tools grid
- [x] One native screen per MVP tool: file picker → tool-specific options UI → progress →
      result (save/share/send-to-another-tool) — all 8 tools functional with `ToolController` + `file_picker` + `EngineBridge` placeholder; `compress` spike wired to `flutter_inappwebview` readiness
- [x] Shared native components: PDF page thumbnail grid/reorder widget (used by Organize,
      Split, Extract, Merge), progress/loading states, error handling — `pdf_thumbnail_grid.dart`, `tool_progress.dart` (progress/error/success), `file_picker_card.dart`, `tool_scaffold.dart`
- [x] Expanded beyond MVP set: Protect PDF (single "Set Password", AES-256) and
      Unlock PDF (password ⇒ plaintext) — both via FFI engine (`protectPdf`/`unlockPdf`),
      native screens, tool grid registered (10 tools total). Home keeps 8 shortcuts
      (the two Import shortcuts removed). Batch decrypt deferred (single-file MVP,
      consistent with other tools).

## Phase 4 — Native Document Scanner (OpenScan pipeline, promoted 2026-09-25)
- [x] Evaluated native-scanner plugins (`cunning_document_scanner` et al.) then replaced them
      with the OpenScan approach after a device-tested beta — `lib/features/scan/openscan/`
      (vendored CV core + filters, BSD-3-Clause) + `OpenScanCaptureScreen` (camera, flash,
      Auto/Original/Gray/B&W) feeding the existing review flow
- [x] Camera capture with boundary detection (pure-Dart edge/contour pipeline in isolates)
- [x] Perspective correction / auto-crop per captured page (falls back to uncropped photo when no boundary found)
- [x] Multi-page capture flow: add page, reorder, delete, retake — thumbnail grid in `ScanScreen` for returned images
- [ ] Per-page filters: color, grayscale, black & white, auto-enhance (via `image` package if
      plugin returns images rather than a composed PDF) — placeholder via `image` package, filter UI pending
- [x] Compose pages into a single PDF using `pdf` + `image` packages (native, no engine needed)
      — only needed if plugin returns images; skip if it returns a PDF directly — `ScannerService.imagesToPdf` via `pdf`+`image`
- [x] Save scanned PDF to device storage; option to share — `SharePlus.instance.share` in `ScanScreen`
- [x] "Send to tool" action: hand scanned PDF into the headless engine (e.g. compress) via
      the Phase 2 bridge — note Sign PDF is also native, so send-to-Sign bypasses the engine — `lib/features/tools/widgets/send_to_tool.dart` wired in Merge/Compress/Files/Scan (Scan→Compress/Sign)
- [x] Fixed ML Kit release-only NPE (2026-09-25, device-verified Redmi + Samsung A15):
      Flutter's Gradle plugin force-enables R8 for release builds; R8 stripped the
      reflection-instantiated `CommonComponentRegistrar.<init>`, so `MlKitContext` never
      initialized and `getStartScanIntent()` NPE'd on every release build (debug unaffected).
      Fix: `shrink=false` in `android/gradle.properties` (verified via dexdump that the
      release dex keeps the constructor; FULL scanner mode restored and working).
      Do NOT re-enable shrinking without proguard keep rules for `com.google.mlkit.**`.

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
- [x] GitHub Release workflow (`.github/workflows/release.yaml`) — builds signed universal APK + AAB and
      publishes to a GitHub Release on `v*` tags or manual dispatch (tag input); release signing via
      `ANDROID_KEYSTORE_BASE64`/`ANDROID_KEY_ALIAS`/`ANDROID_STORE_PASSWORD`/`ANDROID_KEY_PASSWORD`
      secrets, debug-signing fallback with warning when unset
- [x] Tag release, publish Android (Play Store) and iOS (App Store) builds — v1.0.0 (versionCode 1) release artifacts built 2026-09-24: `build/app/outputs/flutter-apk/app-release.apk` (~60M) + `build/app/outputs/bundle/release/app-release.aab` (~59M), signed with upload key (`CN=Bento`, `com.benopdf.scan`, label `Bento`, apksigner verified). Upload key at `android/upload-keystore.jks` + `android/key.properties` (gitignored — back up both; losing the key means a new app listing). Still open: `git tag v1.0.0`, Play Console upload (AAB), App Store `flutter build ipa` on macOS

## Ongoing / Maintenance
- [x] Process for pulling upstream engine updates — `flutter pub upgrade pdf_manipulator` (native binary comes from the package build hook); API map in `docs/ffi-engine.md`
- [ ] Track which tools remain un-ported and prioritize next

## Beta — OpenScan scanner variant (PROMOTED to release 2026-09-25)
- [x] Device-tested beta (`com.benopdf.scan.beta`) confirmed working — OpenScan is now the release scanner
- [x] Beta scaffolding removed: `beta` flavor, `OPENSCAN` gate, badge icons, `docs/beta-openscan.md`;
      release builds are back to flavor-less (`flutter build apk/appbundle --release`)
- [x] Old scanner stack removed: `cunning_document_scanner` dep, platform-channel fallback (Kotlin/Swift), VisionKit/ML Kit references
