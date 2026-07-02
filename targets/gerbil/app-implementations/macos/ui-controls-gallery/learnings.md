# ui-controls-gallery x gerbil

**2026-07-02 (AppSpec instrument + build, leaf k91):**
- 🟢 Instrumented to the k87 logging contract
  (`apps/macos/ui-controls-gallery/docs/logging-contract.md`): emitter inlined in
  the `.ss` (the hello-window k31 rationale — the bundler's closure walk follows
  only `:gerbil-bindings/…` references, and the emitter uses only Gambit
  primitives, so it rides the statically-linked prelude), with the four
  `[controls]` state-change events + the contract's string quoting
  (`ucg-quote-string` over a Gambit string port).
- **Emit placement mirrors chez, not hello-window-gerbil**: the gallery builds
  every control in `main`'s *defines* section (the `def` initializers evaluate
  before main's first expression), so `[lifecycle] startup` cannot be main's
  first expression as in hello-window — `(ucg-events-init!)` + `(ucg-emit-startup)`
  are top-level expressions *before* `(main)` instead, which still lands them
  before construction / the run loop.
- Control emits attach to the three existing handlers (`selectRadio:`
  post-exclusion — title via `nsbutton-title` + `nsstring-utf8-string`, whose
  Gambit `char-string` return maps a NULL UTF8String to `#f`, hence the
  `(or … "")` guard; `sliderChanged:` double→nearest-int via
  `(inexact->exact (round val))`; `stepperChanged:` integral) — no
  visible-behaviour change. The checkbox got its first target-action
  (`checkboxChanged:`): AppKit toggles a switch button's state *before* the
  action fires, so `(= (nsbutton-state sender) 1)` is the post-toggle state the
  contract wants. Unlike chez, the `'object` param token hands the callback a
  *wrapped* sender — no `borrow-objc-object` dance. New
  `applicationWillTerminate:` delegate → `reason=menu` (menu path only,
  mirroring the VM-verified hello-window gerbil).
- 🟢 Emitter verified in isolation against the contract matchers (the emitter
  block extracted verbatim from the `.ss` and driven under plain `gxi`:
  20 assertions — startup-first ordering, quoting edge `\\`/`\"`/newline,
  slider/stepper clamp ends, env + fixed-default path resolution with
  parent-dir creation, truncate-on-startup). Built standalone via new
  `build.sh` (hello-window k70 recipe): `UIControlsGallery-gerbil.app` (52 MB),
  `CFBundleIdentifier=com.linkuistics.ui-controls-gallery-gerbil`,
  `codesign --verify --strict` OK. Descriptor `ui-controls-gallery-impl.rkt`
  authored. Live launch + control interaction is the Tier-2 live-run leaf's
  bar (VM).
- **The gallery now needs `libAPIAnywareGerbil.dylib` at link — hello-window
  doesn't.** The post-swift-native-coverage regenerated bindings embed
  `aw_gerbil_swift_init_*` trampoline calls inside class modules; the gallery's
  closure pulls `nsimage.ss` (one such init), and gerbil *links* the trampoline
  dylib at `gxc -exe` (chez `dlopen`s — ADR-0029 §4), so a missing artifact
  fails loudly at link with undefined `aw_gerbil_swift_*` (bundle-gerbil's
  `discover_swift_dylib` silently omits `-lAPIAnywareGerbil` when absent).
  `build.sh` now has the dylib prereq (`swift build --product APIAnywareGerbil`
  — `--product`, not `--target`, or the dylib doesn't relink); bundle-gerbil
  vendors + relocates it into `Contents/Frameworks/` next to the openssl pair.
  This supersedes the 2026-06-08 "linked clean on first attempt" state, which
  predated the trampoline emission.

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
