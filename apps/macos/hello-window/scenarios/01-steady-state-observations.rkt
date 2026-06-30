#lang app-spec
;; forward-generated from Hello Window §10 on 2026-06-30, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "post-launch steady-state observations"
  #:description "When Hello Window has launched and reached its post-launch steady state, then the process is running, the launch diagnostic is in the log, the greeting and the stable title-bar substring are on screen, and the window, the static-text label (and not an editable text field), and the Quit menu item are present in the accessibility tree. Pure observations of one shared launch."

  ;; run: bundle-id — bound at run time from the impl descriptor / per-app run-values config (ADR-0011).
  ;; An internal define inside the scenario thunk so it resolves at run time, not at load —
  ;; keeping the suite loadable outside the runner (validation L1a).
  (define bundle-id (run-value 'bundle-id))

  ;; spec: §10 — Process is running after launch.
  ;; harness: runner/harness-observations.rkt — (expect-running-app bundle-id); #:running? defaults to #t.
  (expect-running-app bundle-id)

  ;; spec: §10 — Launch diagnostic is emitted.
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a REGEXP; the literal '.' is escaped so it is not a wildcard.
  (wait-for-log #rx"Hello Window opened\\.")

  ;; spec: §10 — The greeting is visible.
  ;; harness: runner/harness-observations.rkt — wait-for-ocr matches a literal substring (string-contains?); polls to absorb render latency.
  (wait-for-ocr "Hello, macOS!")

  ;; spec: §10 — Window title is correct.
  ;; harness: runner/harness-observations.rkt — expect-ocr is a literal substring; assert only the stable "Hello from" (never a realized per-impl "Hello from Racket").
  (expect-ocr "Hello from")

  ;; spec: §10 — Window title is correct.
  ;; harness: runner/harness-observations.rkt — the window AX element exists by role; expect-ax #:title is an exact equal? match, so the per-impl AXTitle is not expressible there (the substring above carries it).
  (expect-ax #:role 'AXWindow)

  ;; spec: §10 — Label is a static text element.
  ;; harness: runner/harness-observations.rkt — the static-text node exists by role; expect-ax has no #:value, so the label's value is carried by the greeting OCR above.
  (expect-ax #:role 'AXStaticText)

  ;; spec: §10 — No interactive editing (structural realization: the label is exposed as static text, not an editable field; the dynamic "typing changes nothing" is a reported gap — expect-ocr is presence-only, so it cannot detect an unchanged value).
  ;; harness: runner/harness-observations.rkt — expect-no-ax keys on #:role; an editable field would surface as AXTextField, so its absence is the discriminating static-label check.
  (expect-no-ax #:role 'AXTextField)

  ;; spec: §10 — Quit menu exists.
  ;; harness: runner/harness-observations.rkt — #:title is exact equal?; "Quit Hello Window" is a whole-string invariant ("Quit " + the fixed display name). The Command-Q key-equivalent has no expect-ax attribute — its behaviour is covered by 02.
  (expect-ax #:role 'AXMenuItem #:title "Quit Hello Window"))
