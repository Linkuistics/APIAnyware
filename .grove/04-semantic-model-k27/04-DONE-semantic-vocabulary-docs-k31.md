# semantic-vocabulary-docs-k31

**Kind:** work

## Goal

**ws3 child 4 — the semantic-vocabulary docs (the last ws3 child).** Author the
prose that documents the now-built semantic model and discharge the ws3
documentation placeholders, so a reader can learn the pattern-kind/instance model
without reading code. Docs-only: no code, no pipeline change, goldens trivially
green. After this retires, ws3 has no live leaf → the retire-cascade asks before
treating **workstream 3** done.

## Context (inherited — see `grove-llm brief-chain`)

The model is **built** — children 1–3 shipped the kind registry + `.apiw` schema +
`semantic/tools/patterns` crate (k28), the `resolved.json` instance carriage (k29),
and the convention-tier datalog producer `apianyware-pattern-detection` (k30). The
glossary (`CONTEXT.md → "Semantic model"`) already carries the vocabulary
(pattern-kind, pattern-instance, role/participant, law/controlled-vocabulary,
convention-tier detection, crate homes), updated inline as each child landed. This
leaf turns that settled vocabulary into **subject-local prose** (REFACTOR §10:
docs live with their subject).

- **Design source of truth:** PRD `prd/2026-06-25-semantic-pattern-kind-model.md`,
  ADR-0048 (D1–D8 + DP1–DP4), ADR-0046/0047. The node `BRIEF.md` running log.
- **REFACTOR.md:** §7.5 (patterns first-class), §12 (semantic model), §13, §30
  (the controlled weirdness vocabularies the laws draw from), §31 (relationships),
  §32 (pattern library / composition).
- **Already good — reuse, don't redo:** `semantic/pattern-kinds/README.md` is a
  full, accurate model overview (the `.apiw` shape, roles/laws/ordering, the
  authored-kind roster, tooling, instance-lives-elsewhere). Child 4 likely only
  needs to drop its "child 4 (semantic-vocabulary docs) follows" forward-reference
  and cross-link the new docs.

## Done when

- **Semantic-model prose authored** under `semantic/docs/` — at least an
  `overview.md` (what the semantic domain is + how kind/instance/convention-tier
  fit) and a `pattern-model.md` (the pattern-kind taxonomy: roles, laws + the §30
  controlled vocabularies, ordering, behavioral-vs-structural, composition via
  pattern-refs, the two-level kind/instance split, provenance tiers). Split
  further only if it reads better. Keep it vocabulary/concept prose, not an API
  reference (the crate rustdoc + the README's `.apiw` shape cover mechanics).
- **`api-pattern-catalog.md` rewritten/superseded** — the v1.0 "stereotype
  catalog" (closed `PatternStereotype` framing, "analysis detects / generation
  emits" contract) is reconciled with the first-class authored-registry model
  (ADR-0048 D2: the 10 stereotypes are now authored `.apiw` kinds, an open data
  registry). Either fold its canonical-examples tables into the new
  `pattern-model.md` and retire the file, or rewrite it in place as the
  authored-kind catalogue — your call; do **not** leave the stale closed-enum
  framing standing.
- **Placeholders discharged:** the `TODO (workstream 3)` markers in
  `semantic/README.md` and `semantic/docs/README.md` are removed and replaced with
  real content / cross-links; the `semantic/pattern-kinds/README.md` forward-ref to
  child 4 is resolved. The **TODO.md ws3 row** is marked ✅ DONE (mirroring the ws2
  row), naming the docs authored.
- Diagrams (if any) are **mermaid**, never ASCII art (feedback memory).
- `CONTEXT.md` stays the terse glossary — promote no implementation detail into it;
  the prose lives in `semantic/docs/`.

## Notes (steers)

- **Docs-only — no code, no `resolved.json` regen needed.** A quick `cargo build`
  sanity check is enough; goldens cannot move.
- **Lazy/last child:** do not pre-spawn anything. After committing + retiring this
  leaf, walk the parent chain — the node `semantic-model-k27` (ws3) then has no live
  leaf. **Ask the user** before treating ws3 done; on confirmation promote anything
  durable upward (the PRD's `Out of scope` rows already hand off to ws5/6/8/9) and
  recurse to the grove root.
- **Don't over-author.** ws3 is consumed by ws6 (target idiom/emit) and informs ws9
  (semantic tests); the docs explain the model, they are not the projection spec
  (that is ws6) nor the test architecture (ws9).
