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

Parts 1–3 and their complete packages now use the label-card API recorded in
`tutorial/README.md`. The entry index and every concept page link to it.
Part 3's temporary next route is the existing callback explanation; replace
it when part 4 lands. Parts 4–5 remain plain text in the index.

`current_label` returns a borrowed opaque `Label`, not a pointer. Its region
is `owner($card)` and refresh invalidates it at entry. `Label` already has
its own unique destructor. The part 5 exercise can therefore change the
operation to give an independent owned Label snapshot, removing the borrow
invalidation clause and making the caller's destruction obligation explicit.
The changed semantic contract needs a distinct publication/access identity;
do not pretend the existing symbol also implements the changed contract.
No raw-pointer allocator extension is needed. The later Watch subscription
is independent of Card: do not silently add callback retention to the
existing card creation/refresh/destruction operations.

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
