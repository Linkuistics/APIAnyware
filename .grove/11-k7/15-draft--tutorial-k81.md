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
- `task docs:check` passes.

## Notes

Last draft session of the bounded run. Copy-edit, art and proof are already
queued, so cut nothing at the end.
