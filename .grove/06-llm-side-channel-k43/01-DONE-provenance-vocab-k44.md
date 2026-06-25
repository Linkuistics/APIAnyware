# provenance-vocab-k44

**Kind:** work

## Goal

Reconcile the `AnnotationSource` provenance vocabulary to the ADR-0046 §4 / ADR-0050 model —
the foundational, golden-neutral first child of ws5. Today the enum and the `.apiw` schema
carry the **legacy** spellings (`Heuristic` / `human_reviewed`), drifting from the decided
`{extraction, convention:<rule>, llm, manual}` vocabulary. This child aligns the *names*;
it does **not** build the precedence mechanism (that's `precedence-audit`, the next child).

## Context (see node `BRIEF.md` + ADR-0050 + `CONTEXT.md`)

- `AnnotationSource` (`semantic/tools/types/src/annotation.rs`) is `{Heuristic, Llm,
  HumanReviewed}` with `#[serde(rename_all = "snake_case")]` → tokens
  `heuristic` / `llm` / `human_reviewed`.
- `schemas/spec-format/annotations.kdl-schema` enumerates the `source` node as
  `enum "heuristic" "llm" "human_reviewed"` (the overlay contract).
- **Emit is provenance-blind** — no emit crate branches on `source` (`emit_class.rs`'s only
  `Heuristic` is a `// Heuristic fallback` comment). So renaming is **golden-neutral by
  construction** (D4). This is the safety invariant to verify, not assume.
- Consumers of the variants (rename targets): `platforms/macos/tools/annotate/{lib,llm,
  validate}.rs`, `semantic/tools/enrich/{fact_loader,checkpoint}.rs`,
  `semantic/tools/spec-format/src/apiw.rs`, and their tests
  (`annotation_roundtrip.rs`, `apiw_roundtrip.rs`, `schema_validation.rs`,
  `enrichment_rules.rs`).
- Committed `annotations.apiw` files are **all `source llm`** (17,171 facts) → the rename
  touches **zero committed overlay content**; `resolved.json` is gitignored/regenerated.

## Scope (this child only)

- **In:** a strict **1:1 rename** — `Heuristic`→`Convention`, `HumanReviewed`→`Manual` (keep
  `Llm`); update serde token output (`heuristic`→`convention`, `human_reviewed`→`manual`), the
  schema `source` enum (3 tokens `convention`/`llm`/`manual`), and every Rust consumer + test.
  Keep doc-comments accurate.
- **Out (later children):** **tightening** the overlay schema `source` to `{llm, manual}` — that
  is the resolved-vs-overlay vocab *split* (D3), built with the resolved side in
  `precedence-audit` (k45); the `convention:<rule>` payload on `Convention`; the `Extraction`
  and `Unknown` variants; any per-fact `source` carriage in `resolved.json`; the precedence /
  `superseded-by` mechanism; staleness / report subcommands; tooling retirement.

## Done when

- `AnnotationSource` is `{Convention, Llm, Manual}` (serde `convention`/`llm`/`manual`); the
  schema `source` enum is the 1:1-renamed `{convention, llm, manual}`; all consumers + tests
  compile and pass.
- `cargo build --workspace` clean; `cargo test` green for the touched crates
  (`apianyware-types`, `apianyware-spec-format`, `apianyware-annotate`, `apianyware-enrich`)
  **and** the emit golden suites (the goldens-as-truth gate — must be **unmoved**).
- Committed `annotations.apiw` files still parse + schema-validate (sample-check at least
  Foundation + a small framework).
- Committed in one focused commit named by the `provenance-vocab-k44` handle.

## Notes

- **Minimal carriage** (k26): rename only; resist adding the deferred variants/payload until a
  child actually produces them.
- If the rename's blast radius proves larger than one focused session (e.g. a hidden consumer
  branch), `leaf-decompose` this child and do only its first grandchild — do **not** absorb.
