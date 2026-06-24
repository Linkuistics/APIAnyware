# PRD — Semantic pattern-kind model (patterns + relationships, first-class)

**Date:** 2026-06-25
**Status:** Agreed (grilling complete; see `.grove/04-semantic-model-k27.md` running log D1–D8)
**Grove:** `structural-refactoring`, workstream 3 (`semantic-model-k27`)
**Decisions:** [ADR-0048](../adr/0048-first-class-semantic-pattern-kind-model.md)
**Builds on:** [ADR-0046](../adr/0046-spec-interchange-format-kdl-everywhere.md) (`.apiw` + triad +
provenance carriage) · [ADR-0047](../adr/0047-convention-heuristics-as-datalog-rules.md) (detection
as datalog)

## Problem

REFACTOR §7.5/§12/§31/§32 want multi-API **patterns** and **relationships** to be *first-class
semantic entities* under `semantic/`. Today they are not: patterns are a closed `PatternStereotype`
Rust enum with instances heuristically detected into an untyped `Framework.api_patterns` IR list (no
authored definition, no provenance/precedence); relationships do not exist in code; and §31/§32 read
as two distinct entity classes. This workstream makes them first-class, authored, provenance-tiered,
and **unified**. It is consumed by ws6 (target idiom/emit) and informs ws9 (semantic tests).

## Goals

1. A reusable, authored, target- *and* platform-independent definition of each pattern/relationship.
2. Concrete per-framework occurrences carried as provenance-tiered facts in the platform triad.
3. One unified model + one mechanism for patterns and relationships (not two parallel systems).
4. §32 composition (patterns reference relationships) expressible.
5. Reuse of the ws2 `.apiw` / triad / provenance machinery — minimal new seam.

## The model

### Two levels: kind (semantic/) + instance (platforms/) — ADR-0048 D1

- **Pattern-kind** — `semantic/pattern-kinds/<kind>.apiw`: roles + laws, framework- and
  target-independent. The reusable definition.
- **Pattern-instance** — `platforms/macos/api/<Framework>/resolved.json`: a kind's roles bound to
  concrete participants, provenance-stamped. Platform knowledge, so it lives in the platform triad,
  *not* in `semantic/`. Supersedes `Framework.api_patterns`.

### Relationships fold into pattern-kinds — ADR-0048 D2/D4

A relationship (§31) is a **degenerate pattern-kind**: type-roles + ownership/lifetime/invalidation
laws, no operation sequence. A behavioral pattern (§32) adds operation-roles + ordering/threading
laws. One schema, one registry, one provenance path. The 10 legacy stereotypes become this open
**authored data registry** — no closed Rust enum.

### Roles, participants, composition — ADR-0048 D5

A kind declares **roles**; an instance binds each role to a **participant ∈ {type,
operation/selector, another pattern-instance-ref}**. The ref case realizes §32's "compose operations
*plus relationships*".

```kdl
// semantic/pattern-kinds/bracket.apiw  — a BEHAVIORAL kind
pattern-kind "bracket" {
    doc "acquire → operation* → release; release runs even if operations fail."
    role "acquire"   binds="operation" cardinality="1"
    role "release"   binds="operation" cardinality="1"
    role "operation" binds="operation" cardinality="*"
    law "ordering"      "acquire precedes all operations; release follows all operations"
    law "release-total" "release must run even on operation failure"
}

// semantic/pattern-kinds/parent-child.apiw  — a STRUCTURAL kind (the §31 'relationship')
pattern-kind "parent-child" {
    doc "An ownership edge between two object types."
    role "parent" binds="type" cardinality="1"
    role "child"  binds="type" cardinality="1"
    law "ownership"     "parent_to_child and child_to_parent ownership directions"
    law "invalidation"  "child removed from parent ends the relationship"
}
```

```jsonc
// platforms/macos/api/CoreGraphics/resolved.json  — INSTANCES (provenance-stamped)
"patterns": [
  { "kind": "bracket",
    "roles": { "acquire": {"op": "CGPathCreateMutable"},
               "release": {"op": "CGPathRelease"} },
    "source": "convention", "confidence": "high",
    "provenance": "convention:create_release_pair" },
  { "kind": "subscription",
    "roles": { "register": {"op": "addObserver:..."},
               "destroy":  {"pattern-ref": "AppKit#notif-destroy-1"} },  // §32 compose
    "source": "llm", "confidence": "medium",
    "provenance": "Notification Programming Guide" }
]
```

### Instances are provenance-tiered — ADR-0048 D4 (reuses ADR-0046 §4 / ADR-0047)

Three producers, ws2 precedence `manual > llm > convention > extraction`:
- **convention** — `detect_patterns` re-expressed as `ascent` datalog in `platforms/macos/tools/`
  (Cocoa-specific); `source=convention:<rule>` falls out of the derivation trace.
- **llm** — guide-derived (the harder relationships are llm/manual-dominated).
- **manual** — authored override in `annotations.apiw`.

### Schema + crate homes — ADR-0048 D7/D8

- **Schema:** ws3 authors `schemas/spec-format/pattern-kinds.kdl-schema` (KDL Schema Language) + a
  focused in-crate validator, mirroring ws2's `annotations.kdl-schema`.
- **Crates:** new `semantic/tools/patterns` (kind registry + `.apiw` parse); detection datalog in
  `platforms/macos/tools/`; instance carriage extends `types` + `resolve`.

## Decomposition (staged; each buildable + goldens-green; D4 skeleton-first)

The node's children build to this design (do **not** re-grill). Materialized **lazily** — only the
first child exists now; later children are grown as earlier ones retire (root brief; task Notes).

1. **kind schema + registry + definitions** — `pattern-kinds.kdl-schema`; the `semantic/tools/patterns`
   crate (loader/validator); the ~10–16 `semantic/pattern-kinds/*.apiw` definitions (behavioral +
   structural). Buildable, no pipeline behaviour change, goldens green. **← first child this grove.**
2. **instance carriage** — extend `types` + `resolve` so `resolved.json` carries first-class
   pattern-instances referencing kinds (provenance-stamped), replacing `api_patterns`. Goldens green.
3. **convention detection (datalog)** — port `detect_patterns` to `ascent` rules in
   `platforms/macos/tools/`, producing `source=convention` instances. Goldens green.
4. **semantic vocabulary docs** — author `semantic/docs/{overview,pattern-model,…}.md`; rewrite/supersede
   `api-pattern-catalog.md`; discharge the ws3 placeholder READMEs + `TODO (workstream 3)` markers.

## Out of scope (other workstreams)

- **Per-fact provenance workflow** (cache / regen / review-accept / diff; disagreement+precedence
  audit) — **ws5** (ws3 defines carriage only; mirrors the k26 seam, D6).
- **Projection** of kinds to target idioms (the `emit/pattern_dispatch` rendering) — **ws6**.
- **Machine JSON Schema** (`extracted.json`/`resolved.json`) + validation tooling/CI — **ws8**.
- **Semantic-layer tests** (multi-layer test model) — **ws9**.
