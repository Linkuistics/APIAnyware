#lang app-spec/run-values

;; Per-impl run-values sibling for the RACKET build of PDFKit Viewer — the
;; k77/k94 per-impl geometry practice: a sibling exists only where an impl's
;; layout genuinely diverges from the shared default (run-values.rkt, which
;; chez + gerbil + sbcl share). racket's generated-binding control metrics
;; are tighter (22px-high toolbar controls vs the others' 26px — the same
;; divergence the gallery measured), shifting every control centre.
;;
;; MEASURED LIVE (live-run-k103, 2026-07-02) from `agent snapshot --mode
;; layout` (AX position+size → element centre, framebuffer px) on the
;; 1920x1080 testanyware-golden-macos-tahoe VM, after a two-launch
;; determinism diff (byte-identical). See run-values.rkt for the schema /
;; consumption notes (runner/main.rkt --run-values <this file>).

(run-values
  ;; scenarios/04,05,06,07 — the Open… button centre (measured: pos (611,166)
  ;; size 63x22)
  (open-button-x 642)
  (open-button-y 177)
  ;; scenarios/03,06 — the ◀ previous-page button centre (pos (680,166) 32x22)
  (prev-button-x 696)
  (prev-button-y 177)
  ;; scenarios/03,06 — the ▶ next-page button centre (pos (718,166) 32x22)
  (next-button-x 734)
  (next-button-y 177)
  ;; scenario/07 — a point inside the PDF document area (the focus click):
  ;; the AXScrollArea centre (pos (600,207) size 720x492)
  (doc-area-x 960)
  (doc-area-y 453)
  ;; scenario/09 — the window close control (leftmost traffic-light) centre
  ;; (pos (608,138) size 12x14)
  (close-button-x 614)
  (close-button-y 145)
  ;; scenarios/05,06,07 — the in-VM absolute path the run stage uploads
  ;; fixtures/fixture.pdf to (same parent dir the impls already create for
  ;; events.log; typed into the panel's go-to-folder sheet)
  (fixture-path "/tmp/pdfkit-viewer/fixture.pdf"))
