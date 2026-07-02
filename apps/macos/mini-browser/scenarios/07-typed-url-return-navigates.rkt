#lang app-spec
;; forward-generated from Mini Browser §13 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "typed URL + Return navigates (fixture success path)"
  #:description
  "When the page-one fixture's file:// URL is typed into the address field and Return is pressed, then the driven load starts and finishes — the finished event carries the canonical URL (the §7.2 address write-back value) — and the status line settles on Done. Realizes the success-path group offline against the fixture pages (the file:// gate is passed — the k116 platform probe). The finished title is never bound (file:// loads read title empty — platform fact), and the field's display is not OCR-gated here: typed ≡ canonical for a file:// URL, so a display read would pass by construction."

  ;; run: address-field-x/y — AX-reported centre of the address field (framebuffer px);
  ;; fixture-one-url — the file:// URL of fixtures/page-one.html as uploaded in-VM under
  ;; /tmp/mini-browser/fixtures/. Bound at run time from the per-app run-values config
  ;; (ADR-0011).
  (define addr-x (run-value 'address-field-x))
  (define addr-y (run-value 'address-field-y))
  (define fixture-one-url (run-value 'fixture-one-url))

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

  ;; spec: §13 — Typed URL + Return navigates. (triple-click = select-all)
  (click-at addr-x addr-y)
  ;; spec: §13 — Typed URL + Return navigates.
  (click-at addr-x addr-y)
  ;; spec: §13 — Typed URL + Return navigates.
  (click-at addr-x addr-y)
  ;; spec: §13 — Typed URL + Return navigates. (type the fixture URL)
  (type fixture-one-url)
  ;; spec: §13 — Typed URL + Return navigates. (Return fires the go action)
  (press 'return)

  ;; spec: §13 — Home page loads. (the loading phase is reached — [nav] started is emitted
  ;; post-state, after the status is set to the loading message; the transient Loading OCR
  ;; is skipped as timing-fragile, §13 itself marks it optional. Fixture BASENAME only,
  ;; regex-escaped, scheme pinned — the pdfkit basename rule; bound because this scenario
  ;; drove the load.)
  (wait-for-log #px"\\[nav\\] started url=\"file:[^\"]*page-one\\.html\"" #:timeout 15.0)
  ;; spec: §13 — Typed URL + Return navigates. (the driven load finishes)
  ;; spec: §13 — Address bar canonicalizes. (the finished url= key IS the §7.2 canonical
  ;; write-back value read at callback time — the operative offline channel; title left
  ;; unmatched by ending the pattern at the url key)
  (wait-for-log #px"\\[nav\\] finished url=\"file:[^\"]*page-one\\.html\"" #:timeout 15.0)
  ;; spec: §13 — Home page loads. (finished is post-state: the whole §7.2 refresh has run —
  ;; settle for the repaint, then read)
  (wait 0.5)
  ;; spec: §13 — Home page loads. (settles on Done — exact via the status value→AXTitle
  ;; fold, the firm channel; OCR is not doubled as a gate, the k103 small-text lesson)
  ;; harness: runner/harness-observations.rkt — expect-ax #:title is an exact equal? match.
  (expect-ax #:role 'AXStaticText #:title "Done"))
