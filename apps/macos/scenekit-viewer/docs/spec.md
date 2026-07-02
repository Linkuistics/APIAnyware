# SceneKit Viewer

*Reverse-generated (LLM) from the four existing VM-verified implementations (racket, chez,
gerbil, sbcl) on 2026-07-02, then human-validated by git review (ADR-0050, ADR-0052): this
prose is the target-independent source of truth; the four implementations are its
projections.*

## 1. Structural facts

- **app-kind:** `gui-app` (the bundled, windowed Cocoa app — `platforms/macos/app-kinds/gui-app/`)
- **display name:** SceneKit Viewer *(the bundlers read this from the first H1 above)*
- **complexity:** 6/7 (the portfolio's sixth rung — SceneKit 3D rendering, SCNAction
  animation, scene-graph construction)
- **API frameworks:** SceneKit (`SCNView`, `SCNScene`, `SCNNode`, `SCNBox`, `SCNSphere`,
  `SCNTorus`, `SCNCylinder`, `SCNGeometry`, `SCNMaterial`, `SCNMaterialProperty`,
  `SCNAction`), AppKit (window, pop-up button, button, stack view, colours, colour spaces,
  the shared `NSColorPanel`), Foundation (strings, geometry value types)
- **pattern-kinds exercised:** `target-action` · `parent-child` (view containment and
  scene-graph node containment) · object-lifecycle · property-configuration ·
  class-method-factory (singletons; geometry/action/colour factories) · chained-accessor
  traversal (node → geometry → material → property) · continuous-control target-action
  (the shared colour panel) · protocol-conformed member access · value-type-geometry ·
  option-set bitmask · menu object-graph construction · run-loop entry
- **native units:** none beyond the platform frameworks (every call is plain ObjC surface
  of AppKit/SceneKit/Foundation; no app-specific native code, no custom drawing)

## 2. Purpose & intent

An interactive 3D scene viewer: a lit, continuously spinning geometry renders in a
SceneKit viewport under a dark-grey backdrop. A toolbar pop-up swaps the displayed
geometry live between four shapes (cube / sphere / torus / cylinder), and a colour button
opens the shared system colour panel — wired in continuous mode — to recolour the
geometry's material as the user picks. The chosen colour is application state: it is
re-applied after every geometry swap (SceneKit gives each new geometry a fresh default
material), so **the colour survives shape changes** — the app's load-bearing behaviour.
Camera interaction (orbit, zoom) is delegated entirely to the scene view's built-in camera
controller; the app creates no camera, no lights, and positions nothing. There is no
document, no persistence, and no custom drawing.

## 3. Application kind & lifecycle

A regular, dock-visible, single-window AppKit application (`gui-app`). Launch is
deterministic; the coarse order below is common to all implementations (finer interleaving
of the two content regions' construction is not contractual):

1. **Acquire the application singleton** — the process-wide shared `NSApplication`.
2. **Become a regular app** — activation policy *Regular*
   (`NSApplicationActivationPolicyRegular` = 0): Dock icon and menu bar.
3. **Install the application menu** (§8).
4. **Build the window** (§4) **and its two content regions** (§5): the toolbar strip and
   the scene view; **construct the scene graph** (§6: scene → root node → geometry node
   carrying the initial cube), assign the scene to the view, **apply the initial colour**
   (system red, §7.1) to the geometry's material, **install the perpetual spin action**
   (§6), and **wire the target-action handlers** (§7, §10).
5. **Present and focus** — make the window key and order it front; activate the
   application ignoring other apps so it is frontmost on launch.
6. **Announce** — write a one-line launch diagnostic to standard output. The line
   **begins with the text `SceneKit Viewer`**; the remainder (running/opened phrasing,
   quit guidance) is implementation-specific and not part of the contract.
7. **Run** — enter the AppKit run loop; the process blocks servicing events.
8. **Terminate** — via the **Quit** command (Command-Q → `-[NSApplication terminate:]`),
   the `gui-app` app-kind's termination model (`termination "ns-application-terminate"`).
   See §8.

   **Termination is Quit-driven, not close-driven.** No implementation installs an
   application delegate or opts into terminate-after-last-window-closed, and the app-kind
   does not require it; on stock AppKit, closing the window hides it and the process keeps
   running **(unknown — to confirm in-VM)**. Three implementations' printed guidance
   ("Close window or Ctrl+C to exit") suggests otherwise; that text is guidance prose, not
   behaviour.

No app-driven timers or background work: the only continuous dynamism is the SceneKit
action animating the node (§6), which the framework drives; everything else is
user-initiated.

## 4. Window

A single top-level window created through the designated initializer
`initWithContentRect:styleMask:backing:defer:`:

- **Content rectangle:** origin `(0, 0)`, size **640 × 480** points (recentered before
  display, so the origin is irrelevant).
- **Style mask:** the bitwise-OR of **Titled** (1) · **Closable** (2) ·
  **Miniaturizable** (4) · **Resizable** (8). Resizable is deliberate: both content
  regions track resize through autoresizing masks (§5).
- **Backing store:** *Buffered* (`NSBackingStoreBuffered` = 2). **Defer:** *false*.
- **Title:** the literal string **`SceneKit Viewer`** — invariant across implementations
  and never changed after launch.
- **Minimum content size:** **480 × 360** points — the window cannot be shrunk below this.
- **Position:** recentered via the window's standard `center` behaviour before display.

## 5. Content layout

Two non-overlapping regions fill the 640 × 480 content view: a toolbar strip in the top
band and the scene view filling everything below it. Both are direct subviews of the
window's content view and track window resize through autoresizing masks (no Auto Layout
constraints).

### 5.1 Toolbar

A **horizontal stack view** (`NSStackView`) with frame `(12, 440, 616, 32)` in the content
view's bottom-left-origin space — a 32-point strip with symmetric 12-point side insets
(12 + 616 + 12 = 640) and symmetric 8-point margins above (472→480) and below (432→440)
it. *The intent is a top-pinned control strip clear of the viewport, not the literal
coordinates.*

- **Orientation:** horizontal (`NSUserInterfaceLayoutOrientationHorizontal` = 0);
  **spacing:** 8 points. *(Three implementations also set first-baseline alignment,
  `NSLayoutAttributeFirstBaseline` = 12; one leaves the stack's default — alignment is a
  realization, not part of this contract.)*
- **Arranged subviews, in order:** the **geometry picker**, then the **colour button**.
  (Individual control frames passed at construction are stack arrangement details, not
  part of this contract.)
- **Autoresizing:** width-sizable + min-Y-margin — the strip grows with window width and
  stays **pinned to the top edge** as the window resizes.

**The geometry picker** is an `NSPopUpButton` created with `initWithFrame:pullsDown:`,
**pullsDown = false** (a pop-up, not a pull-down: the control displays the current
selection). Four items are added via `addItemWithTitle:`, in this order: **`Cube`**,
**`Sphere`**, **`Torus`**, **`Cylinder`**. The app never sets a selection; the picker is
expected to show its first item, `Cube` — matching the initially displayed cube — by the
platform's first-item default **(to confirm in-VM)**.

**The colour button** is a push button whose title is the word for colour followed by an
ellipsis — realized per implementation in en-US or en-GB spelling (e.g. `Color…`), so the
cross-implementation stable observable substring is **`Colo`** and the trailing character
is U+2026. *(Three implementations set the rounded bezel style, `NSBezelStyleRounded` = 1;
one takes its construction factory's default — the bezel is a realization.)*

### 5.2 Scene view

An `SCNView` with frame `(0, 0, 640, 432)` — the full content width and everything below
the toolbar band:

- **Autoresizing:** width-sizable + height-sizable — it grows with the window in both
  dimensions.
- **Camera control on** (`setAllowsCameraControl:` true): SceneKit installs its built-in
  camera controller; every implementation relies on this for mouse-orbit and scroll-zoom
  in place of any app-created camera node **(interaction effect to confirm in-VM)**.
- **Default lighting on** (`setAutoenablesDefaultLighting:` true — a member `SCNView`
  gains from its **SCNSceneRenderer** protocol conformance): SceneKit supplies the
  lighting; the app creates no light node **(lit rendering to confirm in-VM)**.
- **Background colour:** `NSColor darkGrayColor`.
- **The scene is assigned at startup** (`setScene:`); the viewport is never empty.

## 6. Scene & geometry model

- **The scene** comes from the `SCNScene` class factory `scene`; its `rootNode` is the
  graph root.
- **One geometry node** — the app's only created node — is built with the `SCNNode` class
  factory `nodeWithGeometry:` around the **initial cube** (index 0 below) and parented
  into the root via `addChildNode:`. The node is **never positioned**: it stays at the
  root origin, and no `SCNVector3` value crosses the API anywhere in the app.
- **The geometry catalogue** — a pure index → geometry mapping shared by the initial
  construction and every swap; indices align positionally with the picker's item order:

  | Picker index | Item title | Geometry class | Class factory | Parameters |
  |---|---|---|---|---|
  | 0 | `Cube` | SCNBox | `boxWithWidth:height:length:chamferRadius:` | 2.0 × 2.0 × 2.0, chamfer 0.1 |
  | 1 | `Sphere` | SCNSphere | `sphereWithRadius:` | radius 1.2 |
  | 2 | `Torus` | SCNTorus | `torusWithRingRadius:pipeRadius:` | ring 1.0, pipe 0.35 |
  | 3 | `Cylinder` | SCNCylinder | `cylinderWithRadius:height:` | radius 1.0, height 2.0 |

  **Boundary — out-of-range index:** any index outside 0–3 yields the cube (a defensive
  default present in every implementation; unreachable through the four-item picker).
- **The spin.** At startup the app runs, once, on the geometry node:
  `repeatActionForever:` wrapping `rotateByX:y:z:duration:` with **x = 0, y = 1.5, z = 0,
  duration = 4.0** — a continuous rotation about the y-axis of 1.5 radians every
  4 seconds. `runAction:` is a member `SCNNode` gains from its **SCNActionable** protocol
  conformance. The action is installed exactly once and never reinstalled: every
  implementation relies on the platform behaviour that **replacing `node.geometry` does
  not cancel actions on the node**, so the spin survives geometry swaps with no extra
  bookkeeping **(continuity across swaps to confirm in-VM)**.
- **Geometry swap** (the picker's action, §7): read the picker's `indexOfSelectedItem`,
  build the catalogue geometry for it, assign it with `setGeometry:`, then re-apply the
  current colour (§7.2). The swap handler does nothing else — no action, camera, or scene
  manipulation.

## 7. Colour state & the colour-panel flow

### 7.1 The colour state

The app tracks **one current colour** in application state, initially
**`NSColor systemRedColor`**. It is applied to the material at startup and re-applied
after every geometry swap. *Why state, not a view read-back:* SceneKit creates a **fresh
`firstMaterial` for every geometry**, so without re-application every swap would reset the
displayed colour to white (one implementation's VM run observed exactly that regression
before the re-apply existed).

### 7.2 The apply rule (single write-path to the material)

Traverse **node → `geometry` → `firstMaterial` → `diffuse`** and set the material
property's `contents` to the stored colour (`setContents:` accepts an `NSColor`).
**Boundary — every step is nil-guarded:** if the geometry, material, or diffuse property
is missing, the application is silently skipped (no error, no state change).

### 7.3 Opening the panel

Activating the colour button:

1. Obtain the **shared `NSColorPanel`** (class accessor `sharedColorPanel`).
2. (Re)wire it on **every** activation: `setTarget:` the app's handler, `setAction:` the
   colour-changed action, and **`setContinuous:` true** — so the action fires repeatedly
   while the user drags through the panel's colour wheel/sliders, not only on release
   **(continuous delivery to confirm in-VM)**.
3. Show it: `makeKeyAndOrderFront:` — the panel becomes the key window (a driver
   consequence: the next click on the app window only re-activates it — see §13 guidance).

### 7.4 Reacting to a colour change

The panel sends the colour-changed action with itself as sender. The handler:

1. Reads the panel's `color`. **Boundary — nil colour:** if absent, nothing happens.
2. **Normalizes to device RGB** via `colorUsingColorSpace:` with
   `NSColorSpace deviceRGBColorSpace`. *Why:* panel colours can arrive in any colour
   space; normalizing guarantees a colour SceneKit's material path can sample.
3. On a successful conversion: **store** the converted colour as the current colour and
   **apply** it via §7.2 — recolouring the live material immediately.

**Boundary — conversion failure:** the behaviour when the device-RGB conversion returns
nil is **not specified** — the implementations diverge (three keep the previous colour
unchanged; one stores the unconverted panel colour).

**Boundary — handler failure:** two implementations additionally guard the whole handler,
writing a `colorChanged:`-prefixed diagnostic to standard error and continuing; the other
two rely on the nil-guards alone. Error-swallowing-with-log is **not** an invariant of
this spec; the invariant is only that a failed colour change causes no crash and no state
change beyond §7.4.3.

**Boundary — dismissing the panel** picks nothing: no code observes panel closure, so the
current colour and material are unchanged.

## 8. Application menu

- The menu bar carries one application menu; its bold app-name slot comes from the
  bundle's `CFBundleName` when launched as a `.app` bundle.
- The mandated behaviour is a **Quit** command: title **`Quit SceneKit Viewer`**
  (`"Quit " + <display name>`), **key equivalent Command-Q**, action
  **`-[NSApplication terminate:]`** — the app-kind's termination model.
- A conforming implementation may include the other conventional first-menu items
  (About, Hide, …); only *Quit (Command-Q) terminates the app* is asserted.

## 9. API surface exercised

Selectors witnessed in **every** implementation (or named by the app-kind contract) —
platform truths, projection-free:

| Class | Selector | Kind | Role |
|-------|----------|------|------|
| NSApplication | `sharedApplication` | class accessor (singleton) | obtain the app instance |
| NSApplication | `setActivationPolicy:` | property setter | become a Regular app |
| NSApplication | `activateIgnoringOtherApps:` | instance method | foreground on launch |
| NSApplication | `run` | instance method | enter the run loop |
| NSApplication | `terminate:` | instance method | quit (app-kind termination; the Quit item's action) |
| NSWindow | `initWithContentRect:styleMask:backing:defer:` | designated initializer | create the window |
| NSWindow | `setTitle:` · `center` · `setMinSize:` · `contentView` · `makeKeyAndOrderFront:` | setters/methods/getter | title, position, size floor, composition root, show+focus |
| NSView | `addSubview:` · `setAutoresizingMask:` | method / setter | containment; resize tracking |
| NSPopUpButton | `initWithFrame:pullsDown:` | initializer | the geometry picker (pop-up, not pull-down) |
| NSPopUpButton | `addItemWithTitle:` | instance method | the four geometry item titles |
| NSPopUpButton | `indexOfSelectedItem` | property getter | selection → catalogue index |
| NSControl *(picker)* | `setTarget:` · `setAction:` | property setters | wire the swap action (button wiring varies — below) |
| NSStackView | `setOrientation:` · `setSpacing:` · `addArrangedSubview:` | setters/method | the toolbar row |
| NSColor | `systemRedColor` · `darkGrayColor` | class factories | initial material colour; viewport background |
| NSColor | `colorUsingColorSpace:` | instance method | device-RGB normalization (§7.4) |
| NSColorSpace | `deviceRGBColorSpace` | class factory | the normalization target space |
| NSColorPanel | `sharedColorPanel` | class accessor (singleton) | the shared panel |
| NSColorPanel | `setTarget:` · `setAction:` · `setContinuous:` · `makeKeyAndOrderFront:` · `color` | setters/method/getter | continuous wiring; show; read the picked colour |
| SCNView | `setAllowsCameraControl:` · `setBackgroundColor:` · `setScene:` | property setters | §5.2 configuration |
| SCNView *(via SCNSceneRenderer)* | `setAutoenablesDefaultLighting:` | property setter | framework-supplied lighting |
| SCNScene | `scene` | class factory | the scene |
| SCNScene | `rootNode` | property getter | scene-graph root |
| SCNNode | `nodeWithGeometry:` | class factory | the displayed node |
| SCNNode | `addChildNode:` | instance method | parent into the root (scene-graph containment) |
| SCNNode | `geometry` · `setGeometry:` | accessor pair | read/swap the displayed geometry |
| SCNNode *(via SCNActionable)* | `runAction:` | instance method | install the spin |
| SCNGeometry | `firstMaterial` | property getter | the material chain (§7.2) |
| SCNMaterial | `diffuse` | property getter | the diffuse material property |
| SCNMaterialProperty | `setContents:` | property setter | assign the NSColor |
| SCNAction | `rotateByX:y:z:duration:` · `repeatActionForever:` | class factories | the perpetual spin |
| SCNBox | `boxWithWidth:height:length:chamferRadius:` | class factory | catalogue index 0 |
| SCNSphere | `sphereWithRadius:` | class factory | catalogue index 1 |
| SCNTorus | `torusWithRingRadius:pipeRadius:` | class factory | catalogue index 2 |
| SCNCylinder | `cylinderWithRadius:height:` | class factory | catalogue index 3 |

**Abstract operations whose realizing selector varies per implementation** (this spec
asserts the operation, never one impl's selector): scene-view creation (`initWithFrame:`
vs. `initWithFrame:options:` with nil options); control/stack instantiation + framing
(`initWithFrame:` vs. bare init + `setFrame:`); colour-button construction, titling, and
wiring (`setTitle:` + `setBezelStyle:` + `setTarget:`/`setAction:` vs. the
`buttonWithTitle:target:action:` factory); main-menu installation (a shared standard-menu
helper vs. inline `NSMenu`/`NSMenuItem` object-graph construction); handler-object
mechanism (§10).

**9.1 Enum / constant values used in every implementation:**

| Constant | Value | Used for |
|----------|-------|----------|
| `NSApplicationActivationPolicyRegular` | 0 | activation policy |
| `NSWindowStyleMaskTitled` | 1 | window style |
| `NSWindowStyleMaskClosable` | 2 | window style |
| `NSWindowStyleMaskMiniaturizable` | 4 | window style |
| `NSWindowStyleMaskResizable` | 8 | window style |
| `NSBackingStoreBuffered` | 2 | window backing |
| `NSUserInterfaceLayoutOrientationHorizontal` | 0 | toolbar stack orientation |
| `NSViewWidthSizable` | 2 | autoresizing (both regions) |
| `NSViewHeightSizable` | 16 | autoresizing (scene view) |
| `NSViewMinYMargin` | 8 | autoresizing (toolbar pin-to-top) |

*Used in three of the four implementations (the fourth takes platform defaults):*
`NSBezelStyleRounded` (1, colour-button bezel) and `NSLayoutAttributeFirstBaseline`
(12, stack alignment).

## 10. API-usage patterns

- **`target-action`, three wirings:** the picker → the geometry-swap action (wired at
  build time); the colour button → the open-panel action (wired at build time); the shared
  colour panel → the colour-changed action (wired at runtime, on every button activation,
  in continuous mode). All four implementations use the same app-defined action selector
  names — `geometryChanged:`, `openColor:`, `colorChanged:` — an internal, non-observable
  convention recorded here as shared fact, not testable contract.
- **Handler-object granularity is a rule; its mechanism is a realization:** every
  implementation routes all three actions to **one** app-side handler object that outlives
  the run loop (controls and the panel hold their targets weakly). Three implementations
  realize it as a generic multi-selector delegate object; one as a synthesized
  `NSObject` subclass instance holding the node and colour in instance state.
- **`parent-child` twice over:** view containment (toolbar strip and scene view into the
  content view; picker and button arranged into the stack) and scene-graph containment
  (the geometry node into the scene's root node).
- **Chained-accessor traversal:** scene → `rootNode`; node → `geometry` →
  `firstMaterial` → `diffuse` → `contents` — construction and mutation both walk the
  object graph rather than caching intermediate objects (only the node and the colour are
  held as state).
- **Continuous control:** `setContinuous:` true on the panel converts target-action from
  discrete clicks into a stream of updates during dragging.
- **Protocol-conformed members:** `runAction:` (SCNActionable, conformed by `SCNNode`) and
  `setAutoenablesDefaultLighting:` (SCNSceneRenderer, conformed by `SCNView`) are used as
  ordinary members of the conforming classes.
- **State-holding UI with re-application:** the current colour is app state written
  through one rule (§7.2) at three moments — startup, colour change, and after each swap —
  keeping the display correct across model replacement.
- **Class-method factories / singletons:** `sharedApplication`, `sharedColorPanel`,
  `scene`, `nodeWithGeometry:`, the four geometry factories, the two action factories,
  `systemRedColor` / `darkGrayColor` / `deviceRGBColorSpace`.
- **Object lifecycle, property configuration, value-type geometry, option-set bitmask,
  menu object-graph construction, run-loop entry:** as in the app-kind and the earlier
  portfolio specs.

## 11. Observable outcomes & accessibility

**Visual outcomes:**
- A centered, resizable 640 × 480 window titled `SceneKit Viewer`, with a top toolbar
  reading `Cube` (the picker) and `Colo…` (the colour button), above a dark-grey 3D
  viewport.
- The viewport shows a lit red cube spinning continuously about its vertical axis
  **(to confirm in-VM — rendered-scene content is pixel-level, not OCR/AX-addressable)**.
- Picking `Sphere` / `Torus` / `Cylinder` swaps the displayed shape; the spin and the
  current colour persist across the swap **(to confirm in-VM)**.
- Activating the colour button opens the shared system colour panel; dragging through its
  colour wheel recolours the geometry live **(to confirm in-VM)**.
- Dragging in the viewport orbits the camera; scrolling zooms (the built-in camera
  controller) **(to confirm in-VM)**.
- Native macOS control appearance throughout (no custom drawing).

**Accessibility expectations** *(in-VM confirmable)*:
- The window is exposed with accessibility title `SceneKit Viewer`.
- The picker is exposed as a pop-up-button element whose value is the selected item title
  (`Cube` initially); its menu exposes the four items. *(Pop-up menus re-align to the
  current selection, so item positions must be read from the open menu's accessibility
  snapshot — see §13.)*
- The colour button is exposed as a button element whose title contains `Colo` and ends
  with `…`.
- The shared colour panel appears as an additional window of the app (platform-titled —
  observed as `Colors` in one implementation's VM notes) **(to confirm in-VM)**.
- The application menu's Quit item is reachable and carries the Command-Q key equivalent.

## 12. Not included

- **No camera node, no light node, no positioning** — no `SCNVector3` value crosses the
  API anywhere; the camera is `allowsCameraControl`'s, the lighting is
  `autoenablesDefaultLighting`'s, and the node sits at the origin.
- **No zoom/orbit/reset controls of the app's own** — all camera interaction is the scene
  view's built-in behaviour.
- **No view subclassing and no custom drawing** (one implementation's `NSObject` subclass
  is action plumbing, not a view).
- **No document, file, or persistence surface; no MRU; no state across launches.**
- **No error dialogs** — every failure path is silent (at most a stderr diagnostic in two
  implementations, §7.4).
- **No window retitling** — the title stays `SceneKit Viewer`.
- **No close-to-quit** — closing the window is not specified to terminate the app (§3.8).
- **No app timers or background threads** — the animation is SceneKit's action system.
- **No panel teardown** — the colour panel is never unwired or explicitly closed;
  app-lifetime wiring is the contract.
- **No explicit picker selection** — the initial `Cube` display is the platform's
  first-item default, not app code.

## 13. Behavioural exemplar (acceptance / forward-generation input)

Observable assertions against a live-VM run, each mapped to a scenario-runner verb
(enumeration only — not scenario code). Assertions state the *rule* (stable
substrings/invariants), so the suite verifies any conforming implementation.

**No fixtures:** the app ships and needs no documents. **Driver guidance** (from the
implementations' VM notes): click at accessibility-reported coordinates, not screenshot
pixels; read pop-up menu item positions from the *open* menu's AX snapshot (a pop-up
re-aligns its menu to the current selection); after the colour panel has taken key, the
first click on the app window only re-activates it — the targeted control fires on the
second click; the continuous panel action fires reliably on a *drag*, which the closed
verb set cannot express (no mouse-drag verb) — colour-change and rendered-scene assertions
below are therefore spec prose pending a pixel/drag-capable driver.

- **Process is running after launch.** → `expect-running-app`
- **Launch diagnostic is emitted.** Stdout contains a line beginning `SceneKit Viewer`. →
  `wait-for-log "SceneKit Viewer"` / `expect-log "SceneKit Viewer"`
- **Window title is correct.** The frontmost window's accessibility title is
  `SceneKit Viewer`. → `expect-ax` window AXTitle and/or `expect-ocr "SceneKit Viewer"`
- **Picker present, first item selected.** A pop-up-button element exists with value
  `Cube`. → `expect-ax` popup value / `wait-for-ocr "Cube"` *(first-item default — to
  confirm in-VM)*
- **Colour button present.** A button element whose title contains `Colo` exists. →
  `expect-ax` / `expect-ocr "Colo"`
- **Viewport renders a scene.** A lit shape is visible against the dark-grey backdrop
  *(to confirm in-VM; the closed verb set has no pixel-comparison verb, so this stays
  spec prose without a runnable assertion)*.
- **Animation is live.** The rendered shape's orientation changes over time *(to confirm
  in-VM; pixel-level — no runnable verb; `wait` can space the observations)*.
- **Picker menu lists the catalogue.** Opening the picker shows `Cube`, `Sphere`,
  `Torus`, `Cylinder`. → `click-at` the picker, then `wait-for-ocr "Torus"` (any
  non-selected title) *(to confirm in-VM)*
- **Geometry swap tracks selection.** Choosing `Sphere` updates the picker's value to
  `Sphere`. → `click-at` the item (AX-snapshot position), `expect-ax` popup value /
  `expect-ocr "Sphere"` *(to confirm in-VM; the rendered shape change itself is
  pixel-level — no runnable verb)*
- **Spin survives the swap.** After the swap the shape still animates *(to confirm
  in-VM; pixel-level — no runnable verb)*.
- **Colour panel opens.** Activating the colour button brings up the shared colour
  panel. → `click-at` the colour button, `wait-for-ocr "Colors"` *(panel chrome text is
  platform-supplied — to confirm in-VM)*
- **Live recolour.** Dragging in the panel's colour wheel recolours the displayed shape
  while dragging *(to confirm in-VM; needs a drag gesture and pixel comparison — outside
  the closed verb set)*.
- **Colour persists across a swap — the key behaviour.** After recolouring, swapping the
  geometry keeps the chosen colour (never resetting to white) *(to confirm in-VM;
  pixel-level — no runnable verb)*.
- **Boundary — dismissing the panel changes nothing.** Closing the panel without a pick
  leaves the displayed colour unchanged *(to confirm in-VM; pixel-level)*.
- **Quit menu terminates the app.** Sending Command-Q ends the process. →
  `chord cmd q`, then `expect-running-app` is false
- **(To confirm in-VM) Close-button behaviour.** Activating the close control hides the
  window; per §3.8 the process is expected to keep running (no close-to-quit opt-in). A
  scenario should record the *actual* observed behaviour. → `click-at` close button,
  then `expect-running-app`
