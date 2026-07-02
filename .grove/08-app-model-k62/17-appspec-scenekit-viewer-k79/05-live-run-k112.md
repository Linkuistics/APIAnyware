# live-run-k112

**Kind:** work

## Goal

Tier-2 live-run the scenekit-viewer k111 scenario suite against **all four impls**
(racket/chez/gerbil/sbcl) in a live macOS VM via the AppSpec run capability
(`~/Development/AppSpec/capabilities/run/workflow.md`; runner invocation per the
hello-window record: `runner/main.rkt --impl <descriptor> --run-values <config>
--vm <id> run <scenarios-dir>`). Produce `apps/macos/scenekit-viewer/docs/
run-results.md` (outcome table + per-impl findings) — the pdfkit k103 stage.
Closes the k79 node's Done-when ([[vm_verify_every_app]] — CLI smoke never
satisfies it).

## Context

- **Suite:** `apps/macos/scenekit-viewer/scenarios/` — 10 scenarios: 2 hard
  (01 steady-state cluster, 09 Command-Q) + 8 `recording:` (02 picker value-fold,
  03 catalogue menu, 04 swap shape-only, 05 panel opens, 06 wheel-click recolour,
  07 colour-persists-across-swap — the key behaviour — 08 dismiss-changes-nothing,
  10 close-button). Recording semantics: a PASS confirms (reverse-gen may drop the
  `(to confirm in-VM)` markers); a FAILURE is a spec-quality / driver finding
  adjudicated by artifact review — never patch the suite to hide it.
- **Builds + descriptors (k106):** `build/SceneKitViewer-<impl>.app`
  (`com.linkuistics.scenekit-viewer-<impl>`), descriptors at
  `targets/<t>/app-implementations/macos/scenekit-viewer/scenekit-viewer-impl.rkt`;
  install to `/Applications/SceneKitViewer-<impl>.app` (the hello-window recipe;
  sbcl libzstd + racket self-containment already fixed — k75/k76).
- **`run-values.rkt` is PROVISIONAL — re-measure every value first** (the k77
  practice): `agent snapshot --mode layout` per impl, two-launch determinism diff
  before binding, per-impl `run-values-<impl>.rkt` only where layouts genuinely
  diverge (pdfkit: chez+gerbil+sbcl shared, racket diverged; the gallery's
  share-set differed — measure, never assume). The **panel-relative keys are
  placeholders**: bind `panel-*`/`wheel-point-*` from the open panel's AX snapshot
  at provisioning (NSColorPanel position/mode/slider-kind are system-remembered
  per-user); `sphere-item-*` from the OPEN picker menu's AX snapshot with `Cube`
  current.
- **Degrade paths (from the k111 generation notes, pre-agreed):** 06 wheel-click
  delivery failing = the documented no-drag-verb finding (colour driving then
  rests on 07/08's typed fields); 07/08's exact `r=0 g=128 b=255` matchers, if the
  panel's slider→device-RGB conversion shifts components, degrade to **recorded
  actuals** (never drive white — a shape-level persistence matcher cannot catch a
  white-reset); the `wait-for-ocr "Blue"` gate timing out = a non-RGB slider-kind
  default (seed VM defaults or add a kind-selection step at regeneration).
- **Rendered-scene appearance is live-run's by-eye bar** (the app's headline gap
  class): lit red cube spinning, swap visuals, live recolour, orbit/zoom — record
  in `run-results.md` ([[sample_apps_perfect]]).
- **Known run-mechanism residuals** (adjudicate by artifact review / solo re-run,
  never by patching): OCR small-text garble (pdfkit k103 class — title-bar and
  panel chrome text are candidates here), the delayed-truncate empty-log red after
  a failure (k94), the Tahoe "See what's new" notification banner (dismiss by
  hover + close-X). The sbcl launch line reads `SceneKit Viewer opened. Quit with
  Cmd-Q.` by design — prefix-conformant.
- **Driver guidance the suite encodes** (spec §13): AX-reported coordinates only;
  after the panel takes key, the first app-window click only re-activates (07
  clicks the picker twice); 08 expects first-click delivery post-dismissal — a
  wrong inference there times out on its Torus gate and is a driver-guidance
  finding, not a suite bug.

## Done when

All four impls have run the full suite in a live VM; every red is adjudicated
(impl defect / spec finding / run-mechanism residual); measured run-values
(+ per-impl siblings if needed) and `docs/run-results.md` (outcome table,
per-impl findings, by-eye visual verdicts, firmed AX rows) are committed.
This closes `appspec-scenekit-viewer-k79`'s Done-when — expect the node-done
cascade question on retire.

## Notes

Window geometry is 640×480 content across all four impls but toolbar layouts may
diverge (racket's tighter control metrics pattern). The `[scene]` events are
post-state, so a log hit guarantees app state even if the GPU repaint lags.
