# tutorial-k7 — brief

## Goal

Land the five-part tutorial and its checkpoint packages in
`examples/tutorial/`. By describing one small synthetic API, the reader
writes, reads and changes a complete AIL package without any tooling (plan
outcome 2).

## Contract

The structure brief is the documentation plan's §9.3, at `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`. It states
the reader and their outcome, the ordered sections and the purpose of each,
and the emphasis and non-goals. The same plan's §4 (prose contract), §5
(page-one block and example labels), §6 (figures) and §7 (checks) govern
every stage. The gate is `task docs:check`, plus any task this document adds.

## Pipeline

`draft` → `copy-edit` → `art` → `proof`, cut lazily: each stage's last act
adds the next unless a live later sibling already holds it. Stage leaves carry
this document's bare stem as their slug. Defects a later stage owns go under
`## Handed forward` in this brief; the list is created by the first stage that
needs it. Figure slots that `draft` leaves for `art` go there too.

## Done when

- `tutorial/README.md` and five parts exist and meet §9.3. Every checkpoint is
  a labelled complete package kept in step by `docs:examples`, and every
  invalid variant cites its rule.
- Each checkpoint was checked by inspection against `grammar.ebnf` and every
  applicable rule, and the check notes are recorded in the draft leaves.
- Any unclear rule met while designing the API is in the open-question
  register, and the tutorial uses a supported alternative.
- The landing page and concept pages link the tutorial. The landing map
  linked `tutorial/README.md` in the session that landed it, and every landed
  part was reachable from that index (plan §3, *Staging*).

## Decomposition

Two draft sessions, in order. The first designs the synthetic API and drafts
`tutorial/README.md` and parts 1–3 with their checkpoints, and links the
index from the landing map and the concept pages. The second drafts parts
4–5, the final package and the guided change, and turns the index's
plain-text entries for them into links. Only the second cuts `copy-edit`.

## Continuation context

The five parts and their complete packages use the label-card API recorded
in `tutorial/README.md`. The index links every part; part 3 leads to part 4,
then part 5. The landing map and every concept page already link the index.

`current_label` returns a borrowed opaque `Label`, not a pointer, through
the finished checkpoint. Its region is `owner($card)` and refresh invalidates
it at entry. Part 5's separate `tutorial::owned` package returns an independent
owned Label snapshot via `fixture_current_label_owned`; the existing unique
Label destructor discharges the new caller obligation. No allocator extension
or new failure mode is introduced. The Watch subscription is independent of
Card and delivers only a scalar change number. Preserve that boundary.

## Handed forward

- **art — tutorial/01-lifetime.md:** illustrate the nullable creation split
  and the owned Card's unique lifecycle. G6 is the existing visual model but
  describes Store, so adapt labels if reusing its source.
- **art — tutorial/02-lending.md:** show a returned Label borrow ending at
  refresh entry while Card remains alive, versus Card destruction ending the
  owner region. G5's mutation case is the useful visual model; here the
  borrowed value is a resource handle, not a byte pointer.
- **art — tutorial/03-storage.md:** make the relation among seven initialized
  text elements, eight allocated elements and the terminator visible; compare
  valid status with invalid output elements on failure. The prose carries all
  facts. Use the shared vocabulary and commit source plus generated SVG.
- **art — tutorial/04-callbacks.md:** fill the plan's G7 tutorial slot.
  Adapt or reuse the existing G7 source with Watch/watch_labels/destroy_watch
  names. Distinguish synchronous registration return, permitted later
  invocation starts, consumption at destructor entry and quiescence at its
  return; show the outside_callback precondition. The prose carries all facts,
  including zero delivery and no termination guarantee. Do not imply a Card
  is retained or an earlier Label borrow extended.
- **art — tutorial/05-access-and-change.md:** compare the borrowed Label
  ending at refresh/owner destruction with the owned snapshot's independent
  destroy_label obligation. Reuse the established ownership/borrow vocabulary;
  do not add a raw-pointer allocation model. An additional access diagram is
  unnecessary here; the four-clause table and linked G3 explanation cover it.
