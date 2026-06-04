# 010-cli-registration-and-class-registry

**Kind:** work

## Goal

Register `gerbil` in the generate CLI's `EmitterRegistry`, and wire the cross-
framework `ClassRegistry` (ADR-0020) so a parent that lives in another framework
resolves to the precise `:gerbil-bindings/<owner>/<parent>` import.

## What to do

1. **Register the target** (`generation/crates/cli/src/registry.rs` + `Cargo.toml`):
   add `apianyware-macos-emit-gerbil` dep, push `GerbilEmitter` into
   `EmitterRegistry::new()`, mirror the chez registry tests (`registry_contains_gerbil`,
   include in `lists_all` / `format_target_list`).
2. **Wire the registry pre-pass** (`generation/crates/cli/src/generate.rs`): the
   `ClassRegistry` is cross-framework but `emit_framework` runs per-framework — so
   build it once from the already-loaded `ordered_frameworks` and run the gerbil
   emitter constructed via `GerbilEmitter::with_registry(reg)`, the racket-native-
   dispatch precedent (a target-specific whole-program step in `generate.rs`). The
   registry currently holds an empty-registry `GerbilEmitter`; the pre-pass supplies
   the populated one for the actual run. `ClassRegistry::from_frameworks` takes
   `&[Framework]`; `ordered_frameworks` is `Vec<&Framework>` — add a `&[&Framework]`
   variant (or adapt) rather than cloning frameworks.

## Done when

- `--target gerbil` resolves and drives `emit-gerbil` (registry get/list tests green).
- An integration test over a 2-framework subset (dependent class whose super lives in
  the base framework) asserts the cross-framework `:gerbil-bindings/<owner>/<parent>`
  import appears in the emitted child module — exercising the wired registry through
  `run_generation` end-to-end.
- `cargo test -p apianyware-macos-generate -p apianyware-macos-emit-gerbil` green.

## Notes

Keep it hermetic (ADR-0011): the only gerbil-specific thing the CLI learns is how to
construct its emitter with program-wide context; no shared substrate with racket/chez.
Full escalation context in this node's `BRIEF.md` (→ 010 section).
