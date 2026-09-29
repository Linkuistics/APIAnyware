# concepts-k74

## Goal

Revise `explanation/contracts.md` so it describes AIL by reference to the
model: each section names the model concept it writes down, recalls its case,
and then shows how AIL expresses it, in the model's concept order.

## Context

- Structure brief: plan §9.2, *Model-first run* block (the revised section
  order for this page governs where it conflicts with the older list).
- Concept names, anchors and the construct map: plan §10. Prose contract:
  plan §4 (*Make the model the main thread*, *Two models, one purpose*,
  *Domain before notation*).
- The landed model page `explanation/model.md` and the outcome of
  `model-reading`: use the concept set as the human left it.
- Model-reading-k73's example-led refinement, plan §9.2. Concepts-k85 lands
  the grammar/railroad sections in `reference/notation.md` before this leaf.

## Done when

- The page follows the revised order: operations and values (two sections),
  outcomes, entities and their lifecycles, release responsibility, validity,
  storage, execution, callbacks, patterns and laws (or kept in the entities
  section, with the reason recorded here), profiles.
- Every notation-introducing section opens with its concept's `model.md` name
  and link and the reader's task, recalls the concrete case in a sentence or
  two, and only then shows a located snippet. No section re-teaches the model.
- Every construct introduction on the page is enumerated in this leaf with its
  §10 concept.
- The prose explains AIL-specific meaning and model consequences. Remove the
  quoted punctuation walkthrough in *From signature to contract* and similar
  elementary syntax narration elsewhere, retaining useful explanations of
  reference/place meaning and context.
- Existing examples, figures G4–G7, rule citations and anchors are kept.
  Replace G10 embeds with links to the relevant grammar-reference sections;
  moved or renamed headings keep their old slugs via explicit
  anchors, and incoming links across the set still resolve.
- The model page's closing map links the renamed sections.
- `task docs:check` passes.

## Notes

Second of four draft sessions in the one bounded model-first run authorized by
the human's 2026-09-29 direction (node brief). Later drafts, copy-edit, art
and proof are already queued, so cut nothing at the end. Do not change rule
semantics or examples' contracts; a model/rule mismatch becomes a question in
`explanation/choices.md`.

## Decisions (running log)

- D1: Follow plan §9.2's revised call-layer order. Split the old *Lifecycles
  and patterns* section: *Entities and their lifecycles* follows outcomes;
  *Patterns and laws* follows callbacks. The latter connects declarations
  after the reader has met their contracts, while lifecycle precedes the
  transfer clauses that rely on it. Preserve the old lifecycle anchor on the
  entities section and update both model-page routes to name the split.
- D2: Keep all existing AIL regions and G4–G7 figures unchanged. Replace the
  two G10 embeds with grammar-reference links, remove punctuation narration,
  and connect each section opening to its exact model concept and reader
  task. The first examples preview several obligations; give those previews
  routes to their fuller sections instead of expanding into a second model
  account. The named structure brief supplies reader/outcome, ordered plan
  and emphasis/non-goals (§9.2); no new structure decision from the human is
  needed. Later drafts and editorial stages already exist, so add no leaf.
- D3: Retain the existing explanation of `inout` / `state(unchanged)` and
  supply its missing local example: a constructed scalar `inspect_count`
  fragment, synchronized with a new region in `examples/concepts/contracts.ail`.
  C3 establishes readable/writable input storage and C5 permits unchanged
  state only for `inout`. This adds an illustration of the existing claim;
  all pre-existing example regions and the three complete fixture packages
  keep their contracts. The record/handle comparison in the entities section
  reuses the earlier `Created` example, whose fields express operations/values.

## Construct-to-model inventory

Scope: `explanation/contracts.md` after this draft. Enumerated the AIL fence
contents and inline-code spans section by section, then classified declaration
forms, types, paths, clauses and constructor/value alternatives. Example names
(such as `view`, `Created`, `kept` and `resource_type`), literals and rule IDs
are referents or data, not additional constructs. Repeated uses retain the
concept assignment below. This is a teaching inventory, not exhaustive language
coverage. Each section's opening links its principal concept before its first
fragment; previews are developed in the later named sections.

| Introduction / example regions | Constructs introduced or meaningfully developed | Plan §10 concept |
|---|---|---|
| From signature to contract / `watch-close`, `view-borrow` | `fn`, named parameters and result, nominal type names, `unit`, `ptr<u8>`, `$watch`, `$result`; common clause form | Operations and their values (`operations`) |
| Same first package fragment | `package … version …`, local declaration identity and type resolution | The published description (`description`); containment route goes to packages |
| Same first fragments, later expanded below | `resource`; `execution(sync)`; `completions([returned])`, named `outcome`, `when(returned, any)`, `meaning(success)`, `state(valid)`; `input(consume/borrow)`, `give(borrow(owner(...)))`; `valid(call)`, `invalidated_by([])` | Entities (`entities`); execution (`execution`); outcomes (`outcomes`); responsibility (`responsibility`); validity (`validity`), respectively |
| Naming what a contract talks about / `pointee`, `buffer-place`, `record-leaf` | Parameter/result slots; `$parameter`, `.*`, `[]`, `.field`; `mutptr<u64>`, `mutptr<u8>`, `u64`, `bool`; `record`, `field`; reference leaves inside records; external `@view::store` versus local `$store` | Operations and their values (`operations`); scalar record shape is distinct from a contained entity's lifecycle |
| Same place examples | `extent(one)`, `extent(buffer(..., elements))`; `state` of a pointee, buffer or aggregate; `give(owned)` for a reference field | Storage (`storage`); outcomes (`outcomes`); release responsibility (`responsibility`) |
| Every way a call can end / `null-outcomes`, `status-outcomes`, `unchanged-output` | `nullable<Store>`; `outcome`, `when`, `null`, `nonnull`, `equal` with Booleans, `any`, `meaning(success/failure)`, `state(valid/invalid/unchanged)`; completion modes discussed in prose | Type: operations (`operations`); completion partition and output state: How a call finishes (`outcomes`) |
| Same unchanged-output example | `direction(inout)`, `extent(one)` and an unchanged single pointee | Storage (`storage`), used by an outcome (`outcomes`) |
| Entities and their lifecycles / `lifecycles` | `resource`, `object`; `lifecycle(unique, @destroy)`, `lifecycle(refcounted, runtime(...), runtime(...))`; local declaration reference `@destroy`, provider runtime retain/release names; record/handle comparison recalls `Created` | Entities that outlive a call (`entities`); record value structure remains `operations` |
| Who owns what / `entry-transfer`, `output-transfer`, `retention` | `input(borrow/consume)`, `retain(none/strong(owner($result)))`, `give(owned/borrow(...))`; nullable delivery; strong retention versus copy and consumption | Release responsibility (`responsibility`); owner region also expresses validity (`validity`) |
| How long a borrow lasts / `owner-borrow`, `mutable-borrow`, `static-borrow` | `valid`, `call`, `owner($store)`, `static`; `invalidated_by([]/[@replace])`; `mutation(arguments)`; rejected `borrow(call)` for escaping output | Validity (`validity`); mutation supplies the invalidation context |
| Same static-borrow example | `constant` with `$result` output clauses directly in its body | Entities that outlive a call (`entities`), used to illustrate validity (`validity`) |
| Buffers and strings / `binary-buffer`, `text-buffer`, `output-storage` | `extent(buffer(length, capacity, elements))`; integer-literal or scalar-slot bounds; `contents(binary/text("utf-8", nul))`; `direction(out)`, `aliasing(disjoint)`; `mutptr`, `mutation(arguments)` consistency | Storage (`storage`); mutation connects storage writes to validity/execution facts |
| Threads and sharing / `store-threads`, `counter-threads` | `sharing(transferable/confined/shared)`, `isolation(none/main)`, `executor(any/main)`, `concurrency(serial)`, `reentrancy(allowed)` | Where and when calls run (`execution`) |
| Same counter example | `member(@Counter, instance)`, `receiver($receiver)` are shown with a route to their existing package introduction | Entities that outlive a call (`entities`), supporting the execution consistency check |
| Threads and sharing / `sendability` | `fixture::sendability(nonconforming)` and profile-qualified vocabulary | Execution (`execution`), with the extension agreement (`agreement`); F1 is explicitly synthetic |
| Callbacks / `handler`, `subscription-schedule`, `call-schedule`, `outside-callback` | `callback` declaration versus `callback $handler` use; `timing(after_return/during_call)`, `count(0, many)/(1, 1)`, `scope(owner($result)/call)`, `quiescence(@unsubscribe/return)`; `requires(outside_callback(@subscribe::handler))` and external callback-slot identity | Callbacks and their schedules (`callbacks`); slot identity also uses operations (`operations`) |
| Same callback examples | Per-type and per-registration `execution(sync)`, `executor(any)`, `concurrency(serial)`, `reentrancy(forbidden)`; `input`, `retain`, `valid` | Execution (`execution`), responsibility (`responsibility`) and validity (`validity`) applied to callback use |
| Patterns and laws / `lifetime-pattern`, `ordering-pattern` | `pattern`, `role` with `type/operation one`, `law(releases/before, ...)`, `instance`, `bind`, `subject`; local declaration and operation-slot references | Entities that outlive a call (`entities`), expressing recurring release/ordering relationships; paths use operations (`operations`) |
| Extending the language with profiles / `sync`, `async` | `execution(sync/async)`, `completions([returned])`; profile-defined suspension and completion, ABI/representation obligations and consumer validation boundary | Writers, checkers and users (`agreement`), illustrated through execution (`execution`) and access (`access`) |

The page introduces no new concept outside §10. Its two grammar-view routes
are `reference/notation.md#clause` and `#places`; the opening also links
`#callable`. The moved sections retain their heading slugs. The renamed
lifecycle section retains `#lifecycles-and-patterns` explicitly and links to
`#patterns-and-laws`; `#what-the-core-leaves-to-profiles` remains in place.
The model page's entities section and closing map now name and link both
new sections.

## Verification

- Structure: checked the eleven section headings against this leaf's revised
  order; every section links its exact model concept before the first AIL
  fence. Patterns follow callbacks; the entities section keeps G6 and a link
  to the later pattern section. The model's two entities routes reach both
  sections. The first two sections remain operations/values introductions.
- Technical truth: read current L1–L6, C1–C8 and A1–A5/F1 directly, alongside
  the grammar, all concept example regions and the three complete fixture
  packages. Checked the output partitions, aggregate/place distinctions,
  unique and counted lifecycles, transfer versus retention, owner/static
  regions and invalidation, buffer bounds, execution restrictions, callback
  count/quiescence, pattern subjects and profile boundary against those rules.
  The added scalar unchanged-output fragment follows C3/C5 and remains
  explicitly incomplete. No model/rule discrepancy was found in this scope.
- `task docs:check` passed: links and examples checked 21 files, 19 site pages
  were reachable, and all 26 SVGs regenerated identically. The verification
  subjects were all files under `semantic/specification/interface-language/`
  and `semantic/specification/tools/` (excluding Python caches), root
  `Taskfile.yml`, the documentation plan and the audit: 106 files, each hashed
  before and after. No subject changed during the run; the sorted path/digest
  map's aggregate SHA-256 was
  `a7a49acc7ec0f0276e9f08247026d8edd7b634e1514cb1ad237c033cc5afbf98`.
- Preservation comparisons retained all 28 original region-backed AIL blocks
  byte-for-byte, all original section targets and all 17 distinct canonical
  rule-citation destinations. The new `unchanged-output` is the only added
  region. Semantic figure embed paths and alt text are unchanged; G10's two
  removed embeds now have grammar links. Deliberately changing one example
  and removing the legacy lifecycle anchor made the corresponding checks
  reject those mutations. The original page supplied the positive G10-embed
  control before checking its absence from the revision.
- Parent-revision byte comparisons confirmed unchanged canonical pages,
  grammar and complete buffer/object/callback packages. `jj diff --name-only`
  confines the change to this task, the contracts explanation, the model's
  two navigation links and the appended concept example region.
- Graph evidence is Tier 2 with generation `2026-09-23T09:55:55Z`; coverage was
  checked for the task inputs and all verification subjects. Documentation
  metadata is changed/untracked and examples/design docs are excluded; SVGs
  include ignored-suffix exclusions. The conclusions above therefore rely on
  current source reads, direct byte comparisons and the repository checks,
  not on graph completeness. This gate checks documentation consistency and
  diagram regeneration; it is not an AIL parser, semantic validator or native
  implementation test.
- The node still has the live k75/k76 drafts and k77–k79 editorial stages.
  No successor is cut and no ancestor closes. No language decision or ADR
  revision follows from this presentation change.
