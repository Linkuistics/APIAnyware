#lang app-spec
;; forward-generated from Mini Browser §13 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: close button leaves the process running"
  #:description
  "When the window's close control is clicked, then per §3.9 and the gui-app app-kind (termination is Quit-driven — ns-application-terminate; no implementation opts into terminate-after-last-window-closed; §12 excludes close-to-quit) the window hides and the process is expected to keep running. recording: this behaviour is (to confirm in-VM) — a pass confirms the §3.9 expectation and signals reverse-gen may drop the marker; a failure is a spec-quality finding (the impls' 'Close window … to exit' guidance prose would be the contradiction to investigate), not a suite bug — the runner captures artifacts for review."

  ;; run: bundle-id — bound at run time from the impl descriptor (ADR-0011).
  (define bundle-id (run-value 'bundle-id))
  ;; run: address-field-x/y — AX-reported centre of the address field; close-button-x/y —
  ;; the window close control's centre (framebuffer px). Bound at run time from the per-app
  ;; run-values config (ADR-0011).
  (define addr-x (run-value 'address-field-x))
  (define addr-y (run-value 'address-field-y))
  (define close-x (run-value 'close-button-x))
  (define close-y (run-value 'close-button-y))

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

  ;; spec: §13 — Driver guidance — re-activation click after the dismissed modal (k112);
  ;; spent on the address field, where a single click only places the cursor — so the close
  ;; click below cannot be swallowed as the activation click.
  (click-at addr-x addr-y)
  ;; spec: §13 — Driver guidance — settle after re-activation.
  (wait 0.5)

  ;; spec: (to confirm in-VM) — Close-button behaviour. (activate the close control)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y), framebuffer px.
  (click-at close-x close-y)
  ;; spec: (to confirm in-VM) — Close-button behaviour. (settle — give a wrongly-terminating
  ;; impl time to exit before the process check)
  (wait 2.0)
  ;; spec: (to confirm in-VM) — Close-button behaviour. (§3.9 / gui-app anchor: the window
  ;; hides but the process keeps running — the recorded expectation)
  (expect-running-app bundle-id))
