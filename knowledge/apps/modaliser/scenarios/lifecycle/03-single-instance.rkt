#lang app-spec

;; The impl's single-instance guard writes ~/.config/modaliser/.lock with
;; the owning process's pid (main.rkt:63-66). This scenario asserts the
;; lock file exists and its content remains stable across an idle window
;; — indirect evidence the guard is holding. A stronger test would spawn
;; a second invocation and verify it exits without emitting a second
;; [lifecycle] startup, but that requires a driver verb not yet exposed.

(define lock-path "/Users/admin/.config/modaliser/.lock")

(scenario "single-instance-lock-file-stable"
  #:description "Lock file is written at startup and its pid stays stable while idle"
  (wait-for-log #px"\\[lifecycle\\] startup")
  (expect-file lock-path #:exists? #t)
  (define initial-pid (read-file lock-path))
  (wait 1.5)
  (define later-pid (read-file lock-path))
  (unless (equal? initial-pid later-pid)
    (error 'single-instance
           "pid changed unexpectedly: ~a -> ~a"
           initial-pid later-pid)))
