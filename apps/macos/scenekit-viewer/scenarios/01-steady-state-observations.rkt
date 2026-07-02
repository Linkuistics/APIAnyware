#lang app-spec
;; forward-generated from SceneKit Viewer §13 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "post-launch steady-state observations"
  #:description "When SceneKit Viewer has launched and reached its post-launch steady state, then the process is running, the launch diagnostic is in the events log, the invariant window title is readable on screen and carried as the window's exact accessibility title, a pop-up-button element (the geometry picker) exists, and a button element with the stable 'Colo' title substring (the colour button) exists. Pure observations sharing one launch. The to-confirm halves — the picker's first-item 'Cube' selected value and its value->AXTitle fold — are recorded provisionally in 02, not hard-asserted here; everything rendered inside the SCNView viewport is pixel-level and unobservable to the verbs (observable-state: this app's defining constraint) — the [scene] log events carry the state-level assertions in the mutation scenarios."

  ;; run: bundle-id — bound at run time from the impl descriptor (ADR-0011). An internal define inside the
  ;; scenario thunk so it resolves at run time, not at load — keeping the suite loadable outside the runner
  ;; (validation L1a).
  (define bundle-id (run-value 'bundle-id))

  ;; spec: §13 — Process is running after launch.
  ;; harness: runner/harness-observations.rkt — (expect-running-app bundle-id); #:running? defaults to #t.
  (expect-running-app bundle-id)

  ;; spec: §13 — Launch diagnostic is emitted.
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a REGEXP over events.log. The launch line BEGINS
  ;; "SceneKit Viewer" and its remainder is impl-specific (logging contract) — only the prefix is asserted.
  (wait-for-log #rx"SceneKit Viewer")

  ;; spec: §13 — Colour button present. (OCR half; doubles as the render-settled probe for the reads below.
  ;; The realized title is "Color…" or "Colour…" per impl (§5.1), so only the stable "Colo" substring is
  ;; asserted, and the U+2026 tail is never relied on — it may not OCR reliably (observable-state §OCR).)
  ;; harness: runner/harness-observations.rkt — wait-for-ocr polls a literal substring.
  (wait-for-ocr "Colo")

  ;; spec: §13 — Window title is correct.
  ;; harness: runner/harness-observations.rkt — expect-ocr is a literal substring match. The title text
  ;; "SceneKit Viewer" is invariant across impls (§4 — never changed after launch), so the full text is
  ;; assertable. (Title-bar OCR garble is a known run-mechanism residual — adjudicate by artifact review,
  ;; never by patching the suite; observable-state §OCR.)
  (expect-ocr "SceneKit Viewer")

  ;; spec: §13 — Window title is correct.
  ;; harness: runner/harness-observations.rkt — expect-ax #:title is an exact equal? match; usable here
  ;; because §4 fixes the title literally (observable-state role table: firm).
  (expect-ax #:role 'AXWindow #:title "SceneKit Viewer")

  ;; spec: §13 — Picker present, first item selected. (the PRESENCE half only — role firm,
  ;; gallery-confirmed; the "first item selected" half is (to confirm in-VM) — the platform's first-item
  ;; default plus the popup value->AXTitle fold — so it lives in the recording scenario 02, never here.)
  ;; harness: runner/harness-observations.rkt — expect-ax matches #:role (+ optional exact #:title only).
  (expect-ax #:role 'AXPopUpButton)

  ;; spec: §13 — Colour button present. (existence by role; the discriminating half is the "Colo" OCR read
  ;; above. An exact AXTitle match is UNUSABLE: the realized spelling is impl-varying ("Color…"/"Colour…",
  ;; §5.1) and expect-ax #:title is exact-only — baking one spelling would violate the impl-agnostic rule.)
  ;; harness: runner/harness-observations.rkt — expect-ax matches #:role (+ optional exact #:title only).
  (expect-ax #:role 'AXButton))
