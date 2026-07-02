#lang app-spec
;; forward-generated from PDFKit Viewer §13 on 2026-07-02, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: page navigation walks the document boundaries"
  #:description "When the user walks the 3-page fixture with the arrow buttons — 1 ▶ 2 ▶ 3, an extra ▶ at the last page, then 3 ◀ 2 ◀ 1 — then each turn updates the label through the page-changed notification (§7.1 indirection), the first/last boundaries hold (▶ advances from page 1; ▶ is inert at page 3 — no wrap-around), and both directions succeed from/through the interior page 2. The direct enabled-flag reads at each boundary are the app's headline reported gap; the label + [document] page-changed events (driven by the same §7.2 refresh rule as the flags) are the operative proxies. Provisional (the §13 advance/interior/last/no-wrap/back lines are all to-confirm-in-VM): a PASS confirms; a FAILURE is a spec-quality finding, not a suite bug. State-mutating flow: one launch + one open shared by the sequential navigation steps (per-scenario relaunch makes each step's precondition an entire open flow), each mutation carrying its own-effect read."

  ;; run: open-button-x/y, prev-button-x/y, next-button-x/y — toolbar click coordinates (framebuffer px);
  ;; fixture-path — the in-VM fixture path. Bound at run time from the per-app run-values config via
  ;; current-run-values (ADR-0011); internal defines so they resolve at run time, not at load (L1a).
  (define open-button-x (run-value 'open-button-x))
  (define open-button-y (run-value 'open-button-y))
  (define prev-button-x (run-value 'prev-button-x))
  (define prev-button-y (run-value 'prev-button-y))
  (define next-button-x (run-value 'next-button-x))
  (define next-button-y (run-value 'next-button-y))
  (define fixture-path (run-value 'fixture-path))

  ;; ── setup: the §13 fixture-rule open flow (as scenario 05, which asserts it in full) ──
  ;; spec: §13 — Launch diagnostic is emitted. (presentation-settled probe)
  (wait-for-log #rx"PDFKit Viewer")
  ;; spec: §13 — Empty state — label. (render-settled probe before the coordinate click)
  (wait-for-ocr "No PDF loaded")
  (click-at open-button-x open-button-y)
  (wait-for-ocr "Cancel")
  (chord '(cmd shift) 'g)
  (wait 1)
  (type fixture-path)
  (press 'return)
  (wait 1)
  (press 'return)
  ;; spec: (to confirm in-VM) — Open loads page 1. (the open-completed signal gating the walk)
  (wait-for-log #px"\\[document\\] opened file=\"fixture\\.pdf\" pages=3")

  ;; spec: (to confirm in-VM) — Boundary — first page. (the ◀-disabled/▶-enabled flags are the reported
  ;; gap; the label 'Page 1 of 3' plus the advance below SUCCEEDING are the documented proxy.)
  ;; harness: runner/harness-observations.rkt — wait-for-ocr polls a literal substring.
  (wait-for-ocr "Page 1 of 3")

  ;; spec: (to confirm in-VM) — Advance. (▶ from page 1; the update flows through the page-changed
  ;; notification — the handlers never refresh directly, §7.1)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at next-button-x next-button-y)
  ;; spec: (to confirm in-VM) — Advance. (match the specific driven-to line — never a count or an ordering
  ;; relative to `opened`, logging contract)
  ;; harness: runner/harness-logs.rkt — regexp.
  (wait-for-log #px"\\[document\\] page-changed page=2 pages=3")
  (wait-for-ocr "Page 2 of 3")

  ;; spec: (to confirm in-VM) — Boundary — last page. (▶ from the interior page 2 — also the 'advance
  ;; succeeds from the interior page' half of the §13 interior-page proxy; the ▶-disabled flag at page 3 is
  ;; the reported gap, proxied by the no-wrap step below.)
  (click-at next-button-x next-button-y)
  (wait-for-log #px"\\[document\\] page-changed page=3 pages=3")
  (wait-for-ocr "Page 3 of 3")

  ;; spec: (to confirm in-VM) — Boundary — no wrap-around. (a further ▶ at the last page changes nothing)
  (click-at next-button-x next-button-y)
  ;; harness: runner/harness-state.rkt — (wait seconds): settle so a (wrong) wrap would have repainted
  ;; before the read — without it a pre-repaint frame could false-pass the persistence check. No page-changed
  ;; event is expected and its ABSENCE is not asserted (silent no-ops emit nothing; never a negative log read).
  (wait 1)
  ;; harness: runner/harness-observations.rkt — expect-ocr is single-shot; the label must still read the
  ;; last page.
  (expect-ocr "Page 3 of 3")

  ;; spec: (to confirm in-VM) — Back. (◀ from page 3. The page=2 event is NOT waited on here: the tailer
  ;; re-scans the scenario's buffered content, so the advance's earlier page=2 line would satisfy it
  ;; immediately (the gallery slider \\b lesson); the live-screen OCR carries the assertion instead.)
  (click-at prev-button-x prev-button-y)
  (wait-for-ocr "Page 2 of 3")

  ;; spec: (to confirm in-VM) — Interior page. (◀ from the interior page 2 — with the earlier ▶ from
  ;; page 2, both directions have now succeeded from the interior page: the documented proxy for the
  ;; both-enabled flags. 'Page 1 of 3' is OCR-discriminating here — the screen currently shows page 2.)
  (click-at prev-button-x prev-button-y)
  (wait-for-ocr "Page 1 of 3"))
