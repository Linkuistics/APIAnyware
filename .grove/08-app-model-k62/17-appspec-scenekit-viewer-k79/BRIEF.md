# appspec-scenekit-viewer-k79 — brief

## Goal

The full AppSpec cycle for **scenekit-viewer** (the SceneKit 3D scene viewer):
reverse-gen the spec from the four VM-verified impls, instrument to the contracts,
rebuild, forward-gen the scenario suite, Tier-2 live-run all four impls. Fourth app
through the toolkit (after hello-window, ui-controls-gallery, pdfkit-viewer).

## Context

- **hello-window is the worked template** (k64/k67–k74); **ui-controls-gallery
  (`appspec-ui-controls-gallery-k77`) and pdfkit-viewer (`appspec-pdfkit-viewer-k78`)
  are the richer precedents** — apply their promoted outcomes (parent brief
  "ui-controls-gallery outcomes" + "pdfkit-viewer outcomes"): per-impl geometry
  practice (measure from `agent snapshot --mode layout`, two-launch determinism diff,
  per-impl `run-values-<impl>.rkt` only where layouts diverge); the Tier-2-only defect
  classes (launch presentation; ambiguous layout); the OCR small-text run-mechanism
  class + delayed-truncate residual (adjudicate by artifact review / solo re-run,
  never by patching the suite); the Tahoe notification-banner gotcha.
- Drive via the AppSpec capability workflows:
  `~/Development/AppSpec/capabilities/{reverse-gen,forward-gen,run}/workflow.md`.
  Data homes **here** (ADR-0052; AppSpec ADR-0013): spec/contracts/scenarios under
  `apps/macos/scenekit-viewer/`, impl instrumentation under
  `targets/<t>/app-implementations/macos/scenekit-viewer/`.
- **App-specific: GPU/3D contents are not AX-observable.** The SCNView renders in the
  VM but its *contents* (geometry, colour, spin) are invisible to the AX tree —
  expectations must lean on the logging contract + window/AX structure (the
  scene-loaded log line, the SCNView's presence, the geometry popup's AX value), not
  rendered pixels. A finding about what 3D behaviour *is* verifiable in-VM is itself
  spec-quality output. The app also opens the **shared NSColorPanel** (a second
  window) — its drive/observe story is a suite-design concern like pdfkit's open
  panel.
- **Decomposed on entry (2026-07-02)** — per-stage children mirroring
  `appspec-pdfkit-viewer-k78`, materialized lazily (grow the next as each retires;
  stages may merge where they genuinely fit one session):
  1. **`reverse-gen-k104`** — the projection-free spec from the four impls
     (replacing the precursor `docs/spec.md`), via the AppSpec reverse-gen workflow.
  2. **conformance-data** — `logging-contract.md` + `observable-state.md`.
  3. **instrument-builds** — per-impl events emitter + `.app` build (likely a node,
     one child per impl).
  4. **forward-gen-suite** — the scenario suite + `run-values.rkt`.
  5. **live-run** — Tier-2 live-run all four impls → `docs/run-results.md`
     (closes this node's Done-when).

## Done when

All four impls run the forward-gen suite green in a live VM ([[vm_verify_every_app]] —
CLI smoke never satisfies the done-bar); `docs/run-results.md` records the outcome
table + per-impl findings. Commits name the child handles.

## Notes

Geometry-swap (popup), colour-change (NSColorPanel), and camera-control are the
behavioural core; observable state captures the popup selection + contract log
events, not rendered pixels.
