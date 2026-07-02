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
;; ── PROVISIONAL (forward-gen-suite-k102, 2026-07-02) — NOT yet measured ──
;; Coordinates are estimates from the spec's fixed geometry (§4/§5: 720x540
;; content, centred, min-size floor; toolbar strip at content (12, 500,
;; 696, 32); [NSWindow center]'s above-true-centre vertical bias as measured
;; on hello-window) projected onto the 1920x1080 testanyware-golden-
;; macos-tahoe framebuffer, with control widths estimated from intrinsic
;; stack sizing. The live-run stage MUST re-measure every coordinate from
;; `agent snapshot --mode layout` (AX centre, framebuffer px) with a
;; two-launch determinism diff before binding values — the k77/k94 per-impl
;; geometry practice — keeping sibling per-impl run-values-<impl>.rkt files
;; only where impl layouts genuinely diverge (chez+gerbil shared one table
;; in the gallery; racket/sbcl carried their own).
;;
;; The fixture: fixtures/fixture.pdf (3 pages, "PAGE n" markers — regenerate
;; with fixtures/make-fixture.swift). The run stage uploads it to the
;; fixture-path below before the suite runs; scenarios drive the
;; out-of-process open panel by keyboard (Cmd-Shift-G → path → Return x2)
;; and exact-match only the BASENAME in the [document] opened event (the
;; panel canonicalizes /tmp → /private/tmp; basename is the stable identity).

(run-values
  ;; scenarios/04,05,06,07 — the Open… button centre (toolbar strip, first
  ;; arranged subview; strip centre-line fb y ≈ 180)
  (open-button-x 648)
  (open-button-y 180)
  ;; scenarios/03,06 — the ◀ previous-page button centre
  (prev-button-x 709)
  (prev-button-y 180)
  ;; scenarios/03,06 — the ▶ next-page button centre
  (next-button-x 751)
  (next-button-y 180)
  ;; scenario/07 — a point inside the PDF document area (the focus click;
  ;; §5.2 region below the toolbar — the window-content centre)
  (doc-area-x 960)
  (doc-area-y 446)
  ;; scenario/09 — the window close control (leftmost traffic-light) centre
  ;; (window-frame origin + (16, 16), the hello-window-measured offset)
  (close-button-x 616)
  (close-button-y 144)
  ;; scenarios/05,06,07 — the in-VM absolute path the run stage uploads
  ;; fixtures/fixture.pdf to (same parent dir the impls already create for
  ;; events.log; typed into the panel's go-to-folder sheet)
  (fixture-path "/tmp/pdfkit-viewer/fixture.pdf"))
