# concepts-k58

## Goal

Complete and verify the figures supporting the corrected introductions across `explanation/contracts.md`, `explanation/packages.md` and `explanation/choices.md`.

## Context

- Human assessment and H5–H7: first-path-reading-k48, D2–D5.
- Structure brief: documentation plan §9.2; general requirements:
  §4–§6 and §9.7.
- Rule-reading-k49 supplies the canonical examples, language model and selected
  railroad views. Read their landed form and this node's Handed forward list.
- Paths are relative to semantic/specification/interface-language/.

## Work

Read all three pages and the current handoffs. Reuse the rule-reading model/syntax views and render any further justified slots. Keep example names aligned across G2–G7, G9/G10, snippets and prose. Check that diagrams show the intended relation and that railroad views only claim syntax.

Read the whole document under this stage's charter. Preserve original AIL
semantics, example contracts, proposed status and synthetic boundaries.
Work belonging to another stage follows the node's declared handoff and
escalation rules; do not silently absorb it.

## Done when

- This stage's charter is satisfied for the whole named document under the
  revised structure brief, with the disposition of each relevant H5/H6 location
  recorded in the task's notes.
- Snippets, prose and figures agree with their grammar and canonical rules;
  complete/fragment labels remain truthful.
- `task docs:check` passes. Mechanical checks and editorial inspection are
  reported separately from human comprehension.

## Notes

This is the human-directed second correction run. The escalation and authority
are in the node brief; no further automatic rerun is authorized. Record any
unresolved residue for first-path-reading-k64 and seek human direction when
necessary. The next stage is already queued under this node; do not add a duplicate.

## Decisions (running log)

D1 — Retain G2–G7 and the reused G9/G10 views for their existing, distinct
questions. Correct G5's shortened `invalidated_by` spelling to include its
result place; name the constructed G7 operation `notify` to match its snippet.
Describe G9's sibling declarations by their shared package folder rather than
claiming a horizontal layout. These are figure/reading-key corrections, not
changes to the examples or language.

D2 — Add small comparison tables for unique versus counted release obligations,
the two environments locally named `test`, and exact versus range coverage.
Each carries a comparison currently requiring the reader to cross-read prose
or separated snippets. Give the existing address/load table an explicit
takeaway. Keep every other existing figure and its context; no additional
diagram medium or renderer is needed.

## H5/H6 location dispositions

Read all three pages in full, including tables, snippets, figure keys and
scope statements. Inspected the rendered G2–G7, G9 and the four reused G10
views against their sources, local examples and relevant rules.

| Location | Art disposition |
|---|---|
| Packages: shell, local/imported declarations, member and slots (H5/H6) | G9 keeps `Canvas`, `position` and `Filter` inside canvas and `Point` inside geometry. The import connects the packages; the member arrow associates siblings. Corrected the local key's spatial description to match the rendered folder. The reference table and G10 names distinguish shared spelling from name resolution. |
| Packages: four identities, publication and dependencies | Retained identity and pin tables and schematic G2. Geometry's zero placeholder remains separate from F1's synthetic tokens. G2 claims no additional fixture package or imported Store. |
| Packages: environments | Added a comparison of the two `test` configurations, preserving the omitted buffer toolchain and selected object compiler. |
| Packages: access, providers, fixture and projections | G3's message and source branches use the same getter and ABI entry. G10 access follows the exact grammar: a nonempty environment list and zero or more syntactic clauses; A2 supplies requiredness. Added the address/load table's explicit takeaway. Other figure roles and links remain sufficient. |
| Contracts: signature, clause arguments and places (H6) | G10 clause and place views match EBNF, including optional arguments, nested constructors, repeated selectors and empty buffer brackets. Keys tie tracks to the local examples and reserve validity for rules/types. The selector table retains pointer versus storage. |
| Contracts: ownership and borrow duration | Retained watch-only G4 and the two separate Store cases in G5. G5 now spells both arguments of `invalidated_by`; the cutoffs, input validity and returned owner borrow stay distinct. |
| Contracts: outcomes and buffers | Existing partition and storage tables carry observable failure versus unreadable output, and payload length versus terminator capacity. Their roles and synthetic/constructed boundaries remain explicit. |
| Contracts: callbacks | G7 now names `notify` at entry, callback invocation and completion, matching the located fragment. Its caption and alt text agree. The separate subscription trace retains possible zero notifications, owner retention, outside-callback teardown and no eventual-completion promise. |
| Contracts: threads, lifecycles and patterns | Retained the permission and role-mapping tables and unique-store G6. Added a release-obligation comparison with Counter so the unique/refcounted distinction has a figure without widening G6's scope. |
| Contracts: profiles and verification limits | The synchronous/asynchronous fragments and connected explanation retain the provider boundary. No further diagram adds a distinct relationship beyond the existing core/profile comparisons and context links. |
| Choices: domain/API/notation, publication and ownership | Retained the three-level comparison, choices/costs map, clause-count table and ownership-placement comparison; each has an adjacent takeaway. These keep the alternative and synthetic examples distinct. |
| Choices: clause vocabulary, environments and profiles (H6) | Reused G10 clause still accepts shapes without claiming semantic validity. Added the exact/range comparison beside its two-version example; the range stays explicitly hypothetical. Located profile examples and the choices map retain their roles. |
| Choices: coverage limits and Q1–Q6 | Retained the named pressure-case list and question register. They keep each case's required work and each question's source beside its explanation; no question is resolved by art. |

## Figures declined

- **Editorial judgement:** no separate package-shell, member or slot diagram.
  G9, the local reference table and G10 names already show those relationships;
  the package-shell railroad remains linked at its named introduction.
- **Editorial judgement:** no second ownership, buffer, outcome or ordering
  diagram. G4–G7 and the partition, storage and role tables carry these relations.
  The new release table keeps counted ownership visible without expanding G6.
- **Editorial judgement:** no additional profile-support or open-question matrix.
  The choices map and named pressure-case list retain case-specific limitations
  more clearly than a binary support grid would.
- No figure was declined because the contract forbade its medium or because
  the admitted medium could not carry the relationship. No medium change is
  proposed.

D3 — The node's art handoff is discharged and removed. The already-live
concepts-k59 supplies proof; no duplicate successor, correction run, node close
or parent promotion applies. No unresolved art residue or new language
decision was found. Human comprehension remains first-path-reading-k64's
assessment, independently of visual inspection and mechanical checks.

## Verification

- `task docs:diagrams:write` regenerated the source/SVG pairs. Only G5 and G7
  SVG bytes changed. Inspected all eleven relevant rendered views (G2–G7, G9,
  G10 names/clause/places/access), then inspected G5 and G7 again after edits.
  Temporary raster views used `rsvg-convert`; Quick Look's initial square
  thumbnails cropped larger images and were not used to judge their edges.
- `task docs:check` passed: links and examples each checked 19 files, all 17
  Markdown pages were reachable, and every named result for the 23 SVGs was OK.
- Before/after SHA-256 maps matched for all 96 subjects: the interface-language
  tree, documentation tools excluding Python caches, Taskfile, documentation
  plan and audit. Manifest SHA-256:
  `05704196a067785eaa747837c73a79353862b60778572f5d511017c9e33ab93a`.
  No checked input changed during the run.
- Inspected the complete three-page diff and bounded changed-file list.
  All AIL fences, their omission labels, heading order and Q1–Q6 remain
  unchanged. The canonical language/contract/profile files, grammar and all
  example files have no changes. Railroad productions were compared directly
  with `grammar.ebnf`; figure claims were checked against the relevant
  L2/L3, C1/C2/C6 and F1 text and the concrete snippets.
- Tier 2 graph status/coverage was checked at generation
  `2026-09-23T09:55:55Z`. Relevant Markdown metadata is changed or untracked;
  example/design/research subtrees and some SVGs are excluded. Direct document,
  source and rendered-image reads supplied the evidence. No structural code
  discovery or graph-completeness claim was needed.
- These checks establish local consistency, visual inspection and regeneration.
  They do not execute AIL semantics or native APIs, establish human comprehension,
  or demonstrate a general remedy for the earlier reading feedback.

D4 — Retire concepts-k58 and seal the figures, captions, comparison tables and
handoff in one jj commit. Proof remains live, so the concepts node and its
ancestors stay open. No ADR or glossary change is warranted by these local
presentation corrections.
