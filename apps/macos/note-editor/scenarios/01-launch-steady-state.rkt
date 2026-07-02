#lang app-spec
;; forward-generated from Note Editor §15 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "post-launch steady-state observations"
  #:description
  "When Note Editor has launched, then: the process is running, the launch line beginning 'Note Editor' is in events.log, the window's exact accessibility title is 'Untitled — Note Editor', the toolbar exposes the five buttons New/Open…/Save…/Undo/Redo, the status line reads Ready — and stays Ready after a deliberate pause (§14: no status timers; 'unchanged' is expressible here because the AX #:title match is exact), and the preview shows the placeholder — witnessed app-side by the launch sequence's [preview] rendered placeholder=true chars=0 event (the firm half; the to-confirm OCR half is isolated in recording scenario 02 so this hard cluster stays free of the known-risk k103 channel). Pure observations sharing one launch; no mutation."

  ;; run: bundle-id — com.linkuistics.note-editor-<impl>; bound at run time from the impl
  ;; descriptor (ADR-0011). An internal define inside the scenario thunk so it resolves at
  ;; run time, not at load — keeping the suite loadable outside the runner (validation L1a).
  (define bundle-id (run-value 'bundle-id))

  ;; spec: §15 — Process is running after launch.
  ;; harness: runner/harness-observations.rkt — (expect-running-app bundle-id); #:running?
  ;; defaults to #t.
  (expect-running-app bundle-id)

  ;; spec: §15 — Launch diagnostic is emitted. (the line BEGINS 'Note Editor'; the remainder
  ;; is impl-specific and stays unaligned — the logging contract's prefix rule; only the
  ;; prefix is asserted)
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP, not a substring.
  (wait-for-log #rx"Note Editor")

  ;; spec: §15 — Placeholder shows in the preview. (the firm app-side half: the §3 step-5
  ;; initial render's hand-off event, emitted before the window appears — logging contract
  ;; launch sequence; \\b guards the digit boundary so chars=0 cannot match a longer count.
  ;; The line's to-confirm OCR half lives in recording scenario 02.)
  (wait-for-log #px"\\[preview\\] rendered placeholder=true chars=0\\b")

  ;; spec: §15 — Window title at launch. (exact §6.1 launch form, real U+2014 em dashes —
  ;; the window AX title is the dirty/name channel of record; whole-screen OCR is NOT used
  ;; for the title: the menu bar also reads 'Note Editor' — non-discriminating)
  ;; harness: runner/harness-observations.rkt — expect-ax #:title is an exact equal? match.
  (expect-ax #:role 'AXWindow #:title "Untitled — Note Editor")

  ;; spec: §15 — Toolbar is present. (the five §5.1 button titles, exact AX forms — the
  ;; ellipsis-bearing titles carry the single character U+2026, firmed as AXTitle by the
  ;; pdfkit k96 rows)
  (expect-ax #:role 'AXButton #:title "New")
  ;; spec: §15 — Toolbar is present.
  (expect-ax #:role 'AXButton #:title "Open…")
  ;; spec: §15 — Toolbar is present.
  (expect-ax #:role 'AXButton #:title "Save…")
  ;; spec: §15 — Toolbar is present.
  (expect-ax #:role 'AXButton #:title "Undo")
  ;; spec: §15 — Toolbar is present.
  (expect-ax #:role 'AXButton #:title "Redo")
  ;; spec: §15 — Toolbar is present. (OCR corroboration on ellipsis-free titles — the §15
  ;; driver guidance; expect-ocr is a case-sensitive literal substring)
  (expect-ocr "New")
  ;; spec: §15 — Toolbar is present.
  (expect-ocr "Undo")

  ;; spec: §15 — Status starts Ready. (exact via the status value→AXTitle fold — the firm
  ;; channel for the 11-pt label, firmed at k80 ×4)
  (expect-ax #:role 'AXStaticText #:title "Ready")
  ;; spec: §15 — Status starts Ready. (OCR corroboration — 11-pt small text, the k103
  ;; class; a garble here adjudicates by artifact against the AX read above)
  (expect-ocr "Ready")

  ;; spec: §14 — No status timers. (a pure steady-state negative, clustered: after a
  ;; deliberate 2s pause the status must still be exactly Ready — a timer clearing or
  ;; replacing it would fail the exact re-read; AX exactness is what makes 'unchanged'
  ;; expressible, unlike the presence-only OCR channel)
  (wait 2.0)
  (expect-ax #:role 'AXStaticText #:title "Ready"))
