#lang app-spec
;; forward-generated from Swift-Native Probe §10 on 2026-07-04, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "Command-Q terminates the app"
  #:description "When Command-Q is sent from the presentation-settled steady state, then the app menu's Quit command reaches -[NSApplication terminate:]: events.log records [lifecycle] shutdown reason=menu and the process is gone — the mandated §7 Quit invariant and the gui-app ns-application-terminate model (§1, §3.9). A state-mutating assertion isolated in its own launch, carrying only the reads that verify its own effect. (All four impls ignore SIGTERM under nsapplication-run; the menu-Quit path is the one that terminates — this is its first real exercise.)"

  ;; run: bundle-id — bound at run time from the impl descriptor / per-app run-values config (ADR-0011).
  ;; An internal define inside the scenario thunk so it resolves at run time, not at load (validation L1a).
  (define bundle-id (run-value 'bundle-id))

  ;; spec: §10 — Readiness / launch diagnostic. (presentation-settled probe — quit from the steady state)
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP; the literal '.' is escaped.
  (wait-for-log #rx"Swift-Native Probe opened\\.")
  ;; spec: §10 — Window title is correct. (render-settled probe — the steady state is on screen)
  ;; harness: runner/harness-observations.rkt — wait-for-ocr matches a literal substring.
  (wait-for-ocr "Swift-Native API Coverage")

  ;; spec: §10 — Command-Q terminates the app. (⌘Q → the §7 Quit item's terminate: — the key-equivalent routes through the menu bar; the ⌘Q key-equivalent ATTRIBUTE itself is the standing expect-ax #:key gap, reported not asserted)
  ;; harness: runner/harness-inputs.rkt — chord takes a LIST of modifier symbols then a key, not a flat "cmd q".
  (chord '(cmd) 'q)

  ;; spec: §10 — Command-Q terminates the app. (the menu-Quit terminate path witnessed in events.log — logging-contract reason=menu; waiting on it also settles the run-loop unwind before the process check)
  ;; harness: runner/harness-logs.rkt — REGEXP; #:timeout widens for the unwind.
  (wait-for-log #px"\\[lifecycle\\] shutdown reason=menu" #:timeout 10.0)

  ;; spec: §10 — Command-Q terminates the app. (shutdown is logged before exit — let the process end fully)
  ;; harness: runner/harness-state.rkt — (wait seconds).
  (wait 1)

  ;; spec: §10 — Command-Q terminates the app. (the process is gone — the mandated termination invariant, the gap-1 negative form)
  ;; harness: runner/harness-observations.rkt — #:running? #f asserts the app is not running.
  (expect-running-app bundle-id #:running? #f))
