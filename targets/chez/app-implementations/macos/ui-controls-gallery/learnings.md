# ui-controls-gallery x chez

**2026-05-29 (source-exec port):**
- 🟡 All controls render; three delegates (`selectRadio:`, `sliderChanged:`,
  `stepperChanged:`) fire correctly in the TestAnyware VM. Source-exec/precompile
  bundle (103 MB). See `targets/chez/bindings/macos/reports/ui-controls-gallery/report.md`.

**2026-05-30 (standalone, leaf `060/050/020`):**
- 🟢 Re-verified as a **production open-world standalone `.app`** (ADR-0009,
  5.8 MB, kernel baked in). All three dispatch trampolines fire in a **no-Chez
  VM** — first proof the `eval`-synthesised `foreign-callable` substrate survives
  whole-program optimisation. RSS flat at 117 MB across ~15 dispatch round-trips.
  See the "Standalone re-verification" section of the report.

**2026-07-02 (AppSpec instrument + build, leaf k90):**
- 🟢 Instrumented to the k87 logging contract
  (`apps/macos/ui-controls-gallery/docs/logging-contract.md`): emitter inlined in
  the `.sls` (the hello-window k69 rationale — a sibling `events.sls` would need an
  `apps/`-prefixed library name under the whole-program compile tree; only
  `(chezscheme)` names used), with the four `[controls]` state-change events + the
  contract's string quoting (`ucg-quote-string` via `string-for-each` over an
  output string port).
- **Emit placement is shaped by R6RS body semantics**: the gallery builds every
  control in `main`'s *defines* section (internal defines evaluate letrec*-style,
  before any expression), so `[lifecycle] startup` cannot be main's first
  expression as in hello-window — `(ucg-events-init!)` + `(ucg-emit-startup)` are
  top-level expressions *before* `(main)` instead, which still lands them before
  construction / the run loop.
- Control emits attach to the three existing handlers (`selectRadio:`
  post-exclusion — title via `nsbutton-title` + `nsstring-utf8-string`, whose FFI
  `string` return maps NULL → `#f`, hence the `(or … "")` guard; `sliderChanged:`
  double→nearest-int via `(exact (round val))`; `stepperChanged:` integral) — no
  visible-behaviour change. The checkbox got its first target-action
  (`checkboxChanged:`): AppKit toggles a switch button's state *before* the action
  fires, so `(= (nsbutton-state …) 1)` is the post-toggle state the contract wants.
  New `applicationWillTerminate:` delegate → `reason=menu` (menu path only,
  mirroring the VM-verified hello-window chez).
- 🟢 Emitter verified in isolation against the contract matchers (the emitter
  block extracted verbatim from the `.sls` and driven under plain `chez --script`:
  18 assertions — startup-first ordering, quoting edge, clamp ends, fixed-default
  path + parent-dir creation, truncate-on-startup). Built standalone via new
  `build.sh` (hello-window k69 recipe + the shared-identity re-sign):
  `UIControlsGallery-chez.app`,
  `CFBundleIdentifier=com.linkuistics.ui-controls-gallery-chez`. Descriptor
  `ui-controls-gallery-impl.rkt` authored. Live launch + control interaction is
  the Tier-2 live-run leaf's bar (VM).
