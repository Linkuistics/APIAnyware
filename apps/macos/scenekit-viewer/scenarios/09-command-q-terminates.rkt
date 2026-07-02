#lang app-spec
;; forward-generated from SceneKit Viewer §13 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "Command-Q terminates the app"
  #:description "When the user sends the Command-Q chord to the running viewer, then the app menu's Quit command reaches -[NSApplication terminate:] — the shutdown event with reason=menu is logged and the process ends (the gui-app ns-application-terminate model, §3 step 8 / §8). A state-mutating assertion isolated in its own launch, carrying only the reads that verify its own effect."

  ;; run: bundle-id — bound at run time from the impl descriptor (ADR-0011). Internal define so it resolves
  ;; at run time, not at load (validation L1a).
  (define bundle-id (run-value 'bundle-id))

  ;; spec: §13 — Launch diagnostic is emitted. (Re-asserted as the presentation-settled probe: §3 installs
  ;; the menu (step 3) before present+announce (steps 5-6) and the app activates ignoring other apps, so
  ;; the chord below is receivable by the frontmost app.)
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a regexp.
  (wait-for-log #rx"SceneKit Viewer")

  ;; spec: §13 — Quit menu terminates the app.
  ;; harness: runner/harness-inputs.rkt — chord takes (list-of-modifier-symbols key), not a flat "cmd q".
  (chord '(cmd) 'q)

  ;; spec: §13 — Quit menu terminates the app.
  ;; harness: runner/harness-logs.rkt — the shutdown event on the menu-Quit terminate path (logging
  ;; contract: reason=menu); waiting for it also settles the asynchronous run-loop unwind before the
  ;; process check below.
  (wait-for-log #px"\\[lifecycle\\] shutdown reason=menu")

  ;; spec: §13 — Quit menu terminates the app.
  ;; harness: runner/harness-observations.rkt — #:running? #f asserts the process is gone (the mandated
  ;; termination invariant, the gap-1 negative form).
  (expect-running-app bundle-id #:running? #f))
