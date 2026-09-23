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

The four tutorial diagram sources and generated SVGs live under `figures/`
with the `tutorial-` prefix. Part 5 compares borrowed and owned results in a
table beside the guided change. The tutorial links to the overview's G1 rather
than repeating the figure. Each detail diagram has a route back to that wider
context; its source, caption and shared key carry the visual contract.

## Human reading correction

The first human read (`first-path-reading-k8`, D4–D6) requested fuller,
concrete explanations and positive framing before further feedback. The proxy
also found each part's new material hard to locate among repeated introductions
and growing full packages (P7). `tutorial-k44` through `tutorial-k47` form the
first correction run, after orientation and concepts. The revised plan §4–§6
and §9.3 govern it. Retain the complete packages, make the new material and
part-5 ownership exercise easy to reach, and reconsider each repeated context
introduction according to its usefulness. The historical G1 reuse described
above is subject to that revised figure contract. The follow-up human checkpoint
is `first-path-reading-k48`.

## Handed forward

- **Art — parts 1–4, the four `tutorial-` figures and their adjacent captions
  and alt text.** Draft has developed the actor/action explanations in the
  steps but retained these figure passages for their owning stage. Reconcile
  their vocabulary and density with the new prose: in particular part 2's
  “owner-scoped” and “input's call region” summary, part 4's “owner consumption”
  and “quiescence” summary, and the dense timing limitations in each caption.
  Replace part 4's unexplained “G7 adaptation” with reader-facing scope. Keep
  refresh invalidation at entry, destruction responsibility at entry, and
  callback quiescence at return. The surrounding steps already explain those
  events and the absence of delivery or termination guarantees. Check part 5's
  retained comparison table under the same charter. Each detail view now links
  to the overview; no repeated full publication figure is needed for orientation.
