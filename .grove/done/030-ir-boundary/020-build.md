# 020-build

**Kind:** work

## Goal

Implement the shared `collect → analyse` pipeline change specified by `010-design`:
carry the **facts** that make the direct-vs-trampoline boundary derivable, and
**stop dropping** the residual D1 intends to bind. No emitter changes here (that is
040); this leaf only makes the IR carry what the contract needs.

## Scope (settled by 010-design — ADR-0026 + `docs/specs/2026-06-15-ir-objc-exposure-boundary.md`)

The spec is the authority; these bullets summarise it.

- **Add `objc_exposed: bool`** to the eight IR decl structs (`Class`, `Method`,
  `Property`, `Protocol`, `Enum`, `Struct`, `Function`, `Constant`) — default
  `true`, `skip_serializing_if` true. Per-member granularity (not just `Class`):
  an `s:` method merged onto an ObjC class carries its own `false`. Every
  `ir::* { … }` literal across `collection/` + `analysis/` + tests must add the
  field (the bulk of the mechanical churn).
- **One shared classifier in collection.** Replace `non_c_linkable_skip_reason()`
  (`declaration_mapping.rs:164`) with the three-way `classify_usr` (Direct /
  SwiftNative / Skip(reason)); derive `objc_exposed` from it. `extract-objc`
  sets `objc_exposed: true` unconditionally.
- **Recover the additive residual.** Top-level `s:` `Func`/`Var` → retain as
  `Function`/`Constant` with `objc_exposed: false` (no longer `skipped_symbols`).
  `c:@macro@` / `c:@Ea@` / `c:@EA@` → still skip. `SWIFT_NATIVE` skip reason
  retired from the drop path.
- **Pointer-ness is DERIVED, not a new field** — emitters compute
  `is_pointer_valued(constant_type)` per the spec's type list. 020-build adds no
  pointer field.
- **Deferred kinds recorded, not silently dropped.** `Macro`/`TypeAlias`/
  `AssociatedType` (the `_ => {}` at `declaration_mapping.rs:~102`) → a
  `skipped_symbols` entry with the new `DEFERRED_ABI_KIND` reason.
- **Goldens / snapshot tests.** Collected goldens gain `objc_exposed: false` on
  newly-retained `s:` funcs/constants AND already-retained Swift-native types;
  `skipped_symbols` loses `SWIFT_NATIVE`, gains `deferred_abi_kind`; update the
  synthetic-TestKit snapshot expectations.

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
