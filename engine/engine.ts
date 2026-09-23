/**
 * Headless BentoPDF engine entry — Vite minimal bundle.
 *
 * Tree-shaken to 7 engine-backed v1 tools only:
 *   merge, split, organize, extract, compress, imageToPdf, pdfToImage
 *
 * No UI, no Tailwind. Sign PDF is native (pdf package) and excluded.
 * OCR/Tesseract excluded until v1.1 (eng only).
 *
 * Exposes window.BentoEngine for Dart↔JS bridge (lib/engine/engine_bridge.dart).
 * Files are http://127.0.0.1:<port>/files/<name> URLs — not base64.
 *
 * TODO Phase 2: replace stub imports with real BentoPDF processing modules.
 *   Example (after mapping src/):
 *     import { mergePdfs } from '../../bentopdf/src/lib/merge'
 *     import { compressPdf } from '../../bentopdf/src/lib/compress'
 *     // ...etc — only processing logic, no Svelte/React components
 */

declare global {
  interface Window {
    BentoEngine: BentoEngine;
    BentoEngineReady: boolean;
  }
}

type BentoEngine = {
  merge: (fileUrls: string[]) => Promise<string>;
  split: (fileUrl: string, ranges: string[]) => Promise<string[]>;
  organize: (fileUrl: string, ops: unknown[]) => Promise<string>;
  extract: (fileUrl: string, pages: number[]) => Promise<string>;
  compress: (fileUrl: string, opts: string) => Promise<string>;
  imageToPdf: (fileUrls: string[]) => Promise<string>;
  pdfToImage: (fileUrl: string) => Promise<string[]>;
  _placeholder: boolean;
};

async function fetchAsBytes(url: string): Promise<Uint8Array> {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`fetch failed ${res.status} for ${url}`);
  return new Uint8Array(await res.arrayBuffer());
}

async function uploadResult(bytes: Uint8Array, name: string): Promise<string> {
  const base = location.origin;
  const res = await fetch(`${base}/files/${name}`, {
    method: 'POST',
    body: bytes as unknown as BodyInit,
    headers: { 'content-type': 'application/octet-stream' },
  });
  if (!res.ok) throw new Error(`upload failed ${res.status} for ${name}`);
  const url = (await res.text()).trim();
  return url || `${base}/files/${name}`;
}

// ---------------------------------------------------------------------------
// Stub implementations — replace with real BentoPDF processing logic.
// Each stub fetches input, would process, uploads result, returns URL.
// ---------------------------------------------------------------------------

const BentoEngine: BentoEngine = {
  _placeholder: true,

  merge: async (fileUrls) => {
    console.log('[BentoEngine] merge', fileUrls);
    // Real: fetch each, merge via pdf-lib/qpdf, upload
    void fetchAsBytes;
    void uploadResult;
    return fileUrls[0] ?? '';
  },

  split: async (fileUrl, ranges) => {
    console.log('[BentoEngine] split', fileUrl, ranges);
    return [fileUrl];
  },

  organize: async (fileUrl, ops) => {
    console.log('[BentoEngine] organize', fileUrl, ops);
    return fileUrl;
  },

  extract: async (fileUrl, pages) => {
    console.log('[BentoEngine] extract', fileUrl, pages);
    return fileUrl;
  },

  compress: async (fileUrl, opts) => {
    console.log('[BentoEngine] compress', fileUrl, opts, 'SAB:', typeof SharedArrayBuffer);
    // This is the spike that requires SharedArrayBuffer (Ghostscript WASM).
    // Real impl must fail clearly if SAB unavailable.
    if (typeof SharedArrayBuffer === 'undefined') {
      throw new Error('SharedArrayBuffer unavailable — COOP/COEP headers missing');
    }
    return fileUrl;
  },

  imageToPdf: async (fileUrls) => {
    console.log('[BentoEngine] imageToPdf', fileUrls);
    return fileUrls[0] ?? '';
  },

  pdfToImage: async (fileUrl) => {
    console.log('[BentoEngine] pdfToImage', fileUrl);
    return [fileUrl];
  },
};

window.BentoEngine = BentoEngine;
window.BentoEngineReady = true;

console.log('[BentoEngine] headless ready (placeholder=', BentoEngine._placeholder,
  ') SharedArrayBuffer:', typeof SharedArrayBuffer !== 'undefined', ')');
