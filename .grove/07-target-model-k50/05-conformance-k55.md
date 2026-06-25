# conformance-k55

**Kind:** work

## Goal

Author the **conformance report** (§37) layer of the target model (ws6 child 5, D7) — the
last authored target-model *entity*, and the first that is a **hybrid authored + derived**
shape. Add a `conformance/` submodule to the shared `target-model` crate (mirroring
`descriptor/` + `capability/` + `idioms/` + `policy/` + `adapter_spec/`), the `conformance.kdl-schema`
contract + focused validator, the authored `targets/<t>/conformance/macos.apiw` for each of
the four live targets, **extend `derive.rs`** with the derived coverage / app-implementation
status, and add the **thin report-generating CLI surface** (built now because this entity has
a consumer — the report — unlike the prior four authored-only layers).

## Context (see `grove-llm brief-chain` — esp. node BRIEF D1/D5/D6/D7; CONTEXT "Conformance report")

- **D1 (the entity split) — conformance is BOTH faces:**
  - **Authored *judgment* slice** (`targets/<t>/conformance/macos.apiw`, committed `.apiw`):
    the §37 `unsupported` features, `research` items, `known issues`, and the **app-kind
    support call** — the human (or accepted-LLM) judgment a machine cannot derive.
  - **Derived slice** (uncommitted → constraint 4, no rot): the §37 **API coverage** and the
    common **app-implementation status**, computed from the generated bindings + the VM-verify
    reports already under `targets/<t>/bindings/macos/reports/`. **Do not commit the derived
    slice** (it is recomputable — the k26/ws4 "keep carriage minimal" steer).
- **§37 statuses:** `pass` / `partial` / `research` / `unsupported` / `failed` / `skipped`. A
  validator **cross-checks authored claims against the derived reality** (e.g. an authored
  `unsupported` must not contradict a passing VM-verify report) — the novel bit of this child.
- **D5 (crate home):** extend the **same** `targets/_shared/tools/target-model` crate — add the
  `conformance/` submodule (parse + serde + focused validator + registry, the three-layer
  pattern) AND extend `derive.rs` (today only the representability floor) with the
  conformance-coverage / app-status derivation. ws6 authors `conformance.kdl-schema` + the
  focused validator; **ws8** owns the *machine* JSON Schema for the derived report. The thin
  derivation-surfacing **CLI** is built here (its consumer — the report — now exists; the prior
  children deferred a CLI because nothing consumed them yet).
- **D6 / D7 (boundaries):**
  - **ws9 seam (the ws4 D3 mirror):** ws6's conformance `binding tests` field *references* ws9
    test results — it does **not** build the runner. Per-target execution hooks are ws6's; the
    multi-layer runner + TestAnyware/AppSpec driver are ws9's. Declare-now / execute-later.
  - **ws8 seam:** authored `.apiw` KDL Schema + focused validator here; machine JSON Schema for
    the derived report is ws8's (the standing ws2/3/4/5 seam).
- **First action:** read REFACTOR §37 (conformance report) + survey each target's existing
  `bindings/macos/reports/` (the VM-verify reports the derived slice computes from) so the
  derivation reads *what is actually there*, and settle the authored `conformance/macos.apiw`
  shape (one file per target×platform, the `conformance/<platform>.apiw` partition — platform
  in the **filename** here, unlike policy/adapter's platform **directory**).

## Done when

- `target-model` crate gains `conformance/` (parse/serde/validator + registry) + a `derive.rs`
  extension (coverage / app-status derivation) + re-exports.
- `schemas/spec-format/conformance.kdl-schema` authored (§37 statuses) + README registered.
- `targets/{racket,chez,gerbil,sbcl}/conformance/macos.apiw` authored (judgment slice only),
  each parsing + validating green and grounded in each target's real coverage + VM-verify
  reality.
- The thin report-generating CLI surface exists and emits a §37 report (authored judgment +
  derived coverage/app-status), with the authored-vs-derived cross-check validator.
- Goldens unmoved (the report is a new derived artifact, not an emit change); workspace +
  clippy + fmt green.

## Notes

- Commit handle: `conformance-k55`. Remaining ws6 children after this (grow lazily): 6
  mapping + target docs, 7 bundler reshape + guide resync (D7).
- This is the **last authored entity** but introduces the **derived** target-model machinery
  (`derive.rs` coverage) + the first ws6 CLI surface — heavier than the prior four authored-only
  children. The authored slice stays minimal (judgment only); resist committing derivable facts
  (constraint 4) or building the ws9 runner.
- Per-target richness is affordable because the LLM makes it so ([[maximize_target_idiom_and_perf]]);
  each target's judgment slice is grounded in its real shipped binding + VM-verify reports.
