# drawing-canvas x sbcl

**2026-06-23 (grove `add-sbcl-clos-target`, leaf `drawing-canvas-k34` — 060 ladder app 9, the
final app):**

- 🟢 Built + **VM-verified** as a standalone `save-lisp-and-die :executable t` dump (81 MB exe +
  the `aw_sbcl_subclass_*` dylib at `/tmp`). In a no-SBCL VM: drag paints smooth connected
  strokes, a single click paints a round dot, the width slider thickens subsequent strokes
  (per-stroke width preserved), the `NSColorPanel` recolours them live (orange verified, prior
  strokes stayed black), Clear empties the canvas, Cmd-Q quits cleanly. See
  `test-results/drawing-canvas/report.md`.

- **Transparent-subclass showcase — the FIRST sbcl app to subclass NSVIEW** and run under
  AppKit's own display/event loop. `(define-objc-subclass canvas-view (ns:ns-view) …)` + one
  `define-objc-method` per `drawRect:`/`mouseDown:`/`mouseDragged:`/`mouseUp:`. The
  note-editor/mini-browser controllers subclassed NSObject for target-action/notification
  callbacks; here the framework calls INTO Lisp on its own schedule. Same forwarding machinery
  (`_objc_msgForward` → main-thread bounce → the one dispatcher → CLOS), now framework-initiated.
  Instance via bare `(make-instance 'canvas-view)` (alloc/init — a subclass make-instance does NOT
  take an ObjC init like `initWithFrame:`; subclass.lisp's `:around` does bare alloc/init + records
  the back-ref) then `(ns:set-frame_ canvas …)`. Mirrors gerbil's `(new DrawingCanvasView)` +
  `set-frame!`.

- **`drawRect:`'s NSRect arg IS DELIVERED on sbcl (divergence from gerbil).** The forwarding
  dispatcher reads the LIVE `NSInvocation` signature, and `aw-resolve-method-encoding` step 2
  recovers NSView's real `drawRect:` encoding (`v@:{CGRect=…}`) via `class_getInstanceMethod` — so
  the override is `(self rect)` with `rect` a raw SAP (the `{`-struct case of `aw-read-arg`). We
  `(declare (ignore rect))` and repaint the whole bounds. Gerbil's generic trampoline DROPS the
  undeliverable struct, making its override `(self)`-only. (`aw-encoding-size` uses
  `NSGetSizeAndAlignment`, so the 32-byte `{CGRect=…}` arg buffer is correctly sized — no
  overflow.) The mouse selectors take a deliverable NSEvent object → `(self event)`.

- **By-value struct RETURNS are directly slot-readable — NO accessor helper (divergence from
  gerbil).** `-[NSEvent locationInWindow]` and `-[NSView convertPoint:fromView:]` are emitted as
  `alien-funcall`s returning `(sb-alien:struct ns-point)`. arm64 routes the HFA return cleanly, so
  `(sb-alien:slot (ns:location-in-window ev) 'x)` reads x, and a RETURNED struct value chains
  straight into `convert-point_from-view_`'s struct arg. Verified by a headless spike (NSView
  frame/bounds slot-read + a convert-point round-trip) BEFORE writing app code. Gerbil needed
  hand-written `point-x`/`point-y` accessors in `runtime/cocoa.ss` because Gambit's FFI returns
  by-value structs differently; sbcl's `sb-alien` needs none.

- **CoreGraphics is the first ladder app needing `:load-residual t` for FUNCTIONS.** The `ns:cg-*`
  stroke functions are `define-alien-routine`s in `coregraphics/functions.lisp`, which the dev
  loader only loads with residual t (constants.lisp + functions.lisp are the gated files). The
  CGContextRef is the `system-area-pointer` from `(ns:cg-context (ns:current-context (find-class
  'ns:ns-graphics-context)))`. `CGContextStrokePath` exists directly as `ns:cg-context-stroke-path`
  (no `draw-path`+mode needed), and `kCGLineCapRound`/`kCGLineJoinRound` are in the always-loaded
  `coregraphics/enums.lisp`. Loading the full CoreGraphics tree (incl. its CF-typed class files)
  loaded cleanly — verified by a second headless spike before the build.

- **Zero runtime + zero emitter changes.** Every binding (AppKit + Foundation + CoreGraphics) was
  already generated; the 050 subclass machinery + the FFI struct seam handled all four new shapes
  (NSView subclass under dispatch; delivered-then-ignored struct arg; by-value struct return;
  direct `ns:cg-*` C calls). The eight selector kebab-names (`draw-rect_`…`clear-canvas_`) are all
  fresh — no collision with an emitted 0-arg method.

- **Idiom notes:** drawing state (strokes, current RGB+width, drag flag) lives in `canvas-view`
  CLOS slots (sbcl idiom; gerbil used top-level mutable bindings), accessed via `slot-value` (not
  per-class accessors — the helper bodies compile before `define-objc-subclass` runs; the
  mini-browser pattern). A stroke captures colour+width at mouse-DOWN time (a `defstruct`), so
  later colour/width changes never retroactively alter it. Round line cap/join means a single-point
  stroke (a bare click) paints a disc — add a coincident second point so `StrokePath` has a
  non-empty path. All `ns:cg-*` numeric args are `sb-alien:double`: the slider/component returns and
  the struct-slot reads are already double-floats, so no coercion at the call site.

- **VM-verify mechanics:** a bare `input move` between `mouse-down`/`mouse-up` RELEASES the VNC
  button (pointer events carry a button mask; a plain move sends mask 0) → no `mouseDragged:`, only
  a down-point dot. Use `input drag` (button held through the motion) for strokes; the continuous
  `NSColorPanel` action likewise wants a `drag`, not a click. Target everything from `agent snapshot
  --window … --json` input-space coords — the full-screen screenshot PNG scale varied between
  captures while the AX coords stayed stable.
