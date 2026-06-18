# 030-rerun-verify

**Kind:** work

## Goal

Close the gerbil slice — and the grove's "rerun every target" done-bar: cold-run
the whole pipeline for gerbil from the real SDK, VM-verify the Swift-native path
in a GUI app (project done-bar), and **measure N1** so ADR-0029's build-time
finding is quantified, not asserted. Mirrors the racket-050 / chez-060/020 close.

## Context

ADR-0029 (esp. the "Build-time finding (N1)" section, which this leaf fills with
numbers). Use TestAnyware for the VM verify (`reference-testanyware-cli`,
`feedback-use-testanyware`); never run the GUI app from the CLI.

## Done when

- **Cold full rerun, clean.** `collect` → `analyze` → `generate --target gerbil`
  → `swift build` → `gxc`. The gerbil residual classification **reproduces** from
  a cold collect (same counts as racket/chez — same shared IR: 51 function
  trampolines, 7 constants, deferred 6/10/4/34); record the counts.
- **No ObjC regression.** `cargo test --workspace` green; the gerbil runtime
  smoke/load harness green, extended with the trampoline require-shape +
  constant-trampoline round-trip as permanent regression guards (mirror chez/racket).
- **N1 measured + appended to ADR-0029.** Quantify the added `swift build`
  wall-clock and confirm the generics compile (ADR-0023) is unchanged by the
  dylib. Append the real numbers to ADR-0029's "Build-time finding (N1)" section,
  closing N1 honestly (necessity, not a build-time win).
- **VM-verified (project done-bar).** A gerbil `swift-native-probe` sample app
  (port of the racket/chez one) shows the §6a exemplars live —
  `CreateML.timestampSeed()` returning a time-derived `Int` and `MLCreateErrorDomain`
  rendering `com.apple.CreateML`, both through `libAPIAnywareGerbil`'s `@_cdecl`
  trampolines. The bundled `.app` passes `otool -L` self-containment (the dylib
  relocated into `Contents/Frameworks/`). Visually confirmed in the TestAnyware
  macOS VM; screenshot saved under
  `generation/targets/gerbil/test-results/swift-native-probe/`.
- Sample app meets the polish bar (`feedback-sample-apps-perfect`): values render
  correctly, empty/loaded states look intentional — not just a window.

## Notes

- After this leaf the 070 node retires (promote nothing new — ADR-0029 already
  holds the design; just fill its N1 numbers). The grove is then ready to finish:
  propose the complete finish cycle and **wait for explicit confirmation** before
  any teardown.
- Grove-finish unpauses `add-sbcl-clos-target` (memory
  `project-complete-api-model-and-swift-coverage`).
