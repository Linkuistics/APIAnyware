# semantic/ — shared language of meaning

The `semantic/` domain holds APIAnyware's projection-independent source semantics
(REFACTOR.md §8, §7.1): the meaning of platform APIs expressed once, with no
statement about how any target language exposes them. This is where multi-API
patterns become first-class semantic entities (§7.5, §31, §32) and where the
semantic-graph vocabulary is documented. The Rust crates that build the semantic
graph live under `semantic/tools/` (crate-home convention — Rust code co-locates
with the domain it serves, ADR-0043).

TODO: `tools/` crates (`types`, `datalog`, `resolve`, `enrich`, `analyze-cli`)
relocate here in `move-semantic-k5`. Pattern-kind definitions + semantic
vocabulary docs are authored in workstream 3 (semantic model). No content this
leaf (skeleton-only, SC6).
