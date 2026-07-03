#lang app-spec
;; forward-generated from Drawing Canvas §14 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: provisional slider initial-value read"
  #:description "When Drawing Canvas is at its post-launch steady state, then the width slider's value is 2 — expected folded into the slider element's AXTitle by the SDK transform (label -> value -> description, first non-empty; the slider has no label so the value is expected to fold in), matched exactly as '2' per the logging contract's integer formatting of the same stored double. Provisional (observable-state role table: the value/range read format under the SDK transform is a provisional value-read, to confirm at live-run before hard-binding): a PASS confirms the fold and its format, so a regeneration may fold this read into the hard cluster (01); a FAILURE is a read-format / role-mapping finding for human review — the run stage rebinds the format — not a suite bug. The firm state half of §14's slider line rides the first stroke's events carrying width=2 (scenario 05). Pure observation: shares no mutation."

  ;; spec: §14 — Launch diagnostic is emitted. (Re-asserted as the presentation-settled probe: the logging
  ;; contract emits the launch line only once the window is key+front, so the read below sees the fully
  ;; presented window.)
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a regexp.
  (wait-for-log #rx"Drawing Canvas")

  ;; spec: §14 — Slider initial state. (the provisional value half: initial 2 in range 1-20, §5.1/§12 —
  ;; only the value is readable, and only via the AXTitle fold; the range has no AX read at all — the
  ;; upper bound is witnessed by 07's clamped width=20, the lower bound stays a reported gap)
  ;; harness: runner/harness-observations.rkt — expect-ax #:title is an exact equal? match.
  (expect-ax #:role 'AXSlider #:title "2"))
