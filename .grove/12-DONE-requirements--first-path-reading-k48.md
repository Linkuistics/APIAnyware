# first-path-reading-k48

## Goal

Resume the human's first-path reading after the requested comprehension and
positive-framing corrections, before reference and review-guide drafting.

## Context

- Human feedback and the labelled original proxy observations:
  `first-path-reading-k8`, decisions D2–D6, in that leaf's committed record.
- Documentation plan `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`,
  §8 (checkpoints), §4–§6 (revised contract) and §9 (structure briefs).
- Corrected orientation, concepts and tutorial, including their proof leaves
  `orientation-k39`, `concepts-k43` and `tutorial-k47`.

## Work

Start with the corrected overview and *Using an API across languages* at
`semantic/specification/interface-language/README.md` and
`explanation/unsaid.md`. Give the human a concrete, reviewable reading route
and ask whether the explanations now make the actors, actions and consequences
understandable. Use their response to continue through the glossary, concept
pages and tutorial. Record what they read and their assessment in their words.
The original model proxy is historical evidence; a new proxy is optional and
cannot substitute for this human read.

Triage each finding into a document correction, a change to a later structure
brief, a language question in `explanation/choices.md`, or no action with a
reason. Reconcile the reference and review-guide briefs accordingly. If another
correction would repeat a stage's first correction run, follow the editorial
escalation rule instead of silently scheduling an unbounded cycle.

Update the existing `Linkuistics/grove` issues with any new evidence from this
read: #14 overview, #15 draft, #16 copy-edit, #17 art, #18 proof/reader testing,
and #12 writing for understanding, as relevant. Separate observations from
proposed remedies and state the limits of one reader's evidence.

## Done when

- The human's assessment and the extent of their read are recorded verbatim.
- They have judged whether the requested corrections support continuing the
  review, and every new finding has a disposition.
- The later structure briefs reflect the assessment.
- Relevant new process lessons have been added to the existing Grove issues.

## Notes

The human asked to fix compressed, abstract phrasing and negative framing
before giving more feedback. This checkpoint is ordered after those corrections
and before the reference node. If the human is unavailable, leave the checkpoint
live and say that their assessment is still needed.

## Decisions (running log)

D1 — Retain the settled audience, proposed-language scope and revised prose
contract. Begin the human read with the corrected overview and *Using an API
across languages*, then use the response to decide how to continue through the
glossary, concepts and tutorial. No new proxy is commissioned: the outstanding
evidence is the human's assessment of the corrections, and the earlier proxy
observations retain their stated limits. There are no three open interdependent
design questions requiring a full grilling, and no production-code change or
new runtime test seam is in scope.

D2 — Human assessment, verbatim (2026-09-28):

> This clause: "A package has a qualified name and an opaque, nonempty version string. Its canonical identity is (package name, package version, declaration name). Members are top-level declarations with a member clause; they are not nested inside a nominal type. All local declaration names are unique, including overloads. External/source names do not determine identity." could do with examples - what is the distinction between a local declaration and a non-local declatation. An example of a Member would be useful. In general, snippets showing things as they are being introduced are useful for building understanding.
>
> The very next paragraph: "An import pins a package name, version and digest and introduces an alias. @Alias::name addresses an imported declaration; @name addresses a local one. @operation::parameter and @operation::result address slots; receiver is an ordinary explicitly named parameter. A callback's slots use the same convention. Import aliases and local declarations MUST NOT collide. Bare type names resolve identically without @. No implicit package lookup or overload resolution occurs. The names result, exception and completion cannot be parameter names. Parameter names MUST be unique within a callable; outcome names MUST also be unique within that callable. All core type and type-constructor names in L4 are reserved against declaration/import/environment/provider aliases. They cannot be shadowed; u8 always denotes the core unsigned eight-bit type." Introduces syntactic items that make no sense because I don't know the context. We should start with more language model diagrams/railroad diagrams/examples as we talk about such things.
>
> These two points should be generally applied and then let's review again.

D3 — The quoted passages are the first two paragraphs of `language.md` L2,
under the identity-and-dependencies heading. They establish the reported reading
locations; the response does not state the full route taken or the extent of
any other reading. Do not infer approval of the corrected overview, concepts
or tutorial, or that the whole first path was read. The human requests another
general application of the feedback before the next review. The settled
requirements are examples at the introduction of constructs, and diagrams or
railroad diagrams that establish the language model and syntactic context.
The local/imported declaration distinction and a concrete member declaration
are explicit acceptance cases. This is documentation feedback, not a request
to change AIL identity, syntax or semantics; no new language question is raised.

D4 — H5 is the missing concrete introduction to local/imported declarations
and members. H6 is notation introduced before the reader has a language model
or syntactic context. Address both beside the canonical introductions as well
as across the orientation, concepts and tutorial; carry them into every later
structure brief. Add labelled non-normative explanations, checked snippets and
figures around the existing rule text, preserving its wording, rule identifiers
and grammar. A new rule-reading document increment owns those additions to
the three canonical Markdown files. Its first draft handles language rules;
its second handles contracts and profiles. The later reference reuses this
material without delaying the repair to the passages the human actually read.

D5 — H7 is the instruction to apply the feedback generally and then review
again. Orientation, concepts and tutorial have already completed one correction
run each. Another run reaches the editorial escalation boundary. The human's
2026-09-28 instruction supplies explicit direction for one further bounded
draft → copy-edit → art → proof run per document, recorded here and in their
briefs. No further automatic re-run is authorized. Any unresolved defect after
this run is recorded for the new human checkpoint, which precedes reference
and review-guide drafting. The new rule-reading increment precedes these
corrections so they can reuse its examples and language-model figures. This
checkpoint's requested requirements are settled; no full grilling is needed.

D6 — The concrete dispositions are rule-reading-k49 (drafts k50 and k51,
then its lazy editorial tail) for the canonical introductions; orientation-k52
through k55, concepts-k56 through k59 and tutorial-k60 through k63 for the
bounded general correction; and first-path-reading-k64 for the next human
assessment. All precede reference-k9 and review-guide-k10. The root brief,
documentation plan §4–§6, §8 and all §9 structure briefs, and the affected node
briefs now carry H5–H7. Normative page-one blocks move from the reference's
first draft into rule-reading; later reference work preserves the new aids.
No ADR changes: this settles teaching and review requirements, not language
architecture. The requirements checkpoint has an actionable disposition for
each finding; the reader-facing corrections remain the named future work.

D7 — Posted the new reader evidence and its stage-specific implications to the
existing Grove issues, then read each comment back and matched its body with the
prepared text:

- [#14: direct rule-entry teaching context](https://github.com/Linkuistics/grove/issues/14#issuecomment-5864305374).
- [#15: examples at construct introductions](https://github.com/Linkuistics/grove/issues/15#issuecomment-5864305698).
- [#16: contextual meaning beside snippets](https://github.com/Linkuistics/grove/issues/16#issuecomment-5864305985).
- [#17: language-model and railroad purposes](https://github.com/Linkuistics/grove/issues/17#issuecomment-5864306291).
- [#18: reported reading extent and direct-entry checks](https://github.com/Linkuistics/grove/issues/18#issuecomment-5864306604).
- [#12: notation-in-context evaluation case](https://github.com/Linkuistics/grove/issues/12#issuecomment-5864306941).

The comments distinguish the reported L2 difficulty from the previously
corrected page set, whose assessment the response does not supply. The
examples/diagram treatment is the requested remedy, with its effectiveness
still unassessed. No aggregate stage result or skill-specific cause is claimed.

D8 — Verification before retirement: `task docs:check` passed. Links and
example checks covered 19 files, 17 Markdown pages were reachable, and all
11 named SVGs regenerated identically. The before/after subject lists and
SHA-256 manifests matched item for item for 58 files: the interface-language
tree, documentation-checker directory (excluding ignored caches), root
Taskfile, documentation plan and audit. Manifest SHA-256:
`c3797ce94deceffebb850b9fcdd8b6b83acaf7952b53a6e972ce1f4842218da5`.
The canonical documents, example sources, checker code and Taskfile have no
diff in this requirements change. These checks establish consistency of the
current documentation and revised plan; the new teaching material is still
the queued editorial work.

Read back the new task bodies and revised briefs. Grove's explicit brief-chain
reads validated the new rule-reading and three correction nodes, and the next
human checkpoint inherits the root brief. The sorted tree and resolved handles
place rule-reading, all corrections and first-path-reading-k64 before reference
and review-guide drafting. Coverage was checked at graph generation
2026-09-23T09:55:55Z; changed/untracked Markdown and the excluded design directory
were read directly. No code-structure completeness claim is made.

D9 — Retire this requirements checkpoint: the human's words and known reading
locations are recorded, H5–H7 have concrete dispositions, later briefs carry
the requirements, and relevant issue comments are posted and verified. The
human asked for corrections before the next review; this is not approval of
the first path or a claim that those corrections have landed. The root retains
live work, so no parent node closes with this leaf.
