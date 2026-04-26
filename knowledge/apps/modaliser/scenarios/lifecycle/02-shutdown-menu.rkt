#lang app-spec

;; kill-impl! is the driver's graceful-quit path (osascript "quit app")
;; which routes through applicationWillTerminate: — the only deterministic
;; way to hit the `reason=menu` shutdown branch in main.rkt.

(scenario "lifecycle-shutdown-via-menu-quit"
  #:description "Graceful quit emits [lifecycle] shutdown reason=menu"
  (wait-for-log #px"\\[lifecycle\\] startup")
  (kill-impl!)
  (wait-for-log #px"\\[lifecycle\\] shutdown reason=menu" #:timeout 5.0))
