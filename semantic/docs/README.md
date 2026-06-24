# semantic/docs/ — semantic-model documentation

Per the documentation-placement rule (REFACTOR.md §10: "documentation lives with
its subject"), semantic docs live here. This holds the prose describing the
semantic model: the pattern-kind taxonomy and the §31 relationships folded into
it — the conceptual vocabulary that the `../pattern-kinds/` definitions formalize.

## The semantic-model prose

Read in order:

1. **[`overview.md`](overview.md)** — what the `semantic/` domain is, the
   kind/instance split, the three provenance tiers, and where the code lives.
2. **[`pattern-model.md`](pattern-model.md)** — the taxonomy: roles, laws and the
   §30 controlled vocabularies, ordering, behavioral-vs-structural, composition.
3. **[`api-pattern-catalog.md`](api-pattern-catalog.md)** — the roster of the 16
   authored kinds, each with roles/laws and canonical macOS examples (supersedes
   the retired v1.0 "API Pattern Catalog").

The terse vocabulary is in `CONTEXT.md → "Semantic model"`; the decisions are
[ADR-0048](../../adr/0048-first-class-semantic-pattern-kind-model.md) and the PRD
[`prd/2026-06-25-semantic-pattern-kind-model.md`](../../prd/2026-06-25-semantic-pattern-kind-model.md).

This directory also holds existing semantic-pipeline docs
([`analysis.md`](analysis.md), [`enrich-rules.md`](enrich-rules.md),
[`memory-architecture.md`](memory-architecture.md)), design notes under
[`design/`](design/), and the testing docs under [`testing/`](testing/).

> The representability model (REFACTOR §7.7) — what each target *can* express —
> is a per-target capability concern owned by ws6 (`targets/`), not part of this
> projection-independent semantic prose.
