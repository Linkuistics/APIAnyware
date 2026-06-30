#lang app-spec/run-values

;; Per-app run-values config for Hello Window (ADR-0011, the per-app run-value
;; source schema). Carries the *app-level* values shared across impls — the
;; window close-control coordinates the `recording: close-button …` scenario
;; (scenarios/03-close-button-keeps-running.rkt) clicks. The per-*impl* values
;; (bundle-id) live in each `#lang app-spec/impl` descriptor
;; (../../../../targets/<t>/app-implementations/macos/hello-window/hello-window-impl.rkt);
;; the runner merges the two into the single `current-run-values` table that
;; `(run-value 'key)` reads (runner/main.rkt).
;;
;; This config holds *app data* and lives downstream in APIAnyware, never in the
;; AppSpec toolkit (ADR-0052). It is consumed by `runner/main.rkt --run-values
;; <this file>` and is deliberately NOT placed under scenarios/ — the runner
;; discovers every .rkt there as a `#lang app-spec` scenario, so a config file
;; there would be mis-loaded (runner/dispatch.rkt `discover-scenario-files`).
;;
;; ── Geometry is hardcoded per-app; derivation-from-AX is deferred (ADR-0011) ──
;; The close button is the leftmost traffic-light control in the window's title
;; bar. `testanyware input click` takes FRAMEBUFFER PIXELS (testanyware-sdk/
;; input.rkt), i.e. the VNC display coordinates. For the mandated fixed-size
;; 400×200-pt content window, `[NSWindow center]`-positioned on the VM's
;; fixed-resolution non-HiDPI (1×) framebuffer W×H, the close-button center is:
;;
;;   window outer size = 400 × (200 + ~28 title-bar) = 400 × ~228
;;   window left  = (W - 400) / 2          window top (title-bar top) = (H - 228) / 2
;;   close-button-x = window-left + ~20     close-button-y = window-top + ~14
;;
;; Worked for an assumed W×H = 1024×768 framebuffer (the cirruslabs
;; macos-tahoe-vanilla default; CONFIRM against `testanyware screen size`):
;;   left = (1024-400)/2 = 312  →  close-button-x = 312 + 20 = 332
;;   top  = (768 -228)/2 = 270  →  close-button-y = 270 + 14 = 284
;;
;; ── PROVISIONAL — the live-run leaf (04) confirms/refines these in-VM ──
;; `[NSWindow center]` biases the window slightly above the vertical center, and
;; the real framebuffer / title-bar height may differ — so 04 measures the live
;; VM (`testanyware screen size`, then the actual window origin) and refines the
;; two literals below if needed. This is by design: scenario 03 is a *recording:*
;; (provisional) scenario — a click that misses the control surfaces as a 04/05
;; adjudication finding, not a generation defect (ADR-0010 D4, ADR-0011).

(run-values
  (close-button-x 332)
  (close-button-y 284))
