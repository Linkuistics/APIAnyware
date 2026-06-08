# UI Controls Gallery — Gerbil Test Report

**Date:** 2026-06-08
**Status:** PASS — second gerbil sample app; first to exercise the full control
set and the `make-delegate` target-action bridge inside a bundled standalone.

Done-bar for grove leaf `100-sample-apps/010-ui-controls-gallery`: the
self-contained `.app` built by `bundle-gerbil` **draws every major AppKit
control** in a macOS VM with **no Gerbil installed**, and the live target-action
callbacks fire — CLI smoke does not satisfy this ([[feedback-vm-verify-every-app]]).

## Build

`cargo run --example bundle_app -p apianyware-macos-bundle-gerbil -- ui-controls-gallery`.
Output: `generation/targets/gerbil/apps/ui-controls-gallery/build/UI Controls Gallery.app`,
bundle id `com.linkuistics.UIControlsGallery`, CFBundleName "UI Controls Gallery",
codesigned. `otool -L Contents/MacOS/ui-controls-gallery` is dylib-clean — only
system libs/frameworks (AppKit, Foundation) plus the vendored
`@executable_path/../Frameworks/libssl.3.dylib` + `libcrypto.3.dylib` (ADR-0009);
the Gerbil/Gambit runtime is statically embedded (`gxc -exe` links `libgambit.a`).

Build time ~9.6 min (generics 235s · facade 12s · 27 class modules `-O` 80s ·
`-exe -O` link 248s). Note: pre-seeding the per-app `gerbil-cache` from
hello-window's warm cache did **not** avoid the generics recompile — gerbil's
`GERBIL_PATH` artifacts did not cache-hit across the app's output dir, so each
app currently pays the ~4 min sharded-generics cost (within the ADR-0023 budget).
A genuinely shared binding-library cache across apps would amortise this; out of
scope here, noted for the knowledge node.

## VM verify (no-Gerbil bar)

Golden `testanyware-golden-macos-tahoe`, arm64, macOS 26 (1024×768). Tarball
(9.9 MB) uploaded, `xattr -dr com.apple.quarantine`, launched via `open -n`. No
runtime errors in the captured stdout/stderr.

Results:
- [x] Window draws, titled **"UI Controls Gallery"**, 500-wide resizable content,
      centred, with a working vertical scroller (`Titled|Closable|Miniaturizable|Resizable`).
- [x] **All 8 sections render** with correct controls and initial state
      (`ui-controls-gallery-top.png`, `ui-controls-gallery-bottom.png`):
  - Text Fields — `NSTextField` placeholder "Type here…", `NSSecureTextField` "Password".
  - Buttons — rounded "Click Me" push button, "Enable Feature" checkbox,
    three-way radio group (Option A initially selected).
  - Sliders — continuous `NSSlider` 0–100 at 50, with a live "Value: 50" label.
  - Popup & Combo — `NSPopUpButton` "Small/Medium/Large", `NSComboBox` "Red/Green/Blue".
  - Date Picker — text-field-and-stepper style showing the current date/time.
  - Progress Indicators — determinate bar at 65% + "65% complete" + a spinning indicator.
  - Stepper — `NSStepper` 0–10 at 5, with a live "Value: 5" label.
  - Color & Image — `NSColorWell` (systemBlue), `NSImageView` (NSActionTemplate).
- [x] Accessibility snapshot confirms every control's role and initial value
      (radios A=1/B=0/C=0, slider=50, popup="Small", date picker timestamp,
      stepper=5, color-well="System systemBlueColor").
- [x] **Menu-bar app name reads "UI Controls Gallery"** (bold, from CFBundleName)
      with the standard About/Hide/Quit app menu.

### Live target-action callbacks (`make-delegate`)

The riskiest gerbil-specific path: target-action callbacks via `make-delegate`
(ADR-0017 native core), with the `'object` token wrapping `sender` to a bound
instance. Verified end-to-end in the bundled app:
- [x] **Radio** — pressing "Option B" ran `selectRadio:`, which cleared A/C and
      set the sender: radios flipped to A=0, **B=1**, C=0 (persisted in the
      top screenshot). Proves the trampoline → registered IMP → Gerbil proc →
      setter path under whole-program `-O`.
- [x] **Slider** — dragging the knob ran `sliderChanged:`, which read
      `nscontrol-double-value` from the wrapped sender, rounded, and updated the
      label via `nscontrol-set-string-value!`: slider → 75.65, label → **"Value: 76"**.
- Stepper uses the identical `make-delegate` + `nscontrol-int-value` mechanism.

No code changes to the emitter/runtime/bundler were needed: the app compiled and
linked clean on the first attempt (validating the declaring-class procedural-core
naming and the string→NSString boundary), and ran correctly on the first VM launch.

See [[feedback-use-testanyware]], [[reference-testanyware-cli]].
