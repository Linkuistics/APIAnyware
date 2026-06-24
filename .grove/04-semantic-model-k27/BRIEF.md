# semantic-model-k27 — brief

**Kind:** node brief (was a planning leaf; grilling complete 2026-06-25 — decomposed)

## Goal

**Workstream 3** of the `structural-refactoring` grove: realize the **semantic model** —
**patterns** and **relationships** as *first-class* semantic entities under `semantic/`, plus
the semantic-vocabulary docs. The **design is settled** (grilling complete — see the running
log D1–D8 + the doubt pass DP1–DP4 below); the child leaves **implement** it. Consumed by ws6
(target idiom/emit) and informs ws9 (semantic tests); the model stays target-independent
(projection lives in `targets/`, never here).

## Settled design (the children build to this — do NOT re-grill)

- **PRD:** [`prd/2026-06-25-semantic-pattern-kind-model.md`](../../prd/2026-06-25-semantic-pattern-kind-model.md) — the model + `.apiw`/`resolved.json` examples + the staged decomposition.
- **ADR-0048** — first-class pattern-kind model: two-level kind/instance split; relationships
  fold *into* pattern-kinds (one unified entity); composition via polymorphic participants.
- **CONTEXT.md → "Semantic model"** section — pattern-kind (broad), pattern-instance, role/
  participant, convention-tier detection, the crate homes.
- **Builds on:** ADR-0046 (`.apiw`/triad/provenance carriage) · ADR-0047 (detection as datalog).

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

## Decomposition (staged; each buildable + goldens-green; D4 skeleton-first)

Materialized **lazily** — only child 1 exists as a file now; grow 2–4 with `leaf-add` as
earlier ones retire (task Notes; do **not** pre-spawn all). The PRD carries the same list.

1. **`pattern-kind-registry-k28`** *(live — first child)* — the foundation: the
   `pattern-kinds.kdl-schema`, the new `semantic/tools/patterns` crate (loader/validator), and
   the ~10–16 authored `semantic/pattern-kinds/*.apiw` kind definitions (behavioral + structural).
   No instances, no pipeline/emit change; goldens green.
2. **instance carriage** *(grow later)* — extend `types` + `resolve` so `resolved.json` carries
   first-class pattern-instances referencing kinds (provenance-stamped), replacing
   `Framework.api_patterns`. **Owns DP3 (cross-framework home rule) + DP4 (structural/content-
   derived instance identity).** Goldens green.
3. **convention detection (datalog)** *(grow later)* — port `detect_patterns` to `ascent` rules
   in `platforms/macos/tools/` producing `source=convention` instances (D3, ADR-0047). Goldens green.
4. **semantic vocabulary docs** *(grow later)* — author `semantic/docs/{overview,pattern-model,…}.md`;
   rewrite/supersede `api-pattern-catalog.md`; discharge `semantic/README.md` +
   `semantic/docs/README.md` + the remaining `TODO (workstream 3)` markers.

After child 4 retires, ws3 has no live leaf → the retire-cascade asks before treating workstream 3
done (promote anything durable upward; the `Out of scope` rows in the PRD already name ws5/6/8/9).

## Decisions (running log)

**D1 — Two-level pattern model: kind (semantic/) + instance (platforms/).** A
**pattern-kind** (`bracket`, `observer`, …) is the reusable, framework- *and*
target-independent definition — its role set, constraint/law schema — authored once
in `semantic/pattern-kinds/<kind>.apiw`. A **pattern-instance** binds a kind's roles
to a concrete framework's methods (CGPath's bracket = acquire `CGPathCreateMutable`
/ release `CGPathRelease`) and is carried in the **platform spec triad**
(`platforms/macos/api/<F>/`) with the ADR-0046 §4 provenance+confidence stamp,
*because an instance is platform knowledge, not universal vocabulary*. This respects
the `semantic/` domain boundary (projection-AND-platform-independent — CONTEXT.md
`semantic/` entry) and rhymes with the ws2 split (neutral `annotations.kdl-schema`
in `schemas/` vs per-family `annotations.apiw` instances in `platforms/macos/api/`).
*(settled 2026-06-24; supersedes the conflation in REFACTOR §32, which lists
instance-level fields — participants/source-evidence/confidence — under a directory
named `pattern-kinds/`. The two-level reading is: that directory holds **kinds**;
§32's instance fields land in the platform triad.)*

**D2 — Heuristics formalize into a provenance tier (not superseded, not forked).**
The 10 `PatternStereotype` variants become **authored `.apiw` pattern-kinds** — an
*open data registry*, no longer a closed Rust enum. `detect_patterns` becomes **one
instance producer** stamping `source=convention`, co-existing with LLM-derived and
manual pattern-instances under the **same ws2 precedence** (`manual > llm >
convention > extraction`). Cheap structural coverage stays; any instance is
overridable by a higher tier. Reuses ws2's provenance/precedence machinery wholesale
and mirrors ADR-0047 (heuristics → declarative convention tier). *(settled
2026-06-24)*

**D3 — Convention-tier pattern detection is `ascent` datalog (not imperative).**
The structural pattern detectors (`detect_patterns`) re-express as `ascent` rules
over the extracted fact base, **one convention engine** for both method-facets and
patterns. The `convention:<rule>` provenance D2 needs falls out of the derivation
trace for free (each derived `pattern_instance` tuple names its rule). Lives in
`platforms/macos/tools/` — pattern *detection* is Cocoa-specific knowledge, so it
sits with `conventions` (same domain home, by the ADR-0047 precedent that put Cocoa
naming heuristics there, not in shared `semantic/tools/datalog` which holds only the
engine). Multi-role instance assembly (a `bracket` binds acquire+release+operation*)
is a `readback`-layer concern — the `conventions` crate already has that layer.
*(settled 2026-06-24; the `conventions`-crate-vs-sibling-`patterns`-crate placement
is a decompose-time detail, both under `platforms/macos/tools/`.)*

**D4 — Relationships fold INTO pattern-kinds (one unified entity).** A relationship
(§31: `parent_child`, `callback_destroy_notifier`, collection/element ownership) is
**not** a distinct sibling entity — it is modelled *as* a pattern-kind. One entity
class, one `semantic/pattern-kinds/` home, one schema, one registry, one
provenance/precedence path. *(settled 2026-06-25; user chose this over the
distinct-sibling recommendation — the win is less machinery: relationship-instances
ride the exact pattern-instance carriage, no second mechanism.)* The §32
reconciliation this forces — "patterns compose operations **plus relationships**"
when relationships are themselves patterns — is **D5**.

**D5 — Polymorphic participants; pattern-instance refs compose (§32 honoured).** A
pattern-kind declares **roles**; in an *instance* each role binds to a **participant**
∈ {type, operation/selector, **another pattern-instance**}. A "relationship-shaped"
kind is the degenerate case — type-roles + ownership/lifetime/invalidation laws, no
operation sequence (§31); a "behavioral" kind (`bracket`) adds operation-roles +
ordering/threading laws (§32). **One schema serves both.** §32's "compose operations
*plus relationships*" = a role bound to a **pattern-instance-ref** (a `subscription`
references its `callback_destroy_notifier`/token relationship-instance). The glossary
entry for *pattern-kind* must therefore pin the word **broadly** — it covers typed
edges, not only multi-operation contracts. *(settled 2026-06-25)*

**D6 — ws3 defines the provenance carriage; ws5 owns the workflow.** Pattern-instances
carry `source`/`confidence`/`provenance` in `resolved.json` (the carriage — §32's
"confidence, manual override status"). The per-fact caching / regeneration /
review-accept / diff *workflow* + the disagreement/precedence audit is **ws5's** —
exactly as k26 deferred the convention-fact rollout. ws3 keeps carriage minimal
(`annotate` runs once per SDK update). Mirrors the Spec-format-outcomes ws5 seam.
*(settled 2026-06-25)*

**D7 — ws3 authors the pattern-kind `.apiw` KDL Schema + a focused in-crate validator**
(`schemas/spec-format/pattern-kinds.kdl-schema`), mirroring how ws2 authored
`annotations.kdl-schema`. ws8 still owns the machine JSON Schema (extracted/resolved),
validation tooling/CI, and the app-kind/AppSpec/conformance schemas. Honours
ADR-0046 §3 (KDL Schema is the language-neutral source of truth; Rust serde types are
one conforming implementation). *(settled 2026-06-25)*

**D8 — New `semantic/tools/patterns` crate** for the kind-registry + pattern `.apiw`
parsing (a dedicated home for the pattern-model code), *diverging* from the
extend-`spec-format` recommendation. Instance **detection** (datalog) still lives in
`platforms/macos/tools/` (with/beside `conventions`, per D3); instance **carriage**
extends `types` + `resolve`. *(settled 2026-06-25; user chose a dedicated crate over
folding the loader into `spec-format` — one obvious home for the pattern model.)*

## Doubt pass (fresh-context adversarial review of the model, 2026-06-25)

A fresh `Explore` reviewer (no access to this reasoning) was asked to *break* the model
against §30/§31/§32. Four findings, reconciled — **none overturn D1–D8; all sharpen the
build children** (carry these into the child briefs):

- **DP1 — Laws/role-bindings reference §30's enumerated vocabularies, not free prose.**
  The PRD's illustrative `law "ownership" "…prose…"` would make the model vacuous. *Fix
  (schema child):* law/binding values draw from §30's controlled token sets (`owned`/
  `borrowed`/`weak`/`retained`/… ownership; the lifetime/threading/error tokens). The
  reviewer's "no contradiction-checker / no law-algebra" critique is **out of scope** —
  emitters *project* captured structure (§32), they don't theorem-prove; keep carriage
  minimal (the k26 steer).
- **DP2 — Intra-operation relationships (§31 `callback_destroy_notifier`) are valid
  *degenerate* instances.** A relationship whose roles all bind to one operation's params
  is expressed uniformly; a pattern-ref to it is ordinary graph composition (follow the
  ref to read *its* laws), not opaque nesting. *Accepted consequence of the D4 fold* — note
  it so the schema child models single-operation-scoped instances cleanly.
- **DP3 — Cross-framework instance home is an OPEN detail for the carriage child.** An
  instance whose roles span two frameworks (NSView parents a CoreAudio type) needs a
  *deterministic* home rule; "primary participant" is undefined on ties. *Fix (carriage
  child):* define the rule explicitly (candidate: framework of the kind's designated
  primary role, tie-broken deterministically — cf. gerbil `ClassRegistry` cross-framework
  resolution). Do **not** leave implicit.
- **DP4 — Pattern-instance identity is structural/content-derived, not a sequential
  label.** The PRD's `"AppKit#notif-destroy-1"` breaks under re-detection/SDK-drift. *Fix
  (carriage child):* an instance's id is a function of `(kind, sorted role-bindings)` (a
  content hash), so re-detection yields the same id for the same occurrence and D5
  pattern-refs stay stable. Echoes the grove's content-hash-for-idempotency instinct
  (`driving.md`) and the convention datalog's `(receiver, selector)` keying.

## Notes

Lazy decomposition: do not pre-spawn all of ws3's children — grow as earlier ones retire
(root brief). ws3 is consumed by ws6 (target idiom/emit) and informs ws9 (semantic tests);
keep the model target-independent (projection is targets/, never `semantic/`).
