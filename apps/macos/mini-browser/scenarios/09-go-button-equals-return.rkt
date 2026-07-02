#lang app-spec
;; forward-generated from Mini Browser §13 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "Go button drives the same navigation as Return"
  #:description
  "When a fixture file:// URL is typed and the Go button is clicked (instead of pressing Return), then the identical navigation behaviour follows — the driven load starts and finishes and the status line settles on Done (the field's Return action and the Go button share one action by construction, §6.3)."

  ;; run: address-field-x/y — AX-reported centre of the address field; go-button-x/y — the
  ;; Go button's centre (framebuffer px); fixture-two-url — the file:// URL of the uploaded
  ;; fixture page-two.html. Bound at run time from the per-app run-values config (ADR-0011).
  (define addr-x (run-value 'address-field-x))
  (define addr-y (run-value 'address-field-y))
  (define go-x (run-value 'go-button-x))
  (define go-y (run-value 'go-button-y))
  (define fixture-two-url (run-value 'fixture-two-url))

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

  ;; spec: §13 — Driver guidance — re-activation click after the dismissed modal (k112).
  (click-at addr-x addr-y)
  ;; spec: §13 — Driver guidance — break the click sequence so the triple-click starts fresh.
  (wait 1.0)

  ;; spec: §13 — Go ≡ Return. (triple-click = select-all)
  (click-at addr-x addr-y)
  ;; spec: §13 — Go ≡ Return.
  (click-at addr-x addr-y)
  ;; spec: §13 — Go ≡ Return.
  (click-at addr-x addr-y)
  ;; spec: §13 — Go ≡ Return. (type the second fixture's URL)
  (type fixture-two-url)
  ;; spec: §13 — Go ≡ Return. (drive the navigation via the Go button, not Return — the
  ;; point of the scenario; the window is active, so the click delivers)
  (click-at go-x go-y)
  ;; spec: §13 — Go ≡ Return. (same observables as the Return-driven navigation: started…)
  (wait-for-log #px"\\[nav\\] started url=\"file:[^\"]*page-two\\.html\"" #:timeout 15.0)
  ;; spec: §13 — Go ≡ Return. (…and finished, title left unmatched)
  (wait-for-log #px"\\[nav\\] finished url=\"file:[^\"]*page-two\\.html\"" #:timeout 15.0)
  ;; spec: §13 — Go ≡ Return. (settle for the repaint)
  (wait 0.5)
  ;; spec: §13 — Go ≡ Return. (settles on Done, exactly as the Return path — exact via the
  ;; status value→AXTitle fold)
  ;; harness: runner/harness-observations.rkt — expect-ax #:title is an exact equal? match.
  (expect-ax #:role 'AXStaticText #:title "Done"))
