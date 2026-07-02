#lang app-spec
;; forward-generated from UI Controls Gallery §13 on 2026-07-02, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: checkbox toggles and toggles back"
  #:description "When the user clicks the checkbox twice, then its checked state flips and flips back — two checkbox-changed events with opposite states appear (one state=on and one state=off, in either order). The initial checked state is a §6 hole (one impl launches it ON), so the FLIP is asserted, never a fixed on-then-off sequence. Provisional (to confirm in-VM): a PASS confirms and signals reverse-gen may drop the marker; a FAILURE is a spec-quality finding, not a suite bug. State-mutating: its own launch."

  ;; run: checkbox-x / checkbox-y — the checkbox's click coordinates (framebuffer px), bound at run time from
  ;; the per-app run-values config via current-run-values (ADR-0011). Window size and layout are impl-varying
  ;; (§4/§5), so the run stage may bind these per impl. Internal defines so they resolve at run time.
  (define checkbox-x (run-value 'checkbox-x))
  (define checkbox-y (run-value 'checkbox-y))

  ;; spec: §13 — Launch diagnostic is emitted. (Re-asserted as the presentation-settled probe for the clicks below.)
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a regexp.
  (wait-for-log #rx"Controls Gallery")

  ;; spec: (to confirm in-VM) — Checkbox toggles. (first click: flips)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at checkbox-x checkbox-y)

  ;; spec: (to confirm in-VM) — Checkbox toggles. (second click: flips back)
  (click-at checkbox-x checkbox-y)

  ;; spec: (to confirm in-VM) — Checkbox toggles. (flip half 1: some click produced ON — order-agnostic, the
  ;; log buffer accumulates for the whole scenario, so this wait and the next succeed whichever order the two
  ;; events landed in — asserting the flip, never a fixed sequence.)
  ;; harness: runner/harness-logs.rkt — split from the contract's #px"checkbox-changed state=(on|off)" matcher:
  ;; asserting on AND off separately is what makes two clicks a flip regardless of the impl's initial state.
  (wait-for-log #px"\\[controls\\] checkbox-changed state=on")

  ;; spec: (to confirm in-VM) — Checkbox toggles. (flip half 2: some click produced OFF)
  (wait-for-log #px"\\[controls\\] checkbox-changed state=off"))
