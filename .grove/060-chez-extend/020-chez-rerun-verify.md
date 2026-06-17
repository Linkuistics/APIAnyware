# 020-chez-rerun-verify

**Kind:** work

## Goal

Close the chez slice: re-run the whole pipeline cold for chez from the real SDK and
verify the Swift-native trampoline path end-to-end in a GUI app (the project
done-bar — `feedback-vm-verify-every-app`), not just the in-process CLI smoke. Mirror
the racket 050 close (spec §6b).

## Done when

- **Cold full rerun, clean.** `collect` → `analyze` → `generate --target chez` →
  `swift build`. The chez residual classification **reproduces** from a cold collect
  (same counts as racket's residual — same shared IR); record the counts.
- **No ObjC regression.** `cargo test --workspace` green; the chez runtime
  smoke/load harness green, extended to carry the trampoline require-shape +
  constant-trampoline round-trip as permanent regression guards (mirror racket 050's
  `RUNTIME_LOAD_TEST` additions).
- **VM-verified (project done-bar).** A chez `swift-native-probe` sample app (port of
  the racket one, `apps/swift-native-probe/`) shows the §6a exemplars live —
  `CreateML.timestampSeed()` returning a time-derived `Int` and `MLCreateErrorDomain`
  rendering `com.apple.CreateML`, both through `libAPIAnywareChez`'s `@_cdecl`
  trampolines. Visually confirmed in the TestAnyware macOS VM; screenshot saved under
  `generation/targets/chez/test-results/swift-native-probe/`.
- Sample app meets the polish bar (`feedback-sample-apps-perfect`): not just a window
  — the values render correctly and the empty/loaded states look intentional.

## Notes

- Use TestAnyware for the VM verify (`reference-testanyware-cli`,
  `feedback-use-testanyware`); never run the GUI app from the CLI.
- After this leaf the 060 node retires (promote the chez trampoline ADR + the
  ADR-0011 call upward); only `070-gerbil-extend` remains before grove-finish.
