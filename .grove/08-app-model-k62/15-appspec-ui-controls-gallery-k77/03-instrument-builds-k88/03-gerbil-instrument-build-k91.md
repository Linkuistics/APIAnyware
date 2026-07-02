# gerbil-instrument-build-k91

**Kind:** work

## Goal

Instrument the **gerbil** ui-controls-gallery impl to the k87 contracts and rebuild it as a
launchable `.app`: the events emitter (lifecycle + the four `[controls]` events with the
contract's string quoting), wiring in `ui-controls-gallery.ss` (attach emits in the existing
`selectRadio:`/`sliderChanged:`/`stepperChanged:` handlers + new checkbox target-action),
`build.sh`, and the `#lang app-spec/impl` descriptor.

## Context

- Contracts: `apps/macos/ui-controls-gallery/docs/{logging-contract,observable-state}.md`;
  env/paths `UI_CONTROLS_GALLERY_{EVENTS_LOG,TEST_CONFIG}` →
  `/tmp/ui-controls-gallery/{events.log,test-config.scm}`.
- Templates: `targets/gerbil/app-implementations/macos/hello-window/` (k70 pattern — check
  where its emitter lives and mirror it) and the done siblings
  `01-DONE-racket-instrument-build-k89` / `02-DONE-chez-instrument-build-k90` (emit
  placement, post-state semantics, checkbox switch-toggles-before-action, quoting; the chez
  leaf verified its emitter in isolation by extracting the emitter block and driving it
  against the contract matchers — mirror that if practical for gerbil).
- Names: `UIControlsGallery-gerbil.app` / `com.linkuistics.ui-controls-gallery-gerbil`;
  descriptor mirrors the chez one with `(Gerbil)` naming.
- Gotchas: gcc-15 shim if the binding rebuilds ([[gerbil_gcc15_drift]] —
  `/tmp/aw-gcc15-shim`); never rely on a bare `values` identity token in generated
  bindings context ([[gerbil_values_coerce_shadow]]); main-thread bounce (ADR-0022).
- Build caveat: `swift build --product` (not `--target`) if the dylib needs a relink.

## Done when

Emitter verified in isolation against the contract matchers; `.app` built via `build.sh`
with the contract bundle id (mirror hello-window's gerbil build for the recipe + any
PlistBuddy/re-sign dance); descriptor authored; `learnings.md` updated; committed. Live
launch is the Tier-2 leaf's bar (no host GUI launch — [[use_testanyware]]).

## Notes

On retire: grow the last child (sbcl — the biggest delta: real shared radio action + new
checkbox/slider/stepper target-actions; `events.lisp` template exists).
