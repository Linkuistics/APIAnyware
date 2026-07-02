#lang app-spec
;; forward-generated from Mini Browser §13 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "history walk: enables, back, forward"
  #:description
  "After two distinct fixture loads: the second finished event reports can-go-back=true can-go-forward=false (history enabled — the ◀/▶ enabled flags' operative channel, read in the same §7.2 refresh that sets the buttons); when ◀ is clicked the previous page finishes again with can-go-forward=true and the address field reverts to the previous URL; when ▶ is then clicked the newer page re-finishes with can-go-forward=false — ▶ re-disabled at the history head. One driven sequence (the pdfkit navigation-walk precedent): the three §13 lines are causally chained — history must exist to walk it, and forward requires a prior back — so splitting them would re-drive the same prefix under extra VM launches for no isolation gain; every step carries its own §13 trace."

  ;; run: address-field-x/y — AX-reported centre of the address field; back-button-x/y and
  ;; forward-button-x/y — the ◀/▶ button centres (framebuffer px); fixture-one-url and
  ;; fixture-two-url — the file:// URLs of the uploaded fixture pages. Bound at run time
  ;; from the per-app run-values config (ADR-0011).
  (define addr-x (run-value 'address-field-x))
  (define addr-y (run-value 'address-field-y))
  (define back-x (run-value 'back-button-x))
  (define back-y (run-value 'back-button-y))
  (define fwd-x  (run-value 'forward-button-x))
  (define fwd-y  (run-value 'forward-button-y))
  (define fixture-one-url (run-value 'fixture-one-url))
  (define fixture-two-url (run-value 'fixture-two-url))

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

  ;; spec: §13 — History enables after a second load. (first load — the driven prefix;
  ;; triple-click = select-all)
  (click-at addr-x addr-y)
  ;; spec: §13 — History enables after a second load.
  (click-at addr-x addr-y)
  ;; spec: §13 — History enables after a second load.
  (click-at addr-x addr-y)
  ;; spec: §13 — History enables after a second load.
  (type fixture-one-url)
  ;; spec: §13 — History enables after a second load.
  (press 'return)
  ;; spec: §13 — History enables after a second load. (sync — the first load finishes; its
  ;; booleans stay deliberately unbound: whether the failed home load leaves a history entry
  ;; is unconfirmed platform behaviour)
  (wait-for-log #px"\\[nav\\] finished url=\"file:[^\"]*page-one\\.html\"" #:timeout 15.0)

  ;; spec: §13 — History enables after a second load. (second, distinct load — re-select the
  ;; field; no re-activation click needed, no modal intervened)
  (click-at addr-x addr-y)
  ;; spec: §13 — History enables after a second load.
  (click-at addr-x addr-y)
  ;; spec: §13 — History enables after a second load.
  (click-at addr-x addr-y)
  ;; spec: §13 — History enables after a second load.
  (type fixture-two-url)
  ;; spec: §13 — History enables after a second load.
  (press 'return)
  ;; spec: §13 — History enables after a second load. (fixed key order, bare booleans — the
  ;; logging contract; title matched agnostically, file:// loads read title empty;
  ;; can-go-back=true across a file→file hop is the k116 platform fact)
  (wait-for-log #px"\\[nav\\] finished url=\"file:[^\"]*page-two\\.html\" title=\"[^\"]*\" can-go-back=true can-go-forward=false" #:timeout 15.0)

  ;; spec: §13 — Back walks history. (click ◀)
  (click-at back-x back-y)
  ;; spec: §13 — Back walks history. (the back-target finishes again; can-go-forward=true is
  ;; the discriminator — the first page-one finished line carried can-go-forward=false, so
  ;; this cannot match that older line in the monotonic buffer; can-go-back is left unbound,
  ;; §13 does not assert the at-tail state)
  (wait-for-log #px"\\[nav\\] finished url=\"file:[^\"]*page-one\\.html\" title=\"[^\"]*\" can-go-back=(?:true|false) can-go-forward=true" #:timeout 15.0)
  ;; spec: §13 — Back walks history. (address reverts — the display half via OCR, the field's
  ;; AX value being empty; discriminating here: the field showed page-two.html just before
  ;; the click, and no other on-screen text carries the page-one basename URL. The §13
  ;; title-revert half is offline-unassertable — the window title never left the fallback —
  ;; part of the title-tracking gap.)
  (wait-for-ocr "page-one.html" #:timeout 10.0)

  ;; spec: §13 — Forward walks history. (click ▶)
  (click-at fwd-x fwd-y)
  ;; spec: §13 — Forward walks history. (the newer page finishes again with ▶ re-disabled at
  ;; the head; this line is textually identical to the earlier head line, so the matcher
  ;; pins it AFTER the back-walk line — the only can-go-forward=true finished line in this
  ;; scenario's buffer — using an ordered (?s:) chain over the monotonic accumulator: still
  ;; matching the specific line this scenario drove to, never counting events)
  (wait-for-log #px"(?s:\\[nav\\] finished url=\"file:[^\"]*page-one\\.html\" title=\"[^\"]*\" can-go-back=(?:true|false) can-go-forward=true.*\\[nav\\] finished url=\"file:[^\"]*page-two\\.html\" title=\"[^\"]*\" can-go-back=true can-go-forward=false)" #:timeout 15.0)
  ;; spec: §13 — Forward walks history. (the address shows the newer page again — display
  ;; half via OCR, discriminating: the field showed page-one.html just before the click)
  (wait-for-ocr "page-two.html" #:timeout 10.0))
