#lang app-spec

;; After F18 enters the global modal, pressing "f" navigates into the Find
;; group (see spec/config/test-config.scm — "f" is a (group …) node). The
;; impl emits [modal] group key="f" via core/state-machine.rkt modal-handle-key.
;;
;; `char` in log-event is a string (from keycode->char), so events.rkt quotes
;; it: key="f", not key=f.

(scenario "modal-group-navigation"
  #:description "F18 then \"f\" navigates into the Find group"
  (press 'F18)
  (wait-for-log #px"\\[modal\\] enter tree=\"global\"" #:timeout 5.0)
  (press "f")
  (wait-for-log #px"\\[modal\\] group key=\"f\"" #:timeout 5.0))
