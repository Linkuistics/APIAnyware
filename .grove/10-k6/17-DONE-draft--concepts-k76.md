# concepts-k76

## Goal

Give every direct rule entry a route to the model: add the model page to the
canonical pages' page-one blocks and a one-sentence model-concept route to the
first reading aid of each rule section, preserving the rule text exactly.
Apply the example-led refinement to the non-normative aids, glossary and
landing-page routes so they explain meaning and link to the grammar.

## Context

- Structure briefs: plan §9.7 items 7–8 and §9.2's *Canonical reading-aid routes*
  and *Example-led refinement*. Human direction: model-reading-k73.
  Concepts and anchors: plan §10 (its *Rules* column maps rule sections to
  concepts).
- Aid convention and preservation check: rule-reading-k49's brief (*Draft
  conventions and reuse*): paired `reading-aid` comments, blockquote border,
  bold label, explicit anchors, comparison against revision `87221b8c`.
- concepts-k74 and concepts-k75 for the concept-page sections those routes
  may also name.
- Concepts-k85's grammar home and migrated canonical G10 links; retain its
  section anchors and all local examples.

## Done when

- The page-one blocks of `language.md`, `contracts.md` and `profiles.md` name
  the model page in *Before this*.
- Each rule section L1–L6, C1–C8, A1–A5 and F1 opens its first reading aid
  with one sentence naming the §10 concept(s) its constructs express, linked
  to `explanation/model.md` anchors; a section without an aid gets a short
  bordered one. The mapping used is recorded in this leaf.
- Stripping all paired reading-aid blocks still reproduces the three pages
  byte for byte from `87221b8c`; the grammar, conformance record and frozen
  examples are unchanged. The check has been seen to fail on a deliberate
  mutation before its clean result is credited.
- The non-normative aids and glossary explain AIL-specific meaning and
  relationships, without teaching familiar punctuation. Canonical rule text
  is never reworded to remove syntax commentary. Every local example and
  semantic distinction stays; moving the railroads does not turn an aid into
  links alone.
- The landing page and glossary link the grammar-reference sections for
  exact syntax and the canonical aids for meaning; previous anchors and
  incoming links still resolve. No G10 embed remains on these pages.
- `task docs:check` passes.

## Notes

Last draft session of the bounded run. Copy-edit, art and proof are already
queued as live later siblings, so cut nothing at the end. Change no rule text,
anchor, grammar or fixture.

## Decisions (running log)

- D1. The named structure brief meets the draft precondition: plan §9.7
  names the primary reader arriving directly at a rule and the outcome of
  interpreting it; its ordered items 1–8 place context, local examples and
  model routes; its Emphasis and Non-goals preserve local teaching support
  and exclude changes to normative wording, semantics and fixtures. §9.2's
  example-led refinement governs this revision. Retain all examples and
  anchors, replace punctuation/railroad narration with AIL-specific meaning,
  and keep exact syntax lookup in `reference/notation.md`.
- D2. Use the §10 concept names verbatim as linked phrases in each section's
  first aid. The mapping below covers all rule sections; additional links in
  later aids identify the particular constructs they introduce. No new model
  concept is needed. L2's existing slot/member/provider examples also connect
  to operations, entities and access beyond its primary description concept.

| Rule | Model anchors in the first aid |
|---|---|
| L1 | description, agreement |
| L2 | description |
| L3 | description, agreement |
| L4 | operations, entities |
| L5 | operations, entities, description |
| L6 | entities |
| C1 | operations, validity |
| C2 | entities, responsibility, execution, callbacks |
| C3 | outcomes, responsibility, validity, storage, execution |
| C4 | storage |
| C5 | outcomes, responsibility, validity |
| C6 | callbacks |
| C7 | entities |
| C8 | agreement |
| A1 | access, agreement |
| A2 | access |
| A3 | access |
| A4 | access |
| A5 | agreement |
| F1 | access |

## Construct introduction inventory

Enumerated the bold reading-aid headings in the three canonical pages, then
classified their construct introductions below. A row can cover several
headings inside the same paired block. The concept anchors refer to plan §10
and `explanation/model.md`; the rule-opening route applies to its whole
section. The glossary's notation entries retain their own model links and
located examples. Its revised callable, identity, clause, declaration,
local/imported declaration, package, place and slot entries keep the same
concepts and add grammar routes where syntax lookup is needed.

| Aid block | Introductions and local support | Model anchors |
|---|---|---|
| l1-shell | Header, package, record, surface and exports in the geometry shell | description, operations |
| l1-tokens | Identifier/integer/string examples, comments and contextual keywords; lexical interpretation of that shell | description, agreement |
| l1-clauses | Deprecation clause, version constructor and declaration/list values; located Point plus no/maybe comparisons | description, agreement |
| l2-model | Packages, local/imported declarations, member and receiver, identity tuple; geometry/canvas and G9 | description, entities, operations |
| l2-references | Types, declaration and slot references, callable-local places, callback signature/outcome; position and Filter | operations, description, outcomes |
| l2-scope-pins | Import collisions, duplicate parameters/outcomes, reserved names, exact pins and resolution closure; invalid fragments and geometry dependency | description |
| l2-providers | Profile/ABI aliases, source identity, access/via; fixture dependencies and canvas spellings | access, description |
| l3-publication | Surface/exports, exact environment fields, availability and completeness; canvas plus conditional toolchain/runtime/feature variants | description, agreement |
| l4-values | Alias, record, array, complex and scalar fields; Samples; handle/pointer/nullable/unit distinctions in three functions | operations, entities |
| l4-domains | Enum/flags cases, open/closed domains; Axis and Edges | operations |
| l4-profile-types | Hypothetical qualified Sequence type and provider requirements; Points alias, explicitly outside F1 | operations, agreement |
| l5-repetition | Per-place input keys and aggregate state; compare and position | operations |
| l5-navigation | Doc/link/source/deprecated; Point's annotations and advisory variants | description |
| l5-declarations | Base/implements/extends, member/receiver/requirement/overrides/satisfies; Drawable/Shape/Dot; static/initializer and extension members; Counter property/accessors/storage; constant/literal and global/mutable | entities, description, operations |
| l6-roles | Pattern/role/instance/bind/law and kind/cardinality; canvas slots, Store lifetime and grouping | entities, operations |
| l6-ordering | Before law and subject slot references; prepare/read on the same Session | entities, operations |
| c1-places | Field, pointee and uniform element places, reference leaves, result/exception slots; inspect and position | operations |
| c1-regions | Valid/call, give/borrow/owner, invalidation and static; Store view with global link | validity, responsibility |
| c2-lifetime | Unique/refcounted lifecycle, consume, sharing/isolation, runtime and callback captures; Store/destroy and Counter | entities, responsibility, execution, callbacks |
| c3-effects | Execution/completions/executor/concurrency/reentrancy/mutation/variadic plus input/retain/valid; view | outcomes, execution, validity, responsibility |
| c3-retention | Strong owner retention versus consume/none, prospective owner and conditional copy/weak/unretained alternatives; subscribe | responsibility, validity |
| c3-pointers | Direction, aliasing, mutation, pointer versus pointee; copy_bytes and replacement link | storage, responsibility |
| c3-requires | Capability versus availability, optional requirement and outside_callback; Panel redraw and teardown link | entities, description, callbacks |
| c4-buffers | Extent/one/buffer, contents/text/binary, length/capacity/units/termination; copy_bytes, accept_text and zero-bound cases | storage |
| c5-outcomes | Outcome/when/meaning/state, discriminator predicates and partitions; copy_bytes plus null/integer/any comparisons | outcomes |
| c5-outputs | Owned/borrowed/null/aggregate output leaves, inout consume/give and earlier invalidation; create/view, replace and refresh comparison | responsibility, validity, outcomes |
| c6-schedule | Callback declaration versus use block, timing/count/scope/executor/concurrency/reentrancy/quiescence/outside_callback; Handler, subscribe/unsubscribe and call-scoped comparison | callbacks, execution |
| c7-storage | Global read result, static borrow, empty invalidation, mutable/sharing/isolation and constant comparison; pointer_value | entities, validity, responsibility, execution |
| c8-checking | Impossible/missing/unknown extent, validity versus truth and consumer restriction; mutated view | agreement, storage |
| a1-dependencies | Profile/ABI dependency aliases and pins, environment and manifest support; Counter dependencies | access, agreement |
| a1-namespace | Profile clause/type/constructor qualification and closed vocabulary; Counter sendability and hypothetical unsupported type | agreement, access |
| a2-paths | Access/in, ABI convention, via, mapping and compatibility; two Counter paths and canvas symbol comparison | access |
| a2-callback | Callback ABI and closure representation; complete Handler declaration | access, callbacks |
| a3-data | Representation recipe, address versus load, source-expression boundary; Point and two data declarations | access |
| a4-compatibility | Stable/source/artifact domains; Counter paths and explicitly hypothetical artifact | access |
| a5-views | Preserved contract facts, meaningful order, set equality, lossless authoring and feasibility; Store and Counter comparisons | agreement |
| f1-fixture | Synthetic pins/mechanisms, sendability and conditional actor clauses, runtime/closure/encoding support boundaries | access, agreement, execution |

## Verification

Preservation was checked with `jj file show -r 87221b8c`: stripping
each full paired aid and its blank separator reproduced each canonical
page exactly. Before crediting each clean result, an in-memory mutation
changed its normative draft version and the same comparison rejected it.
The grammar, conformance record and buffers/objects/callbacks fixtures also
matched that revision. Compared with the session parent, all AIL fences,
explicit anchors, headings and image targets in the five edited reader
pages are identical. These are preservation checks, not semantic execution
or evidence of human comprehension.

`task docs:check` passed: links in 21 files, all 19 reader pages reachable,
example comparisons in 21 files, and byte-for-byte regeneration of all 26
SVGs. SHA-256 digests before and after the run matched for all 106 subjects:
the entire interface-language tree, documentation-checker Python sources,
`Taskfile.yml`, the documentation plan and the audit. No checked subject
changed while the gate ran.

The inventory above matches every non-context paired aid block. The first-aid
route extraction agrees item by item with the rule mapping. Direct L2, C5
and A2 entries link to description, outcomes and access respectively; their
grammar links lead to names/places, outcomes and access. The glossary routes
reach all eleven grammar sections through the relevant entries and examples.
The no-G10-embed check for these five edited pages detected an injected image
on each page; the same image extraction found all eleven G10 views in the
grammar reference. Existing explicit anchors, heading slugs and semantic
image targets are preserved.

The queued copy-edit, art and proof siblings remain live. This draft leaves
no additional later-charter defect or figure slot to hand forward and cuts
no successor. The node remains open for those stages.

The graph's reported generation was `2026-09-23T09:55:55Z` (Tier 2).
Coverage reported changed/untracked Markdown and excluded design/example
paths. Documentation evidence came from direct source reads and byte
comparisons; no structural code claim relies on the graph.
