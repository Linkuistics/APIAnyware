# API Interface Language documentation plan

Status: planned 2026-09-23. This plan turns the
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
aesthetics and developer expectations, and who is new to API binding. They
read in order to evaluate AIL and give specific feedback.

**Secondary readers.** API authors and tool implementers, who need exact
lookup. The reference serves them without being written for them first.

**Outcomes.** These are taken from the root brief's completion conditions.
After the relevant documents, the primary reader can:

1. explain the problem AIL addresses, who produces and consumes AIL packages,
   and why declarations alone do not describe a binding contract;
2. follow a small worked example, read it, make a modest change and predict
   the consequences, without assuming a parser, validator or implementation;
3. tell domain constraints from AIL's own choices, and critique both, with
   the alternatives and limits in view;
4. evaluate the notation along six dimensions: syntax and readability,
   conceptual consistency, expressive scope, authoring burden,
   discoverability, and fitness for producers and consumers;
5. look up any clause, declaration kind, type or rule and find its exact
   syntax, operands, applicability, requiredness, constraints and rejection
   conditions.

**Not taught.** General programming, EBNF, type systems and closed
vocabularies. The reader knows these (survey §4.1, expertise reversal).

## 2. Page set and homes

All paths are relative to `semantic/specification/interface-language/`. The
normative and supporting files keep their current paths.

| Path | Title | Purpose | Reader question | Increment |
|---|---|---|---|---|
| `README.md` | API Interface Language | Landing page and orientation | What is this, what state is it in, and where do I start? | Orientation |
| `explanation/unsaid.md` | What a signature leaves unsaid | Domain explanation | Why is a declaration not enough to bind to an API? | Orientation |
| `glossary.md` | Glossary | Terms, with familiar-meaning warnings | What does this word mean here, and how does it differ from the meaning I know? | Orientation |
| `explanation/contracts.md` | How AIL states a contract | Explanation of the semantic core | How does AIL express each obligation, and why this way? | Concepts |
| `explanation/packages.md` | Packages, environments and access paths | Explanation of the package and provider boundary | What does a package claim, and how does a consumer reach the code? | Concepts |
| `explanation/choices.md` | Design choices, limits and open questions | Explanation of rationale and scope | What did AIL choose, instead of what, and at what cost? | Concepts |
| `tutorial/README.md` and `tutorial/01-…md` to `05-…md` | Describing a small API | Tutorial in five parts | Can I read, write and change a real AIL contract? | Tutorial |
| `examples/tutorial/*.ail` | — | Checkpoint packages | — | Tutorial |
| `reference/README.md` | Reference | Reference map and indexes | Where is the exact rule for this? | Reference |
| `reference/notation.md` | Reading the grammar and the rules | Reference: notation | How do I read the EBNF, rule identifiers and entries? | Reference |
| `reference/types.md` | Types | Reference entries | What does this type mean, and where may it appear? | Reference |
| `reference/declarations.md` | Declarations | Reference entries, plus the applicability table | What must this declaration contain? | Reference |
| `reference/clauses-*.md` | Clauses, grouped by scope | Reference entries | What does this clause take, where does it apply, and when is it rejected? | Reference |
| `review/README.md` | Reviewing AIL | How-to: evaluation and feedback | What should I judge, and how do I give useful feedback? | Review guide |
| `review/walkthroughs.md` | Reading the conformance examples | How-to: trace tasks on existing examples | What does each clause of these packages commit to? | Review guide |
| `review/tasks.md` | Review tasks | How-to: tasks with expected observations | How do I test the design against my own judgement? | Review guide |
| `figures/` | — | Diagram sources, generated SVGs and shared style | — | From Orientation |
| `language.md`, `contracts.md`, `profiles.md`, `grammar.ebnf` | (unchanged) | Normative rules, the one canonical source | — | Page-one blocks: Reference |
| `conformance.md`, `baseline.md`, `examples/*.ail` | (unchanged) | Conformance corpus; maintainer evidence | — | Page-one blocks: Reference |

The reference's clause files are split by the scope where a clause appears.
There are four files:

- package, environment and common declaration clauses;
- callable effects and input obligations, including buffers and strings;
- outcomes and callback use;
- access paths, patterns and the fixture profile.

The reference drafts may adjust this split if an entry count makes one file
unwieldy. They record the change in this section.

Page sizes follow the reader's questions, not a word budget. A page answers
one question at one level. A definition does not get its own page unless it is
a reference entry.

## 3. Reader journeys

**The guided route:** landing page, then *What a signature leaves unsaid*,
then the three concept pages, then the tutorial, then the review guide. The
reference is consulted along the way, not read through. Every page ends with
where to go next on this route.

**Direct entries.** Each needs its own route back:

- **From a rule** (a review comment cites C6). The normative page's page-one
  block names the explanation that motivates the rules and the reference
  entries that index them.
- **From an example** (a link to `buffers.ail`). The walkthrough explains the
  example, and the landing page lists all examples with their purpose.
- **From a term** (a search for *quiescence*). The glossary entry links to its
  defining page and to the rules that use it.
- **From a reference entry.** Each entry links to its rule, to its
  explanation and to examples that use it.

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
- Where a document's index lands after its pages (the review guide's
  `review/README.md`), the map links the earlier pages directly until the
  index lands and takes over.

Cross-set navigation (§9.6) then completes the map, the back-links and the
footers. It is never the first point at which a page becomes reachable.

## 4. Prose contract

One contract serves the whole set. It is the charter for `copy-edit` and the
standard for `draft`. These rules are defaults with stated exceptions, not
metrics (survey §6).

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
  showing the clause that states it. Every analogy to Rust, Swift, C++ or C
  says where it fails.
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
- **Status.** Use one wording everywhere for the draft's state: "draft 0.1, a
  proposal under review; no parser, validator or implementation exists". Say
  "synthetic" for the fixture profile, catalogue and digest tokens every time
  they appear in an example's surroundings.
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

Every page except the normative files opens with this block. The normative
files get it in the reference increment, with their rule text unchanged.

```markdown
> **Purpose:** <form> — <one sentence on what this page is for>.
> **Reader:** <who, and what they already know>.
> **Before this:** <links to prerequisite pages, or "nothing">.
> **Status:** draft 0.1, a proposal under review; no parser, validator or
> implementation exists.
> **Rules:** the canonical rules are <links to the rule identifiers>.
```

Every AIL code block carries one label, immediately before the fence:

- **Complete package:** "Complete package — admitted by the grammar and
  complete under draft 0.1, checked by inspection." The block is a whole
  `.ail` file, or a region of one, kept in step by the example check (§7).
- **Fragment:** "Fragment — omits <what>; not a publishable package." Say
  what is omitted.
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

**Visual vocabulary.** All three notations render the same vocabulary. The
first `art` session defines it once, as shared style files under
`figures/style/`, and every later figure reuses them:

- one shape per role: producer, package, catalogue (profile or ABI entry),
  validator, consumer, caller, callee and owner;
- one line style per relation: ownership transfer (solid), borrow (dashed),
  invalidation (a marked end) and callback entry (dotted);
- colour only as a redundant cue, never the only one;
- the prose's names on every element, and a key on every diagram.

The shared vocabulary is now defined in
[`figures/style/vocabulary.txt`](../../specification/interface-language/figures/style/vocabulary.txt),
with PlantUML role macros in
[`figures/style/ail.puml`](../../specification/interface-language/figures/style/ail.puml).
G1 and G4 use PlantUML. `task docs:diagrams` compares regenerated SVG bytes;
`task docs:diagrams:write` explicitly updates them. The check also supports the
pinned D2 renderer; Mermaid needs a pinned renderer added before first use.

| ID | Level | Question it answers | Kind | Home |
|---|---|---|---|---|
| G1 | Context | Who writes AIL packages, what do they depend on, and who reads them? | C4 system context | Landing page; reused as the map on explanation pages |
| G2 | Package | What does a package contain and pin? | Structure, class-style | `explanation/packages.md` |
| G3 | Access | How does one operation reach code through two access paths and an ABI entry? | Structure | `explanation/packages.md` |
| G4 | Contract | What moves between caller and callee when a call borrows, consumes, or gives an owned value? | Sequence | `explanation/unsaid.md`, `explanation/contracts.md` |
| G5 | Contract | How long is a borrowed result valid, and what ends it? | Timing | `explanation/contracts.md` |
| G6 | Contract | What states does a uniquely owned resource pass through? | State | `explanation/contracts.md` |
| G7 | Contract | When may a registered callback run relative to registration and quiescent teardown? | Timing or sequence | `explanation/contracts.md`, tutorial part 4 |
| G8 | Navigation | Which page answers which question? | Table, not a diagram | Landing page |

The drafts decide which figure slots a page needs and record each unfilled
slot in the document node's handed-forward list for `art`. Prose carries every
fact that a figure shows.

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
    not vocabulary, with a one-line reason.
  - The check fails on an unclassified candidate, on an entry-class item with
    no entry in its file, and on a disposition naming nothing the sources
    contain. An entry owned by a reference session that has not yet run is
    reported as pending, by name, and a pending item in a file that has landed
    is a failure.

  The candidate extraction is a lexical sweep. It does not parse AIL and does
  not decide what is a clause; the disposition list records that judgement,
  and it is reviewed against the rule text like any entry.

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

## 9. Structure briefs

Each brief states the reader and outcome, the ordered sections with the
purpose of each, the emphasis and non-goals, the sources and the verification.
Sections may merge or split during drafting when the reader's questions demand
it. The order holds unless the draft records why it changed.

### 9.1 Orientation

Pages: `README.md`, `explanation/unsaid.md` and `glossary.md`.

**Reader and outcome.** The primary reader, arriving with no context. After
these pages they can state what AIL is and its status. They can name the
binding obligations a signature leaves unstated and the failure each one
prevents. They can say who writes and reads AIL, and choose a path through the
documentation. This is outcome 1 in §1.

**`README.md`: ordered sections**

1. *What AIL is.* Two sentences: AIL is a proposed language for writing down
   the complete binding contract of an existing API, once, for every consumer.
   Then the status line.
2. *Who this documentation serves.* The primary and secondary readers, and
   the kind of feedback wanted: specific, tied to examples and rules, and
   critical where warranted.
3. *The problem in brief.* One paragraph and figure G1. Producers are human
   authors, analysers and third-party tools. The consumers are binding
   generators, documentation renderers and LLM tooling. Validation sits
   between them. This section links to `explanation/unsaid.md`.
4. *Paths through the documentation.* A table (G8) with rows for "if you want
   to …" and "start at …", covering understanding, learning, reviewing and
   looking up.
5. *What is normative.* Which files are canonical, what the other pages are,
   and the rule-identifier scheme.
6. *Scope of draft 0.1.* The current scope and limits, kept from the existing
   README's scope section, with a link to `explanation/choices.md`.
7. *Design history.* Links to the design proposal, the survey, the audit and
   this plan.

**`explanation/unsaid.md`: ordered sections**

1. Page-one block.
2. *A small API.* A synthetic C header of about three functions: create and
   destroy a handle, return a borrowed view, and register a callback with a
   context pointer. It is written in C, because the reader can read C and C
   leaves every question unstated.
3. *What the header does not say.* One subsection per obligation, each giving
   the question, what a binding that guesses gets wrong, and the domain term:
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
4. *Why the signature cannot be the contract.* Declarations describe shape,
   not obligations. Each consumer (a binding generator, a documentation
   renderer, an LLM) would otherwise re-derive or guess the obligations. One
   authoritative contract serves all of them.
5. *Reaching the code.* ABI, calling convention, access path (symbol, message
   send, source-compiled call), projections, and profiles and providers, in
   domain terms first.
6. *What your language-design knowledge covers, and where it misleads.* The
   familiar-term warnings for *borrow*, *owned*, *consume*, *shared*, *copy*,
   *profile* and *closure*.
7. *Where next.* Links to the concept pages and the tutorial.

**`glossary.md`.** Alphabetical entries. Each entry gives the term, a
one-sentence definition, the defining page, the rules that use it, and a
familiar-meaning warning where one applies. It covers the domain list from the
root brief and every AIL term used on the orientation and concept pages.

**Emphasis.** Concrete failure before abstraction, and domain obligations
before any AIL syntax. The landing page is short: a newcomer should reach the
domain page within one screen.

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
draft 0.1 cannot express. These are outcomes 2 (in part) and 3.

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
11. *What the core leaves to profiles.*

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

**`explanation/choices.md`: ordered sections**

1. Page-one block.
2. *How to read this page.* Domain constraint against language choice.
3. *A dedicated syntax,* against extending WIT or Swift interface syntax.
4. *Complete contracts only.* There is no partial or confidence mode.
5. *Everything explicit.* No defaults, explicit known absence, and the cost
   in authoring burden, shown with a real clause count from an example.
6. *Ownership in clauses, not types.* Put the design proposal's sketch beside
   draft 0.1. The rationale is unrecorded: say so and link question Q3.
7. *One clause syntax, with a closed vocabulary in prose.* What the grammar
   leaves to the rule tables, and what that costs discoverability.
8. *Exact environments,* not version ranges.
9. *Profiles as the extension point.*
10. *What draft 0.1 cannot express.* The pressure cases, and the expected
    refusal.
11. *Open questions.* The review-question register, seeded from audit Q1–Q6
    and extended by any session that finds an ambiguity. Each entry has an
    identifier, the question, where it arises, and why it matters.

**Emphasis.** Honest trade-offs: an awkward construct is shown and named, not
hidden. Two examples for every concept, one taken from the conformance
examples wherever possible. Explanations do not restate rule force.

**Non-goals.** No exhaustive clause coverage (that is the reference's job),
no tutorial steps and no review prompts. No proposed fixes for open
questions.

**Sources.** `language.md`, `contracts.md` and `profiles.md` (all rule
text); the three examples and `conformance.md`; the design proposal's §2 and
§4–§9; the survey's §4.1–§4.3; and the audit's F3, F5, F6 and Q1–Q6.

**Verification.** `docs:check` passes. Every normative claim cites a rule.
Every AIL block carries its label. Every choice section names at least one
alternative and one cost. Every question in the register cites where it
arises.

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

**Emphasis.** Short parts, each ending in a check (survey D6). The full clause
burden stays visible at every checkpoint, because authoring burden is under
review. Rationale is a one-line reason and a link.

**Non-goals.** No installing, running or validating anything; no command
lines; no APIAnyware. No coverage of profiles beyond the fixture.

**Sources.** The rule files, the grammar, F1, and the conformance examples as
models; the survey's §4.3; and the audit's F7.

**Verification.** `docs:check` passes, and every checkpoint block matches its
file. Each checkpoint is checked by inspection against the grammar and every
applicable rule. The check notes are kept in the draft's leaf, not on the
page. Every invalid variant cites its rule.

### 9.4 Reference

Pages: `reference/README.md`, `notation.md`, `types.md`, `declarations.md` and
four `clauses-*.md` files (§2), plus page-one blocks on the normative and
supporting files.

**Reader and outcome.** Any reader looking up an exact fact, including the
secondary readers. Arriving from any link, they find the syntax, operands and
their types, where the clause applies, whether it is required, its
repeatability, its default ("none; required" where the draft has none), its
constraints and its rejection conditions. Each fact links to its canonical
rule. This is outcome 5.

**Entry fields,** in this order, for clauses (survey §4.5). Declaration and
type entries use the subset that applies.

1. Name, with an explicit anchor.
2. Form: its production and clause syntax.
3. Operands and their types.
4. Applies to.
5. Required or optional, and repeatability.
6. Default.
7. Meaning: a labelled non-normative summary with its rule identifier.
8. Constraints.
9. Rejected when: rule identifiers and mutation IDs.
10. Example: labelled, and drawn from the examples or tutorial.
11. Used by and see also: links both ways.
12. Rationale: a link to the explanation.

**Ordered sections**

- `reference/README.md`: how the reference is organised; which files are
  canonical; the rule-identifier index; the mutation-to-rule index; and the
  alphabetical clause index.
- `notation.md`: the EBNF dialect; how the generic `clause` production
  defers vocabulary to prose; the BCP 14 convention as `language.md` states it,
  that `README.md` names all three rule files and the grammar as normative, and
  that lowercase wording keeps its ordinary meaning and can still state a
  requirement. The page does not say lowercase text lacks force; it links the
  presentation question Q1 (audit F10). Then how to read an entry.
- `types.md`: the core types and type constructors; value against reference
  types; and profile types.
- `declarations.md`: one entry per declaration kind and block, including
  package, import, `use`, environment, outcome, callback use and access, plus
  the clause-by-declaration applicability table.
- `clauses-*.md`: one entry per clause, grouped by scope, alphabetical within
  each file.
- Normative and supporting files: a page-one block each, with the rule text
  unchanged. `conformance.md`'s verification record gets a heading that marks
  it as a record.

**Emphasis.** Uniform fields and completeness against the enumerated
inventory, with links both ways. Austere prose.

**Non-goals.** No new rules, no rewording of normative text, and no
resolution of open questions. No tutorials inside entries.

**Sources.** The normative files, the grammar, `conformance.md` N01–N33, and
the survey's §4.5.

**Verification.** `docs:check` passes. `docs:coverage` (added here) passes
against the inventory, with every candidate classified (§7). Every "rejected
when" field cites a rule. A sample of entries is spot-checked against its rule
text, and every prose-defined clause named in audit F5 is confirmed to have an
entry.

### 9.5 Review guide

Pages: `review/README.md`, `review/walkthroughs.md` and `review/tasks.md`.

**Reader and outcome.** The primary reader, who has taken the guided route or
arrives with orientation only. They can evaluate AIL along the six dimensions
in §1 and give feedback that cites examples and rules. This is outcome 4.

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

**Emphasis.** The reviewer's real tasks, criticism-inviting prompts and
expected observations that can be checked by inspection.

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
3. *Where next.* The footers are checked along the guided route.
4. *Glossary.* Completed against every term in use.
5. *Step 2: refactored output.* A section appended to the audit, listing the
   rewritten pages by path. It maps each of findings F1–F12 to the pages that
   resolve it, gives the status of Q1–Q6 and any added questions, and states
   what remains unresolved.

**Emphasis.** No page is orphaned and every link has a return path.

**Non-goals.** No new content pages and no rewording outside navigation,
except where a broken journey forces it.

**Verification.** `docs:check` passes. Every page has an inbound link from
the landing page's map or its parent index. The reviewer journey is walked
from each entry type in §3.
