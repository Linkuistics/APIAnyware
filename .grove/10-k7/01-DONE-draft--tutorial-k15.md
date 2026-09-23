# tutorial-k15

## Goal

Design the tutorial's synthetic API and draft `tutorial/README.md` and parts 1–3, with their checkpoint packages in `examples/tutorial/`.

## Context

- Structure brief: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §9.3. It states the reader and outcome, the ordered
  sections with their purposes, and the emphasis and non-goals. Quote it
  rather than re-deriving it.
- Prose contract, labels, figures and checks: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §4–§7.
- Evidence: the audit (`semantic/docs/research/interface-language-documentation-audit.md`) and the survey's §9 criteria D1–D8.

## Done when

- The API design is recorded in `tutorial/README.md`, and it differs on the
  surface from the conformance examples.
- Parts 1–3 follow §9.3's per-part order. Each checkpoint is a complete
  package for a narrower declared `surface`, using region markers, and each
  part has an invalid variant that cites its rule.
- For each checkpoint, a note in this leaf's decision log records its
  inspection against the grammar and each applicable rule.
- Every checkpoint, from part 1 on, carries the `access` blocks A2 requires
  on its functions, with their provider dependencies (plan §9.3).
- Under the staging rule in the plan's §3: the landing page's map and the concept pages link
  `tutorial/README.md`; the index links parts 1–3 and names parts 4–5 as
  plain text; each part has a return route and a next route to an existing
  page.
- `task docs:check` passes.

## Notes

If an unclear rule blocks the natural design, choose a construct the rules settle and add the question to `explanation/choices.md`'s register. Do not invent a rule.

A later draft sibling finishes this document, so do not cut `copy-edit` here: the last draft session does.

## Decisions (running log)

- Structure precondition: plan §9.3 identifies the reader as “The primary
  reader, after the concept pages or arriving directly with only the
  orientation” and the outcome as “write and read a complete AIL package”.
  Its ordered plan starts with “A package and one resource”, then “Lending
  access”, then “Caller-supplied storage and failure”; each part has goal,
  obligation, steps, checkpoint, observations, questions/answers and invalid
  variant. Emphasis is “Short parts, each ending in a check”; non-goals are
  “No installing, running or validating anything; no command lines; no
  APIAnyware.” These are the named artifact's contract, not an inferred brief.
- Use a synthetic label-card API. Part 1 publishes Card/create_card/destroy_card.
  Part 2 adds a borrowed opaque Label, its required unique destructor,
  current_label and refresh_card; refresh invalidates the old Label borrow.
  Part 3 adds a closed CopyStatus and copy_text with seven UTF-8 code units
  plus a terminator in caller storage. This differs from the immutable raw
  byte-store conformance example in types, mutation, text and result domain.
- Keep separate package identities per complete checkpoint at version 1,
  each naming its release/subset and exporting all included declarations.
  Include synthetic F1 pins and complete access blocks from checkpoint 1.
- Reserve the owned-result exercise for a changed current_label returning
  an independently owned Label snapshot, retaining Label's unique destructor.
  This avoids the unsupported owned-pointer allocator/release requirement in
  C5 and needs no semantic extension or new open question. Part 4 can add an
  independent label-change subscription with a unique Watch owner; it does
  not change Card's established lifetime or refresh contracts.
- Grammar and semantic inspection, checkpoint 1 (`01-lifetime.ail`): read
  the whole package against `grammar.ebnf` (document/dependency/environment/
  nominal/callable/outcome/access/clause/value/type productions). L1: UTF-8,
  header, identifiers, strings, comments and closed clause vocabulary. L2:
  unique names, valid pin shapes, local destructor resolution, no imports or
  cycles. L3: named release/subset, exports and complete lifetime dependencies,
  exact F1 environment, availability for every declaration. L4: resource is
  a handle, nullable only on creation, unit only as result. L5: required
  deprecation and implements, singular/per-place clause scopes. C1: legal
  places, null has no obligation. C2: unique lifecycle, matching consuming
  unit destructor and compatible sharing/isolation. C3: seven effects per
  function, consume/retain on destruction, no borrowed input needing valid.
  C5: exhaustive nonnull/null partition with valid results and conditional
  owned give; unit destructor has one successful returned outcome. C8:
  no absent applicable fact found. A1–A4/F1: declared synthetic aliases,
  fixture64/fixture-1, exact a/b digest tokens, one complete c/symbol path
  per function covering test, faithful identity mapping and stable fixture
  representation for the reachable types. L6, C4, C6 and C7 are inapplicable
  (no patterns, pointers, callbacks or globals). A5: checkpoint/prose retain
  every contract fact; no binding feasibility or real provider claim.
- Checkpoint 2 (`02-lending.ail`): repeat the grammar and L1–L5/C1–C3/C5/C8/
  A1–A5/F1 inspection over the expanded package; checkpoint 1 declarations
  retain their clauses. New dependencies Label/destroy_label/refresh_card
  resolve in test. Label's required lifecycle remains explicit despite a
  borrowed result. Its destructor consumes exactly one non-null Label.
  current_label borrows Card for call and returns a non-null valid Label
  borrow bounded by owner($card); no call-scoped escaping borrow or cyclic
  lifetime. refresh_card has that owner parameter and mutation(arguments),
  making it a C5 earlier invalidator. Single any outcomes cover the non-null
  Label result and unit refresh. New functions carry all effects and A2
  paths. L6/C4/C6/C7 remain inapplicable.
- Checkpoint 3 (`03-storage.ail`): repeat the grammar and prior applicable
  rule inspection over the expanded package; earlier declarations retain
  their clauses. L4/C2: closed i32 CopyStatus has unique representable cases
  0/1, value sharing and no isolation. C3: both reference inputs explicitly
  borrow with retain(none)/valid(call); output mutptr agrees with out,
  disjoint and mutation(arguments). C4: seven u8 UTF-8 code units plus NUL
  fit capacity eight, fixed bounds are valid at entry, allocated storage is
  required even on failure, no initialized entry data required for out.
  C1/C5: [] addresses the buffer length, success initializes valid text,
  failure gives no initialized elements, and result remains a valid closed
  enum discriminator on both exhaustive outcomes. No give is owed on scalar
  output bytes or on the caller's borrowed destination pointer. A3/F1
  provide scalar/pointer/nominal representations and UTF-8. L6/C6/C7 remain
  inapplicable. Each invalid teaching mutation was separately compared to
  its cited rule (C2 destructor borrow, C1 escaping call region, C4 missing
  terminator capacity).
- Used the leaf's one in-session reviewer under doubt-driven-development:
  the claim at issue was completeness of the checkpoint contracts, which
  the docs check cannot establish. Passed packages and canonical rules in
  fresh context. The review read the excluded AIL sources and untracked
  grammar directly and returned no findings. No reconciliation changes or
  second review were needed; this is inspection, not semantic execution.
- Evidence scope: Tier 2 project
  `Users-antony-Development-APIAnyware.improve-api-interface-language-docs`,
  fast generation 2026-09-23T09:55:55Z. Graph File lookup returned no results
  with no further page. Coverage reports rule Markdown metadata matching,
  grammar untracked, examples excluded by subtree. All technical conclusions
  above come from direct rule/grammar/package reads, not graph completeness.
- Final structure/technical read: each part follows §9.3's seven sections;
  questions precede answers, each invalid variant identifies its replacement
  location and rule, and the index states API choices separately from AIL
  rules. The comparison cases are non-null/null creation, live-owner/expired
  label borrow, and valid-status/invalid-output failure. Corrected an overly
  broad prose statement from “reference type” to “resource” for C2 lifecycle
  applicability. No contract redesign or additional reviewer was required.
- Final `task docs:check` exited 0: links checked 17 files with 15 pages
  reachable; examples checked 17 files; each of g1-context, g2-package,
  g3-access, g4-ownership, g5-borrow, g6-lifecycle and g7-callbacks regenerated
  identically. No validator or native runtime was executed. Before/after
  SHA-256 manifests for every rg-visible file under
  `semantic/specification/interface-language/` and
  `semantic/specification/tools/`, plus Taskfile.yml, the documentation plan
  and the audit, matched aggregate digest
  `c8647d2801716fd4f4f43f8e25b594719a619afdc42d84fd6a7f66171be93ace`.
  No subject was edited during that final measurement.
- Navigation checked from the landing map through the tutorial index and
  parts 1–3, back to the index and onward to existing pages. All concept
  pages link the index. Parts 4–5 remain plain text; part 3 uses the callback
  explanation as its interim next route. The node brief carries the precise
  figure handoffs and continuation context. k20 remains live, so there is no
  node close or copy-edit leaf to cut in this session. No durable design
  decision requires an ADR change.
