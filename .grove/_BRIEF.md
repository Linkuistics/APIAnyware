# APIAnyware.improve-api-interface-language-docs — brief

## Goal

Make the proposed API Interface Language understandable and assessable by
reviewers who know language design, language aesthetics and developer audience
expectations, but do not know the API binding domain. Deliver a tutorial, guide,
explanations and precise reference so those reviewers can give informed,
specific feedback on the language itself.

The human's diagnosis is that the current documentation has too little context
and explanation and is too dense for that review. Improving sentences alone
will not satisfy this workstream.

## Done when

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

## Reader and structure brief

The primary reader knows language design but is new to API binding concepts.
Do not spend pages teaching general programming or assume knowledge of FFI,
ABI, ownership transfer, borrow validity, quiescence, projections or profiles.
Define each domain concept before it becomes necessary and illustrate the
failure it prevents. API authors and tool implementers are secondary readers;
the reference still needs to serve them.

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

This work explains and improves presentation of draft 0.1. Preserve its proposed
status, normative force, stable rule identities and supported/unsupported
boundary. Reorganizing and clarifying prose is in scope; silently changing
syntax, semantics, fixtures' contracts, ABI/profile support or production
readiness is not. Surface actual language ambiguities as review feedback rather
than resolving them by inventing rules. If such a gap prevents a truthful
example, use a supported example or seek a substantive language decision.

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
  figure inventory, checks, reader checkpoints and the structure brief for
  every document (§9):
  `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`.
- Research basis and stage criteria (§9 there):
  `semantic/docs/research/documentation-basis-a.md`.
- Human-supplied reading list:
  [Richard Rabil's technical-writing books](https://richardrabil.com/2024/08/18/the-best-books-on-technical-writing-an-in-depth-analysis/).

## On the horizon

- A published edition (HTML or PDF) is not scheduled. If the human wants one,
  the survey's §8 favours AsciiDoc output generated from the Markdown set.
- Revision after the second reading checkpoint depends on its findings. It
  cannot be stated until that checkpoint runs.

## Notes

The first reading stopped with actionable human feedback, before a full-path
assessment. Draft-led corrections under orientation, concepts and tutorial run
before a follow-up human checkpoint, which in turn precedes reference and
review-guide drafting. Their initial editorial pipelines are complete, but the
human's comprehension findings now require corrections. The positive proxy
observations in `first-path-reading-k8` establish only what that proxy inferred.
Keep the human's assessment separate. The human also asks that lessons from
this process be added to the existing Grove GitHub issues: #14 (overview),
#15 (draft), #16 (copy-edit), #17 (art), #18 (proof/reader testing) and #12
(writing for understanding) in `Linkuistics/grove`, as applicable. Record actual
observations and distinguish them from proposed remedies and general claims.

The initial orientation pipeline completed (`orientation-k5`). Its three pages
establish the domain vocabulary and link the existing normative/supporting set. Later increments
must replace their plain-text forthcoming mentions and interim next routes as
each page lands (plan §3). G1 is the publication map in `README.md`; G4 in
`explanation/unsaid.md` is available for reuse by concepts. Their sources/SVGs
and shared vocabulary live under `semantic/specification/interface-language/figures/`.
`task docs:check` includes byte-for-byte diagram regeneration; after intentional
figure edits use `task docs:diagrams:write` and inspect the result. The proof
found no outstanding hand-forward item; human comprehension remains for the
scheduled reading checkpoint.

The initial concepts pipeline completed (`concepts-k6`). Its three explanations
and glossary routes cover contracts, packages/access and design trade-offs; Q1–Q6 remain open in
`explanation/choices.md`. The tutorial can reuse G7's distinction between a
constructed call-scoped operation and successful synthetic subscription, with
quiescence at destructor return and no delivery or termination promise. G5
separates input call validity from the returned owner borrow; its mutable-store
case is constructed, not part of the immutable fixture. G6 covers only the
immutable unique-store lifecycle. G2 is schematic, not an additional fixture
package; G3's two getter paths select one synthetic ABI entry with different
conventions. Whole-document proof found no outstanding defect. Keep future
examples explicit about these boundaries and replace forthcoming tutorial
routes when that page lands.

The initial tutorial pipeline completed (`tutorial-k7`). The index and five
parts lead through complete synthetic label-card packages to a borrowed-to-owned change. The
finished package returns a Label borrow bounded by Card lifetime and invalidated
at refresh entry; the separate owned variant returns an independent snapshot
using the existing Label destructor. Watch notifications carry only a scalar,
retain no Card and extend no Label borrow. Destructor entry consumes Watch;
quiescence holds at return, with no delivery or eventual-return promise. Four
`tutorial-` figures and the part-5 comparison show these obligations. Whole-set
proof found no outstanding defect or handoff; `task docs:check` passed. The
first-path reading checkpoint remains the human comprehension check.

The root brief is the requirements authority for later sessions. There are no
three unresolved interdependent decisions requiring a full grilling: the human
has specified purpose, audience, forms, quality direction and the multi-step
research workflow. Detailed editorial choices belong to research and planning.

No code structure has been investigated in this requirements session. The
checkout had no matching indexed graph project at startup; index this workspace
before any later structural code exploration, then apply Tier 2 verification
and coverage checks. Documentation and config observations here come from direct
reads, not claims of graph coverage.
