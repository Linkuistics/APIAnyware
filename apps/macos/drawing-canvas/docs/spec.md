# Drawing Canvas

Freehand drawing app with color picker and line width control. The most
architecturally novel sample app — a dynamic ObjC subclass with four method
overrides (`drawRect:`, `mouseDown:`, `mouseDragged:`, `mouseUp:`) bridges
Cocoa event handling and CoreGraphics drawing into Racket-level state.

## Layout

- Custom NSView subclass (`DrawingCanvasView`, allocated at load time via
  `make-dynamic-subclass`) fills the window's content area below a
  32-point toolbar.
- Toolbar (top): "Color…" button (opens `NSColorPanel`), line-width
  `NSSlider` (1.0…20.0, double-value continuous), "Clear" button.

## Interactions

1. Mouse down on canvas — starts a new stroke at the event point
2. Mouse drag — appends each drag point to the current stroke and
   requests redraw (`setNeedsDisplay:`)
3. Mouse up — finalizes stroke
4. Color button — opens the shared `NSColorPanel`; selecting a color
   updates the current RGB state (via `setAction:`/`setTarget:` on the
   panel) used for subsequent strokes
5. Slider — continuous update of line width
6. Clear — drops all stored strokes and redraws

## API surface

- Dynamic `NSView` subclass via `runtime/dynamic-class.rkt`
  (`make-dynamic-subclass` + four `add-method!` entries)
- `drawRect:` — pulls current `CGContext` from `NSGraphicsContext`, iterates
  strokes, uses `CGContextMoveToPoint` / `AddLineToPoint` / `StrokePath`
- `mouseDown:` / `mouseDragged:` / `mouseUp:` — coordinate extraction via
  `nsevent-location-in-window` + `nsview-convert-point-from-view`
- `NSColorPanel` — shared color picker; extract RGB via
  `nscolor-red-component` / `green-component` / `blue-component`
- `NSSlider` (continuous, double value)
- `NSButton` (Color, Clear)

## Novel patterns

- **Dynamic ObjC subclass as primary pattern** — four overrides on one
  class. Type encodings for overrides are pulled from the parent class
  via `method-type-encoding` rather than hand-written.
- **CoreGraphics drawing inside `drawRect:`** — first app using
  `CGContext*` functions end-to-end.
- **Mouse event coordinate transformation** — `locationInWindow` → view
  coords via `convertPoint:fromView:` with `fromView=nil`.
- **Mutable shared state accessed from ObjC callbacks** — stroke list is
  mutated by mouse callbacks and read by `drawRect:`, all on the main
  thread.
- **IMP GC retention** — module-level `define`s hold the procs; closures
  would be reclaimed.

## VM test strategy

1. Launch → blank canvas + toolbar, no crash
2. Drag across canvas → stroke appears (screenshot diff vs blank)
3. Change slider → subsequent strokes visibly thicker
4. Open color panel, pick red → subsequent strokes are red
5. Clear → canvas returns to blank
