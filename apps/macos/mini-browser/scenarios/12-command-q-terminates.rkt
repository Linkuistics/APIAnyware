#lang app-spec
;; forward-generated from Mini Browser §13 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "Command-Q terminates the app"
  #:description
  "When Command-Q is sent after the launch alert has been dismissed (a modal alert would swallow the chord — §13 mandates dismissing first), then the app menu's Quit command reaches -[NSApplication terminate:]: events.log records shutdown reason=menu and the process is gone (the gui-app ns-application-terminate model, §3 step 9 / §8). A state-mutating assertion isolated in its own launch, carrying only the reads that verify its own effect."

  ;; run: bundle-id — bound at run time from the impl descriptor (ADR-0011).
  (define bundle-id (run-value 'bundle-id))

  ;; ── §3-lifecycle-mandated setup (spec §13 preamble): dismiss the offline launch alert ──
  ;; spec: §13 — Quit terminates the app. (dismiss any modal alert first — §13 mandates it;
  ;; the failed event is the pre-dismissal cue)
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP.
  (wait-for-log #px"\\[nav\\] failed" #:timeout 20.0)
  ;; spec: §13 — Quit terminates the app. (settle: let the modal run)
  (wait 1.0)
  ;; spec: §13 — Quit terminates the app. (Return dismisses the modal)
  (press 'return)
  ;; spec: §13 — Quit terminates the app. (let the dismissal land fully before the chord)
  (wait 1.0)

  ;; spec: §13 — Quit terminates the app. (Command-Q → -[NSApplication terminate:])
  ;; harness: runner/harness-inputs.rkt — chord takes a LIST of modifier symbols then a key.
  (chord '(cmd) 'q)
  ;; spec: §13 — Quit terminates the app. (the menu-Quit terminate path, witnessed in
  ;; events.log — logging contract: reason=menu; waiting on it also settles the asynchronous
  ;; run-loop unwind before the process check)
  (wait-for-log #px"\\[lifecycle\\] shutdown reason=menu" #:timeout 10.0)
  ;; spec: §13 — Quit terminates the app. (shutdown is logged before exit — let the process
  ;; end fully)
  (wait 1.0)
  ;; spec: §13 — Quit terminates the app. (the process is gone — the mandated termination
  ;; invariant, the gap-1 negative form)
  ;; harness: runner/harness-observations.rkt — #:running? #f asserts the app is not running.
  (expect-running-app bundle-id #:running? #f))
