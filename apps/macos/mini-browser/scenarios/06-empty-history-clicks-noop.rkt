#lang app-spec
;; forward-generated from Mini Browser §13 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "empty-history ◀/▶ clicks navigate nothing"
  #:description
  "When ◀ and ▶ are clicked before any successful load, then no navigation results: the app keeps running and the status line still shows the launch failure — the behavioural half of 'history starts empty' (the pdfkit empty-state shape). The direct enabled=false read is a runner-verb gap (expect-ax has no #:enabled?); the flags are adjudicated from raw `agent snapshot --mode layout` at live-run, and post-load enablement rides the [nav] finished booleans (scenario 10)."

  ;; run: bundle-id — bound at run time from the impl descriptor (ADR-0011).
  (define bundle-id (run-value 'bundle-id))
  ;; run: address-field-x/y — AX-reported centre of the address field; back-button-x/y and
  ;; forward-button-x/y — AX-reported centres of the ◀/▶ buttons (framebuffer px); bound at
  ;; run time from the per-app run-values config (ADR-0011).
  (define addr-x (run-value 'address-field-x))
  (define addr-y (run-value 'address-field-y))
  (define back-x (run-value 'back-button-x))
  (define back-y (run-value 'back-button-y))
  (define fwd-x  (run-value 'forward-button-x))
  (define fwd-y  (run-value 'forward-button-y))

  ;; ── §3-lifecycle-mandated setup (spec §13 preamble): dismiss the offline launch alert ──
  ;; spec: §13 — Network reality (preamble) — wait for the pre-dismissal cue.
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP.
  (wait-for-log #px"\\[nav\\] failed" #:timeout 20.0)
  ;; spec: §13 — Network reality (preamble) — settle: let the modal run.
  (wait 1.0)
  ;; spec: §13 — Network reality (preamble) — dismiss the modal.
  (press 'return)
  ;; spec: §13 — Network reality (preamble) — settle after dismissal.
  (wait 0.5)

  ;; spec: §13 — Driver guidance — re-activation click after the dismissed modal (k112); a
  ;; single click on the address field only places the cursor, so it is a safe spend.
  (click-at addr-x addr-y)
  ;; spec: §13 — Driver guidance — settle after re-activation.
  (wait 0.5)

  ;; spec: §13 — History starts empty. (behavioural half — click ◀; with empty history the
  ;; §6.3 canGoBack guard makes it a no-op)
  (click-at back-x back-y)
  ;; spec: §13 — History starts empty. (behavioural half — click ▶)
  (click-at fwd-x fwd-y)
  ;; spec: §13 — History starts empty. (settle — a wrongly-started navigation would need a
  ;; beat to surface in the status line or the log)
  (wait 1.0)
  ;; spec: §13 — History starts empty. (steady state persists: process alive — the clicks
  ;; did not crash or terminate the app)
  (expect-running-app bundle-id)
  ;; spec: §13 — History starts empty. (steady state persists: the launch-failure status is
  ;; unchanged — no [nav] event is expected from these clicks but absence is never asserted,
  ;; per the logging contract; a weak, presence-only check, recorded in the coverage map)
  (wait-for-ocr "failed:" #:timeout 5.0))
