import { defineConfig } from 'vite';

// Minimal Vite config for headless engine — no Tailwind, no framework plugins.
// Tree-shakes to only the 7 v1 engine tools; Tesseract excluded until v1.1.
export default defineConfig({
  root: '.',
  build: {
    outDir: '../assets/engine',
    emptyOutDir: false,
    target: 'esnext',
    rollupOptions: {
      input: 'engine.html',
    },
  },
  define: {
    // Air-gapped: WASM assets are local, not CDN. Values injected via env.
    // In Flutter assets/engine/, these resolve to http://127.0.0.1:<port>/wasm/...
    'import.meta.env.VITE_USE_CDN': JSON.stringify(process.env.VITE_USE_CDN ?? 'false'),
  },
  server: {
    headers: {
      'Cross-Origin-Opener-Policy': 'same-origin',
      'Cross-Origin-Embedder-Policy': 'require-corp',
    },
  },
});
