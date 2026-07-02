# instrument-builds-k88

**Kind:** work

## Goal

Instrument all four ui-controls-gallery impls to the k87 contracts and rebuild each as a
launchable `.app`: events.log plumbing + the three lifecycle events + the four `[controls]`
state-change events (`radio-selected` / `checkbox-changed` / `slider-changed` /
`stepper-changed`), per-impl `#lang app-spec/impl` descriptors, bundle IDs
`com.linkuistics.ui-controls-gallery-<impl>`.

## Context

- **Contracts:** `apps/macos/ui-controls-gallery/docs/{logging-contract,observable-state}.md`
  (k87) — the conformance checklist at the end of the logging contract is this leaf's
  work list.
- **Templates:** the hello-window per-target instrument+build children (k68–k71 patterns) —
  each `targets/<t>/app-implementations/macos/hello-window/` has the events module
  (e.g. `events.rkt`), `build.sh` (PlistBuddy `CFBundleIdentifier` dance), and the impl
  descriptor (`hello-window-impl.rkt`) to mirror. Env/paths here:
  `UI_CONTROLS_GALLERY_{EVENTS_LOG,TEST_CONFIG}` → `/tmp/ui-controls-gallery/{events.log,
  test-config.scm}`.
- **Per-impl deltas** (surveyed in k87): racket/chez/gerbil already wire
  `selectRadio:`/`sliderChanged:`/`stepperChanged:` handlers — attach emits there and add
  checkbox wiring; **sbcl** needs new target-action wiring for checkbox/slider/stepper and a
  real shared action on the radio pair (today: constructor `nil`/`""` slots, platform
  sibling-grouping). Instrumentation must not change visible behaviour (contract note).
- Build caveats: `swift build --product` (not `--target`) when a dylib relink is needed;
  gerbil needs the gcc-15 shim if rebuilt.

## Done when

All four impls emit the contract's events (verified by a direct CLI launch tailing
`/tmp/ui-controls-gallery/events.log` — startup, launch line, control events on scripted
interaction where feasible, shutdown on quit); four `.app` bundles built with the contract
bundle IDs; four descriptors authored; committed. Live-VM verification is **not** this
leaf's bar — that is the Tier-2 live-run leaf's (the node's stage 5), mirroring
hello-window's k68–k71 → k73/k74 split.

## Notes

May prove bigger than one session (four impls; sbcl has the most new wiring) — if so,
`leaf-decompose` and do only the first child (likely racket, the reference pattern).
