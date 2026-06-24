# First-class semantic pattern-kinds, with relationships folded in

**Status:** accepted

**Raised by:** `structural-refactoring` grove, workstream 3 (`semantic-model-k27`).

**Relates to:** ADR-0046 (spec format / triad / provenance carriage — instances reuse it),
ADR-0047 (convention heuristics as datalog — the instance-detection tier reuses it). Realized
by the PRD `prd/2026-06-25-semantic-pattern-kind-model.md`.

## Context

REFACTOR §7.5/§12/§31/§32 demand that multi-API **patterns** (bracket, observer, builder, …)
and **relationships** (parent-child ownership, callback destroy-notifiers, collection/element
ownership) become **first-class semantic entities** under `semantic/`, not generator flags.

Today they are neither first-class nor unified. Patterns are a **closed Rust enum**
(`PatternStereotype`, 10 variants) with instances **heuristically detected** by
`annotate/pattern_detection.rs` into a loosely-typed `Framework.api_patterns:
Vec<ApiPattern>` IR list (`participants` is `serde_json::Value`). Relationships **do not exist
in code at all**. There is no *authored* definition of a pattern, no provenance/precedence on
pattern facts (unlike method annotations, which ws2 gave the §28 ladder), and §31/§32 read as if
patterns and relationships were two different kinds of thing.

## Decision

A single **two-level, unified** model:

1. **Two levels — kind vs instance, in different domains.** A **pattern-kind** is a reusable,
   framework- *and* target-independent definition — roles + laws — authored once as
   `semantic/pattern-kinds/<kind>.apiw`. A **pattern-instance** binds a kind's roles to a
   concrete framework's participants and is carried in the **platform spec triad**
   (`platforms/macos/api/<Framework>/resolved.json`), *because an instance is platform
   knowledge*. This keeps `semantic/` projection-AND-platform-independent (the domain's
   defining rule) and rhymes with ws2's neutral-schema-vs-per-family-annotations split.

2. **Relationships fold *into* pattern-kinds — one entity, not two.** A relationship (§31) is a
   **degenerate pattern-kind**: type-roles + ownership/lifetime/invalidation laws, no operation
   sequence. A behavioral pattern (§32) adds operation-roles + ordering/threading laws. One
   schema, one registry, one provenance path serve both. The word *pattern-kind* is therefore
   **broad** — it covers typed edges, not only multi-operation contracts.

3. **Composition via polymorphic participants.** A role binds (in an instance) to a
   **participant ∈ {type, operation/selector, another pattern-instance-ref}**. §32's "patterns
   compose operations *plus relationships*" is exactly the pattern-instance-ref case: a
   `subscription` binds its `destroy` role to a `callback-destroy-notifier` relationship-instance.

4. **Instances are provenance-tiered, superseding the heuristic enum.** The 10 stereotypes become
   an **open authored data registry** (no closed Rust enum). `detect_patterns` becomes **one
   producer** stamping `source=convention`, co-existing with `llm` and `manual` instances under
   the ws2 precedence `manual > llm > convention > extraction`. Detection re-expresses as
   `ascent` datalog (ADR-0047), in `platforms/macos/tools/` (Cocoa-specific), so
   `source=convention:<rule>` falls out of the derivation trace. `Framework.api_patterns` is
   replaced by these first-class instances.

## Consequences

- **Domain boundary held:** `semantic/` carries only universal vocabulary; every
  framework-specific binding (CGPath's bracket, NSView's subview ownership) lands in the
  platform triad. A reviewer who expected §32's instance fields under `pattern-kinds/` is
  redirected by the kind/instance split — the surprising part this ADR exists to record.
- **Less machinery, one stretch:** folding relationships in (decision 2) means relationship
  facts ride the *exact* pattern-instance carriage — no second mechanism, no separate
  relationship store. The cost is a vocabulary stretch ("pattern" now spans typed edges); the
  glossary pins it.
- **Uniform provenance:** pattern/relationship facts gain the same `source`/`confidence`/
  `provenance` stamp + precedence as method annotations — §32's "confidence, manual override
  status" for free. ws3 defines the *carriage*; the cache/regen/review/diff *workflow* + the
  disagreement/precedence audit is **ws5's** (mirrors the k26 seam).
- **Schema ownership:** ws3 authors the pattern-kind `.apiw` KDL Schema + a focused in-crate
  validator (`schemas/spec-format/pattern-kinds.kdl-schema`), mirroring ws2's
  `annotations.kdl-schema`; ws8 owns the machine JSON Schema + validation tooling/CI.
- **Crate homes:** a new `semantic/tools/patterns` crate owns the kind registry + `.apiw`
  parsing; detection is datalog in `platforms/macos/tools/`; carriage extends `types` +
  `resolve`. Consumed by ws6 (target idiom/emit, which projects kinds to target constructs via
  the existing `emit/pattern_dispatch` seam) and informs ws9 (semantic tests).
- **Why this clears the ADR bar:** hard-to-reverse (data model + on-disk domain placement +
  schema), surprising (REFACTOR §31/§32 present patterns and relationships as distinct; this
  unifies them and moves instances out of the directory literally named `pattern-kinds/`), a
  real trade-off (one unified broad entity with less machinery, vs two precise sibling entities
  — the project chose the fold).
