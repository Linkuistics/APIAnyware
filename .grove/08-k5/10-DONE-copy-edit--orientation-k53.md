# orientation-k53

## Goal

Copy-edit the examples-and-notation correction across `README.md`, `explanation/unsaid.md` and `glossary.md`.

## Context

- Human assessment and H5–H7: first-path-reading-k48, D2–D5.
- Structure brief: documentation plan §9.1; general requirements:
  §4–§6 and §9.7.
- Rule-reading-k49 supplies the canonical examples, language model and selected
  railroad views. Read their landed form and this node's Handed forward list.
- Paths are relative to semantic/specification/interface-language/.

## Work

Check that each example is introduced in terms the reader already has, that the names and containing package/callable are explicit, and that glossary entries explain rather than merely repeat symbols. Preserve the domain-first watch explanation and positive framing.

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

D1 — Keep the existing section order, watch-domain examples and checked AIL
fragments. The copy-edit closes sentence-level defects: link the overview's
first declaration term to its glossary owner; replace “place the notation” and
“source-compiled access” with the relationship and action they mean; explain
`sync` through completion and return rather than repeating “synchronous”;
name the package behind “geometry identity”; and replace the member entry's
spatial braces description with its explicit package-level association.
The completion explanation follows C3, including its lack of an eventual-finish
promise. No normative text, example contract or figure changes are required.

## H5/H6 disposition and editorial inspection

Read all of README.md, explanation/unsaid.md and glossary.md against plan
§4–§6 and §9.1/§9.7. Paths below are relative to the interface-language directory.

| Location | Copy-edit disposition |
|---|---|
| README workflow, scope and routes | Added the first-use declaration link. Retained the actors/actions explanation, L1/L2 reading order and distinction between model, syntax and semantic rules. No new notation needed local explanation. |
| Unsaid header, obligations and tables | Retained the introduced watch functions, callback/context and `length`/`*length` distinction. Alternative contracts and the separate synthetic callback fixture remain explicit. |
| Unsaid access and next route | Expanded source-compiled access into the compiler's action and replaced “place the notation” with the package/function relationship the linked examples show. |
| Glossary declaration and identity (H5) | Retained the located Point fragment and explicit identity tuple; replaced “geometry identity” with the named package. |
| Glossary local/imported and Import (H5/H6) | Retained explicit package-relative locality, Geometry alias, type/reference spellings and placeholder-digest warning. |
| Glossary member (H5/H6) | Named Canvas and position's containing package directly and described following the member clause to the owning type. Receiver and static-member distinctions remain explicit. |
| Glossary callable, clause and slot (H6) | Explained execution(sync) through completion before return, with the no-eventual-finish limit from C3. Retained callable-qualified slot names and their distinction from local places. |
| Glossary package and place (H6) | Retained explained versions, braces, export list and declaration reference; the located canvas clauses identify caller/callee actions and Point supplies the selected field. |
| Remaining glossary entries, captions and links | Read for terminology, actors, concrete cases and familiar-meaning distinctions. No additional actionable copy-edit defect identified. |

All AIL fences and source fragments remain unchanged, including their omissions
and synthetic boundaries. Page order and headings are unchanged. G1/G4 captions
retain their domain cases; rendered-figure inspection remains the art stage's
work. No structural or later-charter defect was identified for handoff. These
are editorial observations, not evidence of human comprehension; that remains
first-path-reading-k64.

D2 — The live art and proof siblings orientation-k54/k55 already supply the
successor stages. Add no duplicate and leave orientation-k5 open. No ADR or
language decision changed. The bounded copy-edit does not require an in-session
reviewer or a further correction run.

Graph status confirmed the indexed project at Tier 2; coverage generation is
2026-09-23T09:55:55Z. Edited Markdown metadata is stale/untracked, and the design
and example directories are excluded. Relevant document and authority passages
were read directly; no structural-code or graph-completeness claim is made.

## Verification

`task docs:check` passed after the final prose edits: links and examples each
checked 19 files, 17 Markdown pages were reachable, and all 23 SVGs regenerated
identically. Before/after SHA-256 manifests matched item for item for 93 inputs:
the interface-language tree, documentation tools (excluding ignored caches),
Taskfile, documentation plan and audit. Manifest SHA-256:
`fcac31ba63a691fca34a59119670257481fa82dbd7a7d17ae38dba508776118e`.
Mechanical checks establish link/example consistency and diagram reproduction;
they do not parse AIL, validate its semantics or test reader understanding.
The C3 completion wording and named-package explanations were inspected against
the canonical text and existing snippets separately.
