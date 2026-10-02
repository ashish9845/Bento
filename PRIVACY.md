# Privacy Policy — Bento (com.benopdf.scan)

**On-device only. No analytics, no tracking, no ads.**

- All PDF processing (Merge, Split, Organize, Extract, Compress, Image→PDF, PDF→Image)
  runs on-device in a native engine (`pdf_manipulator`, MIT Rust core over FFI) off the
  main thread. No WebView, no file is uploaded.
- Document scanning uses Google ML Kit on Android. No cloud. (Scanning is Android-only; iOS shows an unsupported notice.)
- Crash reporting (Sentry, strictly opt-in and off by default): nothing leaves
  the device unless you turn on Settings → Privacy → “Send crash reports”.
  When enabled, only fatal-error reports are sent: the error, stack trace,
  app version and device model. No documents, file names, file contents,
  or personal data are ever included. Reports are queued offline and
  uploaded when connectivity returns; turning the switch off stops all
  sending immediately (already-queued reports are dropped).
- Results are saved to your chosen location (Documents/Bento by default) when you choose Save/Share.
- Permissions: Storage (pick/save), Camera (scanner only, when you tap Scan). No background access.

Source is AGPL-3.0 and published alongside every store build per licensing terms.

Contact: via repo issues.
