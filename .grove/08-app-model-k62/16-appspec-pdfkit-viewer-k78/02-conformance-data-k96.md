# conformance-data-k96

**Kind:** work

## Goal

The pdfkit-viewer **conformance data**: `logging-contract.md` + `observable-state.md`
at `apps/macos/pdfkit-viewer/docs/` — the porting-guide contracts every impl satisfies
(the hello-window k67 / ui-controls-gallery k87 stage), derived from the accepted
reverse-gen spec (k95) and the four impls.

## Context

- Templates: `apps/macos/{hello-window,ui-controls-gallery}/docs/{logging-contract,
  observable-state}.md`.
- The k95 spec fixes the surface: launch diagnostic (line begins `PDFKit Viewer`),
  the `No PDF loaded` / `Page n of N` label rule, nav-button enabled flags as the
  reliable AX navigation-state signal, open/cancel/failed-open silent no-ops, and
  Quit via ⌘Q. Event vocabulary must cover what the forward-gen scenarios will
  assert: launch, document-open (title/page-count, not pixels), page-change
  (new index), shutdown reason.
- k77 lesson: post-state emission (state applied before the event line), lowercase
  `reason`, `shutdown reason=menu` as the exercised terminate path.
- The k95 fixture rule (open panel is the only document source; N ≥ 3 pages,
  keyboard-driven out-of-process panel) shapes the observable-state doc's
  document-state section.

## Done when

Both contract docs committed under `apps/macos/pdfkit-viewer/docs/`, consistent with
the k95 spec and realizable by all four impls (the instrument-builds children will
implement them verbatim).

## Notes

Observable state captures loaded-document title/page-count and current page index —
never rendered pixel contents (node brief).
