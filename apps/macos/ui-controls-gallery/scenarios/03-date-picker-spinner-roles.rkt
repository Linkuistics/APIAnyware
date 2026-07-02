#lang app-spec
;; forward-generated from UI Controls Gallery §13 on 2026-07-02, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: date-picker and spinner accessibility roles"
  #:description "When the gallery is at its post-launch steady state, then the date picker and the indeterminate spinner are expected in the accessibility tree as AXDateField and AXBusyIndicator — the best-documented expected roles, both marked uncertain (to confirm in-VM) by the app's observable-state contract. A PASS confirms the roles so they can be folded into the hard observation cluster (01); a FAILURE is a role-mapping finding for human review (the date picker may surface as a composite group per element, the spinner as AXProgressIndicator), not a suite bug."

  ;; spec: §13 — Launch diagnostic is emitted. (Re-asserted as the presentation-settled probe: the logging
  ;; contract emits the launch line only once the window is key+front — §3.5 present before §3.6 announce —
  ;; so the AX snapshots below see the fully-presented gallery.)
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a regexp.
  (wait-for-log #rx"Controls Gallery")

  ;; spec: §13 — Gallery structural elements exist. (date picker — role UNCERTAIN, to confirm in-VM per the
  ;; observable-state role table: AXDateField or a composite group per element; asserted provisionally, never hard.)
  ;; harness: runner/harness-observations.rkt — expect-ax matches #:role (+ optional exact #:title only).
  (expect-ax #:role 'AXDateField)

  ;; spec: §13 — Gallery structural elements exist. (spinner — role UNCERTAIN, to confirm in-VM per the
  ;; observable-state role table: AXBusyIndicator for the spinning style, or AXProgressIndicator. The
  ;; AXProgressIndicator fallback would be non-discriminating here because the determinate progress bar
  ;; already carries that role; the failure artifact disambiguates.)
  (expect-ax #:role 'AXBusyIndicator))
