# Drawing Canvas — Observable State

> **Porting guide.** What an implementation of Drawing Canvas must make *observable* to the
> AppSpec runner's VM-side verbs (OCR, accessibility, process, input). Derived from spec §12
> (observable outcomes & accessibility) and §14 (behavioural exemplar); templates:
> [../../hello-window/docs/observable-state.md](../../hello-window/docs/observable-state.md),
> [../../ui-controls-gallery/docs/observable-state.md](../../ui-controls-gallery/docs/observable-state.md),
> [../../scenekit-viewer/docs/observable-state.md](../../scenekit-viewer/docs/observable-state.md),
> [../../note-editor/docs/observable-state.md](../../note-editor/docs/observable-state.md).
> Nothing here is the impl's to *log* — these are states the **VM observes** of a correctly-built
> impl; the porting obligation is "build the UI so these reads succeed." Assertions that need
> state the verbs cannot read — **stroke lifecycle, the frozen tool state, stroke-set
> cardinality** — ride the **logging contract's `[canvas]` events** instead
> ([logging-contract.md](logging-contract.md)); **screenshots are the sole canvas-content
> channel** (strokes are framebuffer-visible but OCR-meaningless and AX-invisible — the visual
> bar is met by artifact review, [[sample_apps_perfect]]). The assertion map below shows which
> channel each §14 line takes.

## Process

| Observable | Verb | Notes |
|---|---|---|
| The app process is running after launch | `expect-running-app <bundle-id>` | `com.linkuistics.drawing-canvas-<impl>`; the impl must build to a `.app` whose `CFBundleIdentifier` matches. |
| The app process is gone after Command-Q | `expect-running-app <bundle-id> #:running? #f` | the ⌘Q chord must reach `-[NSApplication terminate:]` via the app menu (spec §9) and end the process. No modal surface exists in this app (the colour panel is non-modal, §8.1) — quit from steady state per the standing rule; ⌘Q-with-the-panel-key is expected to work (key equivalents route through the menu bar) **(to confirm in-VM)**. |

## No fixtures, no persistence (this app's simplicity)

The first app since hello-window with **neither fixtures nor on-disk state**: nothing to upload,
no `work/` directory, **no between-scenario cleanup obligation**. All app state (strokes, tool
state) is in-process and dies with the process; scenario isolation comes free from relaunch. The
only cross-launch state is the shared `NSColorPanel`'s per-app remembered kind/frame (system
defaults) — neutralized once at provisioning by the k112 rule (below), not per scenario.

## On-screen (OCR)

| Observable | Verb | Notes |
|---|---|---|
| The window title is readable | `expect-ocr "Drawing Canvas"` | title-bar text; the **AX window title is the firm channel** — title-bar OCR garble on racket's compact metrics is a known run-mechanism residual (pdfkit k103; the app-menu bold name is a second on-screen instance of the same text). |
| Toolbar button titles readable | `expect-ocr "Color"`, `expect-ocr "Clear"` | prefer the **ellipsis-free substring** `Color` for the U+2026-bearing title (the standing driver guidance); AX carries the exact form. |
| Canvas content | — | **not an OCR channel at all**: strokes are curves, not text. Blankness, dots, stroke colour/width all ride **screenshot artifacts** (adjudicate by artifact review; the `[canvas]` events are the model half of every drawing assertion). |
| Colour panel chrome | `wait-for-ocr "Colors"` / slider-pane labels (`"Red"`, `"Green"`, `"Blue"`) | after the RGB-kind seeding (below); panel chrome renders at system size (good OCR odds); the RGB value fields are small text — type into them rather than read them (k112). |

## Accessibility (AX tree)

`expect-ax` / `expect-no-ax` walk `gv-ax-snapshot` matching `AXRole` (+ optional **exact**
`AXTitle`). The SDK transform folds each element's `label` → `value` → `description` (first
non-empty) into `AXTitle`. Expected roles — the *uncertain* rows are confirmed/corrected during
the live-run stage before the suite hard-asserts them (the standing precedent):

| Element | Expected role | Title match usable? | Confidence |
|---|---|---|---|
| window | `AXWindow` | **yes** — exact `"Drawing Canvas"`, never retitled (§13) | firm |
| Color… button | `AXButton` | `"Color…"` (U+2026 in the AX title) | firm — pdfkit k96 firmed ellipsis-as-AXTitle |
| Clear button | `AXButton` | `"Clear"` | firm |
| width slider | slider role | value initially **2** in range 1–20 (§5.1/§12); the exact role string + value/range read format under the SDK transform | **provisional value-read** — the gallery's slider rows served its k94 suite (role presence firm); confirm the value format at live-run before hard-binding; the log channel (`width=2` on the first stroke's events) is the firm state half |
| canvas | **no content AX** — no static-text/child element for the drawing surface (§6/§12: no accessibility is configured; strokes are pixels) | — | **provisional** — confirm via `expect-no-ax` at live-run (spec §14 flags it) |
| colour panel | an additional window of the app (platform-supplied chrome) | panel title (`Colors`) | firm presence (k112: shared panel opened as a second window on all four impls); **internal geometry is per-impl** — k112 rows: opens at default frame (0,605) 250×397; racket's compact control metrics **reach inside the picker pane** (fields ~9px higher) → measure panel-interior coordinates per impl from the OPEN panel, never share them |
| Quit menu item | `AXMenuItem` | `"Quit Drawing Canvas"` | as the prior apps; the ⌘Q key-equivalent itself is the standing `#:key` gap |

**NSColorPanel provisioning (the k112 rule, applies wholesale):** fresh per-app defaults open
the sliders pane in **Grayscale** kind — seed the **RGB** kind per impl at provisioning
(remembered per-app, survives relaunch). The panel's slider space is **not device-RGB**: typed
field values land post-fold (k112: driven 0/128/255 → device `(0,150,255)`, byte-identical
across impls) — suites bind **recorded actuals** from the `color-changed` event, and a
no-change field commit does not re-fire the action.

## §14 assertion → observation path (the coverage-or-gap map)

Per the forward-gen coverage-or-gap rule (`AppSpec/capabilities/forward-gen/validation.md`
L1b): every §14 line is served by a verb-backed path *or* carries a documented gap. This app
needs no network and no fixtures; every group below is runnable in the VM. The recurring shape:
**the `[canvas]` event is the model half, the screenshot artifact the pixel half** — the event
makes the assertion drivable, the artifact review meets the visual bar.

**Launch:**

| §14 assertion | Observation path |
|---|---|
| process running after launch | process: `expect-running-app` |
| launch diagnostic emitted | events.log: `wait-for-log "Drawing Canvas"` |
| window title correct | AX `AXWindow` exact `"Drawing Canvas"` + OCR |
| toolbar controls present | AX `AXButton` ×2 (exact `Color…`/`Clear`) + slider role + OCR `"Color"`/`"Clear"` |
| slider initial state | AX slider value 2 *(read format provisional)* + the first stroke's events carrying `width=2` (the firm log half) |
| launch canvas is blank | screenshot artifact (pixel-level — documented gap as a hard assertion) + `cleared count=0` on a launch Clear proves the empty stroke *set* (the positive log channel) |
| canvas exposes no content elements | `expect-no-ax` *(provisional — confirm in-VM)* |

**Drawing gestures:**

| §14 assertion | Observation path |
|---|---|
| bare click paints a dot | `click-at` a canvas point → events.log `stroke-begun r=0 g=0 b=0 width=2` + `stroke-committed … points=1` (the deterministic dot discriminator) → screenshot artifact for the dot's pixels |
| drag paints a stroke | held-button drag across the canvas (the scenekit k112 orbit-drag precedent) → `stroke-committed … points=\d+` → screenshot artifact |
| live rendering during the drag | pixel-level mid-drag capture — **documented gap** (no mid-gesture capture choreography); the post-gesture artifact + the committed event are the record |
| a drag begun on a toolbar control draws nothing | press on a control, drag across the canvas → then `click-at` Clear → `cleared count=0` (the cardinality channel turns the absence positive) + artifact |
| typing draws nothing | `type "x"` → `expect-running-app` → `click-at` Clear → `cleared count=0` + artifact |

**Tool state (the key behaviour):**

| §14 assertion | Observation path |
|---|---|
| width applies to subsequent strokes only | draw at launch (`committed width=2` on record) → `click-at` the slider track (effective ends, knob half-width in — k94) → `width-changed width=<actual>` (bind recorded) → draw → `committed … width=<actual>` — the freeze proven from the log alone; stroke thickness pixels = artifact |
| colour panel opens | `click-at` `Color…` → AX second window / OCR panel chrome (k112 shape) |
| live recolour of subsequent strokes | drive the panel (type into the RGB fields, commit) → `color-changed r=<a> g=<b> b=<c>` (recorded actuals post-fold) → re-key the main window (below) → draw → `committed` carrying the same `r`/`g`/`b`; the earlier stroke's `committed` line (0/0/0) is already on record — **previously drawn strokes keep their colour** rides the artifact + the frozen-tuple log pair |
| dismissing the panel picks nothing | close the panel without a pick → draw → `committed` still carrying the last driven colour (no `color-changed` intervened — the positive form; absence itself not asserted) |

**Clear:**

| §14 assertion | Observation path |
|---|---|
| Clear empties the canvas | draw N strokes → `click-at` Clear → events.log `cleared count=N` + `expect-running-app`; blankness = screenshot artifact |
| Clear on an empty canvas is a safe no-op | `click-at` Clear at launch → `cleared count=0` + `expect-running-app` |

**Lifecycle:**

| §14 assertion | Observation path |
|---|---|
| Quit terminates | steady state → `chord cmd q` → process gone + events.log `shutdown reason=menu` |
| close-button behaviour | recording scenario: `click-at` the close button → `expect-running-app` — recorded, not asserted (§3 expects keep-running but flags it to-confirm; a `shutdown` in the log would be the spec-quality finding) |

**Driver guidance the suite must honour** (spec §14 + the prior runs — acute here because
*every* canvas gesture is a click/drag issued straight after a capture poll): `gv-click`'s
100px pre-move (AppSpec `b2c6ffa`, the k130 capture-then-parked-click swallow) is load-bearing
for every canvas click; strokes require a **held-button drag** — a bare pointer move between
down and up yields only a down-point dot (§14); after the colour panel has key, the first
main-window click **may deliver** (`acceptsFirstMouse` is control-dependent — k112) and on the
canvas a delivered click *begins a stroke* — **re-key via a title-bar click** (no canvas
mouse-down, no control side-effect) before the next gesture, or consume the stray stroke via
`cleared count=`; choreography to confirm at live-run; click at AX-reported coordinates, never
screenshot pixels; bind slider clicks at the track's *effective* ends (knob half-width in) and
never within ~10px of the resizable window's border (k94); settle after `type` before any
button click (k121 — little typing exists here, but the RGB-field drive types then commits).

## Deferred / gap observables (not acceptance preconditions)

Reported as gaps rather than hard-asserted before the channel is firm (the forward-gen
"mutant-D" discipline; same section shape as the prior apps):

- **Stroke pixels — this app's headline gap.** Colour, width, shape, smoothness, the dot's
  roundness, blankness after Clear: all pixel-level with no pixel-diff verb. Every drawing
  assertion has its `[canvas]` event as the firm model half; the pixel half rides screenshot
  artifacts reviewed at adjudication (the visual bar — the human eye still checks the window).
- **Live-during-drag rendering** (§7.1) — needs a mid-gesture capture; recorded if the drag
  choreography allows one, else the post-gesture artifact stands.
- **Continuous delivery of both controls** (§5.1 slider, §8.1 panel — spec flags both
  to-confirm): whether the driver's gestures produce event *streams* or single fires; the
  suites match final lines either way (the logging contract's rule).
- **Stroke anchoring under window resize** (§7.2 unknown; §4 resizable) — no window-resize
  verb; spec prose without a runnable assertion.
- **Canvas AX invisibility and the slider value-read format** — the two provisional AX rows
  above; confirmed at live-run before the suite hard-binds them.
- **Panel-interior geometry** — per-impl, measured live from the OPEN panel (k112: racket's
  compact metrics shift the picker-pane fields); never shared across impls, never projected.
- **Window size/position (640×480 centred, min 400×300) and the ⌘Q key-equivalent** — the
  standing `expect-ax #:size/#:position/#:key` gap set the prior apps recorded. Autoresizing
  behaviour (§5's anchoring intent) additionally lacks a resize gesture.
- **Graphical polish** — native control appearance, the toolbar band's layout intent, stroke
  smoothness (round cap/join) — confirmed visually during the live-run stage and recorded in
  `run-results.md` (sample apps must be visually perfect).

## Build obligation summary (per impl)

A conformant build must, beyond the [logging contract](logging-contract.md): render the single
centred resizable 640 × 480 window (min 400 × 300) titled `Drawing Canvas` (never retitled);
the 36-point top toolbar band holding `Color…` (left, rounded bezel), the 200-point continuous
slider (1–20, initial 2), and `Clear` (right-anchored, sliding with the right edge); below it
the app-defined `NSView` canvas filling the remainder (width+height sizable), overriding
exactly `drawRect:` + the three mouse selectors, holding the §7 capture-at-mouse-down stroke
model and rendering oldest-first with round cap/join through direct CoreGraphics calls; the
shared `NSColorPanel` rewired continuous on every `Color…` activation with the §8.1 device-RGB
fold; standard AX roles for the native controls (and none configured on the canvas); and the
app-menu **Quit** item (⌘Q → `terminate:`). The four existing impls already build all of this —
the delta each needs is the logging instrumentation.
