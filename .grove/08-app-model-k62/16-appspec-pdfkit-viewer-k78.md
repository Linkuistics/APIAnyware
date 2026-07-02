# appspec-pdfkit-viewer-k78

**Kind:** work

## Goal

The full AppSpec cycle for **pdfkit-viewer** (the PDFKit document viewer): reverse-gen
the spec from the four VM-verified impls, instrument to the contracts, rebuild,
forward-gen the scenario suite, Tier-2 live-run all four impls.

## Context

Same shape as `appspec-ui-controls-gallery-k77` — hello-window (k64/k67–k74) is the
worked template; drive via `~/Development/AppSpec/capabilities/*/workflow.md`; data
homes at `apps/macos/pdfkit-viewer/` + the per-target
`app-implementations/macos/pdfkit-viewer/` (ADR-0052 / AppSpec ADR-0013).
**Expected to decompose on entry** (`leaf-decompose`; first child only that session).

App-specific: needs a PDF **fixture** the suite can load deterministically — fixtures
are lazy + assertable (ws4 D3); home it with the app's scenarios, not in the toolkit
(no app data in AppSpec).

## Done when

All four impls run the forward-gen suite green in a live VM ([[vm_verify_every_app]]);
`docs/run-results.md` authored. Commits name the child handles.

## Notes

Document-open + page-navigation are the behavioural core; observable state should
capture the loaded-document title/page-count, not pixel contents.
