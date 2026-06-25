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
  validated by `apianyware-platform-tests`.
- **`api-semantics.kdl-schema`** — the declaration half of a macOS API-facet semantic test: per
  convention facet (ownership / callbacks / threading / errors), the §30 source-semantic weirdness a
  concrete `(receiver, selector)` shape exhibits + projection-free expectations a binding must
  preserve (`platforms/macos/tests/api-semantics/<facet>.apiw`). Workstream 4 (`api-semantics-k40`);
  validated by `apianyware-platform-tests` (sibling family of `app-kind-tests`, same crate). The
  facet-conditional §30 `weirdness` vocabulary is enforced by that validator, not the schema (the
  KDL Schema Language cannot state a conditional enum — cf. `pattern-kinds.kdl-schema`).
- **`target.kdl-schema`** — the §17 per-implementation target descriptor (`targets/<t>/target.apiw`):
  language `family` / `dialect` / `implementation` / `ffi-backend` / `runtime-model` (the one closed
  enum) / `projection-policy` / `adapter-strategy`. Workstream 6 (`target-descriptor-k51`); validated
  by `apianyware-target-model` (the `descriptor/` submodule).
- **`capability.kdl-schema`** — the §20 per-implementation capability profile
  (`targets/<t>/capability.apiw`): a map from a capability `dimension` to a representability `rung`
  (the closed 7-rung ladder, a schema `enum`) across two faces — a `semantic` face that feeds the
  *derived* §7.7 representability status, and an `app-form` face (§36 feasibility) that feeds
  per-app-kind support. Workstream 6 (`capability-k52`, ADR-0051); validated by
  `apianyware-target-model` (the `capability/` submodule). The face-conditional `dimension`
  vocabulary is enforced by that validator, not the schema (cf. `api-semantics.kdl-schema`).

The Rust `apianyware-spec-format` crate is *one conforming validator* of this contract (its
`validate_apiw` step embeds this file); any KDL tool in any language can validate an `.apiw` file
against it. See [`../docs/spec-format-schema.md`](../docs/spec-format-schema.md) for the rationale,
the cross-language consumption notes, and the ws8 boundary (machine-`.json` JSON Schema + the
app-kind / AppSpec / capability-profile / conformance-report schemas live there).
