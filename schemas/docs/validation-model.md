# The validation model

How every artifact in the repository is formally validated. Authored by **workstream 8**
(`schema-validation-k149`, leaf `validation-docs-k155`); the decisions it records are the
node BRIEF running log **D4–D8/D10** and **ADR-0046 §5**.

The one-line version: **one schema language (KDL Schema), one generic engine, three
complementary layers.** There is no JSON Schema anywhere in the stack.

## One schema language, one engine

Every schema in `schemas/spec-format/` — all thirteen — is written in the **KDL Schema
Language** (KDL-in-KDL; [kdl.dev SCHEMA-SPEC](https://github.com/kdl-org/kdl/blob/main/SCHEMA-SPEC.md)),
and every validator delegates the schema-checking to **one** generic engine,
`apianyware_spec_format::validate_against_schema` (homed in `semantic/tools/spec-format` —
the schema-*language* engine is a semantic-domain concern). A schema is the **authoritative
contract**; the Rust serde types are *one conforming implementation* of it, never its source
of truth. Any KDL tool in any language can parse a `.kdl-schema` (it is plain KDL 2.0) and
validate the corresponding file against it.

This uniformity is the **ws8 payoff.** Every prior workstream (ws2–ws6) authored its `.apiw`
KDL-Schema but deferred *the machine `extracted.json` / `resolved.json`* to ws8 as "the one
artifact that needs a JSON Schema." The ws8 machine-format spike (`machine-format-spike-k150`)
measured a non-format-preserving KDL codec the k17 retreat never tested, cleared the perf bar,
and the machine IR **un-retreated to KDL** (ADR-0046 §5, amended in place). The moment the
machine IR became KDL, the machine-JSON-Schema seam **dissolved**: `extracted.kdl` /
`resolved.kdl` are validated by the *same* engine and language as everything else
(`schemas/spec-format/machine-ir.kdl-schema`, `machine-kdl-schema-k153`). "KDL everywhere,
one schema language" is literally true.

> **Why not JSON Schema?** A JSON Schema over a JSON projection was rejected in grilling
> (ADR-0046 §3): it would reintroduce JSON and force every non-Rust consumer to reproduce the
> KDL→JSON projection. Keeping one language means one mental model, one validator to reason
> about, and cross-language validation for free.

### The KDL-2.0 tooling gap

There is **no maintained KDL-2.0 schema validator.** The KDL Schema Language is frozen at
SCHEMA-SPEC 1.0 (2021), "not finalized" for KDL 2.0, and its only Rust validator
(`kdl-schema-check`, 2022) targets the incompatible KDL-1.0 stack. So `validate_against_schema`
interprets the **subset** of the language the contracts actually use — `node` / `value` /
`prop` / `children`, occurrence and value-cardinality `min`/`max`, scalar `type`, `enum`, and
default-deny `other-nodes-allowed` / `other-props-allowed`. Semantics the KDL Schema Language
cannot express (conditional enums, `$ref`, recursion) are layered on top by each producing
crate as focused in-crate checks — e.g. the facet-conditional §30 `weirdness` vocabulary, or
the machine schema's accept-any recursion boundary. See `machine-ir.kdl-schema`'s header for
how the recursion limit sets that schema's altitude.

## Two artifact populations: authored vs. machine

Validation splits the repository's KDL along the axis it is generated on.

| | **Authored `.apiw`** | **Machine IR** |
|---|---|---|
| Files | `annotations.apiw`, `target.apiw`, `capability.apiw`, `pattern-kinds/*.apiw`, … (12 layouts) | `extracted.kdl`, `resolved.kdl` under `platforms/macos/api/<F>/` |
| Committed? | **Yes** — the durable source of truth | **No** — derived + gitignored (constraint 4) |
| Schema | its own `schemas/spec-format/<x>.kdl-schema` | `machine-ir.kdl-schema` (one schema, both phases) |
| Content model | **closed** — pins its vocabulary | **open** — tolerates additive fields (the IR evolves), pins the spine + identity + scalar types + the `checkpoint` enum |
| Validated | **by default**, always | **only under `--machine`** (opt-in) |
| Cost | fast — small files, format-preserving parse is cheap at this scale | **minutes-scale** — ~2 s/MB on the format-preserving `kdl` parser; a flattened `resolved.kdl` can exceed 80 MB |

The machine IR is open-content because it is generated, derived, and still evolving; the
authored contracts are closed because a stray node in hand-written data is a mistake, not a
new field. The cost asymmetry is why machine validation is opt-in — see *Where validation
runs* below.

## Three complementary layers

Validation is not one command; it is three layers that check different things. Each is the
right tool for its job, and they overlap deliberately.

### 1. The `apianyware-validate` umbrella — "validate *every* artifact, in one command"

The single tree-walking command, homed at the crate **`schemas/tools/validate/`**
(`validate-umbrella-k154`; D6 — `schemas/` is an active tool home, a crate lives under the
domain it serves). It walks the repo, dispatches every authored `.apiw` to the KDL-Schema
validator owned by its producing crate (the twelve `validate_*` functions ws2–ws6 authored),
and reports per-class results. It is a **lean driver**: it embeds no schema and re-implements
no validation — all schema-checking is delegated to the same twelve validators (and the same
generic engine) the in-crate guards use.

Two design points make it trustworthy:

- **Coverage as a guard.** Rather than globbing each known class, it walks *every* `.apiw` and
  reports any file matching **no** dispatch rule as a **failure** (exit 1, "unclassified").
  This inverts "validate what I know about" into "prove I know about everything" — a new
  artifact type added without wiring the umbrella cannot silently escape the
  "validate every artifact" promise. This is the enforcement behind the ws8 done-bar.
- **Machine IR is opt-in** (`--machine`; D10). By default the umbrella validates only the
  committed authored artifacts — fast, zero precondition, runnable on a fresh checkout with no
  pipeline output. `--machine` additionally validates the derived machine IR in **one run**;
  because that is minutes-scale, it streams per-file progress (cheapest first, so it is never a
  silent hang) and emits an actionable "run the pipeline first" precondition error (exit 2)
  when the IR is absent, mirroring `make lint-annotations`.

Exit codes: **0** clean · **1** any validation failure *or* an unclassified `.apiw`
(the coverage-gap guard) · **2** usage / precondition error. Run `apianyware-validate --list`
to see the classes and per-class file counts; `--json` for a machine-readable summary.

### 2. The per-crate `tests/*_registry.rs` guards — the `cargo test` story

Each producing crate ships an **in-crate registry test** that loads and validates **every real
authored file of its class** — one per entity (`apianyware-target-model`, for instance, carries
`target_registry.rs`, `capability_profiles.rs`, `idiom_catalogues.rs`, `projection_policies.rs`,
`adapter_specs.rs`, `conformance_reports.rs`; the exact filenames vary — `…_registry.rs` /
`…_load.rs` / `…_validation.rs` — but `tests/*_registry.rs` is the grove's shorthand for the
whole family). These are the exhaustive in-crate guards; they run under `cargo test` alongside
the crate's unit tests and gate every ordinary build. The umbrella is the *runnable driver* over
the same validators; the registry tests are the *test-suite* face. The two share the validators
and cannot disagree.

For the machine schema, the cheap `cargo test` guard is bounded-work by design:
`apianyware-spec-format/tests/machine_schema_validation.rs` validates a small materialized
sample so the exhaustive minutes-scale check stays behind the umbrella's `--machine`.

### 3. The `lint-annotations` drift gate — freshness, not validity

A **different kind of check**: not "is this file schema-valid?" but "has the authored overlay
drifted from the surface it annotates?" (ADR-0050 §5; ws5). `apianyware-analyze annotations
stale` set-diffs each family's committed `annotations.apiw` against the current **resolved API
surface** (`resolved.kdl`) for orphaned / new-surface / shape-changed slots, exiting 1 when an
overlay needs regenerating; `annotations audit` reports per-family disagreement + per-tier win
distribution (informational, exit 0). It reads the derived `resolved.kdl`, so it shares the
machine IR's "run the pipeline first" precondition. Schema validity and overlay freshness are
orthogonal — an overlay can be perfectly schema-valid and completely stale — so this is a
standing third gate, not a subset of layer 1.

## Where validation runs

**Locally, via `make` + `cargo test`. CI is deferred** (D5). There is no CI —
`.github/workflows/` is absent — so a GitHub Actions gate would be net-new infrastructure, a
separately-scoped concern outside ws8's lean mandate (mirroring ws5's lean-mechanism stance,
ADR-0050). The runnable surface:

- **`make validate`** → `apianyware-validate` (authored artifacts only; fast; the everyday
  gate). Machine-IR validation is **not** in this target — run `apianyware-validate --machine`
  by hand when you want it.
- **`make lint-annotations`** → `annotations stale` + `annotations audit` (the drift gate;
  needs the pipeline to have run).
- **`cargo test`** → the per-crate `tests/*_registry.rs` guards.

If CI is ever stood up, these three commands are the gates it would run; nothing about the
mechanism changes.

## Derived reports stay on-demand

ws8 schemas the machine **IR** — the core data model, a stable shape — but **not** ad-hoc
derived reports (D8). Conformance coverage and capability/representability derivations stay
**derived, uncommitted, and un-schema'd** (constraint 4; consistent with ws6/ws7, whose
indexes *point at* the report rather than duplicating it): the per-target coverage and
app-implementation status are computed on demand by the `apianyware-conformance` CLI, never
persisted. A report has no `.apiw` / `.kdl` form and nothing validates it.

**Reopen trigger (recorded for a future session):** *IF a real machine consumer of a derived
report materializes* — something that reads a committed report as input rather than regenerating
it — then that report earns a committed form and a schema, and this decision reopens. Until
then, reports are computed, shown, and discarded.

## Deferred performance trigger

Machine-IR validation runs on the **format-preserving** `kdl` parser (~2 s/MB) because that is
the parser the generic engine is built on. A `serde_json::Value`-based validation engine that
reused the schema *model* (not the `KdlNode` document model) would cut machine-IR validation
**~50×** by bypassing the format-preserving parse — the clean fix. But it is **new machinery**,
and D4's precedent (the native-serde-JiK codec) is the template: build the fast path only if
`--machine` wall-time is ever actually *felt*, not speculatively. The bound today is the
opt-in flag, not the parser.

## Map: which schema validates what

The authoritative per-schema table (all thirteen contracts, their files, and their producing
crates) lives in [`../spec-format/README.md`](../spec-format/README.md). The authored `.apiw`
overlay's contract and its cross-language consumption notes are in
[`spec-format-schema.md`](spec-format-schema.md). This document is the model that ties them
together.
