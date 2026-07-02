#lang app-spec
;; forward-generated from Mini Browser §13 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "blank input navigates nowhere"
  #:description
  "When the address field is emptied (triple-click select-all, then Delete) and Return is pressed, then the status line reads exactly 'Enter a URL to navigate' and nothing else happens — the §6.2 silent no-op: no navigation, no alert, no [nav] event (absence is never asserted, per the logging contract)."

  ;; run: address-field-x/y — AX-reported centre of the address field (framebuffer px);
  ;; bound at run time from the per-app run-values config (ADR-0011). Internal defines so
  ;; they resolve at run time, not at load (validation L1a).
  (define addr-x (run-value 'address-field-x))
  (define addr-y (run-value 'address-field-y))

  ;; ── §3-lifecycle-mandated setup (spec §13 preamble): dismiss the offline launch alert ──
  ;; spec: §13 — Network reality (preamble) — wait for the pre-dismissal cue (loose — the
  ;; offline failure phase is to-confirm).
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP.
  (wait-for-log #px"\\[nav\\] failed" #:timeout 20.0)
  ;; spec: §13 — Network reality (preamble) — settle: let the modal run.
  (wait 1.0)
  ;; spec: §13 — Network reality (preamble) — dismiss the modal.
  (press 'return)
  ;; spec: §13 — Network reality (preamble) — settle after dismissal.
  (wait 0.5)

  ;; spec: §13 — Driver guidance — after a modal has had key, the first click may only
  ;; re-activate the window (the scenekit k112 finding); spend one cursor-placing click.
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y), framebuffer px.
  (click-at addr-x addr-y)
  ;; spec: §13 — Driver guidance — break the click sequence so the triple-click starts fresh.
  (wait 1.0)

  ;; spec: §13 — Boundary — blank input navigates nowhere. (triple-click = select-all; Cmd-A
  ;; is unreliable over the VM input path — §13 driver guidance)
  (click-at addr-x addr-y)
  ;; spec: §13 — Boundary — blank input navigates nowhere.
  (click-at addr-x addr-y)
  ;; spec: §13 — Boundary — blank input navigates nowhere.
  (click-at addr-x addr-y)
  ;; spec: §13 — Boundary — blank input navigates nowhere. (clear the selected prefill)
  (press 'delete)
  ;; spec: §13 — Boundary — blank input navigates nowhere. (submit the empty input)
  (press 'return)
  ;; spec: §13 — Boundary — blank input navigates nowhere. (the status write is synchronous
  ;; with the action — settle for the repaint, then read)
  (wait 0.5)
  ;; spec: §13 — Boundary — blank input navigates nowhere. (deterministic string, exact via
  ;; the status value→AXTitle fold — the firm channel for deterministic status text; OCR is
  ;; not doubled as a gate, the k103 small-text lesson)
  ;; harness: runner/harness-observations.rkt — expect-ax #:title is an exact equal? match.
  (expect-ax #:role 'AXStaticText #:title "Enter a URL to navigate"))
