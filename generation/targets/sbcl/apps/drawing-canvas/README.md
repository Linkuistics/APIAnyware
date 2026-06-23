# drawing-canvas (sbcl target — the 060 ladder's 9th app, the transparent-subclass showcase)

A freehand drawing surface with per-stroke colour + line width. A REAL ObjC subclass of
`NSView` (`canvas-view`) overrides `drawRect:` and the three mouse-event selectors and is
driven by AppKit's own display/event loop; a second subclass of `NSObject`
(`canvas-controller`) carries the **Color… / width slider / Clear** target-actions. Drag to
draw, single-click for a dot; the slider sets stroke width, Color… picks the stroke colour
(live via `NSColorPanel`), Clear empties the canvas. The sbcl analogue of
racket/chez/gerbil's `drawing-canvas`.

## What it proves

The **first sbcl app to subclass NSVIEW** and run under AppKit's own display/event loop —
three sbcl firsts, each diverging from the gerbil precedent:

1. **NSView subclass under live framework dispatch.** `(define-objc-subclass canvas-view
   (ns:ns-view) …)` + one `define-objc-method` per `drawRect:`/`mouseDown:`/`mouseDragged:`/
   `mouseUp:`. The note-editor/mini-browser controllers subclassed NSObject for
   target-action/notification callbacks; here AppKit calls INTO Lisp on its own schedule, for
   the view's lifetime, through the same forwarding machinery (`_objc_msgForward` → bounce to
   main → the one Lisp dispatcher → CLOS). Instance via bare `(make-instance 'canvas-view)`
   (alloc/init) + `setFrame:` — a subclass make-instance does NOT take an ObjC init, so this
   mirrors gerbil's `(new …)` + `set-frame!`.

2. **`drawRect:`'s NSRect arg is delivered, not dropped.** The dispatcher reads the live
   `NSInvocation` signature — recovered from NSView's real `drawRect:` encoding via
   `class_getInstanceMethod` — so the override is `(self rect)` with `rect` an ignorable raw
   SAP (we repaint the whole bounds). Gerbil's generic trampoline instead DROPS the
   undeliverable struct (`(self)`-only). The mouse selectors take a deliverable NSEvent →
   `(self event)`.

3. **Direct CoreGraphics + a by-value struct RETURN.** Strokes render through `ns:cg-*`
   `define-alien-routine`s on the CGContextRef from `(ns:cg-context (ns:current-context …))`.
   `-[NSEvent locationInWindow]` / `-[NSView convertPoint:fromView:]` return
   `(sb-alien:struct ns-point)` by value; arm64 routes the HFA return cleanly, so x/y are read
   with `(sb-alien:slot p 'x)` and a returned struct chains straight into the convert call's
   struct arg — NO `point-x`/`point-y` accessor helper (gerbil needed one).

## Contract surface (ADR-0033)

- **Subclass macros (§3.4/§3.5):** `define-objc-subclass` + `define-objc-method` (TWO
  subclasses: `canvas-view`, `canvas-controller`).
- **Per-selector generics (§3.2):** the whole `ns:` / `ns:cg-*` method + function surface.
- **Typed init (§3.3):** `NSWindow initWithContentRect:…` via `make-instance` + initargs.
- **`@"…"` NSString reader (§3.2)** for menu literals; `(nsstr text)` for dynamic strings.

Drawing STATE (strokes, current RGB+width, drag flag) lives in `canvas-view` CLOS slots (the
sbcl idiom for gerbil's top-level mutable bindings), accessed via `slot-value` (not per-class
accessors — the helper bodies compile before the inner `define-objc-subclass` runs; the
mini-browser pattern). A stroke captures colour+width at mouse-DOWN time (a `defstruct`), so
later changes never retroactively alter it.

## Build & run

```sh
# Dev pre-flight (host construction smoke, no run loop):
SDKROOT=macosx AW_CANVAS_SMOKE=1 sbcl --non-interactive --disable-debugger \
  --load apps/drawing-canvas/run.lisp

# Build the standalone .app (pre-flight → dump → revive smoke):
apps/drawing-canvas/build.sh
# → apps/drawing-canvas/build/DrawingCanvas.app  (save-lisp-and-die :executable t, ~81 MB)
```

The dylib (`libAPIAnywareSbcl`) is loaded ONLY for the `aw_sbcl_subclass_*` bounce shim BOTH
subclasses use — NO block bridge, so (unlike note-editor) there is no
`aw-init-block-dispatcher`; the subclass dispatcher self-registers lazily on the first
`define-objc-method`.

Framework loads: Foundation `:load-residual nil`, AppKit `:load-residual nil` (every enum we
use is in the always-loaded `enums.lisp`), **CoreGraphics `:load-residual t`** (for the
`ns:cg-*` stroke functions — the first ladder app needing the residual flag for FUNCTIONS).

## VM provisioning (TestAnyware)

The standalone exe embeds the SBCL core; the VM needs `/tmp/libAPIAnywareSbcl.dylib` (the
recorded dylib path) + the zstd core-compression dylib at
`/opt/homebrew/opt/zstd/lib/libzstd.1.dylib`. **No network** (all rendering is local
CoreGraphics). Draw with `input drag` (a bare `input move` releases the VNC button mask → no
`mouseDragged:`). See `test-results/drawing-canvas/report.md`.
