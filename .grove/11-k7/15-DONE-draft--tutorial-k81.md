# tutorial-k81

## Goal

Revise tutorial parts 4 and 5 to exercise the model: callback schedules and
execution in part 4, reaching the code and the owned-snapshot change in part 5,
each introduced by the concept it applies.

## Context

- Structure brief: plan §9.3, *Model-first run* block. Concepts: plan §10;
  prose contract: plan §4. tutorial-k80's revised index and parts 1–3.

## Done when

- Parts 4 and 5 open with *The model*, naming and linking their concepts and
  the concrete question; every construct-introducing step names its concept.
- Part 5 introduces `access` as the access concept and frames the owned-
  snapshot change as a change to release responsibility, traced through every
  clause and rule it touches; the early route to that exercise remains.
- `examples/tutorial/04-callbacks.ail`, `05-finished.ail` and `05-owned.ail`
  are byte-identical; invalid variants and answers stay; renamed headings keep
  their old slugs.
- Both parts retain snippets and semantic figures but replace G10 embeds
  with links to the grammar-reference sections at `reference/notation.md`.
  Apply model-reading-k73's example-led requirement: explain meaning and
  consequences, omitting elementary punctuation narration.
- `task docs:check` passes.

## Notes

Last draft session of the bounded run. Copy-edit, art and proof are already
queued, so cut nothing at the end.

## Decisions (running log)

- D1: Keep the existing step order and all example blocks. Introduce each
  step through its named model concept and concrete task; preserve the old
  `the-domain-obligation` anchors when replacing those headings with *The model*.
- D2: Frame the owned snapshot as a release-responsibility change, following
  its consequences through validity, lifecycle, publication and access. Keep
  both variants' successful-return promise and the existing early exercise route.
- D3: Replace the callback-use and access railroad embeds with links to their
  grammar-reference sections. Keep the callback timeline and comparison table.

## Verification

- Structure: plan §9.3 supplies the reader/outcome, ordered parts and steps,
  emphasis and non-goals. Parts 4–5 retain that progression, early routes,
  snippets, checkpoint packages, observations, questions and invalid variants.
  Each step now names and links its model concept before its notation.
- Technical inspection against `grammar.ebnf`, L1–L5, C1–C6/C8 and A1–A5/F1:
  the callback invocation remains separate from registration's seven schedule
  facts; owner-scoped strong retention agrees with the owned Watch and its
  quiescent unique destructor; `outside_callback` names the registration slot.
  The snapshot change updates identity/surface, outcome name, output transfer,
  borrow invalidation and symbol. The unique Label destructor already consumes
  the new obligation; input validity, successful return, effects, representation,
  copying and the independent subscription keep their contracts.
- All six checkpoint files compare byte-for-byte with pre-run `7891f92a`.
  Every fenced example in the two edited pages, plus their questions, answers
  and invalid variants, compares unchanged with parent `5aa6482a`.
- Enumerated every tutorial image: the five semantic figures remain and no
  G10 embed remains. The same extraction finds G10 in the grammar reference
  and detects an injected G10 embed in a scratch string. Both old
  `the-domain-obligation` anchors remain.
- `task docs:check` passed: links and examples each checked 21 files,
  19 pages were reachable, and all 26 SVGs regenerated identically. SHA-256
  manifests before and after cover `Taskfile.yml`, the specification tree,
  documentation tools, documentation plan and audit; every digest matched.
  These are documentation consistency checks, not executed AIL validation or
  evidence about an implementation or human comprehension.
- Graph coverage was checked at Tier 2, generation `2026-09-23T09:55:55Z`.
  Documentation metadata was stale/untracked and examples/design documents
  excluded, so technical evidence came from direct current-source reads.
  No structural code claim relies on the graph.
- Copy-edit, art and proof remain live siblings k82–k84. No further leaf or
  correction run is needed, and this retirement does not close tutorial-k7.
