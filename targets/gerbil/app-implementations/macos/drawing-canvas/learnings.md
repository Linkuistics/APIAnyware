# drawing-canvas x gerbil

**2026-07-03 (instrument+build, `gerbil-instrument-build-k136` — ✅ CLI smoke green):**
- 🟢 Instrumented to the k132 logging contract as the k134/k135 mirror via the
  note-editor k127 house style (inline `dc-` emitter on Gambit primitives only —
  quote-string omitted, no string values in this app; startup + test-config
  no-op top-level before `(main)`; terminate-hook app delegate,
  `nsapplication-set-delegate!` takes the delegate object directly). No
  deviation from the reference pattern. Freeze semantics fall out of the
  stroke-vector data model exactly as in racket/chez: the stroke events read
  the stroke vector's own captured colour/width (`vector-ref stroke 0..3`);
  `mouseUp:` captures `(car (reverse strokes))` before `end-stroke!` clears the
  flags, emits after — post-state and frozen at once. Rounding lives once in
  the emitter (`inexact->exact`+`round`); gerbil carries no stderr
  `colorChanged:` guard and needs none (contract note).
- **Per-target corpus half (the k134 handoff):** the shared collect+resolve
  stood; this leaf ran `apianyware-generate --target gerbil` (new
  `coregraphics/` dir, 11 modules) + adapter relink (`swift build --product
  APIAnywareGerbil`) BEFORE bundling (the k107 order). The trampoline table
  grew **175 → 221** by `grep -c @_cdecl` — the exact racket/chez twin (the
  generate log says 220; the k125 off-by-one counting note applies); the dylib
  gained 92 `aw_gerbil_swift_m_CoreGraphics_*` symbols. Goldens unmoved.
- **No generics-shadow this time** (the k127 `string-length` watch-out): the
  regenerated CG modules the app imports (`functions.ss`/`enums.ss`, 1214
  exported names) export nothing that collides with a Gambit builtin this app
  calls — no `(except-in …)` needed; all ten CG symbols the app uses
  (`CGContext*` ×8, `kCGLineCapRound`, `kCGLineJoinRound`) are present.
- `build.sh` (note-editor k127 mirror): production bundler → rename →
  `com.linkuistics.drawing-canvas-gerbil` → re-sign; prereq keys on
  `coregraphics/functions.ss` (a pre-k134 binding tree has generics but no
  coregraphics modules). Descriptor `drawing-canvas-impl.rkt` authored.
  Post-regenerate timings (cold shard cache): generics 37 shards 137.8s,
  facade 12.0s, closure 22 modules 72.6s, exe link 254.4s.
  `DrawingCanvas-gerbil.app` 58M standalone (static Gambit runtime + vendored
  openssl; ADR-0009).
- CLI smoke green: exact launch sequence `[lifecycle] startup` → bare launch
  line; AppleScript quit → `shutdown reason=menu`; no stray events; clean
  process exit. The `[canvas]` events are not host-reachable (every one needs
  a UI gesture) — witnessed by code-audit against the contract checklist + the
  emitter isolation run (emitter section sliced verbatim from the .ss via sed
  and `(include …)`d under the bottle gxi; all contract example lines
  byte-exact, incl. the k112 device fold → `color-changed r=0 g=150 b=255` and
  the `width=11` rounding); live-run exercises them for real.

**2026-06-08 (standalone, grove leaf `100/030`):**
- 🟢 Ported and VM-verified as a self-contained `.app` (ADR-0009; static Gambit
  runtime + vendored openssl, dylib-clean — and now linking **CoreGraphics**). In
  a **no-Gerbil VM**: drag paints smooth multi-point strokes, single click paints
  a round dot, the width slider thickens strokes, the Color panel changes stroke
  colour live (red verified), and Clear empties the canvas. See
  `generation/targets/gerbil/test-results/drawing-canvas/report.md`.
- **Transparent-subclass showcase (ADR-0020).** First app to drive a synthesized
  ObjC `NSView` subclass under live AppKit dispatch: `(defclass (DrawingCanvasView
  NSView) ())` + `(defmethod (DrawingCanvasView "drawRect:") (self) …)` and one
  `defmethod` per mouse selector (`:gerbil-bindings/runtime/subclass`). `drawRect:`'s
  `CGRect dirtyRect` is undeliverable by the generic trampoline → the override is
  `(self)` only (draw whole bounds); the mouse selectors take `(self event)`.
  Instance via `(new DrawingCanvasView)` + `nsview-set-frame!`. The IMP-trampoline
  callback path (typed `self` recovered from the back-ref table) survives
  whole-program `-O`.
- **Four latent defects this app surfaced (fixed at source)** — it is the first
  app past the all-`objc_msgSend` ceiling (custom subclass + direct CoreGraphics C
  calls + a non-ASCII title):
  1. `bundle-gerbil` cold-cache parallel-compile race → serial first-shard warmup.
  2. `emit-gerbil` `functions.ss` CoreGraphics header vs synthesized-`extern`
     conflict (the `#include`d CG geometry header's real prototypes collide with
     the `void *` fallback `extern`s for unmodelled-type functions) → declare CG
     structs inline in `functions.ss` (class modules keep the header).
  3. `bundle-gerbil` missing `-framework` on the `gxc -O` closure pass —
     `functions.ss` makes direct CG C calls, so the pre-compile loadable link
     needs the frameworks, not just the `-exe` link.
  4. `runtime/ffi.ss` `string->nsstring` used `char-string` (ISO-8859-1) → crashed
     on the `…` in "Color…"; switched the three NSString crossings to
     `UTF-8-string`. **Caught only by VM-verify**, not the build.
- Runtime addition: `point-x`/`point-y` accessors in `runtime/cocoa.ss` for the
  by-value `CGPoint` from `convertPoint:fromView:`.
- Idiom notes: drawing state + the subclass live at **top level** (Gerbil
  `defclass` is a definition form; single-window app state is process-scoped, cf.
  racket's module-level dynamic-class bindings); the toolbar `make-delegate`
  (`openColor:`/`widthChanged:`/`clearCanvas:`/`colorChanged:`) closes over that
  state plus its main-local view/control bindings; CG functions take the raw
  `(pointer void)` ctx from `nsgraphicscontext-cg-context`.
