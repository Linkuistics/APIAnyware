# spec-format-crate-k18

**Kind:** work

## Goal

Build the **`semantic/tools/spec-format`** crate (ADR-0046 §; PRD "Crate home"): the home for the
`.apiw` KDL parser, the machine-IR serde (**JSON** — `serde_json`, per the k17 no-go/retreat; not
KDL), schema-validation hookup, and the `_llm-annotations`→`annotations.apiw` converter.

## Context

Design source (do not re-grill): **PRD `prd/2026-06-24-spec-format-data-model.md`**, **ADR-0046**
(amended) + node BRIEF running-log **H**. **k17 settled the machine-ser/de path: NO-GO on KDL →
machine IR stays JSON (`serde_json`, status quo); only the authored `.apiw` overlay is KDL.** The
crate depends on `apianyware-types` + `kdl`; **keep `apianyware-types` dependency-light (no `kdl`
in it)** — the `.apiw` KDL parse lives here, not on the types crate. Add the crate to the root `Cargo.toml` `members`
under `semantic/tools/` (crate-home convention). The `.apiw` overlay parses to the typed
annotation model (`types::annotation`), carrying `source`/`confidence`/`provenance` (ADR-0046 §4).

## Done when

- `semantic/tools/spec-format` exists, builds, and is a workspace member.
- `.apiw` (KDL) parses to the typed annotation overlay, with good (`miette`) errors; round-trips.
  **One write-side footgun to carry (k17):** the `kdl` crate emits keyword-valued strings
  (`null`/`true`/`false`/`nan`/`inf`/`-inf`) bare-and-unparseable — the `.apiw` writer must
  force-quote them (the k17 spike source shows the `KdlEntryFormat` fix).
- Machine-IR serde for `extracted`/`resolved` is **`serde_json`** (k17 retreat — no new KDL serde);
  keep/lift the existing `apianyware-types` JSON round-trip coverage.
- Converter present + tested: `_llm-annotations/*.llm.json` → `annotations.apiw` (KDL). *(No
  json→kdl machine-IR converter — the machine IR stays JSON.)*
- `cargo fmt --all`; existing suites stay green (this adds a crate, changes no pipeline path yet).

## Notes

Pure library + converter — **no pipeline rewiring** here (that is k20). Provenance/precedence
*representation* lives in the types + the `.apiw` overlay; precedence *application* is k20's
resolve stage.
