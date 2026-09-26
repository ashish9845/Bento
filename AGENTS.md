# AGENTS.md

Instructions for AI coding agents (Claude Code and similar) working in this repository.
Read this before making changes. See `TODO.md` for the current task checklist.

## What this project is

An offline-first Flutter app with a **fully custom native UI**, powered by a native
PDF engine over FFI, plus a new native document scanning feature.

There is no WebView and no bundled website — every screen the user sees is built
natively in Flutter, and all PDF processing runs on-device through
`pdf_manipulator` (MIT-licensed Rust core).

## Locked decisions (do not revisit without explicit instruction)

- **License: AGPL-3.0.** The entire app, including all custom Flutter/UI code, ships
  open-source under AGPL-3.0. This is a consequence of bundling AGPL-licensed processing
  libraries (PyMuPDF, Ghostscript, CoherentPDF) — do not propose a "keep the UI closed-source"
  path, it isn't valid here.
- **Fully offline.** All WASM modules and required OCR language data are bundled into the
  app at build/install time. No CDN calls, no "download on first use" flow.
- **Custom native UI.** BentoPDF's site UI, Tailwind styling, and page components are not
  used. Only its processing logic is reused, as a headless engine. Every screen the user
  sees is built natively in Flutter.
  (Historical note: these three bullets describe the retired WebView/JS plan. The app now
  uses `pdf_manipulator`, MIT — see Licensing below. Locked decisions themselves are unchanged
  until the owner says otherwise.)
- **State management: Riverpod.**

## Architecture at a glance

```
lib/
  core/            # app-wide config, theming, routing, storage
  data/tools/      # FFI engine data source + repository (all PDF processing lives here)
  features/
    tools/         # native tool-grid + per-tool screens (file picker, options, progress, result)
    scan/          # native camera capture, crop/filter, multi-page compose, PDF export
    files/         # local file browser, recent files
    settings/      # theme, storage location, about/licensing
```

### The native FFI engine (replaces the former WebView/JS plan)

All PDF processing runs through **`pdf_manipulator` 5.0.0** (MIT-licensed Rust core over
FFI — no WebView, no JS, no WASM, no local HTTP server). The single entry point is
`lib/data/tools/datasources/pdf_engine_data_source.dart` (shared `Pdf()` instance,
operations already run off the main thread), exposed to UI via `ToolsRepository`:

- Merge, Split (`1-2, 3, 4-end` specs), Organize (delete/rotate/reorder), Extract,
  Compress (`PdfImagePolicy`), Image → PDF, PDF → Image (PNG render)
- Engine outputs are written straight to the save directory (custom/default Documents)
- Password-protected and corrupted PDFs surface friendly errors, not stack traces

Sign PDF stays native (`pdf` package overlay, no engine). Do not reintroduce WebView/JS
processing — the `flutter_inappwebview`/`shelf` dependencies were deliberately removed.

## Working on tool screens (`features/tools`)

- Every tool gets its own native screen, designed independently of BentoPDF's site design —
  do not reference or copy their layout/visual style.
- Shared widgets (page thumbnail grid/reorder, progress indicators, error states) belong in
  a common location, not duplicated per tool.
- Start with the MVP tool set defined in `TODO.md` Phase 0 before expanding coverage.
- All actual PDF processing for these tools happens via `lib/data/tools/` calling into the
  headless engine — do not reimplement PDF manipulation logic natively unless a tool is
  being deliberately moved off the engine.

## Working on the scanner (`features/scan`)

- Pure Dart/Flutter; does not use the headless engine for PDF composition — build the PDF
  directly with the `pdf` + `image` packages.
- The only integration point with the engine is optional and intentional: handing a finished
  scanned PDF's file path to a chosen tool (e.g. "send to Compress" or "send to OCR").

## Licensing — read before adding or updating bundled code

- The AGPL-licensed processing components (PyMuPDF, Ghostscript, CoherentPDF WASM) were
  **removed** with the WebView/JS engine. The current engine (`pdf_manipulator`, MIT) does
  not force AGPL on the app — but the repo still ships AGPL-3.0 (see `LICENSE`) until the
  owner explicitly decides otherwise. Do not treat any part of this repo as proprietary
  without that explicit instruction.
- Do not add AGPL/GPL-licensed PDF processing libraries without flagging it — that would
  change the licensing calculus for the whole app again.

## Conventions

- State management: Riverpod. Use providers consistently; don't introduce Bloc or other
  patterns without explicit instruction.
- Keep `TODO.md` checkboxes current as work completes.

## Commands

- Run app: `flutter run`
- Tests: `flutter test`
- Lint: `flutter analyze`
- Release APK: `flutter build apk --release --split-per-abi`
- Release bundle (Play Store): `flutter build appbundle --release`
