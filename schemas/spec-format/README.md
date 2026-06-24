# schemas/spec-format/ — the authored `.apiw` overlay contract

- **`annotations.kdl-schema`** — the authoritative, language-neutral contract for the authored
  `annotations.apiw` overlay (ADR-0046 §3), written in the KDL Schema Language (KDL-in-KDL).
  Authored by workstream 2 (`spec-format-k16` → `kdl-schema-k19`).

The Rust `apianyware-spec-format` crate is *one conforming validator* of this contract (its
`validate_apiw` step embeds this file); any KDL tool in any language can validate an `.apiw` file
against it. See [`../docs/spec-format-schema.md`](../docs/spec-format-schema.md) for the rationale,
the cross-language consumption notes, and the ws8 boundary (machine-`.json` JSON Schema + the
app-kind / AppSpec / capability-profile / conformance-report schemas live there).
