# live-run-k139

**Kind:** work

## Goal

Tier-2 **live-run** the drawing-canvas `#lang app-spec` suite (k138) against all
four impls in a macOS VM, adjudicate the outcomes, and record the cross-impl
verdict table + per-impl findings in `apps/macos/drawing-canvas/docs/run-results.md`.
The node's done-bar ([[vm_verify_every_app]] — CLI smoke never satisfies it);
seventh app through the toolkit, last stage of `appspec-drawing-canvas-k82`.

## Context

- **Drive via the AppSpec run workflow** (`~/Development/AppSpec/capabilities/run/
  workflow.md`); the runner *consumes* the downstream suite across the boundary
  (`runner/main.rkt --impl <descriptor> --run-values <config> --vm <id> run
  <scenarios-dir>` pointed at this worktree's `apps/macos/drawing-canvas/scenarios/`
  — ADR-0013, it never copies). App data (refined `run-values.rkt`,
  `run-results.md`) lands **here**; only run-mechanism toolkit fixes are AppSpec-side.
- **Inputs, all in place:** the 17-scenario suite + `run-values.rkt` (k138); the
  four built `.app`s (`instrument-builds-k133` — racket 86M, chez 5.1M, gerbil
  58M, sbcl 83M; descriptors at `targets/<t>/app-implementations/macos/
  drawing-canvas/drawing-canvas-impl.rkt`, `com.linkuistics.drawing-canvas-<impl>`
  at `/Applications/DrawingCanvas-<impl>.app`, events under `/tmp/drawing-canvas/`);
  the k131 spec + k132 contracts.
- **The AppSpec toolkit gained `drag-from-to`** (held-button drag over `input drag`;
  `~/Development/AppSpec` 49a6340) — the suite's 06/12 use it. Confirm the built
  AppSpec runner picks it up; it is the gap-1/gap-4 vocabulary-extension precedent.
- **run-values are PROVISIONAL** (k138 — the k120 spec-derived projection over
  scenekit's same-shape geometry, NOT live-measured). **First task: re-measure per
  impl** from `agent snapshot --mode layout` (two-launch determinism diff before
  binding), split per-impl `run-values-<impl>.rkt` siblings only where layouts
  diverge — **measure the share-set, never assume it** (precedents split both ways:
  pdfkit/mini-browser/note-editor racket-alone; gallery sbcl too; scenekit sbcl
  toolbar 4px off + racket's compact metrics reach INSIDE the shared NSColorPanel
  picker pane). Re-tune `slider-track-max-*` until the driven `width-changed` value
  IS the asserted maximum 20 (coordinate is the free variable, asserted value the
  rule — k94 end-click practice). Canvas stroke coordinates are driver-chosen —
  keep them well inside the measured canvas frame, respect the ~10px resize band.
- **NSColorPanel provisioning (k112, applies wholesale):** seed each impl's panel to
  the **RGB Sliders** kind at provisioning (fresh defaults open Grayscale → the
  09/10/11 `Blue` gate times out); remembered per-app, survives relaunch; re-seed
  after any VM re-clone. Panels open at default frame (0,605) 250×397. The panel's
  slider space is NOT device-RGB — the suite already binds the k112 fold
  `r=0 g=150 b=255`; a no-change field commit does not re-fire the action.
- **App-specific reality — the log IS the state channel:** the canvas is a custom
  NSView (strokes are framebuffer pixels, OCR-meaningless + AX-invisible, spec §12),
  so stroke lifecycle + tool state ride the `[canvas]` events and rendered
  appearance rides **screenshot artifacts** (the visual bar,
  [[sample_apps_perfect]] — capture per-scenario artifacts of drawn strokes;
  confirm dots are round, drags smooth/connected, recolour applies to new strokes
  only, Clear blanks). Every canvas gesture is a click/drag straight after a capture
  poll — `gv-click`'s 100px pre-move (k130) and `gv-drag`'s mirror are load-bearing.
- **Known run-mechanism classes to adjudicate against** (never patch the suite):
  the k103 OCR small-text class (title-bar garble on racket's compact metrics —
  the AX window title is the firm channel); the k94 delayed-truncate residual
  (re-run solo); the capture-then-parked-click swallow (fixed k130); SIGTERM
  ignored under `nsapplication-run` (`pkill -9`); the Tahoe notification-banner
  gotcha. A `recording:` red is a spec-quality finding (D4), adjudicated, not a
  suite bug. **To-confirm the suite flags for live-run:** continuous slider/panel
  delivery volume; the panel-open snapshot scope (key-window vs all — the 09
  `Colors`-only assertion); the re-key-via-title-bar choreography (10/11); the drag
  point-count shape (a `points=1` on 06 = degenerate drag, a driver finding).

## Done when

All four impls run the k138 suite in a live VM with every red adjudicated (impl
defect, spec finding, or run-mechanism class — each named);
`apps/macos/drawing-canvas/docs/run-results.md` records the outcome table + per-impl
findings + the visual-bar artifact review; refined per-impl `run-values*.rkt`
committed. Any run-mechanism toolkit fix the run forces is committed AppSpec-side
with a note here. Commits name `live-run-k139`.

## Notes

The freeze proof (10) + the width freeze (07) are this app's signature — verify the
committed tuple never retroactively tracks a later tool change, from the log alone.
The visual bar ([[sample_apps_perfect]]) is met by artifact review since no pixel
verb exists: a human-eye pass on drawn strokes (colour, width, roundness,
smoothness, blank-after-Clear) recorded in run-results.md.
