# concepts-k75

## Goal

Revise `explanation/packages.md` and `explanation/choices.md` to follow the
model: packages opens with the description-layer concepts before the package
shell, and choices judges each language choice by how well it serves the model.

## Context

- Structure brief: plan §9.2, *Model-first run* block (the packages and
  choices paragraphs). Concepts and anchors: plan §10 (description, access,
  agreement for packages; every concept for choices). Prose contract: plan §4.
- The landed `explanation/model.md`, `model-reading`'s outcome, and
  concepts-k74's revised contracts page.
- Model-reading-k73's example-led refinement and the grammar/railroad home
  landed by concepts-k85 at `reference/notation.md`.

## Done when

- `packages.md` opens by recalling what a published description must
  establish (scope, identity, dependencies, environments, reaching the code),
  linked to the model's description, access and agreement concepts, before
  the package shell. *Packages contain declarations* keeps its geometry/canvas
  containment example and reference table, introduced as the language-
  containment view serving the description concept; G9 is not called "the
  model". Later sections gain concept openings in the same pattern.
- `choices.md`'s *How to read this page* states the criterion — each choice is
  judged by how well it serves describing the model and the reader's task —
  and each choice section names the concept it concerns and what the choice
  makes easy or hard for it. Q1–Q6 and the domain/API/language separation
  remain; no question is resolved.
- Construct introductions on both pages are enumerated here with their §10
  concepts. Examples, figures G2/G3/G9 and anchors are kept; renamed headings
  keep their old slugs.
- Replace G10 embeds with links to their grammar-reference sections. Examples
  show familiar syntax; prose explains AIL-specific meaning and relationships
  without elementary punctuation narration. Preserve the local/imported,
  member/receiver and declaration-reference/place distinctions.
- `task docs:check` passes.

## Notes

Third of four draft sessions in the bounded run. Cut nothing at the end.

## Decisions (running log)

D1 — Plan §9.2 is the named structure brief. Its reader/outcome paragraph
requires readers to connect each construct to a model concept; its ordered
packages/choices sections and overriding Model-first run specify the sequence;
its Emphasis and Non-goals require honest trade-offs while excluding exhaustive
reference coverage and proposed fixes to open questions. Keep that order and
the examples. Add concept openings, replace the three G10 embeds with grammar
links, and remove familiar-syntax narration. No heading needs renaming.

D2 — Retain the geometry/canvas containment view as support for the published
description, explicitly distinct from the API model. Use the watch case only
to recall the model's scope/access/agreement obligations, preserving its
separation from the synthetic fixture packages. Later stages already stand
in the node; this leaf adds no successor or correction run.

D3 — Keep Q1–Q6 and the domain/API/language comparison unchanged. The choice
sections assess expressing and inspecting the concepts, without supplying a
missing ownership-placement rationale or choosing an alternative. Existing
examples supply the comparison; no fixture contract or language rule changes.

## Construct introductions and model concepts

The inventory covers both complete pages, including constructs recalled in
prose and comparison tables. It was checked against the extracted inline-code
tokens and clauses in every AIL fence, then classified by plan §10. Concrete
declaration names, aliases, provider strings and numeric values instantiate
the forms below; rule identifiers and example filenames are citations.

| Page / section and example | Constructs and relationships | §10 concepts (model anchors) |
|---|---|---|
| Packages / opening and Packages contain declarations / geometry | `language`, `package`, independent language/package versions, local declaration identity, `record`, `field`, `i32` | The published description (`description`); record values: Operations and their values (`operations`) |
| Packages / Packages contain declarations / canvas `model`, G9 and reference table | `import … version … digest … as`, local/imported type names, `@Canvas`, `@Geometry::Point`, `fn`, parameter/result slots, `@position::canvas`, `@position::result`, local `$canvas`/`$result`; callback `Filter` via its located L2 example | Description (`description`); operations and values/slots (`operations`); callback declaration (`callbacks`) |
| Same canvas example | `resource`, top-level `member(@Canvas, instance)`, ordinary named `receiver($canvas)`; `input(borrow)`, `retain(none)`, `valid(call)` | Entities that outlive a call (`entities`); release responsibility (`responsibility`); validity (`validity`) |
| Packages / Four identities / canvas `spellings` | Canonical package/version/declaration tuple versus import alias; `source`; `access direct in [test]`, `abi`, `via(symbol)`, `mapping(identity)`, `compatibility(stable)`; profile versus ABI alias | Description (`description`); reaching the code (`access`) |
| Packages / What a package claims / `buffers-3`, G2 | `surface`, `exports`, public roots and private support, dependency closure; reference to the store's lifecycle/destructor | Description (`description`); lifecycle recalls entities (`entities`); publication checking connects writers/checkers/users (`agreement`) |
| Packages / Where it holds / `buffers-7`, `objects-7` | `environment`, `target`, `platform`, `toolchain`, `available`; exact values versus local environment aliases; distinct contract variants; optional receiver capability distinguished in prose | Description (`description`); optional entity capability (`entities`) |
| Packages / What it depends on / `providers` | `import` versus `use profile`/`use abi`; pinned identifier/version/digest, provider alias, supplied resolution set, conflicting pins, acyclic imports | Description (`description`); access definitions (`access`); agreement on external meanings (`agreement`) |
| Packages / Reaching the code / `objects-44`, G3 | Two named `access` alternatives, `abi(object-message/source)`, `via(message/source-call)`, explicit semantic receiver, `mapping(identity)`; `compatibility(stable/source)` and prose `artifact` comparison | Reaching the code (`access`); member/receiver recalls entities (`entities`); preserved execution and borrow obligations (`execution`, `responsibility`, `validity`) |
| Same section / `data-access` | `constant`, `global`, `mutable(false)`, `ptr<u8>`, `via(address/load)`; array-storage address versus stored pointer value | Entities (`entities`), storage (`storage`), access (`access`); pointer type: operations (`operations`) |
| Packages / Profiles and ABI entries | Provider manifests, profile meanings versus machine representations, ordered record fields versus native layout, unique applicable representation recipe; unsupported dependencies | Access (`access`); writers, checkers and users (`agreement`); value structure (`operations`) |
| Packages / The synthetic fixture | F1 test configuration and `sha256:` tokens, synchronous registration versus later callback use, unsupported `execution(async)` | Agreement (`agreement`), access (`access`), execution (`execution`), callbacks (`callbacks`) |
| Packages / One contract, several views | Prose/machine projections, illustrative `owner: "store"`, `owner($store)`, semantic equality versus authoring preservation, consumer feasibility | Agreement (`agreement`); the example preserves validity (`validity`) and the other declared facts |
| Choices / How to read this page / `borrow` | `fn`, reference input, pointer result, local places, `input`, `valid(call)`, `outcome`, `when(returned, any)`, `meaning(success)`, `state(valid)`, `give(borrow(owner))`, `invalidated_by([])` | Operations (`operations`), responsibility (`responsibility`), validity (`validity`), how a call finishes (`outcomes`) |
| Same section / `callback` | `retain(strong(owner($result)))`; callback-use block with `timing(after_return)`, `count(0, many)`, `scope(owner)`, `executor(any)`, `concurrency(serial)`, `reentrancy(forbidden)`, `quiescence(@unsubscribe)`; external declaration reference versus local callback place | Callbacks and their schedules (`callbacks`), responsibility (`responsibility`), validity (`validity`), execution (`execution`), operations/slots (`operations`) |
| Choices / A dedicated syntax | Unique handle versus counted-reference release; symbol, message and source-call mechanisms; core/profile/ABI split; WIT and Swift syntax alternatives | Operations (`operations`), entities (`entities`), responsibility (`responsibility`), access (`access`), agreement (`agreement`) |
| Choices / Publishing a complete description / `publication` | `package`, `surface`, `exports`, `resource`, `lifecycle(unique, @destroy)`; dependency closure; `unknown` rejected versus authoritative `many` | Description (`description`), agreement (`agreement`); entities (`entities`) and callbacks (`callbacks`) supply the cases |
| Choices / Stating the applicable facts / `isolation` | `resource`/`object`, `sharing(transferable/confined)`, `isolation(none/main)`; known `retain(none)` versus owner retention | Execution (`execution`); responsibility (`responsibility`), validity (`validity`); agreement (`agreement`) |
| Same section / complete `view` extract | `available`, `deprecated`, `execution`, `completions`, `executor`, `concurrency`, `reentrancy`, `mutation`, `variadic`; `input`, `retain`, `valid`; `extent(buffer(..., elements))`, `contents(binary)`; outcome clauses and four access clauses | Description (`description`), execution (`execution`), outcomes (`outcomes`), responsibility (`responsibility`), validity (`validity`), storage (`storage`), access (`access`), operations (`operations`); explicitness serves agreement (`agreement`) |
| Same section / optionality discussion | Scalar input versus input reference, optional `doc`, provider-defined defaults | Operations (`operations`), responsibility (`responsibility`), agreement (`agreement`) |
| Choices / Expressing ownership / `consume` and alternative `text` fence | `input(consume/borrow)`, `retain(none)`, outcome `give`; signature ownership alternative, owner lifetime and earlier invalidators; pointer type excludes ownership/extent | Responsibility (`responsibility`), validity (`validity`), outcomes (`outcomes`), operations (`operations`), storage (`storage`) |
| Choices / One clause syntax | Common clause/value form, places; `input`, `extent(buffer)`; undefined `fixture::invented(true)`; `callback_abi` as a rule-lookup example | Agreement (`agreement`); responsibility (`responsibility`), storage (`storage`), operations (`operations`), access (`access`) |
| Choices / Describing exact environments / `environment` | `environment`, `target`, `platform`, `available`; exact configuration versus range alternative and compiler/compatibility distinction | Description (`description`), access (`access`) |
| Choices / Profiles as the extension point / `profile`, `execution` | `fixture::sendability(nonconforming)`, `member`, `receiver`, `concurrency(serial)`; `execution(sync/async)`, `completions([returned])`; closed profile vocabulary and support/feasibility distinction | Agreement (`agreement`), execution (`execution`), entities (`entities`), outcomes (`outcomes`) |
| Choices / Extending coverage beyond draft 0.1 | Rejected cancellation-as-quiescence assumption; generic, async, throwing and value-receiver cases; optional capabilities; mapping/compatibility; variadic/source-only mechanisms; layouts/laws; error-output, handle, mutable-borrow and open-enum cases | All eleven concepts, explicitly linked in their relevant cases; these are pressure cases, not new syntax or capabilities |
| Choices / Q1–Q6 | Preserved questions on normative presentation, dependency/capture vocabulary, ownership placement, `@` references versus local places, entry/output validity and rule identifiers | Agreement (`agreement`), description (`description`), callbacks (`callbacks`), responsibility (`responsibility`), operations (`operations`), validity (`validity`) |

No construct requires a new §10 concept. Section headings and legacy explicit
anchors are unchanged. The replaced G10 destinations are `#names` and `#access`
for packages and `#clause` for choices, all on `reference/notation.md`;
packages also links `#shell`. G2/G3/G9 remain beside their examples.

## Verification

- Structure: read both revised pages in full against plan §9.2. Packages
  recalls the watch description's scope, identity, dependencies, configurations
  and access before the geometry/canvas shell. G9 is explicitly the language
  containment view. Every later section opens with its model concept and
  reader task. Choices states the model/reader criterion, connects each choice
  to concepts, and keeps an alternative and a cost in each choice section.
  All eleven concepts appear in its relevant examples and pressure cases.
- Technical truth: read current L1–L6, C1–C8, A1–A5/F1 and the grammar;
  read the complete buffer/object/callback fixtures, the two pages' example
  sources and the conformance record. Checked identity and alias resolution,
  member/receiver and slot/place distinctions, publication closure, exact
  environments, dependency resolution, faithful access mappings, compatibility,
  data access, provider support and projection preservation. The ownership,
  callback and execution comparisons retain the rules' boundaries. Checked
  the design proposal's alternatives and unresolved ownership-placement
  statement against audit F3 and Q1–Q6. No semantic change was needed.
- Direct parent comparisons preserve all nine fenced examples in packages and
  all ten in choices (including its alternative-notation text fence), every
  heading and explicit anchor, all semantic figure embeds with their alt text,
  and every original canonical rule-link destination. The entire Open questions
  section, Q1–Q6 and footer are byte-identical. String-only mutations of a
  field/input example and a heading caused the preservation checks to fail.
- Both pages' old versions supplied positive G10-embed controls; the grammar
  page supplied the cross-page control. The revised pages embed none, and their
  grammar links reach the corresponding reference sections. Each section
  introducing notation has a model-anchor link before its first fence. The
  full prose read checks meaning and remaining familiar-syntax commentary;
  the retained mention of familiar braces in the dedicated-syntax comparison
  describes a design cost, not punctuation mechanics.
- `task docs:check` passed: links and examples checked 21 files, 19 site pages
  were reachable, and all 26 SVGs regenerated identically. Hashed every file
  under `semantic/specification/interface-language/` and
  `semantic/specification/tools/` (excluding Python caches), plus root
  `Taskfile.yml`, the documentation plan and audit, before and after the run.
  All 106 subjects were unchanged during measurement; the sorted path/digest
  map's aggregate SHA-256 was
  `4c452bc0336a7965e1e3e634e877d25c3566c41f73d62a61331a70b969b72191`.
- Canonical language/contracts/profiles pages, grammar and all three complete
  fixtures are byte-identical to the parent revision. The working diff contains
  only the two explanations and this task. No figure or example source changed.
- Graph project and Tier 2 coverage were confirmed at generation
  `2026-09-23T09:55:55Z`, including all verification subjects and the design
  proposal. Changed/untracked Markdown metadata and excluded design, example
  and tooling paths make direct reads and executable checks the evidence here;
  the graph supplies no completeness claim. These checks establish document
  consistency and preservation, not native behaviour or human comprehension.
- The next draft and all three later editorial stages remain live under
  concepts-k6. No successor is cut, no ancestor closes, and there is no
  unresolved hand-forward item from this leaf. No ADR change is warranted by
  this presentation-only revision.
