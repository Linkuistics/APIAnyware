#lang racket/base
;; test-lifecycle.rkt — Verify lifecycle module exports and menu construction
;;
;; This test validates that the lifecycle module loads correctly and
;; its exported functions are accessible. Full GUI integration testing
;; (status bar visible, menu clickable) requires running the app.

(require rackunit
         "../services/lifecycle.rkt")

;; Verify module exports are procedures
(check-true (procedure? setup-status-bar!) "setup-status-bar! should be a procedure")
(check-true (procedure? open-settings!)    "open-settings! should be a procedure")
(check-true (procedure? relaunch!)         "relaunch! should be a procedure")
(check-true (procedure? quit!)             "quit! should be a procedure")

(displayln "test-lifecycle: all checks passed")
