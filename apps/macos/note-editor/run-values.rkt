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
;; ── PROVISIONAL (forward-gen-suite-k129, 2026-07-03) ──
;; Every coordinate below is SPEC-DERIVED, not yet live-measured — the
;; k120 projection method (window frame + [NSWindow center] bias +
;; stack-arrangement sizing, validated within control bounds by the
;; mini-browser live-run k121): spec §4 fixes a 900x600 content rect,
;; centred on the 1920x1080 VM screen with the mini-browser-measured
;; 32px title bar and y-top 115 → window (510,115) 900x632, content-top
;; fb y 147; §5.1 fixes the toolbar stack (12,556,876,32) with 8px
;; spacing and rounded 26px-metric buttons (widths estimated at
;; 32 + 6/char from the k121-measured Reload/Go); §5.2/§5.3 put the
;; editor pane at content x 12–450. fb_x = 510 + cx;
;; fb_y = 147 + (600 − cy). The live-run stage re-measures every value
;; from `agent snapshot --mode layout` per impl (two-launch determinism
;; diff first) and adds per-impl `run-values-<impl>.rkt` siblings where
;; layouts diverge (precedent: racket alone on the compact-22px metrics
;; in both pdfkit and mini-browser — expect the same split, but measure).
;; The ALERT coordinates are the weakest projection (NSAlert centres on
;; screen, size platform-styled): measure them from the OPEN alert at
;; live-run (the scenekit open-menu precedent).
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
  ;; toolbar buttons, centre-line fb y 175 (stack top strip, 26px
  ;; controls); x from the §5.1 arrangement order New·Open…·Save…·Undo·Redo
  (new-button-x 547)
  (new-button-y 175)
  (open-button-x 611)
  (open-button-y 175)
  (save-button-x 681)
  (save-button-y 175)
  (undo-button-x 748)
  (undo-button-y 175)
  (redo-button-x 812)
  (redo-button-y 175)
  ;; scenarios/10,12 — the §8.1 alert's Cancel button centre. WEAKEST
  ;; projection (screen-centred NSAlert, two side-by-side bottom buttons,
  ;; Discard rightmost/default, Cancel to its left) — MEASURE AT LIVE-RUN
  ;; from the open alert before trusting.
  (alert-cancel-x 905)
  (alert-cancel-y 480)
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
