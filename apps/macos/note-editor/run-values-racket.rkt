#lang app-spec/run-values

;; Per-app run-values config for Note Editor — RACKET sibling (ADR-0011).
;; The racket impl's compact 22px control metrics (the standing
;; k77/k94/k103/k121 precedent) shift every toolbar control off the
;; shared chez+gerbil+sbcl table (run-values.rkt): window (510,116)
;; 900x628 vs the shared 900x632, toolbar centre-line fb y 166 vs 171,
;; narrower controls (New 48px, Open… 63px, Save… 59px, Undo 53px,
;; Redo 51px), 12px traffic lights. Coordinates are live-measured AX
;; element centres (framebuffer px) from `agent snapshot --window
;; "Untitled — Note Editor" --mode layout` on the 1920x1080 VM,
;; two-launch determinism diff green (live-run-k130, 2026-07-03). Pass
;; this file as --run-values for the racket impl only; the editor point,
;; alert coordinates (screen-centred NSAlert — layout-independent) and
;; fixture/scratch paths are identical to the shared table.

(run-values
  ;; scenarios/03–07,09–12,15,17,18,20 — a point inside the editor pane
  ;; (split group (522,200) 876x532; left half x 522–960)
  (editor-click-x 741)
  (editor-click-y 447)
  ;; toolbar buttons, centre-line fb y 166 — measured centres:
  ;; New (521,155) 48x22, Open… (575,155) 63x22, Save… (644,155) 59x22,
  ;; Undo (709,155) 53x22, Redo (768,155) 51x22
  (new-button-x 545)
  (new-button-y 166)
  (open-button-x 607)
  (open-button-y 166)
  (save-button-x 674)
  (save-button-y 166)
  (undo-button-x 736)
  (undo-button-y 166)
  (redo-button-x 794)
  (redo-button-y 166)
  ;; scenarios/10,12 — the §8.1 alert's Cancel button centre, measured
  ;; from the OPEN alert (identical to the shared table: the
  ;; screen-centred NSAlert is layout-independent)
  (alert-cancel-x 901)
  (alert-cancel-y 419)
  ;; scenario/21 — the window close control (12x14 compact traffic
  ;; light at AX (518,123)) centre
  (close-button-x 524)
  (close-button-y 130)
  ;; scenarios/08,16 — the in-VM fixture paths
  (fixture-path "/tmp/note-editor/fixtures/fixture-note.md")
  (locked-fixture-path "/tmp/note-editor/fixtures/locked.md")
  ;; scenarios/05,06,07,09,18 — the scratch directory + the prefilled
  ;; untitled.md landing there
  (work-dir "/tmp/note-editor/work")
  (work-file "/tmp/note-editor/work/untitled.md")
  ;; scenario/17 — a SIP-protected directory the save write must fail in
  (unwritable-dir "/System"))
