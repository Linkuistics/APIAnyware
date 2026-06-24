# scenekit-viewer x chez

**2026-05-29 (source-exec port):**
- 🟡 3D render + delegate trio (`geometryChanged:`, `openColor:`, `colorChanged:`)
  fire in the TestAnyware VM. Source-exec/precompile bundle (108 MB). See
  `targets/chez/bindings/macos/reports/scenekit-viewer/report.md`.

**2026-05-30 (standalone, leaf `060/050/030`):**
- 🟢 Re-verified as a **production open-world standalone `.app`** (ADR-0009,
  5.0 MB, kernel baked in). **SceneKit/Metal renders in a no-Chez VM** — the
  dylib-search prelude resolves the GPU stack at runtime. All three selectors
  fire (cube→sphere swap, color panel opens, red→gray recolor). RSS flat ~126 MB.
  See the "Standalone re-verification" section of the report.
