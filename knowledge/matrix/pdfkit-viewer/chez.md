# pdfkit-viewer x chez

**2026-05-29 (source-exec port):**
- 🟡 Multi-delegate (4 selectors incl. NSNotificationCenter observer) fires;
  PDF loads + paginates in the TestAnyware VM. Source-exec/precompile bundle
  (107 MB). See `generation/targets/chez/test-results/pdfkit-viewer/report.md`.

**2026-05-30 (standalone, leaf `060/050/040`):**
- 🟢 Re-verified as a **production open-world standalone `.app`** (ADR-0009,
  5.0 MB, kernel baked in) in a **no-Chez VM**. All four selectors fire:
  openDocument: (NSOpenPanel → load), goNext:/goPrev: (page nav), pageChanged:
  (notification observer → "Page N of 3" label + button states). RSS ~226 MB
  with document loaded. See the "Standalone re-verification" section of the report.
