# model-reading-k73

## Goal

Obtain the human's assessment of the model account before the concept pages,
tutorial, canonical aids, reference and review guide are organized around it.

## Context

- The human's direction and rationale: first-path-reading-k64, D12–D13.
- The page under assessment: `explanation/model.md` with G11, landed by
  orientation-k69 through orientation-k72; its contract is plan §9.8 and the
  concept-to-notation map in plan §10.
- What depends on the answer: the queued concepts run (concepts-k74 to k79),
  tutorial run (tutorial-k80 to k84), and the reference and review-guide
  briefs (plan §9.4–§9.5), all of which name and link §10's concepts.

## Work

Ask one concrete question and give a concrete route. Route: the model page's
*The model at a glance* and G11, then two concept sections the human chooses
(suggest *validity* and *callbacks and their schedules*, which carry the watch
API's hardest cases), then the closing map. Question: do the concept set, its
order and the map give the right account of what an API description records —
is any concept missing, redundant, mis-grouped or at the wrong level — before
the rest of the documentation is reorganized to refer to it?

Record the human's words and the pages or headings they actually report
reading. Triage each finding: an edit to §10 and the dependent briefs and
queued leaf bodies; model-page work for the human to direct (the run's bound
authorizes no automatic correction run); a language question for
`explanation/choices.md`; or no action, with a reason. Update the existing Grove
issues with new evidence only where it adds an observation, keeping
observation separate from proposed remedy.

## Done when

- The human's assessment and reported reading extent are recorded verbatim.
- Every finding has a disposition, and §10 plus the queued concepts/tutorial
  leaves reflect any change to the concept set before they run.
- The concepts run can start from a concept set the human has judged, or the
  leaf stays live stating that the assessment is still needed.

## Notes

HITL. This is the single earlier read the model-first planning justified: it
answers whether the foundation is right, not whether the whole path is
understandable (the full-set checkpoint owns that). Do not substitute a proxy
reader for the human's judgement, and do not infer approval of unread
sections. If the human is unavailable, leave this leaf live.

## Decisions (running log)

D1 — Human feedback, verbatim (2026-09-29):

> The model page diagrams show as broken image placeholders

The reported surface is the model page's diagrams. The human has not yet
reported which prose sections they read or assessed the concept set. Diagnose
and repair the image presentation so the reading can continue; keep the
concept-set assessment pending. This report does not authorize or require
another model-content correction run.

D2 — Presentation diagnosis: both relative image targets exist in the current
workspace. `xmllint --noout` accepts both G11 SVGs, and `rsvg-convert --zoom
1.5` renders both to PNG; visual inspection shows the complete call and
description views. Temporary direct PNG previews were supplied as a reading
workaround. These checks do not reproduce or resolve the broken embeds in
the human's page viewer. The viewer has been requested and remains needed to
diagnose that boundary; no documentation-image change is justified yet.

D3 — Human clarification, verbatim (2026-09-29):

> When I view the MD in VSCode Preview

D4 — Reproduced the failure in the human's VS Code window: the Explorer
reported `No Folder Opened`, the preview displayed both image alt texts in
place of the diagrams, and Developer Tools reported HTTP 401 for both
`g11-calls.svg` and `g11-description.svg`. VS Code's Markdown extension
allows a standalone file's local resources only beneath that file's own
directory; the sibling `../figures/` directory was outside it. The installed
extension and its upstream `getMarkdownLocalResourceRoots` implementation
agree on that rule:
<https://github.com/microsoft/vscode/blob/main/extensions/markdown-language-features/src/util/resources.ts>.

Opened `semantic/specification/interface-language/` as the VS Code folder and
reopened `explanation/model.md` in preview. Visual inspection confirmed both
G11 views now render in the page. Restricted Mode remained enabled. The
Markdown links, SVGs and model content required no change. Future VS Code
reading handoffs should open this containing folder or the workspace root,
then the page. The image-loading finding is resolved; the human's concept-set
assessment and reported prose-reading extent remain pending.

D5 — Added the reader-environment observation to Grove's existing proof and
reader-testing issue, separating reproduction and verified repair from the
proposed handoff improvement and from any comprehension claim:
<https://github.com/Linkuistics/grove/issues/18#issuecomment-5884943848>.
The root brief carries the VS Code folder-opening requirement for later
reading handoffs. No change to plan §10 or the queued concept/tutorial work
follows from this image-loading finding.

D6 — Human assessment and direction, verbatim (2026-09-29):

> This is looking good - however we don't need to describe the syntax in prose - for example: "The package braces locate both the Watch type and watch_close operation. watch: Watch names a parameter and its type; -> unit says that the function returns no value. Inside the function, $watch addresses that parameter. A clause takes the form name(arguments);: parentheses group arguments, commas separate them, and the semicolon ends the clause. outcome closed opens a nested block describing one way this call finishes. Comments beginning with // explain omitted context (L1, L2, L4, C1)." doesn't need to describe parentheses, commas, semicolons etc. That is obvious to the language-aware reader  through both the syntax example of the railroad diagram. In fact, given your excellent use of example fragments, we should keep the railroad diagrams with the grammar description, and just link to the grammer/railroad diagrams.

The identified passage is `explanation/contracts.md`, *From signature to
contract*. The human positively assesses the material and its example
fragments, and asks for an audience-appropriate separation between explaining
the model and looking up syntax. They do not report the full extent or order
of their reading. Preserve that limit; do not infer that they read every model
section or completed the full reviewer journey.

D7 — Keep the model concept set and order. The human requests an editorial
change, not a missing concept or a language-semantic change: use examples to
show familiar syntax, explain the AIL-specific meanings and relationships
needed to understand the API model, and omit prose tutorials on punctuation
and other self-evident syntax. Railroad views belong with the grammar
description; other pages link to that location. Apply this through the queued
document work, preserving examples, canonical wording and stable anchors.
The positive assessment with this concrete refinement is sufficient to
continue the queued work; it is not evidence of comprehension of unread
sections. No full grilling or additional model-content run is needed.

D8 — Stage the grammar home before its consumers. Inserted concepts-k85
before concepts-k74 in the existing concepts run: it lands the grammar and
eleven existing G10 views in `reference/notation.md`, with stable section
anchors, a landing-page route and links from the canonical aids. The existing
drafts then replace embedded railroads with links and remove elementary
syntax commentary in the explanations (k74–k75), canonical aids and glossary
(k76), and tutorial (k80–k81). Existing examples and semantic figures stay.
The concepts run's already-queued copy-edit, art and proof cover the expanded
document; no extra correction run is cut. Reference-k16 later extends the
same notation page with reference-entry conventions and indexes. Reference,
review-guide and final-journey briefs carry the same distinction between
explaining meaning and looking up grammar.

D9 — Human reminder, verbatim (2026-09-29):

> Remember that we want to convert everything we've learnt here about produce good documentation into skills/agent guidance, so we want to keep everything we've learnt in some way.

Preserve this session's observations and their limits in the existing Grove
guidance issues, linked from this log and the root brief. Capture the audience
model, what an explained example needs to explain, the separate homes of
semantic and syntax figures, the verified VS Code handoff repair, and the
limits of a positive but partial reading. Record proposed stage-specific
guidance separately from observed reader evidence. Keep the full quotations
here and the resulting document contracts in the plan; issue notes are durable
inputs for later skill work, not a claim that Grove's skills already changed.

D10 — Preserved the new evidence in the existing Grove issues:

- Cross-stage record and guidance candidates, including copy-edit, proof,
  reader testing and cross-session retention:
  <https://github.com/Linkuistics/grove/issues/14#issuecomment-5885384609>.
- Draft/structure-brief refinement of what an explained example must explain:
  <https://github.com/Linkuistics/grove/issues/15#issuecomment-5885388298>.
- Art refinement: semantic figures beside the concept, railroad figures with
  grammar, and textual grammar rather than punctuation narration:
  <https://github.com/Linkuistics/grove/issues/17#issuecomment-5885388607>.

Each distinguishes observed feedback from proposed guidance and queued edits,
retains the audience and unreported reading extent, and links the earlier
verified image-loading repair. The root brief and plan now require later
checkpoints to preserve these evidence-to-guidance records as well.

D11 — Verification and disposition: `task docs:check` passed after the plan
revision: links and examples checked 20 files, 18 site pages were reachable,
and all 26 SVGs regenerated identically. The 105 verification subject files
(the specification tree, its tools, Taskfile, plan and audit, excluding Python
cache files) had the same SHA-256 aggregate before and after the run:
`55a2b5e76252919d847ca375482e6cf50472f32179f5d47cc38ce98ac722feef`.
`jj diff --name-only semantic/specification/interface-language` was empty:
this session changes requirements and queued work, not the published rules,
examples, figures or prose. The viewer repair is verified separately in D4.

Reviewed the changed plan and live contracts for the old embed/punctuation
instructions, retaining completed-run history while updating the current
requirements. Grove resolves concepts-k85 before k74–k79 with the correct root
and concepts brief chain. All three new GitHub comment bodies were fetched
and compared with the submitted text. Every human finding now has its
disposition in D4–D10; the concepts run can proceed under the unchanged §10
concept set and the new presentation contract. The root still has live work,
so no ancestor closes at this checkpoint.
