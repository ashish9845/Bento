# Bento — Offline PDF Tools & Document Scanner

Bento is an **offline-first** Flutter app for everyday PDF work: merge, split,
organize, compress, convert, protect, unlock, sign — plus a native document
scanner. Every screen is built natively in Flutter, and all PDF processing
runs **on-device** through a native Rust engine over FFI. No accounts, no
uploads, no network calls. Airplane mode works.

**License: AGPL-3.0** (see [License](#license)).

## Features

**10 PDF tools** (Tools tab, 4-per-row launcher grid with search):

| Tool | What it does |
|---|---|
| Merge PDFs | Combine multiple PDFs into one |
| Split PDF | Split by page ranges (`1-2, 3, 4-end`) |
| Organize Pages | Rotate / delete / reorder with thumbnails |
| Extract Pages | Pull selected pages into a new PDF |
| Compress PDF | Shrink file size (Low / Medium / High) |
| Image → PDF | Convert images into a PDF |
| PDF → Image | Export pages as PNGs |
| Protect PDF | Password-protect with AES-256 |
| Unlock PDF | Remove password protection |
| Sign PDF | Draw a signature and stamp it on a page |

Plus:

- **Smart Scan** — Google ML Kit document scanner on Android (edge detection,
  crop, filters built in); OpenScan pipeline (custom camera + pure-Dart edge
  detection) on iOS. Review, reorder, rename, export to PDF, or send straight
  into another tool (e.g. Compress, Sign).
- **Files tab** — local file browser with tap-to-open, share, delete, and a
  long-press menu (Open / Share / Send to… / Details / Delete).
- **Home dashboard** — search across tools, shortcut grid, recent files, scan FAB.
- **Theming** — Dark / Light / System plus 32 app themes (Default, Dynamic /
  Material You, Catppuccin, Lavender, Mocha, Dracula, Nord, Gruvbox and more)
  with swipeable live previews. Swipe left/right to switch tabs.
- **Fully offline** — every engine module and font is bundled at build time.
  Nothing is downloaded on first use.

## Getting started

Requirements: Flutter 3.47+ / Dart 3.13+ (see CI), Android SDK 37 for release
builds.

```bash
flutter pub get
flutter analyze
flutter test
flutter run            # debug build on a connected device / emulator
```

Release builds:

```bash
flutter build apk --release --split-per-abi   # per-ABI APKs
flutter build appbundle --release             # Play Store bundle
```

No engine build step — the native library ships with the `pdf_manipulator`
package (its build hook fetches it on first build). Android needs
`minSdk 24`; iOS needs 13+. The upload keystore (`android/upload-keystore.jks`
+ `android/key.properties`) is gitignored — back both up; losing the key
means a new store listing.

## Architecture

```
lib/
  core/            # theme (32 palettes + mode), go_router table + transitions,
                   # storage location, file opener, shared widgets
  data/tools/      # FFI engine data source + ToolsRepository (all PDF ops)
  data/files/      # local file repository
  presentation/    # Repository → Bloc → UI screens (files, merge, image2pdf)
  features/
    tools/         # native per-tool screens (file picker → options → progress → result)
    scan/          # scanner UI + review flow; openscan/ (iOS pipeline)
    files/         # file browser UI
    settings/      # theme picker, storage location, about/licensing
```

- **State management:** Riverpod (`ToolController` per tool) + flutter_bloc in
  the presentation layer. No other patterns.
- **PDF engine:** [`pdf_manipulator`](https://pub.dev/packages/pdf_manipulator)
  5.0.0 (MIT-licensed Rust core over FFI). Single shared instance in
  `lib/data/tools/datasources/pdf_engine_data_source.dart`; outputs are
  verified (page count + render check) before reaching the user.
- **Scanner:** [`google_mlkit_document_scanner`](https://pub.dev/packages/google_mlkit_document_scanner)
  on Android; vendored OpenScan CV core on iOS
  (`lib/features/scan/openscan/`, BSD-3-Clause, see `third_party/openscan/`).

Tests: `flutter test` (unit + widget + real-engine smoke tests).
CI runs analyze + tests on PRs (`.github/workflows/ci.yaml`).

## Credits

Bento stands on the shoulders of these projects — thank you:

- **[BentoPDF](https://www.bentopdf.com/)** ([github.com/alam00000/bentopdf](https://github.com/alam00000/bentopdf))
  — the open-source web PDF toolkit whose processing logic inspired this app's
  toolset. Bento reimplements that experience as a fully native, offline
  mobile app; only the ideas are reused, none of BentoPDF's site UI or code
  is bundled here.
- [pdf_manipulator](https://pub.dev/packages/pdf_manipulator) — MIT-licensed
  Rust PDF engine (merge, split, organize, compress, encrypt, render).
- [google_mlkit_document_scanner](https://pub.dev/packages/google_mlkit_document_scanner)
  — Google ML Kit document scanner (Android).
- [OpenScan](https://github.com/ethereal-developers/OpenScan) (ethereal-developers,
  BSD-3-Clause) — camera document-scanning pipeline vendored for iOS
  (`third_party/openscan/`).
- mpvRx theme system (AGPL-3.0) — the 32-theme table
  and scheme-derivation rules ported in `lib/core/theme/app_palettes.dart`.
- [Material Symbols](https://fonts.google.com/icons) (Apache 2.0) and
  [Pixelify Sans](https://fonts.google.com/specimen/Pixelify+Sans) (OFL 1.1,
  bundled in `assets/fonts/`) for icons and the Tools-tab footer. Body text
  uses the platform system font (no custom body font is bundled, keeping the
  public repo free of proprietary type).

See also `PRIVACY.md` (offline guarantee), `docs/ffi-engine.md`, and
`store/metadata.md`.

## License

**AGPL-3.0-or-later.** The entire app, including all custom Flutter/UI code,
is open source under AGPL-3.0 — see [`LICENSE`](LICENSE). (Historical note:
the AGPL WASM processing components were removed with the old WebView engine;
the current engine is MIT — but the repo stays AGPL-3.0 until the owner
decides otherwise. Do not add AGPL/GPL PDF libraries without flagging it.)
