# schemas/spec-format/ — the authored `.apiw` overlay contracts

Each file is a language-neutral contract (ADR-0046 §3) for one authored `.apiw` family,
written in the KDL Schema Language (KDL-in-KDL). A Rust crate is *one conforming validator*
of each; any KDL tool in any language can validate against them.

- **`annotations.kdl-schema`** — the authored `annotations.apiw` overlay. Workstream 2
  (`spec-format-k16` → `kdl-schema-k19`); validated by `apianyware-spec-format`'s `validate_apiw`.
- **`pattern-kinds.kdl-schema`** — the first-class semantic pattern-kind registry
  (`semantic/pattern-kinds/<kind>.apiw`). Workstream 3 (ADR-0048); validated by `apianyware-patterns`.
- **`platform.kdl-schema`** — the macOS platform manifest (`platforms/macos/platform.apiw`).
  Workstream 4 (`platform-manifest-k33`); validated by `apianyware-platform-manifest`.
- **`app-kind.kdl-schema`** — a macOS app-kind process-model definition
  (`platforms/macos/app-kinds/<kind>/kind.apiw`). Workstream 4 (`mechanism-k35`, ADR-0049);
  validated by `apianyware-app-kinds`.
- **`app-kind-tests.kdl-schema`** — the declaration half of an app-kind's platform-level test
  obligations (`platforms/macos/tests/app-kinds/<kind>.apiw`). Workstream 4 (`test-mechanism-k38`);
  validated by `apianyware-platform-tests`. (Its sibling `api-semantics.kdl-schema` grows in the
  same crate in workstream 4 child 3.)

The Rust `apianyware-spec-format` crate is *one conforming validator* of this contract (its
`validate_apiw` step embeds this file); any KDL tool in any language can validate an `.apiw` file
against it. See [`../docs/spec-format-schema.md`](../docs/spec-format-schema.md) for the rationale,
the cross-language consumption notes, and the ws8 boundary (machine-`.json` JSON Schema + the
app-kind / AppSpec / capability-profile / conformance-report schemas live there).
