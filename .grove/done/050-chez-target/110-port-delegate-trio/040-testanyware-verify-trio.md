# 040-testanyware-verify-trio

**Kind:** work

## Goal
Verify chez `ui-controls-gallery`, `scenekit-viewer`, and
`pdfkit-viewer` in the VM via TestAnyware. Per-app: launch the
bundle, exercise each interactive element (target-actions,
delegate-driven updates, scrolling), take screenshots, write a
`report.md`. Three reports, one VM session, one focused commit.

This is the gate that retires the parent node `110-port-delegate-trio/`:
per the chez design spec §7, "the work-leaf doesn't retire until the
app's TestAnyware run is green", applied to each of the three apps.

## Context
- Three chez bundles produced by leaves `010`-`030` of this node.
  Re-bundle each before running so the latest emitter / runtime
  changes are in flight.
- Per-app test strategy: `knowledge/apps/<script>/test-strategy.md`
  (matches racket's). If missing, copy from the racket port and
  adapt for chez differences (menu-bar app-name reads `chez`,
  no auto-quit-on-window-close — same as racket parity from
  hello-window's report).
- TestAnyware harness: same as hello-window's leaf `040`-verify.
  See `.grove/done/050-chez-target/100-port-hello-window/040-testanyware-verify.md`
  for the recipe.

## Done when
- `generation/targets/chez/test-results/ui-controls-gallery/`
  contains: `report.md` (status pass/pass-with-fixes), screenshots
  covering empty state, slider mid-drag with live-value label
  updating, radio-button mutual-exclusion state, stepper interaction,
  date-picker interaction, scroll-to-bottom view of all sections.
- `generation/targets/chez/test-results/scenekit-viewer/` contains:
  `report.md`, screenshots covering scene render, any rotation /
  delegate-driven animation, mouse-driven interaction if applicable.
- `generation/targets/chez/test-results/pdfkit-viewer/` contains:
  `report.md`, screenshots covering the loaded PDF, page-change
  delegate state, annotation interaction if present.
- Each report includes the dev-host bundle build time, the in-VM
  cold launch time (precompile is in flight via leaf `105` —
  expect ~1-2s), and Activity Monitor RSS stability over a 30s
  observation window.
- All three apps: indistinguishable from the racket bar at the
  pixel level (modulo menu-bar app name, which is `chez` for both
  targets per the hello-window precedent).

## Notes
- A delegate-related bug surfacing in ONE app means a runtime fix
  in `runtime/dispatch.sls` and a re-verification of ALL THREE.
  Plan the VM session to keep all three bundles fresh.
- VM provisioning: macOS golden image does not ship Chez Scheme;
  `brew install chezscheme` once per VM clone before launching
  the bundle (parity baseline from hello-window's report).
- If any per-app bar requires a non-trivial fix (emitter regression,
  runtime gap, design oversight), split the work into a follow-up
  leaf in this node before retiring the verify — same pattern as
  hello-window's `100/040` surfacing the bundled-dylib bug.

## Pointers
- VM-verify recipe: `.grove/done/050-chez-target/100-port-hello-window/040-testanyware-verify.md`.
- Racket parity references: `generation/targets/racket/test-results/<script>/`
  (if present), or the racket bundle running side-by-side in the
  VM as the visual diff baseline.
