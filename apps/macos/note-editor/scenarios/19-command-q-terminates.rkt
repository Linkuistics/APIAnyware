#lang app-spec
;; forward-generated from Note Editor §15 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "Command-Q terminates the app"
  #:description
  "When Command-Q is sent from the steady state (no sheet or modal alert open — either would swallow the chord, the mini-browser rule), then the app menu's Quit command reaches -[NSApplication terminate:]: events.log records shutdown reason=menu and the process is gone (the gui-app ns-application-terminate model, §3 step 10 / §10). A state-mutating assertion isolated in its own launch, carrying only the reads that verify its own effect."

  ;; run: bundle-id — bound at run time from the impl descriptor (ADR-0011).
  (define bundle-id (run-value 'bundle-id))

  ;; spec: §15 — Quit terminates the app. (presentation-settled probe — quit from steady
  ;; state only)
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP.
  (wait-for-log #rx"Note Editor")
  (wait-for-ocr "Undo")

  ;; spec: §15 — Quit terminates the app. (Command-Q → the §10 Quit item's terminate:)
  ;; harness: runner/harness-inputs.rkt — chord takes a LIST of modifier symbols then a key.
  (chord '(cmd) 'q)
  ;; spec: §15 — Quit terminates the app. (the menu-Quit terminate path witnessed in
  ;; events.log — logging contract reason=menu; waiting on it also settles the run-loop
  ;; unwind before the process check)
  (wait-for-log #px"\\[lifecycle\\] shutdown reason=menu" #:timeout 10.0)
  ;; spec: §15 — Quit terminates the app. (shutdown is logged before exit — let the
  ;; process end fully)
  (wait 1.0)
  ;; spec: §15 — Quit terminates the app. (the process is gone — the mandated termination
  ;; invariant)
  ;; harness: runner/harness-observations.rkt — #:running? #f asserts the app is not
  ;; running.
  (expect-running-app bundle-id #:running? #f))
