# concepts-k41

## Goal

Edit the corrected document's sentences and terminology so readers can follow
each relationship in ordinary language.

## Context

All document and figure paths here are relative to
`semantic/specification/interface-language/`. The document is `explanation/contracts.md`, `explanation/packages.md` and `explanation/choices.md`.

- Human findings H1–H2 and proxy finding P7 are recorded in
  `first-path-reading-k8`, decisions D2–D6, in that leaf's committed record.
- Structure brief: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`, §9.2.
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

- D1: Keep the corrected section order, examples and Q1–Q6. This pass
  expands residual compressed sentences and supplies first-use glossary
  links. Figure captions, alt text and labels remain with the queued art
  stage under the existing node-brief handoff.
- D2: Use direct Markdown reads as evidence. Graph coverage generation
  `2026-09-23T09:55:55Z` reports changed metadata for these pages and excludes
  the documentation-plan subtree; it is not evidence of their current prose.
- D3: The headings and opening sentences introduce concrete subjects; the
  whole-document read found no further structural handback. Existing figure
  findings remain owned by `concepts-k42`, with `concepts-k43` after it.
  Both siblings are live, so this correction adds no duplicate stage.

## Verification

- `task docs:check` passed: links checked across 19 files with 17 pages
  reachable; example checks passed for 19 files; all 11 diagram SVGs matched
  regeneration. The external RFC link was listed without fetching.
- SHA-256 manifests before and after the gate matched for the documentation
  and example files, diagram sources/SVGs/styles, documentation-check scripts,
  design/research Markdown and root Taskfile. No checked input changed during
  the run.
- Read all three pages, then checked headings and opening sentences together.
  Reviewed the final diff for unchanged examples, rule citations and Q1–Q6.
  These are editorial and static checks; human comprehension remains for
  `first-path-reading-k48`.
