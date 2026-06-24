# block-invocation-k23

**Kind:** work

## Goal

Port the **block-invocation** facet of `heuristics.rs` to the `ConventionProgram` (the crate stood
up by `scaffold-ownership-k22`), extending the characterization harness to gate it. This is the
gnarliest facet — the most string patterns.

Reproduce *exactly* (goldens-as-truth) `heuristics::derive_block_parameters` →
`BlockParamAnnotation { param_index, invocation }` for every block-typed parameter, where
`invocation ∈ {synchronous, async_copied, stored}`:
- **`classify_block_invocation`** — the sync / async / stored selector-substring tables plus the
  "last block param + async-method token" rule and the `async_copied` default.
- **`is_copy_block_property_setter`** — a synthesised `set<Cap>:` selector whose target is a
  class/protocol `@property (copy)` block property → **stored** (overrides the substring tables).

## Context

Design source (do NOT re-grill): node brief `conventions-datalog-k21`, ADR-0047. Same crate
`platforms/macos/tools/conventions`; add rules to `program.rs`, base facts to `fact_loader.rs`,
and a `block_invocation` facet to `readback.rs`, each derived fact stamped `convention:<rule>`.

**New fact-base need vs k22:** the copy-block-property-setter rule consults the *receiver's
properties* — extend the loader to push property facts (`property(receiver, name, is_copy,
is_block)`) for classes **and** protocols (a protocol may declare a `@property (copy)` block
property; see `annotate_protocol_method_heuristic`). The `set<Cap>:` → property-name mapping
(`heuristics::setter_target_property_name`) is a string predicate ported verbatim.

**Pipeline still UNCHANGED** — `annotate` keeps driving `heuristics.rs`; the flip is the node's
last child. So the 71 suites + emit goldens stay green by construction.

Characterization: extend `tests/ownership_equivalence.rs` (or add a sibling `block_equivalence.rs`)
to assert the new `block_parameters` output equals `heuristics::annotate_method_heuristic(...)`
`.block_parameters` over the synthetic cases (cover the full sync/async/stored tables + the
copy-property-setter + its negatives) and the real Foundation IR when present.

## Done when

- The block-invocation facet is `ascent` rules in `ConventionProgram`; loader carries property facts.
- Characterization test asserts `block_parameters` equals `heuristics.rs` over synthetic + real IR.
- Derived facts carry `convention:<rule>` stamps; `cargo build`/`test` green; `cargo fmt --all`.

## Notes

Watch the precedence: `is_copy_block_property_setter` wins over the substring tables (stored). And
the substring tables have an *order* (sync checked before async before the last-param async-method
rule before stored) — encode that precedence faithfully (stratified rules or explicit priority in
the readback). Ownership's block→copy (k22) and this facet's block invocation are independent
outputs on the same block param; keep them decoupled.
