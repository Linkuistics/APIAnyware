# semantic-model-k27

**Kind:** planning

## Goal

**Workstream 3** of the `structural-refactoring` grove: design the **semantic model** —
**pattern-kinds** and **relationship entities** as *first-class* semantic entities under
`semantic/`, plus the semantic-vocabulary docs. ws2 (`spec-format-k16`) shipped the `.apiw`
KDL DSL + the spec triad these entities will be authored/expressed in; ws3 defines **what
the semantic vocabulary is** and **how patterns + relationships are modelled, authored,
stored, resolved, and consumed by emit** — target-independently (projection lives in
targets/, never here).

This is a **grilling** leaf: interview to settle the design (one question at a time, WDYT +
running log per `driving.md`), raise ADRs sparingly, update `CONTEXT.md` inline as terms
resolve, MAY write a PRD at a genuine agreement point, then **decompose** into staged,
buildable + goldens-green child leaves (D4). Do **only** the first child this session if it
converts to a node.

## Context (inherited — see `grove-llm brief-chain`)

- **Spine is ready:** ws1 (skeleton) + ws2 (spec-format) complete. The `.apiw` DSL, KDL
  Schema, per-family triad, and the `ascent` convention-datalog tier all shipped
  (ADR-0046/0047; root brief **Spec-format outcomes**). Content rewrites land **in place**.
- **REFACTOR.md (source of truth):** §7.5 *Patterns are first-class*, §12 *Semantic model*,
  §13 *Source platform semantic specifications*, §30 *Source semantic weirdness to model*,
  **§31 *Relationship entities***, **§32 *Pattern library***.
- **Prefiguring code (the heuristic ancestor of first-class patterns):**
  `apianyware-types::annotation::{ApiPattern, PatternStereotype}` (10 stereotypes —
  resource-lifecycle, observer-pair, transaction-bracket, …) + `annotate/pattern_detection.rs`
  (`detect_patterns` → `api_patterns`). ws3 decides how these heuristic patterns relate to
  authored first-class pattern-kinds (formalize? supersede? co-exist with provenance?).
- **Placeholders to populate / discharge:** `semantic/pattern-kinds/README.md` (ws3 marker),
  `semantic/README.md`, `semantic/docs/README.md` (TODO.md ws3 row); semantic vocab docs under
  `semantic/docs/`.
- **Glossary:** `CONTEXT.md` (read every session) — add a "Semantic model" section as terms
  resolve (pattern-kind, relationship entity, semantic vocabulary, first-class).

## Grilling agenda (open — settle, don't assume)

- **Pattern-kind model:** what *is* a pattern-kind as a first-class `.apiw` entity? Schema
  (participants/roles, constraints, ordering, threading/ownership)? Relationship to the
  existing `PatternStereotype` enum + `detect_patterns` heuristics (formalized, replaced, or
  a provenance-tiered overlay like the convention facts)?
- **Relationship entities (§31):** the model for explicit relationships (parent/child, owner,
  lifecycle-coupled, …) beyond types+operations; how authored, where stored (own `.apiw`
  family? per-framework?), how resolved, and how patterns *compose* operations + relationships
  (§32 close).
- **Authoring + storage + resolve:** where do pattern-kinds / relationships live on disk
  (`semantic/pattern-kinds/*.apiw`?), how do they enter the resolve graph, and what does the
  generator/emit consume? Reuse the ws2 triad/precedence machinery vs a new seam.
- **Provenance/confidence reuse:** do pattern/relationship facts carry the ADR-0046 §4
  carriage (and is per-fact provenance here also a **ws5** rollout, mirroring k26)?
- **Schema (ws8 seam):** does ws3 author the `.apiw` KDL Schema for pattern-kinds (like ws2
  did for `annotations.apiw`), or defer to ws8?
- **Crate home:** new `semantic/tools/<crate>` for pattern/relationship parsing+resolve, or
  fold into `spec-format`/`resolve`/`enrich`?

## Done when

Design settled (running log + inline `CONTEXT.md`); ADRs raised where warranted; PRD if a
genuine agreement point; the leaf **decomposed** into staged child leaves (buildable +
pipeline/goldens-green at each step), with only the first child done this session. Discharges
the `TODO (workstream 3)` markers as its children land.

## Notes

Lazy decomposition: do not pre-spawn all of ws3's children — grow as earlier ones retire
(root brief). ws3 is consumed by ws6 (target idiom/emit) and informs ws9 (semantic tests);
keep the model target-independent (projection is targets/, never `semantic/`).
