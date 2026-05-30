# 040-pdfkit-viewer

**Kind:** work

## Goal
Build `pdfkit-viewer` as an open-world standalone `.app` and VM-verify it in a
no-Chez VM.

## Context
- **Multi-delegate** app (spec §7): more than one delegate object wired
  simultaneously → multiple distinct `foreign-callable` trampoline signatures
  synthesised at runtime. New axis vs `030`: trampoline *multiplicity* under the
  embedded boot, not just a single delegate.
- PDFKit reach — confirm `(apianyware pdfkit)` facade links and the document
  renders from a bundled sample PDF (watch the Resources/ layout for the asset).

## Done when
- `pdfkit-viewer.app` builds via `bundle_app` (open-world standalone).
- TestAnyware run in a no-Chez VM is green: a PDF renders, page navigation /
  delegate callbacks work, visual bar met.
- Any multi-delegate / asset-bundling standalone quirk noted in
  `knowledge/targets/chez.md`.

## Notes
- If only one of several delegates fires, suspect trampoline-signature caching in
  `dispatch.sls` under whole-program optimisation rather than the app wiring.
