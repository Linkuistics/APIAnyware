# SceneKit Viewer — Observable State

> **Porting guide.** What an implementation of SceneKit Viewer must make *observable* to the
> AppSpec runner's VM-side verbs (OCR, accessibility, process, input). Derived from spec §11
> (observable outcomes & accessibility) and §13 (behavioural exemplar); templates:
> [../../hello-window/docs/observable-state.md](../../hello-window/docs/observable-state.md),
> [../../ui-controls-gallery/docs/observable-state.md](../../ui-controls-gallery/docs/observable-state.md),
> [../../pdfkit-viewer/docs/observable-state.md](../../pdfkit-viewer/docs/observable-state.md).
> Nothing here is the impl's to *log* — these are states the **VM observes** of a correctly-built
> impl; the porting obligation is "build the UI so these reads succeed." Everything *rendered
> inside the viewport* is unobservable to the verbs and rides the **logging contract's `[scene]`
> events** instead ([logging-contract.md](logging-contract.md)); the assertion map below shows
> which channel each §13 line takes.

## Process

| Observable | Verb | Notes |
|---|---|---|
| The app process is running after launch | `expect-running-app <bundle-id>` | `com.linkuistics.scenekit-viewer-<impl>`; the impl must build to a `.app` whose `CFBundleIdentifier` matches. |
| The app process is gone after Command-Q | `expect-running-app <bundle-id> #:running? #f` | the ⌘Q chord must reach `-[NSApplication terminate:]` via the app menu (spec §8) and end the process. |

## The viewport is not observable (this app's defining constraint)

The SCNView's contents are GPU-rendered pixels: **no text for OCR, no AX children for the tree**
(what AX element the SCNView itself exposes, if any, is uncertain — see the AX table). Shape
identity, colour, the spin, and camera orbit/zoom are all invisible to the closed verb set, which
also has no drag or pixel-diff verb (spec §13). So the observable state of this app is the
**window + toolbar chrome** (AX/OCR: title, popup value, `Colo…` button, the `Colors` panel
window) **plus the `[scene]` log events** (the state-level record of swaps and colour changes).
Rendered appearance — lit red cube, live recolour, spin continuity, orbit — is witnessed only by
the human eye during the live-run stage and recorded in `run-results.md`.

The app ships no document and needs **no fixtures** (spec §13). Unlike pdfkit-viewer's
out-of-process open panel, the shared `NSColorPanel` is **in-process** — its window belongs to
the app and should appear in the app's AX tree *(snapshot scope — which windows a snapshot
covers, key vs. all — to confirm in-VM)*.

## On-screen (OCR)

| Observable | Verb | Notes |
|---|---|---|
| The window title `SceneKit Viewer` is readable | `expect-ocr "SceneKit Viewer"` | title-bar text — **invariant across impls** (spec §4). The launch *log* line also begins `SceneKit Viewer` — distinct channels. Title-bar OCR garble is a known run-mechanism residual (pdfkit k103, racket) — adjudicate by artifact review, never by patching the suite. |
| `Cube` is readable at launch | `wait-for-ocr "Cube"` | the picker's selected-item title (first-item default — to confirm in-VM); doubles as the render-settled probe. |
| A button title containing `Colo` is readable | `expect-ocr "Colo"` | realized `Color…` (racket/chez/gerbil) / `Colour…` (sbcl) — assert the substring only (spec §5.1); the U+2026 tail may not OCR reliably. |
| `Sphere` / `Torus` / `Cylinder` readable in the open picker menu | `click-at` the picker, then `wait-for-ocr "Torus"` | the §13 catalogue-listing assertion; any non-selected title suffices *(to confirm in-VM)*. |
| The selected title after a swap | `expect-ocr "Sphere"` etc. | the picker displays its selection (pop-up, not pull-down — spec §5.1). |
| `Colors` after activating the colour button | `wait-for-ocr "Colors"` | the shared panel's platform-supplied chrome *(to confirm in-VM — observed in one impl's VM notes)*. |

There is no other stable text on screen: the viewport is dark-grey pixels plus the rendered
shape, and the app has no labels.

## Accessibility (AX tree)

`expect-ax` / `expect-no-ax` walk `gv-ax-snapshot` matching `AXRole` (+ optional **exact**
`AXTitle`). The SDK transform folds each element's `label` → `value` → `description` (first
non-empty) into `AXTitle`. Expected roles — the *uncertain* rows are confirmed/corrected during
the live-run stage before the suite hard-asserts them (the gallery/pdfkit precedent):

| Element | Expected role | Title match usable? | Confidence |
|---|---|---|---|
| window | `AXWindow` | `"SceneKit Viewer"` (invariant §4) | firm |
| geometry picker | `AXPopUpButton` | `"Cube"` / the selected title — via the value→AXTitle fold | role firm (gallery-confirmed); **popup value-fold to confirm in-VM** (pdfkit firmed the fold for static text, not popups) |
| colour button | `AXButton` | **no** — the title spelling is impl-varying (`Color…` vs `Colour…`, §5.1), so exact match is unusable; presence rides the role + OCR substring | firm role |
| open picker menu items | `AXMenuItem` (?) | `"Cube"` `"Sphere"` `"Torus"` `"Cylinder"` | uncertain — §13 driver guidance reads item *positions* from the open menu's AX snapshot; role/title shape to confirm in-VM |
| SCNView | **unknown** — possibly absent from the tree entirely, or an untitled group/unknown role | no | **uncertain — provisional row** (the k96 pattern): confirm what, if anything, an SCNView exposes during live-run; the suite must not hard-assert it before then |
| Colors panel | `AXWindow` | `"Colors"` (platform-titled) | expected (in-process window) — to confirm in-VM, incl. snapshot scope once the panel is key |
| Quit menu item | `AXMenuItem` | `"Quit SceneKit Viewer"` | as the prior apps; the ⌘Q key-equivalent itself is the standing `#:key` gap |

## §13 assertion → observation path (the coverage-or-gap map)

Per the forward-gen coverage-or-gap rule (`AppSpec/capabilities/forward-gen/validation.md` L1b):
every §13 line is served by a verb-backed path *or* carries a documented gap.

| §13 assertion | Observation path |
|---|---|
| process running after launch | process: `expect-running-app` |
| launch diagnostic emitted | events.log: `wait-for-log "SceneKit Viewer"` |
| window title correct | OCR `"SceneKit Viewer"` (+ AX `AXWindow` exact title) |
| picker present, first item selected | AX `AXPopUpButton` (+ OCR `"Cube"`); the value-fold half *(to confirm in-VM)* |
| colour button present | AX `AXButton` role + OCR `"Colo"` |
| viewport renders a scene | **gap** (pixel-level, no pixel verb) — visual check at live-run, recorded in `run-results.md` |
| animation is live | **gap** (pixel-level) — visual check at live-run |
| picker menu lists the catalogue | `click-at` the picker → `wait-for-ocr "Torus"` (+ the open-menu AX snapshot) *(to confirm in-VM)* |
| geometry swap tracks selection | `click-at` the item (AX-snapshot position) → events.log `geometry-changed shape="Sphere"` + OCR/AX the picker's new value |
| spin survives the swap | **gap** (pixel-level) — visual check at live-run |
| colour panel opens | `click-at` the colour button → `wait-for-ocr "Colors"` (+ AX panel window) *(to confirm in-VM)* |
| live recolour | app-state half: `click-at` inside the panel's colour wheel → events.log `color-changed r=… g=… b=…` *(click delivery to confirm in-VM — the continuous action fires reliably on a drag, and there is no drag verb)*; rendered half a **gap** (pixel-level) |
| **colour persists across a swap** (the key behaviour) | events.log: drive a colour, then swap → `geometry-changed shape="…"` carrying the same folded `r`/`g`/`b` (see the logging contract). Exact-value matching needs an exactly-driven colour — typing into the panel's slider fields *(to confirm in-VM: the panel's slider colour space → device-RGB conversion may shift components; if it does, match the event shape and record actuals)* |
| boundary — dismissing the panel changes nothing | no `color-changed` is emitted (absence is not asserted); behavioural half: a post-dismiss swap's `geometry-changed` still carries the last-driven colour; visual half a **gap** (pixel-level) |
| Quit terminates the app | `chord cmd q` → process gone + events.log `shutdown reason=menu` |
| close-button behaviour | recording scenario: `click-at` close button + `expect-running-app` — recorded, not asserted (spec §3 expects keep-running but flags it to-confirm; a contradiction is a spec-quality finding, not a suite bug) |

Driver guidance the suite must honour (spec §13): click at AX-reported coordinates, never
screenshot pixels; read pop-up item positions from the **open** menu's AX snapshot (a pop-up
re-aligns its menu to the current selection); after the colour panel has taken key, **the first
click on the app window only re-activates it** — the targeted control fires on the second click.

## Deferred / gap observables (not acceptance preconditions)

Reported as gaps rather than hard-asserted before the verb exists (the forward-gen "mutant-D"
discipline; same section shape as the prior apps):

- **Rendered-scene content — this app's headline gap class** (seeded by the reverse-gen stage):
  shape identity, displayed colour, spin continuity, live-recolour appearance, and camera
  orbit/zoom are pixel-level with no pixel-diff verb; orbit additionally needs a drag gesture no
  verb expresses. The `[scene]` events are the state-level proxies; rendered appearance is
  checked by eye at live-run (sample apps must be visually perfect — the human eye still checks
  the window).
- **Panel drive fidelity** — no drag verb: whether a single `click-at` in the colour wheel fires
  the continuous action, and whether typing exact values into the panel's RGB slider fields
  yields exactly those device-RGB components (colour-space shift), are both to-confirm in-VM;
  the suite degrades to shape-level matchers + recorded actuals if either fails.
- **Popup value-fold and open-menu snapshot shape** — expected but unconfirmed; OCR is the firm
  fallback for both.
- **SCNView AX exposure** — unknown; provisional row above, firmed at live-run.
- **Window size/position (640×480 centred, 480×360 min) and the ⌘Q key-equivalent** → the same
  `expect-ax #:size/#:position/#:key` gap set the prior apps recorded. Resize behaviour (§4/§5
  autoresizing) additionally lacks a window-resize gesture verb — spec prose without a runnable
  assertion.

## Build obligation summary (per impl)

A conformant build must, beyond the [logging contract](logging-contract.md): render the single
centred resizable 640 × 480 window (min 480 × 360) titled exactly `SceneKit Viewer`; a top
toolbar strip (horizontal stack) holding the four-item geometry pop-up (`Cube` / `Sphere` /
`Torus` / `Cylinder`, first-item default) and the `Colo…` button; an `SCNView` filling the rest
(dark-grey background, built-in camera control, default lighting, scene assigned at startup with
the spinning geometry node, initial colour applied); the §7 colour state machine (one stored
device-RGB colour, single §7.2 write-path, re-applied after every swap); standard AX roles for
the native controls; and the app-menu **Quit** item (⌘Q → `terminate:`). The four existing impls
already build all of this — the delta each needs is the logging instrumentation.
