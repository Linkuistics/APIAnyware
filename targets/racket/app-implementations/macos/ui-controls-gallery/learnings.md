# ui-controls-gallery x racket

**2026-03-31:**
- 🔴 Duplicate emission bug: emitter was emitting some symbols twice; fixed
- 🔴 Typedef alias FFI type mapping: unrecognized aliases defaulted to _uint64; fixed
- 🟡 All 8 sections render correctly with native appearance
- 🟡 Scrolling works

**2026-06-02 (Racket 9.2 + ffi2, native dispatch):**
- 🟢 Re-verified after the ffi2 migration. NSPopUpButton, combo box, date picker
  (live time + stepper), determinate progress bar (65%), indeterminate spinner,
  stepper (Value: 5), and color well all render natively. No regression vs the
  2026-03-31 baseline. TestAnyware VM (macOS 26.3).

**2026-07-02 (AppSpec instrument + build, leaf k89):**
- 🟢 Instrumented to the k87 logging contract
  (`apps/macos/ui-controls-gallery/docs/logging-contract.md`): new `events.rkt`
  (hello-window emitter + the four `[controls]` state-change events + the contract's
  string quoting for `radio-selected option="…"`), lifecycle wiring mirroring
  hello-window (startup before construction; `applicationWillTerminate:` delegate →
  `reason=menu`; `uncaught-exception-handler` → `signal`/`error`; dual-emitted launch
  line; `UI_CONTROLS_GALLERY_TEST_CONFIG` honoured as a no-op).
- Control emits attach to the three existing handlers (`selectRadio:` post-exclusion
  via `nsbutton-title` + `nsstring-utf8-string`; `sliderChanged:` double→nearest-int;
  `stepperChanged:` integral) — no visible-behaviour change. The checkbox got its
  first target-action (`checkboxChanged:`): AppKit toggles a switch button's state
  *before* the action fires, so `(= (nsbutton-state sender) 1)` is the post-toggle
  state the contract wants.
- 🟢 `events.rkt` verified in isolation against the contract matchers (incl. quoting
  edge + startup-first ordering). Built self-contained via new `build.sh`
  (hello-window k76 recipe): bundle → `UIControlsGallery-racket.app`,
  `CFBundleIdentifier=com.linkuistics.ui-controls-gallery-racket`, re-sign,
  self-containment gate. Descriptor `ui-controls-gallery-impl.rkt` authored. Live
  launch + control interaction is the Tier-2 live-run leaf's bar (VM).
