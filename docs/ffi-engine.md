# Native FFI Engine — Phase 2

Processing runs through [`pdf_manipulator` 5.0.0](https://pub.dev/packages/pdf_manipulator)
(MIT-licensed Rust core over FFI). No WebView, no JS, no WASM, no local HTTP server.
Supports Android (API 21+, arm64/arm/x64/x86) and iOS 13+ (device + simulator).
The native library is fetched by the package build hook on first build.

## Entry point

`lib/data/tools/datasources/pdf_engine_data_source.dart` — one shared `Pdf()`
instance (per package guidance), every operation already runs off the main thread.

## v1 tools → engine calls

| Tool | Engine call |
|---|---|
| Merge PDFs | `merge([FileSource…], sink)` |
| Split PDF | `pageCount` + `parsePageRanges("1-2, 3, 4-end")` + `extractPages` per chunk |
| Organize/Rotate/Delete | single `edit()` session: `selectPages` (delete/reorder) + `rotatePage`, then `save` |
| Extract Pages | `extractPages(source, sink, pages: [...])` |
| Compress PDF | `compress(source, sink, images: PdfImagePolicy.screen/ebook/lossless)` |
| Image → PDF | `imagesToPdf([FileSource…], sink)` |
| PDF → Image | `open` + `render(pages: all, size: 1440px)` → PNG files |

Sign PDF stays native (`pdf` package overlay) — the engine `sign()` needs PKCS#12
certificates, which is digital signing, a different feature.

Engine outputs are written straight to the save directory
(custom/default Documents) — no temp copies, no Files-tab duplicates.

## Errors

Typed `PdfError`s are mapped to friendly messages in the data source:
password-protected → "decrypt it first", corrupted → "not a valid PDF",
everything else surfaces `PdfError.message`.

## History

Replaces the retired WebView/JS plan (Vite bundle, `window.BentoEngine`,
`shelf` 127.0.0.1 server, invisible WebView, AGPL WASM) — all deleted.
