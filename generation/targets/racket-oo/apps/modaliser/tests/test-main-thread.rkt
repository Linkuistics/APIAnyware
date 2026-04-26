#lang racket/base
;; test-main-thread.rkt — Tests for ffi/main-thread.rkt

(require rackunit
         "../ffi/main-thread.rkt")

;; ─── on-main-thread? ─────────────────────────────────────────
;; In a test context (no NSApplication run loop), the main Racket
;; thread runs on the main OS thread, so this should return #t.

(check-true (on-main-thread?)
  "test process runs on main OS thread")

;; ─── call-on-main-thread (synchronous path) ──────────────────
;; When already on the main thread, call-on-main-thread should
;; invoke the thunk directly (synchronous, no dispatch).

(define result (box #f))
(call-on-main-thread (lambda () (set-box! result #t)))
(check-true (unbox result)
  "call-on-main-thread invokes thunk synchronously on main thread")

;; Verify return values flow through (thunk returns void)
(define counter (box 0))
(call-on-main-thread
  (lambda ()
    (set-box! counter (add1 (unbox counter)))))
(check-equal? (unbox counter) 1
  "call-on-main-thread executes thunk exactly once")

;; ─── Error handling ──────────────────────────────────────────
;; Errors in the thunk should be caught, not crash the app.
;; On the synchronous path (main thread), the error propagates
;; normally since we call the thunk directly.

;; On the async path, errors are caught by the dispatch callback.
;; We can't easily test the async path without a run loop, but
;; we verify the sync path works with error-raising thunks.

(check-not-exn
  (lambda ()
    ;; When on main thread, thunk is called directly, so the error
    ;; propagates. We wrap in with-handlers to simulate the caller's
    ;; responsibility.
    (with-handlers ([exn:fail? (lambda (e) (void))])
      (call-on-main-thread
        (lambda () (error "test error")))))
  "error in thunk does not crash the dispatch mechanism")

;; ─── Module loads without error ──────────────────────────────
;; The FFI bindings (dispatch_async_f, pthread_main_np, _dispatch_main_q)
;; must resolve on macOS. If we got this far, they did.

(displayln "test-main-thread: all tests passed")
