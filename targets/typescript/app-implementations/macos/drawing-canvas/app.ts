// drawing-canvas — the Node TypeScript target's Drawing Canvas sample app (ladder rung 7/7, the
// LAST app): a 640×480 window with a 36-point toolbar band (`Color…` button, a 1–20 line-width
// slider, `Clear` button) over a freehand-drawing canvas. The canvas is a dynamic `NSView`
// subclass overriding `drawRect:` (repaint every stroke via direct CoreGraphics C calls) and
// `mouseDown:`/`mouseDragged:`/`mouseUp:` (the drawing gesture) — the portfolio's custom-view
// showcase (spec complexity 5/7). Mirrors the racket/chez/gerbil/sbcl `drawing-canvas` apps
// (`apps/macos/drawing-canvas/docs/spec.md`).
//
// Loaded by bootstrap.cjs strictly AFTER the dispatch backend is installed — see hello-window's
// app.ts for why. Does NOT call `NSApplication.run()`: the native launcher (embed_main.mm) owns
// `main()` and calls `[NSApp run]` itself, AFTER this module finishes (ADR-0056).
//
// FIRST app in this ladder to subclass `NSView` itself (every earlier app's subclass was a plain
// `NSObject` target-action/notification controller) — the framework calls INTO the app on its own
// schedule (`drawRect:`, the mouse selectors), not the other way round. Two prerequisite gaps were
// closed immediately ahead of this leaf, both cited rather than re-derived here:
//   - `inbound-struct-arg-surface-k123` widened the inbound trampoline/super-send tables to admit
//     a struct-by-value PARAMETER, so `NSView.__overridable` finally lists `drawRect_` (a `CGRect`
//     param) — without it, `extends NSView` could not override `drawRect:` at all.
//   - `coregraphics-context-function-surface-k124` admitted the eight direct-C CoreGraphics
//     drawing functions and `NSGraphicsContext.CGContext()` into the free-function/method surface.
//
// A SECOND, genuinely new thing this app needs: `mouseDown_`/`mouseDragged_`/`mouseUp_` each take
// a real `NSEvent` (an OBJ-kind arg) — every earlier subclass override in this ladder only ever
// took a RAW-kind arg (an ignored target-action sender, a notification token), which crosses
// unconverted with no marshal at all. An OBJ-kind inbound arg crosses the C ABI as a bare pointer
// handle (marshal.ts's own module doc: the native side cannot itself know which pointer is an
// object to wrap), so `__bindSubclass` needs an explicit `CallbackMarshal` (`__methodMarshal`,
// built by hand from the exact `args`/`ret` shapes `NSView`/`NSResponder`'s own generated
// `__overridable` entries already carry) or `event.locationInWindow()` below would be called on a
// raw `bigint`. `drawRect:`'s struct arg needs no conversion at this layer (already a real
// `{origin,size}` object by the time it reaches JS — `inbound-struct-arg-surface-k123`'s own
// `native/test/inbound-struct-arg.mjs` proves this crosses correctly even with NO marshal at all),
// but every selector reaching a marshalled callback must have an entry in it (marshal.ts's
// `driver` throws on an uncovered selector) — so `drawRect:` is listed too, RAW-to-RAW.

import {
  NSApplication,
  NSApplicationActivationPolicy,
  NSAutoresizingMaskOptions,
  NSBackingStoreType,
  NSBezelStyle,
  NSButton,
  NSColor,
  NSColorPanel,
  NSColorSpace,
  NSEvent,
  NSGraphicsContext,
  NSMenu,
  NSMenuItem,
  NSSlider,
  NSView,
  NSWindow,
  NSWindowStyleMask,
} from '@apianyware/appkit';
import {
  CGContextAddLineToPoint,
  CGContextBeginPath,
  CGContextMoveToPoint,
  CGContextSetLineCap,
  CGContextSetLineJoin,
  CGContextSetLineWidth,
  CGContextSetRGBStrokeColor,
  CGContextStrokePath,
  CGLineCap,
  CGLineJoin,
} from '@apianyware/coregraphics';
import { NSString } from '@apianyware/foundation';
import {
  NSObject,
  OBJ,
  RAW,
  RET_RAW,
  __alloc,
  __allocSubclass,
  __bindSubclass,
  __cfstr,
  __class,
  __methodMarshal,
  __subclassAlloc,
  __wrapOwned,
} from '@apianyware/runtime';
import type { CGPoint, CGRect, SubclassOverride } from '@apianyware/runtime';

function jsString(s: string): NSString {
  return __wrapOwned(NSString, __cfstr(s))!;
}

function rect(x: number, y: number, w: number, h: number): CGRect {
  return { origin: { x, y }, size: { width: w, height: h } };
}

// ── App menu (Quit -> -[NSApplication terminate:]), as the rest of the ladder. ─────────────────
function installAppMenu(app: NSApplication, appName: string): void {
  const mainMenu = __alloc(NSMenu).initWithTitle_(jsString(''));
  const appMenuItem = __alloc(NSMenuItem).initWithTitle_action_keyEquivalent_(jsString(''), '', jsString(''));
  const appMenu = __alloc(NSMenu).initWithTitle_(jsString(appName));
  const quitItem = __alloc(NSMenuItem).initWithTitle_action_keyEquivalent_(
    jsString(`Quit ${appName}`),
    'terminate:',
    jsString('q'),
  );
  appMenu.addItem_(quitItem);
  appMenuItem.setSubmenu_(appMenu);
  mainMenu.addItem_(appMenuItem);
  app.setMainMenu_(mainMenu);
}

// A nil source view for `convertPoint:fromView:` (window coordinates → this view's own) — the same
// "mint a real null instance rather than fight the non-nullable emitted type" pattern note-editor's
// own `NIL_URL` uses (`__wrapOwned` returns null for a 0n handle by construction; `!` only asserts
// the TS type, the runtime value stays genuinely null).
const NIL_VIEW = __wrapOwned(NSView, 0n)!;

// ── The canvas (spec §6/§7) — a stroke collection + capture-at-mouse-down tool state. ───────────

interface RGB {
  readonly r: number;
  readonly g: number;
  readonly b: number;
}

interface Stroke {
  readonly color: RGB;
  readonly width: number;
  readonly points: CGPoint[];
}

const BLACK: RGB = { r: 0, g: 0, b: 0 };

// The inbound value surface for the four overridden selectors (module doc) — `drawRect:`'s CGRect
// needs no conversion (already RAW) but must still be listed, since a marshalled callback's every
// arriving selector must resolve through it (marshal.ts's `driver`); the three NSEvent args are the
// OBJ kind that turns a raw handle into a real, borrowed `NSEvent` wrapper.
const CANVAS_MARSHAL = __methodMarshal({
  'drawRect:': { args: [RAW], ret: RET_RAW },
  'mouseDown:': { args: [OBJ], ret: RET_RAW },
  'mouseDragged:': { args: [OBJ], ret: RET_RAW },
  'mouseUp:': { args: [OBJ], ret: RET_RAW },
});

class DrawingCanvasView extends NSView {
  private strokes: Stroke[] = [];
  private currentColor: RGB = BLACK;
  private currentWidth = 2.0;
  private inProgress: Stroke | null = null;

  constructor() {
    super(__allocSubclass(DrawingCanvasView));
    __bindSubclass(this, CANVAS_MARSHAL);
  }

  // Written by the toolbar controller (spec §8) — applies to strokes started afterwards only;
  // never touches an existing stroke.
  setCurrentColor(r: number, g: number, b: number): void {
    this.currentColor = { r, g, b };
  }

  setCurrentWidth(w: number): void {
    this.currentWidth = w;
  }

  // Clear (spec §8.3) — empties the collection, cancels any in-progress stroke, redraws. A safe
  // no-op when already empty.
  clearStrokes(): void {
    this.strokes = [];
    this.inProgress = null;
    this.setNeedsDisplay_(true);
  }

  private localPoint(event: NSEvent): CGPoint {
    return this.convertPoint_fromView_(event.locationInWindow(), NIL_VIEW);
  }

  // drawRect: (spec §6) — repaints the COMPLETE stroke set on every call, oldest first, ignoring
  // the dirty rectangle. Boundary — no current graphics context: draw nothing.
  drawRect_(_dirtyRect: CGRect): void {
    const ctx = NSGraphicsContext.currentContext() as NSGraphicsContext | null;
    if (!ctx) return;
    const cg = ctx.CGContext();
    for (const stroke of this.strokes) this.paint(cg, stroke);
  }

  // The rendering rule (spec §7.3): one begin/stroke pair per stroke (colour/width are graphics
  // STATE, not per-subpath attributes, so strokes cannot batch into one path). A one-point stroke
  // adds a coincident second point so the round cap paints a disc — the same no-special-case trick
  // every reference implementation uses.
  private paint(cg: bigint, stroke: Stroke): void {
    if (stroke.points.length === 0) return; // defensive guard; unreachable (every stroke is born with its down point).
    CGContextSetRGBStrokeColor(cg, stroke.color.r, stroke.color.g, stroke.color.b, 1.0);
    CGContextSetLineWidth(cg, stroke.width);
    CGContextSetLineCap(cg, CGLineCap.kCGLineCapRound);
    CGContextSetLineJoin(cg, CGLineJoin.kCGLineJoinRound);
    CGContextBeginPath(cg);
    const [first, ...rest] = stroke.points;
    CGContextMoveToPoint(cg, first.x, first.y);
    if (rest.length === 0) {
      CGContextAddLineToPoint(cg, first.x, first.y);
    } else {
      for (const p of rest) CGContextAddLineToPoint(cg, p.x, p.y);
    }
    CGContextStrokePath(cg);
  }

  // The drawing gesture (spec §7.2) — mouse-down begins a stroke, capturing colour+width; drag
  // extends it (boundary: only while in-progress — a drag with no preceding down-in-canvas appends
  // nothing); mouse-up merely ends extension, the release point is NOT appended.
  mouseDown_(event: NSEvent): void {
    const stroke: Stroke = {
      color: this.currentColor,
      width: this.currentWidth,
      points: [this.localPoint(event)],
    };
    this.strokes.push(stroke);
    this.inProgress = stroke;
    this.setNeedsDisplay_(true);
  }

  mouseDragged_(event: NSEvent): void {
    if (!this.inProgress) return;
    this.inProgress.points.push(this.localPoint(event));
    this.setNeedsDisplay_(true);
  }

  mouseUp_(_event: NSEvent): void {
    this.inProgress = null;
    this.setNeedsDisplay_(true);
  }
}

// ── The toolbar controller (spec §8) — one handler object, four actions: the two buttons, the
// slider, and the shared colour panel (rewired on every Color… activation). Holds plain references
// to the canvas + slider (the note-editor `NoteController` pattern) rather than reading state off
// an ignored RAW sender. ─────────────────────────────────────────────────────────────────────────
const NSOBJECT_CLASS = __class('NSObject');
const TOOLBAR_METHODS: readonly SubclassOverride[] = [
  ['openColor:', 'v@:@'],
  ['widthChanged:', 'v@:@'],
  ['clearCanvas:', 'v@:@'],
  ['colorChanged:', 'v@:@'],
];

class ToolbarController extends NSObject {
  private readonly canvas: DrawingCanvasView;
  private readonly slider: NSSlider;

  constructor(canvas: DrawingCanvasView, slider: NSSlider) {
    super(__subclassAlloc(ToolbarController, NSOBJECT_CLASS, TOOLBAR_METHODS));
    __bindSubclass(this);
    this.canvas = canvas;
    this.slider = slider;
  }

  // Color… (spec §8.1) — (re)wire the shared panel on EVERY activation, continuous.
  openColor_(_sender: bigint): void {
    const panel = NSColorPanel.sharedColorPanel();
    panel.setTarget_(this);
    panel.setAction_('colorChanged:');
    panel.setContinuous_(true);
    panel.makeKeyAndOrderFront_(this);
  }

  // The panel's action (spec §8.1): nil-colour / normalization-failure boundaries both leave the
  // current colour unchanged.
  colorChanged_(_sender: bigint): void {
    const panel = NSColorPanel.sharedColorPanel();
    const color = panel.color() as NSColor | null;
    if (!color) return;
    const converted = color.colorUsingColorSpace_(NSColorSpace.deviceRGBColorSpace()) as NSColor | null;
    if (!converted) return;
    this.canvas.setCurrentColor(converted.redComponent(), converted.greenComponent(), converted.blueComponent());
  }

  // The slider's action (spec §8.2) — reads its own current double value.
  widthChanged_(_sender: bigint): void {
    this.canvas.setCurrentWidth(this.slider.doubleValue());
  }

  clearCanvas_(_sender: bigint): void {
    this.canvas.clearStrokes();
  }
}

// ── Assemble the window (spec §4/§5) ─────────────────────────────────────────────────────────
const WINDOW_W = 640;
const WINDOW_H = 480;
const TOOLBAR_H = 36;
const CANVAS_H = WINDOW_H - TOOLBAR_H;
const TOOLBAR_Y = CANVAS_H + 4; // content-view y 444..480

const app = NSApplication.sharedApplication();
app.setActivationPolicy_(NSApplicationActivationPolicy.NSApplicationActivationPolicyRegular);
installAppMenu(app, 'Drawing Canvas');

const window = __alloc(NSWindow).initWithContentRect_styleMask_backing_defer_(
  rect(0, 0, WINDOW_W, WINDOW_H),
  NSWindowStyleMask.NSWindowStyleMaskTitled |
    NSWindowStyleMask.NSWindowStyleMaskClosable |
    NSWindowStyleMask.NSWindowStyleMaskMiniaturizable |
    NSWindowStyleMask.NSWindowStyleMaskResizable,
  NSBackingStoreType.NSBackingStoreBuffered,
  false,
);
window.setTitle_(jsString('Drawing Canvas'));
window.center();
window.setMinSize_({ width: 400, height: 300 });

const content = window.contentView();

// Canvas (spec §5.2): full width, everything below the toolbar band, absorbs all resize.
const canvas = new DrawingCanvasView();
canvas.setFrame_(rect(0, 0, WINDOW_W, CANVAS_H));
canvas.setAutoresizingMask_(
  NSAutoresizingMaskOptions.NSViewWidthSizable | NSAutoresizingMaskOptions.NSViewHeightSizable,
);
content.addSubview_(canvas);

// Toolbar band (spec §5.1): all three controls pinned to the top edge (min-Y-margin); Clear also
// pinned to the right edge (min-X-margin) so it slides with the window's right side.
const colorButton = __alloc(NSButton).initWithFrame_(rect(12, TOOLBAR_Y + 4, 96, 28));
colorButton.setTitle_(jsString('Color…'));
colorButton.setBezelStyle_(NSBezelStyle.NSBezelStyleRounded);
colorButton.setAutoresizingMask_(NSAutoresizingMaskOptions.NSViewMinYMargin);
content.addSubview_(colorButton);

const widthSlider = __alloc(NSSlider).initWithFrame_(rect(120, TOOLBAR_Y + 6, 200, 24));
widthSlider.setMinValue_(1);
widthSlider.setMaxValue_(20);
widthSlider.setDoubleValue_(2);
widthSlider.setContinuous_(true);
widthSlider.setAutoresizingMask_(NSAutoresizingMaskOptions.NSViewMinYMargin);
content.addSubview_(widthSlider);

const clearButton = __alloc(NSButton).initWithFrame_(rect(WINDOW_W - 12 - 76, TOOLBAR_Y + 4, 76, 28));
clearButton.setTitle_(jsString('Clear'));
clearButton.setBezelStyle_(NSBezelStyle.NSBezelStyleRounded);
clearButton.setAutoresizingMask_(
  NSAutoresizingMaskOptions.NSViewMinYMargin | NSAutoresizingMaskOptions.NSViewMinXMargin,
);
content.addSubview_(clearButton);

const controller = new ToolbarController(canvas, widthSlider);
colorButton.setTarget_(controller);
colorButton.setAction_('openColor:');
widthSlider.setTarget_(controller);
widthSlider.setAction_('widthChanged:');
clearButton.setTarget_(controller);
clearButton.setAction_('clearCanvas:');

// AW_DC_SMOKE=1 (the host construction pre-flight, matching the rest of the ladder's AW_*_SMOKE
// convention): every FFI crossing above must still succeed, but skip actually showing the window.
if (!process.env.AW_DC_SMOKE) {
  window.makeKeyAndOrderFront_(app);
  app.activate();
  console.log('Drawing Canvas opened. Drag to draw; adjust colour/width via the toolbar. Quit with Cmd-Q.');
}
