# drawing-canvas x gerbil

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
