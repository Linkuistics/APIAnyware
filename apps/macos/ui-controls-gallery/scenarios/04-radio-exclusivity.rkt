#lang app-spec
;; forward-generated from UI Controls Gallery §13 on 2026-07-02, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: radio exclusivity — selecting Option B"
  #:description "When the user clicks the 'Option B' radio button, then the group's sole selection becomes Option B — observed via the [controls] radio-selected event, whose semantics name the group's sole selection after the callback returns (logging contract), so Option A's deselection is carried by the event's exclusivity semantics. Provisional (to confirm in-VM): a PASS confirms the expectation and signals reverse-gen may drop the marker; a FAILURE is a spec-quality finding, not a suite bug. State-mutating: its own launch."

  ;; run: radio-option-b-x / radio-option-b-y — the 'Option B' radio button's click coordinates (framebuffer
  ;; px), bound at run time from the per-app run-values config via current-run-values (ADR-0011). Window size
  ;; and layout are impl-varying (§4/§5), so the run stage may bind these per impl. Internal defines inside
  ;; the scenario thunk so they resolve at run time, not at load (validation L1a).
  (define radio-option-b-x (run-value 'radio-option-b-x))
  (define radio-option-b-y (run-value 'radio-option-b-y))

  ;; spec: §13 — Launch diagnostic is emitted. (Re-asserted as the presentation-settled probe: the launch line
  ;; lands only once the window is key+front and centered, so the click below addresses the presented window.)
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a regexp.
  (wait-for-log #rx"Controls Gallery")

  ;; spec: (to confirm in-VM) — Radio exclusivity.
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at radio-option-b-x radio-option-b-y)

  ;; spec: (to confirm in-VM) — Radio exclusivity.
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a REGEXP; brackets and quotes escaped. The event
  ;; names the group's sole post-callback selection (logging contract), which carries the 'Option A becomes
  ;; deselected' half; a direct AX state read of Option A is a reported gap (expect-ax has no state/value
  ;; attribute). Only Option B is asserted (a third Option C is a §6 hole).
  (wait-for-log #px"\\[controls\\] radio-selected option=\"Option B\""))
