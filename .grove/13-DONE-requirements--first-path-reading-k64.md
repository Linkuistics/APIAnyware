# first-path-reading-k64

## Goal

Obtain the human's assessment after the examples-and-notation correction,
before reference and review-guide drafting.

## Context

- `first-path-reading-k48`, D2–D5: verbatim feedback, the known read locations,
  H5–H7 and the explicitly bounded second correction.
- Documentation plan §8, revised §4–§6 and structure briefs §9.1–§9.7.
- Rule-reading-k49, orientation-k52–k55, concepts-k56–k59 and tutorial-k60–k63.

## Work

Begin at the repaired `language.md` L2 introductions the human quoted.
Give a concrete route through the language model, the local/imported declaration
and member examples, and the selected syntax views. Ask whether those aids now
give the notation enough context to understand the rules. Then use the answer
to proceed through the connected concepts and tutorial, retaining the earlier
ownership-exercise navigation question where the human actually reaches it.

Record the human's words and reported reading extent, without inferring the
route or approval of unread pages. Triage findings into document work, later
structure briefs, language questions or no action with a reason. Reconcile
reference/review-guide requirements and update the existing Grove issues with
new evidence as relevant, distinguishing observation from proposed remedy.

## Done when

- The human's assessment and actual reported extent are recorded.
- They have judged whether the material supports continuing the review, and
  every finding has a disposition.
- Later briefs reflect that assessment and relevant process lessons are posted.

## Notes

The human directed one further correction and then this review. Do not repeat
a questionnaire over an early comprehension problem or substitute a proxy.
The correction history and escalation bound remain in the document briefs.
No further automatic rerun is authorized: an unresolved scope or another run
requires human direction. If unavailable, leave this leaf live and state that
their assessment is still needed.

## Decisions (running log)

D1 — Begin the human read at L2's repaired introductions: the geometry/canvas
fragments and package/declaration model, followed by the member explanation,
reference/slot table and name/callable/place railroads. Ask whether those aids
supply enough context to understand the two previously quoted rule paragraphs,
and record the actual reported reading extent. Continue into the connected
concepts and tutorial only as the human proceeds. The earlier corrections'
proof results establish consistency, not comprehension; no new proxy is
commissioned. There are no three unresolved interdependent design questions
requiring a full grilling and no production-code change or runtime test seam.
The bounded correction history remains in force, and this leaf stays live until
the human assessment and its dispositions are recorded.

D2 — The existing reference and review-guide briefs, and plan §9.4–§9.5,
already require explained examples in enclosing context, reuse of the model
and railroad views, local/imported declarations, members and callable slots.
Both explicitly require this checkpoint's assessment before drafting. Retain
those requirements while the human reads; any further revision and process-issue
update must follow actual reader evidence. P7 remains a proxy observation about
tutorial navigation; ask about the ownership exercise when the human actually
reaches it, without attributing that earlier observation to them.

D3 — Preparation checks: `task docs:check` reported links and examples valid
for 19 files, 17 Markdown pages reachable, and all 24 named SVGs regenerated
identically. External URLs were not fetched. Before/after subject lists and
SHA-256 manifests matched item for item across 99 files: the interface-language
tree, documentation-checker directory (excluding ignored caches), root Taskfile,
documentation plan and audit. Manifest SHA-256:
`d1f1f5a001b757e3427406a65e123ac36daa000190d390eb05bd766ba1b94bad`.
These are consistency checks, not a human reading result.

Graph project `Users-antony-Development-APIAnyware.improve-api-interface-language-docs`
is ready at coverage generation `2026-09-23T09:55:55Z`. Coverage checks identify
changed/untracked Markdown metadata and the excluded design directory. The
checkpoint, prior reader evidence, relevant glossary/ADR text, rule passages,
plan sections and later briefs were read directly; no structural code claim
depends on graph completeness.

D4 — Human clarification, verbatim:

> You can assume the reader is familiar with railroad diagrams.

This establishes an audience assumption. It supplies neither a reported reading
extent nor an assessment that the repaired L2 explanations support continuing
the review; those remain unreported.

D5 — Carry railroad-diagram familiarity into the root reader brief, plan §1,
§4, §6 and §9.7, and the reference/review-guide briefs. Explain the AIL productions,
example spellings and their meaning; omit generic instruction on following
tracks, branches, optional paths or repetition. A concise legend may identify
the chosen drawing conventions. Keep the domain and language-model explanations
and concrete examples: familiarity with railroads supplies no knowledge of
AIL's name resolution, member relationships or contracts. This is a teaching
scope clarification, with no language change or new automatic correction run.
Retain it with this checkpoint's evidence for the relevant process-issue update.

D6 — Human feedback, verbatim:

> This is a lot better however

Record the positive assessment with its unfinished qualification. The human has
not yet specified the remaining concern or reading extent. Do not infer
full-path approval; ask for the qualification before deciding the next step.

D7 — Human clarification of D6, verbatim:

> I mean your improvement is good.

This resolves the apparent unfinished qualification in D6. The human positively
assesses the improvement; there is no additional concern in that word. Retain
D4's railroad-familiarity requirement. Ask only for the pages or headings read,
because the response supplies no reading extent; do not re-ask for approval of
the improvement or infer an assessment of unread pages.

D8 — Added the reader's positive response and railroad-familiarity clarification
to the existing Grove issues, with the reading extent explicitly unreported:

- [#14: follow-up human response](https://github.com/Linkuistics/grove/issues/14#issuecomment-5869477737).
- [#17: audience knowledge of diagram notation](https://github.com/Linkuistics/grove/issues/17#issuecomment-5869468605).
- [#12: representation knowledge and subject knowledge](https://github.com/Linkuistics/grove/issues/12#issuecomment-5869469009).

Read each posted comment back through the API and compared its body byte for
byte with the prepared text. Each matched. The comments separate observation
from a proposed general lesson and make no claim about full-path coverage,
individual stage effects or skill effectiveness. No distinct new finding
warrants duplicating the update on draft, copy-edit or proof issues.

D9 — After the audience-contract edits, `task docs:links` passed: 19 files
checked and 17 Markdown pages reachable. Before/after subject lists and hashes
matched item for item across the same 99-file scope as D3. Manifest SHA-256:
`c90414b54002137bb078d967e1058e3623d502b0b9c05b061ef992d353c79650`.
The changed files are this checkpoint, the root brief, the two later document
briefs and the documentation plan. Reader-facing pages, examples, diagram
sources/SVGs and normative material have no edits in this requirements change.

D10 — Human direction, verbatim (2026-09-29):

> Because we can assume fluency in language design and railroad diagrams, we don't need the boxes explaining how to read the railroad diagram

Apply this explicit, bounded correction now: remove the railroad-reading legend
boxes and their generic reading instructions. Keep the syntax diagrams, their
AIL examples and semantic explanations; retain the non-normative status as an
unboxed caption. Apply the same audience assumption to repeated prose keys
about standard railroad mechanics. This is the human-directed correction of a
specific presentation feature, not an automatic repeat of the whole editorial
pipeline. The positive assessment in D7 remains recorded with its stated limit
on reading extent.

D11 — Human direction, verbatim (2026-09-29):

> It would be better if the non-normative reading aids were delimited by something other than headings and an end-heading e.g. a background color, or a left margin line etc.

Use a blockquote's left border to delimit each non-normative reading aid in
the repository's GitHub-flavoured Markdown. Give each aid a bold label in place
of its heading and remove its visible end marker. Preserve existing incoming
links with explicit anchors and keep the canonical rule text outside the aid.
Verify the rendered boundary with code, tables and figures as well as plain text.

D12 — Human direction, verbatim (2026-09-29):

> I think we should prioritize explaining the model, and then describing the language by reference to the model.

Make the conceptual model the organizing structure. Explain the entities and
relationships AIL describes before teaching their surface notation; connect
each introduced construct to the corresponding model concept. This goes beyond
adding an example or railroad beside a syntax-led introduction. Carry the
priority into the explanatory route, tutorial, canonical reading aids and later
reference/review guide. Keep the existing domain-first teaching, concrete
examples and draft 0.1 semantics. Record a bounded document-planning follow-up
for the structural revision; the two presentation corrections in D10–D11 can
proceed independently within this checkpoint.

D13 — Human rationale, verbatim (2026-09-29):

> Because the language is a tool and is not of interest by itself.

The learning path serves understanding and describing API behavior and binding
obligations. Explain the relevant model concepts and relationships, then show
how AIL expresses and connects them. Judge language choices by how well they
serve that job. Package/declaration/slot structure supports that account where
needed; neither a grammar tour nor a tour of document containers is the learning
path's organizing purpose. Exact syntax remains available for reference lookup.

D14 — Applied D10–D11 across the existing presentation: eleven syntax views
now include the unboxed status caption, and the generic railroad-reading prose
keys are removed. The three canonical pages have thirty-seven bordered aids
with forty-two bold labels and preserved explicit anchors. Domain/model figure
keys and AIL-specific explanations remain. The rule-reading brief, root brief,
documentation plan and later reference/review-guide briefs carry the convention.

D15 — Inserted model-first-documentation-k68 immediately before reference-k9.
It owns revising the detailed learning route and structure briefs, mapping each
introduced construct to a model concept and reader task, and cutting only the
bounded document increments needed before later drafting. The model-first work
is authorized by D12–D13; it preserves prior correction history and the full-set
human checkpoint. No language question, semantic change or new ADR is required
by these editorial directions.

D16 — Updated the D8 comments on Grove issues #14, #17 and #12 with the new
direction and its bounded local disposition. Added the distinct structure-brief
lesson to [#15](https://github.com/Linkuistics/grove/issues/15#issuecomment-5883240495).
Read all four bodies back through the API and compared them byte for byte with
their prepared bodies; each matched. The structural revision is explicitly
future work, and the earlier positive assessment is not presented as its result.

D17 — Final verification on the changed presentation: `task docs:check`
passed links and examples for nineteen files, with seventeen Markdown pages
reachable, and regenerated all twenty-four SVGs identically. External URLs
were not fetched. A separate preservation check compared the three canonical
pages and grammar against baselines verified byte for byte against the parent
commit: rule text, all anchors and all forty-five fenced examples are unchanged.
Each of the eleven railroad sources differs only in its shared caption include;
the generated SVG text contains the status caption without the instructional
legend. The old SVG and a deliberately changed rule exercised the controls.

Actual page HTML rendered with markdown-it-py 4.2.0 contains all thirty-seven
aid borders and forty-two labels, with code, tables and figures inside and rule
headings outside. A synthetic GitHub Markdown render independently confirmed
the wrapper convention; the regenerated name and callable SVGs were visually
inspected. These checks establish preservation and presentation, not reader
comprehension.

Before/after subject paths and SHA-256 hashes matched item for item across
ninety-nine repository files (the interface-language tree, documentation tools
excluding caches, root Taskfile, documentation plan and audit) and seventeen
temporary verification inputs (sixteen parent baselines and the preservation
checker). Manifest SHA-256:
`f64434bcc9bedc6fbb826d16d2aa4e461bcfaf98f6cb5b25665509a5a2e806b4`.
Verified the remaining order: this checkpoint, model-first planning, reference,
review guide, reviewer journey and full-set human reading.

D18 — Retire the checkpoint with D7's positive assessment and D10–D13's new
directions, each with the disposition above. The human identified the railroad
instruction boxes, aid boundaries and organizing priority; they did not name
the pages or headings they read. Exact reading extent, connected-path coverage
and the earlier ownership-exercise navigation question remain unreported.
Do not infer full-path approval or a post-change reading result. The full-set
human checkpoint remains live, and model-first-documentation-k68 is the next
work item. The root still has live work, so there is no parent-node close.
