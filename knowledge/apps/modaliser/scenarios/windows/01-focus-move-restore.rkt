#lang app-spec

;; Window verbs: launch TextEdit, center it, fullscreen, restore.
;;
;; Event shape per spec/docs/logging-contract.md: `[window] move x=<n>
;; y=<n> w=<n> h=<n>` — numeric values, emitted as inexact floats by
;; services/window-manager.rkt (e.g. x=123.0). The plan snippet's regex
;; `[0-9]+` would miss the `.0` tail; use `[0-9.]+` to match floats.
;;
;; **Impl gap (known, filed as `impl-window-move-logging-gap` in
;; LLM_STATE/core/backlog.md):** `center-window` and `restore-window`
;; in services/window-manager.rkt call ax-set-position!/ax-set-size!
;; without emitting `[window] move`, violating the logging contract
;; ("move fires on any Modaliser-initiated position/size change").
;; Only `move-window` currently emits the event. This scenario asserts
;; the contract as written, so it will fail on live-VM until the gap
;; is closed — that's the expected signal (scenario-first spec
;; development). `toggle-fullscreen` deliberately stays silent in the
;; contract too: AX fullscreen doesn't yield rectangular geometry.

(scenario "center-then-fullscreen-then-restore"
  #:description "TextEdit: center logs [window] move; fullscreen; restore logs [window] move"
  ;; Pre-state: TextEdit frontmost via quick-launch "t".
  (press 'F18)
  (press "t")
  (wait-for-log #px"\\[launch\\] bundle id=\"com\\.apple\\.TextEdit\"" #:timeout 5.0)
  (wait 1.0)
  (expect-running-app "com.apple.TextEdit")

  ;; Center — emits [window] move with the new x/y (w/h unchanged).
  (press 'F18) (press "w") (press "c")
  (wait-for-log #px"\\[window\\] move x=[0-9.]+ y=[0-9.]+ w=[0-9.]+ h=[0-9.]+"
                #:timeout 5.0)

  ;; Fullscreen — no event; give the AX animation time to settle before
  ;; the restore step so the saved frame is what we actually captured.
  (press 'F18) (press "w") (press "f")
  (wait 1.5)

  ;; Restore — emits [window] move with the pre-fullscreen saved frame.
  (press 'F18) (press "w") (press "r")
  (wait-for-log #px"\\[window\\] move x=[0-9.]+ y=[0-9.]+ w=[0-9.]+ h=[0-9.]+"
                #:timeout 5.0))
