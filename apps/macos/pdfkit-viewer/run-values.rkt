#lang app-spec/run-values

;; Per-app run-values config for PDFKit Viewer (ADR-0011, the per-app
;; run-value source schema). Carries the *app-level* values the scenarios
;; read: toolbar/window click coordinates (scenarios/03–07, 09) and the
;; in-VM fixture path (05–07); the per-*impl* value (bundle-id) lives in
;; each `#lang app-spec/impl` descriptor
;; (../../../targets/<t>/app-implementations/macos/pdfkit-viewer/
;; pdfkit-viewer-impl.rkt); the runner merges the two into the single
;; `current-run-values` table that `(run-value 'key)` reads (runner/main.rkt;
;; the descriptor wins on any key clash).
;;
;; This config holds *app data* and lives downstream in APIAnyware, never in
;; the AppSpec toolkit (ADR-0052). It is consumed by `runner/main.rkt
;; --run-values <this file>` and is deliberately NOT placed under scenarios/ —
;; the runner discovers every .rkt there as a `#lang app-spec` scenario, so a
;; config file there would be mis-loaded (runner/dispatch.rkt).
;;
;; ── MEASURED LIVE (live-run-k103, 2026-07-02) ──
;; Coordinates measured per impl from `agent snapshot --mode layout` (AX
;; position+size → element centre, framebuffer px) against the live
;; 1920x1080 testanyware-golden-macos-tahoe VM, after a two-launch
;; determinism diff per impl (all four byte-identical across relaunches —
;; the k77/k94 geometry practice). chez + gerbil + sbcl are PIXEL-IDENTICAL
;; (same 26px-high toolbar controls) and share this default table; racket
;; alone diverges (tighter 22px control metrics — the gallery pattern) and
;; carries the sibling run-values-racket.rkt.
;;
;; The fixture: fixtures/fixture.pdf (3 pages, "PAGE n" markers — regenerate
;; with fixtures/make-fixture.swift). The run stage uploads it to the
;; fixture-path below before the suite runs; scenarios drive the
;; out-of-process open panel by keyboard (Cmd-Shift-G → path → Return x2)
;; and exact-match only the BASENAME in the [document] opened event (the
;; panel canonicalizes /tmp → /private/tmp; basename is the stable identity).

(run-values
  ;; scenarios/04,05,06,07 — the Open… button centre (measured: pos (611,169)
  ;; size 70x26)
  (open-button-x 646)
  (open-button-y 182)
  ;; scenarios/03,06 — the ◀ previous-page button centre (pos (687,169) 37x26)
  (prev-button-x 706)
  (prev-button-y 182)
  ;; scenarios/03,06 — the ▶ next-page button centre (pos (730,169) 37x26)
  (next-button-x 748)
  (next-button-y 182)
  ;; scenario/07 — a point inside the PDF document area (the focus click):
  ;; the AXScrollArea centre (pos (600,210) size 720x492)
  (doc-area-x 960)
  (doc-area-y 456)
  ;; scenario/09 — the window close control (leftmost traffic-light) centre
  ;; (pos (608,138) size 16x16)
  (close-button-x 616)
  (close-button-y 146)
  ;; scenarios/05,06,07 — the in-VM absolute path the run stage uploads
  ;; fixtures/fixture.pdf to (same parent dir the impls already create for
  ;; events.log; typed into the panel's go-to-folder sheet)
  (fixture-path "/tmp/pdfkit-viewer/fixture.pdf"))
