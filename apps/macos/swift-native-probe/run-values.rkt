#lang app-spec/run-values

;; Per-app run-values config for Swift-Native Probe (ADR-0011, the per-app
;; run-value source schema). Carries the *app-level* geometry the
;; `recording: close-button …` scenario (scenarios/03-close-button-keeps-running.rkt)
;; clicks. The per-*impl* values (bundle-id) live in each `#lang app-spec/impl`
;; descriptor (../../../targets/<t>/app-implementations/macos/swift-native-probe/
;; swift-native-probe-impl.rkt); the runner merges the two into the single
;; `current-run-values` table that `(run-value 'key)` reads (runner/main.rkt).
;;
;; This config holds *app data* and lives downstream in APIAnyware, never in the
;; AppSpec toolkit (ADR-0052). It is consumed by `runner/main.rkt --run-values
;; <this file>` and is deliberately NOT under scenarios/ (the runner loads every
;; .rkt there as a `#lang app-spec` scenario — runner/dispatch.rkt).
;;
;; ── WHICH IMPLS SHARE THIS FILE ──────────────────────────────────────────────
;; The close button is the leftmost traffic-light control in the window's
;; title bar — window CHROME, not content — so its framebuffer position is
;; fixed by the window ORIGIN (a centred window → origin depends on window SIZE),
;; NOT by the per-impl 22px/26px content metric divergence seen elsewhere. So
;; every impl with the SAME window size shares this coordinate:
;;   • THIS file  →  racket / chez / gerbil  — the 2-shape probe, content 560×240.
;;   • run-values-sbcl.rkt  →  sbcl  — the 5-shape probe, content 640×300 (k141).
;;
;; ── Geometry is hardcoded per-app; derivation-from-AX is deferred (ADR-0011) ──
;; `testanyware input click` takes FRAMEBUFFER PIXELS (testanyware-sdk/input.rkt).
;; For the fixed-size 560×240-pt content window (+ ~32pt title bar ⇒ outer
;; 560 × ~272), `[NSWindow center]`-positioned on the VM's 1× framebuffer W×H:
;;   window left = (W - 560) / 2      window top (title-bar top) ≈ centre-biased-up
;;   close-button-x = window-left + ~20     close-button-y = window-top + ~14
;;
;; ── MEASURED LIVE by forward-gen-live-run-k147 (2026-07-04) ──────────────────
;; The 1920×1080 golden VM (`testanyware-golden-macos-tahoe`). The chez window
;; (fixed 560×240 content ⇒ 560×272 outer) opens at AX top-left (680, 205) —
;; [NSWindow center] biases it above true centre, so the provisional vertical
;; hint (209) was ~12px high; the horizontal hint (left = (1920-560)/2 = 680) was
;; exact. The leftmost traffic-light reads from `agent snapshot --mode layout`:
;; AXButton "close button" at pos (688, 213) size 16×16 → centre (696, 221).
;; gerbil is pixel-identical to chez (560×272 outer at origin (680,205), close
;; centre (696,221)). racket's compact 22px metrics make its window 4px shorter
;; (560×268 outer at (680,206)) with 12px traffic-lights → its own close centre
;; is (694,220), but (696,221) lands COMFORTABLY INSIDE racket's close button
;; (694±6 ⇒ x∈[688,700], y∈[214,226]), so all THREE share these literals
;; (measured, not assumed — the drawing-canvas "lands inside, so it shares"
;; pattern). sbcl's 640×332 window carries its own (run-values-sbcl.rkt, close
;; centre (656,206)). Two-launch determinism green (fixed-size static-label
;; window, no ambiguous-layout defect). Scenario 03 stays `recording:` — a click
;; that still misses is a run adjudication finding, not a generation defect
;; (ADR-0010 D4, ADR-0011).

(run-values
  (close-button-x 696)
  (close-button-y 221))
