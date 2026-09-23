# orientation-k27

## Goal

Copy-edit the whole orientation set: `semantic/specification/interface-language/README.md`,
`explanation/unsaid.md` and `glossary.md`, for sentences, terminology and consistency
with the prose contract. Preserve the draft's structure and technical truth.

## Context

- Structure brief: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`
  §9.1; prose contract and page-one block: §4–§5; checks: §7.
- The survey's copy-edit criteria are in
  `semantic/docs/research/documentation-basis-a.md` §9.
- Draft inspection and rule traceability are recorded in `orientation-k13`.
  The C header is a synthetic fragment whose possible contracts are compared,
  not an implemented library or a translation into the synthetic fixture profile.
- The node brief holds G1/G4 figure slots for art. Leave their drawing to that
  stage. The new concept, tutorial, reference and review pages do not yet exist;
  keep their names as plain text and the interim routes pointing at real pages.

## Done when

- Read and copy-edit all three pages against §4. Check clear caller/callee
  actors, first-use term links and warnings, sentence-case headings, code
  typography, non-normative summaries and rule links. Preserve the distinctions
  between consumed input and retention, owner lifetime and invalidation,
  any-thread entry and parallel access, and cancellation and quiescence.
- The landing page still gets a new reader to the domain explanation near its
  top; its scope/status statements retain their meaning. Glossary entries remain
  alphabetically ordered (ignoring punctuation in “Re-entrancy”).
- `task docs:check` passes. This is a documentation gate, not an AIL validator.
- Add the `art` successor with the bare slug `orientation` unless a live later
  sibling already holds that stage, following the editorial-family procedure.

## Notes

Do not silently repair structural or technical defects outside this charter;
use the editorial correction-run procedure if one is found. The prose carries
all figure facts already, so the pages are usable before art lands.
