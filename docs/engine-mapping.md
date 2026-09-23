# BentoPDF Engine Mapping — Phase 2

Generated after cloning https://github.com/alam00000/bentopdf @ /tmp/bentopdf (2026-09-23).

## Source layout in BentoPDF `src/js/`

- `src/js/logic/*.ts` — per-tool page controllers (UI + processing mixed). Files like `merge-pdf-page.ts` (683 LOC), `compress-pdf-page.ts` (617 LOC), `organize-pdf-page.ts`, `extract-pages-page.ts`, `image-to-pdf-page.ts` contain both DOM handling and calls to processing utils/workers.
- `src/js/utils/*.ts` — pure processing logic (safe to reuse headlessly):
  - `merge-cpdf.ts` — `mergePdfsCpdf` via `coherentpdf` WASM worker (`workers/merge.worker.js`)
  - `cpdf-helper.ts` / `wasm-provider.ts` / `wasm-preloader.ts` — WASM URL resolution for cpdf
  - `compress.ts` — `performCondenseCompression` via `pymupdf-loader.ts` (PyMuPDF WASM)
  - `pymupdf-loader.ts` / `ghostscript-loader.ts` / `ghostscript-dynamic-loader.ts` / `libreoffice-loader.ts` — WASM loaders for Compress
  - `images-to-pdf-lib.ts` — image→PDF via pdf-lib
  - `load-pdf-document.ts`, `pdf-operations.ts`, `split-pdf-helpers.ts` — split/extract/organize helpers
  - `ocr.ts` / `tesseract-runtime.ts` — OCR (deferred to v1.1)
- `src/js/handlers/` — `fileHandler.ts`
- `vendor/bentopdf-pdfium/` + `vendor/bentopdf-viewer/` — PDFium WASM (813903c)

## MVP 7 engine tools → processing modules

| v1 Tool | BentoPDF source (processing) | WASM / Lib |
|---|---|---|
| Merge PDFs | `src/js/logic/merge-pdf-page.ts` → `src/js/utils/merge-cpdf.ts` + `workers/merge.worker.js` | `coherentpdf` (`@neslinesli93/qpdf-wasm` + cpdf `coherentpdf.browser.min.js`) |
| Split PDFs | `src/js/logic/split-pdf-page.ts` + `split-pdf-helpers.ts` + `pdf-operations.ts` | same cpdf |
| Organize/Rotate/Delete | `src/js/logic/organize-pdf-page.ts` + `rotation-utils.ts` + `merge-cpdf.ts` | cpdf |
| Extract Pages | `src/js/logic/extract-pages-page.ts` + `pdf-operations.ts` | cpdf |
| Compress PDF | `src/js/logic/compress-pdf-page.ts` + `src/js/utils/compress.ts` + `pymupdf-loader.ts` | **PyMuPDF** (agpl, needs SAB), fallback Ghostscript (`ghostscript-loader.ts`) + LibreOffice (`libreoffice-loader.ts`) for image-heavy PDFs |
| Image → PDF | `src/js/logic/image-to-pdf-page.ts` + `images-to-pdf-lib.ts` + `image-input-utils.ts` | `pdf-lib` + `pdfjs` (no WASM) |
| PDF → Image | `src/js/logic/pdf-to-jpg-page.ts` / `pdf-to-png-page.ts` + `render-utils.ts` + `pdf.worker.ts` | `pdfjs-dist` (no WASM for render, but GS for rasterize option) |

Sign PDF is **native** (`pdf` package canvas overlay, not engine) — excluded from bundle per TODO.md.

## What to import headlessly (no UI, no Tailwind)

For `engine/engine.ts`, import **only** utils + workers:

```ts
import { mergePdfsCpdf } from '/tmp/bentopdf/src/js/utils/merge-cpdf';
import { performCondenseCompression } from '/tmp/bentopdf/src/js/utils/compress';
import { splitPdf } from '/tmp/bentopdf/src/js/utils/split-pdf-helpers';
import { imagesToPdfLib } from '/tmp/bentopdf/src/js/utils/images-to-pdf-lib';
// ...etc — never import logic/*-page.ts which pulls in ui.ts / DOM
```

Configure Vite with `VITE_USE_CDN=false` and local WASM URLs per BentoPDF air-gapped docs:
`VITE_WASM_CPDF`, `VITE_WASM_MUPDF`, `VITE_WASM_GS` resolve to `assets/engine/wasm/`.

## Air-gapped WASM assets to bundle

Copy from `/tmp/bentopdf/public/wasm` and `vendor/` (or CDN) into `assets/engine/wasm/`:
- `coherentpdf.browser.min.js` + `.wasm` (cpdf)
- `mupdf.wasm` (PyMuPDF)
- `gs.wasm` (Ghostscript) — optional fallback
- `soffice.wasm` (LibreOffice) — for office→PDF (not needed for MVP 7, but Compress may use)
- Exclude Tesseract `eng.traineddata` until v1.1

Current placeholder bundle is 16K (no WASM). Real bundle expected 40-80 MB.
