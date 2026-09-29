# tutorial-k61

## Decisions (running log)

D1 — Apply plan §4–§6 and §9.3 to all six tutorial pages. Preserve their
section order, complete checkpoints, fragment containers and early ownership
exercise links. The copy-edit fixes terminology, instruction references and
sentence density; the queued art leaf owns the label-card model.

D2 — Use the glossary's slot/place distinction consistently: `destination`
names a parameter slot, `$destination` selects its pointer value, and
`$destination[]` selects buffer elements. Link introduced declaration,
callable, slot and place terms to their existing glossary entries. Keep AIL
fences and fixture contracts unchanged.

D3 — Graph coverage is generation 2026-09-23T09:55:55Z (fast). The plan and
research are excluded; tutorial paths are untracked in that generation and
the glossary/rule files have changed metadata. Directly read the relevant
Markdown and canonical passages; do not infer current coverage from the graph.
No structural code discovery is needed for this prose-only task.

D4 — The existing tutorial-k62 art and tutorial-k63 proof leaves discharge
the successor rule. Clear the copy-edit handoff after reading all six pages;
retain the art handoff and its exact label-card relationships. No duplicate
successor or additional correction run is needed.

## Goal

Copy-edit the examples-and-notation correction across `tutorial/README.md` and parts 1–5.

## Context

- Human assessment and H5–H7: first-path-reading-k48, D2–D5.
- Structure brief: documentation plan §9.3; general requirements:
  §4–§6 and §9.7.
- Rule-reading-k49 supplies the canonical examples, language model and selected
  railroad views. Read their landed form and this node's Handed forward list.
- Paths are relative to semantic/specification/interface-language/.

## Work

Check each introduction and instruction alongside its excerpt: the reader can identify its container, introduced names, what changes and why. Keep local context for direct entry without hiding each part's new material. Preserve complete examples and the accessible ownership exercise.

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

## Editorial inspection and H5/H6 disposition

Read all six pages, including the complete checkpoints, fragment labels,
instructions, observations, questions and answers, invalid variants, tables,
and adjacent figure explanations. Applied the plan's prose contract and
survey C1–C10 against the glossary and the landed L1/L2/C1/A2 reading aids.

| Location | Disposition |
|---|---|
| Index, package shell | Separate package/declaration explanation from signature reading; link declaration terminology. Keep the five-part map and early owned-snapshot route. |
| Part 1, shell and local/imported comparison | State what local means for the three declarations; link local/member terms and explicitly identify the linked geometry/canvas model. H5's imported/member comparison remains there, outside this free-function exercise. |
| Part 1, environment/resource/outcomes/effects | Link environment at its introduction and result slot at its first explanation. Remove the repeated implements explanation while retaining its imperative and meaning. Replace the compressed eventual-return phrase with the explicit absence of a termination guarantee. |
| Part 2, input and returned borrow | Link place at its introduction and read borrow(owner($card)) one relationship at a time. Retain the difference between the input's call region and the result's owner region, plus the earlier refresh cutoff. |
| Part 3, enum/storage/outcomes | Point the enum instruction to the adjacent fragment. Distinguish the destination parameter slot, pointer-valued place and element selection; link place at its first explanation. Preserve the status-first reading instruction and allocation obligation. |
| Part 4, callback and callback-use introductions | Link callable, place, slot and exports terminology. Replace the abstract call-boundary phrase with program/library actions. Name the quiescence clause's destructor reference and the obligation it takes over. Keep callback declaration versus callback-use, registration result versus callback slots, and entry versus return distinct. |
| Part 5, access and guided change | Explain mapping through consumer actions and completion terminology. Remove the repeated type statement in the symbol-change instruction while retaining the fixture representation and implementation obligations. Keep both result fragments and the direct exercise route. |

H6's containing scopes and fragment omissions remain visible; all complete
packages and all AIL excerpts retain their original text. The four G10
captions retain their concrete example paths and distinguish grammar from
semantic requirements. Art still owns the planned label-card model and figure
inspection. No additional structural or technical handoff arose from this
copy-edit. These are editorial observations, not evidence that the human
understands the corrected route; first-path-reading-k64 owns that assessment.

## Verification

- `task docs:check` passed: links checked 19 files with 17 reachable pages;
  examples checked 19 files; all 23 SVGs regenerated byte-for-byte.
- Compared every AIL fence and heading in each of the six tutorial Markdown
  files against parent commit `22f21613`: all preserved exactly. Reviewed the
  final diff; only tutorial prose and this leaf's Grove bookkeeping changed.
- SHA-256 digests before and after the gate matched for all 97 subjects:
  the interface-language tree, documentation tools excluding `__pycache__`,
  root Taskfile, documentation plan and audit. No subject changed mid-run.
- These checks establish source consistency, navigation and reproducible
  figures. They do not parse AIL, execute a semantic validator or runtime,
  or measure human comprehension. The existing art/proof siblings keep
  tutorial-k7 live, so this retirement closes no parent node.
