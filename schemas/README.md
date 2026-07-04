# schemas/ — formal validation

The `schemas/` domain holds the formal schemas that validate every KDL artifact in the
repository (REFACTOR.md §8): the machine interchange IR (`extracted.kdl` / `resolved.kdl`),
the authored `.apiw` semantic overlay, the pattern-kind registry, the platform manifest +
app-kinds + platform tests, and the six target-model entities (descriptor, capability profile,
idiom catalogue, projection policy, adapter spec, and conformance *judgment*). This is the
"obvious place for schemas" the success criteria demand (§45.13) and the home the root README
points validation at (§11).

Two things are deliberately **not** here: common **AppSpecs** are the external AppSpec
project's `#lang app-spec` format and it owns its own validation (ADR-0052), and **derived
reports** (conformance coverage, capability/representability) stay computed-on-demand and
un-schema'd (constraint 4) — only conformance's *authored judgment slice* has a schema. See
[`docs/validation-model.md`](docs/validation-model.md).

## Layout

- **`spec-format/`** — the **thirteen KDL-Schema contracts**, one schema language over every
  KDL artifact (ADR-0046 §3/§5). Twelve validate an **authored `.apiw`** family (the overlay,
  the pattern-kind registry, the platform manifest + app-kinds + platform tests, and the six
  target-model entities); one — `machine-ir.kdl-schema` — validates the **machine** IR
  (`extracted.kdl` / `resolved.kdl`). Each is authored by the workstream that owns its data
  and validated by that workstream's in-crate validator. See
  [`spec-format/README.md`](spec-format/README.md) for the per-schema table.
- **`tools/validate/`** — **`apianyware-validate`**, the one tree-walking validation command
  over every artifact (`make validate`). A lean driver over the twelve per-crate validators —
  it embeds no schema and re-implements no validation.
- **`docs/`** — the validation-model prose. Start at
  [`docs/validation-model.md`](docs/validation-model.md).

## The validation model, in one line

**One schema language (KDL Schema), one generic engine
(`apianyware_spec_format::validate_against_schema`), three complementary layers** — the
`apianyware-validate` umbrella, the per-crate `tests/*_registry.rs` guards, and the
`lint-annotations` drift gate. Validation runs locally (`make validate` + `cargo test`); CI is
deferred (none exists). There is **no JSON Schema** anywhere — when the machine IR un-retreated
to KDL (ADR-0046 §5), the machine-JSON-Schema seam every prior workstream deferred here
dissolved. Full model: [`docs/validation-model.md`](docs/validation-model.md).
