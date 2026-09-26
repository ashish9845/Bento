# Store Metadata — Bento (com.benopdf.scan)

## Short description (80 chars)
Offline PDF tools + scanner — Merge, Compress, Sign & more. 100% on-device.

## Full description

Bento is an offline-first PDF toolkit plus document scanner. All processing is on-device — no upload, no cloud. Built on a native FFI engine (pdf_manipulator, MIT) plus native scanning.

**Tools (v1):** Merge PDFs, Split, Organize/Rotate/Delete, Extract Pages, Compress PDF (balanced/high quality), Image→PDF, PDF→Image, Sign PDF (draw signature, native).

**Scanner:** On-device document scanner with auto edge detection, auto-crop, multi-page review, color/gray/B&W filters, rename-before-save, compose to PDF, Send to tool. Google ML Kit on Android; OpenScan pipeline (BSD-3-Clause) on iOS.

**Offline:** Native engine bundled with the app; no CDN, no downloads. OCR (eng only) in v1.1.

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
