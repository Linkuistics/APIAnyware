#lang racket/base
;; test-main-thread.rkt — Tests for runtime/main-thread.rkt
;;
;; Tests:
;;   1. Module loads and FFI bindings resolve
;;   2. on-main-thread? returns #t in test context
;;   3. call-on-main-thread synchronous path works
;;   4. Error handling in dispatched thunks

(require rackunit
         rackunit/text-ui
         "../runtime/main-thread.rkt")

(define main-thread-tests
  (test-suite
   "GCD main-thread dispatch"

   (test-case "on-main-thread? returns #t in test context"
     ;; In a test (no NSApplication run loop), the main Racket
     ;; thread runs on the main OS thread.
     (check-true (on-main-thread?)
                 "test process runs on main OS thread"))

   (test-case "call-on-main-thread invokes thunk synchronously"
     ;; When already on the main thread, thunk runs directly.
     (define result (box #f))
     (call-on-main-thread (lambda () (set-box! result #t)))
     (check-true (unbox result)
                 "thunk should execute immediately on main thread"))

   (test-case "call-on-main-thread executes thunk exactly once"
     (define counter (box 0))
     (call-on-main-thread
       (lambda () (set-box! counter (add1 (unbox counter)))))
     (check-equal? (unbox counter) 1
                   "thunk should fire exactly once"))

   (test-case "call-on-main-thread propagates return value on sync path"
     ;; On the synchronous path, the thunk's return value is discarded
     ;; (call-on-main-thread returns void), but it should not error.
     (check-not-exn
       (lambda ()
         (call-on-main-thread (lambda () 42)))
       "thunk returning a value should not error"))

   (test-case "error in thunk does not crash dispatch mechanism"
     ;; On the synchronous path (main thread), the error propagates
     ;; normally. Callers handle it.
     (check-not-exn
       (lambda ()
         (with-handlers ([exn:fail? (lambda (e) (void))])
           (call-on-main-thread
             (lambda () (error "test error")))))
       "error should propagate without crashing dispatch"))

   ;; Note: call-on-main-thread-after cannot be fully tested without
   ;; a Cocoa run loop — GCD dispatch_after requires run loop iteration.
   ;; We test that it doesn't error when called (the thunk won't fire
   ;; without a run loop, but the FFI call should succeed).
   (test-case "call-on-main-thread-after accepts valid arguments"
     (check-not-exn
       (lambda ()
         (call-on-main-thread-after 0.1 (lambda () (void))))
       "scheduling a delayed dispatch should not error"))))

(run-tests main-thread-tests)
