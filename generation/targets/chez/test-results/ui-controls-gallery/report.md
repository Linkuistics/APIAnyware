# UI Controls Gallery — Chez Test Report

**Date:** 2026-05-29
**Status:** Pass

## Build & launch

- Dev-host bundle build: `cargo run --release --example bundle_app -p
  apianyware-macos-bundle-chez -- ui-controls-gallery` — **154.8 s**
  (dominated by chez-compiling the 838 staged `.sls` libraries to `.so`).
- Bundle size: **103 MB** (precompile path from leaf `105`).
- In-VM cold launch (window visible after `open -n`): **~3 s**, in the
  1-3 s band the leaf brief predicted for the precompile flow. Compared
  with the ~75 s hello-window pre-precompile baseline, the win holds
  GUI-side, not just CLI.

## Steps Completed
- [x] Window appears with title "UI Controls Gallery", 500×632 content,
      centred, native scroller.
- [x] Empty state: all eight sections present — Text Fields, Buttons,
      Sliders, Popup & Combo, Date Picker, Progress Indicators, Stepper,
      Color & Image (screenshot-001-launch-top.png /
      screenshot-006-scroll-bottom.png).
- [x] Push button "Click Me" rendered with rounded bezel.
- [x] Checkbox "Enable Feature" rendered, toggles on click (AX value 0/1).
- [x] **Radio mutual exclusion via `selectRadio:` delegate.** Option A
      starts selected; clicking Option B clears A and selects B. AX
      reports value=1 on the active radio, 0 on the others
      (screenshot-003-radio-mutex.png).
- [x] **Slider drag → live label via `sliderChanged:` delegate.** Drag
      from x=502 to x=608 over the 482-px track: slider AX value advances
      to 73.04; "Value: 50" label updates to "Value: 73" in real time
      (continuous: #t honoured) (screenshot-002-slider-dragged.png).
- [x] Popup "Small" renders with dropdown arrow. (Combo box renders as
      an empty editable field with dropdown arrow — same as the racket
      bar; the `add-item-with-object-value!` calls populate the menu but
      don't set an initial visible value. Parity, not a regression.)
- [x] Date picker shows current date/time (`5/28/2026, 2:43:07 PM` —
      VM clock) in `TextFieldAndStepper` style with year/month/day +
      hour/minute/second elements (screenshot-004-date-picker.png).
- [x] Progress bar at 65% (determinate), spinner animating (indeterminate
      visible mid-frame in screenshot-006).
- [x] **Stepper +/- via `stepperChanged:` delegate.** Two up-clicks on the
      stepper's increment half: AX value advances 5 → 7; "Value: 5" label
      updates to "Value: 7" live (continuous: #t honoured)
      (screenshot-005-stepper.png).
- [x] Color well shows system-blue.
- [x] `NSImage imageNamed:"NSActionTemplate"` resolves and renders
      (chat-bubble glyph visible at bottom of screenshot-006).
- [x] Scrolling: NSScrollView auto-scrolls to bottom on launch (parity
      with racket port; NSStackView flipped-document side-effect). Wheel
      scroll works through full content range.
- [x] Cmd+Q exits cleanly (process gone, no stderr).

## Activity Monitor — RSS stability (30 s)

In-VM `ps aux` for the chez process, sampled every 5 s during idle:

```
t=5s:  525.781 MB
t=10s: 525.781 MB
t=15s: 525.781 MB
t=20s: 525.781 MB
t=25s: 525.781 MB
t=30s: 525.797 MB
```

16 KB drift over 30 s. No unbounded growth. The baseline is well below
hello-window's 1.22 GB because `.sls`→`.so` precompile (leaf `105`)
moves the chez compile cost out of the bundle's launch, and the loaded
form is smaller than the pre-precompile in-memory representation.

## Issues Found

None. Three delegates (`selectRadio:`, `sliderChanged:`, `stepperChanged:`)
all fire correctly via `(make-delegate (list-of-specs))` — chez's
synchronous-delegate runtime piece works end-to-end on rung 2 of the
feature ladder.

## Notes

- Menu-bar app name reads "chez" instead of "UI Controls Gallery" — the
  stub-launcher `execv`s into `/opt/homebrew/bin/chez`. Same as
  hello-window and the racket port; runtime/stub-launcher concern, not
  per-app, out of this node's scope.
- VM provisioning: golden image still lacks chez; `brew install
  chezscheme` once before launch (5.5 MB bottle, ~3 s). Pre-installing
  in the golden image remains an open candidate.
- VM display was 1024×768 (the `--display 1280x800` flag at `vm start`
  appears not to take effect on the tahoe golden image). 500-px-wide
  window fit cleanly.
- Auto-scroll-to-bottom on launch is parity with racket — flipped-doc
  side-effect of NSStackView inside NSScrollView with no explicit
  `scrollToTop`. If polish is wanted, the fix is a one-liner in either
  the app or the runtime's `cocoa.sls` helpers.
