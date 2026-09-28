# orientation-k52

## Goal

Apply the human's examples-and-notation requirements to `README.md`, `explanation/unsaid.md` and `glossary.md`.

## Context

- Human assessment and H5–H7: first-path-reading-k48, D2–D5.
- Structure brief: documentation plan §9.1; general requirements:
  §4–§6 and §9.7.
- Rule-reading-k49 supplies the canonical examples, language model and selected
  railroad views. Read their landed form and this node's Handed forward list.
- Paths are relative to semantic/specification/interface-language/.

## Work

Make the language-model and rule-reading aids discoverable from the overview. Give glossary introductions to declaration, local/imported declaration, member, slot and identity small named examples with context. Inspect the whole orientation for notation introduced without a referent. Keep the watch page domain-first: its C examples can teach the domain without turning it into a syntax reference.

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

D1 — The named structure brief is plan §9.1: the reader arrives “with no
context”; the outcome is to “state what AIL is and its status” and choose a
reading path. Its ordered README/domain/glossary plans specify each section's
purpose. Its emphasis is “Concrete actions and consequences before abstraction”;
its non-goals include “No clause-by-clause coverage” and no AIL syntax on the
domain page beyond a closing glimpse. All three draft preconditions are met.

D2 — Reuse the landed geometry/canvas names and route readers to L1/L2's
model and railroads. Add local, checked glossary fragments where a construct
needs its containing context; keep them explicitly incomplete and preserve the
placeholder import warning. The watch page keeps its C/domain teaching role.
No language semantics, normative text, frozen fixture or diagram change is
needed. Copy-edit, art and proof already stand ahead as k53–k55.

D3 — The sole fresh-context reviewer reported one P2 context gap: Callable's
first snippet omitted Canvas and the import and delegated their referents to
L2. Classified as valid/actionable, checked against §4 and the landed L2
geometry/canvas definitions. Added the exact local resource, import target,
Point fields and function action immediately before the snippet. This is a
bounded missing-context clarification, with no changed example or semantics;
no second review is needed or commissioned. The reviewer found no other
material semantic or naming inconsistency. No unclear-contract, trade-off or
noise findings were reported. Human comprehension remains unassessed.

D4 — Retire this draft after the final post-review check. No unresolved draft
defect or later-charter defect was identified for handoff. The live copy-edit,
art and proof siblings k53–k55 own the remaining stages, so no duplicate leaf
is added and orientation-k5 does not close. No architecture or language decision
changed, so the ADR set needs no update. First-path-reading-k64 retains the
human assessment; the editorial and mechanical results do not replace it.

## H5/H6 disposition and draft inspection

The inventory covers the whole three-page document, including inline code,
fenced examples, tables, captions and navigation. Inline-code extraction by
section supplemented the full read; it was not used as a semantic validator.

| Location | Disposition | Authority / boundary |
|---|---|---|
| README: workflow, scope and paths | Retained domain examples and the G1 workflow; added direct routes to L1 shell/key and L2 model/references, with reading order. Explained the reading-aid markers beside the canonical-file list. No new AIL tokens in the overview. | L1–L3, A1–A5; models teach containment, railroads teach syntax. |
| Unsaid: C header and obligations | The named watch functions, Notice/context and returned view already anchor the domain cases. Added the concrete distinction between `length` and C `*length` before the failure table uses it. All later C identifiers refer back to that header. | C1–C6; the alternatives are possible contracts, not a complete implementation. |
| Unsaid: reaching code, terms and next route | Retained the explicit distinction from the context-free callback fixture, synthetic provider limits, and familiar-term comparisons. Added a closing route to shell/model; it explicitly identifies the canvas example as a different API. | A1–A5/F1; no AIL syntax lesson added to the domain page. |
| Glossary: declaration and canonical identity (H5) | Added a located geometry record and the three concrete identity values. Fields belong inside Point; declaration identity belongs to its named/versioned package. The tuple is identified as prose notation. | Grammar document/nominal/field; L2/L4–L5. |
| Glossary: local/imported and Import (H5/H6) | Added the landed canvas model fragment with exact alias and type/reference spellings; linked from Import. Explained relative locality and identity preservation. The all-zero pin remains explicitly a placeholder, not a resolvable import. | L2; existing geometry/canvas reading aids and G9. |
| Glossary: member (H5/H6) | Added sibling resource/function fragment with explicit member and receiver clauses. Explained declaration `@Canvas` versus callable-local `$canvas`, and instance versus static receiver designation. | L2/L5; no nesting or implicit receiver invented. |
| Glossary: callable, clause, slot (H6) | Located function signature and execution clause inside canvas. Explained colon, arrow, bare type names, clause arguments/semicolon and callable-qualified slot references. Linked the separate Filter result and exact railroads. | Grammar callable/parameter/clause/reference/name; L2/L5/C1/C3. |
| Glossary: package | Reused the checked geometry shell; distinguished AIL version from package version and explained braces, surface, exports, list brackets and `@Point`. | L1–L3; fragment omits complete publication/nominal facts. |
| Glossary: place (H6) | Replaced unlocated `$length` examples with a located canvas parameter, its three input clauses and its qualified external slot spelling. Anchored `$result.x` to Point; routes to C1 locate pointer/buffer selections. | C1/C3; grammar place, exact leaf applicability. |
| Glossary: remaining entries | Domain-only definitions retain their concrete watch, byte-buffer, callback, consumer and provider cases. Isolation now states its absence in domain terms and links the located clause. Region's `static`, Output state's `inout` and Rust's `Copy` are named with their meanings and limits, not presented as standalone AIL syntax. Pattern/role/instance examples remain domain relationships, with exact L6 links. Rule IDs are citations. | Full rule-text read: L1–L6, C1–C8, A1–A5/F1. |

All new fenced blocks are labelled fragments and linked to committed sources.
The three new regions in `examples/rule-reading/glossary.ail` are independent
excerpts using the existing canvas/geometry context, not a new API fixture.
Their missing headers, imports, publication, nominal and callable contracts
are explicit. Existing full examples, normative pages, grammar and diagrams
have no changes in this leaf.

Structure read: the overview keeps its prescribed section order and domain
next route; the watch page stays a domain explanation; the glossary retains
alphabetical lookup and adds short local examples. No new figure slot is
needed: existing G1/G4 retain their roles, and L1/L2 supply G9/G10 where the
reader follows the new links. Figure-source names and relationships agree
with the examples. Sentence polish and rendered-figure inspection belong to
the queued stages, not a substituted in-session copy-edit or art pass.

## Verification

The final `task docs:check`, rerun after the review clarification, passed:
links and example equality checked 19 files,
17 Markdown pages were reachable, and all 23 SVGs regenerated identically.
The sorted subject list and SHA-256 manifest matched item for item before and
after the run: 93 files comprising the interface-language tree, documentation
tools (excluding ignored caches), root Taskfile, documentation plan and audit.
Final manifest SHA-256: `334f4be34efc9502e7b6298b9ad3a5bb258119c5caca4615bd0c078d72153b34`.
An initial shell invocation failed before running Task because a zsh special
variable shadowed command lookup; its empty digest output was discarded and
the complete measurement restarted with an ordinary variable name.

Grammar and contract consistency were checked by editorial inspection against
the source, separately from these mechanical checks. No parser, runtime or
human-comprehension result is claimed. The latter remains first-path-reading-k64.
Graph generation 2026-09-23T09:55:55Z was confirmed at Tier 2; coverage reported
changed/untracked Markdown and excluded design, example and tool directories.
The relevant documents, source fragments, grammar, normative rule text and
checker contracts were read directly. No structural code or graph-completeness
claim is made.
