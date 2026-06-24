# spec-format-crate-k18

**Kind:** work

## Goal

Build the **`semantic/tools/spec-format`** crate (ADR-0046 §; PRD "Crate home"): the home for the
`.apiw` KDL parser, the IR-as-KDL serde, schema validation hookup, and the converters
(json→kdl, `_llm-annotations`→`annotations.apiw`).

## Context

Design source (do not re-grill): **PRD `prd/2026-06-24-spec-format-data-model.md`**, **ADR-0046**.
Depends on the spike (k17) outcome for the machine-ser/de path. The crate depends on
`apianyware-types` + `kdl`; **keep `apianyware-types` dependency-light (no `kdl` in it)** — the
KDL ser/de lives here, not on the types crate. Add the crate to the root `Cargo.toml` `members`
under `semantic/tools/` (crate-home convention). The `.apiw` overlay parses to the typed
annotation model (`types::annotation`), carrying `source`/`confidence`/`provenance` (ADR-0046 §4).

## Done when

- `semantic/tools/spec-format` exists, builds, and is a workspace member.
- `.apiw` (KDL) parses to the typed annotation overlay, with good (`miette`) errors; round-trips.
- IR-as-KDL serde for the `extracted`/`resolved` types (path per k17), with golden round-trip tests.
- Converters present + tested: JSON IR → KDL, and `_llm-annotations/*.llm.json` → `annotations.apiw`.
- `cargo fmt --all`; existing suites stay green (this adds a crate, changes no pipeline path yet).

## Notes

Pure library + converters — **no pipeline rewiring** here (that is k20). Provenance/precedence
*representation* lives in the types + KDL serde; precedence *application* is k20's resolve stage.
