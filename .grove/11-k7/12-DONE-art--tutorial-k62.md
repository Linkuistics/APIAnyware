# tutorial-k62

## Decisions (running log)

D1 — Follow the settled figure design in the node's handoff and plan §6:
add a local label-card model before part 1's shell railroad, using the shared
PlantUML vocabulary and generated SVG. A package folder contains three sibling
declaration boxes; function compartments locate their parameters and results.
A labelled lifecycle arrow connects Card to destroy_card separately from
containment. Keep the geometry/canvas comparison linked for imports/members.

D2 — Read all six pages and their figures under the art charter. Retain the
four existing tutorial diagrams, four reused G10 views and three tables:
their adjacent explanations state reading order, takeaway and scope. The
existing proof sibling discharges the successor rule; add no duplicate.

D3 — Tier 2 graph coverage is generation 2026-09-23T09:55:55Z (fast).
Tutorial/figure paths are untracked in that generation, examples/design are
excluded, and canonical Markdown has changed metadata. Use direct reads of
these documentation artifacts and sources; graph results establish no current
content claim. No structural code discovery is needed.

D4 — Add two tables for new prose-only reference comparisons: part 1 step 5
maps declaration/slot/place forms, and part 4 step 8 maps the cross-callable
handler reference against each function's local place. Each has an adjacent
reading instruction and rule links. These are art-owned mappings; existing
prose, code and complete/fragment labels remain intact.

D5 — Clear the completed art handoff and retain the queued tutorial-k63 proof
leaf. No earlier-stage defect or unresolved residue for first-path-reading-k64
was identified in this art inspection. No architectural decision changed, so
the ADR set needs no edit. The tutorial node remains live through proof.

## Goal

Complete and verify the figures supporting the corrected introductions across `tutorial/README.md` and parts 1–5.

## Context

- Human assessment and H5–H7: first-path-reading-k48, D2–D5.
- Structure brief: documentation plan §9.3; general requirements:
  §4–§6 and §9.7.
- Rule-reading-k49 supplies the canonical examples, language model and selected
  railroad views. Read their landed form and this node's Handed forward list.
- Paths are relative to semantic/specification/interface-language/.

## Work

Inspect all six pages and existing tutorial figures. Reuse model/railroad aids selectively where a step needs them; render assigned figure slots with keys and adjacent explanations. Keep the code's exact names and boundaries in the diagrams, including refresh invalidation and callback quiescence.

Read the whole document under this stage's charter. Preserve original AIL
semantics, example contracts, proposed status and synthetic boundaries.
Work belonging to another stage follows the node's declared handoff and
escalation rules; do not silently absorb it.

## Done when

- This stage's charter is satisfied for the whole named document under the
  revised structure brief, with the disposition of each relevant H5/H6 location
  recorded in the task's notes.
- Snippets, prose and figures agree with their grammar and canonical rules;
  complete/fragment labels remain truthful.
- `task docs:check` passes. Mechanical checks and editorial inspection are
  reported separately from human comprehension.

## Notes

This is the human-directed second correction run. The escalation and authority
are in the node brief; no further automatic rerun is authorized. Record any
unresolved residue for first-path-reading-k64 and seek human direction when
necessary. The next stage is already queued under this node; do not add a duplicate.

## Figure inspection and H5/H6 disposition

Read all six tutorial pages, including fragments, complete checkpoints,
observations, questions, invalid variants and figure surroundings. Inspected
the generated views as well as their sources and adjacent explanations.

| Location | Disposition |
|---|---|
| Index | Retain the five-part/checkpoint map and its instruction to use it for navigation. Domain sequences are developed in the linked parts' figures; the initial shell routes directly to part 1's model and syntax view. |
| Part 1, step 2 (H5/H6) | Add tutorial-model: the named/versioned folder contains Card, create_card and destroy_card as siblings. Function compartments show the nullable result, card parameter and unit result. The labelled lifecycle arrow identifies a reference separately from containment. Add local key, takeaway, source and context links before G10 shell. |
| Part 1, step 5 (H6) | Add a declaration/slot/place table for @create_card, @create_card::result and $result. Explicitly state that the checkpoint does not need the cross-callable result reference. Retain the later lifecycle states with ownership moving at destructor entry and destruction completed before return. |
| Part 2 | Retain the two borrow timelines. Input validity ends with current_label; returned access ends at refresh entry or owner destruction. The caption and key preserve Card ownership and the prohibition on destroying a borrowed Label. |
| Part 3 (H6) | Retain G10 place syntax beside $destination[]/$result and the two storage grids. Verify zero-selector bypass, repeated selector alternatives, status-first reading, seven text elements plus terminator, and unreadable failure output. |
| Part 4 (H6) | Retain G10 callback-use and the teardown timeline. Add the handler-slot/local-place mapping in step 8. The outside_callback row concerns the calling context, while the timeline explicitly permits a handler running on another thread during teardown. Ownership moves at entry; quiescence holds at return. Watch retains no Card. |
| Part 5 (H6) | Retain G10 access with its nonempty environment list, the access-clause/tool-action table, and the borrowed/owned comparison by event. Each table states how to read it and keeps the two package identities distinct. |

The four G10 sources were compared with document/item/clause, place,
callback_use and access in grammar.ebnf. Paths retain all alternatives and
repetition; captions assign semantic restrictions to the canonical rules.
The new model was checked against the part 1 shell, resource clause and full
checkpoint, L2/L4 and C2. The reference tables were checked against L2/C1 and
the outside_callback/quiescence rules in C3/C6.

### Figures declined

- A second geometry/canvas imports/member model in the tutorial: editorial
  judgement. Part 1 links G9 with an explanation of its purpose; this exercise
  contains local free functions and would gain unrelated declarations from a
  second local model of imports or members.
- Further local railroad views for each clause, outcome and type: editorial
  judgement. The four selected views explain the introduced structural choices;
  located snippets and existing contract figures carry the remaining relations.
- Separate owned-snapshot timeline: editorial judgement. Part 5's event table
  already aligns refresh, destruction and the continuing obligation directly.
- Repeating the part diagrams on the index: editorial judgement. Its table
  routes readers to those developed views while introducing the exercise.

No declined figure was blocked by the contract or by the medium's expressive
limits. These judgements do not measure reader comprehension; that assessment
remains with first-path-reading-k64.

## Verification

- `task docs:check` passed: links checked 19 files with 17 reachable pages,
  examples checked 19 files, and all 24 SVGs regenerated byte-for-byte.
- SHA-256 snapshots before and after the gate matched for all 99 subjects:
  the interface-language tree, specification tools excluding `__pycache__`,
  Taskfile.yml, the documentation plan and audit. No subject moved mid-run.
- Compared every AIL fence in all six tutorial pages with parent commit
  4ee5825d: unchanged. The final diff changes only two pages' figure material,
  the new PlantUML/SVG pair and this leaf's Grove bookkeeping. Existing figure
  sources/SVGs, checkpoint files, normative rules and grammar are unchanged.
- Visually inspected all nine embedded diagrams through SVG raster previews.
  The new model has readable containment, compartment labels, arrow and key;
  corrected a literal quote escape exposed by the first render. Existing
  diagrams retain legible labels, tracks and event boundaries.
- These are reproducibility, source-consistency and editorial checks. No AIL
  parser, semantic validator, native runtime or human comprehension test ran.
  Proof remains queued; no parent closes on this leaf's retirement.
