# full-set-reading-k12

## Goal

Run reader checkpoint 2 over the whole documentation set, after cross-set
navigation has landed. Establish, in the human's own words, whether the set
supports the review of AIL they want to make, and what further revision (if
any) the tree should hold.

## Context

- Documentation plan §8 and §1 (all six outcomes):
  `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`.
- Checkpoint 1's findings and dispositions, in `first-path-reading-k8`'s
  commit.
- Follow-up findings in `first-path-reading-k48` and the subsequent
  `first-path-reading-k64` assessment, and the model account's assessment in
  `model-reading`. Keep each read's reported extent and correction history
  distinct; do not infer approval of unreported pages.
- The model-first route (plan §3) and outcome 6 (plan §1): judge whether the
  reader can explain which model concept each construct expresses.
- The audit's closing "Step 2: refactored output" section, written by
  `reviewer-journey`.

## Work

1. Run the proxy reader as in checkpoint 1, over the whole set and all six
   outcomes, starting it from each direct-entry type in the plan's §3. Label
   its output as a proxy.
2. The human reads the set as a reviewer, starting from the landing page, and
   judges it against the root brief's completion conditions.
3. Triage the findings as in checkpoint 1. Revision work that is precise
   enough to state becomes leaves; revision work that is not stays on the root
   brief's horizon.

## Done when

- The human's verdict on the set is recorded in their words.
- Every finding has a disposition, and the root brief's horizon note on
  post-checkpoint revision has been resolved or restated.

## Notes

HITL. The same proxy-labelling rule as checkpoint 1 applies. Include direct
rule entries, their model/snippet support and links to the grammar/railroad
reference in the reading route. Assess model-reading-k73's example-led
refinement as well as the model-first structure. For VS Code preview, open
the interface-language folder or workspace root first so sibling figures load.
Further correction runs require the human's direction at this checkpoint;
the bounded runs authorized on 2026-09-28 do not authorize an unattended loop.

## Decisions (running log)

D1 — Retain the settled audience, draft-0.1 scope, model-first route and all
six reading outcomes in plan §1. Run one fresh-context proxy over the published
set, including each of §3's five direct-entry types. This spends the leaf's
one in-session reviewer allowance. Its reading observations are proxy evidence;
the human's verdict and reported reading extent are recorded separately. The
existing `task docs:check` supplies document-consistency checks. No production
code or new runtime test seam is in scope, and the settled procedure does not
require a full requirements grilling.

The parent confirmed the graph project
`Users-antony-Development-APIAnyware.improve-api-interface-language-docs`,
generation `2026-09-23T09:55:55Z`, and checked the corpus and checkpoint paths.
The design/research, examples and documentation-tools subtrees are excluded;
the published Markdown metadata is changed or untracked. The scope reports
known gaps with no remaining coverage page. Direct reads of the current
documentation, rather than graph completeness, supply this checkpoint's
evidence. No code call-chain claim is needed.

D2 — Preparation verification: `task docs:check` passed. Links checked 31
files with 29 pages reachable; example checks passed for 31 files; all 26
SVGs regenerated identically; reference coverage reported 229 candidates,
zero pending entries and zero errors. SHA-256 manifests before and after
the run matched item by item for every enumerated file under
`semantic/specification/interface-language/` and
`semantic/specification/tools/` (excluding bytecode caches), and for
`Taskfile.yml`, the documentation plan and the documentation audit. These
checks establish document consistency, not AIL execution or comprehension.

D3 — The proxy's preliminary direct-file observation is confirmed by reading
the complete `examples/buffers.ail`: it supplies the synthetic package and
surface but no route to its explanation. The landing page and review index
link the package to `review/walkthroughs.md#buffers`; the walkthrough itself
has model, rule and syntax routes. Plan §3 explicitly includes arrival at
`buffers.ail` as a direct-entry case. Treat the missing onward route from
the raw file as a documentation-navigation finding, separate from Q1–Q6's
language-design questions. Its final disposition awaits the completed proxy
response and human direction; the published corpus remains unchanged.

D4 — The proxy completed the assigned reading and returned the response
preserved below. It reports reading all 29 published Markdown pages, the
grammar, nine complete example packages and all 26 figure source/SVG pairs.
Its five entry probes share one accumulating context; they are not independent
cold-reader trials. Its attempted answers cover all six outcomes, including
the model-to-construct map, a guided ownership change, a pointer-input change,
an independently recorded open-enum prediction, scope-sensitive lookup and a
rejection condition. This remains model evidence only.

D5 — Triage of the proxy's numbered observations:

- P1 is valid and actionable documentation-navigation feedback, independently
  confirmed in D3. Recommend a bounded correction giving a reader who opens a
  raw example a discoverable route to its walkthrough, while preserving its
  AIL contract. The existing landing/index pairing is useful but does not
  supply a route from the file itself. Further correction requires this
  checkpoint's human direction; none has arrived, so no correction run has
  been cut and this finding's final disposition remains open.
- P2 is a visible trade-off already represented by Q6 in
  `explanation/choices.md`: section-level rule identities can require searching
  for the exact condition. The C6 anchor begins with its substantial reading
  aid; direct source inspection confirms the reported scanning cost. Retain
  Q6 without inventing finer normative identities or duplicating the language
  question. No new correction is authorized by this proxy observation alone.
- P3 and P4 are positive proxy observations, requiring no corrective action.
  They support preserving the stated boundaries, model routes, located
  snippets and figures; they establish neither human comprehension nor the
  independent effectiveness of any editorial stage.
- P5 records visible language-design trade-offs and disclosed scope limits.
  Retain the existing question register and provider/implementation limits;
  no missing semantics or new language question is established.

The human was invited to review the landing → model → explanations → tutorial
→ review-guide route, consult the reference and report their verdict and
actual reading extent. No new human assessment has been received. Earlier
positive feedback applies only to its recorded extent. This leaf remains live;
its human-verdict condition, P1's final disposition and the root brief's
post-checkpoint horizon are not yet settled.

D6 — Human assessment and direction, verbatim (2026-09-29):

> The documentation mentions Swift (as in 'extending Swift syntax'), but both the model and AIL are intended to also work for .Net and Linux/Wayland/Gtk/KDE (presumably C interfaces), so Swift is not priviledged in that way. It would also be useful to be able to describe Rust and other language libraries such that they could be consumed by other languages. Most likely not interpreted or untyped languages being consumed, but certainly as consumers (given our emphasis on types).
>
> Apart from that point, I am very impressed with your work. I hope we can later make the material somewhat more conversational and 'guided', but for now this is good.
>
> As far as the language itself is concerned, I would like (also later) to look at changing the generic clause syntax to more specific syntactic forms for each clause type, so it can looks less like a function-call style and also provide more suggestions about semantics through the syntactic forms and structure we use.

D7 — The human accepts the documentation for now with one present correction:
the model and AIL must be framed as independent of a privileged source language
or platform. Intended coverage includes .NET, the Linux/Wayland/GTK/KDE
ecosystems, Rust and other libraries with describable typed contracts. Keep the
API being described distinct from its consumers: interpreted or dynamically
typed languages remain intended consumers. The source-side emphasis is on typed
contracts; the human's "most likely" is a tentative scope preference, not a
normative prohibition on a language implementation technique. Do not turn the
ecosystem list or the tentative C-interface assumption into a claim that every
system exposes the same ABI or that draft 0.1 already supplies its providers.

The cited wording is in `explanation/choices.md`, *A dedicated syntax*.
The human did not report a page-by-page reading extent. Record their positive
verdict without inferring a cold-reader comprehension result or full coverage
of the six outcomes. More conversational guidance and exploration of
clause-specific syntax are explicitly later work; neither authorizes a general
rewrite or grammar change now. These are settled directions, so no full
requirements grilling is needed.

D8 — The dispositions are concrete. H1, the source/platform framing correction,
is the one ordered concepts run k95 draft → k96 copy-edit → k97 art → k98 proof.
The node brief and plan §1/§9.2 define its bounded document: landing page,
model account and choices, with affected summaries inspected across the set.
It preserves the rules, grammar, examples and eleven model concepts, and adds
no automatic re-read or correction cycle. The current session establishes
requirements and the handoff; that run owns the prose correction.

H2, the later conversational/guided presentation, stays on the root brief's
horizon and in the durable audit reader-evidence section. H3, later
clause-specific syntax exploration, is now Q7 in the published choices page
and audit. It invites a later comparison on the same API contracts without
changing the grammar now. The root brief's previously unspecified
post-checkpoint revision is resolved into H1 and these explicitly later aims.

P1 receives no separate correction run: the human identifies H1 as the present
exception and accepts the rest for now. Retain the index/walkthrough pairing
and disclose the raw-file navigation limitation in the plan and audit. This
is the checkpoint's scope disposition, not a claim that the human tested that
route. P2 remains Q6; P3–P5 keep D5's no-correction dispositions. No finding
is left without a disposition, and no unreported human comprehension is inferred.

D9 — Preserved the new evidence and proposed guidance in the existing Grove
issues, as requested at the earlier checkpoints:

- [#14: domain breadth, roles and the timing of feedback](https://github.com/Linkuistics/grove/issues/14#issuecomment-5890462651).
- [#15: scope framing in structure briefs and syntax rationale](https://github.com/Linkuistics/grove/issues/15#issuecomment-5890463091).
- [#18: exact entry surfaces and distinct kinds of reader evidence](https://github.com/Linkuistics/grove/issues/18#issuecomment-5890463477).

Each posted body was read back through the API and matched its prepared text.
The comments preserve the positive verdict, source-scope correction and later
aims, and keep the human's unreported reading extent, proxy observations and
stage-effectiveness limits explicit. They are guidance proposals, not changes
already made to Grove's skills.

D10 — Final verification after the requirements and Q7 edits:
`task docs:check` passed (31 files checked for links/examples, 29 pages
reachable, 26 SVGs reproduced, 229 coverage candidates, zero pending entries
and zero errors). Before/after SHA-256 manifests matched item by item for
every enumerated file under `semantic/specification/interface-language/`
and `semantic/specification/tools/` (excluding bytecode caches), plus
`Taskfile.yml`, the plan and the audit. Comparing the corpus with the
pre-checkpoint manifest shows only `explanation/choices.md` changed, for
Q7 and its forward link. Canonical rules, grammar, figures and every `.ail`
file are unchanged. All four generated task bodies were read back and matched
their prepared content; their order is draft, copy-edit, art, proof.

D11 — Retire this requirements checkpoint. The human's verdict and known
reading extent are recorded, every finding has a disposition, the root
horizon is resolved into one current correction and two explicitly later aims,
and the new evidence is preserved in the existing guidance issues. The queued
concepts run owns the source/platform prose correction. No ancestor node
closes: this leaf is at the root, and concepts-k6 again has live work.
No ADR change is needed for this framing/requirements clarification; the
language's rules and implementation scope have not been redesigned.


## Proxy reader response

The following is the proxy's returned response, preserved verbatim. Paths are
relative to `semantic/specification/interface-language/`; abbreviated paths
retain the proxy's wording. It is not the human's assessment.

This is a **model-proxy reader response**, from the requested perspective of a language designer new to API binding. It is evidence of this model’s task attempts, not evidence of human comprehension or a human verdict.

I enumerated 29 published Markdown pages before reading them, and read every page:

- Root: `README.md`, `baseline.md`, `conformance.md`, `contracts.md`, `glossary.md`, `language.md`, `profiles.md`.
- Explanation: `unsaid.md`, `model.md`, `contracts.md`, `packages.md`, `choices.md`.
- Tutorial: `README.md`, `01-lifetime.md`, `02-lending.md`, `03-storage.md`, `04-callbacks.md`, `05-access-and-change.md`.
- Review: `README.md`, `walkthroughs.md`, `tasks.md`.
- Reference: `README.md`, `notation.md`, `types.md`, `declarations.md`, `clauses-package.md`, `clauses-callable.md`, `clauses-outcomes.md`, `clauses-access.md`.

The guided reading followed the requested explanation → tutorial → review progression, with direct-entry probes and reference consultation interleaved. I also read `grammar.ebnf`; directly inspected the complete buffer, callback and object packages and all six tutorial checkpoint packages; read the teaching fragments embedded throughout the pages; and inspected all 26 diagram sources and rendered SVGs, including all eleven railroad views.

I did not inspect implementation, history, planning/research artifacts or prior review artifacts. Links outside the permitted corpus were not followed. This was a paper exercise: no parser, semantic validator, native implementation or binding generator was assumed or tested. I read Markdown as source and figures as rendered images; this does not establish the behavior of a particular published-site renderer. No files changed.

**Direct-entry observations**

These probes shared one developing context. They were not five independently blinded cold reads.

1. **`contracts.md#c6`, then `language.md#l2`.** C6’s opening reading aid establishes the distinction that matters: `callback Handler(...)` describes an invocation, whereas `callback $handler { ... }` describes one registration’s schedule. Its local Handler and subscription snippets provide substantially more support than isolated clauses would. The model link is `explanation/model.md#callbacks`; retention, returned ownership and the destructor connect the schedule to an entity’s lifetime.

   L2 supplies the missing name structure: `Canvas` and `position` are package-level siblings; `Geometry::Point` comes through an import alias; `member(@Canvas, instance)` associates the function with its owner; `$canvas` addresses the local value, while `@position::canvas` identifies its slot externally. The G9 containment diagram makes these relationships visible.

   Exact syntax is reached through `reference/notation.md#callable`, `#callback-use`, `#names` and `#places`, then `grammar.ebnf`. The railroad distinguishes the two callback forms immediately. C6 also provides onward routes to clause lookup, the complete callback package, tutorial part 4 and teardown tasks. Context was recoverable without returning to the landing page.

2. **`explanation/model.md#callbacks`.** This entry establishes the domain meaning before notation: invocation arguments and results, registration timing, count, overlap, captured state and the point after which no invocation remains possible. It connects callbacks to execution and lifetime concepts without treating cancellation as completed teardown.

   There is no local AIL block in this model section. Concrete syntax is supplied by the linked contract explanation, tutorial part 4, callback-use declaration entry, and `scope`/`quiescence` reference entries. Those lead to the callable and callback-use railroad views and canonical C6. This is an effective conceptual entry, with an intentional additional step before syntax.

3. **`examples/buffers.ail`.** The file itself provides `language`, package identity, a synthetic `surface`, complete declarations, and Store’s immutable sixteen-byte description. I could trace creation, destruction, borrowing, copying and the lifetime pattern directly.

   It contains no onward documentation link. To obtain binding-domain context or locate the exact grammar, I used the already-known README route to `review/walkthroughs.md#buffers`, then the model, clause reference and notation pages. The walkthrough establishes what the clauses mean together; `#places`, `#outcome`, `#pattern` and the generic clause grammar explain their forms. This recovery depended on navigation outside the example file. That is the clearest direct-entry documentation gap encountered.

4. **`glossary.md#quiescence`.** The entry gives a useful operational definition: for the registration being ended, no invocation is running or can begin. Its cancellation contrast prevents the tempting inference that a returned cancellation request makes captured state disposable.

   The entry links to `model.md#callbacks`, the domain teardown explanation, C6, `requires`, `quiescence`, and `review/tasks.md#stretch`. It contains no local AIL snippet or direct railroad link; the clause entry and C6 supply a situated snippet, then the callback-use and clause grammar routes. This extra hop is reasonable for a short glossary entry.

5. **`reference/clauses-outcomes.md#scope`.** This entry immediately identifies the model concept, forms, operand meaning, applicability, requiredness, constraints and rejection conditions. Its registration/destructor example supplies the owner context that `scope(owner($result))` alone would lack.

   `scope` occurs exactly once in a callback-use block. Call scope requires during-call timing, no retained callback, and quiescence at return. Owner scope requires the compatible returned owner, retention and teardown facts. `scope(call)` with `timing(after_return)` is explicitly rejected. The Form route leads to the callback-use railroad; `#clause` and the canonical grammar give the nested constructor syntax. Links to timing, retention, quiescence, tutorial part 4 and review tasks support further investigation.

**Task answers**

**1. Problem, authors and users.** AIL proposes a shared declarative account of an existing API for tools that must preserve its behavior across languages. A signature supplies names, types and parameter/result structure. It leaves questions such as release responsibility, borrow duration, output readability after failure, pointer bounds, callback teardown and access mechanisms unanswered.

An API author, analysis tool or third-party producer writes a package covering a stated surface and its required dependencies. The producer resolves missing or conflicting facts before publication. Proposed validators check completeness and consistency; binding generators, documentation renderers and LLM tools consume the same facts. A valid description can exceed a particular binding generator’s capabilities, and validity does not prove that an implementation honors it. These distinctions are established in the README’s producer/consumer section, `explanation/unsaid.md`, L3, C8 and A5.

**2. Worked example, paper change and prediction.** I can follow the tutorial’s chain of obligations. Successful Card creation gives one destruction obligation; null allocation failure gives none. `current_label` lends a Label tied to that Card. Entry into `refresh_card` invalidates the earlier borrow while the Card remains alive; destruction also ends it. The caller must not pass that borrowed Label to a consuming destructor.

`copy_text` requires eight bytes of writable capacity. On status 0, seven UTF-8 code units plus the terminating zero are available. On status 1, the status remains readable but the destination output cannot be inspected, including by searching for a terminator. A Watch has its own lifetime: it retains the callback, retains no Card, and becomes quiescent when `destroy_watch` returns. These answers follow tutorial parts 1–4 and C1–C6.

I followed part 5’s owned-snapshot change on paper: change the returned obligation to `give($result, owned)`, remove the borrow’s `invalidated_by`, and select the owned-result API variant and access symbol. The input Card remains borrowed only for the call. The returned Label can survive Card refresh and destruction; the caller now owes `destroy_label`. Merely editing ownership syntax while retaining an implementation that returns a borrow would make the description false. The supplied `05-owned.ail` makes the changed package and access identity inspectable.

For the review task’s modest pointer-input addition, I would append `tag: ptr<u8>` to `copy_bytes` and supply:

```ail
input($tag, borrow);
retain($tag, none);
valid($tag, call);
direction($tag, in);
aliasing($tag, disjoint);
extent($tag, buffer(4, 4, elements));
contents($tag, binary);
```

The four bytes are initialized input, read during the call without retention. They require no output `state` or `give`. The destination’s existing output contracts remain applicable. The changed signature needs the task’s new access symbol and revised package/surface identity; identity mapping must account for the additional parameter. This is supported by `review/tasks.md#change`, C3–C4 and A2.

My separate prediction, recorded before checking the reference and canonical answer, was that changing `CopyStatus` from `values(closed)` to `values(open)` would make its existing 0/1 outcomes incomplete. L4 and C5 confirm this: every `i32` value becomes admitted, including negative values and values above 1. Additional exhaustive, disjoint outcomes would need authoritative meanings and output states. The documentation cannot supply those API facts by inference.

**3. Domain constraints versus AIL choices.** Callers need to know when storage is usable, which party owes release, and when callback state can be discarded. Those are binding-domain obligations. Whether this particular API lends or owns a Label is an API promise. Expressing that promise with `give`, `owner`, and an explicit invalidator list is an AIL design choice.

Other choices include a dedicated syntax, mandatory applicable facts, ownership in clauses, a closed vocabulary, exact environment configurations and versioned profiles. `explanation/choices.md` exposes alternatives and costs: a general data format, defaults, ownership-bearing types, broader predicates or environment ranges. Exact environments make claims bounded and checkable but require a potentially large publication matrix. Ownership clauses support outcome-dependent obligations but distribute facts away from the signature. Neither trade-off follows inevitably from the domain.

**4. Critique across six dimensions.**

- **Syntax/readability:** Familiar declarations, braces and uniform clauses are straightforward to scan. `$` versus `@` gives a useful visual distinction. The cost appears in nested forms and the amount of repetition: the worked `view` contract contains 23 clauses across its scopes.
- **Conceptual consistency:** Transfer, retention, validity and mutation remain distinct through explanations, examples and rules. Callback invocation and registration likewise have separate subjects. Reused names such as `executor` and `concurrency` require close attention to their enclosing scope, which the reference explicitly addresses.
- **Expressive scope:** The core covers substantial lifetime, storage, outcome and schedule facts. It intentionally limits outcome discrimination, lifetime regions and pattern laws. Profiles carry significant additional semantic work. F1’s limitations are explicit; parseable async, throws or generic syntax does not imply supplied provider support.
- **Authoring burden:** Explicit absence prevents omissions from becoming silent defaults, but even a small call requires many facts. Following one borrowed result can involve its outcome, owner type, invalidator and destructor. The tutorial makes that work visible; it does not establish that gathering the facts is economical for production APIs.
- **Discoverability:** Clause entries have a predictable lookup structure and strong links to the model and rules. Markdown direct entries are well supported. Raw example entry is weaker, and precise normative lookup can require scrolling through long reading aids after arriving at a broad rule anchor.
- **Producer/consumer fitness:** One publication standard and preserved source observations are valuable for agreement between consumers. A5 distinguishes binding limitations from malformed AIL. Producer feasibility remains a practical question: `baseline.md` identifies facts the existing model lacks, and no working production toolchain is claimed.

**5. Exact lookup.** For a scope-sensitive lookup, `reference/clauses-callable.md#concurrency` gives the two values and its applicability to functions, callback declarations and callback-use blocks. Callable seriality governs independent overlap; re-entrancy governs nested entry separately. The registration’s concurrency fact cannot relax the callback type’s own contract. C3, C6 and C8 establish the compatibility obligation.

For a rejection lookup, `give($result, borrow(call))` in the Store view has valid generic clause syntax but violates C1/C5 because an escaping borrow’s region must survive delivery. `conformance.md` names this N07. N15 independently rejects call scope paired with after-return timing. These are semantic failures, not missing punctuation.

Declaration and type lookup also worked: `reference/declarations.md#fn` and the applicability table identify the function’s required contracts and access; `reference/types.md` and L4 explain that a resource already denotes a handle, `ptr<Resource>` denotes storage containing one, `unit` is result-only, and nullable integers are invalid. Grammar determines shape; the typed reference and canonical rules determine admissibility.

**6. Model and construct mapping.** The model separates call facts from the published description and access machinery. Operations receive and produce values; outcomes determine readable outputs and delivered obligations; handles identify entities whose lifecycles govern release; regions and invalidators bound access to storage; execution and callback schedules constrain permitted calls. Packages gather those facts for selected environments, dependencies and access paths.

The corresponding AIL groups are visible:

- Signatures, types, slots and places → operations and values.
- `outcome`, `when`, `meaning`, `state` → observable completion and usable outputs.
- `resource`, `lifecycle`, member/property relations and patterns → persistent entities.
- `input`, `retain`, `give` → release responsibility.
- `valid`, regions and `invalidated_by` → validity.
- `direction`, `aliasing`, `extent`, `contents` → storage.
- Sharing/isolation and callable effects → execution.
- Callback declaration, use block and quiescence → callable values and registration schedules.
- Package/import/environment/availability and access clauses → description and realization.

An unfamiliar construct I traced was `subject(preparation, @prepare::session)`. `reference/clauses-access.md#subject`, `model.md#entities` and L6 explain why it exists: the ordering law must identify the same resource instance across two operations. Matching parameter spellings would not establish that relationship.

**Numbered findings and positive observations**

1. **Documentation navigation finding:** provide an onward reading route at the raw buffer example’s entry. `examples/buffers.ail` supplies its contract but gives a newcomer no link to its walkthrough, model or syntax reference. This caused an observable navigation detour, though it did not prevent the task after the landing map was known.

2. **Lookup friction:** distinguish arrival at a rule’s exact requirements from arrival at its explanatory reading aid. C6 and other broad anchors serve both purposes, so exact lookup involves further scanning. This supports the already disclosed precision concern in `choices.md#q6`; it is not evidence of missing semantics.

3. **Positive observation:** preserve the repeated separation between description validity, implementation truth and consumer feasibility. It prevented me from treating fixture syntax acceptance, `state(valid)`, or an identity mapping as proof of native behavior.

4. **Positive observation:** the model links, located snippets and figures work together. G9 resolves containment versus association; the lifetime and callback timelines distinguish entry from completion; the railroad captions explicitly limit themselves to syntax. No visual ambiguity in those inspected figures blocked these tasks.

5. **Open language questions and disclosed limits:** ownership presentation, repeated clause burden and precise rule addressing remain worthwhile design questions. The corpus already acknowledges several of them. F1’s restricted capabilities, missing production providers, bounded baseline mapping and future implementation work are disclosed limits, not newly discovered documentation defects. This proxy could answer the six outcomes on paper; the human reader’s assessment remains separate.
