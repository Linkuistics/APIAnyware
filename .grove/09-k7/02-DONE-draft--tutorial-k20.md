# tutorial-k20

## Goal

Draft tutorial parts 4 and 5: callbacks and teardown, access paths, the finished package, and the guided change from a borrowed to an owned result.

## Context

- Structure brief: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §9.3 (parts 4–5). It states the reader and outcome, the ordered
  sections with their purposes, and the emphasis and non-goals. Quote it
  rather than re-deriving it.
- Prose contract, labels, figures and checks: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §4–§7.
- Evidence: the audit (`semantic/docs/research/interface-language-documentation-audit.md`) and the survey's §9 criteria D1–D8.

## Done when

- Parts 4 and 5 follow §9.3's per-part order, and the final package is
  complete under draft 0.1 by inspection, with an inspection note in this
  leaf's decision log.
- The guided change lists every clause and rule it touches, as observations
  that can be checked by inspection.
- The landing page and the concept pages link to the tutorial, and the
  tutorial index links parts 4 and 5, replacing its plain-text entries and
  part 3's interim next route (plan §3, *Staging*).
- `task docs:check` passes.

## Notes

The tutorial API's design is in `tutorial/README.md`, from the previous session. Extend it; do not redesign it. If redesign is unavoidable, it is a correction run of part 1.

This is the node's last draft session, so its last act is `leaf-add` of the `copy-edit` leaf, unless a live later sibling already holds one.

## Decisions (running log)

- Structure precondition: the named plan's §9.3 gives the reader as “The
  primary reader, after the concept pages or arriving directly with only the
  orientation”; the final outcome is “make a modest change and predict what
  else must change and which rule decides”. It orders part 4 as “A callback
  declaration; registration with a schedule and owner scope; quiescent
  destruction; and `outside_callback`”, and part 5 as “`access` blocks, the
  finished package, and a guided change”. Each uses goal, domain obligation,
  steps, checkpoint, observations, questions/answers and invalid variant.
  Emphasis: “The full clause burden stays visible at every checkpoint”.
  Non-goals: “No installing, running or validating anything; no command
  lines; no APIAnyware. No coverage of profiles beyond the fixture.”
- Extend the existing design with independent Watch/LabelChanged/
  watch_labels/destroy_watch declarations, following F1's retained callback
  representation. Notifications carry a scalar change number, never a Card
  or Label reference. Registration returns a non-null unique Watch, supports
  zero-or-more invocations after return, and blocks for quiescence on destroy.
- Part 5 explains the access blocks already present. Publish a complete
  borrowed-result checkpoint and a separate owned-snapshot package; change
  current_label's symbol as well as its give/invalidated_by clauses. Keep
  the non-null successful result and existing Label destructor, so the
  exercise changes ownership without inventing an allocation-failure mode.
- Grammar and semantic inspection of `04-callbacks.ail`: read the complete
  package against grammar.ebnf's document, dependency, environment, nominal,
  enum, callable, callback_use, outcome, access, clause, value and type
  productions. L1: correct header, lexical forms, strings and closed
  vocabulary. L2: unique local names, valid synthetic digest shapes, no
  imports/cycles, all type/destructor/slot references resolve. L3: release
  and subset stated, exports include dependencies, exact F1 environment,
  all declarations available in test. L4: resource handles, nullable Card
  creation, closed i32 status cases 0/1, u64 callback value and unit results
  are admitted. L5: availability/deprecation and required common clauses,
  singular clauses and per-place input/output clauses have their scopes.
  C1: no cyclic or call-scoped escaping borrow; current_label's owner is a
  valid non-null Card. C2: Card, Label and Watch each name a consuming
  non-null resource destructor with unit/successful-returned completion;
  all nominals have compatible sharing/isolation. C3: every callable has
  seven effects, every input reference has input/retain and borrowed valid;
  handler retention is prospective in the returned Watch region. C4:
  copy_text's disjoint out mutptr provides capacity 8, initialized length 7
  and UTF-8/NUL contents; pointer and mutation clauses agree. C5: creation
  splits null/non-null, copying exhausts closed status values, other calls
  use one any outcome; all non-unit results and output storage have states,
  all valid reference outputs have give, only the returned borrow has its
  refresh invalidator with matching owner/mutation. C6: one full schedule
  per callback parameter, after_return/0..many/owner scope agrees with
  strong retention, unique destructor quiescence and outside_callback;
  invocation declaration and use have compatible executor/concurrency/
  reentrancy. C8: no missing applicable facts or contradictions found.
  A1–A4/F1: synthetic aliases/pins resolve in fixture mode, all functions
  have four-clause c/symbol/identity/stable paths covering test; callbacks
  have c callback ABI and retained closure representation; all reachable
  types are supported. A5: prose preserves these obligations without
  asserting real execution or consumer feasibility. L6/C7 inapplicable:
  no patterns or global storage.
- `05-finished.ail`: repeated whole-package inspection against the same
  grammar and applicable rules. Its only change from checkpoint 4 is the
  package name; all contracts and references remain local and complete.
  `05-owned.ail`: inspected the whole package and its exact diff from the
  finished package. L2/L3 give it a distinct identity and stated variant
  surface. C1/C2/C5: owned Label replaces the owner borrow, removes the
  earlier invalidator and creates exactly one existing unique lifecycle
  obligation. C3 input borrow/retain(none)/valid(call) and mutation(none)
  remain consistent with an independent snapshot. C5's non-null successful
  result still has an exhaustive valid any outcome; no failure mode was
  inferred. A2–A4/F1 still lower the same signature, and via names a distinct
  synthetic implementation for the changed whole contract. All other
  declarations, pins, exports, states, schedules and dependencies remain
  present. Comment region markers have no semantic effect (L1).
- The guided-change table enumerates each actual edit and each retained
  obligation it could affect, including publication, exports/dependencies,
  signature, lifecycle, input/output clauses, outcome, access, effects,
  copying, callbacks and consumer views. Invalid variants were compared
  directly to C6 (return quiescence with owner scope) and C5 (missing give
  on a valid Label result). Both defects can be observed without execution.
- Used doubt-driven-development and the leaf's one fresh-context reviewer
  for the completeness claim that the documentation gate cannot establish.
  Supplied the three packages, both new pages and canonical contract, with
  an adversarial prompt. Result: no substantive findings; no reconciliation
  change or second review needed. This is inspection, not semantic execution.
- Evidence scope: Tier 2 project
  `Users-antony-Development-APIAnyware.improve-api-interface-language-docs`,
  fast generation 2026-09-23T09:55:55Z. File graph query returned zero with
  has_more false. Coverage reports normative Markdown metadata matching,
  grammar untracked, examples and research/design subtrees excluded, and
  tutorial pages untracked. Direct source reads supply the evidence; no
  graph completeness or runtime claim is made.
- Whole-tutorial read confirms the approved API continues without redesign.
  Parts 4 and 5 have the seven required sections, with questions before
  answers and one labelled invalid variant each. Part 5 presents access,
  the finished checkpoint, then its guided change in that order. The
  complete checkpoint remains visible; the changed operation is a marked,
  source-checked fragment linked to its complete package. The node brief
  carries precise art handoffs, alongside those for parts 1–3.
- Final `task docs:check` exited 0 after the reading-order adjustment:
  docs:links checked 19 files with 17 pages reachable, docs:examples checked
  19 files, and g1-context/g2-package/g3-access/g4-ownership/g5-borrow/
  g6-lifecycle/g7-callbacks each regenerated identically. Before/after
  SHA-256 manifests matched for 50 subject files: all files under
  `semantic/specification/interface-language/` and
  `semantic/specification/tools/` except generated Python cache files,
  plus Taskfile.yml, the documentation plan and audit. Manifest digest:
  `d85915064de97917ab4883aac22c4d50e25ba65c957c3c80af945cd90272ea39`.
  No measurement subject changed during the run. No AIL validator or native
  runtime was executed.
- Navigation was inspected from the existing landing/concept links through
  the tutorial index and each part. Both new parts replace plain-text index
  entries; part 3's interim next route and part 1's part-5 mention now link
  the landed pages. The new pages return to the index and point onward to
  existing pages. No additional landing/concept edit was needed.
- Added `tutorial-k33` with kind copy-edit as the last production act;
  it owns the whole index and five-part set, followed lazily by art and
  proof. That live sibling keeps tutorial-k7 open, so no parent cascade is
  due. No durable architecture decision requires an ADR change.
