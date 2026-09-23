# Headless BentoPDF Engine — Build Instructions (Phase 2)

This directory is the **separate Vite entry** that produces the vendored
bundle in `assets/engine/`. It is NOT part of BentoPDF's own website build.

> Do NOT hand-edit `assets/engine/` — regenerate from here per `TODO.md:43` and `AGENTS.md:100`.

## What this entry does

- Imports **only** the 7 engine-backed v1 tools (Merge, Split, Organize, Extract, Compress, Image→PDF, PDF→Image)
- No Tailwind, no site chrome, no UI components
- Exposes `window.BentoEngine` with one async function per tool:
  ```
  merge(fileUrls) -> Promise<resultUrl>
  split(fileUrl, ranges) -> Promise<resultUrl[]>
  organize(fileUrl, ops) -> Promise<resultUrl>
  extract(fileUrl, pages) -> Promise<resultUrl>
  compress(fileUrl, opts) -> Promise<resultUrl>
  imageToPdf(fileUrls) -> Promise<resultUrl>
  pdfToImage(fileUrl) -> Promise<resultUrl[]>
  ```
  Files are passed as `http://127.0.0.1:<port>/files/<name>` URLs served by the
  `shelf` server — not base64 — per `AGENTS.md:65`.

- Bundled with `VITE_USE_CDN=false` and local `VITE_WASM_*` URLs (air-gapped).
  `VITE_TESSERACT_*` excluded in v1 (OCR → v1.1, eng only).

- Sign PDF is **native** (`pdf` + signature capture) and not part of this bundle.

## Rebuild

```bash
# 1. Clone BentoPDF beside this repo (once)
git clone https://github.com/alam00000/bentopdf /tmp/bentopdf

# 2. Install deps (Node 20+)
cd engine
npm ci

# 3. Build with air-gapped WASM paths
VITE_USE_CDN=false \
VITE_WASM_MUPDF=/wasm/mupdf.wasm \
VITE_WASM_GS=/wasm/gs.wasm \
VITE_WASM_QPDF=/wasm/qpdf.wasm \
  vite build --config vite.config.ts

# 4. Copy to Flutter assets
rm -rf ../assets/engine/* && cp -r dist/* ../assets/engine/

# 5. Declare in pubspec.yaml already done:
#   flutter:
#     assets:
#       - assets/engine/
```

## Spike gate (must pass before Phase 3)

Build only the **Compress** tool first and verify on both platforms
with `SharedArrayBuffer` available (COOP `same-origin` + COEP `require-corp`):

```bash
VITE_BENTO_TOOLS=compress vite build && flutter run
# Test in airplane mode with 5MB + 30MB PDF
```

If the spike fails on Android minSdk 24 or iOS 13+, revisit `flutter_inappwebview` choice per `TODO.md:64`.

## Size gate

After the spike, run `du -sh ../assets/engine` — expected 40-80 MB for 7 tools
without Tesseract. If over store limits, decide on asset splitting or deferral
before Phase 3 UI per `TODO.md:67`.

## Source layout in this folder

- `vite.config.ts` — minimal Vite config, no Tailwind
- `engine.html` — host document loading `engine.ts`
- `engine.ts` — imports processing modules and exposes `window.BentoEngine`
- `package.json` — pinned BentoPDF processing deps (pdfjs, pdf-lib, etc.)
