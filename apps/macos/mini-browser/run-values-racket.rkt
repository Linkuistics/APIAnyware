#lang app-spec/run-values

;; Per-app run-values config for Mini Browser — RACKET sibling (ADR-0011).
;; The racket impl's compact 22px control metrics (the standing k77/k94/k103
;; precedent) shift every toolbar control off the shared chez+gerbil+sbcl
;; table (run-values.rkt): window (560,116) 800x628 vs the shared 800x632,
;; toolbar centre-line fb y 167 vs 171, narrower controls (◀/▶ 32px,
;; Reload 61px, Go 39px), 12px traffic lights. Coordinates are live-measured
;; AX element centres (framebuffer px) from `agent snapshot --window
;; "Mini Browser" --json` on the 1920x1080 VM, two-launch determinism diff
;; green (live-run-k121, 2026-07-03). Pass this file as --run-values for the
;; racket impl only; fixture URLs are impl-independent and identical to the
;; shared table.

(run-values
  ;; scenarios/03–11,13 — the address field centre (AX (714,155) 590x21)
  (address-field-x 1009)
  (address-field-y 166)
  ;; scenarios/06,10 — the ◀ back button centre (AX (571,156) 32x22)
  (back-button-x 587)
  (back-button-y 167)
  ;; scenarios/06,10 — the ▶ forward button centre (AX (609,156) 32x22)
  (forward-button-x 625)
  (forward-button-y 167)
  ;; scenario/11 — the Reload button centre (AX (647,156) 61x22)
  (reload-button-x 678)
  (reload-button-y 167)
  ;; scenario/09 — the Go button centre (AX (1310,156) 39x22)
  (go-button-x 1330)
  (go-button-y 167)
  ;; scenario/13 — the window close control centre (AX (568,123) 12x14)
  (close-button-x 574)
  (close-button-y 130)
  ;; scenarios/07–11 — the file:// URLs typed into the address field
  (fixture-one-url "file:///tmp/mini-browser/fixtures/page-one.html")
  (fixture-two-url "file:///tmp/mini-browser/fixtures/page-two.html"))
