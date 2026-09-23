# tutorial-k47

## Goal

Read the whole corrected document and verify the human's two reported defect
classes before handing the path back for human assessment.

## Context

All document and figure paths here are relative to
`semantic/specification/interface-language/`. The document is `tutorial/README.md` and tutorial parts 1–5.

- Human findings H1–H2 and proxy finding P7 are recorded in
  `first-path-reading-k8`, decisions D2–D6, in that leaf's committed record.
- Structure brief: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`, §9.3.
  Its revised §4–§6 govern comprehension, framing and figures; §7 governs checks.
- This is the first correction run for this document after its original
  editorial pipeline. It runs through draft, copy-edit, art and proof in order.

## Work

Apply the proof charter to the whole document against the revised §4–§6 and
§9.3. Check explanations, headings, table summaries, figure text, navigation,
examples and exact semantic claims. Start at the landing page and also try a
direct entry. Verify that technical names follow understandable explanations,
that positive framing leads the text, and that a reader can trace actors,
actions and consequences. Distinguish this inspection from evidence of human
comprehension: the scheduled human checkpoint owns that assessment.

## Done when

- The whole document and its direct-entry routes satisfy the revised contract.
- Example contracts and rule identities are preserved; links and anchors work.
- `task docs:check` passes and the node's handed-forward list is cleared or
  escalated through the editorial procedure.
- The node's close carries forward what the follow-up human read needs.

## Notes

This proof is the last stage of the queued correction run. Use the editorial
procedure for any additional finding. A second re-run of the same stage on this document
requires escalation. The human requested corrections before further feedback;
`first-path-reading-k48` follows all three corrected documents and precedes
reference drafting. Keep the synthetic examples and proposed-language status
explicit throughout.

## Decisions (running log)

- D1. The six-page read found no further actionable defect under plan §4–§6
  and §9.3. Keep the corrected prose, four figures and two part-5 tables.
  Each part identifies its new work and links its steps and checkpoint;
  the index and part 5 link the ownership exercise before the full package.
  The complete examples remain visible for assessing authoring burden.
- D2. The node has no outstanding handed-forward item. Its art handoff was
  closed by `tutorial-k46`; this proof found nothing requiring a correction
  run. Close `tutorial-k7` after the documentation gate and carry its boundaries
  and the human reading questions into the root brief. No language or ADR
  decision changes.
- D3. Editorial inspection establishes agreement with the stated contract,
  not human comprehension or evidence that a particular stage is effective.
  At `first-path-reading-k48`, assess whether the caller/library explanations
  are understandable and whether the local routes solve P7's difficulty
  finding new material, especially the owned-snapshot exercise.

## Verification and node close

- Read the index and all five parts, including examples, questions, answers,
  invalid variants, tables, captions and alt text. Checked the landing-map route
  and direct entry into parts 2, 4 and 5 through local goals, prerequisites and
  glossary links. Each part identifies its new material; the index and part 5
  offer the ownership exercise before the full package. Concrete explanations
  and their technical names agree across the set.
- Checked against the grammar, L1–L5, C1–C6, C8, A1–A5 and F1: null creation
  carries no ownership; Label is an opaque handle; input call validity and
  returned owner validity are distinct; refresh invalidates at entry; seven
  UTF-8 code units plus zero require eight allocated bytes; failed copying
  leaves output unreadable but status valid. Watch retains the handler, not
  Card; entry consumes Watch and return establishes quiescence. Delivery and
  eventual return remain unpromised. Each invalid variant violates its cited
  rule. No new ambiguity or change to the language is needed.
- Exact source comparisons confirmed that checkpoint declarations 1–4 equal
  the corresponding prefix of the finished package. Read the finished/owned
  diff: package identity, surface, outcome name, ownership, invalidation removal
  and symbol selection match the exercise; extraction comments are the only
  additional difference. The existing destructor, input validity and successful
  non-null completion support the owned variant.
- Read the four PlantUML sources and viewed rasterizations of their committed
  SVGs. Labels fit, cases remain distinct and keys explain the relations.
  The figures, table summaries and prose preserve the same lifetime boundaries.
  Each detail figure links to the overview and has a textual explanation.
- `task docs:check` passed: 19 files passed link and example checks, 17 pages
  were reachable, and all 11 SVGs reproduced byte for byte. Before/after SHA-256
  manifests matched item by item for 58 subjects: the interface-language tree,
  documentation checker directory (excluding Python caches), root Taskfile,
  documentation plan and audit. No subject changed during the run.
- Tier 2 coverage was checked against graph generation
  `2026-09-23T09:55:55Z`. Editorial metadata was changed/untracked and the
  examples/design directories were excluded. Evidence comes from direct source
  reads, exact comparisons and rendered inspection, not graph completeness.
  No parser, semantic validator or native execution is claimed.
- The node's delivery conditions hold: six tutorial pages, complete checkpoint
  files, draft inspection notes, incoming navigation and a green gate. There is
  no outstanding hand-forward item. Closing `tutorial-k7` promotes fixture
  boundaries and human reading questions to the root brief. No ADR change or
  further stage is needed; the root retains live work at `first-path-reading-k48`.
