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

## Decisions (running log)

D1 — Bootstrap read: root brief, first-path-reading-k64 (D4–D18), the
documentation plan in full, the rule-reading/orientation/concepts/tutorial and
reference/review-guide/reviewer-journey briefs and queued leaves, the landing
page, the domain page, and the openings of the contracts and packages
explanations and tutorial part 1, plus the heading outlines of every
first-path page and canonical rule page. Finding: the first path is
domain-first *within* each section (each obligation starts from a watch or
store case), but no page gives the model as a whole. Entities and their
relationships are scattered across six obligation sections of the domain page,
and the notation pages open with syntax: the contracts page with clause shape,
the packages page with a package shell and the containment model, tutorial part
1 with the package shell and synthetic pins before the card's lifetime. G9 is a
language-containment model, not a model of API behaviour. The canonical
page-one blocks route a direct reader to the domain page, not to a model.

D2 — The canonical model account is a new page, `explanation/model.md`,
between the domain page and the notation explanations. It is AIL-light: it
names the entities and relationships a description records, illustrated by the
watch API the reader already met, and links each concept back to the domain
page's failure case rather than re-teaching it. It ends with the concept-to-
notation map. The domain page keeps its purpose (why the obligations exist);
the model page answers *what the description records and how the parts
relate*; the concept pages answer *how AIL writes each part*. Alternatives
rejected: rebuilding the domain page into the model (loses its tested
failure-case route and overloads a 470-line page), or a model section at the
top of the contracts page (keeps the model subordinate to notation, the
defect the human named). Each model concept gets a stable explicit anchor, so
concept pages, tutorial parts, canonical aids and later reference entries link
to one canonical explanation.

D3 — The model page belongs to the orientation document (domain problem and
domain model, before any notation), so its run is the first new run and every
later run can link it. Orientation's run also repairs the landing route and the
two stale k64 residues found by direct search: the README and glossary still
link "the package shell and railroad reading key", and the README says reading
aids carry "an explicit end marker". Remaining `Reading key` hits are
domain/model figure keys, which the audience contract keeps.

D4 — Canonical reading-aid model routes go in the concepts run as its own draft
session, not under rule-reading-k49. Pre-order puts rule-reading before
orientation, so a leaf there would run before the model page exists; moving the
done node by hand would misstate the visible history. The concepts run defines
the concept sections those routes target, and its copy-edit/art/proof then
read the changed aids under the existing preservation check. The aids' reference
lookup routes stay with the reference node, as §9.4 already states.

D5 — One earlier human read is justified and placed after the orientation run,
before the concepts run: `model-reading`, a requirements checkpoint with one
concrete question — does the model page's concept set, order and concept-to-
notation map give the right account before the concept pages, tutorial,
canonical aids, reference and review guide are organized around it? About
twenty later sessions depend on that answer. The full-set checkpoint stays
after cross-set navigation.

D6 — Bounds. The human direction at first-path-reading-k64 (D12–D13)
authorizes exactly one further ordered run for each of orientation, concepts and
tutorial: draft session(s), then one copy-edit, one art and one proof. All
stages are queued now so the bound is visible in the tree, as the k52–k63 runs
were. No correction run inside these runs is authorized automatically; residue
that would send work back is recorded for the next human checkpoint. This is
new scope from the human, not a reset of the documents' correction history.

D7 — Revised the documentation plan: outcome 6 (describe the model; appended so
cited outcome numbers 1–5 stay valid); the model page in §2; §3's three-stage
learning route (why a description is needed → what it records → how AIL
writes it) with exact lookup kept separate and a new direct entry from a model
concept; §4's distinction between the API model (G11, `model.md`) and the
language-containment model (G9), plus the concrete rule that every
notation-introducing section names and links its concept first; G11 in §6;
the bounded runs and `model-reading` in §8; model-first blocks in §9.1–§9.3;
an *Expresses* entry field, a model-concept index and concept-aware coverage in
§9.4 and §7; a model-framed statement of the six review dimensions and a
*Model fit* task in §9.5; model routes in §9.6 and §9.7; the model page's own
brief as §9.8; and the concept-to-notation contract as §10. §10's eleven
concepts and their construct lists were checked against the rule text and
grammar: every named construct occurs in `language.md`, `contracts.md`,
`profiles.md` or `grammar.ebnf` (a nonsense control token counted zero).
Model-page anchors are written as code, not links, so the plan's link check
stays green until the page lands; a deliberately added link to the absent page
made `docs:links` fail, and the restored plan passes.

D8 — Cut the tree. Orientation (orientation-k5): orientation-k69 draft (model
page, G11 slot, landing/domain/glossary routes, the two k64 residues),
k70 copy-edit, k71 art (G11), k72 proof. Root: `model-reading-k73`, inserted
before the concepts node (the insert renumbered later root entries only; no
file contents changed). Concepts (concepts-k6): k74 draft (contracts page in
§10 order), k75 draft (packages and choices), k76 draft (canonical model-
concept routes under the preservation check), k77 copy-edit, k78 art, k79
proof. Tutorial (tutorial-k7): k80 draft (index, parts 1–3, part-1 reorder),
k81 draft (parts 4–5), k82 copy-edit, k83 art, k84 proof. Each node brief
gained a *Model-first run* section stating the direction, the one-run bound,
the absence of any automatic correction run and the run's done-when. The
reference, review-guide and reviewer-journey briefs and their queued drafts,
and the full-set checkpoint, now consume §10: the *Expresses* field,
model-concept index and concept-aware coverage; model-framed dimensions,
concept-grouped walkthroughs and *Model fit*; two-way model routes; outcome 6.
The root brief's decomposition records the cut.

Verified order with `grove-llm pick` (returns orientation-k69) and a sorted
listing of live leaves: orientation k69–k72, model-reading-k73, concepts
k74–k79, tutorial k80–k84, this leaf, reference k16/k21–k23, review guide
k17/k24, reviewer journey k18, full-set reading k12. Pre-order finishes each
node before its next sibling, so every run lands before the reference node.
`task docs:check` passed: links for nineteen files with seventeen pages
reachable, examples for nineteen files, all twenty-four SVGs regenerated
identically. The change touches only the plan and `.grove/`; no reader-facing
page, example, figure or normative text changed.

D9 — No review-planning leaf. The subtree follows the reviewed k3
architecture with bounded runs, and its one new load-bearing element, the
concept set, goes to the human at `model-reading` before anything is built on
it. The in-session reviewer allowance was not spent: the one checkable claim
(every mapped construct exists in the rules) was verified mechanically with a
control. No Grove issue update: this session produced a plan, not new reader
evidence, and k64 already posted the structure-brief lesson (#15).
