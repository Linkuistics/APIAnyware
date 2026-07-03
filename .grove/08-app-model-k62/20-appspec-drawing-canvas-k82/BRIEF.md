# appspec-drawing-canvas-k82 — brief

## Goal

The full AppSpec cycle for **drawing-canvas** (the freehand drawing app — a custom
`NSView` canvas with CoreGraphics stroke rendering, an NSColorPanel colour picker,
and a line-width slider): reverse-gen the spec from the four VM-verified impls,
instrument to the contracts, rebuild, forward-gen the scenario suite, Tier-2
live-run all four impls. Seventh app through the toolkit (after hello-window,
ui-controls-gallery, pdfkit-viewer, scenekit-viewer, mini-browser, note-editor).

## Context

- **hello-window is the worked template** (k64/k67–k74); **the five richer precedents'
  promoted outcomes** (parent brief outcome sections k77/k78/k79/k80/k81) apply:
  per-impl geometry practice (measure from `agent snapshot --mode layout`, two-launch
  determinism diff, per-impl `run-values-<impl>.rkt` only where layouts diverge —
  measure the share-set, never assume it); the Tier-2-only defect classes (launch
  presentation; ambiguous layout — nested containers arranged in a stack must carry
  intrinsic size); the OCR small-text run-mechanism class (prefer AX-exact via the
  value→AXTitle fold for deterministic strings; 11-pt OCR reads
  adjudicate-by-artifact) + the delayed-truncate residual; the
  **capture-then-parked-click swallow** (k130 — `gv-click` now pre-moves 100px
  off-target, AppSpec `b2c6ffa`; acutely relevant here: every canvas gesture is a
  click/drag straight after a capture poll); settle after `type` before any button
  click (k121); `acceptsFirstMouse` is control-dependent (k112 — after the colour
  panel takes key, the first app-window click DELIVERS for some controls); the
  **NSColorPanel practice** (k112: seed the RGB slider kind per impl at provisioning —
  fresh defaults open Grayscale; the panel's slider space is NOT device-RGB — bind
  recorded actuals after the fold; a no-change field commit does not re-fire the
  action; racket's compact metrics reach inside the picker pane); slider practice
  (k94: bind slider ends at the track's *effective* start/end, knob half-width in;
  never click within ~10px of a resizable window's border); the Tahoe
  notification-banner gotcha.
- Drive via the AppSpec capability workflows:
  `~/Development/AppSpec/capabilities/{reverse-gen,forward-gen,run}/workflow.md`.
  Data homes **here** (ADR-0052; AppSpec ADR-0013): spec/contracts/scenarios under
  `apps/macos/drawing-canvas/`, impl instrumentation under
  `targets/<t>/app-implementations/macos/drawing-canvas/`.
- **App-specific: the first app whose primary content surface is a custom `NSView`** —
  the canvas has no text and (expected) no AX children; unlike scenekit's GPU
  viewport its strokes ARE framebuffer-visible, but OCR-meaningless. Verification
  leans on the **logging contract** (stroke-lifecycle events + tool/colour/width
  state — the scenekit `[scene]` channel mirror) + coordinate-driven mouse drags
  (down → drag path → up; the drag verb worked in scenekit's orbit) + screenshot
  artifacts for the visual bar ([[sample_apps_perfect]]). NSColorPanel is shared
  system chrome — the k112 practice applies wholesale.
- **Decomposed on entry (2026-07-03)** — per-stage children mirroring
  `appspec-note-editor-k81`, materialized lazily (grow the next as each retires;
  stages may merge where they genuinely fit one session):
  1. **`reverse-gen-k131`** — the projection-free spec from the four impls
     (replacing the precursor `docs/spec.md`).
  2. **conformance-data** — logging contract + observable-state doc.
  3. **instrument-builds** — per-impl instrumentation + rebuild ×4.
  4. **forward-gen-suite** — the scenario suite + fixtures + run-values.
  5. **live-run** — Tier-2 live-run all four impls → `docs/run-results.md`.

## Done when

All four impls run the forward-gen suite green in a live VM ([[vm_verify_every_app]] —
CLI smoke never satisfies the done-bar); `docs/run-results.md` records the outcome
table + per-impl findings. Commits name the child handles.

## Notes

Stroke drawing (mouse-down / drag / up), line-width slider, colour-panel drive,
Clear, and the launch empty state are the behavioural core; observable state
captures stroke events, tool state, and screenshot-level canvas appearance — with
every gesture coordinate-driven from measured `run-values` geometry.
