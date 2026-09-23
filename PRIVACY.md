# Privacy Policy — Beno PDF (com.benopdf.scan)

**On-device only. No network.**

- All PDF processing (Merge, Split, Organize, Extract, Compress, Image→PDF, PDF→Image) runs on-device via a local WebView engine (`flutter_inappwebview`) served by a `shelf` server on `127.0.0.1` with COOP/COEP headers for `SharedArrayBuffer`. No file is uploaded.
- Document scanning uses on-device ML Kit (Android) / VisionKit (iOS). No cloud.
- WASM modules (PyMuPDF, Ghostscript, CoherentPDF, pdf-lib, PDF.js) and OCR data (v1.1 `eng` only) are bundled at install; no CDN at runtime. `VITE_USE_CDN=false`.
- No analytics, no tracking, no ads. `SharedArrayBuffer` requires no outbound call.
- Files you pick are copied to temp (`bento_files`) only to pass local URLs to the engine; they are not sent elsewhere. Results are saved to app docs via `path_provider` when you choose Save/Share.
- Permissions: Storage (pick/save), Camera (scanner only, when you tap Scan). No background access.

Source is AGPL-3.0 and published alongside every store build per licensing terms.

Contact: via repo issues.
