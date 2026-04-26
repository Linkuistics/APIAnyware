#lang app-spec

;; F18 is the 'global leader (spec/config/test-config.scm); the impl emits
;; [modal] enter tree="global" on press, and [modal] exit reason=user when
;; Escape is pressed while the modal is active.
;;
;; Values emitted by lib/events.rkt: strings are double-quoted, so match
;; tree="global" — not tree=global. reason is a symbol ('user) so it's bare.
;;
;; wait-for-log (not expect-log) because press returns before CGEvent-tap →
;; state-machine → log flush → tailer poll completes. Timeout matches the
;; style used by spec/scenarios/lifecycle/02-shutdown-menu.rkt.

(scenario "modal-leader-enter-then-escape-exit"
  #:description "F18 enters modal (tree=global); Escape exits with reason=user"
  (press 'F18)
  (wait-for-log #px"\\[modal\\] enter tree=\"global\"" #:timeout 5.0)
  (press 'Escape)
  (wait-for-log #px"\\[modal\\] exit reason=user" #:timeout 5.0))
