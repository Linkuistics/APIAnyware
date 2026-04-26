#lang app-spec

;; core/state-machine.rkt defines modal-safety-timeout=5 seconds. On
;; modal-enter the watchdog captures the current overlay generation and
;; schedules an after-delay callback; the callback fires modal-exit with
;; reason='watchdog if the generation is still valid (i.e. no further
;; overlay-show or modal-exit has bumped it). With no user input after F18,
;; nothing advances the generation, so the watchdog fires deterministically.
;;
;; Wait 6s to cover the 5s watchdog plus flush/tailer latency; wait-for-log
;; adds a further 5s polling window as a final safety margin.

(scenario "modal-watchdog-closes-stuck-overlay"
  #:description "5s no-input watchdog emits [modal] exit reason=watchdog"
  (press 'F18)
  (wait-for-log #px"\\[modal\\] enter tree=\"global\"" #:timeout 5.0)
  (wait 6.0)
  (wait-for-log #px"\\[modal\\] exit reason=watchdog" #:timeout 5.0))
