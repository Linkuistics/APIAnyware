#lang app-spec/run-values

;; Per-app run-values config for Note Editor (ADR-0011, the per-app
;; run-value source schema). Carries the *app-level* values the scenarios
;; read: window/toolbar/editor click coordinates and the in-VM
;; fixture/scratch paths; the per-*impl* value (bundle-id) lives in each
;; `#lang app-spec/impl` descriptor
;; (../../../targets/<t>/app-implementations/macos/note-editor/
;; note-editor-impl.rkt); the runner merges the two into the single
;; `current-run-values` table that `(run-value 'key)` reads
;; (runner/main.rkt; the descriptor wins on any key clash).
;;
;; This config holds *app data* and lives downstream in APIAnyware, never
;; in the AppSpec toolkit (ADR-0052). It is consumed by `runner/main.rkt
;; --run-values <this file>` and is deliberately NOT placed under
;; scenarios/ — the runner discovers every .rkt there as a scenario
;; (runner/dispatch.rkt).
;;
;; ── LIVE-MEASURED (live-run-k130, 2026-07-03) ──
;; Coordinates below are AX element centres (framebuffer px) measured
;; from `agent snapshot --window "Untitled — Note Editor" --mode layout`
;; on the 1920x1080 VM, two-launch determinism diff green on every impl.
;; chez + gerbil + sbcl are PIXEL-IDENTICAL (window (510,115) 900x632,
;; 26px control metrics, toolbar centre-line fb y 171) and share this
;; table; racket alone diverges on its compact 22px metrics (window
;; 900x628, centre-line y 166) — pass run-values-racket.rkt for the
;; racket impl (the pdfkit/mini-browser share-set precedent). The ALERT
;; coordinates were measured from the OPEN alert (the scenekit open-menu
;; precedent) and are LAYOUT-INDEPENDENT: the screen-centred NSAlert has
;; byte-identical geometry over the racket and chez window layouts
;; (dialog titled "alert", 260x234 body, Cancel [focused] left of the
;; rightmost Discard). The k129 spec-derived provisional values all
;; landed inside their control bounds (worst: Redo, 10px off-centre);
;; the k120 projection method holds for this window shape too.
;;
;; ── The persistence story (run-stage obligations; observable-state.md) ──
;; Before the runs, the run stage must prepare the guest:
;;   mkdir -p /tmp/note-editor/fixtures /tmp/note-editor/work
;;   upload  apps/macos/note-editor/fixtures/fixture-note.md  (123 chars —
;;     byte-exact: scenario 08 binds `rendered chars=123` from it)
;;   upload  apps/macos/note-editor/fixtures/locked.md, then
;;     chmod 000 /tmp/note-editor/fixtures/locked.md  (git cannot carry
;;     mode 000 — the run stage applies it in-guest; scenario 16)
;; Between scenarios (before each save-driving scenario at minimum):
;;   rm -rf /tmp/note-editor/work && mkdir -p /tmp/note-editor/work
;; — the cleanup obligation: scenario 07 asserts `expect-file
;; #:absent?` against a fresh work/, and a leftover work/untitled.md
;; would raise the save panel's replace-confirmation sheet, changing the
;; keyboard choreography scenarios 05/06/09/18 drive.
;; Panel-remembered directories need no cleanup: every panel drive goes
;; through Cmd-Shift-G with an absolute path (the k103 fixture rule).
;;
;; Log matchers deliberately bind only path BASENAMES (`[^"]*/untitled\.md`):
;; the panels canonicalize /tmp → /private/tmp in their URL paths (the
;; pdfkit basename rule), so the /tmp spellings below serve the file verbs
;; (in-guest `test -f`/`cat`, where the symlink resolves) and the typed
;; Go-to-Folder paths — never the event matchers.

(run-values
  ;; scenarios/03–07,09–12,15,17,18,20 — a point inside the
  ;; editor pane (left split half, below the single typed line — clicking
  ;; past the text end puts the insertion point at the end):
  ;; content (231,300) → fb (741,447)
  (editor-click-x 741)
  (editor-click-y 447)
  ;; toolbar buttons, centre-line fb y 171 (stack top strip, 26px
  ;; controls); §5.1 arrangement order New·Open…·Save…·Undo·Redo —
  ;; measured centres: New (521,158) 53x26, Open… (580,158) 70x26,
  ;; Save… (656,158) 66x26, Undo (728,158) 59x26, Redo (793,158) 58x26
  (new-button-x 548)
  (new-button-y 171)
  (open-button-x 615)
  (open-button-y 171)
  (save-button-x 689)
  (save-button-y 171)
  (undo-button-x 758)
  (undo-button-y 171)
  (redo-button-x 822)
  (redo-button-y 171)
  ;; scenarios/10,12 — the §8.1 alert's Cancel button centre, measured
  ;; from the OPEN alert: Cancel (845,404) 112x30 [focused], Discard
  ;; (963,404) 112x30 rightmost. Screen-centred and layout-independent
  ;; (identical over racket's and chez's window layouts).
  (alert-cancel-x 901)
  (alert-cancel-y 419)
  ;; scenario/21 — the window close control (leftmost traffic-light)
  ;; centre: window x-origin 510 + the k121-measured 8px inset,
  ;; AX (518,123) 16x16 → centre
  (close-button-x 526)
  (close-button-y 131)
  ;; scenarios/08,16 — the in-VM fixture paths (typed into Go-to-Folder;
  ;; also the read-file/expect-file arguments)
  (fixture-path "/tmp/note-editor/fixtures/fixture-note.md")
  (locked-fixture-path "/tmp/note-editor/fixtures/locked.md")
  ;; scenarios/05,06,07,09,18 — the scratch directory the save scenarios
  ;; target, and the file the sheet's prefilled `untitled.md` name lands
  ;; there
  (work-dir "/tmp/note-editor/work")
  (work-file "/tmp/note-editor/work/untitled.md")
  ;; scenario/17 — a SIP-protected directory the save write must fail in
  (unwritable-dir "/System"))
