# reviewer-journey-k18

## Goal

Integrate navigation across the finished set and append the Step 2 index to the audit.

## Context

- Structure brief: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §9.6. It states the reader and outcome, the ordered
  sections with their purposes, and the emphasis and non-goals. Quote it
  rather than re-deriving it.
- Prose contract, labels, figures and checks: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §4–§7.
- Evidence: the audit (`semantic/docs/research/interface-language-documentation-audit.md`) and the survey's §9 criteria D1–D8.

## Done when

- Every page has an inbound link from the map or its parent index. Links
  between rules, entries, explanations, tutorial parts and review tasks run
  both ways, and so do the model routes: the model page's concept sections and
  map rows link their reference entries and review tasks, which link back.
- The final syntax routes follow model-reading-k73: G10 embeds and the
  grammar description live in `reference/notation.md`; every other page's
  syntax links reach the relevant section while its local example context
  remains. Walk this from explanations, tutorial, canonical aids and review.
- The audit's "Step 2: refactored output" section maps F1–F12 to their
  resolving pages, gives the status of Q1–Q6 and any added questions, and
  names what remains unresolved.
- `task docs:check` passes.

## Notes

This is navigation work. Rewording elsewhere is limited to what a broken journey forces, and anything larger is handed back as a correction run to the owning document.

This is the node's last draft session, so its last act is `leaf-add` of the `copy-edit` leaf, unless a live later sibling already holds one.

## Decisions (running log)

D1 — The structure brief is plan §9.6: “Every reader, from every entry point,
can reach the page answering their next question”; its ordered sections are
“Landing page”, “Back-links”, “Where next”, “Glossary” and “Step 2: refactored
output”. Its emphasis is “No page is orphaned and every link has a return
path”; its non-goals are “No new content pages and no rewording outside
navigation, except where a broken journey forces it.” All three preconditions
are explicit in the named artifact. This draft owns navigation structure and
the technical truth of the destinations and audit dispositions.

D2 — Complete direct model-to-reference/task routes in each concept section
and map row. Preserve the existing domain, notation, tutorial and rule links.
Connect review tasks to the exact entries they exercise and supply reverse
links; repair the stale forthcoming-review-guide footer and the tutorial's
interim conformance destination. Keep canonical changes inside reading-aid
markers, and leave examples and figures intact.

D3 — Step 2 distinguishes supplied documentation from unresolved language
questions and unmeasured reader outcomes. Q1–Q6 stay open. The positive human
assessments in first-path-reading-k64 and model-reading-k73 have unreported
reading extent; neither establishes whole-path comprehension. No new language
question follows from these navigation repairs.

D4 — Tier 2 graph project confirmed at generation 2026-09-23T09:55:55Z.
Coverage was checked for the document corpus and contract paths: semantic/docs
and examples are excluded; relevant Markdown metadata is changed or untracked.
Navigation evidence comes from direct source reads and link enumeration, not
graph completeness. No production-code structure is investigated.

D5 — Walked the guided footers (landing → domain → model → contracts →
packages → choices → tutorial parts 1–5 → review) and the direct-entry types:
C6 → callback model → schedule reference → Stretch; model concepts → notation,
tutorial, rules, entries and tasks; buffers.ail via the landing's walkthrough
pairing; quiescence glossary → domain/model/rule/entry/Stretch; valid reference
→ model/rule/explanation/tutorial/Predict. Existing linked examples retain
their local omission and synthetic-provider context. The glossary's linked
term destinations remain defined; this navigation work introduces no new
domain term needing a definition.

D6 — Enumerated all 29 Markdown pages: each has a direct inbound link from
the landing or its parent index. Checked all eleven model sections and map
rows for reference/task destinations and direct concept returns. Checked the
task-to-entry returns, then added the grammar-section returns for the tasks'
pre-existing exact-syntax links. Removing a validity return in memory made
the route check fail, confirming that the clean check can detect that defect.
Enumerating Markdown image destinations puts G10 embeds only in notation.md;
that page supplies the positive control. Relevant syntax links and local
examples were inspected in explanations, tutorial, canonical aids, glossary
and review. These are source/navigation checks, not a fresh human reading.

D7 — Applied the verification-before-completion procedure. The first full
`task docs:check` passed: 31 files, 29 reachable pages, all 26 regenerated SVGs,
229 reference candidates, no pending entries or errors. A final read then
clarified the audit's sentence about adding aid boundaries and supplied the
grammar task returns in D6; the complete gate is being rerun against those
final edits. No in-session reviewer was spent: the route/preservation claims
have executable checks with failure controls; the human-comprehension
question cannot be discharged by a second model reading.

D8 — Compared against parent 87b1f21e: removing paired reading aids recovers
the same canonical text, with all anchors and fenced examples preserved.
The conformance and baseline bodies are identical after removing their new
page-one navigation line. Grammar, all example files and all figures have no
diff; all changed reader-page fences match the parent. Deliberately changing
normative text made the preservation comparison fail. The evidence confirms
navigation-only changes, not AIL semantic or runtime validation.

D9 — The final full `task docs:check` passed with the same per-item results:
31 files checked, 29 pages reachable, all 26 SVGs reproduced, and 229
reference candidates with zero pending entries and zero errors. A bounded
route assertion then located the new Change back-link beneath the next
heading instead of inside the Access paths section. Moved that link within
notation.md and reran `task docs:links docs:examples`: both passed. Enumerating
all seven tasks' reference links now confirms every entry's task return.
No example fence changed. Diagram inputs and coverage anchors/vocabulary were
unchanged by the move, so their successful checks remain applicable.

D10 — Measurement subjects were the entire interface-language tree, all
documentation tools excluding Python caches, Taskfile.yml, the plan and the
audit: 123 paths. The first complete run's before/after hashes matched item
by item (manifest 3f9673be0cfc8b85bf047fb540d5288bf9dcb99a60d5e2a1301ab1ea2ac51ae7).
The second complete run used manifest
0bace8e53f95f658379cbc842f915b4de3b297b9a4f0515238542beb084d6bfc;
after its completion and the subsequent link move, all subjects still matched
except notation.md, as expected. The final subject manifest is
925b4833c10c389d2e9db02730aa0e21354c5cc6c2835ff7a292314e590891ad.
The G10 placement assertion also detected a deliberately injected outside
embed. Scope coverage reports known example/SVG exclusions with no further
page; filesystem enumeration and preservation checks supply the evidence.

D11 — The leaf's navigation and Step 2 deliverables are complete under D1–D10.
No content correction run is needed. The node brief hands the pending-stage
status statements to proof for update when warranted, preserving the human
assessment and language-question boundaries. Add the ordinary copy-edit
successor with the bare stem reviewer-journey; none is already queued. Retire
this draft and seal its focused jj change. The successor keeps the node and
ancestors live, so there is no parent close or ADR change in this session.
