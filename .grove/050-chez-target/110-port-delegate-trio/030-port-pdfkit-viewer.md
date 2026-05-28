# 030-port-pdfkit-viewer

**Kind:** work

## Goal
Port `pdfkit-viewer` from racket to chez. End state: a
`generation/targets/chez/apps/pdfkit-viewer/pdfkit-viewer.sls` that
bundles via `bundle-chez`, launches in the VM (via leaf `040`'s
TestAnyware run), and looks indistinguishable from the racket bar.

This is the first chez app that pulls in **PDFKit**, and the first
to exercise a **multi-delegate** binding shape (one object listening
on several selectors at once).

## Context
- Racket source: `generation/targets/racket/apps/pdfkit-viewer/pdfkit-viewer.rkt`
  (248 LOC).
- Knowledge spec: `knowledge/apps/pdfkit-viewer/spec.md`.
- PDFKit is in the staged chez tree as `apianyware/pdfkit.sls` and
  `apianyware/pdfkit/*.sls`. Verify before porting.
- Chez delegate API: see node BRIEF. Multi-delegate is the same
  `make-delegate` call with a longer list of specs — one entry per
  selector.

## Done when
- `apps/pdfkit-viewer/pdfkit-viewer.sls` exists and is idiomatic Chez.
- Multi-delegate uses chez list-of-specs shape, all selectors on one
  delegate record, retained in a top-level variable.
- App bundles via `bundle_app -- pdfkit-viewer`. Precompile pass
  succeeds.
- CLI smoke: imports load, class/method resolution succeeds, run
  loop reached.
- `knowledge/apps/pdfkit-viewer/spec.md` exists (copy from racket).

## Notes
- The racket version uses a PDFView with a delegate that handles
  page-changed / annotation-clicked / similar callbacks. Confirm
  the exact selector list against the racket source before writing
  the delegate spec.
- PDFView itself is the owner that holds the delegate (weakly).
  Keep the chez delegate record alive in a top-level binding;
  hello-window's pattern (define before the let cascade) works.
- PDFKit's PDF rendering needs a real PDF asset — likely the racket
  app ships a sample under `apps/pdfkit-viewer/`. Confirm the
  resource path; the chez bundle's resource layout differs from
  racket's. Update the path resolution accordingly or copy the
  resource into the chez app dir.
- Per-class gaps in `apianyware/pdfkit/` get the split-leaf
  treatment same as scenekit.

## Pointers
- Reference shape: leaves `010` and `020` of this node.
