# live-run-k94

**Kind:** work

## Goal

Tier-2 live-run of the ui-controls-gallery forward-gen suite (k93) against all four
built impls (k89–k92) in a live macOS VM, via the AppSpec run capability
(`~/Development/AppSpec/capabilities/run/workflow.md`) — the hello-window k73/k74
stage. Outcome table + per-impl findings recorded in
`apps/macos/ui-controls-gallery/docs/run-results.md`.

## Context

- **The suite** (`apps/macos/ui-controls-gallery/scenarios/`, 11 scenarios): `01`
  hard steady-state cluster; `02`/`03` pure-observation `recording:` (placeholders
  OCR; uncertain AXDateField/AXBusyIndicator roles); `04`–`08` `recording:`
  interactions riding the k87 `[controls]` events; `09` hard §12 push-button
  negative; `10` hard Command-Q; `11` `recording:` close-button. Drive per impl:
  `runner/main.rkt --impl <descriptor> --run-values <config> --vm <id> run
  <scenarios-dir>` (descriptors at
  `targets/<t>/app-implementations/macos/ui-controls-gallery/ui-controls-gallery-impl.rkt`).
- **Coordinates must be measured FIRST.** `run-values.rkt`'s 18 coordinate keys are
  provisional ZEROS. Unlike hello-window, window size + layout are impl-varying —
  measure each control's centre per impl from `agent snapshot --mode layout`
  (AX position+size → centre, framebuffer px), and bind per-impl run-values files
  if the four galleries diverge (`--run-values` binds per invocation; the
  descriptor wins only on `bundle-id`). Scenarios 01/02/03/10 need no coordinates
  and can run before measurement.
- **Install:** built `.app`s at `targets/<t>/app-implementations/macos/
  ui-controls-gallery/build/UIControlsGallery-<impl>.app` → VM `/Applications/`
  (chunked upload; hello-window k73 recipe). racket needs the VM Racket runtime +
  `ffi2-lib` + `raco make` precompile (k74 recipe) unless already provisioned;
  sbcl/chez/gerbil `.app`s travel alone (k92: sbcl uses the production bundler —
  vendored libzstd + libAPIAnywareSbcl).
- **`recording:` semantics (D4):** a pass CONFIRMS (reverse-gen may drop the
  to-confirm marker); a failure is a spec-quality finding for `run-results.md` —
  notably `03` (role-table correction: date picker may be a composite group,
  spinner may be AXProgressIndicator) and `02` (greyed-placeholder OCR
  reliability). Run-tuning knobs are legitimate: in-set `(wait …)` settles,
  click pacing in `05`/`08`, the `07` track-click assumption.
- **Cross-impl variance already encoded** (k88 outcomes): sbcl checkbox launches
  ON (the flip assertion absorbs it); sbcl has radios A/B only; both radio
  exclusion realizations conform. Graphical states (spinner animating, progress
  fill, well blue, system image) have no OCR/AX read — check visually and record
  in `run-results.md` ([[sample_apps_perfect]]).

## Done when

All four impls run the suite green in a live VM (recording failures adjudicated as
findings, not suite bugs) — [[vm_verify_every_app]]; measured coordinates committed
into `run-values.rkt` (or per-impl configs); `docs/run-results.md` records the
outcome table + per-impl findings + the visual check. This closes the k77 brief's
Done-when.

## Notes

- Toolkit defects belong AppSpec-side (ADR-0013 boundary): if the run seam breaks
  (as hello-window's first live run did — running-app?/quit-impl!/log-tail), record
  here, fix in `~/Development/AppSpec`, never fork the runner downstream.
- The k77 node retires when this leaf lands green — promote durable findings
  (per-impl geometry practice, role-table corrections) up to the k62 brief for the
  six remaining apps (k78–k83).
