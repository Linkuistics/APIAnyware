#lang racket/base
;; test-source-guards.rkt — Single entry point for the dead-scheduler
;; guardrail.
;;
;; Walks every .rkt file in core/, services/, ui/, lib/, ffi/ plus the
;; top-level main.rkt and asserts no forbidden scheduler forms survive.
;; See tests/source-guards.rkt for the full list of forbidden forms
;; and the sanctioned alternatives.
;;
;; No rackunit wrapper: check-source-tree raises on any violation so a
;; failing run exits non-zero. Wrapping in test-case would only print
;; the failure while exiting 0 — that's exactly the silent-failure
;; mode this guardrail exists to prevent.

(require "source-guards.rkt")

(check-source-tree
 '("core" "services" "ui" "lib" "ffi" "main.rkt")
 ;; Per-(file, form) allowlist. Each entry exempts ONE forbidden form
 ;; in ONE file; all other forbidden forms in that file are still
 ;; flagged. Document every entry with a sentence explaining why the
 ;; exemption is safe — if the justification no longer holds, revert.
 #:allow
 '(;; place-channel-try-get wraps (sync/timeout 0 ch) as a pure
   ;; non-blocking try-receive on a place channel. Empirically
   ;; scheduler-independent: each call runs inside a brief Racket
   ;; execution window scheduled via call-on-main-thread-after, so
   ;; the blocking-wait hazard that forbids sync/timeout elsewhere
   ;; does not apply here.
   ("lib/place-channel-utils.rkt" . "sync/timeout")
   ;; main.rkt's (semaphore-wait ...) only runs under the
   ;; MODALISER_TEST_BLOCK=signal test-harness gate — never in
   ;; production flow, and the guarded branch is reached *before*
   ;; any call to nsapplication-run. The test subprocess uses
   ;; this semaphore as a parking primitive so SIGINT can
   ;; exercise the shutdown-logging handler; Racket's scheduler
   ;; is still alive at that point, so the wait is legitimate.
   ("main.rkt" . "semaphore-wait")))

(displayln "test-source-guards: runtime tree is clean")
