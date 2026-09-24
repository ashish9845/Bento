# Privacy Policy — Bento (com.benopdf.scan)

**On-device only. No network.**

- All PDF processing (Merge, Split, Organize, Extract, Compress, Image→PDF, PDF→Image)
  runs on-device in a native engine (`pdf_manipulator`, MIT Rust core over FFI) off the
  main thread. No WebView, no file is uploaded.
- Document scanning uses on-device ML Kit (Android) / VisionKit (iOS). No cloud.
- No analytics, no tracking, no ads.
- Results are saved to your chosen location (Documents/Bento by default) when you choose Save/Share.
- Permissions: Storage (pick/save), Camera (scanner only, when you tap Scan). No background access.

Source is AGPL-3.0 and published alongside every store build per licensing terms.

Contact: via repo issues.
