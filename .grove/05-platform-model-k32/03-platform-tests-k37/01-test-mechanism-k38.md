# test-mechanism-k38

**Kind:** work (platform-tests child 1 — the mechanism + exemplar)

## Goal

Stand up the **platform test-declaration mechanism**, mirroring the
manifest/app-kinds template (ADR-0049): an authored `.apiw` family contracted by a
**KDL-Schema** under `schemas/spec-format/` + a **focused in-crate validator** +
a **standing `tests/` guard**, with **one exemplar declaration end-to-end** —
`platforms/macos/tests/app-kinds/gui-app.apiw` resolving `lifecycle` +
`bundle-structure`. De-risks the grammar children 2–4 follow. Schema-validated +
goldens-green, **not executed** (ws9 owns execution).

## Context (node BRIEF D3/D6 + ADR-0049/0046; see `grove-llm brief-chain`)

- **Two declaration families, two sibling schemas (node D6, settled this session).**
  api-semantics and app-kind-obligation declarations are *distinct entities sharing
  only the mechanism* — the ADR-0049 distinct-entity precedent — so they take **two
  sibling schemas**, not one unified envelope. This child authors the
  **app-kind-obligation** half (`app-kind-tests.kdl-schema`); child 3 authors the
  **api-semantics** half (`api-semantics.kdl-schema`) as a sibling submodule of the
  same crate.
- **Crate:** new `platforms/macos/tools/platform-tests` → `apianyware-platform-tests`
  (crate-home convention, ADR-0043). Hosts both families (submodule-per-family:
  `src/app_kind_tests/` now, `src/api_semantics/` in child 3).
- **Grammar** (`tests/app-kinds/<kind>.apiw` — identity = file **stem**):
  ```kdl
  app-kind-tests "<kind>" {
      obligation "<name>" {        // ≥1; one per the kind's test-obligation ref
          doc "..."                // optional one-liner
          fixture "<rel-path>"     // ≥0; inputs the obligation reads (child 4 populates)
          expect "<id>" { doc "..." }   // ≥1; projection-free expectation prose
      }
  }
  ```
- **Three validation layers** (mirror app-kinds): structural (the generic
  KDL-Schema engine via `validate_against_schema`); semantic per-file (obligation
  names unique; `expect` ids unique within an obligation); registry/cross-entity in
  the guard (file stem = top-node name; the obligations a `<kind>.apiw` declares
  **exactly resolve** the `test-obligation` refs in `app-kinds/<kind>/kind.apiw` —
  no orphan body, no unresolved ref). The cross-resolution is the strong invariant:
  the guard loads the `apianyware-app-kinds` registry as a dev-dependency.
- **Exemplar bodies** are the gui-app `docs/test-obligations.md` prose (the written
  source). Projection-free, target-independent.

## Done when

- `schemas/spec-format/app-kind-tests.kdl-schema` authored; schema README updated.
- `apianyware-platform-tests` crate: typed model + parser + semantic checks +
  structural validator (`include_str!` the schema) + a registry loading
  `tests/app-kinds/*.apiw`; in workspace `members`.
- `platforms/macos/tests/app-kinds/gui-app.apiw` authored, resolving `lifecycle` +
  `bundle-structure`, loads + validates + cross-resolves.
- Standing guard `tests/app_kind_tests_registry.rs` green (loads the exemplar,
  cross-resolves vs the app-kind registry, asserts the realized shape + the
  `fixture` grammar branch via a unit test).
- `cargo test -p apianyware-platform-tests`, `cargo check --workspace`, clippy, fmt
  green; **no emit-golden movement** (declarations are not executed).

## Notes

- Mechanism-first: anticipate the `fixture` grammar branch (a known node
  requirement, exercised by an in-crate unit test) so child 2 is pure content, not
  grammar work. Keep `expect` minimal (id + doc) — no speculative check-dispatch
  vocabulary (the k26 "keep carriage minimal" steer); ws9 gives execution meaning.
- `tests/README.md` discharge is child 4's, not this child's.
