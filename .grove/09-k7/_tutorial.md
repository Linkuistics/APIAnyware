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
table beside the guided change. G1 is reused on all six tutorial pages before
the contract detail; sources, captions and the shared key carry the visual
contract. No handed-forward defect remains from art.
