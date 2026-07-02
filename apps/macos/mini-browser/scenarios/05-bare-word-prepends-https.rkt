#lang app-spec
;; forward-generated from Mini Browser §13 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "bare word is treated as a URL, never a search"
  #:description
  "When the schemeless bare word not-a-url is submitted, then the attempted navigation's [nav] started event witnesses the §6.2 https:// prepend (url=\"https://not-a-url…\") even though the load then fails offline — input is always a URL, never a search query. The started url= is bound because this scenario drove the load (the logging contract's rule). The ensuing second failure/alert is deliberately NOT waited on: [nav] failed carries no url key, so it is indistinguishable from the launch failure already in the monotonic buffer; the per-scenario teardown clears the pending alert (quit-impl! escalates past a modal — the k112 fix)."

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

  ;; spec: §13 — Boundary — input is a URL, never a search. (triple-click = select-all)
  (click-at addr-x addr-y)
  ;; spec: §13 — Boundary — input is a URL, never a search.
  (click-at addr-x addr-y)
  ;; spec: §13 — Boundary — input is a URL, never a search.
  (click-at addr-x addr-y)
  ;; spec: §13 — Boundary — input is a URL, never a search. (a schemeless bare word)
  (type "not-a-url")
  ;; spec: §13 — Boundary — input is a URL, never a search. (submit)
  (press 'return)
  ;; spec: §13 — Boundary — input is a URL, never a search. (the started url= witnesses the
  ;; prepend, offline, for this scenario-driven load — the logging contract's own matcher.
  ;; The line's to-confirm tail — the exact failure sequence that follows — is left
  ;; unasserted; only the contract-firm prepend witness gates.)
  ;; spec: §13 — Bare host gets `https://` prepended. (the rule's log half — the display half
  ;; is network-gated: §7.2 writes the address back only on finish; documented gap)
  (wait-for-log #px"\\[nav\\] started url=\"https://not-a-url" #:timeout 15.0))
