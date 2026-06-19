# 020-rerun-verify

**Kind:** work

## Goal

Prove the chez method-trampoline port (`010-build`) end-to-end through a full cold
pipeline rerun and a VM-verified GUI app — the §6b done-bar applied to the chez
method slice, mirroring `030-racket/030-rerun-verify`.

## Done when

- **Cold full rerun, clean:** `SDKROOT=macosx collect` (284 frameworks) → `analyze`
  (LLM annotations replayed) → `generate --target chez` → `swift build` green.
- The chez method/init residual **reproduces exactly** from the cold collect — same
  decl set as racket's 576 init + 554 method (chez entry-name prefix), with the same
  per-reason deferred counts (the §6c invariant); report them.
- **No regression:** `cargo test --workspace` green (note the known gerbil
  `computes_hello_window_closure` env-flake). The chez runtime-load / method
  round-trip guard carries the IndexSet init→contains→mutating insert! write-back
  (the §6b permanent regression guard, chez analogue of `runtime_swift_method_roundtrip`).
- **CLI smoke (both exemplars)** through the generated chez require/import tree against
  the freshly built dylib: pop-B IndexSet init→contains→insert!→contains and pop-A
  async `URLSession.data(from: file://…)`.
- **VM-verified (project done-bar):** a chez `swift-native-method-probe` sample app
  (extend/mirror the racket one, or the chez `swift-native-probe`) shows both
  exemplars live through libAPIAnywareChez's `@_cdecl` trampolines via the generated
  tree; screenshot in `generation/targets/chez/test-results/`. Use TestAnyware /
  macOS VM (never run GUI from CLI).

## Notes

chez-only (ADR-0011). Last-but-one leaf; on completion only `050-gerbil` remains.
VM-verify per the project done-bar (TestAnyware, golden macOS 26 / `macos-tahoe`).
