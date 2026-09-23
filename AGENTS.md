# AGENTS.md

Instructions for AI coding agents (Claude Code and similar) working in this repository.
Read this before making changes. See `TODO.md` for the current task checklist.

## What this project is

An offline-first Flutter app with a **fully custom native UI**, powered by the processing
engine from **BentoPDF** (https://github.com/alam00000/bentopdf) running headlessly, plus a
new native document scanning feature.

This is explicitly **not** a WebView wrapper around BentoPDF's website. The user does not
want BentoPDF's UI at all — only its underlying tool functionality (PDF.js, PDFLib, PDFKit,
EmbedPDF, and WASM modules for LibreOffice, Ghostscript, PyMuPDF, CoherentPDF, Tesseract OCR).

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
- **State management: Riverpod.**

## Architecture at a glance

```
lib/
  core/            # app-wide config, theming, routing, local web-server bootstrap
  engine/          # Dart↔JS bridge: typed wrappers calling into the headless BentoPDF engine
  features/
    tools/         # native tool-grid + per-tool screens (file picker, options, progress, result)
    scan/          # native camera capture, crop/filter, multi-page compose, PDF export
    files/         # local file browser, recent files
    settings/      # theme, storage location, about/licensing (AGPL notice + credits)
assets/
  engine/          # headless BentoPDF processing bundle + WASM assets (built separately, see below)
```

### The headless engine

BentoPDF's `src/` is split into UI components and processing logic. This project builds a
**separate, minimal Vite entry point** (not part of BentoPDF's own build) that imports only
the processing modules for the tools currently supported (see MVP set in `TODO.md`), with no
UI components, no Tailwind, no site chrome. That entry exposes each tool as a plain function,
e.g.:

```js
window.BentoEngine.merge(fileUrls) -> Promise<resultUrl>
window.BentoEngine.split(fileUrl, ranges) -> Promise<resultUrl[]>
```

This bundle, plus its WASM assets, is built with `VITE_USE_CDN=false` and local
`VITE_WASM_*` / `VITE_TESSERACT_*` URLs (per BentoPDF's own air-gapped deployment docs),
then copied into `assets/engine/`.

At runtime, a local `shelf` HTTP server starts on `127.0.0.1` serving `assets/engine/` with
COOP/COEP headers set — required for `SharedArrayBuffer`, which the LibreOffice-based tools
need. An **invisible** `flutter_inappwebview` instance loads `http://127.0.0.1:<port>` and
hosts the engine; it is never shown to the user. Files are passed to/from the engine as local
file URLs served by the same local server, not as base64 blobs, to avoid large in-memory
payloads for big PDFs.

Do not add UI, styling, or navigation to anything under `assets/engine/` or its source —
it exists purely as a compute sandbox called from native Dart code.

## Working on tool screens (`features/tools`)

- Every tool gets its own native screen, designed independently of BentoPDF's site design —
  do not reference or copy their layout/visual style.
- Shared widgets (page thumbnail grid/reorder, progress indicators, error states) belong in
  a common location, not duplicated per tool.
- Start with the MVP tool set defined in `TODO.md` Phase 0 before expanding coverage.
- All actual PDF processing for these tools happens via `lib/engine/` calling into the
  headless engine — do not reimplement PDF manipulation logic natively unless a tool is
  being deliberately moved off the engine.

## Working on the scanner (`features/scan`)

- Pure Dart/Flutter; does not use the headless engine for PDF composition — build the PDF
  directly with the `pdf` + `image` packages.
- The only integration point with the engine is optional and intentional: handing a finished
  scanned PDF's file path to a chosen tool (e.g. "send to Compress" or "send to OCR").

## Licensing — read before adding or updating bundled code

- Do not strip license notices or attribution from the bundled engine build.
- Do not silently swap the AGPL WASM components (PyMuPDF, Ghostscript, CoherentPDF) for
  alternatives without flagging it — that changes the licensing calculus for the whole app.
- Because the app ships AGPL-3.0, full corresponding source (including custom UI code) must
  be published alongside any distributed build. Don't treat any part of this repo as
  proprietary/closed-source.

## Conventions

- State management: Riverpod. Use providers consistently; don't introduce Bloc or other
  patterns without explicit instruction.
- Treat `assets/engine/` as a vendored build artifact: never hand-edit files inside it —
  regenerate it from the engine source per the Phase 2 steps in `TODO.md`.
- Keep `TODO.md` checkboxes current as work completes.

## Commands

Fill these in once the project is scaffolded (Phase 1):
- Run app: `flutter run`
- Tests: `flutter test`
- Lint: `flutter analyze`
- Rebuild headless engine bundle: see `TODO.md` Phase 2 and BentoPDF's own source/build docs
  at https://github.com/alam00000/bentopdf
