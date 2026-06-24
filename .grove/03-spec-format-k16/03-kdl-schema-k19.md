# kdl-schema-k19

**Kind:** work

## Goal

Author the **KDL Schema** for the authored **`annotations.apiw`** overlay in `schemas/spec-format/`
— the **authoritative, language-neutral format contract** so non-Rust tools can validate/consume
the authored artifact (ADR-0046 §3; PRD "Schema"). *(Post-k17: the machine `extracted.json`/
`resolved.json` are JSON, not KDL — they get a JSON Schema, deferred to ws8; only the KDL overlay
gets a KDL Schema here.)*

## Context

Design source (do not re-grill): **PRD `prd/2026-06-24-spec-format-data-model.md`**, **ADR-0046**
(amended) + node BRIEF running-log **H**. Mechanism = the **KDL Schema Language** (KDL-in-KDL,
kdl.dev SCHEMA-SPEC) for the authored overlay. The Rust serde types (k18) are *one conforming
implementation*; the schema is the contract, not derived-from-types as truth. Validates authored
`.apiw` (the §29 "validator" step) with good errors, and documents the format for humans/LLMs.
*(k17 retreat: machine `extracted.json`/`resolved.json` are JSON; their schema is JSON Schema and
is ws8's — out of scope here.)*

## Done when

- `schemas/spec-format/annotations.kdl-schema` (KDL Schema) authored, covering the authored
  overlay's data model in ADR-0046 §4 (provenance `source`, `confidence` enum, `provenance`,
  `superseded-by`, explicit `unknown`).
- The `spec-format` crate (k18) validates authored `.apiw` against the schema (wired as the
  validator step), with at least one passing + one deliberately-failing fixture.
- `schemas/docs/` notes the contract is language-neutral + how other languages consume it; records
  that the machine `.json` artifacts' JSON Schema is ws8.
- ws8 boundary recorded: ws8 owns validation tooling/CI + schemas for the machine `.json`
  artifacts and the *other* (app-kinds/AppSpec/profile/conformance) artifacts.

## Notes

Schema covers the authored **`.apiw`** overlay only. The machine `.json` IR (JSON Schema),
app-kinds, AppSpecs, capability profiles, and conformance-report schemas are all ws8.
