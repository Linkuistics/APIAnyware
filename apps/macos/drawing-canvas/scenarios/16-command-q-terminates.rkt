#lang app-spec
;; forward-generated from Drawing Canvas §14 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "Command-Q terminates the app"
  #:description "When Command-Q is sent from the steady state (no colour panel open — quit from steady state per the standing rule; ⌘Q with the panel key is a separate to-confirm this suite does not drive), then the app menu's Quit command reaches -[NSApplication terminate:]: events.log records shutdown reason=menu and the process is gone — the gui-app app-kind's ns-application-terminate model (§3 step 8, §9). A state-mutating assertion isolated in its own launch, carrying only the reads that verify its own effect."

  ;; run: bundle-id — bound at run time from the impl descriptor (ADR-0011). An internal define inside the
  ;; scenario thunk so it resolves at run time, not at load (validation L1a).
  (define bundle-id (run-value 'bundle-id))

  ;; spec: §14 — Launch diagnostic is emitted. (presentation-settled probe — quit from steady state)
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP.
  (wait-for-log #rx"Drawing Canvas")
  ;; spec: §14 — Toolbar controls present. (render-settled probe — the steady state is on screen)
  (wait-for-ocr "Clear")

  ;; spec: §14 — Quit menu terminates the app. (Command-Q → the §9 Quit item's terminate: — the
  ;; key-equivalent routes through the menu bar; the ⌘Q key-equivalent ATTRIBUTE itself is the standing
  ;; expect-ax #:key gap, reported not asserted)
  ;; harness: runner/harness-inputs.rkt — chord takes a LIST of modifier symbols then a key.
  (chord '(cmd) 'q)

  ;; spec: §14 — Quit menu terminates the app. (the menu-Quit terminate path witnessed in events.log —
  ;; logging contract reason=menu; waiting on it also settles the run-loop unwind before the process check)
  ;; harness: runner/harness-logs.rkt — regexp; #:timeout widens for the unwind.
  (wait-for-log #px"\\[lifecycle\\] shutdown reason=menu" #:timeout 10.0)

  ;; spec: §14 — Quit menu terminates the app. (shutdown is logged before exit — let the process end fully)
  ;; harness: runner/harness-state.rkt — (wait seconds).
  (wait 1)

  ;; spec: §14 — Quit menu terminates the app. (the process is gone — the mandated termination invariant)
  ;; harness: runner/harness-observations.rkt — #:running? #f asserts the app is not running.
  (expect-running-app bundle-id #:running? #f))
