#lang app-spec
;; forward-generated from PDFKit Viewer §13 on 2026-07-02, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: provisional accessibility roles and titles"
  #:description "When the viewer is at its post-launch empty steady state, then the toolbar controls and the document view are expected in the accessibility tree with the observable-state contract's expected roles/titles: the Open… button (exact AXTitle with the real U+2026), the ◀/▶ arrow buttons (glyph-as-AXTitle), the page label as static text whose value 'No PDF loaded' folds into AXTitle, and the PDF view as a scroll area. Every read here is marked to-confirm/uncertain by the contract's role table. Provisional (to confirm in-VM): a PASS confirms the rows so a regeneration may fold them into the hard cluster (01); a FAILURE is a role-mapping finding for human review (the gallery precedent: the date-picker role was corrected in-VM), not a suite bug. Pure observations: shares no mutation."

  ;; spec: §13 — Launch diagnostic is emitted. (Re-asserted as the presentation-settled probe: the logging
  ;; contract emits the launch line only once the window is key+front, so the AX snapshots below see the
  ;; fully-presented window.)
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a regexp.
  (wait-for-log #rx"PDFKit Viewer")

  ;; spec: §13 — Toolbar present. (the Open button's exact title — role firm, ellipsis-in-AXTitle to confirm:
  ;; observable-state role table. The title string uses the real U+2026 HORIZONTAL ELLIPSIS, not three dots.)
  ;; harness: runner/harness-observations.rkt — expect-ax #:title is an exact equal? match.
  (expect-ax #:role 'AXButton #:title "Open…")

  ;; spec: §13 — Empty state — navigation disabled. (the ◀/▶ button ELEMENTS the line names — their enabled
  ;; flags are the app's headline reported gap (runner-side: the SDK transform drops `enabled`; expect-ax has
  ;; no #:enabled?), so only existence-by-glyph-title is read here, glyph-as-AXTitle to confirm in-VM. The
  ;; behavioural half of the line is scenario 03; the label + [document] events are the operative proxies.)
  (expect-ax #:role 'AXButton #:title "◀")

  ;; spec: §13 — Empty state — navigation disabled. (as above — the ▶ next-page button element)
  (expect-ax #:role 'AXButton #:title "▶")

  ;; spec: §13 — Empty state — label. (the AXStaticText realization: the SDK transform folds an element's
  ;; value into AXTitle, so the label's exact value is expected matchable — to confirm in-VM; OCR (01) is the
  ;; firm channel either way.)
  (expect-ax #:role 'AXStaticText #:title "No PDF loaded")

  ;; spec: observable-state role table (§5.2 — the PDF view; no §13 line asserts the empty view directly).
  ;; PDFView wraps a scroll view in continuous mode, so AXScrollArea is the expected role — marked uncertain
  ;; by the contract; confirmed/corrected here so the live-run stage can firm the table.
  (expect-ax #:role 'AXScrollArea))
