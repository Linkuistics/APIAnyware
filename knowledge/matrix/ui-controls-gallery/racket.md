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
