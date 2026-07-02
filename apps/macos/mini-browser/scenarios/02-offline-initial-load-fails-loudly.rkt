#lang app-spec
;; forward-generated from Mini Browser §13 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "offline initial load fails loudly"
  #:description
  "When the app launches with no network, then the home load starts and fails: [nav] started then [nav] failed appear in events.log (failed is the pre-runModal dismissal cue), a modal warning alert runs, and dismissing it with Return reveals a status line containing 'failed: '. The mutation here is the mandated dismissal itself — this scenario asserts the §13 failure boundary that every other scenario replays as setup."

  ;; spec: §13 — Boundary — offline initial load fails loudly. (the launch load reaches the
  ;; loading phase; the home URL is impl-specific — started url= is deliberately NOT bound,
  ;; the logging contract's bind-only-scenario-driven-loads rule)
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP, not a substring.
  (wait-for-log #px"\\[nav\\] started" #:timeout 20.0)
  ;; spec: §13 — Boundary — offline initial load fails loudly. (which failure callback the
  ;; platform delivers offline is to-confirm in-VM — matched loosely, never phase=; the
  ;; event is emitted pre-runModal, the deterministic dismissal cue)
  (wait-for-log #px"\\[nav\\] failed" #:timeout 20.0)
  ;; spec: §13 — Boundary — offline initial load fails loudly. (settle — let the modal run;
  ;; alert-chrome OCR is skipped: its platform text is to-confirm, the log event is the cue)
  (wait 1.0)
  ;; spec: §13 — Boundary — offline initial load fails loudly. (Return dismisses the modal)
  (press 'return)
  ;; spec: §13 — Boundary — offline initial load fails loudly. (the post-dismissal §7.3
  ;; status line — stable substring; the phase word and message are impl/platform-realized)
  (wait-for-ocr "failed:" #:timeout 10.0))
