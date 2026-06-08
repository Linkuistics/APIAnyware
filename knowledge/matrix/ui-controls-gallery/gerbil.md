# ui-controls-gallery x gerbil

**2026-06-08 (standalone, grove leaf `100/010`):**
- 🟢 Ported and VM-verified as a self-contained `.app` (ADR-0009; static Gambit
  runtime + vendored openssl, dylib-clean). All 8 sections render with every
  major AppKit control, in a **no-Gerbil VM**. The three target-action delegates
  (`selectRadio:`, `sliderChanged:`, `stepperChanged:`) use the `make-delegate`
  native-core bridge (ADR-0017); radio press flipped the selection and slider
  drag drove the live "Value: 76" label — proving the IMP-trampoline callback
  path survives whole-program `-O`. App compiled + linked clean on first attempt.
  See `generation/targets/gerbil/test-results/ui-controls-gallery/report.md`.
- Idiom notes: strings cross as `(string->nsstring …)`; inherited methods called
  via the declaring superclass's procedural core (`nscontrol-double-value`,
  `nscontrol-set-string-value!`); most controls use the bare `make-<class>`
  initializer + `nsview-set-frame!`.
