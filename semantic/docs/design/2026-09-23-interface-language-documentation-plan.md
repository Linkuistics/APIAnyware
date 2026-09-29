# API Interface Language documentation plan

Status: planned 2026-09-23; revised 2026-09-29 for the model-first route (§3,
§9.8, §10). This plan turns the
[documentation audit](../research/interface-language-documentation-audit.md)
(Step 1) and the [documentation-basis survey](../research/documentation-basis-a.md)
into the architecture of the rewritten documentation (Step 2). It fixes each
document's reader, section order and emphasis before drafting begins. Drafting
sessions cite the structure briefs in §9 by section.

The subject is draft 0.1 of the proposed
[API Interface Language](../../specification/interface-language/README.md)
(AIL). The documentation explains and presents that draft. It does not change
its syntax, semantics, rule identifiers, fixtures or supported boundary.

## 1. Readers and outcomes

**Primary reader.** A language designer who knows language design, notation
aesthetics and developer expectations, is familiar with railroad diagrams,
and is new to API binding. They read in order to evaluate AIL and give specific
feedback. Railroad familiarity is the human's explicit clarification at
first-path-reading-k64.

**Purpose of the language.** The human's 2026-09-29 direction makes explaining
the conceptual model the priority. Teach the entities, relationships and
binding obligations that the reader needs to describe; then show how AIL
expresses them. The language is a tool for this job. Evaluate its choices by
how well they serve the model and its users. The learning route develops that
account, while the reference supplies exact syntax lookup.

**Secondary readers.** API authors and tool implementers, who need exact
lookup. The reference serves them without being written for them first.

**Outcomes.** These are taken from the root brief's completion conditions.
After the relevant documents, the primary reader can:

1. explain the problem AIL addresses, who writes and uses AIL packages,
   and how signatures and behavioural obligations together describe an API;
2. follow a small worked example, read it, make a modest change and predict
   the consequences, without assuming a parser, validator or implementation;
3. tell domain constraints from AIL's own choices, and critique both, with
   the alternatives and limits in view;
4. evaluate the notation along six dimensions: syntax and readability,
   conceptual consistency, expressive scope, authoring burden,
   discoverability, and fitness for producers and consumers;
5. look up any clause, declaration kind, type or rule and find its exact
   syntax, operands, applicability, requiredness, constraints and rejection
   conditions;
6. describe the model: name the entities and relationships an API description
   records, and say which model concept each introduced AIL construct
   expresses (§10).

Outcome 6 organizes the others. The numbering is historical: briefs and task
notes cite outcomes 1–5 by number, so the model outcome is appended rather
than renumbering them. The learning route reaches it first (§3).

**Not taught.** General programming, EBNF, type systems, closed vocabularies
and how to read railroad diagrams. The reader knows these (survey §4.1,
expertise reversal; human clarification at first-path-reading-k64).

## 2. Page set and homes

All paths are relative to `semantic/specification/interface-language/`. The
normative and supporting files keep their current paths.

| Path | Title | Purpose | Reader question | Increment |
|---|---|---|---|---|
| `README.md` | API Interface Language | Landing page and orientation | What is this, what state is it in, and where do I start? | Orientation |
| `explanation/unsaid.md` | Using an API across languages | Domain explanation | What do callers and API implementers need to agree on? | Orientation |
| `explanation/model.md` | A model of API behaviour and binding obligations | Explanation of the model: the canonical account of what a description records | Which entities and relationships does a description record, and which AIL construct expresses each? | Orientation (model-first run) |
| `glossary.md` | Glossary | Terms, with familiar-meaning warnings | What does this word mean here, and how does it differ from the meaning I know? | Orientation |
| `explanation/contracts.md` | How AIL states a contract | Explanation of the semantic core | How does AIL express each obligation, and why this way? | Concepts |
| `explanation/packages.md` | Packages, environments and access paths | Explanation of the package and provider boundary | What does a package claim, and how does a consumer reach the code? | Concepts |
| `explanation/choices.md` | Design choices, limits and open questions | Explanation of rationale and scope | What did AIL choose, instead of what, and at what cost? | Concepts |
| `tutorial/README.md` and `tutorial/01-…md` to `05-…md` | Describing a small API | Tutorial in five parts | Can I read, write and change a real AIL contract? | Tutorial |
| `examples/tutorial/*.ail` | — | Checkpoint packages | — | Tutorial |
| `reference/README.md` | Reference | Reference map and indexes | Where is the exact rule for this? | Reference |
| `reference/notation.md` | Reading the grammar and the rules | Reference: grammar, railroad views and notation | Where is the exact grammar, and how do rules and reference entries describe it? | Grammar and G10 views: Concepts; entry conventions: Reference |
| `reference/types.md` | Types | Reference entries | What does this type mean, and where may it appear? | Reference |
| `reference/declarations.md` | Declarations | Reference entries, plus the applicability table | What must this declaration contain? | Reference |
| `reference/clauses-*.md` | Clauses, grouped by scope | Reference entries | What does this clause take, where does it apply, and when is it rejected? | Reference |
| `review/README.md` | Reviewing AIL | How-to: evaluation and feedback | What should I judge, and how do I give useful feedback? | Review guide |
| `review/walkthroughs.md` | Reading the conformance examples | How-to: trace tasks on existing examples | What does each clause of these packages commit to? | Review guide |
| `review/tasks.md` | Review tasks | How-to: tasks with expected observations | How do I test the design against my own judgement? | Review guide |
| `figures/` | — | Diagram sources, generated SVGs and shared style | — | From Orientation |
| `language.md`, `contracts.md`, `profiles.md`, `grammar.ebnf` | (unchanged) | Normative rules, with separately labelled reading aids in the Markdown files | How do the introduced constructs fit together? | Rule-reading (§9.7); indexed lookup remains Reference |
| `conformance.md`, `baseline.md`, `examples/*.ail` | (unchanged) | Conformance corpus; maintainer evidence | — | Page-one blocks: Reference |

The reference's clause files are split by the scope where a clause appears.
There are four files:

- package, environment and common declaration clauses;
- callable effects and input obligations, including buffers and strings;
- outcomes and callback use;
- access paths, patterns and the fixture profile.

The reference inventory confirms this split: `clauses-package.md` owns 29
package, environment, common and nominal clauses; `clauses-callable.md` owns
15 effects/input/storage clauses; `clauses-outcomes.md` owns 9 outcome and
callback-schedule clauses; and `clauses-access.md` owns 11 access, pattern and
fixture clauses. Shared spellings (`executor`, `concurrency`, `reentrancy`)
have one entry covering both scopes. The `runtime` entry distinguishes its
environment-clause use from its lifecycle-constructor use. The reviewed
classifications are in `semantic/specification/tools/reference-dispositions.tsv`;
`task docs:coverage` re-extracts candidates and checks them against this list.

Page sizes follow the reader's questions, not a word budget. A page answers
one question at one level. A definition does not get its own page unless it is
a reference entry.

## 3. Reader journeys

The organizing priority is the model and its use (human direction,
2026-09-29: "the language is a tool and is not of interest by itself"). The
learning route has three stages, and each answers a different question:

1. **Why a description is needed.** The landing page and *Using an API across
   languages* show, through one small C API, what a caller and implementer
   have to agree on and what goes wrong without that agreement. No AIL yet.
2. **What the description records.** *A model of API behaviour and binding
   obligations* (`explanation/model.md`) gathers those agreements into one
   account: the entities involved, how they relate, and what a caller or tool
   needs to know about each. It names each model concept once, with a stable
   anchor, and ends with the concept-to-notation map (§10). This page is the
   canonical model explanation; later pages link to it instead of re-deriving
   the model.
3. **How AIL writes it down.** The concept pages, the tutorial, the canonical
   reading aids and the reference introduce each construct by the model
   concept it expresses. Each introduction names the concept and the reader's
   task, links the concept's anchor, then shows the notation in a located
   snippet. The package/declaration containment model (G9) appears where the
   relationships need it. Exact syntax is reached through links to the
   grammar and railroad sections in `reference/notation.md`.

Exact lookup is separate from this route. The reference answers "what exactly
does this clause take and when is it rejected?"; it links each entry back to
its model concept but teaches nothing in sequence.

**The guided route:** landing page, then *Using an API across languages*,
then *A model of API behaviour and binding obligations*, then the three
concept pages, then the tutorial, then the review guide. The reference is
consulted along the way, not read through. Every page ends with where to go
next on this route.

**Direct entries.** Each needs its own route back:

- **From a rule** (a review comment cites C6). The normative page's page-one
  block names the model page and the explanation that motivates the rules, and
  the reference entries that index them once they exist. Each rule section's
  first reading aid names the model concept its constructs express and links
  that concept's anchor. Local reading aids give each introduced construct a
  concrete context; a reader following a rule link need not first read the
  whole guided route (§9.7).
- **From a model concept** (a link to `model.md#callbacks`). The concept's
  section links the domain case that motivates it, the concept-page section
  that introduces its notation, the tutorial part that exercises it and the
  canonical rules; the reference entries are added when they land.
- **From an example** (a link to `buffers.ail`). The walkthrough explains the
  example, and the landing page lists all examples with their purpose.
- **From a term** (a search for *quiescence*). The glossary entry links to its
  defining page and to the rules that use it.
- **From a reference entry.** Each entry names the model concept it expresses
  and links to it, to its rule, to its explanation and to examples that use it.

A reader who lands anywhere must learn, within the first screen, what the page
is for, what it assumes, the draft's status, and where the canonical rules are
(§5).

**Staging.** The set lands over several increments, and every landed page must
be reachable and usable on the day it lands, not only after cross-set
navigation. One rule serves every increment, including a document split
across several draft sessions and the reference's clause files:

- The session that lands a page links it from the landing page's map, or from
  a parent index that the map already links. The page is then reachable from
  `README.md`, and `docs:links` checks that (§7).
- The same session gives the page a return route and a next route, both to
  pages that already exist. Where the guided route's true next page is not yet
  written, the next route points to the nearest existing page on the route.
- A route to a page that does not exist yet is written as plain text naming
  the page, not as a link. The session that lands that page converts every
  such mention into a link, and replaces the interim next route that pointed
  past it.
- Where a document's index lands after its pages (`reference/notation.md`
  before the reference index, or the review guide's walkthrough before
  `review/README.md`), the map links the earlier pages directly until the
  index lands and takes over.

Cross-set navigation (§9.6) then completes the map, the back-links and the
footers. It is never the first point at which a page becomes reachable.

## 4. Prose contract

One contract serves the whole set. It is the charter for `copy-edit` and the
standard for `draft`. These rules are defaults with stated exceptions, not
metrics (survey §6).

- **Explain the action before naming the abstraction.** Start with the people,
  tools and values the reader can identify. Explain who acts, what they act on,
  what happens, and why the next step follows. Introduce a technical term once
  that account gives it meaning. A glossary link helps readers revisit a
  concept; the surrounding prose teaches it. At checkpoint 1 the human could
  not understand "every producer crosses the same publication boundary" and
  reported the same problem elsewhere. The correction covers the whole path,
  including headings, opening sentences, tables, captions and diagram labels.
- **Positive framing.** Lead with what a thing is, how it works, what the
  reader can do and which conditions apply. Name the actual subject in a
  heading: *Using an API across languages*. Explain two cases by stating each
  case's behaviour. Preserve exact obligations and limitations by explaining
  the applicable condition and consequence; the normative text remains the
  authority for prohibitions and rejection. Familiar-meaning comparisons
  follow an affirmative definition when that comparison helps the reader.
- **Room for understanding.** Develop a new relationship over connected
  sentences and a concrete example. The reader should be able to name the
  actor, action and result from the passage itself. Sentence counts, brief
  paragraphs, glossary coverage and a model's successful paraphrase do not
  establish that the human understands it. Keep the explanation needed for
  that reader, even when it makes the page longer.
- **Semantic density.** Outside reference documentation, limit how many new
  concepts and relationships a sentence or paragraph asks the reader to absorb.
  Explain one relationship, illustrate it, then build on it. Tables and captions
  support that explanation; they do not replace it with compressed terminology.
- **Standalone documents.** Reader-facing pages carry their own context and
  explanations. They are independent of Grove, editorial history, ADRs and the
  process that produced them. Keep plans, research records and process evidence
  outside the published documentation. Links within the documentation set may
  provide prerequisites, fuller explanations and exact rules.
- **Normative force.** BCP 14 keywords appear only in the normative files,
  which keep their current wording. Explanation, tutorial, review and
  reference pages use no capitalised keywords and do not restate a rule's
  force. They cite the rule, written in Markdown as
  `the validator rejects it ([C5](../contracts.md#c5))`. Where a page
  summarises a rule, it says so: `In summary (non-normative; the rule is
  [C3](../contracts.md#c3)): …`. Rule anchors are the lower-case identifier
  (`#c5`), placed by the documentation foundation.
- **Voice and actors.** Obligation sentences name the responsible party
  (caller, callee, producer, validator, consumer) as the subject and the
  action as the verb, as in "The caller keeps `store` alive until …". Passive
  or stative wording is correct where a rule concerns a document and the actor
  is irrelevant.
- **Conditions before actions** apply in the tutorial and review tasks: state
  the condition, the goal or the location, then the action, then the result.
  Steps use the imperative, and running text uses the indicative.
- **Terms.** One term, one concept. The glossary is the term list. Link a
  glossary term at its first use on each page. Where a term collides with a
  familiar meaning, say so at first use. *Closure* is always qualified as
  *dependency closure* or *callback captures*, because the normative text uses
  both senses (audit Q2).
- **Domain before notation.** Explain an obligation in domain terms before
  showing the clause that states it. Where the model page already explains
  it, recall it in a sentence or two with the concrete case and link the
  concept, rather than re-teaching it. Every analogy to Rust, Swift, C++ or C
  says where it fails.
- **Show constructs as they are introduced** (human decision, 2026-09-28).
  Put a small, explained snippet beside a construct's first substantive
  introduction on each standalone page. Show enough of its enclosing package,
  declaration or callable to locate it, and explain what its names refer to
  and which model facts it records. Let the example show familiar punctuation;
  omit prose lessons on parentheses, commas, semicolons, braces and other
  self-evident notation (model-reading-k73). Explain AIL-specific distinctions
  such as declaration references versus callable-local places, whose meaning
  the reader cannot infer from general language fluency. A complete package
  later on the page and a glossary link serve different purposes; they do not supply this local
  introduction. Build from a small example to the relationship and rule,
  retaining complete examples for later inspection. Domain-only passages can
  use their C example or concrete actions without introducing AIL prematurely.
- **Two models, one purpose.** The *API model* (§10, `explanation/model.md`,
  figure G11) is what the documentation teaches: the entities and obligations
  a description records. The *language model* (G9) is how AIL organizes the
  text that records them: packages, declarations, imports, members and slots.
  Introduce the language model where a snippet needs it, after the API-model
  concept that motivates the construct, and say which API-model concept the
  containment serves. Never call G9 "the model" without qualification.
- **Establish the language model before dependent syntax.** Relate packages,
  declarations, nominal owners, imports, callables and slots before presenting
  reference spellings that assume those relationships. The explicit acceptance
  cases are a declaration in the current package versus one in a named imported
  package; a top-level member associated with its owner by `member`; and local,
  imported and slot references. Distinguish `@operation::parameter` from a
  callable-local `$parameter` place. Show how a receiver is an ordinary named
  parameter, and how a type name is written without `@`. Give the syntax a
  visible containing context and explain its use, rather than listing tokens.
- **Use figures to teach the relevant structure.** A language-model diagram
  shows containment and named relations beside the example that needs them.
  Railroad diagrams live with the grammar description in `reference/notation.md`;
  other pages link to the relevant section for exact syntax. Explain the
  language model's relationships and the examples' meaning and consequences.
  Assume the reader can read railroads; omit generic lessons on tracks,
  branches, optional paths and repetition. Explain name resolution,
  applicability and semantic validity through the examples and rules. Follow
  §6 for sources, SVGs and drawing conventions.
- **Make the model the main thread.** Explain what needs to be described and
  the relationships involved, then connect language constructs to that account.
  Choose the next learning step by the model concept or reader task it enables.
  Use syntax examples to express those ideas and reference entries for exact
  lookup. This is the human's explicit priority at first-path-reading-k64.
  Concretely, every notation-introducing section names its model concept in
  its opening sentences, in the concept's own words from `model.md`, links
  that concept's anchor, and states the reader's task ("to tell a caller when
  it may stop reading the view …") before showing syntax. It then shows how
  AIL expresses the concept and judges the notation by that job. A section
  that introduces a construct with no concept in §10 is a defect: either the
  construct belongs to an existing concept or §10 is incomplete, and the draft
  records which.
- **Two cases, then the principle.** Teach a concept by comparing two
  contrasting cases, then state the principle, then say where the comparison
  breaks down (survey D7).
- **Code typography.** Identifiers, clause names, types, file names and rule
  identifiers are in code font. Fence tags: `ail` for AIL, `ebnf` for grammar,
  `c` for domain signatures, `json` for projections and `text` for anything
  else.
- **Headings and links.** Use sentence-case headings that start with the
  information-carrying words; question headings suit explanation pages. Link
  text pairs an AIL term with a gloss, as in "`quiescence` (no callback
  running or able to start)".
- **Status.** Explain what is available and how to review it: "Draft 0.1 is a
  proposal under review through its specification and synthetic examples.
  Parser, validator and implementation development are future work." Identify
  the invented API and synthetic fixture profile, catalogue and digest tokens
  in each example's local context. Refer to that explanation as the reader
  proceeds, retaining enough context for an independently read extract.
- **No invented tool output.** No page shows a validator message, command
  output or diagnostic text. Expected results are observations a reader can
  check by inspection: which clause changes, and which rule a conforming
  validator applies.
- **No process narration on reader pages.** Session history, grove state and
  verification logs stay out of reader pages. The existing verification record
  in `conformance.md` is kept and labelled as a record.
- **Length.** Judge length against what the reader needs. No readability
  score or grade-level target is used (survey §5).

## 5. Page-one block and example labels

On canonical pages, delimit non-normative reading aids with a blockquote's left
border. Use a bold label and explicit anchors preserving incoming links;
remove heading-based delimiters and visible end markers. An HTML `<blockquote>`
wrapper with blank lines permits the existing Markdown, tables, figures and
fenced examples to render inside it. Keep the paired `reading-aid` comments as
source boundaries for canonical-text preservation, and the rule text outside
the visible border. This is the human's 2026-09-29 presentation direction.

Every page except the normative files opens with this block. The normative
Markdown files get it in the rule-reading increment, with their rule text
unchanged. The reference increment checks and reuses those blocks.

```markdown
> **Purpose:** <form> — <one sentence on what this page is for>.
> **Reader:** <who, and what they already know>.
> **Before this:** <links to prerequisite pages, or "nothing">.
> **Status:** Draft 0.1 is a proposal under review through its specification
> and synthetic examples. Parser, validator and implementation development
> are future work.
> **Rules:** the canonical rules are <links to the rule identifiers>.
```

Every AIL code block carries one label, immediately before the fence:

- **Complete package:** "Complete package — admitted by the grammar and
  complete under draft 0.1, checked by inspection." The block is a whole
  `.ail` file, or a region of one, kept in step by the example check (§7).
- **Fragment:** "Fragment — shows <the subject>. The complete package also
  supplies <the surrounding declarations and facts>." Identify its scope and
  link the complete example when one exists. A constructed fragment names the
  surrounding context needed to form a complete package.
- **Invalid:** "Invalid — rejected under <rule> (<mutation ID if one
  exists>)." Each block shows one failure.

## 6. Figures

**Medium** (human decision, 2026-09-23). PlantUML, D2 and Mermaid are equal
notations, alongside fenced text diagrams. Every diagram commits its source
and a tool-generated SVG under `figures/`. The relation being shown chooses
the notation. Diagrams run from context down to detail, C4-style. The pinned
renderers are the local installs: PlantUML 1.2026.8 with Graphviz 16.1.0, and
D2 0.9.0. Mermaid needs `mmdc`, which is not installed, so a Mermaid figure
is used only once its renderer is pinned and its SVG can be regenerated.

The human's 2026-09-28 reading adds two figure purposes: a language-model view
and syntax/railroad views. Keep them within these admitted notations and the
source-plus-generated-SVG workflow. A selected production can be drawn with
the existing tools; no new diagram service or parser implementation is needed.
Distinguish literal tokens and nonterminals, and represent alternatives,
optional parts and repetition accurately. Assume familiarity with railroad
diagrams (human clarification at first-path-reading-k64). Omit the instructional
legend boxes; a plain caption identifies the non-normative syntax view.
The grammar reference names the productions and their scope, links the exact
EBNF, and keeps the existing G10 views together. Examples carry familiar
surface syntax; prose explains AIL-specific meaning without restating obvious
punctuation or teaching how to follow a railroad. Check every
path against the named EBNF production. Keep semantic constraints in prose with
rule links.

**Visual vocabulary.** All three notations render the same vocabulary. The
first `art` session defines it once, as shared style files under
`figures/style/`, and every later figure reuses them:

- one shape per role: producer, package, catalogue (profile or ABI entry),
  validator, consumer, caller, callee and owner;
- one line style per relation: ownership transfer (solid), borrow (dashed),
  invalidation (a marked end) and callback entry (dotted);
- colour only as a redundant cue, never the only one;
- the prose's names on every element, with keys for domain and language-model
  diagrams; railroad diagrams assume notation fluency and omit instructional keys.

The shared vocabulary is now defined in
[`figures/style/vocabulary.txt`](../../specification/interface-language/figures/style/vocabulary.txt),
with PlantUML role macros in
[`figures/style/ail.puml`](../../specification/interface-language/figures/style/ail.puml).
G1 and G4 use PlantUML. `task docs:diagrams` compares regenerated SVG bytes;
`task docs:diagrams:write` explicitly updates them. The check also supports the
pinned D2 renderer; Mermaid needs a pinned renderer added before first use.

| ID | Level | Question it answers | Kind | Home |
|---|---|---|---|---|
| G1 | Context | Who writes AIL packages, what do they depend on, and who reads them? | C4 system context | Landing page; linked or reused where it helps a later page |
| G11 | API model | Which entities and relationships does a description record: operations and their values, outcomes, entities with lifetimes, release responsibility, validity, storage, execution, callback schedules, and the published description that reaches code? | Conceptual structure, class-style; one overview, or two linked views (calls; description and access) if one is not legible | `explanation/model.md`; linked from the concept pages, the tutorial index and the canonical page-one blocks |
| G2 | Package | What does a package contain and pin? | Structure, class-style | `explanation/packages.md` |
| G3 | Access | How does one operation reach code through two access paths and an ABI entry? | Structure | `explanation/packages.md` |
| G4 | Contract | What moves between caller and callee when a call borrows, consumes, or gives an owned value? | Sequence | `explanation/unsaid.md`, `explanation/contracts.md` |
| G5 | Contract | How long is a borrowed result valid, and what ends it? | Timing | `explanation/contracts.md` |
| G6 | Contract | What states does a uniquely owned resource pass through? | State | `explanation/contracts.md` |
| G7 | Contract | When may a registered callback run relative to registration and quiescent teardown? | Timing or sequence | `explanation/contracts.md`, tutorial part 4 |
| G8 | Navigation | Which page answers which question? | Table, not a diagram | Landing page |
| G9 | Language model | Where do declarations and slots live, and how do imports and member ownership relate them? | Structure, with concrete names shared by the examples | `language.md` L2; linked or reused by `explanation/packages.md` |
| G10 | Syntax | What forms do the package shell, imports, references and clauses admit? | Small railroad views tied to named EBNF productions | `reference/notation.md`, with the grammar description; linked from other pages |

G11 sits between G1 and the detail figures in the C4-style order: G1 shows
who writes and uses a description, G11 what it records, and G2–G7 and G9–G10
one relationship or production each. G11 uses the watch API's names from the
domain page and the concept names and anchors from §10; its labels name
entities and relations in the prose's words, not AIL keywords. G9 remains the
language-containment view and is never substituted for G11.

The drafts decide which figure slots a page needs and record each unfilled
slot in the document node's handed-forward list for `art`. Prose carries every
semantic fact that a figure shows. The textual grammar is the exact alternative
to a railroad image; this does not require prose to narrate each punctuation
mark or path through the diagram.

Start diagram labels and captions with the same concrete actors and actions
the prose has introduced. Order views from overview to detail across the
reading route; a link back to the overview can orient a later page. Repeating
the full context figure and its introduction on every page is a choice to
justify against that page's reader task. Keep a clear route from each detail
view to the overview. Apply the same comprehension check to titles, keys,
labels, alt text and captions as to paragraphs.

## 7. Checks and verification

**Repeatable checks** are root `Taskfile.yml` tasks, using only the Python 3
standard library. The documentation-foundation increment writes the first two:

- `docs:links`: every relative link and `#fragment` in the set's Markdown
  (the directory above, this plan and the audit) resolves. A fragment must
  match an explicit anchor or a GitHub heading slug. Links that leave the
  repository fail, and external URLs are listed, not fetched. Every Markdown
  page in the directory above must also be reachable from the landing
  `README.md` by
  following relative links, so an orphaned page fails (§3, *Staging*).
- `docs:examples`: every `ail` fence has an example or fragment marker. An
  example marker names a file and either a region (`// region: name` …
  `// endregion` comments in new `.ail` files) or a line range (for the
  existing, frozen conformance examples). The fence body must equal that text
  with the marker lines removed. Every fence has an info string.
- `docs:check` runs both.

The scripts are in `semantic/specification/tools/` (`docs_links.py`,
`docs_examples.py` and their shared scanner `mdscan.py`). Each script's
docstring states its rules in full. A marker is an HTML comment on its own
line. It is the nearest non-blank line before its `ail` fence, so it sits
between the visible label (§5) and the fence:

```text
Complete package — admitted by the grammar and complete under draft 0.1,
checked by inspection.

<!-- ail-example: examples/buffers.ail region=create -->
```

The four marker forms are:

| Marker | The fence body must equal |
|---|---|
| `<!-- ail-example: PATH -->` | the whole file |
| `<!-- ail-example: PATH region=NAME -->` | the lines between `// region: NAME` and its matching `// endregion` |
| `<!-- ail-example: PATH lines=A-B -->` | lines A to B of the file, inclusive |
| `<!-- ail-fragment -->` | nothing; the fence is not compared |

`PATH` is relative to the Markdown page. Every form removes `// region:` and
`// endregion` lines before it compares. Regions may nest, and a region name
is defined once per file. The fragment marker also serves invalid blocks,
since neither shows a whole file. A marker with no `ail` fence after it
fails. The anchors that rule citations use (`#l1`–`#l6`, `#c1`–`#c8`,
`#a1`–`#a5`, `#f1`) are explicit `<a id>` lines before the rule headings.
The heading slugs still resolve.

Later increments add tasks when they first need them:

- `docs:diagrams` (first `art`): regenerate every SVG from its source with the
  pinned renderers and fail on a difference.
- `docs:coverage` (reference): build the inventory from the sources and
  confirm each item is accounted for. The grammar cannot supply the clause
  vocabulary, because its generic `clause` production admits any name. Many
  clauses are defined in running prose rather than in tables, among them
  `surface`, `exports`, `values`, `extent`, `contents`, `callback_abi` and
  `representation` (audit F5). So the check enumerates, then classifies:
  - *Candidates* are extracted mechanically from every normative source: the
    grammar's productions and literal keywords; every `name(` token in code
    spans and table cells of `language.md`, `contracts.md` and `profiles.md`,
    including qualified profile names such as `fixture::actor`; the clause
    heads used in `examples/*.ail`; the rule identifiers; and the mutation IDs.
  - A committed *disposition list* classifies every candidate. A candidate is
    a reference entry, with the file that owns it; covered by a named entry
    (a value constructor such as `owner(…)`, documented under its clause); or
    not vocabulary, with a one-line reason. A reference entry's disposition
    also names the §10 model concept it expresses (§9.4).
  - The check fails on an unclassified candidate, on an entry-class item with
    no entry in its file, and on a disposition naming nothing the sources
    contain. An entry owned by a reference session that has not yet run is
    reported as pending, by name, and a pending item in a file that has landed
    is a failure.

  The candidate extraction is a lexical sweep. It does not parse AIL and does
  not decide what is a clause; the disposition list records that judgement,
  and it is reviewed against the rule text like any entry.
  The implementation also extracts the names in L4's core-type table, so scalar
  types and type constructors cannot fall outside the grammar/clause sweep.
  `docs_coverage.py` exposes `--inventory` for source locations, `--json` for
  candidates/dispositions/errors/pending, and `--require-complete` for the final
  reference gate. The runtime checker uses the standard library. The separate
  maintainer task `docs:coverage:test` runs pytest contract tests through uv;
  it is not a parser or semantic-validation suite.

None of these checks parses AIL or validates contracts. The EBNF recognizer
from the draft's verification record was disposable and is not a documentation
check. A complete-package label is checked by inspection against
`grammar.ebnf` and the rules.

**Semantic fidelity**, checked by `draft` and `proof`:

- every normative claim on a non-normative page cites a rule identifier;
- no rule is invented;
- an ambiguity found while drafting is recorded as a review question in
  `explanation/choices.md`, not resolved.

Syntax claims, semantic inspection and unexecuted runtime claims are reported
separately.

**Accessibility.** Every figure has adjacent prose carrying all its facts and
an accessible description. Tables have no merged cells and stay narrow enough
to read as raw Markdown.

**Stage criteria.** The survey's §9 lists apply per stage: D1–D8 for `draft`,
C1–C10 for `copy-edit`, A1–A8 for `art` and R1–R5 for `proof`.

## 8. Reader checkpoints

The human is the only human reader available, and is an experienced language
designer who knows the domain. No cold reader new to the domain is available,
so survey tests T1, T3 and T5 cannot be run as designed. Each checkpoint
therefore has two parts:

1. **A proxy reader.** A fresh-context model is briefed as a language designer
   new to API binding. It gets only the pages under test and the outcomes in
   §1, and is asked to perform them, thinking aloud. Its transcript is kept
   with the checkpoint's findings and labelled as a proxy (T4). It is not
   evidence of human comprehension.
2. **The human's read.** The human reads the same path as a reviewer, marks
   what helps and hinders, and judges whether it supports the review they want
   to make.

Checkpoint 1 follows the tutorial and covers the first path: landing,
explanation and tutorial. Checkpoint 2 follows the cross-set navigation and
covers the whole set. A defect found in a landed document becomes a correction
run under that document's node. A change to a later document's structure
becomes an edit to its brief in §9.

At checkpoint 1 (`first-path-reading-k8`), the human stopped the read because
the prose was too compressed and used negative framing. The proxy's successful
answers remain proxy observations. Correct orientation, concepts and tutorial
through their editorial stages, then run a follow-up human reading checkpoint
before reference or review-guide drafting. Start that follow-up with the revised
overview and domain explanation and let the human's feedback determine whether
to continue the path. Record the extent of the read and the human's words.
The first checkpoint's proxy transcript remains available as historical
evidence; repeating it is optional for this follow-up. The full-set checkpoint
still follows cross-set navigation.

At the follow-up (`first-path-reading-k48`, 2026-09-28), the human quoted the
opening two paragraphs of `language.md` L2. They asked for examples distinguishing
local from non-local declarations, a member example, and language-model or
railroad diagrams that establish context when syntax is introduced. They asked
to apply these points generally and then review again. Those quoted locations
are the extent of the reported read; the response does not establish the route
taken, full-path coverage or an assessment of the previously corrected pages.

Run rule-reading (§9.7) before one further correction run each for orientation,
concepts and tutorial. This reaches the second-re-run escalation boundary for
those three documents; the human's explicit instruction supplies direction for
this bounded run, not an unattended repetition policy. Each runs draft,
copy-edit, art and proof once. Record unresolved residue and stop for human
direction rather than growing another correction cycle. Then run
`first-path-reading-k64`, before reference and review-guide drafting. Begin
that read at L2's repaired introductions and their model/notation aids, then
follow the connected explanations and tutorial as the human proceeds. Record
what was actually read and said; neither editorial checks nor a proxy supplies
human comprehension evidence.

At first-path-reading-k64 the human clarified, "I mean your improvement is
good," and established fluency in language design and railroad diagrams.
They asked to remove the railroad-reading boxes, visually delimit the
non-normative reading aids, and prioritize explaining the model before
describing the language by reference to it. Their rationale is that the language
serves as a tool. The bounded presentation changes land in that checkpoint;
model-first-documentation-k68 owns revising the detailed route and cutting the
document work. The human did not report a page-by-page reading extent, so this
records a positive assessment and new direction without inferring a full-path
comprehension result.

`model-first-documentation-k68` cut one further ordered run for each of
orientation, concepts and tutorial, in that order, before reference and
review-guide drafting. The human direction authorizes exactly those runs; it
does not reset the correction history or authorize automatic repetition.
Each run is its draft session(s), then one copy-edit, one art and one proof.
A defect that would send work back to an earlier stage is recorded for the
next human checkpoint instead of growing a correction run.

One earlier read, `model-reading`, sits between the orientation run and the
concepts run. It asks one concrete question: does the model page's concept
set, order and concept-to-notation map (§10) give the right account of what
an API description records, before the concept pages, tutorial, canonical
aids, reference and review guide are organized around it? Record the human's
words and actual reading extent; a changed concept set becomes an edit to §10
and the later briefs, and a defect in the model page becomes work for the human
to direct. The full-set checkpoint still follows cross-set navigation.

At `model-reading-k73`, the human said the material was "looking good", praised
the example fragments, and requested less syntax narration: familiar
punctuation needs no prose lesson, and railroad diagrams belong with the
grammar description, linked from other pages. They quoted *From signature to
contract* in `explanation/contracts.md`; the full reading extent was not
reported. The concept set and order remain unchanged. This assessment permits
the queued work to continue with the presentation refinement; it does not
establish comprehension of unreported sections. The concepts run adds one
early draft, concepts-k85, to establish the grammar destination before its
consumers. Its existing copy-edit, art and proof cover that addition; the
bounded-run rule remains. For local VS Code handoffs, open the interface-language
directory or workspace root as a folder before previewing Markdown so sibling
figure resources load.

Preserve reader evidence for the Grove skills and agent-guidance work (human
reminder at model-reading-k73). Keep verbatim feedback and its reading extent
in the checkpoint leaf, the resulting requirements in this plan and the root
brief, and links to observations and stage-specific proposals in Grove's
existing guidance issues. Retain how new evidence refined earlier advice:
"explain examples" requires meaning and context appropriate to the audience,
not a narration of every visible token. Distinguish proposed guidance from
guidance already implemented and a verified presentation repair from evidence
that the prose was understood.

## 9. Structure briefs

Each brief states the reader and outcome, the ordered sections with the
purpose of each, the emphasis and non-goals, the sources and the verification.
Sections may merge or split during drafting when the reader's questions demand
it. The order holds unless the draft records why it changed.

### 9.1 Orientation

Pages: `README.md`, `explanation/unsaid.md`, `explanation/model.md` (its own
brief is §9.8) and `glossary.md`.

**Reader and outcome.** The primary reader, arriving with no context. After
these pages they can state what AIL is and its status. They can name the
binding obligations that govern use of the API and explain what each one
requires. They can say who writes and reads AIL, and choose a path through the
documentation. This is outcome 1 in §1. After the model page they can also
describe the model as a whole, the first half of outcome 6: its entities,
relationships and the question each concept answers for a caller or tool.

**`README.md`: ordered sections**

1. *What AIL is.* Explain that AIL is a proposed way to describe an existing
   API so tools can help programs in other languages use it correctly. Give
   enough context to understand a binding contract, then the status line.
2. *Who this documentation serves.* The primary and secondary readers, and
   the kind of feedback wanted: specific, tied to examples and rules, and
   critical where warranted.
3. *Who writes and uses an AIL description.* Explain the proposed workflow
   through actors and actions, then figure G1. For example: an API author or
   an analysis tool writes a description. A validator checks that it contains
   the required information and that its statements agree. Human authors and
   tools meet the same checks. Other tools use the checked description to
   generate bindings or documentation. The author remains responsible for
   evidence that it matches the API. Introduce *producer*, *consumer* and
   *publication boundary* only after their meanings are clear. This section
   links to `explanation/unsaid.md`.
4. *Paths through the documentation.* A table (G8) with rows for "if you want
   to …" and "start at …", covering understanding, learning, reviewing and
   looking up.
5. *What is normative.* Which files are canonical, what the other pages are,
   and the rule-identifier scheme.
6. *Scope of draft 0.1.* The current scope and limits, kept from the existing
   README's scope section, with a link to `explanation/choices.md`.
7. *Next route.* Lead to the domain explanation. Keep design history, the audit,
   surveys and this plan outside the reader-facing page.

**`explanation/unsaid.md`: ordered sections** (title: *Using an API across
languages*; keep the existing file path)

1. Page-one block.
2. *A small API.* A synthetic C header of about three functions: create and
   destroy a handle, return a borrowed view, and register a callback with a
   context pointer. Start with the operations and types the C declarations
   describe, then explain the conditions for using those operations.
3. *The caller's and implementer's obligations.* One subsection per obligation,
   each explaining the action, its conditions and consequences, and then
   introducing the domain term. Use concrete cases for:
   - ownership transfer (a leak or a double free);
   - borrow validity and invalidation (use after free);
   - buffer extent and contents (overrun, or a missing terminator);
   - how failure is signalled and what the outputs mean on failure (reading
     uninitialised output);
   - threads, executors and re-entrancy (data races, deadlock);
   - callback count, timing and quiescent teardown (a callback runs after its
     captures are freed).
   Figure G4 goes here. The components and their possible states are
   introduced before anything combines them (survey P10).
4. *A shared description for API tools.* Show how signatures and the stated
   obligations together let a binding generator, a documentation renderer and
   an LLM describe the same API accurately. Explain what each tool uses from
   the description through a concrete operation already introduced.
5. *Reaching the code.* ABI, calling convention, access path (symbol, message
   send, source-compiled call), projections, and profiles and providers, in
   domain terms first.
6. *Reading AIL's terms.* Define *borrow*, *owned*, *consume*, *shared*,
   *copy*, *profile* and the two senses of *closure* affirmatively, with a
   concrete use. Add a familiar-meaning comparison where it helps interpret
   the stated obligation.
7. *Where next.* Links to the concept pages and the tutorial.

**`glossary.md`.** Alphabetical entries. Each entry gives the term, a
definition with enough context to understand it, the defining page, the rules
that use it, and a familiar-meaning warning where one applies. It covers the domain list from the
root brief and every AIL term used on the orientation and concept pages.

For the 2026-09-28 correction, show a small named example when an entry
introduces language structure or notation. In particular, give declaration,
local/imported declaration, member, callable/slot and canonical identity enough
context to distinguish containment, association and reference. Link the rule
reading aids and the concept explanation. The landing route should make these
aids discoverable; the domain page retains its domain-first purpose.

**Model-first run (human direction, 2026-09-29).** The run lands the model
page (§9.8) and makes the orientation pages lead to it:

- `README.md`. *What AIL is* says in a sentence that the documentation
  explains a model of API behaviour and binding obligations and then shows how
  AIL writes it down. *Paths through the documentation* gains a first-row
  route "Understand what a description records → the model page", and routes
  the direct notation entry through the model page before L1/L2. The
  continuation paragraph follows §3's route. Repair the two k64 residues: the
  link text "The package shell and railroad reading key" (also in
  `glossary.md`) names a key that no longer exists, and *What is normative*
  still describes reading aids as having "an explicit end marker"; describe
  the bordered, labelled aids as they now are.
- `explanation/unsaid.md`. Keep every obligation section and its failure case;
  they are the model page's motivating evidence. End each obligation section
  by naming, in one sentence, the model concept it motivates, linking its
  anchor. *A shared description for API tools* and *Reaching the code* keep
  their domain explanations and point to the model page's description and
  access concepts for how the parts fit together. *Where next* leads to the
  model page first.
- `glossary.md`. Each term that names a model concept, or an entity within
  one, links its concept anchor alongside its defining page. The fragment
  examples added in 2026-09-28 remain; their introduction names the model
  concept before the containment it illustrates.

The run preserves the pages' existing explanations, examples, figures G1/G4
and anchors. It moves no domain explanation out of `unsaid.md`.

**Emphasis.** Concrete actions and consequences before abstraction, and domain
obligations before AIL syntax. The landing page gives a newcomer a clear route
to the domain page while retaining the explanation needed to choose that route.
The checkpoint's reported phrase is one example of the defect: read all three
pages for compressed relationships and negative framing. Update every affected
link label and heading-derived anchor across the existing document set.

**Non-goals.** No clause-by-clause coverage and no AIL syntax on
`explanation/unsaid.md` beyond a closing glimpse. No teaching of programming
or language design. Nothing about APIAnyware's internal pipeline beyond one
sentence of provenance.

**Sources.** The existing `README.md`; the design proposal's §1, §3 and §4;
`contracts.md` C1–C6 for which obligations exist; the survey's §4.1; and the
audit's F1, F2 and F4.

**Verification.** `docs:check` passes. Every obligation named maps to a rule
identifier, even where the page shows no AIL. Every domain term in the root
brief has a defining location. The landing page's links cover every page that
exists when this increment lands. Later pages are named as plain text, not
linked, under the staging rule in §3.

### 9.2 Concepts

Pages: `explanation/contracts.md`, `explanation/packages.md` and
`explanation/choices.md`.

**Reader and outcome.** The primary reader, after orientation. They can
explain how AIL states each obligation from §9.1, and read any clause in the
three conformance examples at the level of what it commits. They can tell a
domain constraint from an AIL choice for every major choice, and know what
draft 0.1 cannot express. These are outcomes 2 (in part) and 3. They can also
say which model concept each construct they have met expresses, and judge
whether AIL expresses that concept well: the second half of outcome 6.

**`explanation/contracts.md`: ordered sections.** Every section after the
first follows the same pattern: the domain obligation, two contrasting cases
in AIL, the principle, AIL's choice and its alternative, and the rule links.

1. Page-one block.
2. *From signature to contract.* The shape of a declaration and its clauses,
   using one operation from `explanation/unsaid.md`, now in AIL.
3. *Naming what a contract talks about.* Slots and places (`$p`, `$result`,
   `.*`, `[]`) and reference leaves.
4. *Who owns what.* `input` (`borrow` against `consume`), `retain`, and
   `give` (`owned` against `borrow`). Figure G4.
5. *How long a borrow lasts.* The regions `call`, `static` and `owner`, and
   `invalidated_by`. Figure G5.
6. *Every way a call can end.* Outcomes as an exhaustive partition, using
   `when`, `meaning` and `state`, compared across a null-result API and a
   status-result API.
7. *Buffers and strings.* `extent` and `contents`: length against capacity,
   and terminators.
8. *Callbacks.* The declaration against the use-site schedule: `timing`,
   `count`, `scope` and `quiescence`. Figure G7.
9. *Threads and sharing.* The nominal facts `sharing` and `isolation` against
   the per-call `executor`, `concurrency` and `reentrancy`.
10. *Lifecycles and patterns.* `lifecycle`, patterns, roles and the two core
    laws. Figure G6.
11. *Extending the language with profiles.*

**`explanation/packages.md`: ordered sections**

1. Page-one block.
2. *Four identities.* The semantic API, the source declaration, the access
   path, and the ABI or profile selection.
3. *What a package claims.* `surface`, `exports`, complete publication over a
   declared subset, and the dependency closure. Figure G2.
4. *Where it holds.* Exact environments and `available`, and why claims are
   exact rather than ranges.
5. *What it depends on.* Imports, digests and pinned catalogues.
6. *Reaching the code.* `access` with `abi`, `via`, `mapping` and
   `compatibility`. Figure G3.
7. *Profiles and ABI entries.* Providers and what a manifest must define.
8. *The synthetic fixture.* What F1 is and why the examples use it.
9. *One contract, several views.* Documentation and machine projections,
   drawing on `conformance.md`'s "Two views of one contract".

In the 2026-09-28 correction, open the package explanation with a small package
shell and the language model before *Four identities*. Use two explicitly named
packages to explain local versus imported declarations and their aliases. Place
a nominal declaration and its member side by side at package level; show the
`member` association, named receiver and references to callable slots. Reuse
G9 and the rule-reading examples where suitable. Thread the same names through
the explanation so new notation has an established referent. Apply the local
snippet/context check to all three concept pages, including their tables.

**`explanation/choices.md`: ordered sections**

1. Page-one block.
2. *How to read this page.* Domain constraint against language choice.
3. *A dedicated syntax,* against extending WIT or Swift interface syntax.
4. *Publishing a complete description.* Explain how a declared API subset and
   its dependencies establish the scope of the facts the author supplies.
5. *Stating the applicable facts.* Explain required clauses, optional facts
   and known absence accurately, then show the authoring burden with a real
   clause count from an example.
6. *Expressing ownership.* Compare draft 0.1 with the alternative ownership
   notation in a self-contained example. Explain what each expresses and the
   trade-off behind question Q3. Present the alternative as a design possibility;
   do not require the reader to reconstruct proposal history or an absent rationale.
7. *One clause syntax, with a closed vocabulary in prose.* What the grammar
   leaves to the rule tables, and what that costs discoverability.
8. *Describing exact environments.* Explain the declared configuration values
   and compare them with the version-range alternative.
9. *Profiles as the extension point.*
10. *Extending coverage beyond draft 0.1.* Explain what each pressure case
    requires, what the core already expresses and what additional provider or
    language support is needed. Keep the current limits explicit.
11. *Open questions.* The review-question register, seeded from audit Q1–Q6
    and extended by any session that finds an ambiguity. Each entry has an
    identifier, the question, where it arises, and why it matters.

**Model-first run (human direction, 2026-09-29).** Where this block and the
ordered lists above conflict, this block governs. The three pages become the
account of how AIL writes down the model in `model.md`; they stop teaching
the model from scratch.

**Example-led refinement (model-reading-k73).** Keep the located examples and
explain what they say about the API model. Omit elementary syntax narration,
including the punctuation walkthrough in *From signature to contract*.
Replace embedded G10 views with links to the relevant grammar-reference
section. Preserve the examples, AIL-specific meaning, rule links and semantic
figures G2–G7/G9. This applies to non-normative prose throughout the set,
including canonical aids, glossary entries and later reference/review pages.

The first draft of this run, concepts-k85, lands the grammar portion of
`reference/notation.md` (§9.4): the EBNF source and dialect, the eleven existing
G10 views with stable anchors and named productions, and links back to rules
and examples. It links the page from the landing map before a reference index
exists and replaces the canonical aids' G10 embeds with section links. The
remaining drafts own the explanations (k74–k75) and the canonical aids'
meaning-focused prose and model routes, plus glossary/landing adjustments
(k76). Copy-edit, art and proof cover this expanded document. Tutorial embeds
move to links in its already-queued run. Reference-k16 later extends the same
notation page with entry conventions and index routes, preserving its anchors.

*`explanation/contracts.md`, revised order.* Sections follow §10's concept
order for the call layer. Each section opens with the model concept (its
`model.md` name and link), the reader's task and a one-paragraph recall of
the concrete case, then keeps the existing pattern: two contrasting cases in
AIL, the principle, AIL's choice and its alternative, and the rule links.

1. Page-one block, whose *Before this* names the model page.
2. *From signature to contract* — operations and values: the declaration and
   clause shape, introduced as how AIL writes an operation's facts.
3. *Naming what a contract talks about* — operations and values: slots and
   places, introduced as how AIL points at the value an obligation concerns.
4. *Every way a call can end* — outcomes (moved forward, because returned
   ownership and validity are stated per outcome).
5. *Entities and their lifecycles* — entities: resource, object and record
   declarations, `lifecycle`, and figure G6. Member association and the named
   receiver stay taught in `packages.md`'s containment example; link it rather
   than teaching it twice. The patterns-and-laws material moves to follow
   *Callbacks* unless the draft shows it belongs here.
6. *Who owns what* — release responsibility. Figure G4.
7. *How long a borrow lasts* — validity. Figure G5.
8. *Buffers and strings* — storage.
9. *Threads and sharing* — execution.
10. *Callbacks* — callback schedules. Figure G7. Then *Patterns and laws*
    (entities: recurring arrangements), unless kept in section 5.
11. *Extending the language with profiles* — agreement and extension.

*`explanation/packages.md`.* Open with the description-layer concepts
(description; access; agreement): what a published description has to
establish about scope, identity, dependencies, environments and reaching the
code, recalled from `model.md` with the watch case. Then introduce the package
shell and G9 as how AIL organizes that description's text; keep *Packages
contain declarations* with its geometry/canvas model and reference table, now
as the language-model view serving the description concept. The later
sections keep their order and gain concept openings.

*`explanation/choices.md`.* *How to read this page* states the criterion the
human set: judge each language choice by how well it serves describing the
model and the reader's task. Each choice section names the model concept it
concerns and asks what the choice makes easy or hard for expressing and
inspecting that concept. Q1–Q6 and the domain/API/language separation stay.

*Canonical reading-aid routes.* A separate draft session of this run adds, on
`language.md`, `contracts.md` and `profiles.md`: the model page in each
page-one block's *Before this*, and a one-sentence model-concept route at the
start of each rule section's first reading aid (for example, "The rules below
express validity: how long …", with *validity* linked to
`explanation/model.md#validity`). It uses only the
existing bordered-aid convention and paired `reading-aid` comments, changes no
rule text, anchor or grammar, and reruns the canonical preservation check
against `87221b8c`. §9.7 records the convention.

The run keeps every existing example, figure source/SVG, anchor and incoming
link; G10 embeds move to the grammar reference. A renamed or reordered heading
gets an explicit anchor preserving its old slug. Moving a figure does not
remove the local example or the explanation of its meaning.

**Emphasis.** Honest trade-offs: an awkward construct is shown and named, not
hidden. Two examples for every concept, one taken from the conformance
examples wherever possible. Explanations do not restate rule force.
Develop the relationships in familiar language before using terms such as
dependency closure, resolution set, projection or compatibility domain. Review
the whole three-page set for the checkpoint's compression and framing defects,
including tables, summaries and figure surroundings. Preserve Q1–Q6 and the
separation between domain requirements, API choices and language choices.

**Non-goals.** No exhaustive clause coverage (that is the reference's job),
no tutorial steps and no review prompts. No proposed fixes for open
questions.

**Sources.** `language.md`, `contracts.md` and `profiles.md` (all rule
text); the three examples and `conformance.md`; the design proposal's §2 and
§4–§9; the survey's §4.1–§4.3; and the audit's F3, F5, F6 and Q1–Q6.

**Verification.** `docs:check` passes. Every normative claim cites a rule.
Every AIL block carries its label. Every choice section names at least one
alternative and one cost. Every question in the register cites where it
arises. After the model-first run: enumerate the construct introductions on
the three pages and in the canonical aids, and record for each the §10
concept it is tied to; every notation-introducing section links its concept
anchor before its first snippet; the canonical preservation check passes.
Walk the grammar links from a concept page, a canonical aid and the glossary;
all eleven G10 views are reachable with their named grammar productions.
Within this run's pages, G10 is embedded only in `reference/notation.md`;
familiar punctuation is not retaught in non-normative prose.

### 9.3 Tutorial

Pages: `tutorial/README.md` and five parts. Checkpoint packages are in
`examples/tutorial/`.

**Reader and outcome.** The primary reader, after the concept pages or
arriving directly with only the orientation. By describing one small synthetic
API step by step, they write and read a complete AIL package. After the final
part they can make a modest change and predict what else must change and which
rule decides. This is outcome 2.

**The API.** One new synthetic API, drafted in part 1. It differs on the
surface from the conformance examples, so each concept gets a second example
(survey D4). It uses only constructs that the normative text and the fixture
profile settle. If a design hits an unclear rule, the draft picks a supported
alternative and records the question in `explanation/choices.md`. Every
checkpoint is a complete package for a narrower declared `surface`, as the L3
subset rule allows. The subset narrows which APIs are described, never which
required clauses a described declaration carries. A2 requires `access` blocks
on every function, so every checkpoint from part 1 onward has them, with their
provider dependencies. Part 5 explains them; it does not introduce them.

**Ordered sections**

- `tutorial/README.md`: the page-one block; what you will describe and why;
  the five parts, each with its concept and checkpoint; and how to check your
  work without a validator.
- *Part 1: A package and one resource.* The header, `surface`, `exports`, the
  environment and synthetic pins; a uniquely owned resource; creation with a
  nullable result and two outcomes; destruction by consumption.
- *Part 2: Lending access.* An operation that borrows the resource and returns
  a borrow tied to its owner, with invalidation.
- *Part 3: Caller-supplied storage and failure.* An output buffer with
  `extent`, `contents`, `direction` and `aliasing`, and a success and failure
  partition with output states.
- *Part 4: Callbacks and teardown.* A callback declaration; registration with
  a schedule and owner scope; quiescent destruction; and `outside_callback`.
- *Part 5: Reaching the code, and changing the contract.* `access` blocks, the
  finished package, and a guided change: turn a borrowed result into an owned
  one, and trace every clause and rule the change touches.

Each part follows the same order:

1. Goal.
2. The domain obligation in one sentence, linked to its explanation.
3. Steps as conditions and imperatives.
4. The checkpoint package, labelled and checked by the example check.
5. Expected observations to verify by inspection.
6. Two or three check questions with answers, placed after the questions.
7. One labelled invalid variant, with its rule.

**Emphasis.** Each part develops its new concept and ends in a check (survey
D6). State what the reader will learn or change near the start and provide
direct links to the new material and the checkpoint. In part 5, make the
ownership exercise reachable before the repeated full package. Retain each
complete package so authoring burden remains inspectable. Explain each step's
reason at the length needed for comprehension and link to deeper discussion.
Use positive framing and concrete actors throughout; review the repeated
publication introductions, status text, example labels, tables and figure
surroundings under §4–§6. Local context should help someone entering that page
while allowing a continuing reader to find the new material quickly.

For the 2026-09-28 correction, each step introduces its construct with a short
explained excerpt before asking the reader to use it. Locate the excerpt within
the package or callable and connect it to the unchanged complete checkpoint.
Use the rule-reading language model when it explains the current task and link
to the grammar reference for railroad views. Preserve the existing access to
each part's new material and the
owned-snapshot exercise. Inspect all six pages, including the initial package
shell and the distinction between declaration references and local places.

**Model-first run (human direction, 2026-09-29).** The tutorial exercises the
model: each part applies named model concepts to the label-card API, and the
AIL is how the reader records them. Where this block and the lists above
conflict, this block governs.

- `tutorial/README.md`. *What you will describe* keeps its label-card story,
  now told as the model's entities and obligations (a card with a lifetime; a
  lent label; caller storage; a subscription and its teardown). The map table
  gains a column naming each part's model concepts, linked to their anchors.
  The index shell fragment follows the story, with a link to the grammar
  reference's shell view.
  *Before this* names the model page.
- Each part replaces *The domain obligation* with *The model*: the concept(s)
  the part applies, in the model page's words and linked, the concrete
  question about the label-card API they answer, and what the reader will be
  able to say at the checkpoint.
- Steps meet the model before the notation. Part 1 is the clearest case: the
  card's entity, its creation outcomes and its release responsibility come
  before the package's publication clauses and synthetic pins. The package
  shell appears as the enclosing context of the first located snippet; the
  step that writes `surface`, `exports` and the pins introduces them as the
  description concept (what this description publishes and depends on).
  Parts 2–5 already run concept-by-concept; there each step that introduces a
  construct names the concept it expresses. Part 5 introduces `access` as the
  access concept and keeps the owned-snapshot change framed as a change to
  release responsibility, traced through every clause and rule it touches.
- The complete checkpoint packages, their example files, the invalid variants
  and the tutorial figures' facts are unchanged. Step order, headings and
  explanatory prose may change; a renamed heading keeps its old slug through
  an explicit anchor. The early routes to each part's new material and to the
  owned-snapshot exercise remain.
- Apply model-reading-k73's example-led refinement to the index and all five
  parts: explain the AIL facts and their consequences, omit commentary on
  self-evident punctuation, and replace G10 embeds with links to the relevant
  section of `reference/notation.md`. Keep the snippets and semantic figures.

**Non-goals.** No installing, running or validating anything; no command
lines; no APIAnyware. No coverage of profiles beyond the fixture.

**Sources.** The rule files, the grammar, F1, and the conformance examples as
models; the survey's §4.3; and the audit's F7.

**Verification.** `docs:check` passes, and every checkpoint block matches its
file. Each checkpoint is checked by inspection against the grammar and every
applicable rule. The check notes are kept in the draft's leaf, not on the
page. Every invalid variant cites its rule. After the model-first run, the six
checkpoint files (`examples/tutorial/01-lifetime.ail` to `05-owned.ail`) are
byte-identical to their pre-run revision; `reading-fragments.ail` may gain or
reorder regions for relocated step snippets. Each step that introduces a
construct names and links its §10 concept. Grammar links resolve to the
reference sections, no G10 image remains embedded on a tutorial page, and
non-normative prose does not teach familiar punctuation.

### 9.4 Reference

Pages: `reference/README.md`, `notation.md`, `types.md`, `declarations.md` and
four `clauses-*.md` files (§2), plus verified context/lookup routes on normative
files and page-one blocks on supporting files.

**Reader and outcome.** Any reader looking up an exact fact, including the
secondary readers. Arriving from any link, they find the syntax, operands and
their types, where the clause applies, whether it is required, its
repeatability, its default ("none; required" where the draft has none), its
constraints and its rejection conditions. Each fact links to its canonical
rule. This is outcome 5.

**Entry fields,** in this order, for clauses (survey §4.5). Declaration and
type entries use the subset that applies.

1. Name, with an explicit anchor.
2. Expresses: the §10 model concept, linked to its `model.md` anchor, and a
   phrase saying which part of the concept this construct states ("the region
   bounding a returned borrow").
3. Form: its production and clause syntax.
4. Operands and their types.
5. Applies to.
6. Required or optional, and repeatability.
7. Default.
8. Meaning: a labelled non-normative summary with its rule identifier.
9. Constraints.
10. Rejected when: rule identifiers and mutation IDs.
11. Example: labelled, and drawn from the examples or tutorial.
12. Used by and see also: links both ways.
13. Rationale: a link to the explanation.

**Ordered sections**

- `reference/README.md`: how the reference is organised; which files are
  canonical; the model-concept index (each §10 concept, linked to `model.md`,
  with the entries that express it); the rule-identifier index; the
  mutation-to-rule index; and the alphabetical clause index.
- `notation.md`: a short pointer to the API model; the authoritative
  `grammar.ebnf` and its EBNF dialect; the eleven existing G10 views grouped
  by shell, clauses, names, callables, places, environments, patterns, outcomes,
  callback use, dependencies and access, each with a stable anchor and its
  named productions; how the generic `clause` production defers vocabulary to
  prose. These grammar sections land early in concepts-k85. The reference run
  extends this same page with the BCP 14 convention as `language.md` states it,
  that `README.md` names all three rule files and the grammar as normative, and
  that lowercase wording keeps its ordinary meaning and can still state a
  requirement. The page does not say lowercase text lacks force; it links the
  presentation question Q1 (audit F10). Then how to read an entry. The grammar
  description and railroad views remain together here; entries elsewhere
  show their form and examples and link to the relevant section. The page
  assumes language and railroad fluency and does not narrate punctuation.
- `types.md`: the core types and type constructors; value against reference
  types; and profile types.
- `declarations.md`: one entry per declaration kind and block, including
  package, import, `use`, environment, outcome, callback use and access, plus
  the clause-by-declaration applicability table.
- `clauses-*.md`: one entry per clause, grouped by scope, alphabetical within
  each file.
- Normative files: verify the context blocks and reading aids from §9.7,
  adding lookup routes to the reference with the rule text unchanged.
  Supporting files: add a page-one block each. `conformance.md`'s verification record gets a heading that marks
  it as a record.

**Emphasis.** Uniform fields and completeness against the enumerated
inventory, with links both ways. Each entry explains its operands and meaning
in complete, plain sentences; exact lookup still needs enough context to
understand the answer. Introduce specialized terms locally with links to fuller
explanations. State applicability, conditions and consequences directly. Apply
§4's positive framing and comprehension requirements to summaries, tables and
headings as well as entry prose; retain precise rejection conditions and rule
citations.

**Non-goals.** No new rules, no rewording of normative text, and no
resolution of open questions. No tutorials inside entries.

The 2026-09-28 requirements apply to each entry: give the introduced notation
an enclosing context and an explained short example. Reuse language-model
views where the relationships need them and link to `notation.md` for grammar
and railroad views, with local orientation for direct entry. The notation and
declaration entries must include local/imported declarations, a top-level member
and receiver, and declaration/slot/place references. Preserve the reading aids
already added beside the canonical rules; their examples and semantic
explanations remain local when the syntax figures move to the grammar reference.
Normative page-one blocks now land in §9.7; this increment verifies them and
adds links to the new reference entries.

Model-first (human direction, 2026-09-29): the reference is the exact-lookup
path, separate from the learning route, and consumes the model account rather
than restating it. Each entry's *Expresses* field names its concept in the
model page's words; the entry does not re-explain the concept beyond the local
context its answer needs. The concepts run lands the model-concept routes in
the canonical reading aids (§9.2, §9.7); this increment preserves them and adds
reference lookup routes beside them. `notation.md` introduces the grammar as
the text form of the model's declarations and clauses, after a short pointer
to the model page, and keeps G9 as the language-containment view.

**Sources.** The normative files, the grammar, `conformance.md` N01–N33, and
the survey's §4.5.

**Verification.** `docs:check` passes. `docs:coverage` (added here) passes
against the inventory, with every candidate classified (§7). Every "rejected
when" field cites a rule. A sample of entries is spot-checked against its rule
text, and every prose-defined clause named in audit F5 is confirmed to have an
entry. The disposition list records each entry-class item's §10 concept;
`docs:coverage` fails on an entry-class item with no concept or with a concept
that is not an anchor on `model.md`, and every §10 concept has at least one
entry or a recorded reason (for example, a concept expressed only by a
declaration's structure).

### 9.5 Review guide

Pages: `review/README.md`, `review/walkthroughs.md` and `review/tasks.md`.

**Reader and outcome.** The primary reader, who has taken the guided route or
arrives with orientation only. They can evaluate AIL along the six dimensions
in §1 and give feedback that cites examples and rules. This is outcome 4.

**Model-first framing (human direction, 2026-09-29).** The review question is
how well AIL serves as a tool for describing the model: the language is judged
by that job, not for its own sake. Each dimension is stated against the model:

- *Syntax and readability*: can a reader find, in a declaration, the facts for
  one model concept (say, validity) without reading unrelated clauses?
- *Conceptual consistency*: does each §10 concept have one recognisable form,
  and does one form ever mean two concepts?
- *Expressive scope*: which model concepts, and which variants of them (the
  refresh-invalidated view; cancellation with acknowledgement), can draft 0.1
  state, and which need a profile or a later version?
- *Authoring burden*: how many clauses does describing one concept cost, and
  which are repeated?
- *Discoverability*: starting from a model question ("who releases this?"),
  can the reviewer find the construct, and from a construct, its concept?
- *Fitness for producers and consumers*: can an analysis tool emit, and a
  binding generator or renderer recover, each concept's facts?

Every task starts from a model question about a named example (what must the
caller know, and when?) and then asks the reviewer to trace, change or judge
the AIL that answers it. Walkthroughs group each declaration's clauses by
model concept, naming and linking the concept at each group. `review/tasks.md`
gains a *Model fit* task: for one concept, list the constructs that express it
across the examples and judge the fit. The earlier task types below keep their
purposes.

**`review/README.md`: ordered sections**

1. Page-one block.
2. *What this review is for.* What feedback changes, and the draft's status.
3. *The six dimensions.* One subsection each: what it means for AIL, and
   prompts tied to specific examples and rules. The prompts invite criticism
   and ask what the reviewer would do differently.
4. *Recording feedback.* A short template: dimension, location (rule,
   example or page), observation, why it matters, and optionally an
   alternative.
5. *Known open questions.* A link to the register in
   `explanation/choices.md`.
6. *Limits.* No tooling, a synthetic fixture, and what cannot be tried.

**`review/walkthroughs.md`.** One section each for `buffers.ail`,
`callbacks.ail` and `objects.ail`:

- the purpose;
- a clause-by-clause reading of each declaration, grouped by obligation;
- the plain-language view;
- trace questions, with expected observations after them.

**`review/tasks.md`.** Self-contained tasks, each with a goal, conditions,
steps, expected observations and a feedback prompt:

- *Trace:* answer contract questions from a declaration.
- *Predict:* apply a mutation and name the rejecting rule.
- *Change:* add a parameter and list every clause it requires, or change a
  borrow to an owned result.
- *Compare:* the design sketch against draft 0.1.
- *Stretch:* take a pressure case and state what 0.1 lacks.
- *Author:* write the contract for a small C signature from
  `explanation/unsaid.md`, then count its clauses.
- *Model fit:* for one §10 concept, collect every construct that expresses it
  in the examples, and judge whether AIL states the concept clearly, once and
  completely.

**Emphasis.** The reviewer's real tasks, criticism-inviting prompts and
expected observations that can be checked by inspection.
State each task as a concrete action on a named example, explain the concepts
needed to attempt it, and develop the expected observation in ordinary language.
Keep language-design choices open to criticism. The human's first read found
compressed abstraction and negative framing before they could assess the
language; this guide applies §4's corrections to its prompts and explanations
and records the extent of a reader's progress honestly.

For the 2026-09-28 requirements, introduce every task's notation through a
small located snippet and, where helpful, the existing language-model view
before asking the reader to trace or change it. Explain what the example
records and why it matters; link to the grammar reference's railroad sections
for exact syntax, without embedding those views or narrating punctuation.
In walkthroughs,
show the clause beside the explanation with its enclosing declaration named.
Include concrete tasks distinguishing local/imported declarations and following
a member's owner and slots. Cite canonical rules and preserve the separation
between finding syntax, interpreting contracts and judging design choices.

**Non-goals.** No leading questions that presume the design is right, and
no invented tool output. No satisfaction ratings.

**Sources.** Every earlier document; `conformance.md`; the survey's §4.3 and
§4.4; and the cognitive-dimensions work cited there.

**Verification.** `docs:check` passes. Each task's expected observations are
checked against the rules. Every prompt cites something concrete.

### 9.6 Cross-set navigation and the Step 2 index

Pages: navigation edits across the set, and a closing section in the audit.

**Reader and outcome.** Every reader, from every entry point, can reach the
page answering their next question. The requester can see Step 2 as a whole
and trace each audit finding to its resolution.

**Ordered sections**

1. *Landing page.* The document map is completed, now that every page exists.
2. *Back-links.* "Used by" and "see also" links, in both directions, between
   rules, reference entries, explanations, tutorial parts and review tasks.
   Model routes run both ways too: each `model.md` concept section and its §10
   map row link the reference entries and review tasks that now exist, and
   each of those links back to its concept.
3. *Where next.* The footers are checked along the guided route.
4. *Glossary.* Completed against every term in use.
5. *Step 2: refactored output.* A section appended to the audit, listing the
   rewritten pages by path. It maps each of findings F1–F12 to the pages that
   resolve it, gives the status of Q1–Q6 and any added questions, and states
   what remains unresolved.

**Emphasis.** No page is orphaned and every link has a return path. Include the
rule-reading aids and the routes between model diagrams, syntax views, examples
and exact rules in the 2026-09-28 first-introduction checks. A direct rule entry
retains its local context when the final reference links are added. Walk the
model-first route (§3) end to end, and from each model concept to its notation,
tutorial part, rules and entries.

**Non-goals.** No new content pages and no rewording outside navigation,
except where a broken journey forces it.

**Verification.** `docs:check` passes. Every page has an inbound link from
the landing page's map or its parent index. The reviewer journey is walked
from each entry type in §3.

The final journey also checks model-reading-k73's syntax-lookup requirement:
the grammar description and all G10 embeds are in `reference/notation.md`;
concept, tutorial, canonical-aid, glossary and review entries link to its
relevant sections and retain their local examples and semantic context.

### 9.7 Reading the rules through examples and diagrams

Pages: non-normative additions within `language.md`, `contracts.md` and
`profiles.md`, their checked example fragments and figure sources/SVGs. The
grammar remains the source for syntax diagrams. The original rule-reading
increment added no reference page. Model-reading-k73's refinement moves the
G10 embeds to the grammar description in `reference/notation.md`, landed by
the concepts run before the aids link to it; local examples remain here.

**Reader and outcome.** The primary reader arrives directly at a rule or
follows a citation from the overview. They can place a newly introduced
construct in the language model, follow the example's names and syntax, and
then interpret the exact rule. In particular, they can distinguish a local
declaration from one in an imported package, identify a member at package
level and its nominal owner, and resolve declaration and callable-slot
references. This responds to `first-path-reading-k48` without requiring the
reader to wait for the indexed reference.

**Ordered work and section placement.**

1. Add the page-one context and an explicit convention distinguishing the
   preserved normative rule paragraphs from labelled reading aids. Keep
   additions bounded by identifiable markers so the original rule text can
   be recovered and compared with the pre-edit file. The visible boundary is
   a blockquote's left border, with a bold label and explicit stable anchors;
   the aid has no visible end marker.
2. At L1, introduce a small document/package shell, distinguish declarations
   from clauses, and link to the grammar views tied to `document`, `item`
   and `clause`. Explain the example's purpose and AIL-specific meaning;
   familiar punctuation is already visible in the snippet.
3. At L2, place G9 before notation depending on it. Use named packages and
   versions, a declaration in each, an import alias and reference uses. Explain
   local/imported relative to the package being read. Show the declaration
   identity tuple with its three concrete values, and source/access spellings
   separately. Show a nominal type and its member as top-level siblings,
   connected by `member`, and the ordinary receiver parameter. Locate
   `@name`, `@Alias::name`, `@operation::parameter`, `@operation::result`,
   callback slots and bare type names in those examples; contrast `@` references
   with `$` places in their enclosing callable. Show scope and collision rules
   with small valid/invalid cases. Link to the grammar views for `import`,
   `reference`, `name`, `callable`, `parameter` and `place` as needed, without
   claiming the grammar enforces semantic restrictions.
4. Continue through L3–L6 in rule order. Introduce environments, types,
   declarations, clauses, patterns and roles with small located examples.
   Existing complete examples remain available for the combined contract.
5. Apply the same treatment through C1–C8 and A1–A5/F1: slots/places/regions;
   lifetime and effects; buffers and outcomes; callback-use blocks; relations;
   provider references and access blocks. Introduce one relationship at a
   time, with enough enclosing context to read the snippet. Reuse existing
   examples and semantic figures where they answer the question; link to the
   grammar reference for syntactic choices.
6. Give each aid a route to its exact rule and fuller explanation, using only
   existing destinations. The later reference adds its lookup routes.
7. Model-first routes (human direction, 2026-09-29; landed by the concepts
   run, §9.2). Each page-one block's *Before this* names the model page. The
   first reading aid of each rule section opens with one sentence naming the
   §10 concept(s) its constructs express, linked to the `model.md` anchors; a
   section with no aid gets a short new one. These are ordinary bordered aids
   inside paired `reading-aid` comments, so
   the preservation check strips them like the rest.
8. Example-led refinement (model-reading-k73; landed by concepts-k85 and
   concepts-k76). Replace G10 embeds with links to their new grammar home,
   retain every local example and meaningful AIL explanation, and remove
   non-normative commentary on obvious punctuation. Preserve all rule text
   and anchors even where the normative wording itself discusses syntax.

**Emphasis.** The rule pages need local teaching support even when another
page teaches the same concept. Explain the example before combining it with
more syntax. Keep identifiers aligned across the model, railroad, snippets
and prose. Enumerate the construct introductions actually present in each
page and account for their local support in the draft's task notes; do not
equate the presence of a few illustrative figures with coverage of the set.

**Non-goals.** No change to the existing normative wording, rule identities,
grammar, fixture catalogue or supported semantics. No resolution of Q1–Q6,
parser, validator, production provider or tutorial exercise inside the rules.
An illustrative fragment is labelled as a fragment and states what context
is omitted. Any new package presented as complete must satisfy the full
existing contract, including byte-correct import pins; a placeholder digest
does not establish a valid import. Prefer existing complete examples and
clearly scoped fragments over expanding the fixture catalogue.

**Sources.** The current grammar and rule text, conformance examples, tutorial
packages, glossary and the human's verbatim feedback in `first-path-reading-k48`.

**Verification.** `task docs:check` passes. Added AIL fences match committed
source fragments. Every railroad path agrees with its named production, and
every semantic example is checked against its rule. Compare the preserved
normative text and grammar with the pre-edit version, separately from added
reading aids. Inspect semantic diagrams beside their examples and railroads
with their grammar description; walk a direct L2 entry, its syntax-lookup link
and the overview-to-rule route. These checks establish consistency; the human
assessments and their limits are recorded in §8.

### 9.8 The model account

Pages: `explanation/model.md` and figure G11 (source plus generated SVG), with
the routes to it from the landing page, the domain page and the glossary
(§9.1). Owned by the orientation document's model-first run.

**Reader and outcome.** The primary reader after *Using an API across
languages*, or arriving directly from a link to one concept. They can name
the entities an API description records and how they relate. For each
concept they can say which question it answers for a caller or tool, which
failure it prevents, and how it varies between APIs. They can tell the call
layer (what happens when a program uses the API) from the description layer
(what the published description establishes and how tools reach the code).
From the closing map they can find where AIL writes each concept down. This
is the first half of outcome 6 and the root brief's first completion
condition.

**Ordered sections**

1. Page-one block. *Before this:* *Using an API across languages*. *Rules:*
   the three rule files, cited per concept below.
2. *What the model is for.* The facts a caller or tool needs to use an API
   correctly, gathered into one account; AIL is a proposed notation for
   recording them. Recall the watch API in a paragraph, then name the two
   layers.
3. *The model at a glance.* Figure G11, then a prose walk through it in
   reading order that names every entity and relation. The prose carries
   every fact the figure shows.
4. One section per call-layer concept, in §10 order, each under an explicit
   anchor from §10: *operations and their values*, *how a call finishes*,
   *entities that outlive a call*, *release responsibility*, *validity*,
   *storage*, *where and when calls run*, *callbacks and their schedules*.
   Each section states the concept affirmatively; names its entities and the
   relations to concepts already introduced; recalls the watch case in a
   sentence or two and links the domain page's subsection for the failure;
   says what a caller or tool can decide once it knows this; and names the
   variants the model has to allow (unique or reference-counted release; an
   owner's lifetime or an earlier invalidating call; one invocation or many).
5. One section per description-layer concept, in §10 order: *the published
   description*, *reaching the code*, *writers, checkers and users*. The same
   pattern, using the landing page's workflow and the domain page's *A shared
   description for API tools* and *Reaching the code*.
6. *From the model to AIL.* The concept-to-notation map from §10 as a reader
   table: concept, what AIL writes (construct names in code font, no syntax
   lesson), where that notation is introduced (concept-page section and
   tutorial part, linked), and the canonical rules. Explain in a paragraph
   that the rest of the documentation introduces AIL in this order and that
   AIL's choices are judged by how well they serve this map, linking
   `choices.md`. The reference column is added by cross-set navigation.
7. *Where next.* *How AIL states a contract* on the guided route; the tutorial;
   and, for a direct notation entry, L1 and L2 with G9 described as the
   language-containment view.

**Emphasis.** The model comes before notation. Sections 2–5 show no AIL
snippets; a construct name appears only in the closing map. The page is a
synthesis, not a second domain page: it relates concepts the reader has met
and links the failure cases instead of re-teaching them. Keep §4's density
and positive-framing rules: explain one relationship, give its concrete case,
then build on it. Use the watch API's names throughout, and the prose's names
on G11's labels. Say plainly that the model explains what the rules describe
and is not itself normative; any mismatch found between the model and the
rules is an open question in `choices.md`, not a silent fix to either.

The §10 concept set and order are the contract. A draft may merge or split a
concept only with a recorded reason, and updates §10 and the anchors in the
same session. Once landed, concept anchors are stable citation targets like
rule identifiers.

**Non-goals.** No clause-by-clause coverage, syntax lesson or railroad view;
no new obligation beyond the rules; no resolution of Q1–Q6; nothing about
APIAnyware's internal pipeline.

**Sources.** `explanation/unsaid.md` and `README.md`; the rule files
(`L2–L6`, `C1–C8`, `A1–A5`); the design proposal's §2–§4; the existing figures
G1, G4–G7 and G9 for names and relations; the human's direction at
first-path-reading-k64 (D12–D13).

**Verification.** `docs:check` passes, including G11's regeneration. Every §10
anchor exists on the page and every concept section cites its rules. Every
construct named in the map appears in the rule text. Every "introduced in"
link resolves. Two direct entries at concept anchors are read for local
context. These checks establish consistency; `model-reading` owns the human
assessment of the account.

## 10. Model concepts and their notation

This table is the concept-to-notation contract for every document. Its concept
set and order are unchanged after model-reading-k73's positive assessment and
example-led presentation refinement; that read did not report full coverage
of the model page. The anchors are those on `explanation/model.md`.
"Introduced in" names the sections as
the model-first runs will leave them. The construct lists identify the main
forms for each concept; they are not the reference inventory, which
`docs:coverage` enumerates from the sources (§7). The domain-case column names
sections of `explanation/unsaid.md`.

| Anchor | Concept | Question it answers for a caller or tool | Domain case | Main AIL constructs | Notation introduced in | Rules |
|---|---|---|---|---|---|---|
| `operations` | Operations and their values | Which operations exist, what values pass in and out, and which value or storage does each fact concern? | *A small API* | `fn` and callable signatures; value types (`record` with `field`, `alias`, `enum`/`flags`, scalars and pointers); parameter, result and thrown-value slots; `@operation::slot` references; places `$p`, `.*`, `[]`, `.field` | `contracts.md` *From signature to contract* and *Naming what a contract talks about*; L2 aids; tutorial 1 | L4, L5, C1 |
| `outcomes` | How a call finishes | Which cases can the caller tell apart when the call ends, what does each mean, and which outputs are readable? | *What can the caller read when a call fails?* | `completions`, `outcome`, `when`, `null`/`nonnull`/`equal`/`range`, `meaning`, `state` | `contracts.md` *Every way a call can end*; tutorials 1 and 3 | C3, C5 |
| `entities` | Entities that outlive a call | Which values stand for something with its own identity and lifetime, how is each released, and which operations belong to it? | *Who is responsible for releasing a value?* (the watch handle) | `resource`, `object`, `interface`; `global`, `constant`, `property`; `lifecycle`; `member`, `receiver`; `pattern`, `role`, `instance`, `law` | `contracts.md` *Entities and their lifecycles* and *Patterns and laws*; `packages.md` member example; tutorial 1 | L4–L6, C2, C7 |
| `responsibility` | Release responsibility | Who must release this value, and does a call take, keep or hand back that duty? | *Who is responsible for releasing a value?* | `input` (`borrow`, `consume`), `retain`, `give` (`owned`, `borrow`) | `contracts.md` *Who owns what*; tutorials 1, 2 and 5 | C2, C3, C5 |
| `validity` | Validity | For how long may borrowed access be used, and which events end it early? | *How long can the caller use a view?* | `valid`; regions `call`, `static`, `owner(...)`; `invalidated_by`; `mutation` | `contracts.md` *How long a borrow lasts*; tutorial 2 | C1, C3, C5 |
| `storage` | Storage | How many elements exist, how much room is there, what do they contain, and who writes them? | *How many bytes exist, and what do they contain?* | `extent` (`one`, `buffer(...)`), `contents`, `direction`, `aliasing` | `contracts.md` *Buffers and strings*; tutorial 3 | C3, C4 |
| `execution` | Where and when calls run | Where may a call start, may calls overlap or nest, and where may references travel? | *Which calls may run together, and where?* | `execution`, `executor`, `concurrency`, `reentrancy`; `sharing`, `isolation` | `contracts.md` *Threads and sharing*; tutorial 4 | C2, C3 |
| `callbacks` | Callbacks and their schedules | When may a supplied function run, how often, with which state, and when is it safe to release that state? | *When is it safe to discard callback state?* | `callback` declarations; the callback-use block with `timing`, `count`, `scope`, `quiescence`; `outside_callback` | `contracts.md` *Callbacks*; tutorial 4 | C2, C6 |
| `description` | The published description | Which part and release of an API is described, which declarations and dependencies does it need, and in which configurations does it hold? | *A shared description for API tools* | `language`, `package`, `surface`, `exports`, `import … digest … as`, declaration identity, `environment`, `available`, `deprecated` | `packages.md` opening, *Packages contain declarations* to *What it depends on*; L1–L3 aids; tutorial 1 | L1–L3, L5 |
| `access` | Reaching the code | How does a tool call the implementation, under which machine-level rules, and what keeps the path compatible? | *Reaching the code* | `use abi` and `use profile` dependencies; `access … in`, `abi`, `via`, `mapping`, `compatibility`, `representation`, `callback_abi` | `packages.md` *Reaching the code* and *Profiles and ABI entries*; tutorial 5 | A1–A4, F1 |
| `agreement` | Writers, checkers and users | Who produces a description, what does checking establish, and how do consumers keep the same facts across presentations and extensions? | The landing page's workflow; *A shared description for API tools* | profile requirements; no single construct otherwise | `packages.md` *One contract, several views*; `contracts.md` *Extending the language with profiles* | L1, L3, C8, A1, A5 |

Order: the call layer runs from what a call is (operations, outcomes) to what
persists and who is responsible for it (entities, responsibility, validity,
storage), then to time and threads (execution, callbacks). *How a call
finishes* precedes release responsibility because returned obligations are
stated per outcome. The description layer follows, because its facts only
make sense once the reader knows what is being described.
