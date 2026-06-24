# pattern-kind-registry-k28

**Kind:** work

## Goal

**ws3 child 1 — the foundation:** author the **pattern-kind registry** — the reusable,
target- and platform-independent *definitions* of every pattern/relationship kind — plus its
schema and loader. This is the layer every later ws3 child builds on (instances reference these
kinds). No pipeline behaviour change and **goldens stay green** (this child adds the kind layer;
it does not yet produce instances or touch emit).

Three deliverables:

1. **`schemas/spec-format/pattern-kinds.kdl-schema`** — the language-neutral KDL Schema for a
   `pattern-kind` `.apiw` file (roles + laws), mirroring how ws2 authored
   `schemas/spec-format/annotations.kdl-schema`. Author it as the *source of truth*; the Rust
   types conform to it (ADR-0046 §3), not vice-versa.
2. **`semantic/tools/patterns`** — a **new crate** (D8): the pattern-kind registry types + `.apiw`
   parser/loader + a focused in-crate validator of the schema's subset (the ws2 `spec-format`
   pattern: there is no maintained KDL-2.0 schema validator, so ship a focused one). Add it to the
   root `Cargo.toml` workspace `members`. Unit-tested: load every `semantic/pattern-kinds/*.apiw`,
   assert role/law shapes.
3. **`semantic/pattern-kinds/*.apiw`** — the authored kind definitions: the ~10 behavioral kinds
   (from the legacy `PatternStereotype` + REFACTOR §32 list: `bracket`/resource-lifecycle,
   `builder`, `observer`, `delegate`, `factory-cluster`, `paired-state`, `target-action`,
   `enumeration`, `error-out`, `subscription`, `two-call-sizing`, `buffer-fill`, `typestate`) **and**
   the structural (relationship) kinds (§31: `parent-child`, `callback-destroy-notifier`,
   `collection-element-ownership`). Each: roles (with `binds=type|operation|pattern` + cardinality)
   + laws drawing from **DP1**'s vocabularies.

## Context (inherited — see `grove-llm brief-chain`)

Design is **settled** — build to it, do **not** re-grill. Read:
- **PRD** `prd/2026-06-25-semantic-pattern-kind-model.md` (the model + the `.apiw`/`resolved.json`
  examples + the staged decomposition this child is #1 of).
- **ADR-0048** (first-class pattern-kind model; the two-level split, the fold, composition).
- **CONTEXT.md → "Semantic model"** section (pattern-kind, role/participant, the broad-word steer).
- The node `BRIEF.md` running log (**D1–D8**) + **doubt pass (DP1–DP4)**.
- **Templates to mirror:** `schemas/spec-format/annotations.kdl-schema` (schema house style);
  `semantic/tools/spec-format/` (the `.apiw` parser + focused-validator crate shape ws2 built).
- **Prefiguring data:** `apianyware-types::annotation::{PatternStereotype, ApiPattern}` + the
  catalog `semantic/docs/api-pattern-catalog.md` (the 10 stereotypes' shapes/constraints — mine it
  for role/law content; it is superseded by child 4's docs rewrite, not this child).

## Done when

- `pattern-kinds.kdl-schema` authored; `semantic/tools/patterns` crate builds + is a workspace
  member; loader+validator parse all authored `.apiw` kinds with passing unit tests.
- Every kind from §31/§32 (behavioral + structural) authored as a `semantic/pattern-kinds/*.apiw`
  file, validating against the schema.
- `cargo build` + the existing test suites + **emit goldens** all green (no pipeline/emit change).
- Discharges the `semantic/pattern-kinds/README.md` TODO (kinds now authored) — leave
  `semantic/README.md` / `semantic/docs/README.md` for child 4 (docs).

## Notes (steers folded from the doubt pass — read DP1/DP2 in the node brief)

- **DP1 — laws are not free prose.** Role-binding and law *values* draw from REFACTOR §30's
  enumerated token sets (ownership: `owned`/`borrowed`/`weak`/`retained`/`autoreleased`/…;
  lifetime; threading; error). Model these as schema enums where they have a fixed vocabulary;
  reserve free text only for a human `doc` field. This is what keeps the registry non-vacuous.
- **DP2 — a structural kind may be single-operation-scoped.** `callback-destroy-notifier`'s roles
  all bind to params of *one* operation; the schema must allow a role to address an operation
  *parameter*, not only a whole operation/type. Model that role-binding granularity here.
- **Identity/home (DP3/DP4) are NOT this child's** — they are *instance* concerns (child 2,
  carriage). This child defines only **kinds**, which have stable authored names (the filename /
  `pattern-kind "<name>"`), so no content-hash is needed at the kind level.
- Keep it kinds-only: **no** instance production (child 3), **no** `resolved.json` carriage
  (child 2), **no** emit/projection (ws6). Goldens-green is the gate that proves this stayed scoped.
