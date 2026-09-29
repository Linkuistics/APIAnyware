# first-path-reading-k8

## Goal

Run reader checkpoint 1 over the first path: the landing page,
*What a signature leaves unsaid*, the glossary, the three concept pages and
the tutorial. Establish, in the human's own words, what must change before the
reference and review guide are drafted.

## Context

- Documentation plan §8 (reader checkpoints) and §1 (outcomes):
  `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`.
- Task-file decision D2 of `reviewer-documentation-k3`, from its commit: the
  human is the only human reader and knows the domain. No cold readers are
  available.

## Work

1. **The proxy reader.** Launch one fresh-context model briefed as a language
   designer new to API binding. Give it only the pages under test and outcomes
   1–3 from the plan's §1, and ask it to attempt them while thinking aloud.
   Keep the transcript's findings in this leaf's decision log, labelled as a
   proxy. It is not evidence of human comprehension. This spends the session's
   one in-session reviewer allowance.
2. **The human's read.** Ask the human to read the same path as a reviewer.
   Give them the proxy's findings as prompts, not conclusions. Ask them to mark
   what helps, what hinders, and whether the path supports the review they
   want to make.
3. **Triage** every finding into one of:
   - a defect in a landed document: cut a correction run under that
     document's node, as the grove editorial procedure requires;
   - a change to a later document: edit its structure brief in the plan's §9;
   - a language question: add it to the register in `explanation/choices.md`;
   - no action, with the reason.

## Done when

- The human's own assessment of the first path is recorded in their words.
- Every proxy and human finding has one of the four dispositions above.
- The reference and review-guide structure briefs reflect anything the
  reading changed.

## Notes

HITL: this session needs the human present. If they are not, stop and say so.
Do not substitute the proxy for them.

## Decisions (running log)

D1 — The checkpoint retains the settled audience, proposed-language scope and
outcomes 1–3 from the documentation plan. One fresh-context proxy reads only the
twelve pages on the first path; its observations are prompts for the human's
assessment, not evidence of human comprehension. This consumes the leaf's one
in-session reviewer allowance. No production code or new runtime test seam is
in scope. The existing `task docs:check` remains the documentation check.

D2 — Proxy observation transcript. The proxy read the twelve permitted pages
in order, including embedded code, without reading linked authorities or example
files, editing files or running validation. The following is proxy evidence only;
it does not establish human comprehension. Paths below are relative to
`semantic/specification/interface-language/`.

- **P1 — Purpose and audience.** The proxy could explain that AIL records an
  existing API's obligations once for binding generators, documentation
  renderers and LLM tools; humans, analysers and third-party tools meet the same
  publication standard. It could explain why identical signatures leave
  release, validity, output states and callback schedules unresolved. The
  contrasting contracts in `explanation/unsaid.md`, *What the header does not
  say* and *Why the signature cannot be the contract*, made the need clear;
  `README.md`, *The problem in brief*, supplied the producer/consumer boundary.
- **P2 — Reading the worked contract.** The proxy identified one destruction
  obligation after successful card creation; label invalidation at refresh
  entry or the end of the card's lifetime; eight allocated output bytes;
  readable text and terminator only on copy status `0`; and notification starts
  after registration return, with quiescence at watch destruction's return.
  Evidence: tutorial parts 1–3, *Expected observations*, and part 4, *Steps*
  3–5. Input and output validity needed attention, but part 2's *Check yourself*
  answer 2 resolved the distinction. This was taught difficulty, not an
  unresolved defect.
- **P3 — Guided change, on paper.** The proxy would use `tutorial::owned` and a
  revised surface; replace the returned borrow with `give($result, owned)`;
  remove its invalidator; rename `lent` to `supplied`; and select
  `fixture_current_label_owned`, leaving the card's call-scoped input borrow.
  It predicted an independent label usable after card refresh or destruction,
  with one `destroy_label` obligation. It also recognized that changing a
  clause cannot make the original borrowing implementation satisfy the new
  contract. Evidence: part 5, *Guided change: an owned snapshot* and *Expected
  observations*. No parser, validator or runtime result was claimed.
- **P4 — Unguided prediction.** Changing `CopyStatus` to an open enum while
  retaining only the `0` and `1` outcomes would leave other `i32` values
  uncovered. Evidence: part 3, *Steps* 2, and `explanation/contracts.md`,
  *Every way a call can end*. This is a predicted rule violation, not observed
  validator output.
- **P5 — Constraints versus choices.** The proxy distinguished usable storage
  and live callback state as domain constraints; borrowing labels and blocking
  teardown as this synthetic API's choices; and complete publication, explicit
  clauses, exact environments and typed profiles as AIL's choices. It could
  identify partial models, defaults, ownership in signatures and version
  ranges as alternatives with costs. Evidence: `explanation/choices.md`, *How
  to read this page*, *Complete contracts only*, *Exact environments* and
  *What draft 0.1 cannot express*; part 5, *Guided change* 1, assigns snapshot
  implementation burden to the API choice. These distinctions supported
  criticism rather than requiring acceptance of the design.
- **P6 — Unanswered language rationale.** The proxy could see individually
  addressable ownership clauses but could not judge why their distance from
  the signature won over ownership in types. The unchanged `current_label`
  signature made the cost concrete. `explanation/choices.md`, *Ownership in
  clauses, not types*, explicitly says no rationale is recorded; Q3 asks for
  corpus evidence. Its *Everything explicit* section counts 23 clauses in one
  operation. The proxy suggested comparing both notations against the same
  demanding contracts. This is a visible language question, not a concealed
  explanatory answer.
- **P7 — Linear-route presentation friction.** Repeated publication
  introductions and growing complete packages made each chapter's new material
  harder to locate. Tutorial parts 1–5 repeat *The context map locates this
  part…* and each *Checkpoint package*; part 5 puts another assembled package
  before its ownership exercise. An early link to *Guided change* would reduce
  navigation cost. The proxy valued independent complete examples and did not
  recommend removing them. `tutorial/README.md`, *How to check your work*,
  deliberately keeps repeated clauses visible, and the landing page permits
  non-linear routes: the reported friction concerns this assigned linear path.
- **P8 — Provider-verification boundary.** The proxy could explain `abi`,
  `via`, `mapping` and `compatibility`, but could not independently verify the
  provider's faithful lowering from these pages alone. Part 5, *Steps* 2,
  explicitly routes that check to F1. `explanation/packages.md`, *The synthetic
  fixture*, disclaims real interoperability, and the tutorial's *How to check
  your work* disclaims parser/validator execution. The proxy treated this as a
  disclosed scope boundary, not evidence of a false claim.

D3 — P1–P5 require no correction: they supply positive proxy observations for
outcomes 1–3, with their limits retained. P6 belongs to the existing language
question Q3 in `explanation/choices.md`; retain that question without duplicating
it or inventing the missing rationale. P8 requires no correction: the intended
reading outcomes concern interpretation and critique, and the pages disclose
the separate F1 verification step. The reference already owes links to exact
rules. P7's final disposition and any change to later structure briefs await
the human's assessment; no proxy finding substitutes for that assessment.

D4 — Human assessment, verbatim:

> I don't understand the phrase "every producer crosses the same publication boundary". And many other phrases are not understandable. The language is too compressed, and needs to be cast in terms the reader can understand.
>
> The use of negative framing such as "What a signature leaves unsaid" is a hallmark of LLM prose, and generally disliked by humans. Please use positive framing rather than saying what something isn't, and what it doesn't say, or doesn't do etc.
>
> I would like to fix this before giving more feedback.
>
> Also keep in mind that we want to update the GH issues we raised in the grove project with anything new you learn from this process.

D5 — The human identifies two document defects: H1, compressed abstraction
that assumes the domain knowledge the pages should teach; and H2, negative
framing used to introduce and explain concepts. Correct the whole first path,
starting with the landing page's publication explanation. Teach who writes a
description, what it contains, what gets checked, and how other tools use it;
introduce the short technical term after that explanation. State each subject
positively, with the relevant actors, actions and consequences. Preserve the
language's exact obligations, draft status and example contracts. This requires
a draft-led correction run under each of orientation, concepts and tutorial,
followed by copy-edit, art and proof; it exceeds sentence polishing. P7 joins
the tutorial correction: make new material and the ownership exercise easy to
reach while retaining the complete examples. P1–P5 remain observations about
the proxy alone; the human's difficulty establishes that its success did not
demonstrate accessibility for this reader.

D6 — H3 is the requested order: finish those corrections, then offer a fresh
human read before reference or review-guide drafting. Insert a requirements
checkpoint there. H4 is the request to update the existing Grove issues; add
the evidence and stage-specific lessons to the relevant issues in
`Linkuistics/grove`. The documentation plan's prose contract and all remaining
structure briefs carry H1–H2 forward. These are settled instructions, so a
full grilling would add no decision. This checkpoint records an interrupted
human read with actionable findings, not approval of the first path.

D7 — The dispositions are now concrete. H1–H2 are assigned to the first
correction runs `orientation-k36` → `orientation-k39`, `concepts-k40` →
`concepts-k43` and `tutorial-k44` → `tutorial-k47`, each ordered draft,
copy-edit, art, proof under its existing document node. P7 is assigned to
`tutorial-k44` and its later stages. H3 is assigned to `first-path-reading-k48`,
inserted before the reference node. The root brief, document briefs and plan
§4–§6, §8 and §9 carry the changed requirements; reference (§9.4) and review
guide (§9.5) explicitly inherit them. The scope is settled and the correction
tasks are reviewable; no change to AIL semantics or new language question is
required by these findings.

D8 — H4 is fulfilled by verified comments on the existing Grove issues:

- [#14: the observed case and its limits](https://github.com/Linkuistics/grove/issues/14#issuecomment-5794534445).
- [#15: teaching actions before abstractions](https://github.com/Linkuistics/grove/issues/15#issuecomment-5794534758).
- [#16: concrete prose and positive framing](https://github.com/Linkuistics/grove/issues/16#issuecomment-5794535032).
- [#17: figure wording and context-map repetition](https://github.com/Linkuistics/grove/issues/17#issuecomment-5794535422).
- [#18: proxy success alongside an interrupted human read](https://github.com/Linkuistics/grove/issues/18#issuecomment-5794535784).
- [#12: further evaluation evidence, with skill activation unestablished](https://github.com/Linkuistics/grove/issues/12#issuecomment-5794536070).

Each posted body was read back and matched its prepared text. The comments
distinguish this reader's experience, the proxy's observations and the proposed
remedies. They leave the correction's effect for the follow-up read to establish.

D9 — Verification before retirement: `task docs:check` passed. Links checked
19 files with 17 pages reachable, example checks passed for 19 files, and all
11 diagram SVGs regenerated identically. Before/after SHA-256 manifests matched
for the 58 files under `semantic/specification/interface-language/` and
`semantic/specification/tools/` (excluding Python bytecode caches), plus the
root Taskfile, documentation plan and audit included in that total. The new
task bodies were read back; Grove's brief-chain reads confirm the orientation
correction inherits its node brief and the follow-up checkpoint inherits the
root brief. The on-disk order places all three correction runs and that
checkpoint before reference drafting. No runtime behaviour or improved human
comprehension is claimed by these checks. This requirements leaf's assessment
and triage are complete; the document corrections remain the named live work.
