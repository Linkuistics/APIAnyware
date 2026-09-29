# APIAnyware.improve-api-interface-language-docs — brief

## Goal

Make the model of API behavior and binding obligations understandable and
assessable by reviewers who know language design, language aesthetics and
developer audience expectations, but do not know the API binding domain.
Introduce the proposed API Interface Language as a tool for expressing that
model. Deliver a tutorial, guide, explanations and precise reference so those
reviewers can judge how well the tool serves that purpose.

The human's diagnosis is that the current documentation has too little context
and explanation and is too dense for that review. Improving sentences alone
will not satisfy this workstream.

## Done when

- The reader understands the model's entities and relationships and can explain
  which part of that model each introduced AIL construct expresses.
- A newcomer to the domain can explain the problem AIL addresses, who would
  produce and consume it, and why declarations alone do not describe an API's
  binding-relevant contract.
- A reviewer can follow a small worked example, read and make a modest change
  to its AIL description, and understand the consequences without assuming an
  existing AIL parser, native implementation or APIAnyware integration.
- Context and explanations make the major choices, alternatives, limitations
  and trade-offs inspectable. Reviewers can distinguish domain constraints
  from choices this language makes and can critique both.
- A review guide supports concrete evaluation of syntax/readability, conceptual
  consistency, expressive scope, authoring burden, discoverability and fitness
  for AIL's intended producers and consumers. Questions refer to examples and
  rules and invite criticism rather than presuppose that the design is right.
- A complete, navigable reference lets readers verify exact syntax, clause
  arguments and types, applicability, requiredness, defaults, constraints and
  rejection conditions. Explanatory pages link to one canonical rule source.
- The initial audit precedes rewriting. The audit and the rewritten documents
  are explicitly identifiable as the two deliverables the user's prompt asks
  for. Reader-facing pages contain the actual documentation, without editorial
  process boilerplate on every page.
- The research-informed quality criteria have been checked through drafting,
  copy-editing, figures and whole-document proof. Local navigation and examples
  are checked, with evidence and limits stated honestly.

## Decomposition

This is explicitly a multi-step Grove involving web research. Research comes
before detailed planning, and planning cuts focused document increments. The
editorial pipeline for each bounded document/set is `draft` -> `copy-edit` ->
`art` -> `proof`, grown lazily under Grove's editorial procedure. The current
requirements leaf does not perform those stages.

1. Research the referenced books and primary documentation guidance; derive
   criteria for this particular audience and review purpose.
2. Audit the current material, establish the detailed information architecture
   and named structure briefs, and cut the editorial work into bounded leaves.
3. Produce and verify the documentation through the editorial stages. Integrate
   navigation across the set and check the complete reviewer journey.

Planning (`reviewer-documentation-k3`) cut the entries after it in dependency
order. First, `review-planning` reads the plan before anything executes. Then
come `docs-foundation` (rule anchors and repeatable checks); the document nodes
`orientation`, `concepts` and `tutorial`; the first human reading checkpoint;
the `reference` and `review-guide` nodes; `reviewer-journey` (cross-set
navigation and the Step 2 index); and the full-set reading checkpoint. Each
document node runs the editorial pipeline lazily, and its structure brief is
a named section of the documentation plan.

One literature survey is sufficient initially. No paired survey or implementation
work is justified by the settled requirements.

The 2026-09-28 follow-up read (`first-path-reading-k48`) requests examples and
language-model/railroad diagrams as constructs are introduced, applied generally
before another review. `rule-reading-k49` now precedes orientation and adds
labelled teaching material beside the existing canonical rules (plan §9.7).
The second corrections for orientation (k52–k55), concepts (k56–k59) and
tutorial (k60–k63) have been proofed. `first-path-reading-k64` follows those
corrections and precedes reference and review-guide drafting. Each existing
document gets one further ordered draft/copy-edit/art/proof run; the escalation
and its bound are recorded in its brief. Further automatic re-runs are not
authorized. This is the direction supplied by the human at the escalation
boundary, not a reset of the documents' correction history.

At `first-path-reading-k64`, the human positively assessed the improvement and
clarified the teaching priority: explain the model, then describe AIL by
reference to it, because the language serves as a tool. The 2026-09-29 direction
also removes railroad-reading boxes and asks for visual boundaries around
non-normative aids. This checkpoint applies those bounded presentation changes.

`model-first-documentation-k68` revised the documentation plan for a
three-stage learning route — why a description is needed, what it records,
how AIL writes it down — with exact lookup kept separate (plan §3). The
canonical model account is a new page, `explanation/model.md`, with figure G11
(plan §9.8). Plan §10 fixes its eleven concepts, their anchors, order and
concept-to-notation map; every later document names and links those
concepts. The cut, in walk order: one bounded orientation run that lands the
model page and its routes (orientation-k69–k72); `model-reading`, one human
read of the model account before anything is organized around it; one bounded
concepts run, including the grammar/railroad home (concepts-k85, first) and
the canonical aids' model-concept routes (concepts-k74–k79); one bounded
tutorial run (tutorial-k80–k84); then the
reference, review guide, reviewer journey and full-set checkpoint, whose
briefs now consume the model. Each run is authorized once by the human's
direction and grows no automatic correction run. The existing correction
history remains visible; this new direction supplies the scope, not an
automatic repetition policy.

## Reader and structure brief

The primary reader knows language design and is familiar with railroad diagrams,
but is new to API binding concepts. Explain the examples' AIL-specific meaning
and relationships; let the examples show familiar syntax. Omit prose lessons
on parentheses, commas, semicolons, braces and other self-evident notation
(human refinement, model-reading-k73). Keep railroad diagrams with the grammar
description in `reference/notation.md`, and link to its relevant section from
other pages. Railroad figures use an unboxed
status caption and omit instructional keys. Omit generic instruction on
following railroad tracks, branches, optional paths and repetition (human
clarification, first-path-reading-k64).
Do not spend pages teaching general programming or assume knowledge of FFI,
ABI, ownership transfer, borrow validity, quiescence, projections or profiles.
Define each domain concept before it becomes necessary and illustrate the
failure it prevents. API authors and tool implementers are secondary readers;
the reference still needs to serve them.

Explain the conceptual model first and describe the language by reference to
that model (human direction, 2026-09-29). Organize the learning path around
describing API behavior and binding obligations: what the entities are, how
they relate, and what a caller or tool needs to know. Then introduce AIL syntax
where it helps express or inspect that account. Judge language choices by
their usefulness for the model and the reader's task. Exact syntax remains a
reference concern. A diagram of package/declaration containment supports this
account where needed; the organizing purpose is the API model and its use.

At each substantive introduction of language structure or notation, show a
small explained snippet with its enclosing context. Establish the package,
declaration, import, member and slot relationships before using syntax that
assumes them. The human explicitly needs local versus imported declarations,
a member example, and context for `@` references. Use a language-model diagram
for those relationships alongside the concrete examples. For exact syntax,
link to the grammar and railroad reference. Apply this to all reader-facing
forms, including
direct entries into the canonical rules and later reference/review pages.
Retain the domain-first explanations and complete checkpoint packages.

The human's first read (checkpoint `first-path-reading-k8`) found the prose too
compressed and phrases such as "every producer crosses the same publication
boundary" incomprehensible. Explain the people, tools, actions and consequences
before introducing an abstraction. Give each relationship enough connected
prose and a concrete example to make it understandable. Use positive framing:
say what the subject is, how it works and which conditions apply. The domain
page's correction uses the title *Using an API across languages*; retain its existing
`explanation/unsaid.md` path. These requirements govern headings, paragraphs,
tables, captions, alt text and diagram labels across the first path and every
later document. The plan's revised §4–§6 and §9 carry the detailed contract.

The human has specified tutorial, guide and reference, with the latest
clarification making context and explanation essential. The initial conceptual
order is:

1. **Orientation:** reader, review purpose, language status, domain problem,
   intended AIL producers/consumers, and a map to the documentation paths.
2. **Domain and language explanation:** a small API and what its signature
   leaves unstated; the concepts AIL uses to express those obligations; design
   choices, alternatives and limits. Move from concrete need to abstraction.
3. **Tutorial:** a guided, progressive exercise describing one small synthetic
   API, with meaningful intermediate checkpoints and a complete final example.
   Label partial teaching fragments explicitly. Link deeper rationale out of
   the procedural flow instead of removing it from the documentation set.
4. **Review/task guide:** self-contained tasks for tracing and changing
   contracts and judging the design, with expected observations and grounded
   feedback prompts. Prefer the reviewer's real tasks over generic setup or
   fictional API invocation instructions.
5. **Reference:** consistent entries and indexes for exact lookup; retain the
   formal grammar and complete normative contract as the source of authority.

This order is a learning route, not a compulsory linear reading sequence.
Every standalone page needs enough local context, prerequisites and links to
work as a direct entry point. Planning refines the page boundaries and ordered
section plans from the research; it must preserve the reader and purpose above.
Every drafting leaf must name a structure-brief artifact that explicitly states
reader/outcome, ordered sections with their purpose, and emphasis/non-goals.

Emphasise conceptual clarity, language ergonomics, realistic examples, precise
semantics and honest trade-offs. Brevity is useful only when it does not remove
the context needed for review. Evaluate the language; do not market it or hide
awkwardness with unexplained examples.

## Editorial contract

Human clarification (2026-09-23, orientation art correction): limit semantic
density everywhere except reference documentation. Give non-reference prose
enough space to explain one relationship before adding the next. Published
documents stand on their own, independent of Grove, the process that produced
them, ADRs and planning/research artifacts. Teach needed context within the
documentation set; keep process records outside reader-facing pages. This
clarification governs the queued proof and all later corrections and documents.

Use the supplied prompt's Diátaxis separation of tutorial, how-to/task guide,
reference and explanation. The latest audience clarification governs how those
forms serve this workstream. The prompt's example of getting an API call working
does not justify inventing a runtime for a language that is still proposed.

Audit content purpose, reader assumptions, missing explanations, organization,
accuracy, completeness, density, concrete examples, navigation, visual clarity
and sentence-level style before rewriting. Verify the prompt's attributions
against original guidance rather than treating its summaries as quotations from
the books. Explain material tensions between sources and the chosen application.

Use conditions before actions; clear actors and active voice; explicit noun
references; imperative procedural steps; meaningful identifiers; code typography
and tagged fences. Reference entries need syntax, operands/types, scope,
obligations, constraints and errors as applicable to a declaration language.
Do not dilute a normative distinction to satisfy a mechanical style metric.

Work in repository Markdown, with tables and accessible diagrams when a
relationship needs them. Provide adjacent explanatory text and do not require a
new publishing site or graphical tool to read the core content. No deployment
or website redesign is requested.

Non-normative reading aids on canonical pages have a visible left border, a
bold non-normative label and stable explicit anchors. Use a blockquote wrapper
with blank lines so embedded Markdown, tables and examples continue to render.
The border delimits the whole aid; there is no visible end-heading or end marker.
Keep the paired source comments used for canonical-text preservation checks.

Diagrams (human decision, 2026-09-23): PlantUML, D2 and Mermaid are equal
notations, alongside fenced text. Each diagram commits its source and a
tool-generated SVG. Order diagrams by C4-style abstraction level, from context
down to detail, and let the relation being shown choose the notation.

Format (human decision, 2026-09-23, settled at planning): GitHub-flavoured
Markdown. AsciiDoc, DocBook and Typst are not used. Code on pages is kept in
step with committed `.ail` files by a repeatable check. The diagram and format
conventions are recorded in the documentation plan (see Pointers), not in an
ADR, because neither passes the ADR test.

## Technical scope and verification

The model and AIL are intended to describe APIs across source languages and
platforms, including .NET, Linux/Wayland/GTK/KDE, Rust and other libraries with
typed contracts. Swift has no privileged position. Distinguish the API being
described from the languages that consume it: interpreted and dynamically
typed languages remain intended consumers. The human's source-side emphasis
is on typed contracts, with a tentative preference against describing untyped
or interpreted libraries; do not turn that preference into a normative ban.
The ecosystem list describes intended reach, not supplied production providers
or a shared C ABI. The full-set correction makes this scope explicit in the
orientation, model and rationale while preserving the draft's actual limits.

This work explains and improves presentation of draft 0.1. Preserve its proposed
status, normative force, stable rule identities and supported/unsupported
boundary. Reorganizing and clarifying prose is in scope; silently changing
syntax, semantics, fixtures' contracts, ABI/profile support or production
readiness is not. Surface actual language ambiguities as review feedback rather
than resolving them by inventing rules. If such a gap prevents a truthful
example, use a supported example or seek a substantive language decision.

The 2026-09-28 correction adds separately labelled non-normative reading aids
around canonical rule text. Preserve the original normative wording, rule
anchors and grammar; verify their preservation separately from added examples.
The human requested teaching support at the quoted L2 paragraphs themselves.
Moving that support solely into the future reference would leave the reported
entry point unrepaired. The plan's §4–§6 and §9.7 specify the boundary.

Treat the language files and grammar as technical authorities for AIL. Earlier
design sketches are rationale, not executable syntax. Synthetic fixture
catalogues and digest tokens must remain explicitly synthetic; examples do not
establish facts about real operating-system APIs.

Verification covers rule-to-explanation/example traceability, the completeness
of final examples and context retained by extracts, links/anchors, code fences,
tables and a walkthrough of the reviewer journey. Check reference coverage
against an enumerated grammar/clause/rule inventory rather than a remembered
list. Separate syntax checks, semantic inspection and unexecuted runtime claims.
The old disposable checker described in `conformance.md` is historical evidence,
not a shipped validator or a guaranteed available test command.

There is no requested production-code change, so no new runtime test seam is
needed. The checked-out Makefile's validation entry covers existing `.apiw`
artifacts, not this proposed AIL documentation. No Taskfile was found during
requirements bootstrap; the planning recommendation is to add a root
`Taskfile.yml` only if this work establishes a useful repeatable documentation
check, wrapping its existing mechanics. Do not expand the task into a parser,
semantic validator or general build-system migration.

## Pointers

- Existing language: `semantic/specification/interface-language/README.md`,
  `language.md`, `contracts.md`, `profiles.md`, `grammar.ebnf`, `baseline.md`,
  `conformance.md` and `examples/` in that directory.
- Approved architecture and rationale:
  `semantic/docs/design/2026-09-22-interface-language.md`.
- Completed earlier specification-writing plan:
  `semantic/docs/design/2026-09-22-interface-language-plan.md`. It is historical
  context, not a fresh mandate to redo its tasks or launch its worker workflow.
- Documentation placement: `adr/0024-per-language-docs-co-locate-adrs-stay-central.md`
  and CONTEXT.md's documentation-structure terms. Keep subject material in
  `semantic/`; do not create a new top-level `docs/` tree.
- Step 1 audit: `semantic/docs/research/interface-language-documentation-audit.md`
  (findings F1–F12; review questions Q1–Q6).
- Documentation plan, including the page architecture, prose contract,
  figure inventory, checks, reader checkpoints, the structure brief for
  every document (§9) and the model concepts and their notation (§10):
  `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`.
- Research basis and stage criteria (§9 there):
  `semantic/docs/research/documentation-basis-a.md`.
- Human-supplied reading list:
  [Richard Rabil's technical-writing books](https://richardrabil.com/2024/08/18/the-best-books-on-technical-writing-an-in-depth-analysis/).

## On the horizon

- A published edition (HTML or PDF) is not scheduled. If the human wants one,
  the survey's §8 favours AsciiDoc output generated from the Markdown set.
- The human would like a more conversational, guided presentation later.
  They accept the present documentation apart from the source/platform
  framing correction below; a general prose rewrite is outside this run.
- Later language design should explore clause-specific syntax that suggests
  meaning through its forms and structure. Q7 in `explanation/choices.md`
  preserves this direction. It is not a grammar change in this documentation
  workstream.

## Notes

At `full-set-reading-k12`, the human said, "Apart from that point, I am very
impressed with your work" and "for now this is good." The exception is the
Swift-centred rationale and the need to state the broader intended source and
consumer scope above. They cited the phrase about extending Swift syntax;
the full reading extent was not reported. This is a positive verdict with a
specific correction, not evidence that a cold reader achieved every outcome.

One bounded correction under concepts-k6 is authorized by that direction:
concepts-k95 draft → concepts-k96 copy-edit → concepts-k97 art → concepts-k98
proof. Its document is the landing page, model page and choices page, with
affected summary/route text checked across the set. It does not repeat the
whole documentation project. No further automatic correction or human reading
checkpoint is scheduled. Any unresolved residue returns to the human.

The single full-set proxy read all 29 pages and attempted all six outcomes.
Its response and limits are preserved in k12. Its raw-example navigation gap
is retained as an accepted limitation of the existing index/walkthrough
pairing; the human's current correction is source/platform framing and the
rest is accepted for now. Do not infer that the human independently tested
the raw-file route. P2's lookup friction remains Q6; Q1–Q7 remain language
questions, with Q7 explicitly later work. Mechanical checks and proxy results
remain separate from the human's reported verdict.

Cross-set navigation is proofed (`reviewer-journey-k94`, closing
`reviewer-journey-k11`). Every page has a direct inbound link from the landing
map or its parent index, and the guided footers run landing → domain → model →
concepts → tutorial → review guide. Each model section and §10 map row links
its reference entries and a review task, and those destinations link back.
Task links use one gloss per task across the set. Proof moved `lifecycle`'s
reference entry, index row and disposition from *Release responsibility* to
*Entities*, matching §10, the model page and the glossary. The audit's closing
*Step 2: refactored output* indexes the set, maps F1–F12, keeps Q1–Q6 open and
separates those consistency checks from the then-unassessed full-set human reading.
`task docs:check` passed, with 229 coverage candidates and no pending entries.
The checkpoint's subsequent verdict and its limits are recorded above.

The three-page review guide is proofed (`review-guide-k91`, closing
`review-guide-k10`). `review/README.md` is the landing-map and guided-route
destination; it links the six dimensions, feedback template, complete
clause-by-clause walkthroughs and seven tasks. Use `review/tasks.md#trace`,
`#predict`, `#change`, `#compare`, `#stretch`, `#author` and `#model-fit` for
direct task links. Preserve Compare's historical non-0.1 label, Trace's
placeholder import pin, Author's lifetime-only assumptions, and Stretch's
separate cancellation/acknowledgement boundary. Model fit includes L6's
checked release relationship without inventing a second ownership authority.
Whole-document proof found no actionable defect or outstanding handoff.
`task docs:check` passed, including 26 SVGs and complete reference coverage;
canonical rules, grammar, conformance record and frozen packages match
`a1e22077`. These are consistency checks. The reviewer journey and later
human checkpoint still own cross-set assessment and comprehension evidence.

The complete eight-page reference is proofed (`reference-k88`, closing
`reference-k9`). `reference/README.md` provides model-concept, rule,
N01–N33 mutation and alphabetical clause indexes; `declarations.md#applicability`
provides the scope route. `notation.md#integer` now supplies the integer-token
entry, separate from integer types. Canonical reading aids, explanations,
tutorials and the glossary link into the reference. Complete coverage reports
229 classified candidates with no pending entries. Keep the shared spelling
scopes, optional fixture facts without inferred defaults, and N11/N14's
implementation/runtime qualifications. These are document consistency checks;
the later reader checkpoints still assess human understanding.

The model-first tutorial run is proofed (`tutorial-k84`, closing
`tutorial-k7`). The index and five parts connect each construct-introducing
step to named model concepts. Part 1 now teaches the card's lifecycle,
creation outcomes and release transfer before publication and provider pins.
For reference and review-guide links, use `01-lifetime.md#card-lifetime`,
`#3-describe-creations-success-and-failure`,
`#4-transfer-responsibility-when-destruction-begins` and
`#5-name-the-package-and-the-api-it-covers`, under `tutorial/`.
Part 2 also offers `02-lending.md#label-lifecycle`; the part-5 exercise stays
at `05-access-and-change.md#guided-change-an-owned-snapshot`. Old renamed
heading slugs and each part's `the-domain-obligation` anchor remain available.

The tutorial's five semantic figures stay beside their examples, with model
links in their captions. Exact-syntax routes now go to the grammar home.
All six complete checkpoints match pre-run `7891f92a`; the owned variant
continues to describe an independent Label snapshot, its caller's destruction
duty and a changed implementation symbol. The Watch subscription remains
independent of Card. Whole-document proof found no actionable defect or
outstanding handoff. `task docs:check` passed, including all 26 SVGs; canonical
rules and grammar are unchanged. No correction run or full-set checkpoint
residue was added. These findings establish consistency and preservation,
not human comprehension; the full-set checkpoint still owns that assessment.

The model-first concepts run is proofed (`concepts-k79`, closing
`concepts-k6`). The expanded document comprises the three explanations,
`reference/notation.md`, the canonical reading aids and affected glossary
and landing routes. Proof found no actionable defect or outstanding handoff;
`task docs:check` passed, including byte-identical regeneration of 26 SVGs.
Canonical rule text still matches `87221b8c` after removing paired aids;
grammar and frozen fixtures are unchanged. These are consistency checks,
not evidence of human comprehension. Q1–Q6 remain open for the review guide
and full-set checkpoint. No new correction run or checkpoint residue was cut.

For the following tutorial, reference and review-guide work:

- The eleven model concepts and their order in plan §10 are unchanged.
  `explanation/contracts.md` now places outcomes before lifecycle and release
  responsibility, and execution before callbacks. Link lifecycle material at
  `#entities-and-their-lifecycles`, and relationships at `#patterns-and-laws`.
  The old `#lifecycles-and-patterns` anchor still reaches lifecycle material.
  `#extending-the-language-with-profiles` retains its old
  `#what-the-core-leaves-to-profiles` alias. Other existing anchors survive.
- The grammar home is `reference/notation.md`, with stable anchors `shell`,
  `clause`, `names`, `callable`, `places`, `environment`, `pattern`, `outcome`,
  `callback-use`, `dependency` and `access`. All eleven G10 views are embedded
  there; the concepts pages, canonical aids and glossary link to those sections
  while keeping local examples. The tutorial now uses those grammar links
  too. Reference extends this page and preserves these anchors.
- Canonical first-aid routes use this model-anchor mapping: L1 → description,
  agreement; L2 → description; L3 → description, agreement; L4 → operations,
  entities; L5 → operations, entities, description; L6 → entities;
  C1 → operations, validity; C2 → entities, responsibility, execution,
  callbacks; C3 → outcomes, responsibility, validity, storage, execution;
  C4 → storage; C5 → outcomes, responsibility, validity; C6 → callbacks;
  C7 → entities; C8 → agreement; A1 → access, agreement; A2–A4 → access;
  A5 → agreement; F1 → access. Additional local links cover the specific
  constructs in later aids. Keep the border, paired comments and rule text.
- G2–G7 and G9 remain with their examples; their captions route to the model.
  G9 is the language-containment view, and G11 is the API-model overview.
  Preserve the synthetic fixture boundary, placeholder import warning and
  separate declaration, source and access identities. The grammar reference
  defines its EBNF dialect; other prose explains meaning without punctuation
  or railroad-reading lessons.

The model-first orientation run is proofed (`orientation-k72`, closing
`orientation-k5`). Later runs use the canonical account at
`semantic/specification/interface-language/explanation/model.md` and its
stable concept anchors, in order: `operations`, `outcomes`, `entities`,
`responsibility`, `validity`, `storage`, `execution`, `callbacks`,
`description`, `access`, `agreement`. The closing `#from-the-model-to-ail`
map connects them to current notation introductions and tutorial exercises.
The concept set and order in plan §10 are unchanged; drafting added L5 to
the published-description citations because it defines advisory deprecation.

G11's call and description views are
`figures/g11-calls.{puml,svg}` and `figures/g11-description.{puml,svg}`, relative
to the interface-language directory. Both are embedded under the model page's
*The model at a glance*. G1 remains the publication workflow, G4 the separate
ownership cases and G9 the language-containment view. Preserve these distinct
roles and the watch API's alternative possible contracts.

Whole-document proof found no actionable defect or outstanding handoff. The
landing → domain → model route and direct validity/callback entries carry
local context and onward links. `task docs:check` passed, including all 26
SVGs. Earlier orientation examples and anchors are preserved; canonical
rules, grammar and frozen fixtures are unchanged from `793cd745`. This
establishes consistency, not comprehension. At `model-reading-k73` the human
said the material was "looking good" and praised the example fragments, then
requested the audience and grammar-placement refinement above. The quoted
passage was in `explanation/contracts.md`, *From signature to contract*;
the full reading extent was not reported. Keep §10's concepts and order and
continue the queued work under that refinement. This is not a whole-path
comprehension finding.

The concepts run lands `reference/notation.md` before other pages link to it:
concepts-k85 gathers the existing G10 views with their grammar description;
k74–k75 revise the explanations; k76 revises non-normative canonical aids,
the glossary and landing routes. The tutorial run applies the same requirement
to its six pages. The reference run extends the existing notation page.
Preserve local examples, AIL-specific meaning, semantic diagrams, canonical
rule wording and stable anchors. Do not replace local teaching support with
links alone or reword normative text to remove syntax explanations.

For local VS Code reading, open `semantic/specification/interface-language/`
or the workspace root as a folder before opening a Markdown preview. At
`model-reading-k73`, opening the model page alone left `../figures/` outside
the preview's allowed resource directories and both G11 requests returned
401. Opening the containing folder restored both diagrams with Restricted
Mode still enabled. This resolves the image-loading finding; the subsequent
human feedback and its reading-extent limit are recorded above.

The first reading stopped with actionable human feedback, before a full-path
assessment. Its first corrections completed. At `first-path-reading-k48`, the
human quoted two L2 paragraphs about identity and dependencies, requested local
examples and language-model/railroad diagrams, and asked to apply the treatment
generally before reviewing again. The response does not report the whole route
or extent of reading, and does not assess the previous corrected pages. The
new requirements and bounded corrections above govern the next read. The positive proxy
observations in `first-path-reading-k8` establish only what that proxy inferred.
Keep the human's assessment separate. The human also asks that lessons from
this process be added to the existing Grove GitHub issues: #14 (overview),
#15 (draft), #16 (copy-edit), #17 (art), #18 (proof/reader testing) and #12
(writing for understanding) in `Linkuistics/grove`, as applicable. Record actual
observations and distinguish them from proposed remedies and general claims.
The human reaffirmed this at model-reading-k73: preserve everything learned
for later conversion into skills and agent guidance. Each checkpoint keeps
the human's words and reported reading extent in its leaf, promotes the
current document contract here and in the plan, and links its observations to
the relevant existing Grove issues. Preserve refinements and counterexamples
to earlier guidance, not just the latest rule. Stage proposals must retain the
audience, task and evidence limits that make them applicable; recording them
does not mean they have already been implemented in Grove's skills.

Model-reading-k73's durable guidance record is
<https://github.com/Linkuistics/grove/issues/14#issuecomment-5885384609>, with
drafting details at
<https://github.com/Linkuistics/grove/issues/15#issuecomment-5885388298>, figure
placement at
<https://github.com/Linkuistics/grove/issues/17#issuecomment-5885388607>, and the
verified VS Code handoff repair at
<https://github.com/Linkuistics/grove/issues/18#issuecomment-5884943848>.

The orientation correction run completed (`orientation-k39`, node
`orientation-k5`). Its three pages
establish the domain vocabulary and link the existing normative/supporting set. Later increments
must replace their plain-text forthcoming mentions and interim next routes as
each page lands (plan §3). G1 is the publication map in `README.md`; G4 in
`explanation/unsaid.md` is available for reuse by concepts. Their sources/SVGs
and shared vocabulary live under `semantic/specification/interface-language/figures/`.
`task docs:check` includes byte-for-byte diagram regeneration; after intentional
figure edits use `task docs:diagrams:write` and inspect the result. The proof
found no outstanding hand-forward item. The corrected pages explain actors,
actions and consequences before abstractions and supply their own context.
G4 now shows three separate watch cases; its concepts-page caption explicitly
distinguishes them from the Store fixture. Proof expanded two residual dense
summaries (deployment/support and callback lifetimes/teardown). The follow-up
human checkpoint did not report an assessment of the whole orientation.
`first-path-reading-k64` follows the next correction; these editorial observations establish
neither human comprehension nor the effectiveness of a stage. Carry that limit
into any process-issue update based on the reading.

The second orientation correction is complete (`orientation-k55`, closing
`orientation-k5`). Its overview leads to L1's shell/key and L2's model and
reference examples. The glossary now supplies located geometry/canvas fragments
for declaration identity, imports, members, callables, clauses, packages, slots
and places. G9 is reused beside the local/imported example with its own reading
key. The slot table distinguishes `@position::result` from `@Filter::result`
and each callable's local `$result`. The all-zero import digest remains a
placeholder; these fragments are not complete packages. The domain page keeps
its separate watch API and introduces C pointee notation before using it.
Whole-document proof found no actionable defect or outstanding handoff.
`task docs:check` passed, including reproduction of all 23 SVGs.
Preserve these names, containment relations and boundaries in concepts and
tutorial corrections. At `first-path-reading-k64`, assess whether the local
examples and model make those relationships understandable; editorial
consistency and legibility checks do not establish human comprehension or a
new process remedy.

The concepts correction completed (`concepts-k43`, closing `concepts-k6`). Its three explanations
and glossary routes cover contracts, packages/access and design trade-offs; Q1–Q6 remain open in
`explanation/choices.md`. The tutorial can reuse G7's distinction between a
constructed call-scoped operation and successful synthetic subscription, with
quiescence at destructor return and no delivery or termination promise. G5
separates input call validity from the returned owner borrow; its mutable-store
case is constructed, not part of the immutable fixture. G6 covers only the
immutable unique-store lifecycle. G2 is schematic, not an additional fixture
package; G3's two getter paths select one synthetic ABI entry with different
conventions. The correction develops tool and caller actions before naming
abstractions, with figure text and comparison tables following the same cases.
Whole-document proof found no further actionable defect or outstanding handoff;
`task docs:check` passed. The landing map and direct-entry prerequisite/glossary
routes lead through all three pages, whose footers now link the tutorial.
At `first-path-reading-k64`, ask the human to follow contracts → packages →
choices after orientation, and assess whether the ownership, dependency and
access explanations now make sense. The proof's rule checks and figure read
are editorial evidence only; human comprehension and the correction's effect
remain unassessed. Keep future examples explicit about these boundaries and
preserve the separation of domain requirements, API promises and AIL choices.

The second concepts correction is complete (`concepts-k59`, closing
`concepts-k6`). Packages now introduces the geometry/canvas shell and G9 model
before its identity discussion; member association, receiver parameters,
imported types and slot references retain the same names as orientation and
L2. Contracts and choices locate their examples inside declarations and use
G10 views for clause/place syntax. G5 spells both invalidated_by arguments;
G7 names its constructed call notify. Preserve the separation between these
constructed examples and the complete fixtures, including the placeholder
Geometry pin and F1 test tokens. Whole-document proof found no actionable
defect or outstanding handoff; Q1–Q6 remain open. `task docs:check` passed,
including reproduction of all 23 SVGs. The three pages and their eleven
rendered figures were checked against the rules and examples; this supplies
consistency evidence, not a human comprehension result. The already-queued
first-path-reading-k64 owns that assessment after the tutorial correction.

The tutorial correction completed (`tutorial-k47`, closing `tutorial-k7`). The index and five
parts lead through complete synthetic label-card packages to a borrowed-to-owned change. The
finished package returns a Label borrow bounded by Card lifetime and invalidated
at refresh entry; the separate owned variant returns an independent snapshot
using the existing Label destructor. Watch notifications carry only a scalar,
retain no Card and extend no Label borrow. Destructor entry consumes Watch;
quiescence holds at return, with no delivery or eventual-return promise. Four
`tutorial-` figures and the part-5 comparison show these obligations. Whole-set
proof found no further actionable defect or outstanding handoff; `task docs:check`
passed, with all eleven SVGs reproduced. The corrected steps explain program
and library actions before the related abstractions. Each part links its new
material and complete checkpoint; the index and part 5 link the owned-snapshot
exercise before the long package. Four rendered figures and both part-5 tables
agree with the surrounding explanations and canonical rules.
At `first-path-reading-k64`, assess whether those explanations are understandable
and whether the local routes resolve P7's difficulty finding new material,
especially the ownership exercise. These are editorial observations, not evidence
of human comprehension or the effectiveness of a stage. Preserve that distinction
in any later Grove issue update; this proof establishes no new process remedy.

The second tutorial correction is complete (`tutorial-k63`, closing
`tutorial-k7`). All six pages introduce notation through located fragments;
part 1's label-card model shows Card and its two functions as package siblings,
with a separate lifecycle reference. The linked L2 geometry/canvas model supplies
the imported/member comparison. Declaration/slot/place tables distinguish
`@` references from each callable's local values, including the teardown reference
to `@watch_labels::handler`. Four G10 views accompany shell, place, callback-use
and access syntax. Preserve these scopes and the existing synthetic boundaries
in later reference and review material.

Whole-document proof found no actionable defect or outstanding handoff.
`task docs:check` passed, including reproduction of all 24 SVGs. The six complete
tutorial packages and the three canonical rule files plus grammar remain
byte-identical to pre-correction commit 0bd4c22b. The nine embedded figures,
five tables, first-time route and direct entries into parts 2, 4 and 5 agree
with the prose and contracts. The index and part 5 retain early routes to the
owned-snapshot exercise. These checks establish consistency, not comprehension;
first-path-reading-k64 owns the human assessment of the combined corrections.
No new process remedy or stage-effectiveness claim follows from this proof.

The rule-reading pipeline completed (`rule-reading-k67`, closing
`rule-reading-k49`). `language.md`, `contracts.md` and `profiles.md` now place
labelled, non-normative examples and figures beside the preserved canonical
rules. Whole-document proof found no actionable defect or outstanding handoff.
`task docs:check` passed, including reproduction of all 23 SVGs. Stripping the
paired reading-aid blocks and their trailing blank separators recovers the
three pages exactly from `87221b8c`; their anchors and F1 catalogue are preserved.
The grammar, conformance record and frozen buffers/objects/callbacks fixtures
also remain byte-identical to that revision. Both Handler extracts include the
closing brace (`callbacks.ail` lines 19–37).

For the following orientation, concepts and tutorial corrections, reuse these
landed resources under `semantic/specification/interface-language/`:

- `examples/rule-reading/{syntax,geometry,canvas,types,clauses,patterns,invalid,contracts,providers}.ail`
  contains the checked teaching material. Region files hold independent
  fragments, not concatenable complete packages. Keep their omitted-context
  labels; frozen fixture extracts and complete tutorial packages serve a
  separate purpose.
- `figures/g9-model.{puml,svg}` locates `Point` in `example::geometry` version
  `1`, and `Canvas`, `position` and `Filter` in `example::canvas` version `1`.
  The canvas package imports geometry as `Geometry`. `position` and `Canvas`
  are sibling declarations connected by `member`; each callable owns its
  named parameter and result slots. Preserve that containment distinction.
- `figures/g10-{shell,clause,names,callable,places,environment,pattern,outcome,callback-use,dependency,access}.{puml,svg}`
  supplies exact grammar-production views, with the shared unboxed caption at
  `figures/style/railroad-caption.puml`. L2/C1 share the place view; C5/C6/A2 link
  the callable overview before their nested-block details. Environment and
  pattern views expose structure the shell leaves opaque. Existing G3 access
  and G7 callback-timing explanations remain linked for their distinct jobs.

Keep the all-zero Geometry import digest explicitly a placeholder. The source
`"Canvas.position"`, symbol `"canvas_position"` and declaration identity
`(example::canvas, "1", position)` remain separate; `direct` names an access
path. The `fixture`/`native` pair and repeated `a`/`b` digests are synthetic F1
definitions and tokens, not production providers. Hypothetical
`collections::Sequence<i32>` and the optional Panel member require providers
beyond F1. Nominal-relation and session-order sketches omit compatibility,
lifetime and availability facts; retention, actor and artifact variants remain
conditional illustrations. They are not added fixture capabilities.

The proof inspected direct L2 entry, overview-to-rule navigation and the rendered
model/railroads beside their examples. These checks establish consistency and
preservation only. `first-path-reading-k64` still owns the human assessment of
understanding and the combined corrections; no new process remedy follows from
this proof's empty findings.

The root brief is the requirements authority for later sessions. There are no
three unresolved interdependent decisions requiring a full grilling: the human
has specified purpose, audience, forms, quality direction and the multi-step
research workflow. Detailed editorial choices belong to research and planning.

The graph project is `Users-antony-Development-APIAnyware.improve-api-interface-language-docs`;
the follow-up checkpoint confirmed generation `2026-09-23T09:55:55Z`. Its design
directory is excluded and edited Markdown metadata is stale or untracked.
Documentation and config observations here come from direct reads, not claims
of graph coverage. No code structure was investigated. Refresh project status
and apply Tier 2 verification before later structural code exploration.
