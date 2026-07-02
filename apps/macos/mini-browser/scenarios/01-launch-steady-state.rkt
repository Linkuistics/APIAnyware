#lang app-spec
;; forward-generated from Mini Browser §13 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "post-launch steady-state observations"
  #:description
  "When Mini Browser has launched in the no-network VM and the failing home load's modal alert has been dismissed (the §13-mandated launch setup — offline, the post-launch steady state IS the post-dismissal state), then: the process is running, the launch line beginning 'Mini Browser' is in events.log, the window's exact accessibility title is 'Mini Browser', the toolbar exposes ◀ ▶ Reload Go button elements with the address field present and prefilled with an https:// URL, and no progress indicator exists (§12). Pure observations sharing one launch; the alert dismissal is lifecycle-mandated setup, not an asserted mutation — the offline failure boundary itself is asserted in 02."

  ;; run: bundle-id — com.linkuistics.mini-browser-<impl>; bound at run time from the impl
  ;; descriptor (ADR-0011). An internal define inside the scenario thunk so it resolves at
  ;; run time, not at load — keeping the suite loadable outside the runner (validation L1a).
  (define bundle-id (run-value 'bundle-id))

  ;; ── §3-lifecycle-mandated setup (spec §13 preamble): dismiss the offline launch alert ──
  ;; spec: §13 — Network reality (preamble) — the [nav] failed event is the deterministic
  ;; pre-dismissal cue (emitted pre-runModal; which failure phase fires offline is
  ;; to-confirm in-VM, so the pattern stays loose — never phase=).
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP, not a substring.
  (wait-for-log #px"\\[nav\\] failed" #:timeout 20.0)
  ;; spec: §13 — Network reality (preamble) — settle: the event precedes the modal; let it run.
  (wait 1.0)
  ;; spec: §13 — Network reality (preamble) — dismiss the modal before reading obscured chrome.
  (press 'return)
  ;; spec: §13 — Network reality (preamble) — settle after dismissal.
  (wait 0.5)

  ;; spec: §13 — Process is running after launch.
  ;; harness: runner/harness-observations.rkt — (expect-running-app bundle-id); #:running?
  ;; defaults to #t.
  (expect-running-app bundle-id)

  ;; spec: §13 — Launch diagnostic is emitted. (the line BEGINS "Mini Browser"; the remainder
  ;; is impl-specific — only the prefix is asserted, the logging contract's prefix rule)
  (wait-for-log #rx"Mini Browser")

  ;; spec: §13 — Window title at launch. (exact — §4 fixes the launch title literally, and
  ;; offline no titled load ever happens, so it is stable for the whole scenario. Whole-screen
  ;; OCR is NOT used for the title: the menu bar also reads "Mini Browser" — non-discriminating.)
  ;; harness: runner/harness-observations.rkt — expect-ax #:title is an exact equal? match.
  (expect-ax #:role 'AXWindow #:title "Mini Browser")

  ;; spec: §13 — Toolbar present. (◀/▶ glyph-as-AXTitle is firm — the pdfkit-firmed row; the
  ;; glyphs ride AX, never OCR)
  (expect-ax #:role 'AXButton #:title "◀")
  ;; spec: §13 — Toolbar present.
  (expect-ax #:role 'AXButton #:title "▶")
  ;; spec: §13 — Toolbar present.
  (expect-ax #:role 'AXButton #:title "Reload")
  ;; spec: §13 — Toolbar present.
  (expect-ax #:role 'AXButton #:title "Go")
  ;; spec: §13 — Toolbar present. (OCR corroboration — the observable-state map's second channel)
  (expect-ocr "Reload")
  ;; spec: §13 — Toolbar present.
  (expect-ocr "Go")

  ;; spec: §13 — Address field is prefilled. (presence rides the role — the field's AX value
  ;; reads back empty under the driver, so content rides OCR below)
  (expect-ax #:role 'AXTextField)
  ;; spec: §13 — Address field is prefilled. (stable substring — home URLs diverge per impl,
  ;; the impl-agnostic rule)
  ;; spec: §12 — No chrome refresh outside didFinishNavigation. (dual trace: the failed launch
  ;; load leaves the field showing the prefill — §7.3 refreshes no chrome)
  (wait-for-ocr "https://")

  ;; spec: §12 (Not included) — No progress indicator. (pure-observation negative, clustered;
  ;; §12 names NSProgressIndicator — AXProgressIndicator is its standard AX role)
  ;; harness: runner/harness-observations.rkt — expect-no-ax asserts role absence.
  (expect-no-ax #:role 'AXProgressIndicator))
