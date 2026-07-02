#lang app-spec
;; forward-generated from Mini Browser §13 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: unparseable URL is reported, not loaded"
  #:description
  "When text the platform URL parser rejects (here: input containing spaces, §13's own example) is submitted, then the status line begins 'Invalid URL: ' — the §6.2 silent no-op (no navigation, no alert, no [nav] event; absence never asserted). recording: which strings NSURL initWithString: rejects is platform behaviour (to confirm in-VM) — a pass confirms the expectation and signals reverse-gen may drop the marker; a failure (e.g. the platform accepting or percent-encoding the string) is a spec-quality finding, not a suite bug — the runner captures artifacts for review."

  ;; run: address-field-x/y — AX-reported centre of the address field (framebuffer px);
  ;; bound at run time from the per-app run-values config (ADR-0011).
  (define addr-x (run-value 'address-field-x))
  (define addr-y (run-value 'address-field-y))

  ;; ── §3-lifecycle-mandated setup (spec §13 preamble): dismiss the offline launch alert ──
  ;; spec: §13 — Network reality (preamble) — wait for the pre-dismissal cue.
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP.
  (wait-for-log #px"\\[nav\\] failed" #:timeout 20.0)
  ;; spec: §13 — Network reality (preamble) — settle: let the modal run.
  (wait 1.0)
  ;; spec: §13 — Network reality (preamble) — dismiss the modal.
  (press 'return)
  ;; spec: §13 — Network reality (preamble) — settle after dismissal.
  (wait 0.5)

  ;; spec: §13 — Driver guidance — re-activation click after the dismissed modal (k112).
  (click-at addr-x addr-y)
  ;; spec: §13 — Driver guidance — break the click sequence so the triple-click starts fresh.
  (wait 1.0)

  ;; spec: (to confirm in-VM) — Boundary — unparseable URL is reported, not loaded.
  ;; (triple-click = select-all)
  (click-at addr-x addr-y)
  ;; spec: (to confirm in-VM) — Boundary — unparseable URL is reported, not loaded.
  (click-at addr-x addr-y)
  ;; spec: (to confirm in-VM) — Boundary — unparseable URL is reported, not loaded.
  (click-at addr-x addr-y)
  ;; spec: (to confirm in-VM) — Boundary — unparseable URL is reported, not loaded. (space-
  ;; bearing input; §6.2 prepends https:// first, then NSURL is expected to reject it)
  (type "not a url")
  ;; spec: (to confirm in-VM) — Boundary — unparseable URL is reported, not loaded. (submit)
  (press 'return)
  ;; spec: (to confirm in-VM) — Boundary — unparseable URL is reported, not loaded. (stable
  ;; prefix only — the suffix text is ambiguous between §6.2 'normalized' and the
  ;; observable-state 'typed', a spec-quality finding fed back to reverse-gen; AX-exact is
  ;; therefore unusable and OCR is the mapped channel)
  (wait-for-ocr "Invalid URL" #:timeout 10.0))
