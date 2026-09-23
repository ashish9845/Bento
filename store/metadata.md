# Store Metadata — Beno PDF (com.benopdf.scan)

## Short description (80 chars)
Offline PDF tools + scanner — Merge, Compress, Sign & more. 100% on-device.

## Full description

Beno PDF is an offline-first PDF toolkit plus document scanner. All processing is on-device — no upload, no cloud. Built on the BentoPDF engine running headlessly (PyMuPDF, Ghostscript, CoherentPDF are AGPL) plus native scanning.

**Tools (v1):** Merge PDFs, Split, Organize/Rotate/Delete, Extract Pages, Compress PDF (balanced/high quality), Image→PDF, PDF→Image, Sign PDF (draw signature, native).

**Scanner:** ML Kit GMS Document Scanner (Android) + VisionKit (iOS). Live border detection, auto-crop, multi-page, color/gray/B&W filters, compose to PDF, Send to tool (Compress/Sign). See docs/scanner-evaluation.md.

**Offline:** All WASM bundled (~56 MB apparent engine); no CDN. VITE_USE_CDN=false. OCR (eng only) in v1.1.

**Privacy:** No network. See PRIVACY.md. AGPL-3.0 — full source published with every build.

## Keywords
pdf, merge pdf, split pdf, compress pdf, image to pdf, pdf to image, sign pdf, scanner

## Screenshots needed (Phase 7)

- Tool grid (M3)
- Merge (reorder list)
- Compress (quality segmented + spike badge)
- Sign (draw pad)
- Scan (camera + grid)
- Files (recent) / Settings (AGPL notice)

## Icons / Splash

Placeholder app icon currently Flutter default. Generate via `flutter_launcher_icons` (1024) and `flutter_native_splash` (M3 seed 0xFF3B5BFE). Required before store upload.

## Version

1.0.0+1 · Android minSdk 24 · iOS 13+
