# reviewer-documentation-k25

**Reviews:** reviewer-documentation-k3

## Goal

Adversarially read the planned subtree and its two planning artifacts before
any of it executes. Produce findings, not fixes.

## Context

- The producer's commit (find it by the handle `reviewer-documentation-k3`)
  holds:
  - the audit, `semantic/docs/research/interface-language-documentation-audit.md`;
  - the plan, `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`;
  - the root brief edits, the node briefs and the leaves at root positions
    after this one.
- The producer's decision log, D1–D9, is in its task file.

## Doubts to test first

1. **Audit accuracy.** Spot-check the audit's line references, counts and
   first-use claims against revision `1c4b8e7ec3da`. Is each Q1–Q6 truly a
   question about the language and not a presentation defect, and are any
   presentation findings really language questions?
2. **Structure briefs.** Does each §9 brief state all three things the `draft`
   kind requires (reader and outcome, ordered sections with purposes,
   emphasis and non-goals) as quotable text? Could a draft session run from
   it without inventing an audience or an order?
3. **Increments and order.** Does each increment leave every landed page
   navigable? Is the reference correctly placed before the review guide and
   after the first reading checkpoint? Are the tutorial's and the reference's
   links to not-yet-existing pages handled?
4. **Session sizing.** Are the 12 `draft` sessions sized for one session each,
   especially the reference's four and `explanation/contracts.md`?
5. **Kinds.** Are `requirements` leaves the right kind for the human reading
   checkpoints? Is `draft` right for the cross-set navigation node?
6. **Scope.** Does anything drift into changing the language, beyond the
   explicit anchors that `docs-foundation` adds to the normative files and the
   page-one blocks the reference adds? Does anything claim the old EBNF
   recognizer or the `.apiw` validator as evidence?
7. **The L3 subset claim** (decision D6): may each tutorial checkpoint be a
   complete package for a narrower surface?

## Done when

Findings are committed, each with its location, the evidence and a severity.
An `integrate-review-planning` leaf is cut only if a finding is worth acting
on, placed where `pick` reaches it next.

## Decisions (running log)

D1. The reviewed producer is commit `8103dd6b`, whose parent is the audit's
`1c4b8e7ec3da`. Its diff leaves the specification corpus unchanged, so direct
reads of that corpus also check the audit's cited revision. This is a
documentation-only inspection; no test, build, lint or format commands run.

D2. Three findings warrant integration: the clause inventory omits vocabulary
defined outside tables; early draft leaves defer their inbound navigation to
later siblings; and the audit overstates the semantic effect of capitalization.
The review report retains evidence and severity for each. The plan and task
contracts remain unchanged by this review; inserting integration only shifts
later siblings' positions.

D3. Findings are in
`semantic/docs/design/2026-09-23-interface-language-documentation-plan-review.md`.
Integration is `reviewer-documentation-k26`, immediately after this review and
before `docs-foundation-k4`. Its charter points to this review for independent
triage rather than restating the findings as mandatory fixes.
