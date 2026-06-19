# 020-rerun-verify

**Kind:** work

## Goal

Prove the gerbil method-trampoline port (`010-build`) end-to-end through a full cold
pipeline rerun and a VM-verified GUI app — the §6b done-bar applied to the gerbil
method slice, mirroring `040-chez/020-rerun-verify`. **Last leaf of the grove:** on
completion the "propagate to all targets, each VM-verified" done-bar is met and the
grove is ready to **finish**.

## Done when

- **Cold full rerun, clean:** `SDKROOT=macosx collect` (284 frameworks) → `analyze`
  (LLM annotations replayed) → `generate --target gerbil` → `swift build` (the
  `APIAnywareGerbil` dylib) → `gxc -exe` green.
- The gerbil method/init residual **reproduces exactly** from the cold collect — same
  decl set as racket's/chez's init + method counts (gerbil `aw_gerbil_swift_*`
  entry-name prefix), with the same per-reason deferred counts (the §6d invariant);
  report them.
- **No regression:** `cargo test --workspace` green (note the known gerbil
  `computes_hello_window_closure` env-flake), **incl. the `bundle-gerbil`
  swift-dylib-relocation tests**. A gerbil runtime-load / method round-trip guard
  carries the IndexSet init→contains→mutating insert! write-back (the §6b permanent
  regression guard, gerbil analogue of the chez/racket method round-trip).
- **CLI smoke (both exemplars)** through the generated gerbil require/import tree
  against the freshly built dylib, **chained into `run-smokes.sh`** as the permanent
  Swift-native-method regression guard: pop-B IndexSet init→contains→insert!→contains
  and pop-A async `URLSession.data(from: file://…)`.
- **VM-verified (project done-bar):** a gerbil `swift-native-method-probe` sample app
  (extend/mirror the gerbil `swift-native-probe`, or the chez method-probe) shows both
  exemplars live through libAPIAnywareGerbil's `@_cdecl` trampolines via the generated
  tree, in a **standalone self-contained `.app`** (ADR-0009); bundled exe `otool -L`
  clean (dylib relocated into `Contents/Frameworks/`); screenshot in
  `generation/targets/gerbil/test-results/`. Use TestAnyware / macOS VM (never run GUI
  from CLI).
- **N1 re-measured** if material (the added `swift build` cost vs. the ADR-0023
  generics compile — ADR-0029's build-time finding; confirm it stays small/additive
  with the method/init/async `@_cdecl`s added).

## Notes

gerbil-only (ADR-0011). Last leaf of the grove — VM-verify per the project done-bar
(TestAnyware, golden macOS 26 / `macos-tahoe`). On completion, propose the grove
**Finish** cycle (promote ADRs/docs, delete `.grove/`, merge, inbox cleanup, remove
worktree + branch) — this unpauses `add-sbcl-clos-target`.
