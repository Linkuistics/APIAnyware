# 010-design

**Kind:** planning

## Goal

Finalize the **shared-IR direct-vs-trampoline contract** decided in the node BRIEF
(facts-only, emitters-derive; additive + corrective D1), and record it as an **ADR
+ design spec** so `020-build` (shared pipeline) and `040` (racket emitter) have a
firm contract. The two forks are already settled — this leaf does the
code-investigation the design rests on, then writes it down.

## Tasks

1. **Verify the `@objc` fact (highest priority).** The corrective half assumes the
   emitter can tell an `@objc`-bridged Swift class (bind directly) from a genuinely
   Swift-native non-`@objc` one (skip / trampoline). `DeclarationSource:
   SwiftInterface` does **not** distinguish them. Investigate the swift-api-digester
   node attributes and the current IR (`ir.rs`, `declaration_mapping.rs`,
   `merge.rs`): is `@objc`-ness / ObjC-runtime-exposure captured anywhere? If not,
   decide the minimal fact to carry (e.g. an `objc_exposed: bool` / runtime-name
   presence on `Class`).
2. **Pointer-constant detection rule.** Define what marks a constant pointer-valued
   (so it routes to a trampoline, not a literal). Decide from the captured type.
3. **Skipped → retained mechanism.** Specify how recovered top-level `s:`
   `Func`/`Var` are retained as regular nodes carrying their facts, and what (if
   anything) still records in `skipped_symbols` (the deferred `Macro`/`TypeAlias`/
   `AssociatedType` kinds presumably do, with a clear reason).
4. **Emitter contract.** Write the cross-target rule for deriving
   direct-vs-trampoline from the facts — the contract 040 (racket) implements first.
5. **Record it.** Write an ADR (allocate the next free number; **0025 is taken** —
   verify against `docs/adr/` before writing) refining ADR-0025 with the IR
   mechanism, plus a design spec under `docs/specs/` (or the pipeline docs). Note the
   goldens/snapshot-test impact for `020-build`.

## Done when

- The `@objc`-fact question is answered with evidence (captured, or the fact to add
  is specified).
- ADR + spec written: IR facts, pointer-constant rule, skipped→retained mechanism,
  and the emitter contract for direct-vs-trampoline are all pinned.
- `020-build` has an unambiguous implementation target.

## Notes

- Stay at the **shared-pipeline** layer. The emitter *implementation* is 040; this
  leaf only *defines the contract* it consumes.
- If investigation reveals the build is larger/different than `020-build` assumes,
  reshape `020-build` (or add leaves) before retiring this design leaf.
