# concepts-k77

## Goal

Copy-edit the concepts document after its model-first drafts: the three
explanation pages, grammar reference, non-normative canonical aids and the
affected glossary/landing prose and routes.

## Context

- Drafts: concepts-k85, concepts-k74, concepts-k75, concepts-k76. Structure brief: plan
  §9.2 (*Model-first run* and *Example-led refinement*), §9.4 grammar portion,
  §9.7 items 7–8; concepts: plan §10; prose contract:
  plan §4.
- The node brief's `## Handed forward` list.

## Done when

- Every concept is named exactly as `model.md` names it, on the three pages
  and in every canonical route sentence; "model" unqualified means the API
  model and G9 is the language-containment view.
- Each concept opening develops the reader's task and case in connected
  sentences, positively framed, without re-teaching the model or compressing
  it into terminology.
- Across this document, examples show familiar syntax and prose explains
  meaning and consequences without lessons on punctuation. Grammar links
  name their destination clearly. Preserve AIL-specific distinctions and
  local example context, including in canonical aids and glossary entries.
- The canonical preservation check still passes after the last edit.
- `task docs:check` passes.

## Notes

Charter: sentences, terminology and consistency. Structural residue goes to
the node brief's `## Handed forward` or, if it would send work back to draft,
is recorded for the full-set checkpoint; the run's bound authorizes no
correction run. Art and proof are already queued, so cut nothing at the end.

## Decisions (running log)

- D1 — Keep the existing section order, examples and figure assets. Correct
  sentence-level defects against plan §4: name the reader's action directly,
  preserve the model's concept names in links, and distinguish the canvas
  language-containment example from the API model. Art and proof already
  hold the later charters; no successor or correction run is needed.
- D2 — Use direct Markdown reads for this editorial evidence. Tier 2 graph
  coverage reports generation `2026-09-23T09:55:55Z`, changed or untracked
  document metadata, and an excluded design subtree. No structural code
  claim depends on that stale generation.
- D3 — Route the glossary's cardinality, pattern, pattern-instance and role
  entries, plus L6's ordering aid, directly to *Patterns and laws*. Route
  C2's lifetime aid to *Entities and their lifecycles*. The old combined
  heading's anchor remains available for incoming links; the current labels
  now identify the destination readers will actually reach.
- D4 — Link the grammar page's domain terms to their glossary entries while
  retaining local examples and explanations. No figure source, syntax fragment
  or normative paragraph needs an edit for these corrections.

## Verification and handoff

Read the three explanations, grammar reference, canonical reading-aid prose,
glossary and landing page against the model account and plan §4. The edits
clarify actors and actions in concept openings, separate the synthetic profile
from its catalogue and digest tokens, replace ambiguous canvas-model wording,
restore exact concept names, link grammar terms to the glossary and repair
the lifecycle/pattern routes. The section structure, local examples and
AIL-specific distinctions remain intact. The landing page and profiles aids
needed no copy-edit change. Q1–Q6 remain open.

After the last reader-page edit:

- Stripping the complete paired reading aids, including their blank separators,
  reproduced `language.md`, `contracts.md` and `profiles.md` byte for byte from
  `87221b8c`. Each comparison rejected an in-memory normative-version mutation.
  `grammar.ebnf`, `conformance.md` and the frozen buffers/objects/callbacks
  packages also matched that revision exactly.
- Comparing all nine scoped reader pages with the session parent confirmed
  unchanged code fences, explicit anchors, headings and images, item by item.
- Every concept-anchor link on the eight concept-bearing pages uses the
  model heading's words, allowing sentence-case capitalization. Each page's
  check rejected an altered link label. The landing page links the whole
  model and its map rather than individual concepts; its model, containment
  and grammar routes were checked separately. The initial scratch check's
  assumption that it needed individual concept links was corrected before
  the final terminology run.
- `task docs:check` passed: links in 21 files, all 19 reader pages reachable,
  example comparisons in 21 files, and byte-for-byte regeneration of 26 SVGs.
  Before/after SHA-256 digests agreed for all 105 subjects: files in the
  interface-language tree, documentation-checker Python sources, `Taskfile.yml`,
  the documentation plan and the audit. No checked subject changed during
  the gate.

These checks establish preservation and editorial consistency, not semantic
execution or human comprehension. No new structural or later-charter finding
needs handing forward. Art `concepts-k78` and proof `concepts-k79` remain live;
their existing scope includes figure captions and whole-document proof. Cut
no successor and leave the concepts node open for those stages.
