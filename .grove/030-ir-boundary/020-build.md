# 020-build

**Kind:** work

## Goal

Implement the shared `collect → analyse` pipeline change specified by `010-design`:
carry the **facts** that make the direct-vs-trampoline boundary derivable, and
**stop dropping** the residual D1 intends to bind. No emitter changes here (that is
040); this leaf only makes the IR carry what the contract needs.

## Scope (from the node BRIEF; confirm against 010-design's ADR/spec)

- **Recover the additive residual.** Stop routing top-level `s:` `Func`/`Var` to
  `skipped_symbols` (`declaration_mapping.rs:164-175`); retain them as regular
  `Func`/`Var` nodes carrying their facts (`DeclarationSource`, `s:` USR).
- **Carry the corrective fact.** Whatever `010-design` decides distinguishes
  `@objc`-bridged from genuinely Swift-native types (e.g. an `objc_exposed` fact on
  `Class`) — add it to the IR and populate it in collection.
- **Pointer-constant fact.** Carry the pointer-ness fact per the rule from
  `010-design`, so emitters can route pointer-valued constants to a trampoline.
- **Deferred kinds recorded, not silently dropped.** `Macro`/`TypeAlias`/
  `AssociatedType` (the un-walked `_ => {}` at `declaration_mapping.rs:~102`) get an
  explicit `skipped_symbols` entry with a clear reason, rather than vanishing.
- **Goldens / snapshot tests.** Update `collected` goldens and the synthetic-TestKit
  snapshot expectations; the recovered residual and new facts change the IR.

## Done when

- The shared pipeline (`extract-swift` + `types` + any `analyse` touch) carries the
  facts the emitter contract needs; `cargo test --workspace` green (goldens updated).
- A spot-check confirms recovered `s:` funcs/constants and the new facts survive
  `collect → resolve → annotate → enrich` into the enriched IR a real target reads.
- Per `feedback-regenerate-pipeline-aggressively`: re-run the affected pipeline
  stages rather than trusting stale checkpoints.

## Notes

- No target-language emission changes here. If implementing reveals the contract is
  underspecified, kick back to `010-design` rather than guessing.
