# tutorial-k82

## Goal

Copy-edit the tutorial after its model-first drafts: the index and all five
parts.

## Context

- Drafts: tutorial-k80 and tutorial-k81. Structure brief: plan §9.3; concepts:
  plan §10; prose contract: plan §4. The node brief's `## Handed forward`.

## Done when

- Concept names match `model.md` everywhere; each *The model* section and each
  concept-naming step sentence is positively framed and concrete about the
  label-card program and library.
- Conditions precede actions in steps; the repeated context introductions
  still let a continuing reader find the new material quickly.
- Across all six pages, examples carry familiar syntax; prose explains
  AIL-specific meaning and consequences without narrating punctuation.
  Grammar links clearly name the relevant reference section.
- `task docs:check` passes.

## Notes

Charter: sentences, terminology and consistency. Structural residue goes to
the node brief or, if it would send work back to draft, to the full-set
checkpoint; no correction run is authorized. Art and proof are queued, so cut
nothing at the end.

## Decisions (running log)

- D1: Keep the six-page structure, examples, stable anchors and early routes.
  Copy-edit concept introductions to name the program/library actions, align
  named concepts with `explanation/model.md`, and put conditions before actions.
  Keep concrete destruction duties as examples of release responsibility.
- D2: Link glossary-owned terms at their first prose use and name grammar
  destinations precisely. Preserve AIL-specific reference and place explanations.
  Art k83 and proof k84 are already live; add no successor or correction run.

## Verification

- Read the index and five parts against plan §4/§9.3/§10, the model account
  and relevant glossary entries. Named model links now match the model's
  headings exactly; all six pages retain their headings, explicit anchors
  and fenced examples compared with the parent revision.
- Each of the six checkpoint files was compared byte-for-byte with
  `7891f92a`: lifetime, lending, storage, callbacks, finished and owned all
  match. This copy-edit changes no example source or figure source.
- `task docs:check` passed: links and examples checked 21 files, 19 pages
  were reachable, and all 26 SVGs reproduced. SHA-256 digests before and
  after the run matched for 106 subjects: the interface-language tree,
  checker files (excluding bytecode caches), Taskfile, plan and audit.
- Graph project confirmed at generation `2026-09-23T09:55:55Z`, Tier 2.
  Coverage reports the plan excluded and tutorial/model/brief metadata
  untracked or changed; observations use direct Markdown reads. No code
  structure claim or graph completeness claim is made.
- No structural residue found for the full-set checkpoint. Art owns the
  outstanding figure-to-model routes recorded in the node brief. These checks
  establish consistency and preservation, not human comprehension.
