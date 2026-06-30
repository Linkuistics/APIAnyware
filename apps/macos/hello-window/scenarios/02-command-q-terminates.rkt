#lang app-spec
;; forward-generated from Hello Window §10 on 2026-06-30, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "Command-Q terminates the app"
  #:description "When the user sends the Command-Q chord to the running app, then the process terminates — the mandated §6 Quit invariant and the gui-app ns-application-terminate model (§1, §3.8). A state-mutating assertion isolated in its own launch, carrying only the read that verifies its own effect."

  ;; run: bundle-id — bound at run time from the impl descriptor / per-app run-values config (ADR-0011).
  ;; An internal define inside the scenario thunk so it resolves at run time, not at load —
  ;; keeping the suite loadable outside the runner (validation L1a).
  (define bundle-id (run-value 'bundle-id))

  ;; spec: §10 — Command-Q terminates the app.
  ;; harness: runner/harness-inputs.rkt — chord takes (list-of-modifier-symbols key), not a flat "cmd q".
  (chord '(cmd) 'q)

  ;; spec: §10 — Command-Q terminates the app.
  ;; harness: runner/harness-observations.rkt — #:running? #f asserts the process is gone (the mandated termination invariant, the gap-1 negative form).
  ;; run-tuning note (for 04): termination is asynchronous; if a single-shot check races the run-loop unwind, 04 inserts a settle (the in-set (wait seconds), runner/harness-state.rkt) — a run-capability tweak, not a §10 assertion.
  (expect-running-app bundle-id #:running? #f))
