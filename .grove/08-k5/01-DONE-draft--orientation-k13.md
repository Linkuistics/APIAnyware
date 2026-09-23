# orientation-k13

## Goal

Draft `README.md` (a rewrite as the landing page), `explanation/unsaid.md` and `glossary.md` from their sources, owning their structure and technical truth.

## Context

- Structure brief: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §9.1. It states the reader and outcome, the ordered
  sections with their purposes, and the emphasis and non-goals. Quote it
  rather than re-deriving it.
- Prose contract, labels, figures and checks: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §4–§7.
- Evidence: the audit (`semantic/docs/research/interface-language-documentation-audit.md`) and the survey's §9 criteria D1–D8.

## Done when

- The three pages follow §9.1's section order, or the draft records why a
  section moved.
- Every obligation named on `explanation/unsaid.md` maps to a rule identifier,
  even where the page shows no AIL. Every domain term in the root brief has a
  defining location.
- The existing README's status and scope statements survive with their
  meaning intact.
- Pages that do not exist yet (the concept pages, tutorial, reference and
  review guide) are named as plain text, not linked, under the staging rule in the plan's §3.
  Each page's next route points to an existing page.
- Figure slots G1 and G4 are recorded under `## Handed forward` in the node
  brief for `art`.
- `task docs:check` passes.

## Notes

The synthetic C header on `explanation/unsaid.md` must be labelled synthetic. It makes no claim about a real library. Keep the landing page short enough to reach the domain page within one screen.

This is the node's last draft session, so its last act is `leaf-add` of the `copy-edit` leaf, unless a live later sibling already holds one.

## Decisions (running log)

- §9.1 supplies the structure precondition: reader/outcome, “The primary reader,
  arriving with no context … can state what AIL is and its status”; order,
  “A small API” before “What the header does not say” before “Reaching the
  code”; emphasis, “Concrete failure before abstraction, and domain obligations
  before any AIL syntax”; non-goals, “No clause-by-clause coverage”. Keep that
  order. The README's page-one block follows its opening definition/status;
  the domain route remains near the top.
- Use three synthetic C functions: opening a watch also registers its callback,
  a view operation exposes bytes and an output length, and closing destroys the
  watch. Contrast possible contracts without claiming that the header establishes
  one. This is a domain illustration, not an AIL package or a fixture mapping.
- This leaf concerns documentation only. No structural code exploration or
  graph evidence is needed; the project listing confirms no index for this
  workspace. Sources are the directly read normative documents and named briefs.
- Keep later pages as plain-text titles with existing interim routes. Record G1
  and G4 for art in the node brief; the draft's prose carries their facts.

## Draft inspection

The §9.1 order is preserved on all three pages. The glossary is alphabetical
(ignoring punctuation in “Re-entrancy”). No AIL fragments or new package claims
are introduced. The C header is explicitly a synthetic fragment with alternative
contracts, not an implemented API; the F1 context-pointer mismatch is explained.

| Obligation in `explanation/unsaid.md` | Checked authority | Boundary preserved |
|---|---|---|
| Ownership transfer | C2, C3, C5 | Consumption at entry on every outcome; retaining creates a separate obligation |
| Borrow validity/invalidation | C1, C5 | Owner survival alone is insufficient; invalidating calls act at entry |
| Buffer extent/contents | C3, C4 | Length versus capacity; terminator space; bounded core versus scanned profile |
| Failure/output states | C5 | Null need not mean failure; invalid outputs cannot be read or null-tested |
| Executors, concurrency, re-entrancy | C2, C3, C6 | Any-thread entry does not allow overlap; sharing does not imply safe concurrent mutation |
| Callback schedules/teardown | C2, C6 | Count/timing are independent; cancellation need not establish quiescence |
| Publication and consumers | L2, L3, C8, A5 | Completeness is scoped; validation is not binary truth or binding feasibility |
| Reaching code | A1–A5, F1 | ABI versus convention; source spelling versus path; lossy projection is distinct |

Root-brief domain inventory checked: FFI, ABI, ownership transfer, borrow
validity, quiescence, projections and profiles each have both a glossary entry
and a linked defining location in `explanation/unsaid.md`. The audit's added
terms (access path, slot, provider and closure) have glossary entries and exact
defining links. Familiar-meaning warnings cover borrow, owned, consume, shared,
copy, profile and both senses of closure. Deeper notation terms link directly to
their normative definitions until the concepts pages land.

Cold-start journey inspected: landing → domain explanation → C1–C6, with a
return to the map. Direct glossary entry → explanation subsection → canonical
rule is also connected. Existing normative, baseline and conformance pages and
all three `.ail` examples remain linked from the landing page. Later concept,
tutorial, reference and review pages are plain-text titles with existing interim
routes. Scope/status statements were compared with the previous README.

`task docs:check` passed after the first draft. This checks links, anchors,
reachability, fence tags and existing AIL example synchronization, not AIL
semantic validity or runtime behaviour. The semantic checks above are direct
inspection against the source rules; no parser or runtime was executed.

Final gate: `task docs:check` passed (10 checked files, 8 reachable pages;
example/fence checks passed). SHA-256 manifests before and after the run matched
for `Taskfile.yml` and every file enumerated under
`semantic/specification/interface-language/`, `semantic/specification/tools/`
and `semantic/docs/`. The gate's external URL is reported, not fetched. The
normative documents, grammar and committed `.ail` examples are unchanged.
