# drawing-canvas x chez

**2026-07-03 (instrument+build, `chez-instrument-build-k135` — ✅ CLI smoke green):**
- 🟢 Instrumented to the k132 logging contract as the k134 racket mirror via the
  note-editor k126 house style (inline `dc-` emitter — quote-string omitted, no
  string values in this app; startup + test-config no-op top-level before
  `(main)`; terminate-hook app delegate). No deviation from the reference
  pattern. Freeze semantics fall out of the data model exactly as in racket:
  the stroke events read the stroke vector's own captured colour/width
  (`vector-ref stroke 0..3`); `mouseUp:` captures `(car (reverse strokes))`
  before `end-stroke!` clears the flags, emits after — post-state and frozen
  at once. Rounding lives once in the emitter (`dc-component->255`/
  `dc-width->int`, `exact`+`round`); the stderr `colorChanged:` guard stays
  off events.log.
- **Per-target corpus half (the k134 handoff):** the shared collect+resolve
  stood; this leaf ran `apianyware-generate --target chez` (new
  `coregraphics/` dir, 12 files) + adapter relink (`swift build --product
  APIAnywareChez`) BEFORE bundling (the k107 order). The trampoline table grew
  **175 → 221** by `grep -c @_cdecl` — the exact racket twin (the generate log
  says 220; the k125 off-by-one counting note applies). Goldens unmoved.
- `build.sh` (note-editor k126 mirror): production bundler → rename →
  `com.linkuistics.drawing-canvas-chez` → re-sign; prereq keys on
  `apianyware/coregraphics.sls`. Descriptor `drawing-canvas-impl.rkt`
  authored. `DrawingCanvas-chez.app` 5.1M open-world standalone (kernel baked
  in; ADR-0009).
- CLI smoke green: exact launch sequence `[lifecycle] startup` → bare launch
  line; AppleScript quit → `shutdown reason=menu`; no stray events; clean
  process exit. The `[canvas]` events are not host-reachable (every one needs
  a UI gesture) — witnessed by code-audit against the contract checklist + the
  emitter isolation run (emitter section sliced verbatim from the .sls, all
  contract example lines byte-exact, incl. the k112 device fold →
  `color-changed r=0 g=150 b=255` and the `width=11` rounding); live-run
  exercises them for real.

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
