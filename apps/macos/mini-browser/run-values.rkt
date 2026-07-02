#lang app-spec/run-values

;; Per-app run-values config for Mini Browser (ADR-0011, the per-app
;; run-value source schema). Carries the *app-level* values the scenarios
;; read: toolbar/window click coordinates (scenarios/03–13) and the in-VM
;; fixture file:// URLs (07–11); the per-*impl* value (bundle-id) lives in
;; each `#lang app-spec/impl` descriptor
;; (../../../targets/<t>/app-implementations/macos/mini-browser/
;; mini-browser-impl.rkt); the runner merges the two into the single
;; `current-run-values` table that `(run-value 'key)` reads (runner/main.rkt;
;; the descriptor wins on any key clash).
;;
;; This config holds *app data* and lives downstream in APIAnyware, never in
;; the AppSpec toolkit (ADR-0052). It is consumed by `runner/main.rkt
;; --run-values <this file>` and is deliberately NOT placed under scenarios/ —
;; the runner discovers every .rkt there as a `#lang app-spec` scenario, so a
;; config file there would be mis-loaded (runner/dispatch.rkt).
;;
;; ── PROVISIONAL (forward-gen-suite-k120, 2026-07-03) — NOT yet measured ──
;; Coordinates are estimates from the spec's fixed geometry (§4/§5: 800x600
;; content, centred, titled+resizable; toolbar stack at content
;; (12, 556, 776, 32), baseline-aligned, 8pt spacing; [NSWindow center]'s
;; above-true-centre vertical bias ≈ 0.25·(screenH − windowH), as measured
;; on hello-window/pdfkit/scenekit) projected onto the 1920x1080
;; testanyware-golden-macos-tahoe framebuffer: window frame ≈ origin
;; (560, 115), 800x628 (28px title bar + 600 content); toolbar control
;; centre-line ≈ fb y 171; control widths estimated from intrinsic stack
;; sizing (◀/▶ ≈ 37px, Reload ≈ 70px, Go ≈ 40px at the 26px control metric —
;; the address field takes the remaining stack width). The live-run stage
;; MUST re-measure EVERY coordinate from `agent snapshot --mode layout` (AX
;; centre, framebuffer px) with a two-launch determinism diff per impl
;; before binding values — the k77/k94 geometry practice — keeping sibling
;; per-impl run-values-<impl>.rkt files only where impl layouts genuinely
;; diverge (pdfkit: chez+gerbil+sbcl shared one table, racket alone
;; diverged; scenekit's share-set differed — measure, never assume; racket's
;; compact 22px control metrics are the standing precedent).
;;
;; The fixtures: fixtures/page-one.html + page-two.html (distinct <title>s
;; 'Fixture Page One'/'Fixture Page Two'; 72px ALL-CAPS body markers
;; FIXTURE ONE / FIXTURE TWO). The live-run stage uploads them to
;; /tmp/mini-browser/fixtures/ (the same parent dir the impls already create
;; for events.log) before the runs; scenarios drive them by typing the
;; file:// URLs below into the address field (triple-click select-all →
;; type → Return / Go) and match only the regex-escaped BASENAME in [nav]
;; event urls (the pdfkit basename rule).

(run-values
  ;; scenarios/03–11,13 — the address field centre (triple-click target; the
  ;; field spans the toolbar gap between Reload and Go)
  (address-field-x 1020)
  (address-field-y 171)
  ;; scenarios/06,10 — the ◀ back button centre (leftmost toolbar control)
  (back-button-x 590)
  (back-button-y 171)
  ;; scenarios/06,10 — the ▶ forward button centre
  (forward-button-x 636)
  (forward-button-y 171)
  ;; scenario/11 — the Reload button centre
  (reload-button-x 697)
  (reload-button-y 171)
  ;; scenario/09 — the Go button centre (rightmost toolbar control)
  (go-button-x 1328)
  (go-button-y 171)
  ;; scenario/13 — the window close control (leftmost traffic-light) centre
  ;; (frame origin + (16,16), the hello-window/scenekit measurement shape)
  (close-button-x 576)
  (close-button-y 131)
  ;; scenarios/07–11 — the file:// URLs typed into the address field; the
  ;; in-VM upload home is the contract's fixture path
  (fixture-one-url "file:///tmp/mini-browser/fixtures/page-one.html")
  (fixture-two-url "file:///tmp/mini-browser/fixtures/page-two.html"))
