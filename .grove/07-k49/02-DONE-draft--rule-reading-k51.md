# rule-reading-k51

## Goal

Apply the same examples-at-introduction treatment to the whole contract and
provider rule pages, completing the rule-reading draft before copy-edit.

## Context

- Structure brief: documentation plan §9.7 and §4–§6.
- Preceding draft: `rule-reading-k50`, its landed aids in `language.md` and
  its example/figure conventions.
- `contracts.md` C1–C8 and `profiles.md` A1–A5/F1, their cited examples and
  `grammar.ebnf` under `semantic/specification/interface-language/`.
- Human findings H5–H6 in `first-path-reading-k48`.

## Work

Read both whole pages and enumerate construct introductions. At each new
syntactic relationship supply an explained, located snippet: places/regions,
nominal and callable contracts, outputs/outcomes, callback-use blocks,
relations, profiles/ABI references and access blocks. Teach its surrounding
declaration before combining terms. Reuse the model and examples already
landed; add only the necessary specific detail views or railroad slots.

Use the preceding draft's boundary convention for non-normative additions.
Preserve normative wording, anchors, grammar and F1 catalogue. Compare
preserved content with the pre-edit version, and verify new snippets and
their stated context. Account for introductions in task notes, not process
boilerplate on reader-facing pages.

## Done when

- Both pages supply local teaching context while their exact rules remain
  recoverable unchanged.
- The complete three-page draft follows §9.7, with source-backed examples,
  direct-entry routes and explicit art handoffs.
- `task docs:check` passes and the next copy-edit leaf covers all three pages.

## Notes

This is the last draft. Cut copy-edit under rule-reading-k49 with the bare
stem rule-reading and the specific whole-set handoff. Its later stages add
art and proof lazily. Unresolved substantive residue goes to the scheduled
human checkpoint rather than another unattended correction cycle.

## Decisions (running log)

D1 — The named structure brief is documentation plan §9.7. It states the
reader ("arrives directly at a rule"), outcome ("place a newly introduced
construct in the language model"), ordered placements 1–6, and explicit
Emphasis/Non-goals. This human-set structure is the design for this draft.

D2 — Reuse k50's paired reading-aid markers and preserve the canonical bytes
against revision `87221b8c`, before either draft. New aids use existing Store,
Counter and Subscription fixture contracts wherever possible; narrowly scoped
constructed fragments supply remaining syntax. All are labelled with their
omitted context. No complete new package, provider or semantics is introduced.
Art owns the selected syntax views; copy-edit will read all three rule pages.

D3 — Enumerate C1–C8 and A1–A5/F1 introductions from the complete original
pages, including table clauses and prose-only constructors. The local supports
are places/regions, nominal lifecycle, callable effects and reference inputs,
pointee access, extent/contents, outcomes and escaping borrows, callback uses,
global storage, rejection, dependencies and profile namespaces, access paths,
callback representation, data representation, compatibility and consumer views.
L5/L6 already own nominal relations and pattern relations; link those existing
introductions where this page depends on them rather than invent new relations.

D4 — Spend the single leaf-wide review allowance on technical truth of the
new contract/provider aids. The claim is that the located fragments and their
explanations preserve ownership, storage, scheduling and provider boundaries;
source equality alone cannot establish that. Give one fresh reviewer the
artifact and its canonical contract, asking for concrete contradictions,
unsupported claims and misleading omissions. This is the only review context.

D5 — The reviewer reported one valid/actionable finding: the A2 Handler
extract advertised a complete declaration but lines 18–36 included the prior
Subscription closing brace and missed Handler's closing brace. Corrected it
to lines 19–37 and its exact source. This was an extraction error, not a
semantic redesign; the example check verifies equality and a direct balanced
declaration check verifies the scope. No findings were classified as an unclear
contract, accepted trade-off or noise. No second reviewer is needed or used.
Self-inspection also corrected the L5 literal cross-reference to `literal(16)`
and made A5's parameter-order example explicitly concern a multi-parameter
callable. These are source-exact clarifications, not changes to the rules.

D6 — Read the expanded three-page draft and match the original construct
introductions to the inventory below. Exact rule order and canonical anchors
remain intact. New pages route direct readers to L2's language model, the
domain explanation, complete fixtures and the connected concept pages. The
README's existing links reach the expanded rule pages, and direct C1/C5/C6/A1/A2
entries place the selected clause in a containing declaration. Figure slots
are specific art handoffs, not claims of finished diagrams. No language
decision changed; the ADR set needs no revision. Human comprehension remains
the scheduled checkpoint's question.

D7 — Final `task docs:check` passed: 19 files checked, all 17 Markdown pages
reachable, AIL fences matched their sources, and all 11 existing SVGs regenerated
identically. The 67 input paths and SHA-256 digests matched item by item before
and after the run: interface-language tree, documentation-checker directory
(ignored caches excluded), root Taskfile, documentation plan and audit.
Manifest SHA-256:
`3c65e733f6ade557d2c7f20987f3016fee275f793f23df97935ce7da430ea0b1`.
Measured page SHA-256 values:

- `language.md`: `44dbfd928d6b87c650d7298c80885068855063a30675f3752bcfac114a47c254`
- `contracts.md`: `d39ba30aff5860426eea4a978922ec6f666f629a66fdba241f9e74d919e6ab47`
- `profiles.md`: `a3a8cf766dab3626c6f8710c0c6c6cacf4b69c4d9471d6d386472348e86446a8`

Separately, stripping each full marked block recovered all three canonical
pages byte for byte against revision `87221b8c`, including F1. Each page's
marker IDs are unique, boundaries pair, and canonical anchors match. A
deliberate MUST-to-MAY change in each recovered page failed its comparison.
The grammar, conformance record and frozen buffers/objects/callbacks examples
also matched that revision exactly. All fences in the two changed pages have
balanced containing braces. Handler starts at its declaration and closes
exactly; the prior shifted range fails the same scope check. These checks
establish source consistency, not parser/semantic-validator acceptance or
native implementation truth. No docs tool or Taskfile implementation changed.

Graph evidence: Tier 2, project
`Users-antony-Development-APIAnyware.improve-api-interface-language-docs`,
generation `2026-09-23T09:55:55Z`. The bounded contracts/profiles file search
returned zero rows and no more pages, so no structural conclusion was drawn.
Coverage reported changed Markdown metadata and excluded examples/design
directories; grammar was untracked. All material evidence used direct current
source reads. No graph-completeness claim follows.

D8 — Queue the required whole-set copy-edit under rule-reading-k49, then
retire rule-reading-k51. No live copy-edit sibling already exists. Its body
inherits the specific art handoffs and canonical-preservation convention from
the node brief. The node still has live editorial work, so no close or ancestor
promotion is due. Further substantive residue goes to first-path-reading-k64,
not a new unattended correction run. Only Grove task/brief bookkeeping changes
after the measured inputs above.

## Construct inventory and local support

Read both whole original pages, including prose and every table row. Extracted
all clause/constructor-shaped tokens from the preserved original text, then
classified them below. This covers introductions, not every allowed combination
or an exhaustive future reference entry. Named inline variants use the same
containing clause shown by their snippet and state the required missing support.

| Introduction | Local support and exact rule |
|---|---|
| C1 slots, local places, reference leaves, aliases, nullable leaves and nested storage | Canvas/Selection inspection; `.field`, `.*`, `[]`, result field and callable slots; bare type versus `@`/`$` routes to L2; exact type/null constraints remain adjacent |
| C1 `call`, `static`, `owner`, output borrow and earlier invalidation | Located Store view distinguishes input `valid` from outcome `give`; constructor nesting explained; C7 supplies static global; C5 supplies invalidator variant |
| C2 lifecycle/unique/`@destroy`, refcounted `runtime`, sharing/isolation and captures | Store/destructor siblings and complete Counter declaration; scalar Point contrast; C6 Handler with callback captures; L5/L6 relation routes |
| C3 execution, completions, executor, concurrency, reentrancy, mutation, variadic | Located Store view effects; distinguish entry location, independent overlap, nested entry and completion; async/variadic provider boundary explicit |
| C3 input/consume/borrow, retain/none/strong/copy/weak/unretained, valid | Store borrow versus destructor consumption versus Subscription retention; same-position retention variants labelled conditional, with F1 copy limit and output-owner condition |
| C3 direction, aliasing, pointee input and property consistency | Located `copy_bytes` pointer/storage distinction; `in`/`out`/`inout` and aliasing variants; C5 reference replacement; Counter property source already located in L5, whose storage consistency rule remains linked |
| C3 `requires`, `capability`, `outside_callback` | Hypothetical Panel optional member, explicitly outside F1; located unsubscribe precondition in C6 |
| C4 extent/one/buffer, length/capacity, bytes/elements, contents/binary/text/none/nul | Copy destination and constructed three-code-unit text input; zero length/capacity contrast, scalar-place bound variant and representation route |
| C5 outcome/when/meaning, completion partition, any/null/nonnull/equal/range | Located Boolean `copy_bytes` outcomes and same-position nullable/integer variants; scalar result validity distinguished from invalid output buffer; provider boundary for thrown/cancelled/terminated remains explicit in C3/F1 and the adjacent rules |
| C5 state valid/invalid/unchanged, give owned/borrow, invalidated_by | Located `inout` Counter replacement, Store result borrow/owned-create contrast, aggregate leaf explanation and refresh variant linked to complete tutorial packages |
| C6 callback declaration versus callback-use, timing/count/scope/executor/concurrency/reentrancy/quiescence | Full Handler declaration, subscribe/use block and unsubscribe; callback field variant, call-scoped companion-clause contrast, retained owner and no-delivery/no-termination promise |
| C7 global/constant, static output clauses, extent/contents, sharing/isolation and mutable storage | Full pointer_value declaration with output clauses at declaration scope; constant and confined mutable-scalar comparisons, L5 literal link |
| C8 missing facts/contradictions/unknown vocabulary, consumer restrictions and truth | Single impossible-extent fragment plus missing/unknown variants; coherence versus implementation truth; generator reentrancy restriction example |
| A1 profiles, ABI entries, manifests, pinned aliases/environment, namespace clauses/types/constructors | Located dependency package and Counter profile fact; alias versus identifier/digest; F1 boundary and L4 profile-type route |
| A2 access name/environment list, abi/via/mapping/compatibility, explicit/implicit receiver | Located Counter function with both paths; named-mapping variant conditional on provider; symbol route to existing canvas fragment; no document-order selection |
| A2 callback_abi and representation | Complete Handler declaration at correct source lines 19–37; captures and registration route to C6 |
| A3 representation recipe, scalar/record facts versus layout, load/address/source-expression | Point field-order example linked from L2 and two located data access blocks; explicit F1 limit on data expression evaluation |
| A4 stable/artifact/source | Counter's two actual clauses, source recipe contents and hypothetical artifact clause in the same position; build-id boundary explicit |
| A5 authoritative views, semantic equality and authoring round trip, target limitations | Located Store output contract and Counter path choices; clause reorder, multi-parameter order, field order and set-list comparisons |
| F1 pins, mechanisms, runtime/closure/text, sendability/actor and capability limits | Existing local dependency, path, data and callback examples reused; Counter profile clause and conditional actor/isolation pair; frozen catalogue untouched |

The original contracts token enumeration was: aliasing, borrow, buffer,
capability, completions, concurrency, contents, copy, count, direction, equal,
execution, executor, extent, give, input, invalidated_by, isolation, lifecycle,
meaning, mutation, nonnull, null, outside_callback, owner, quiescence, range,
reentrancy, requires, retain, runtime, scope, sharing, state, strong, text,
timing, unretained, valid, variadic, weak and when. Profiles added abi,
alias::clause, callback_abi, compatibility, fixture::actor,
fixture::sendability, mapping, representation and via; its overlapping tokens
are accounted for above. The surrounding prose-only introductions were checked
in the same section inventory rather than inferred from this lexical list.
