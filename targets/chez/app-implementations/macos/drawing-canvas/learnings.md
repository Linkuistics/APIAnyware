# drawing-canvas x chez

**2026-05-29 (source-exec port):**
- 🟡 Dynamic NSView subclass (`make-dynamic-subclass`) with 4 IMPs (drawRect: +
  3 mouse events) draws strokes; color/width/clear work. Found + fixed the
  all-sizes struct-return-buffer bug (leaf 025/140). Source-exec/precompile
  bundle (92 MB). See `targets/chez/bindings/macos/reports/drawing-canvas/report.md`.

**2026-05-30 (standalone, leaf `060/050/070`):**
- 🟢 Re-verified as a **production open-world standalone `.app`** (ADR-0009,
  4.8 MB, kernel baked in) in a **no-Chez VM** — the **capstone** for the
  embedded-compiler claim. Mouse drags draw strokes (dynamic-subclass IMPs fire),
  `drawRect:` with `(& NSRect)` renders, Clear works. RSS ~108 MB.
- ⚠️ Found + fixed a **whole-program-only bug**: the `(& NSRect)` IMP's ftype was
  invisible in the sealed binary's interaction-environment (source-exec relied on
  the app's top-level types import; `compile-whole-program` de-registers
  libraries so a runtime import fails too). Fix: `dispatch.sls` re-`define-ftype`s
  the geometry structs directly into the interaction-environment. See the report's
  standalone section + `targets/chez/docs/reference.md` gotchas.
