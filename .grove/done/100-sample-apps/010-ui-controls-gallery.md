# 010-ui-controls-gallery

**Kind:** work

## Goal

Port `generation/targets/chez/apps/ui-controls-gallery/` to the gerbil target —
a scrollable window showcasing every major AppKit control — then bundle
(`bundle-gerbil`) and **VM-verify via TestAnyware** that it renders visually
perfectly (all 8 sections, live slider/stepper/radio callbacks).

## Context

First app after hello-window (070); re-establishes the per-app build/bundle
recipe at scale. Controls exercised: NSTextField/NSSecureTextField, NSButton
(push/checkbox/radio), NSSlider, NSPopUpButton, NSComboBox, NSDatePicker,
NSProgressIndicator, NSStepper, NSColorWell, NSImageView, laid out in an
NSStackView inside an NSScrollView.

Gerbil-specific differences from the chez source:
- Strings are explicit: `(string->nsstring "...")`, not raw Scheme strings.
- Geometry constructors are `make-rect`/`make-size` (per hello-window), not
  `make-nsrect`/`make-nssize` — confirm against generated bindings.
- Target-action callbacks (radio select, slider, stepper) use the gerbil
  delegate/block mechanism from 050/020 + 080 — confirm the API surface before
  porting (this is the riskiest part; chez's `make-delegate`/`delegate-ptr` has
  a gerbil analogue to identify).
- Inherited setters dispatch through the declaring superclass proc core.

## Done when

- `ui-controls-gallery.ss` + `build.sh` mirror the chez app one control at a
  time; binding-library closure pre-compiled; exe links clean.
- Any missing control bindings regenerated into `generation/targets/gerbil/lib`.
- Bundled `.app` (id `com.linkuistics.*`) **VM-verified** — all sections visible,
  scroll works, slider/stepper/radio update their value labels live.

## Notes

If callback wiring proves large, decompose into port-leaf + verify-leaf. Use the
**bottle** toolchain. Compare against chez/racket screenshots for visual parity.
