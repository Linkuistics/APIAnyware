# Spec-format schema — the `.apiw` contract

Authored by **workstream 2** (`spec-format-k16` → leaf `kdl-schema-k19`); the rest of the
validation model is workstream 8 (ws8). This doc explains *which* schema validates the authored
overlay, *why* it is language-neutral, and *how* a non-Rust tool consumes it.

## What it validates

| Schema | Validates | Authored by |
|--------|-----------|-------------|
| [`../spec-format/annotations.kdl-schema`](../spec-format/annotations.kdl-schema) | the authored `annotations.apiw` overlay | **ws2** (here) |
| [`../spec-format/machine-ir.kdl-schema`](../spec-format/machine-ir.kdl-schema) | machine `extracted.kdl` / `resolved.kdl` | **ws8** |
| the other eleven `../spec-format/*.kdl-schema` | pattern-kinds, platform manifest, app-kinds, platform tests, the six target-model entities | **ws3–ws6** |

The spec triad is `extracted.kdl` → `annotations.apiw` → `resolved.kdl` per API family
(`platforms/macos/api/<Framework>/`). The **whole** triad is KDL (ADR-0046 §5); the machine
artifacts get a **machine KDL-Schema** — reusing the generic KDL-Schema engine, one schema
language — shipped by ws8 (`machine-kdl-schema-k153`). The full per-schema table is
[`../spec-format/README.md`](../spec-format/README.md); the model tying the layers together is
[`validation-model.md`](validation-model.md). (Common **AppSpecs** are the external AppSpec
project's format and are *not* schema'd here — ADR-0052.)

## Language-neutral by design (ADR-0046 §3)

The schema is the **authoritative contract**, written in the **KDL Schema Language** (KDL-in-KDL;
[kdl.dev SCHEMA-SPEC](https://github.com/kdl-org/kdl/blob/main/SCHEMA-SPEC.md)). The Rust serde
types in `apianyware-types::annotation` are *one conforming implementation* of this contract, **not
its source of truth**. A schema written in JSON Schema over a JSON projection was rejected during
grilling: it would reintroduce JSON and force every consumer to reproduce the KDL→JSON projection.

### How other languages consume it

`annotations.kdl-schema` is itself a KDL document. Any KDL implementation (Rust, JS, Python, Ruby,
Go, …) can:

1. **Parse the schema** with its own KDL parser — it is plain KDL 2.0.
2. **Validate** an `.apiw` file against it, either with a KDL Schema Language validator in that
   language, or by interpreting the contract directly (it is small and declarative — node
   definitions with occurrence/cardinality bounds, scalar `type`s, and `enum` value sets).

The enum value spellings (`copy`, `async_copied`, `main_thread_only`, `llm`, `high`, …) are the
serde `snake_case` tokens shared with the machine IR, so an `.apiw` value's spelling always
matches its `extracted.kdl` / `resolved.kdl` spelling.

## The validator step (and the KDL-2.0 tooling gap)

The `apianyware-spec-format` crate exposes `validate_apiw(name, text)` — the §29 "validator" step,
wired here and called by the pipeline cutover (`pipeline-cutover-k20`). It embeds the schema
(`include_str!` from this domain) so the validator and the contract can never drift, and reports
violations as located `miette` diagnostics that name the offending node/value.

It is an **in-crate validator**, by necessity: there is **no maintained KDL-2.0 schema validator**.
The KDL Schema Language is frozen at SCHEMA-SPEC 1.0 (2021) and is "not finalized" for KDL 2.0; its
only Rust validator (`kdl-schema-check`, 2022) targets the KDL-1.0 `kdl`/`knuffel` stack, which is
incompatible with this repo's KDL-2.0 `kdl = 6.3.4`. So the crate interprets the **subset** of the
KDL Schema Language the `.apiw` contract uses — `node` / `value` / `prop` / `children`, occurrence
and value-cardinality `min`/`max`, scalar `type`, `enum`, and the default-deny
`other-nodes-allowed` / `other-props-allowed`. **Adopting or authoring a general KDL-2.0 schema
validator is ws8's call** (it owns the validation tooling/CI); this is the validator step until then.

Evidence the contract is correct against real content: the crate's test suite validates the
fixtures (`tests/fixtures/{valid,invalid}.apiw`), the output of the k18 writer (`write_apiw`), and
**every committed `_llm-annotations` file folded into `.apiw`** (152 files at time of writing).

## The ws2 boundary (how the seam actually resolved)

ws2 authored only the `.apiw` overlay schema above and its `validate_apiw` step. Everything ws2
originally deferred "to ws8" landed differently than this doc first predicted, and the record now
stands as:

- The schemas for the **other authored artifacts** (pattern-kinds, platform manifest, app-kinds,
  platform tests, the six target-model entities) were each authored by **the workstream that owns
  the data** (ws3–ws6), not ws8 — every producing crate ships its schema + validator together.
- The **machine KDL-Schema** for `extracted.kdl` / `resolved.kdl` *was* ws8's
  (`machine-kdl-schema-k153`), reusing the generic engine — the machine-JSON-Schema seam dissolved
  when the machine IR un-retreated to KDL (ADR-0046 §5).
- The **validation umbrella** (`apianyware-validate`) was ws8's (`validate-umbrella-k154`); **CI
  was deferred** — none exists, so it stays net-new infrastructure (D5).
- Common **AppSpecs** are *not* schema'd here at all — `#lang app-spec` is the external AppSpec
  project's format and owns its own validation (ADR-0052).

The full picture is [`validation-model.md`](validation-model.md).
