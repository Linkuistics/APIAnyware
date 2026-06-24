# kdl-schema-k19

**Kind:** work

## Goal

Author the **KDL Schema** for the spec triad (`extracted.kdl`, `annotations.apiw`, `resolved.kdl`)
in `schemas/spec-format/` — the **authoritative, language-neutral format contract** so non-Rust
tools can validate/consume the artifacts (ADR-0046 §3; PRD "Schema").

## Context

Design source (do not re-grill): **PRD `prd/2026-06-24-spec-format-data-model.md`**, **ADR-0046**.
Mechanism = the **KDL Schema Language** (KDL-in-KDL, kdl.dev SCHEMA-SPEC) — *not* JSON Schema (no
JSON projection in a KDL-everywhere stack). The Rust serde types (k18) are *one conforming
implementation*; the schema is the contract, not derived-from-types as truth. Validates authored
`.apiw` (the §29 "validator" step) with good errors, and documents the format for humans/LLMs.

## Done when

- `schemas/spec-format/{extracted,annotations,resolved}.kdl-schema` (KDL Schema) authored,
  covering the data model in ADR-0046 §4 (provenance `source`, `confidence` enum, `provenance`,
  `superseded-by`, explicit `unknown`).
- The `spec-format` crate (k18) validates authored `.apiw` against the schema (wired as the
  validator step), with at least one passing + one deliberately-failing fixture.
- `schemas/docs/` notes the contract is language-neutral + how other languages consume it.
- ws8 boundary recorded: ws8 owns validation tooling/CI + schemas for the *other* artifacts.

## Notes

Schema covers the **spec-format** artifacts only. App-kinds, AppSpecs, capability profiles, and
conformance-report schemas are ws8. KDL Schema Language maturity caveat (ADR-0046): if a consumer
needs JSON Schema, a canonical KDL→JSON projection + JSON Schema is a deferrable secondary.
