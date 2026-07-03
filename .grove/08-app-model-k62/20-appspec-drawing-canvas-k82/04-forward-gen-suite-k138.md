# forward-gen-suite-k138

**Kind:** work

## Goal

Forward-gen the drawing-canvas `#lang app-spec` scenario suite + `run-values.rkt`
from the k131 spec + k132 contracts, via the AppSpec forward-gen workflow
(`~/Development/AppSpec/capabilities/forward-gen/workflow.md`) — the note-editor
k129 stage. Suite homes at `apps/macos/drawing-canvas/scenarios/`.

## Context

- **Template:** the note-editor suite (`apps/macos/note-editor/scenarios/` +
  `run-values.rkt`, k129) and the pdfkit k102 exemplar rules (hard vs `recording:`
  cluster split, `;; spec:` per-assertion tracing, coverage-or-gap rule
  `AppSpec/capabilities/forward-gen/validation.md` L1b, two-run consensus for a
  suite gating four impls, presentation-settled `wait-for-log` probe before
  coordinate clicks).
- **Inputs:** `apps/macos/drawing-canvas/docs/{spec,logging-contract,
  observable-state}.md`. The observable-state assertion → observation-path map is
  the suite's skeleton — every spec assertion verb-backed or a documented gap.
- **All four impls are instrumented + built** (k134–k137; the parent brief's
  instrument-builds handoffs): the suite can assume the contract events
  (`[lifecycle] startup`, bare launch line beginning `Drawing Canvas`, the five
  `[canvas]` events with fixed `r` `g` `b` `width` (`points` last) key order,
  `shutdown reason=menu`) and the descriptors at
  `targets/<t>/app-implementations/macos/drawing-canvas/drawing-canvas-impl.rkt`
  (`com.linkuistics.drawing-canvas-<impl>` at `/Applications/DrawingCanvas-<impl>.app`).
  Launch-line remainders diverge by design (`running.` ×3 vs sbcl `opened.`) —
  match the `Drawing Canvas` prefix only. All four impls round once at emit with
  round-half-to-even — integer keys are byte-comparable across impls.
- **The log channel carries the state assertions** (the app-specific reality): the
  canvas is a custom NSView — strokes are framebuffer pixels, OCR-meaningless and
  AX-invisible (spec §12) — so stroke lifecycle and tool state ride the `[canvas]`
  events; rendered appearance rides **screenshot artifacts** (the visual bar,
  [[sample_apps_perfect]] — capture per-scenario artifacts of drawn strokes even
  where nothing pixel-asserts).
- **Contract rules the scenarios must respect:** the stroke events carry the
  stroke's **frozen** tuple — the freeze proof is the §14 core assertion (drive
  colour/width, draw, change tool state, assert the committed tuple equals the
  begin tuple, not the new tool state); `points=1` is deterministic for a
  motionless click (the dot-boundary discriminator); **never bind an exact drag
  count** (`points=\d+`); **never count events** (slider + panel are continuous —
  many lines per drag; match the specific line driven to); `cleared count=<n>` is
  the positive stroke-set-cardinality channel (follow a should-draw-nothing gesture
  with Clear and assert `count=0`; Clear always emits, `count=0` on empty);
  `color-changed` success-path only; absence never asserted directly; silent
  no-ops (panel dismissal, toolbar-press strokes) emit nothing.
- **Colour values: bind recorded actuals** (the k112 rule — the panel's slider
  space is NOT device-RGB: typed 0/128/255 landed as device `(0,150,255)` after the
  §7.4 fold, byte-identical across all four impls; a no-change field commit does
  not re-fire the action). Width likewise: a click-driven slider value is bound
  from the recorded actual (`width-changed width=11` shape).
- **Driver guidance from the precedents** (acutely relevant — every canvas gesture
  is a click/drag straight after a capture poll): the **capture-then-parked-click
  swallow** is fixed runner-side (k130, AppSpec `b2c6ffa` — `gv-click` pre-moves
  100px; suites inherit); strokes need the **drag verb** (a bare `input move`
  between down/up releases the VNC button mask → no `mouseDragged:` — the sbcl
  VM-verify lesson; the drag verb worked for scenekit's orbit); **NSColorPanel
  practice** (k112): seed the RGB slider kind per impl at provisioning (fresh
  defaults open Grayscale), panels open at default frame (0,605) 250×397, racket's
  compact metrics reach inside the picker pane — measure panel geometry per impl
  from the OPEN panel; `acceptsFirstMouse` is control-dependent (k112) — after the
  panel takes key, the first app-window click may DELIVER (scenekit 07's single-
  click choreography precedent); **settle after `type` before any button click**
  (k121, for panel field entry); slider practice (k94): bind slider ends at the
  track's *effective* start/end, knob half-width in; never click within ~10px of a
  resizable window's border; prefer AX-exact over whole-screen OCR for
  deterministic strings (the toolbar's `Color…`/`Clear` titles; 11-pt OCR reads
  adjudicate-by-artifact); the Tahoe notification-banner gotcha.
- **Geometry:** measure per impl from `agent snapshot --mode layout`; two-launch
  determinism diff before binding values; per-impl `run-values-<impl>.rkt` only
  where layouts diverge (precedents split both ways — pdfkit/mini-browser/
  note-editor: racket alone; gallery: sbcl too; scenekit: sbcl toolbar 4px off —
  **measure the share-set, never assume it**). Canvas stroke coordinates are
  driver-chosen — pick well-inside-canvas paths (respect the border band) and keep
  them per-impl-relative to the measured canvas frame.
- **Fixtures:** none (no files, no network) — the persistence-story machinery
  (cleanup obligations, Cmd-Shift-G) does not apply; between-scenario state is
  in-process only and resets with the relaunch.

## Done when

The suite + run-values are committed under `apps/macos/drawing-canvas/`, validated
per the forward-gen workflow (coverage-or-gap complete, two-run consensus plan
stated); the live-run leaf (grown next) executes it. Commits name
`forward-gen-suite-k138`.

## Notes

The freeze proof is this app's signature scenario shape: colour/width changes
between gestures must never retroactively alter a committed stroke's tuple —
drive colour → draw → drive width → draw → assert each `stroke-committed` against
its own `stroke-begun`, and close with `cleared count=2`. Continuous-delivery
volume through the driver (slider drags, panel drags) is itself to-confirm in-VM
(the spec flags both) — suites match driven-to lines, `recording:` anything
volume-shaped.
