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
;; ── LIVE-MEASURED (live-run-k121, 2026-07-03) ──
;; Every coordinate below is the AX element centre (framebuffer px) from
;; `agent snapshot --window "Mini Browser" --json` against the live
;; 1920x1080 testanyware-golden-macos-tahoe VM, each impl passing a
;; two-launch determinism diff (byte-identical control geometry across
;; launches). This table is the shared chez+gerbil+sbcl set — those three
;; impls are PIXEL-IDENTICAL (window (560,115) 800x632, 26px control
;; metrics, toolbar centre-line fb y 171); racket alone diverges (its
;; compact 22px control metrics — window (560,116) 800x628, centre-line
;; y 167) and carries the sibling run-values-racket.rkt. The k120
;; provisional estimates all landed within their control bounds (closest:
;; close-button exact; farthest: Reload 6px off-centre) — the spec-derived
;; projection method is validated for this window shape.
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
  ;; field spans the toolbar gap between Reload and Go: x 731–1299)
  (address-field-x 1015)
  (address-field-y 170)
  ;; scenarios/06,10 — the ◀ back button centre (leftmost toolbar control;
  ;; AX (571,158) 37x26)
  (back-button-x 590)
  (back-button-y 171)
  ;; scenarios/06,10 — the ▶ forward button centre (AX (614,158) 37x26)
  (forward-button-x 632)
  (forward-button-y 171)
  ;; scenario/11 — the Reload button centre (AX (657,158) 68x26)
  (reload-button-x 691)
  (reload-button-y 171)
  ;; scenario/09 — the Go button centre (rightmost toolbar control;
  ;; AX (1305,158) 44x26)
  (go-button-x 1327)
  (go-button-y 171)
  ;; scenario/13 — the window close control (leftmost traffic-light) centre
  ;; (AX (568,123) 16x16)
  (close-button-x 576)
  (close-button-y 131)
  ;; scenarios/07–11 — the file:// URLs typed into the address field; the
  ;; in-VM upload home is the contract's fixture path
  (fixture-one-url "file:///tmp/mini-browser/fixtures/page-one.html")
  (fixture-two-url "file:///tmp/mini-browser/fixtures/page-two.html"))
