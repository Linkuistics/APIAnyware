# tutorial-k45

## Goal

Edit the corrected document's sentences and terminology so readers can follow
each relationship in ordinary language.

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

Apply the revised prose contract (§4–§5) to the whole document, including
headings, first sentences, tables, status statements and example labels. Check
that the reader can identify who acts, what changes, and why it matters without
decoding an unexplained abstraction. Use connected explanations and positive
framing. Preserve the distinctions the specification requires; judge length by
what the reader needs. Structural teaching gaps belong to draft and figure work
to art: use the editorial handoff procedure for those findings.

## Done when

- Sentences, terminology and example surroundings satisfy the revised prose
  contract across the whole document.
- A headings-and-first-sentences read introduces the actual subjects clearly.
- `task docs:check` passes and each out-of-charter finding has an owner.

## Notes

The later stages of this correction run are already queued. Read the live
siblings and keep the existing run; each stage uses the editorial procedure
for any additional finding. A second re-run of the same stage on this document
requires escalation. The human requested corrections before further feedback;
`first-path-reading-k48` follows all three corrected documents and precedes
reference drafting. Keep the synthetic examples and proposed-language status
explicit throughout.

## Decisions (running log)

- D1: Keep the section order and complete packages. Clarify dense sentences
  about caller responsibility, refresh, output validity and access mapping,
  and link glossary terms at first use. Fixture contracts and code stay intact.
- D2: Keep the existing art handoff for the four figures, captions, alt text
  and part 5's comparison table. Live art and proof siblings already discharge
  this correction run's successor requirement.

## Verification

- Read the index and all five parts against plan §4–§5 and §9.3, including
  a separate headings-and-paragraph-openings pass. Clarified sentences in
  parts 1–5; the index needed no change. The existing art handoff remains
  current. No additional structural correction was identified.
- `task docs:check` passed: 19 files checked for links and examples, 17 pages
  reachable, and all 11 diagram SVGs reproduced. SHA-256 manifests before
  and after the final run matched for the interface-language tree, docs
  checker directory, documentation plan, audit and root Taskfile.
- Reviewed the diff: changes are prose, headings and glossary links; example
  fences and fixture files are unchanged. These checks establish neither
  runtime conformance nor human comprehension; the human reading remains
  `first-path-reading-k48`.
- Graph generation `2026-09-23T09:55:55Z` reported changed or untracked
  metadata for the editorial files and excluded the plan's directory.
  Editorial evidence came from direct Markdown reads, not graph completeness.
