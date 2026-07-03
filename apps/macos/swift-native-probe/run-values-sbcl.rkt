#lang app-spec/run-values

;; Per-app run-values config for Swift-Native Probe — the **sbcl** impl only.
;; sbcl is the 5-shape probe (k141): a 640×300 content window, larger than the
;; 560×240 window the 2-shape racket/chez/gerbil trio share (run-values.rkt). The
;; close button is title-bar chrome positioned by the window ORIGIN, and a centred
;; 640-wide window has a different left edge than a 560-wide one, so sbcl needs its
;; own close-button coordinate. (bundle-id still comes from the sbcl descriptor.)
;;
;; App data, downstream in APIAnyware, never in the AppSpec toolkit (ADR-0052).
;; Consumed as `runner/main.rkt --run-values <this file>` for the sbcl impl.
;;
;; ── Geometry (ADR-0011; derivation-from-AX deferred) ─────────────────────────
;; Fixed-size 640×300-pt content window (+ ~32pt title bar ⇒ outer 640 × ~332),
;; `[NSWindow center]`-positioned on the 1× framebuffer W×H:
;;   window left = (W - 640) / 2      close-button-x = window-left + ~20
;;   window top  ≈ centre-biased-up   close-button-y = window-top + ~14
;;
;; ── MEASURED LIVE by forward-gen-live-run-k147 (2026-07-04) ──────────────────
;; The 1920×1080 golden VM. The sbcl window (fixed 640×300 content ⇒ 640×332
;; outer) opens at AX top-left (640, 190) — [NSWindow center] biases it above true
;; centre (the provisional vertical hint 179 was ~27px high; the horizontal hint
;; left = (1920-640)/2 = 640 was exact). The leftmost traffic-light reads from
;; `agent snapshot --mode layout`: close AXButton at pos (648, 198) 16×16 →
;; centre (656, 206). Two-launch determinism green. scenario 03 stays
;; `recording:` — a click that still misses is a run adjudication finding, not a
;; generation defect (ADR-0010 D4, ADR-0011).

(run-values
  (close-button-x 656)
  (close-button-y 206))
