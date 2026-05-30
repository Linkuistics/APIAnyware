# ui-controls-gallery x chez

**2026-05-29 (source-exec port):**
- 🟡 All controls render; three delegates (`selectRadio:`, `sliderChanged:`,
  `stepperChanged:`) fire correctly in the TestAnyware VM. Source-exec/precompile
  bundle (103 MB). See `generation/targets/chez/test-results/ui-controls-gallery/report.md`.

**2026-05-30 (standalone, leaf `060/050/020`):**
- 🟢 Re-verified as a **production open-world standalone `.app`** (ADR-0009,
  5.8 MB, kernel baked in). All three dispatch trampolines fire in a **no-Chez
  VM** — first proof the `eval`-synthesised `foreign-callable` substrate survives
  whole-program optimisation. RSS flat at 117 MB across ~15 dispatch round-trips.
  See the "Standalone re-verification" section of the report.
