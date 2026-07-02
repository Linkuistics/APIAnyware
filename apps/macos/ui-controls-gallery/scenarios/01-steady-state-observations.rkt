#lang app-spec
;; forward-generated from UI Controls Gallery §13 on 2026-07-02, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "post-launch steady-state observations"
  #:description "When UI Controls Gallery has launched and reached its post-launch steady state, then the process is running, the launch diagnostic is in the events log, the stable title substring and the invariant roster texts are readable on screen, and the window, slider, combo box, color well, and image are present in the accessibility tree by their firm roles. Pure observations sharing one launch; the uncertain date-picker/spinner roles are recorded provisionally in 03, not hard-asserted here."

  ;; run: bundle-id — bound at run time from the impl descriptor / per-app run-values config (ADR-0011).
  ;; An internal define inside the scenario thunk so it resolves at run time, not at load —
  ;; keeping the suite loadable outside the runner (validation L1a).
  (define bundle-id (run-value 'bundle-id))

  ;; spec: §13 — Process is running after launch.
  ;; harness: runner/harness-observations.rkt — (expect-running-app bundle-id); #:running? defaults to #t.
  (expect-running-app bundle-id)

  ;; spec: §13 — Launch diagnostic is emitted.
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a REGEXP over events.log; only the stable substring
  ;; "Controls Gallery" is asserted (the launch line's full text is impl-specific — logging contract, §3.6).
  (wait-for-log #rx"Controls Gallery")

  ;; spec: §13 — Roster texts are visible.
  ;; harness: runner/harness-observations.rkt — wait-for-ocr matches a literal substring (string-contains?) and
  ;; polls; matching the first roster text doubles as the render-settled probe for the OCR reads below.
  (wait-for-ocr "Click Me")

  ;; spec: §13 — Roster texts are visible.
  ;; harness: runner/harness-observations.rkt — expect-ocr is a literal substring match.
  (expect-ocr "Option A")

  ;; spec: §13 — Roster texts are visible. (Only Option A / Option B are asserted; a third Option C is a §6
  ;; hole — neither its presence nor its absence is asserted.)
  (expect-ocr "Option B")

  ;; spec: §13 — Roster texts are visible. (The checkbox title only BEGINS "Enable" — capitalization is a §6
  ;; hole — so only the substring is asserted.)
  (expect-ocr "Enable")

  ;; spec: §13 — Window title names the gallery.
  ;; harness: runner/harness-observations.rkt — expect-ocr is a literal substring; the stable on-screen title
  ;; substring is "Controls" (NOT "Controls Gallery" — that substring belongs to the launch log line, §3.6).
  (expect-ocr "Controls")

  ;; spec: §13 — Window title names the gallery.
  ;; harness: runner/harness-observations.rkt — the window AX element exists by role; expect-ax #:title is an
  ;; exact equal? match, so the impl-varying full title is not expressible there (the OCR substring above
  ;; carries it; an AXTitle-substring read is a reported gap).
  (expect-ax #:role 'AXWindow)

  ;; spec: §13 — Slider is present within range.
  ;; harness: runner/harness-observations.rkt — existence by role only; expect-ax has no #:value read, so the
  ;; "value in [0, 100]" half is a reported gap (indirectly witnessed by 07's clamp events value=0/value=100).
  (expect-ax #:role 'AXSlider)

  ;; spec: §13 — Gallery structural elements exist. (combo box — firm role)
  (expect-ax #:role 'AXComboBox)

  ;; spec: §13 — Gallery structural elements exist. (color well — firm role)
  (expect-ax #:role 'AXColorWell)

  ;; spec: §13 — Gallery structural elements exist. (image view — firm role. The date-picker and spinner roles
  ;; are uncertain — AXDateField / AXBusyIndicator, to confirm in-VM — and are recorded provisionally in 03.)
  (expect-ax #:role 'AXImage))
