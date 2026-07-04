# machine-kdl-schema-k153

**Kind:** work

## Goal

Author the **machine-IR KDL-Schema** over the `Framework` shape (`extracted` + `resolved`) at
`schemas/spec-format/`, plus a focused in-crate validator that reuses the shared generic engine
`apianyware_spec_format::validate_against_schema`. This is the artifact the machine-JSON-Schema seam
every prior workstream (ws2–ws6) deferred to ws8 became — **one schema language** now that the
machine IR is KDL (ADR-0046 §5). Mirror the established per-workstream pattern: author the
`.kdl-schema` + a registry-style test that loads and validates the **real materialized per-family
IR** against it.

## Context

Depends on `machine-kdl-codec-k152` (the KDL form must exist on disk to validate real files). The
pattern to copy is already repeated a dozen times:

- **The generic engine:** `semantic/tools/spec-format/src/schema.rs` (`validate_against_schema`) —
  the KDL-Schema-language interpreter every producing crate delegates to.
- **The pattern:** the twelve `schemas/spec-format/*.kdl-schema` + their per-crate `src/**/schema.rs`
  wrappers (`app-kinds`, `platform-manifest`, `platform-tests`, the six `target-model` submodules,
  `patterns`, `spec-format`) + `tests/*_registry.rs`. Each delegates to the engine and layers
  semantic checks the generic language can't state.
- **The shape to schema:** `apianyware_types::ir::Framework` (classes/protocols/methods/…, plus the
  `resolved`-only provenance ladder `source`/`confidence`/`superseded-by`). The `resolved` shape is
  the superset — decide whether one schema covers both (with optional resolved-only nodes) or two
  sibling schemas; the codec spike proved both shapes round-trip, so the shape is settled.

## Done when

- The machine-IR KDL-Schema is authored under `schemas/spec-format/` (naming: `machine-ir.kdl-schema`
  or an `extracted`/`resolved` split — a `02` judgement made at author time).
- A focused in-crate validator (reusing `validate_against_schema`) + a registry-style test that
  validates the real materialized per-family `extracted.kdl` / `resolved.kdl` are green.
- Golden-neutral (pure additive — no emit path touched).

## Notes

- Reuse the generic engine; do **not** write a second validator. Layer only the semantic checks the
  KDL-Schema language can't express, exactly as the twelve prior schemas do.
- No JSON Schema anywhere — the machine-JSON-Schema seam dissolved (ADR-0046 §5).
- The machine IR is gitignored/derived, so the registry test must guard on the IR being materialized
  (skip-as-pass when absent, like the existing resolved-dependent tests) — see [[sbcl_6d_test_stale]]
  for the established skip-when-absent pattern.
