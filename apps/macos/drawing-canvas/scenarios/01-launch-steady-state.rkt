#lang app-spec
;; forward-generated from Drawing Canvas §14 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "post-launch steady-state observations"
  #:description "When Drawing Canvas has launched and reached its post-launch steady state, then the process is running, the launch line beginning 'Drawing Canvas' is in events.log, the invariant window title is carried as the window's exact accessibility title and readable on screen, the two buttons Color… and Clear are present by exact AX title with OCR corroboration on their ellipsis-free substrings, and a slider element exists by its firm role. Pure observations sharing one launch; the two provisional reads — the slider's folded AXTitle value and the canvas's AX invisibility — are recorded in 02 and 03, not hard-asserted here; everything drawn on the canvas is pixel-level and unobservable to the verbs (observable-state: strokes are framebuffer-visible but OCR-meaningless and AX-invisible) — the [canvas] log events carry the state-level halves in the mutation scenarios."

  ;; run: bundle-id — com.linkuistics.drawing-canvas-<impl>; bound at run time from the impl descriptor
  ;; (ADR-0011). An internal define inside the scenario thunk so it resolves at run time, not at load —
  ;; keeping the suite loadable outside the runner (validation L1a).
  (define bundle-id (run-value 'bundle-id))

  ;; spec: §14 — Process is running after launch.
  ;; harness: runner/harness-observations.rkt — (expect-running-app bundle-id); #:running? defaults to #t.
  (expect-running-app bundle-id)

  ;; spec: §14 — Launch diagnostic is emitted. (the line BEGINS 'Drawing Canvas' and the remainder is
  ;; impl-specific and stays unaligned — the logging contract's prefix rule; only the prefix is matched)
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP over events.log, not a substring.
  (wait-for-log #rx"Drawing Canvas")

  ;; spec: §14 — Toolbar controls present. (the Clear OCR half; polling doubles as the render-settled
  ;; probe for the reads below)
  ;; harness: runner/harness-observations.rkt — wait-for-ocr polls a literal substring.
  (wait-for-ocr "Clear")

  ;; spec: §14 — Toolbar controls present. (the Color OCR half — the ellipsis-free substring 'Color' per
  ;; the standing driver guidance; the U+2026 tail is never relied on in OCR)
  ;; harness: runner/harness-observations.rkt — expect-ocr is a literal substring match.
  (expect-ocr "Color")

  ;; spec: §14 — Window title is correct. (OCR half. Non-discriminating on its own — the app menu's bold
  ;; name is a second on-screen instance of the same text; the AX read below is the firm channel, and
  ;; title-bar OCR garble on compact metrics is a known run-mechanism residual adjudicated by artifact,
  ;; never by patching the suite — observable-state §OCR.)
  (expect-ocr "Drawing Canvas")

  ;; spec: §14 — Window title is correct.
  ;; spec: §13 not-included — No window retitling. (exact match is what makes the invariant assertable;
  ;; re-read after mutations in 08)
  ;; harness: runner/harness-observations.rkt — expect-ax #:title is an exact equal? match; usable because
  ;; §4 fixes the title literally and it is never changed after launch (observable-state role table: firm).
  (expect-ax #:role 'AXWindow #:title "Drawing Canvas")

  ;; spec: §14 — Toolbar controls present. (exact AX title carries the single U+2026 character — firmed
  ;; as AXTitle by the pdfkit k96 rows; observable-state role table: firm)
  (expect-ax #:role 'AXButton #:title "Color…")

  ;; spec: §14 — Toolbar controls present.
  (expect-ax #:role 'AXButton #:title "Clear")

  ;; spec: §14 — Toolbar controls present.
  ;; spec: §14 — Slider initial state. (the ROLE-presence half only — firm, the gallery's k94 suite served
  ;; this role; the value read is provisional and recorded in 02; expect-ax has no value/range attribute,
  ;; so 'value 2 in range 1-20' is otherwise a reported gap — the firm state half rides the first stroke's
  ;; width=2 events in 05, and the range's upper bound is witnessed by the clamped width=20 in 07)
  (expect-ax #:role 'AXSlider))
