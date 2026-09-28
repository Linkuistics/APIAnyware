# model-first-documentation-k68

## Goal

Revise the documentation plan and cut bounded document work so the learning
path explains the conceptual model, then describes AIL by reference to it.
The language serves the job of describing API behavior and binding obligations.

## Context

- Human direction and rationale: first-path-reading-k64, D10–D13 and its
  subsequent dispositions. The human positively assessed the improvement;
  their exact page-by-page reading extent is unreported.
- Documentation plan: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`,
  especially the reader/purpose, journey, prose contract and §9 structure briefs.
- Existing orientation, concepts, tutorial and rule-reading documents, their
  node briefs and correction history. The reference and review guide are still
  queued after this planning leaf.
- Draft 0.1's canonical language, contract and profile files and grammar are
  the technical authorities. The existing design rationale may explain choices;
  the task does not authorize changing language semantics.

## Work

Establish the smallest coherent model account needed to understand what AIL
describes and why: entities, relationships, observable behavior and obligations,
illustrated through concrete API cases. Give each introduced language construct
a named model concept and reader task to refer back to. Keep package/declaration
containment and syntax diagrams in service of that account. A reordered grammar
tour or an extra model diagram alone does not fulfill the request.

Read the current first path and choose its revised section/page boundaries.
Preserve useful explanations and examples. Reconcile the orientation, concepts,
tutorial, direct rule-entry aids and reference/review-guide structure briefs,
including which model explanation is canonical and how later pages refer to it.
Separate exact lookup from the learning route. Preserve the domain-first,
positive and adequately developed prose contract.

Cut only the document increments needed to implement that structure, before
reference and review-guide drafting. Name the changed reader outcome and the
specific existing material each increment owns. Keep the editorial pipeline
and existing correction history visible. This new human direction authorizes
the structural revision; bound its runs explicitly rather than resetting the
old escalation history or creating an automatic repetition policy. Preserve
the full-set human checkpoint and place any earlier read only where it answers
a concrete question about the newly organized model account.

## Done when

- The current documentation plan supplies an explicit model-first learning
  route, ordered section briefs and concept-to-notation/reference connections.
- Each required revision has an actionable, bounded leaf under the appropriate
  document node, ordered ahead of the later material that consumes it.
- The existing reference/review-guide briefs consume the model account and
  ask how the language serves the description and review task.
- The plan and tree preserve the human's notation fluency, bordered
  non-normative aids, examples, stable links and exact draft 0.1 semantics.
- Navigation checks pass and the resulting task order is verified.

## Notes

This is planning, not another requirements interview over settled preferences.
The human has supplied the priority and rationale. Use judgment for routine
editorial choices and surface only a genuinely unresolved decision.

The bounded presentation fixes already landed with first-path-reading-k64:
railroad instructional boxes and generic reading-key prose were removed;
syntax views use an unboxed status caption; non-normative aids use a left
border, bold labels and explicit anchors. Reuse them instead of scheduling
their correction again. Normative text, grammar and example contracts remain
fixed. No parser, runtime, production provider, new language feature or formal
modeling project is in scope.
