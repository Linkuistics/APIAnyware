# chez-instrument-build-k90

**Kind:** work

## Goal

Instrument the **chez** ui-controls-gallery impl to the k87 contracts and rebuild it as a
launchable `.app`: the events emitter (lifecycle + the four `[controls]` events with the
contract's string quoting), wiring in `ui-controls-gallery.sls` (attach emits in the
existing `selectRadio:`/`sliderChanged:`/`stepperChanged:` handlers + new checkbox
target-action), `build.sh`, and the `#lang app-spec/impl` descriptor.

## Context

- Contracts: `apps/macos/ui-controls-gallery/docs/{logging-contract,observable-state}.md`;
  env/paths `UI_CONTROLS_GALLERY_{EVENTS_LOG,TEST_CONFIG}` →
  `/tmp/ui-controls-gallery/{events.log,test-config.scm}`.
- Templates: `targets/chez/app-implementations/macos/hello-window/` (k69 pattern — check
  whether events are a separate module or inline in the `.sls`; mirror it) and the just-done
  racket sibling `01-DONE-racket-instrument-build-k89` (the reference: emit placement,
  post-state semantics, checkbox switch-toggles-before-action, quoting).
- Names: `UIControlsGallery-chez.app` / `com.linkuistics.ui-controls-gallery-chez`;
  descriptor mirrors the racket one with `(Chez)` naming.
- Chez idiom over R6RS-only forms every time ([[chez_target_idiomatic_not_portable]]).
- Build caveat: `swift build --product` (not `--target`) if the dylib needs a relink.

## Done when

Emitter verified in isolation against the contract matchers; `.app` built via `build.sh`
with the contract bundle id (mirror hello-window's chez build for the recipe + any
PlistBuddy/re-sign dance); descriptor authored; `learnings.md` updated; committed. Live
launch is the Tier-2 leaf's bar (no host GUI launch — [[use_testanyware]]).

## Notes

On retire: grow the next child (gerbil or sbcl — sbcl is the biggest delta: real shared
radio action + new checkbox/slider/stepper target-actions).
