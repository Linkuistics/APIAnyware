#lang app-spec
;; forward-generated from Mini Browser §13 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "Reload re-navigates"
  #:description
  "When Reload is clicked on a loaded fixture page, then a fresh started + finished cycle for the same URL follows and the status line settles on Done again (reload is unconditional and fires the same [nav] pair as a typed navigation)."

  ;; run: address-field-x/y — AX-reported centre of the address field; reload-button-x/y —
  ;; the Reload button's centre (framebuffer px); fixture-one-url — the file:// URL of the
  ;; uploaded fixture page-one.html. Bound at run time from the per-app run-values config
  ;; (ADR-0011).
  (define addr-x (run-value 'address-field-x))
  (define addr-y (run-value 'address-field-y))
  (define reload-x (run-value 'reload-button-x))
  (define reload-y (run-value 'reload-button-y))
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

  ;; spec: §13 — Reload re-navigates. (complete a load first — the driven prefix;
  ;; triple-click = select-all)
  (click-at addr-x addr-y)
  ;; spec: §13 — Reload re-navigates.
  (click-at addr-x addr-y)
  ;; spec: §13 — Reload re-navigates.
  (click-at addr-x addr-y)
  ;; spec: §13 — Reload re-navigates.
  (type fixture-one-url)
  ;; spec: §13 — Reload re-navigates.
  (press 'return)
  ;; spec: §13 — Reload re-navigates. (sync — the first load's finished line)
  (wait-for-log #px"\\[nav\\] finished url=\"file:[^\"]*page-one\\.html\"" #:timeout 15.0)

  ;; spec: §13 — Reload re-navigates. (click Reload; the window is active, the click delivers)
  (click-at reload-x reload-y)
  ;; spec: §13 — Reload re-navigates. (a fresh started AFTER the completed load — pinned via
  ;; an ordered (?s:) chain over the monotonic buffer: the typed load's own started precedes
  ;; its finished, so a started following that finished can only be the reload's. The
  ;; reload's provisional started url= value is left unbound — started-url fidelity on
  ;; non-typed navigations is to-confirm.)
  (wait-for-log #px"(?s:\\[nav\\] finished url=\"file:[^\"]*page-one\\.html\".*\\[nav\\] started url=)" #:timeout 15.0)
  ;; spec: §13 — Reload re-navigates. (…through to a fresh finished with the same basename —
  ;; the full chain: finished → started → finished)
  (wait-for-log #px"(?s:\\[nav\\] finished url=\"file:[^\"]*page-one\\.html\".*\\[nav\\] started url=.*\\[nav\\] finished url=\"file:[^\"]*page-one\\.html\")" #:timeout 15.0)
  ;; spec: §13 — Reload re-navigates. (settle for the repaint)
  (wait 0.5)
  ;; spec: §13 — Reload re-navigates. (Done again — exact via the status value→AXTitle fold)
  ;; harness: runner/harness-observations.rkt — expect-ax #:title is an exact equal? match.
  (expect-ax #:role 'AXStaticText #:title "Done"))
