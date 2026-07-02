#lang app-spec
;; forward-generated from PDFKit Viewer §13 on 2026-07-02, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "post-launch steady-state observations"
  #:description "When PDFKit Viewer has launched and reached its post-launch steady state, then the process is running, the launch diagnostic is in the events log, the empty-state label and the invariant window title are readable on screen, the window carries its exact accessibility title, and a toolbar button element exists. Pure observations sharing one launch; the uncertain AX titles/roles (the Open… ellipsis, the arrow glyphs, the label's static-text value fold, the PDF view's scroll-area role) are recorded provisionally in 02, not hard-asserted here."

  ;; run: bundle-id — bound at run time from the impl descriptor (ADR-0011). An internal define inside the
  ;; scenario thunk so it resolves at run time, not at load — keeping the suite loadable outside the runner
  ;; (validation L1a).
  (define bundle-id (run-value 'bundle-id))

  ;; spec: §13 — Process is running after launch.
  ;; harness: runner/harness-observations.rkt — (expect-running-app bundle-id); #:running? defaults to #t.
  (expect-running-app bundle-id)

  ;; spec: §13 — Launch diagnostic is emitted.
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a REGEXP over events.log. The launch line BEGINS
  ;; "PDFKit Viewer" and its remainder is impl-specific (logging contract), so only the prefix is asserted.
  (wait-for-log #rx"PDFKit Viewer")

  ;; spec: §13 — Empty state — label.
  ;; harness: runner/harness-observations.rkt — wait-for-ocr matches a literal substring and polls; the first
  ;; OCR read doubles as the render-settled probe for the reads below (observable-state: the §7.2 empty-state
  ;; label, exact text deterministic for this app).
  (wait-for-ocr "No PDF loaded")

  ;; spec: §13 — Window title is correct.
  ;; harness: runner/harness-observations.rkt — expect-ocr is a literal substring match. The title text
  ;; "PDFKit Viewer" is invariant across impls (§4 — it names the app, not the document), so unlike the
  ;; gallery the full text is assertable.
  (expect-ocr "PDFKit Viewer")

  ;; spec: §13 — Window title is correct.
  ;; harness: runner/harness-observations.rkt — expect-ax #:title is an exact equal? match; usable here
  ;; because §4 fixes the title literally (observable-state role table: firm).
  (expect-ax #:role 'AXWindow #:title "PDFKit Viewer")

  ;; spec: §13 — Toolbar present. (existence by role; the discriminating half is the OCR read below — window
  ;; chrome also carries AXButton elements. The exact "Open…" AXTitle with the real U+2026 is to-confirm and
  ;; recorded provisionally in 02.)
  ;; harness: runner/harness-observations.rkt — expect-ax matches #:role (+ optional exact #:title only).
  (expect-ax #:role 'AXButton)

  ;; spec: §13 — Toolbar present.
  ;; harness: runner/harness-observations.rkt — expect-ocr literal substring. The button title is "Open…"
  ;; (U+2026) but only the "Open" substring is asserted — the ellipsis glyph may not OCR reliably
  ;; (observable-state §OCR).
  (expect-ocr "Open"))
