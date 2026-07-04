# schemas/spec-format/ — the spec-format KDL Schema contracts

Each file is a language-neutral contract (ADR-0046 §3) written in the KDL Schema Language
(KDL-in-KDL). A Rust crate is *one conforming validator* of each; any KDL tool in any language
can validate against them. All but one describe an **authored `.apiw`** family; the exception,
`machine-ir.kdl-schema`, is the one **machine / derived** contract (the ws8 payoff — the machine
IR flipped to KDL, so it is validated by the *same* engine and language, not a separate JSON
Schema).

- **`machine-ir.kdl-schema`** — the **machine** interchange IR (`platforms/macos/api/<F>/`
  `extracted.kdl` + `resolved.kdl`), an `apianyware_types::ir::Framework` in JSON-in-KDL (ADR-0046
  §5). Workstream 8 (`schema-validation-k149` → `machine-kdl-schema-k153`); validated by
  `apianyware-spec-format`'s `validate_machine_kdl`. Unlike the authored contracts it is an **open
  content model** (the IR is generated + derived + evolving, so it tolerates additive fields while
  pinning the document spine, entity identity, scalar types, and the `checkpoint` enum). One schema
  covers both phases (`resolved` is the same type with later-phase fields, optional). The KDL Schema
  Language's lack of `$ref`/recursion sets its altitude — see the schema header for the full
  rationale (the JiK on-disk shape, the accept-any recursion boundary). Validation runs on the
  format-preserving `kdl` parser at ~2 s/MB, so the umbrella command (`validate-umbrella-k154`) owns
  bounding machine-scale validation.
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
- **`idioms.kdl-schema`** — the §21 per-implementation idiom catalogue
  (`targets/<t>/idioms/catalogue.apiw`): a per-target map from a §21 idiom `category` to this
  target's `construct`, plus — for the categories with an emit projection — the ws3 pattern-kinds
  that category `projects`, each to an `emit` construct (the closed `EmitConstruct` taxonomy, a
  schema `enum`) + a generated `name`. The authored data the shared `emit/pattern_dispatch`
  classifier reads. Workstream 6 (`idioms-k53`); validated by `apianyware-target-model` (the
  `idioms/` submodule). The §21 `category` vocabulary is enforced by that validator, not the schema
  (cf. `capability.kdl-schema`). Identity (`idiom-catalogue "<id>"`) matches the *target* directory,
  the file's grandparent (the `idioms/docs/` home forces the extra `idioms/` level).
- **`policy.kdl-schema`** — the §23 per-platform projection policy
  (`targets/<t>/policies/<platform>/projection.apiw`): the authored `choice`s mapping a projection
  `concern` (an open token) to a point on the §24 direct-call-vs-adapter `spectrum` (the closed
  `SpectrumPoint` ladder, a schema `enum`). Projection-bearing → lives in `targets/`, never
  `platforms/` (the domain rule). Workstream 6 (`policy-adapter-k54`); validated by
  `apianyware-target-model` (the `policy/` submodule). Identity matches the *target* directory (the
  file's great-grandparent) and `platform` the parent directory.
- **`adapter-spec.kdl-schema`** — the §24–§26 per-platform native adapter spec
  (`targets/<t>/adapters/<platform>/spec.apiw`): the authored description of the target's *existing*
  adapter dylib — its `output`, the §26 adapter `role`s + runtime `service`s it provides (each
  service rated by the closed `ServiceStatus` enum), and the §26 `direct-call-policy` (`allow`/`deny`
  categories). Documents the existing library (built by the target grove), it does not redesign the
  §25 ABI. Workstream 6 (`policy-adapter-k54`); validated by `apianyware-target-model` (the
  `adapter_spec/` submodule). The §26 `role` + `service` vocabularies are enforced by that validator,
  not the schema (REFACTOR §26 calls them "suggested" extensible lists; cf. `capability.kdl-schema`).
- **`conformance.kdl-schema`** — the §37 per-platform conformance report's authored **judgment slice**
  (`targets/<t>/conformance/<platform>.apiw`): the per-app-kind `app-support` call (each rated by the
  closed `ConformanceStatus` enum, with optional `exemplar` common apps), the `unsupported` features,
  the `research` items, and the `known-issue`s. The §37 *derived* slice (per-API coverage, common
  app-implementation status) is computed on demand by the `apianyware-conformance` CLI and has no
  `.apiw` form. Workstream 6 (`conformance-k55`); validated by `apianyware-target-model` (the
  `conformance/` submodule). The `app-support` app-kind token is checked against the seven macOS
  app-kinds by that validator, not the schema (a lockstep vocabulary copy keeps the targets domain off
  the platforms domain; cf. `capability.kdl-schema`). Identity matches the *target* directory (the
  file's grandparent) and `platform` the file STEM (platform-in-filename, unlike policy/adapter).

The Rust `apianyware-spec-format` crate is *one conforming validator* of the authored contracts
(its `validate_apiw` step embeds `annotations.kdl-schema`) and of the machine contract (its
`validate_machine_kdl` step embeds `machine-ir.kdl-schema`); any KDL tool in any language can
validate the corresponding file against them. See
[`../docs/spec-format-schema.md`](../docs/spec-format-schema.md) for the rationale and the
cross-language consumption notes. The single tree-walking validation mechanism over every artifact
is `apianyware-validate` (`validate-umbrella-k154`); the `schemas/docs/` validation-model prose is
`validation-docs-k155`.
