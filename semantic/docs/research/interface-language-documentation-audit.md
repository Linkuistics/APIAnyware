# API Interface Language documentation: structural and style audit

Step 1 of the documentation rework: the linting and structural audit that
comes before any rewriting. Audited 2026-09-23 at revision `1c4b8e7ec3da`.
Line references below are to that revision. Step 2, the rewritten
documentation, is planned in the
[documentation plan](../design/2026-09-23-interface-language-documentation-plan.md).

The audit reads the material as its primary reader would. That reader knows
language design, notation aesthetics and what developers expect. The reader
does not know API binding: FFI, ABI, ownership transfer, borrow validity,
quiescence, access paths, projections or profiles. The reader's purpose is to
evaluate draft 0.1 and give feedback on it, not to use the language. The
evidence base for the criteria is the
[documentation-basis survey](documentation-basis-a.md). The survey's §7 lists
first observations, and this audit extends and checks them.

## Summary

- **No page introduces the domain.** Every page assumes the reader already
  knows why a signature is not enough. "FFI" and "binding" are never defined.
  The README uses *access path*, *ABI*, *profile* and *provider* in its first
  28 lines. None of those terms is defined before `profiles.md`, and
  *provider* is never defined at all (F1, F2).
- **Explanation is missing, and it is not simply dispersed.** The
  specification states rules with almost no reasons. The rationale in the
  design proposal sits outside the reading path. Its open question on
  ownership, whether it belongs in types or in clauses, was settled in favour
  of clauses by draft 0.1, and no document records why (F3).
- **Purposes are mixed on every non-normative page.** `conformance.md` holds
  eight kinds of material for three different readers. `baseline.md` maps
  APIAnyware's Rust structs to rules, and it is fourth in the reviewer's
  reading order (F4).
- **Reference lookup needs cross-file assembly.** The grammar leaves the whole
  clause vocabulary to prose tables in three files. A minimal function needs
  clauses from five sections across three files, and nothing lists them
  together (F5).
- **Density is high where the concepts are newest.** Single table cells in
  `contracts.md` hold up to six sentences of rules. Slash compounds stand in
  for distinctions the reader has not yet met (F6).
- **The examples are complete but unannotated.** Their meanings live in a
  separate table. Of the documentation forms, only failure cases already
  exist, as the rejection mutations (F7).
- **Normative force is ambiguous in two ways.** Lowercase *must* appears 64
  times across the three normative files, and only `language.md` states the
  keyword convention. The audit surfaces this as a question for the language,
  not a presentation fix (F10, Q1).
- **Much is worth keeping.** The honest status statements, the synthetic
  labelling, the stable rule identifiers, the mutation table, the pressure
  cases and the "Two views of one contract" passage are what reviewers need,
  and the rework keeps them (§3).

## 1. Inventory and purposes

Every file below was read in full. The compass answer is the Diátaxis purpose
the page actually serves; "mixed" lists each purpose found.

| File | Lines | Current purposes | Reader it assumes | Disposition |
|---|---|---|---|---|
| `specification/interface-language/README.md` | 60 | Status; publication principles stated as facts; normative reading order; scope and limits; design links | A binding-tool author who knows APIAnyware's analysis pipeline | Rewrite as the landing page. Keep the status and scope statements |
| `language.md` (L1–L6) | 213 | Reference: lexical rules, identity, publication, types, declaration clauses, patterns | A specification implementer | Keep as normative. Add a page-one block and stable anchors; its content does not change |
| `contracts.md` (C1–C8) | 244 | Reference, with fragments of explanation (for example lines 88–95) | An implementer who knows ownership and threading | Keep as normative. Explanatory fragments are summarised in explanation pages, linked to their rules |
| `profiles.md` (A1–A5, F1) | 198 | Reference (provider boundary); test-data specification (F1) | An implementer who knows ABIs and runtimes | Keep as normative. F1 is signposted as fixture data |
| `grammar.ebnf` | 49 | Reference | A reader of EBNF who knows the dialect | Keep. A notation page explains how to read it and what it leaves to prose |
| `baseline.md` | 192 | Migration evidence mapping APIAnyware's Rust IR to rules | An APIAnyware maintainer | Keep, off the reviewer's path. It is linked as evidence for expressive scope |
| `conformance.md` | 188 | Example interpretations; rejection mutations; runtime tests to write later; pressure cases; two views of one contract; parser obligations; verification record | Future implementers, reviewers and the drafting session's own audit trail | Keep the acceptance material. The explanation and reference pages draw on the example, pressure-case and two-views material, linked back. The verification record is labelled as a record |
| `examples/buffers.ail`, `callbacks.ail`, `objects.ail` | 149, 98, 123 | Complete positive packages | A reader who already knows every clause | Keep unchanged as the canonical conformance inputs. Annotated walkthroughs are added beside them |
| `docs/design/2026-09-22-interface-language.md` | 439 | Explanation: requirements, alternatives, identities, semantic model and syntax direction. Partly historical (its syntax sketch predates the grammar) | A reviewer of the architecture | Keep as the record of the design. Its alternatives and open questions feed the design-choices page |
| `docs/research/2026-09-22-interface-language-a.md` | 197 | Research evidence | A design reviewer | Keep. Linked from rationale |
| `docs/README.md` | 38 | Entry link to the draft (line 24) | A semantic-domain contributor | Keep the link. Its target becomes the landing page |

## 2. Findings

Each finding gives the evidence, what it costs this reader, and a class:
**presentation** (the rework fixes it) or **language** (it becomes a review
question in §4 and is not silently fixed). The disposition names the planned
document that resolves it.

### F1. No domain introduction (presentation)

- **Evidence.** No page says what an API binding is, why a foreign-function
  interface needs more than a signature, or what fails when an obligation is
  unstated. A whole-word search finds no `FFI` anywhere in the
  specification. *Binding* first appears at `README.md:15` as a consumer of
  "the same contract", with nothing before it. The README's second paragraph
  (lines 7–11) begins with publication obligations and "confidence scores".
  Those only make sense to someone who knows APIAnyware's analysis pipeline.
- **Cost.** The reader cannot tell the domain constraints that any notation
  must express from the choices AIL makes. Without that distinction, the
  review cannot separate "the problem is hard" from "this design is heavy".
- **Disposition.** A domain explanation built on one small signature, before
  any AIL syntax: *What a signature leaves unsaid*.

### F2. Terms used before they are defined, or never defined (presentation)

- **Evidence.** First uses of each term, from a line-number search with
  whole-word checks:
  - *access path*: `README.md:13` (defined in `profiles.md` A2, line 38);
  - *ABI*: `README.md:14` (defined in A1, line 26);
  - *profile*: `README.md:21` and `language.md:28` (defined in A1, line 9);
  - *slot*: `language.md:42` (never defined as a term; C1 describes place
    syntax only);
  - *provider*: `README.md:28` and `language.md:49`, used as an umbrella for
    profile and ABI entries but never defined.
  - *Quiescence* is explained only inside the `quiescence(...)` row of the C6
    table (`contracts.md:205`).
- **Collisions.** *Closure* means a dependency closure (`README.md:51`,
  `language.md:58`, `language.md:73`) and a callback's captured environment
  (`contracts.md:42–44`). *Borrow*, *owned*, *consume*, *shared*, *copy* and
  *profile* collide with Rust, Swift or everyday meanings. No page warns the
  reader.
- **Cost.** Survey §4.1: prior knowledge that looks relevant can distort new
  learning, and an expert cannot predict a novice's difficulty.
- **Disposition.** A glossary with a "familiar term, different meaning" note
  for each collision. Each concept gets one defining page, with its first use
  on each page linked. The two senses of *closure* are listed under Q2.

### F3. Missing rationale and alternatives (presentation, one language gap)

- **Evidence.** The normative pages contain rules without reasons. Examples
  are the exact-environments rule (L3), the absence of defaults (L3, C8) and
  explicit known absence such as `isolation(none)` (L3, lines 96–97). The
  design proposal's alternatives table (§2) and its syntax principles (§7)
  are linked only under "Design basis" at the end of the README. §7 says
  "Whether ownership appears principally in types or contract clauses needs a
  corpus-backed decision". Draft 0.1 chose clauses (`ptr<T>` carries no
  ownership, L4), and a search of the specification and the specification
  plan finds no record of that decision or its reasons.
- **Cost.** A reviewer judging the design needs the alternatives and the
  trade-off, and the most visible stylistic choice has no stated rationale.
- **Disposition.** A design-choices explanation page covering each major
  choice, its alternatives and its costs. The missing ownership rationale
  becomes review question Q3; the documentation does not invent a reason.

### F4. Mixed purposes and reading order (presentation)

- **Evidence.** `conformance.md` holds eight kinds of material (§1 table). Its
  pressure cases (lines 87–106) are the best statement of AIL's expressive
  limits, but they sit between runtime-test plans and a JSON projection. The
  README's reading order (lines 17–23) sends reviewers through `baseline.md`
  fourth. That page is a field-by-field mapping of Rust structs
  (`ir.rs`, `type_ref.rs` and five more) that a language reviewer cannot use.
  The verification record (lines 163–188) is process history inside a reader
  page.
- **Disposition.** Navigation by the reviewer's journey. The explanation and
  review pages use the pressure-case and two-views material with a link back
  to its source. `baseline.md` is linked as maintainer evidence. The
  verification record is kept and labelled as a record.

### F5. Lookup requires assembling rules across files (presentation)

- **Evidence.** `grammar.ebnf:37` admits any `name(...)` as a clause, so the
  closed vocabulary exists only in prose tables in `language.md` L5,
  `contracts.md` C2–C7 and `profiles.md` A2 and F1. Consider what a minimal
  public function requires:
  - `available` (L3) and `deprecated` (L5);
  - seven effect clauses (C3), plus `input`, `retain` and `valid` per
    reference leaf (C3) and `direction`, `aliasing`, `extent` and `contents`
    per pointer (C3, C4);
  - one or more outcomes with `when` and `meaning`, and with `state`, `give`
    and `invalidated_by` as applicable (C5);
  - a `callback` block per callback parameter (C6);
  - one or more `access` blocks, each with four clauses (A2).

  That is five sections in three files, and no page lists them together. Rule
  identifiers are section-level (L1–L6, C1–C8, A1–A5, F1), and their only
  anchors come from heading text. `conformance.md:5` already depends on one
  (`profiles.md#f1-synthetic-fixture-catalogue`), which breaks if the heading
  is reworded.
- **Cost.** Discoverability and authoring burden are review targets, and the
  documentation should make them visible for inspection, not reproduce them
  as a burden.
- **Disposition.** A reference with fixed-field entries for each clause and
  declaration kind, a clause-by-declaration applicability table, and indexes
  (rules, mutations to rules, alphabetical clauses). Rule identifiers get
  explicit anchors. The need for a single applicability table is itself
  reported to reviewers as evidence about the language's discoverability.

### F6. Density at the point of highest novelty (presentation)

- **Evidence.** Some single table cells in `contracts.md` hold four to six
  sentences of distinct rules, including the rows for `lifecycle(unique)`
  (line 51), `completions` (74), `retain` (81) and `give` (174). Many prose
  sentences compress distinctions into slash compounds, such as
  "declaration/import/environment/provider aliases" (`language.md:49`) and
  "Resource/object/interface" (`contracts.md:52`). Such compounds occur 21
  times in `contracts.md` prose and 23 times in `profiles.md` prose, outside
  tables and code. Many rules deny a misreading the reader has never met:
  "not a placeholder for missing analysis" (`README.md:10–11`) and "not
  whether a binary actually honours the author's assertions"
  (`language.md:98–99`).
- **Cost.** A reference entry may be terse. A first explanation must not be.
  The reader meets the terse form first because no explanation exists.
- **Disposition.** The normative text stays terse. The explanation pages
  teach each concept through two contrasting cases before stating its rule
  (survey D7). Their prose follows the style guide in the plan.

### F7. Examples are complete but unexplained (presentation)

- **Evidence.** The three examples contain no comments and one `doc(...)`
  clause each. `view` in `buffers.ail:72–100` appears as a run of fourteen
  clauses, an outcome block and an access block. Its meaning is in
  `conformance.md:13`, a different file. There is no smaller example, no
  progression, and no example whose purpose is teaching. The fixture profile
  and digest tokens are labelled as synthetic (`profiles.md` F1,
  `conformance.md:3–7`), and the rework keeps those labels.
- **Assets.** Mutations N01–N33 (`conformance.md:31–65`) are failure pairs
  that already cite rules. "Two views of one contract" (`conformance.md:108–138`)
  renders `view` in five plain sentences, which is the target explanation
  style.
- **Disposition.** A tutorial on a new synthetic API, whose checkpoints are
  complete packages for a narrower declared surface. L3 and `README.md:48–51`
  permit a named subset with its whole dependency closure. Annotated
  walkthroughs of the three existing examples go in the review guide. The
  guide's failure exercises use the mutations, each citing its rule. No page
  shows validator output, because no validator exists.

### F8. Navigation is one-way and linear (presentation)

- **Evidence.** The README links to every page. Among the normative pages,
  `language.md` links to the grammar, contracts and profiles; `contracts.md`
  links only to A4; `profiles.md` links only to research. No page links back
  to the README or says where it sits in the set. A reader arriving from a
  search or a review comment at `contracts.md` C6 finds no orientation.
- **Disposition.** Every page gets a page-one block giving its purpose,
  reader, status, prerequisites and canonical rule source, plus a document
  map on the landing page.

### F9. Links outside the repository (accuracy)

- **Evidence.** All seven source links in `baseline.md:11–17` point to
  `../../../../APIAnyware.add-ocaml-target/`. That is a sibling checkout
  outside this repository. It resolves on the author's machine only, and is
  broken on GitHub and in any fresh clone. `conformance.md:170` cites a
  script under `/private/tmp`, and says honestly that it is a disposable
  script.
- **Disposition.** The documentation-foundation increment replaces the links
  with plain-text paths that name the workspace holding the files, so no link
  leaves the repository. It does not reproduce the source files.

### F10. Normative-force signals are inconsistent (language question)

- **Evidence.** `language.md:3–4` defines **MUST**, **MUST NOT**, **SHOULD**
  and **MAY** for "this draft". `contracts.md` and `profiles.md` do not
  restate the convention. The three normative files use uppercase keywords
  25, 10 and 5 times, and lowercase *must* or *should* 9, 32 and 23 times.
  Many of the lowercase uses are plainly requirements, as in "All referenced
  declarations must exist" (`language.md:72`). Under RFC 8174, only
  uppercase keywords carry the defined meaning.
- **Disposition.** This is not rewritten under an editorial mandate: changing
  the case of a word changes its normative force. It is recorded as Q1 for
  the language's authors. Until they answer, explanation pages cite the rule
  and do not restate its force.

### F11. No figures where relations are hardest (presentation)

- **Evidence.** The specification has no diagrams. The design proposal has
  one Mermaid flowchart of the publication boundary (§3). Ownership transfer,
  owner-dependent borrow validity, outcome partitions and callback schedules
  are sequences and lifetimes. The text states them only in prose and tables.
- **Disposition.** A diagram inventory in the plan: a system-context overview
  reused as the map, then sequence, state and timing diagrams for contracts.
  Every diagram commits its source and a generated SVG.

### F12. Sentence-level patterns (presentation, for copy-editing)

- Telegraphic rows drop articles and subjects: "Destructor has one non-null
  resource parameter, consumes it at entry, returns unit…" (`contracts.md:51`).
- The symbol-like *iff* appears in prose (`contracts.md:74`).
- Many sentences are negations or contrasts ("not a …", "rather than …").
  They are precise, but they hide the positive rule the reader needs first.
- These patterns are acceptable in terse normative entries, which the rework
  does not reword. They are defects in explanation and tutorial prose, which
  the prose contract governs.

## 3. Material worth preserving

- The status statements: proposed draft, no parser, synthetic fixtures
  (`README.md:3–5`, `README.md:25–30`, `conformance.md:185–188`).
- Stable rule identifiers, and the requirement that a validator reject for
  the stated rule (`conformance.md:24–29`).
- The mutation table as failure cases, and N11's lesson that a valid document
  can be false about an implementation.
- The pressure-case table as the honest statement of expressive limits.
- "Two views of one contract", as both the style target and evidence for
  AIL's purpose.
- The scope section's distinction between limits of expressiveness and
  partial specification (`README.md:40–51`).
- The design proposal's alternatives table, the four identities (§4) and the
  memory-as-relationship explanation (§5).

## 4. Possible language issues surfaced for review

These came up while reading for presentation. They are review questions, not
defects this rework may fix. The audit is not a semantic review of draft 0.1.

- **Q1. Normative force of lowercase *must*.** See F10. Is every lowercase
  *must* in `contracts.md` and `profiles.md` intended as a requirement? Does
  the keyword convention apply to all three normative files?
- **Q2. One word for two concepts.** *Closure* names both a dependency closure
  and a callback's captures. Is the overlap acceptable in a language whose
  readers include binding authors, for whom both senses are live?
- **Q3. The ownership placement decision.** The design proposal left open
  whether ownership belongs in types or clauses. Draft 0.1 uses clauses only.
  What evidence decided it, and what did the alternative cost?
- **Q4. Two notations for one slot.** Inside a callable, a slot is written
  `$result` or `$handler`. From outside, it is written `@op::result` or
  `@subscribe::handler`, and `@Alias::name` also addresses an imported
  declaration (L2). Is a double spelling with an overloaded `::` the intended
  trade-off?
- **Q5. Borrow validity is split.** In `view`, the input says
  `valid($store, call)` while the result's validity depends on
  `owner($store)`. The caller's obligation to keep `store` alive after the
  call follows from the output region, not the input clause. Reviewers may
  judge whether that split is discoverable.
- **Q6. Rule-identifier granularity.** Mutations cite section-level rules; for
  example, C3 covers about forty lines. Is section granularity enough for
  diagnostics and review comments, or does the draft need paragraph-level
  identifiers?

## 5. Limits of this audit

- Findings come from direct reading and from searches whose flags were
  checked against known hits. The *FFI* search was re-run as a whole-word
  search after a case-insensitive search matched "insufficient".
- The audit made no grammar or semantic check of the examples, ran no
  validator (none exists) and tested no reader. Reader outcomes are unmeasured
  until the reader checkpoints in the plan.
- Counts are for this revision only.
