# Drawing Canvas

*Reverse-generated (LLM) from the four existing VM-verified implementations (racket, chez, gerbil, sbcl) on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052): this prose is the target-independent source of truth; the four implementations are its projections.*

## 1. Structural facts

- **app-kind:** `gui-app` (the bundled, windowed Cocoa app — `platforms/macos/app-kinds/gui-app/`)
- **display name:** Drawing Canvas *(the bundlers read this from the first H1 above)*
- **complexity:** 5/7 (the portfolio's fifth rung — dynamic ObjC subclass with `drawRect:` + mouse events, CoreGraphics drawing, NSColorPanel)
- **API frameworks:** AppKit (window, buttons, slider, the shared `NSColorPanel`, colours and colour spaces, the graphics-context bridge, and the `NSView` base class the canvas subclasses), CoreGraphics (direct C calls for path construction and stroking), Foundation (strings, geometry value types)
- **pattern-kinds exercised:** `target-action` · `parent-child` (view containment) · subclass-override callback surface (the framework invokes app-registered `drawRect:`/mouse overrides on its own schedule) · continuous-control target-action (the slider and the colour panel) · object-lifecycle · property-configuration · class-method-factory (singletons) · value-type-geometry · option-set bitmask · menu object-graph construction · run-loop entry
- **native units:** none beyond the platform frameworks (all drawing is direct CoreGraphics C calls; the callback machinery each target uses to host the NSView subclass is target-runtime plumbing, not app code)

## 2. Purpose & intent

A freehand drawing app — the portfolio's custom-view showcase. A canvas occupying most of the window is an app-defined `NSView` subclass: AppKit calls *into* the app for drawing (`drawRect:`) and for the mouse gesture (`mouseDown:` / `mouseDragged:` / `mouseUp:`), and the app renders every stroke itself through direct CoreGraphics calls. A top toolbar band holds a **Color…** button (opens the shared system colour panel, wired continuous), a **line-width slider** (1–20, continuous), and a **Clear** button.

The load-bearing behaviour is the **capture-at-mouse-down stroke model**: each stroke freezes the current colour and width at the moment it begins, so tool changes apply only to strokes started afterwards — an existing stroke is never repainted in a new colour or width, and a tool change mid-drag does not affect the stroke in progress. There is no document, no persistence, no undo, and no eraser; Clear is the only removal and it is total.

## 3. Application kind & lifecycle

A regular, dock-visible, single-window AppKit application (`gui-app`). Launch is deterministic; the coarse order below is common to all implementations (finer construction interleaving is not contractual):

1. **Acquire the application singleton** — the process-wide shared `NSApplication`.
2. **Become a regular app** — activation policy *Regular* (`NSApplicationActivationPolicyRegular` = 0): Dock icon and menu bar.
3. **Install the application menu** (§9).
4. **Build the window** (§4) **and its content** (§5): the canvas view (an instance of the app's `NSView` subclass, §6) filling everything below a 36-point toolbar band, and the three toolbar controls; **wire the target-action handlers** (§8) — all four actions route to one app-side handler object.
5. **Present and focus** — make the window key and order it front; activate the application ignoring other apps so it is frontmost on launch.
6. **Announce** — write a one-line launch diagnostic to standard output. The line **begins with the text `Drawing Canvas`**; the remainder (running/opened phrasing, usage guidance) is implementation-specific and not part of the contract.
7. **Run** — enter the AppKit run loop; the process blocks servicing events.
8. **Terminate** — via the **Quit** command (Command-Q → `-[NSApplication terminate:]`), the `gui-app` app-kind's termination model (`termination "ns-application-terminate"`). See §9.

   **Termination is Quit-driven, not close-driven.** No implementation installs an application delegate or opts into terminate-after-last-window-closed, and the app-kind does not require it; on stock AppKit, closing the window hides it and the process keeps running (confirmed on all four impls — `run-results.md` scenario 17, the seventh portfolio app to confirm; ADR-0010 D4). Three implementations' printed guidance ("Close window or Ctrl+C to exit") suggests otherwise; that text is guidance prose, not behaviour.

No timers, no background threads, no app-driven animation: every redraw is a response to a user gesture (a mouse event or a toolbar action requesting `setNeedsDisplay:`).

## 4. Window

A single top-level window created through the designated initializer `initWithContentRect:styleMask:backing:defer:`:

- **Content rectangle:** origin `(0, 0)`, size **640 × 480** points (recentered before display, so the origin is irrelevant).
- **Style mask:** the bitwise-OR of **Titled** (1) · **Closable** (2) · **Miniaturizable** (4) · **Resizable** (8). Resizable is deliberate: the canvas and toolbar track resize through autoresizing masks (§5).
- **Backing store:** *Buffered* (`NSBackingStoreBuffered` = 2). **Defer:** *false*.
- **Title:** the literal string **`Drawing Canvas`** — invariant across implementations and never changed after launch.
- **Minimum content size:** **400 × 300** points — the window cannot be shrunk below this (so the canvas region never drops below 400 × 264, derived).
- **Position:** recentered via the window's standard `center` behaviour before display.

## 5. Content layout

Two non-overlapping regions fill the 640 × 480 content view: a **36-point toolbar band** across the top and the **canvas** filling everything below it. All views are direct subviews of the window's content view and track resize through autoresizing masks (no Auto Layout, and — unlike the stack-view apps — no container view for the toolbar: the three controls sit directly in the band).

### 5.1 Toolbar band

Three controls occupy the top band (content-view y **444–480**, bottom-left-origin coordinates), each pinned to the top edge on resize (min-Y-margin autoresizing):

- **The colour button** — a push button, frame `(12, 448, 96, 28)`: title **`Color…`** (the trailing character is U+2026), rounded bezel (`NSBezelStyleRounded` = 1). Left-anchored (12-point inset); 4-point margins above and below within the band.
- **The width slider** — an `NSSlider`, frame `(120, 450, 200, 24)`: **minimum 1.0, maximum 20.0, initial value 2.0** (matching the initial stroke width, §8.2), **continuous** (`setContinuous:` true — the action fires while the knob is dragged, not only on release **(continuous delivery to confirm in-VM)**). Left-anchored, fixed 200-point width; vertically centred in the band (6-point margins).
- **The clear button** — a push button, frame `(552, 448, 76, 28)`: title **`Clear`**, rounded bezel. **Right-anchored**: its autoresizing adds min-X-margin, so it slides with the right edge, keeping a 12-point right inset symmetric with the colour button's left inset.

*The intent is a top-pinned tool strip — left-cluster (colour, width) and a right-anchored Clear — clear of the drawing surface; re-implement the anchoring intent, not the literal coordinates.*

### 5.2 Canvas placement

The canvas view has frame `(0, 0, 640, 444)` — the full content width and everything below the toolbar band — with **width-sizable + height-sizable** autoresizing, so it absorbs all window resize and the toolbar band stays 36 points deep.

## 6. The canvas view

The canvas is an instance of an **app-defined subclass of `NSView`**, registered with the Objective-C runtime under an app-chosen class name (the realized names vary; the class name is not observable contract). It overrides exactly four selectors:

- **`drawRect:`** — repaints the **complete stroke set** on every call, ignoring the dirty rectangle (no implementation consults it; in one the callback mechanism does not even deliver it). The draw pass obtains the current `NSGraphicsContext` and its `CGContext`; **boundary — if no current graphics context is available, the pass silently draws nothing** (a defensive guard present in every implementation).
- **`mouseDown:` / `mouseDragged:` / `mouseUp:`** — the drawing gesture (§7.2).

No other `NSView` behaviour is overridden. In particular the view paints **no background of its own** — `drawRect:` strokes paths and nothing else — so an empty canvas shows the plain window background (the launch state; VM notes for one implementation record the empty canvas rendering correctly).

## 7. Stroke model & drawing gestures

### 7.1 Data model

The application state is: a **stroke collection**, a **current colour** (three numeric RGB components — extracted numbers, not a colour object; initially **black**, 0/0/0), a **current width** (initially **2.0**), and an **in-progress flag**. A **stroke** carries:

- its **colour** — the three RGB components frozen at mouse-down (opacity is not stored; it is fixed at 1.0 at render time);
- its **width** — frozen at mouse-down;
- its **ordered point list** — positions in the canvas view's own coordinate space (unflipped, bottom-left origin), in chronological order at render time.

The collection renders **oldest-first**, so newer strokes paint over older ones. The in-progress stroke is a member of the collection from the moment of mouse-down and **renders live** as it grows during the drag; mouse-up merely ends extension (clears the in-progress flag) — no data transformation occurs at commit, and a committed stroke is never mutated again.

### 7.2 The drawing gesture

Each mouse event's location is converted from window coordinates to view-local coordinates (`locationInWindow`, then `convertPoint:fromView:` with a nil source view).

- **Mouse-down** — begin a new stroke: capture the current colour and width, seed the point list with the down point, set the in-progress flag, request a redraw.
- **Mouse-drag** — **only if the in-progress flag is set**, append the point and request a redraw. **Boundary:** a drag with no preceding mouse-down in the canvas (e.g. a drag that began on a toolbar control, or after Clear reset the flag) appends nothing.
- **Mouse-up** — clear the in-progress flag and request a redraw. **The release location is not appended**: a stroke's points are exactly the down point plus the drag points.
- **Boundary — click without drag:** the stroke has a single point and renders as a **filled disc of diameter = the stroke's width, centred on the click** (the rendering rule §7.3 adds a coincident second point so the round cap paints a dot; VM notes for two implementations observed the dot).
- **Boundary — tool change mid-drag:** the in-progress stroke is unaffected — its colour and width were frozen at mouse-down. *(With a single pointer this facet is not independently drivable — adjusting a tool requires releasing the drag; the structurally guaranteed observable is that no existing stroke ever changes appearance.)*
- Points are stored as absolute view coordinates and repainted verbatim; the visual anchoring of existing strokes when the window (and therefore the canvas) is resized is not asserted **(unknown — to confirm in-VM)**.

### 7.3 Rendering rule

For each stroke, oldest first (skipping a stroke with an empty point list — a defensive guard in every implementation, unreachable in normal operation since every stroke is born with its down point):

1. Set the RGB stroke colour to the stroke's components with **alpha 1.0**; set the stroke's line width; set **round line cap** and **round line join**.
2. Begin a path; move to the first point; if the stroke has **one point**, add a line to that same point (the degenerate segment the round cap renders as a disc — the recorded rationale in every implementation: a bare click yields a visible dot without a special-case branch); otherwise add a line to each subsequent point.
3. Stroke the path.

One begin/stroke pair per stroke — colour and width are graphics *state*, not per-subpath attributes, so strokes cannot be batched into one path. Round cap + join are also the recorded rationale for smooth (non-mitred) direction changes within a drag.

## 8. Tool state & the toolbar actions

All three controls and the colour panel send their actions to **one** app-side handler object that outlives the run loop (controls hold their targets weakly); the four action selectors — `openColor:`, `widthChanged:`, `clearCanvas:`, `colorChanged:` — are identical in every implementation (an internal convention recorded as shared fact, not testable contract).

### 8.1 Colour & the colour-panel flow

The **current colour** changes only through the panel's action; nothing else writes it.

**Opening.** Activating **Color…**: obtain the **shared `NSColorPanel`** (class accessor `sharedColorPanel`); **(re)wire it on every activation** — `setTarget:` the handler, `setAction:` the colour-changed action, **`setContinuous:` true** so the action fires repeatedly while the user drags through the panel's colour surface **(continuous delivery to confirm in-VM)**; show it with `makeKeyAndOrderFront:`.

**Reacting.** The panel sends the colour-changed action with itself as sender. The handler:

1. Reads the panel's `color`. **Boundary — nil colour:** nothing happens.
2. **Normalizes to device RGB** via `colorUsingColorSpace:` with `NSColorSpace deviceRGBColorSpace`. *Why (the identical recorded rationale in all four implementations):* component extraction is defined only for RGB-family colours; normalizing first makes it always safe.
3. **Boundary — conversion failure:** if normalization returns nil, the previous colour is kept unchanged (consistent across all four implementations).
4. On success, extracts `redComponent` / `greenComponent` / `blueComponent` and stores them as the current colour — used by strokes started afterwards. **No existing stroke changes.**

**Boundary — handler failure:** two implementations additionally guard the whole handler, writing a `colorChanged:`-prefixed diagnostic to standard error and continuing; the other two rely on the nil-guards alone. Error-swallowing-with-log is **not** an invariant; the invariant is that a failed colour change causes no crash and no state change beyond the above.

**Boundary — opening alone:** no app code runs when the panel merely opens or closes; whether the platform fires an immediate action on wiring/opening is not app behaviour **(unknown — to confirm in-VM)**. Dismissing the panel picks nothing: colour state is unchanged. The panel is non-modal — drawing continues while it is open, each stroke using the colour current at its own mouse-down.

### 8.2 Width

The slider's action reads the **slider's current double value** and stores it as the current width. Range 1.0–20.0, initial 2.0 — the slider's initial position and the initial stroke width agree at launch. Width applies to strokes started afterwards only.

### 8.3 Clear

The Clear action **empties the stroke collection, cancels any in-progress stroke state** (the in-progress flag is reset, so a gesture cannot straddle a clear), and requests a redraw — returning the canvas to the blank launch state. **Boundary — Clear on an already-empty canvas:** a safe no-op. Cleared strokes are unrecoverable (no undo).

## 9. Application menu

- The menu bar carries one application menu; its bold app-name slot comes from the bundle's `CFBundleName` when launched as a `.app` bundle.
- The mandated behaviour is a **Quit** command: title **`Quit Drawing Canvas`** (`"Quit " + <display name>`), **key equivalent Command-Q**, action **`-[NSApplication terminate:]`** — the app-kind's termination model. *(The literal item is witnessed inline in one implementation; the other three install their target's standard application menu, called with the display name — the helper's realization lives outside this app's sources.)*
- A conforming implementation may include the other conventional first-menu items (About, Hide, …); only *Quit (Command-Q) terminates the app* is asserted.

## 10. API surface exercised

Selectors witnessed in **every** implementation (or named by the app-kind contract) — platform truths, projection-free:

| Class | Selector | Kind | Role |
|-------|----------|------|------|
| NSApplication | `sharedApplication` | class accessor (singleton) | obtain the app instance |
| NSApplication | `setActivationPolicy:` | property setter | become a Regular app |
| NSApplication | `activateIgnoringOtherApps:` | instance method | foreground on launch |
| NSApplication | `run` | instance method | enter the run loop |
| NSApplication | `terminate:` | instance method | quit (app-kind termination; the Quit item's action — inline in one implementation, via the standard-menu helper in the other three) |
| NSWindow | `initWithContentRect:styleMask:backing:defer:` | designated initializer | create the window |
| NSWindow | `setTitle:` · `center` · `setMinSize:` · `contentView` · `makeKeyAndOrderFront:` | setters/methods/getter | title, position, size floor, composition root, show+focus |
| NSView | `addSubview:` · `setAutoresizingMask:` · `setNeedsDisplay:` · `convertPoint:fromView:` | methods/setters | containment; resize tracking; redraw requests; event-point conversion |
| NSView *(overridden by the canvas subclass)* | `drawRect:` · `mouseDown:` · `mouseDragged:` · `mouseUp:` | overridden instance methods | the drawing surface (§6, §7) |
| NSEvent | `locationInWindow` | property getter | gesture position (window coordinates) |
| NSGraphicsContext | `currentContext` · `CGContext` | class accessor / getter | reach the CoreGraphics context inside `drawRect:` |
| NSButton | `setTitle:` · `setBezelStyle:` | property setters | the two buttons |
| NSSlider | `setMinValue:` · `setMaxValue:` · `setDoubleValue:` · `setContinuous:` · `doubleValue` | setters/getter | the width control |
| NSControl | `setTarget:` · `setAction:` | property setters | wire the three toolbar actions |
| NSColorPanel | `sharedColorPanel` | class accessor (singleton) | the shared panel |
| NSColorPanel | `setTarget:` · `setAction:` · `setContinuous:` · `makeKeyAndOrderFront:` · `color` | setters/method/getter | continuous wiring; show; read the picked colour |
| NSColor | `colorUsingColorSpace:` · `redComponent` · `greenComponent` · `blueComponent` | method/getters | device-RGB normalization and component extraction (§8.1) |
| NSColorSpace | `deviceRGBColorSpace` | class factory | the normalization target space |
| CoreGraphics (C) | `CGContextSetRGBStrokeColor` · `CGContextSetLineWidth` · `CGContextSetLineCap` · `CGContextSetLineJoin` · `CGContextBeginPath` · `CGContextMoveToPoint` · `CGContextAddLineToPoint` · `CGContextStrokePath` | C functions | the rendering rule (§7.3) |

**Abstract operations whose realizing selector varies per implementation** (this spec asserts the operation, never one impl's selector): canvas-subclass definition and registration (a dynamic-subclass runtime facility vs. a class-definition form vs. a CLOS-backed macro pair); canvas instantiation + framing (raw `alloc`/`initWithFrame:` vs. plain instantiation + `setFrame:`); control instantiation + framing (`initWithFrame:` vs. bare init + `setFrame:`); handler-object mechanism (a generic multi-selector delegate object vs. a synthesized `NSObject` subclass instance); main-menu installation (a shared standard-menu helper vs. inline `NSMenu`/`NSMenuItem` object-graph construction).

**10.1 Enum / constant values used in every implementation:**

| Constant | Value | Used for |
|----------|-------|----------|
| `NSApplicationActivationPolicyRegular` | 0 | activation policy |
| `NSWindowStyleMaskTitled` | 1 | window style |
| `NSWindowStyleMaskClosable` | 2 | window style |
| `NSWindowStyleMaskMiniaturizable` | 4 | window style |
| `NSWindowStyleMaskResizable` | 8 | window style |
| `NSBackingStoreBuffered` | 2 | window backing |
| `NSBezelStyleRounded` | 1 | button bezels |
| `NSViewWidthSizable` | 2 | autoresizing (canvas) |
| `NSViewHeightSizable` | 16 | autoresizing (canvas) |
| `NSViewMinYMargin` | 8 | autoresizing (all three controls: pin to top) |
| `NSViewMinXMargin` | 1 | autoresizing (Clear: pin to right edge) |
| `kCGLineCapRound` | 1 | stroke rendering |
| `kCGLineJoinRound` | 1 | stroke rendering |

## 11. API-usage patterns

- **Subclass-override callback surface (the app's defining pattern):** the framework calls *into* the app, on its own schedule, for the view's lifetime — `drawRect:` whenever the platform decides to repaint, the mouse selectors as events arrive. App-side state read and mutated from these callbacks is the whole data flow; all activity is on the main thread.
- **`target-action`, four wirings:** the colour button → open-panel (build time); the slider → width-changed (build time, continuous); the Clear button → clear (build time); the shared colour panel → colour-changed (runtime, rewired on every button activation, continuous). One handler object receives all four (controls hold targets weakly; every implementation anchors the handler in process-lifetime app state).
- **Continuous controls:** `setContinuous:` true on both the slider and the panel converts target-action from discrete clicks into a stream of updates during dragging.
- **`parent-child` (view containment):** canvas and the three controls parented into the window's content view; layout maintained by autoresizing masks alone.
- **State-holding UI with capture semantics:** tool state (colour, width) is application state sampled *into* each stroke at gesture start — the inverse of the re-application pattern elsewhere in the portfolio: here past output must *never* track later state changes.
- **Immediate-mode repaint over retained scene:** the view retains no display list of the platform's; the app's stroke collection *is* the model, and every repaint re-renders it in full through CoreGraphics path calls (`begin path → move → add lines → stroke`, one pair per stroke).
- **Redraw-request loop:** every mutation (gesture point, clear) is followed by `setNeedsDisplay:`, deferring actual painting to the framework's next display pass.
- **Class-method factories / singletons:** `sharedApplication`, `sharedColorPanel`, `deviceRGBColorSpace`.
- **Object lifecycle, property configuration, value-type geometry, option-set bitmask, menu object-graph construction, run-loop entry:** as in the app-kind and the earlier portfolio specs.

## 12. Observable outcomes & accessibility

**Visual outcomes:**
- A centered, resizable 640 × 480 window titled `Drawing Canvas`; a top toolbar band with `Color…` (left), a horizontal slider, and `Clear` (right); below it a blank drawing surface showing the plain window background.
- Dragging on the canvas paints a smooth, round-capped, round-joined stroke that renders live during the drag, in the current colour and width **(to confirm in-VM — stroke content is pixel-level, not OCR/AX-addressable; VM notes for all four implementations record drag strokes rendering)**.
- A bare click paints a round dot of diameter equal to the current width **(to confirm in-VM; observed in two implementations' VM notes)**.
- Moving the slider thickens subsequent strokes; picking in the colour panel recolours subsequent strokes; existing strokes never change **(to confirm in-VM; one implementation's VM notes observed per-stroke width preserved and prior strokes keeping their colour)**.
- Clear returns the canvas to blank **(to confirm in-VM; observed in two implementations' VM notes)**.
- Native macOS control appearance for the toolbar; the canvas has no chrome of its own.

**Accessibility expectations** *(in-VM confirmable)*:
- The window is exposed with accessibility title `Drawing Canvas`.
- Two button elements are exposed with titles `Color…` and `Clear`; a slider element is exposed with value 2 in range 1–20 (initially).
- **The canvas itself exposes no content accessibility structure** — no implementation configures accessibility on the view, and strokes are pixels, not elements **(to confirm in-VM)**. Verification of drawing therefore requires screenshots, not the AX tree.
- The shared colour panel appears as an additional window of the app (platform-supplied chrome) **(to confirm in-VM)**.
- The application menu's Quit item is reachable and carries the Command-Q key equivalent.

## 13. Not included

- **No persistence, no undo/redo, no save/export** — strokes live in process memory only and are lost on quit.
- **No eraser, no stroke selection, no per-stroke deletion** — Clear-all is the only removal.
- **No canvas background fill** — the view paints strokes only (an empty canvas is the window background; no fill call exists in any implementation's draw path).
- **No opacity control** — stroke alpha is fixed at 1.0.
- **No per-gesture diagnostics** — the single launch line is the only standard-output the app writes; strokes, colour changes, width changes, and clears log nothing, so runtime verification is visual-only.
- **No keyboard interaction** beyond menu key equivalents; no text surface anywhere.
- **No accessibility configuration on the canvas.**
- **No dirty-rect optimisation** — every repaint renders the full stroke set.
- **No modality** — the colour panel is an independent window; drawing continues while it is open.
- **No app delegate, timers, or background threads; no close-to-quit** (§3.8).
- **No window retitling** — the title stays `Drawing Canvas`.

## 14. Behavioural exemplar (acceptance / forward-generation input)

Observable assertions against a live-VM run, each mapped to a scenario-runner verb (enumeration only — not scenario code). Assertions state the *rule* (stable substrings/invariants), so the suite verifies any conforming implementation.

**No fixtures:** the app ships and needs no documents or network. **Driver guidance** (from the implementations' VM notes): strokes require a *held-button drag* — a bare pointer move between down and up releases the button and yields only a down-point dot; the continuous colour-panel action likewise wants a drag; target controls from accessibility-snapshot coordinates, not screenshot pixels. The closed verb set has **no mouse-drag verb and no pixel-comparison verb**, so stroke-content assertions below are spec prose pending a drag/pixel-capable driver.

- **Process is running after launch.** → `expect-running-app`
- **Launch diagnostic is emitted.** Stdout contains a line beginning `Drawing Canvas`. → `wait-for-log "Drawing Canvas"` / `expect-log "Drawing Canvas"`
- **Window title is correct.** The frontmost window's accessibility title is `Drawing Canvas`. → `expect-ax` window AXTitle and/or `expect-ocr "Drawing Canvas"`
- **Toolbar controls present.** A button titled `Color…`, a button titled `Clear`, and a slider exist. → `expect-ax` / `expect-ocr "Color"` + `expect-ocr "Clear"`
- **Slider initial state.** The slider's value is 2 within range 1–20. → `expect-ax` slider value
- **Launch canvas is blank.** The region below the toolbar shows only window background *(to confirm in-VM; pixel-level — no runnable verb)*.
- **Canvas exposes no content elements.** No static-text/child element exists for the drawing surface. → `expect-no-ax` *(to confirm in-VM)*
- **Bare click paints a dot.** `click-at` a canvas point; a round dot of the current width and colour appears at it *(to confirm in-VM; pixel-level — no runnable verb for the assertion)*.
- **Drag paints a live stroke.** A held-button drag leaves a connected, smooth stroke, visible while still dragging *(to confirm in-VM; needs a drag gesture and pixel comparison — outside the closed verb set)*.
- **Width applies to subsequent strokes only.** After moving the slider up, a new stroke is thicker; existing strokes are unchanged *(to confirm in-VM; pixel-level)*.
- **Colour panel opens.** Activating `Color…` brings up the shared colour panel as an additional window. → `click-at` the colour button, then `expect-ax` for a second window *(panel chrome is platform-supplied — to confirm in-VM)*
- **Live recolour of subsequent strokes — the key behaviour.** After picking a colour (drag in the panel), a new stroke uses it; **previously drawn strokes keep their original colour** *(to confirm in-VM; pixel-level; one implementation's VM notes observed exactly this)*.
- **Boundary — dismissing the panel picks nothing.** Closing the panel without a pick leaves stroke colour behaviour unchanged *(to confirm in-VM; pixel-level)*.
- **Clear empties the canvas.** `click-at` the Clear button; the canvas returns to blank and the app keeps running. → `click-at`, then `expect-running-app` *(blankness itself is pixel-level — to confirm in-VM)*
- **Boundary — Clear on an empty canvas is a safe no-op.** → `click-at` Clear at launch, `expect-running-app`
- **Boundary — a drag begun on a toolbar control draws nothing.** Press on a control and drag across the canvas: no stroke appears *(to confirm in-VM; pixel-level)*.
- **Boundary — typing draws nothing.** → `type "x"`, `expect-running-app` (canvas unchanged — pixel-level part to confirm in-VM)
- **Quit menu terminates the app.** Sending Command-Q ends the process. → `chord cmd q`, then `expect-running-app` is false
- **(To confirm in-VM) Close-button behaviour.** Activating the close control hides the window; per §3.8 the process is expected to keep running (no close-to-quit opt-in). A scenario should record the *actual* observed behaviour. → `click-at` close button, then `expect-running-app`
