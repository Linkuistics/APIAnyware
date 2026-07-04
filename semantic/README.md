# semantic/ — shared language of meaning

The `semantic/` domain holds APIAnyware's projection-independent source semantics
(REFACTOR.md §8, §7.1): the meaning of platform APIs expressed once, with no
statement about how any target language exposes them. This is where multi-API
patterns become first-class semantic entities (§7.5, §31, §32) and where the
semantic-graph vocabulary is documented. The Rust crates that build the semantic
graph live under `semantic/tools/` (crate-home convention — Rust code co-locates
with the domain it serves, ADR-0043): `types`, `datalog`, `resolve`, `enrich`,
the new `patterns` crate (the pattern-kind registry), and the `analyze-cli`
orchestrator (bin `apianyware-analyze`), relocated here in `move-semantic-k5`.

## Contents

- **[`pattern-kinds/`](pattern-kinds/)** — the first-class **pattern-kind** and
  relationship definitions, authored as `.apiw` files (ADR-0048). Each kind is a
  reusable, framework- and target-independent set of roles + laws.
- **[`docs/`](docs/)** — the semantic-model prose: start at
  [`docs/overview.md`](docs/overview.md), then
  [`docs/pattern-model.md`](docs/pattern-model.md) (the taxonomy) and
  [`docs/api-pattern-catalog.md`](docs/api-pattern-catalog.md) (the authored-kind
  roster).
- **`tools/`** — the crates that build the semantic graph (above), including
  `tools/patterns` (the kind registry / `.apiw` parser / §30 controlled
  vocabularies / validator).

The vocabulary is defined in `CONTEXT.md → "Semantic model"`; the design is
[ADR-0048](../adr/0048-first-class-semantic-pattern-kind-model.md) and the PRD
[`prd/2026-06-25-semantic-pattern-kind-model.md`](../prd/2026-06-25-semantic-pattern-kind-model.md).

A pattern **instance** (a kind bound to a concrete framework) is *platform*
knowledge and lives in the platform triad
(`platforms/macos/api/<Framework>/resolved.kdl`), not here — the kind/instance
split that keeps this domain projection- and platform-independent.
