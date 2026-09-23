# tutorial-k44

## Goal

Correct the document's explanatory structure and prose after the human's first
reading identified compressed abstractions and negative framing.

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

Read the corrected orientation and concept pages first. Rewrite the tutorial's explanations, steps, status text and example surroundings using concrete actions and positive framing. Explain each new relationship at the length it needs. Make each part's new material easy to find and give part 5 an early route to the owned-snapshot exercise. Retain the complete checkpoint packages and their code-to-file checks. Reconsider repeated publication-map introductions in light of what the reader already knows. The Label, Card and Watch contracts and the synthetic provider identities stay as specified.

Read the whole document, including its tables and opening summaries. Preserve
normative semantics, rule identities, AIL code and synthetic example contracts.
The human asked for understandable explanation before giving more feedback;
replacing a few reported phrases is insufficient.

## Done when

- The whole document explains the relevant actors, actions and consequences
  before relying on technical shorthand.
- Headings and explanatory framing state their subjects positively, while
  exact conditions, limitations and obligations remain recoverable.
- The revised structure brief is satisfied and `task docs:check` passes.
- Work belonging to later stages is recorded in the node's handed-forward list.

## Notes

The later stages of this correction run are already queued. Read the live
siblings and keep the existing run; each stage uses the editorial procedure
for any additional finding. A second re-run of the same stage on this document
requires escalation. The human requested corrections before further feedback;
`first-path-reading-k48` follows all three corrected documents and precedes
reference drafting. Keep the synthetic examples and proposed-language status
explicit throughout.

## Decisions (running log)

D1 — The named structure brief is plan §9.3. Its reader/outcome is “the primary
reader, after the concept pages or arriving directly with only the orientation”
who can “make a modest change and predict what else must change and which rule
decides.” Its ordered sections name the index and five parts, then give the
seven-part internal sequence. Its emphasis requires direct routes to new
material and the part-5 exercise; its non-goals exclude installation, command
lines and runtime use. This is the existing human-approved design for the
correction; no new design or approval cycle is needed.

D2 — Keep the six-page sequence and every existing code fence verbatim. Replace
compressed explanations with caller/library actions, split multi-concept steps
into named subsections, and put links to the steps and complete checkpoint near
each part's goal. Part 5 also links the owned exercise before the full package.
The index introduces Card/Label, copying, and Watch in separate passages before
the route table. Overview links provide context without another publication
introduction on every part. Figure editing remains with the already queued art
stage; draft supplies the surrounding explanation and records specific handoffs.

D3 — The corrected document teaches package scope and fixture selections as
separate steps; input-call validity precedes the returned-label lifetime;
allocated storage precedes readable output; callback invocation precedes
storage, schedule and teardown; and access mechanics precede the ownership
change. The reader's progression and complete examples follow plan §9.3.
All later correction stages remain live (`tutorial-k45`, `tutorial-k46`,
`tutorial-k47`), so the editorial successor condition requires no new leaf.

## Technical inspection

The sources are the current `language.md`, `contracts.md`, `profiles.md` and
`grammar.ebnf`, plus all six files in `examples/tutorial/`. The fixture files
and rule text remain unchanged. Graph project
`Users-antony-Development-APIAnyware.improve-api-interface-language-docs`,
generation `2026-09-23T09:55:55Z`, was checked at Tier 2. Documentation metadata
was changed or untracked and examples/design material excluded; evidence here
comes from direct source reads and exact file comparison, not graph completeness.

- **Grammar/L1–L5:** header, package/version, unique local names and fixture
  aliases, dependency-pin form, the exact `test` configuration, exports and
  references checked. Each subset has its complete referenced declarations.
  Nominal types, functions, outcomes, callback uses and access blocks use the
  grammar's scopes. Common clauses and per-place clauses retain their scopes
  and required singularity. The code fences are copied verbatim from the
  pre-edit pages, including the five invalid variants; final examples remain
  checked against their files by `docs:examples`.
- **Part 1, C1–C3/C5:** creation partitions nullable Card into null and
  non-null, both valid to inspect; ownership is conditional on non-null.
  The unique destructor consumes at entry, returns unit and has only successful
  returned completion. Mutation describes live contents, not destruction.
  Transferable ownership, executor permission, serial/parallel calls and nested
  re-entry remain separate; no eventual-return promise is added.
- **Part 2, C1–C3/C5:** Label is an opaque handle with its own unique lifecycle.
  The getter borrows Card during the call and lends its result in owner(Card).
  Refresh has the owner parameter and argument mutation; it invalidates at
  entry. Card destruction ends the owner region. The caller cannot consume the
  returned borrow through destroy_label. The call-region invalid variant still
  violates C1's escaping-borrow rule.
- **Part 3, L4/C1/C3–C5:** the closed i32 enum has exactly 0/1; both statuses
  remain valid. The destination is a non-null mutable borrowed pointer with
  out direction, disjointness, no retention and call validity. Capacity eight
  accommodates seven UTF-8 code units and a zero terminator; out needs no
  initialized entry elements. Failure marks the buffer elements invalid while
  preserving caller ownership of the allocation. The capacity-seven variant
  still violates C4.
- **Part 4, C2–C3/C5–C6:** one callback invocation and one registration's
  schedule are described separately. Strong handler retention creates the
  library's independent obligation in the returned Watch region. Watch is
  non-null/owned on the sole successful outcome; after_return, zero-to-many,
  serial, forbidden re-entry and destructor quiescence agree. outside_callback
  names the registration's handler use. Destruction consumes at entry and
  establishes quiescence at return; no eventual delivery/return promise.
  Scalar notifications retain no Card and extend no Label borrow. The invalid
  quiescence(return) still contradicts the owner scope.
- **Part 5, L2–L5/C1–C6/A1–A5/F1:** the owned file differs in package name,
  surface, outcome name, owned give, removal of invalidation, and symbol name
  (plus extraction comments). Its signature, input borrow/validity, successful
  non-null result, lifecycle, buffer and callback contracts stay the same.
  F1 defines the c/symbol/identity combination and fixture-only compatibility;
  callback ABI/representation remain distinct from function access. The new
  symbol owes the owned snapshot's full contract. Removing give remains C5's
  missing-reference-output defect. The two packages' nominal identities remain
  distinct. Documentation or machine views retain the changed ownership (A5).

No new language ambiguity was required to describe these unchanged examples.
L6 pattern rules and C7 global-storage rules have no declarations to govern in
these tutorial packages. Grammar admission and semantic completeness are
inspection results; no parser, semantic validator or native execution is claimed.
The structural correction is not evidence of human comprehension; that remains
the scheduled `first-path-reading-k48` assessment.

## Verification

- `task docs:check` passed: link/anchor checks reported 19 files and 17
  reachable pages; example/fence synchronization reported 19 files; all eleven
  SVGs regenerated byte-for-byte. No check failure required a repair.
- SHA-256 digests before and after the run matched for each of its 58 recorded
  subjects: the interface-language tree, documentation tools, root Taskfile,
  documentation plan and audit. No subject was edited during the run.
- Exact per-page comparison with the pre-edit copies confirmed that all
  fourteen existing fenced blocks are unchanged. Exact declaration-prefix
  comparisons confirmed checkpoints 1–4 use the corresponding declarations
  in `05-finished.ail`; the owned-file diff was read separately against the
  exercise's edit list. The `.ail` files and normative sources have no edits.
- Re-read the six resulting pages, including opening blocks, tables, example
  surroundings, questions/answers and invalid variants. Every part retains the
  ordered teaching sections, a complete package and direct local routes.
  Part 5 and the index both link directly to the owned exercise. The four
  existing figure passages and the comparison table remain for art's explicit
  handoff. Copy-edit and proof retain their whole-document charters.
- No ADR decision changes: the work changes explanatory structure and
  navigation under the existing documentation contract. The tutorial node
  remains live through its queued correction stages, so no parent close or
  promotion is due at this retirement.
