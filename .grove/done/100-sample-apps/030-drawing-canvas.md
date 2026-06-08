# 030-drawing-canvas

**Kind:** work

## Goal

Port `generation/targets/chez/apps/drawing-canvas/` to gerbil — a freehand
drawing app (per-stroke colour + width, NSColorPanel) built on a **custom NSView
subclass** that overrides `drawRect:` + 3 mouse handlers — then bundle and
**VM-verify** that strokes actually draw (drag to paint, colour/width/clear work).

## Context

The hardest test of the 050/030 subclass-synthesis runtime (`runtime/subclass.ss`)
under live AppKit dispatch, plus CoreGraphics drawing (emitted at 020). CoreGraphics
+ subclass bindings now exist (`lib/coregraphics/`, `runtime/subclass.ss`).

Reconnaissance done (2026-06-08), so this is mostly mechanical porting:

- **Subclass** via the shadowing forms (import `:gerbil-bindings/runtime/subclass`):
  `(defclass (DrawingCanvasView NSView) ())` then
  `(defmethod (DrawingCanvasView "drawRect:") (self) …)` and one per mouse selector.
  **Key:** `drawRect:`'s `CGRect dirtyRect` is a struct → **undeliverable** by the
  generic trampoline, so the override receives **only `self`** (draw the whole
  bounds, as the racket/chez ports do — they ignore the rect). `mouseDown:`/
  `mouseDragged:`/`mouseUp:` take an `event` object (deliverable) → `(self event)`.
  Instantiate with `(new DrawingCanvasView)` — no manual alloc/initWithFrame
  msgSend (the runtime does it); set its frame via `nsview-set-frame!`.
- **CoreGraphics fns** are emitted in `lib/coregraphics/functions.ss` with the C
  names verbatim, taking a `(pointer void)` ctx:
  `(CGContextSetRGBStrokeColor ctx r g b a)`, `CGContextSetLineWidth`,
  `CGContextSetLineCap`, `CGContextSetLineJoin`, `CGContextBeginPath`,
  `CGContextMoveToPoint`, `CGContextAddLineToPoint`, `CGContextStrokePath`.
  Constants `kCGLineCapRound`/`kCGLineJoinRound` exist (confirm exact gerbil names
  in `coregraphics/enums.ss`/`constants.ss`).
- **Graphics ctx:** `nsgraphicscontext-current-context` (class method) →
  `nsgraphicscontext-cg-context` → the ctx pointer. Confirm whether cg-context
  returns a wrapped object (then `(->ptr ctx)`) or a raw pointer; pass to the CG fns.
- **Toolbar** (Color…/width slider/Clear) + NSColorPanel callbacks via `make-delegate`
  (same idiom proven in 010 ui-controls-gallery): `'object` token wraps sender.
- **Color extraction:** normalise the panel colour to device-RGB
  (`nscolor-color-using-color-space` + `nscolorspace-device-rgb-color-space`) before
  red/green/blue-component (RGB-only methods).

## Known porting tasks / risks

1. **Missing point accessors.** `runtime/cocoa.ss` has `rect-x/y/width/height` +
   `make-point` but **no `point-x`/`point-y`**. The mouse handlers need x/y from the
   `CGPoint` returned by `nsevent-location-in-window` + `nsview-convert-point-from-view`.
   Add `point-x`/`point-y` `define-c-lambda`s to cocoa.ss's geometry begin-ffi
   (CGPoint by value → double), export them. (Hand-written runtime change — tracked.)
2. **By-value CGPoint crossing.** Verify the emitted `nsevent-location-in-window`
   (returns NSPoint/CGPoint by value) and `nsview-convert-point-from-view` (CGPoint
   param by value + view, returns CGPoint) actually marshal the struct correctly —
   this is the by-value-geometry path; if an emitted method drops the struct, that's
   an emitter gap to fix + regenerate.
3. **drawRect: redraw trigger:** `nsview-set-needs-display!` (NSView) after each
   mouse event. Confirm it exists on NSView.

## Done when

- `drawing-canvas.ss` mirrors the chez app one piece at a time; bundled
  (`com.linkuistics.DrawingCanvas`); **VM-verified**: drag paints smooth strokes,
  Color… opens the panel and changes stroke colour live, width slider changes
  thickness, Clear empties the canvas, a single click paints a round dot.
- Report + screenshots under `generation/targets/gerbil/test-results/drawing-canvas/`
  + `knowledge/matrix/drawing-canvas/gerbil.md`.

## Notes

Use the **bottle** toolchain; build ~10 min (generics recompile per app — known
non-amortised cost). This is the subclass-synthesis showcase: getting `drawRect:`
firing from AppKit into a Gerbil method, under whole-program `-O`, in a no-Gerbil VM.
