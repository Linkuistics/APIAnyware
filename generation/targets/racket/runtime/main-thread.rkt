#lang racket/base
;; main-thread.rkt — Dispatch thunks to the macOS main thread via GCD
;;
;; When an app enters the Cocoa run loop via nsapplication-run, the main
;; Racket place thread is blocked in a C call. Racket CS's green thread
;; scheduler cannot advance — (thread ...), (sleep ...), (sync ...) are
;; all dead. This module provides run-loop-integrated dispatch utilities.
;;
;; Uses dispatch_async_f (function-pointer variant of dispatch_async) to
;; avoid the Objective-C block ABI. Combined with pthread_main_np() for
;; main-thread detection: synchronous when already on main thread,
;; async dispatch otherwise.
;;
;; API:
;;   (on-main-thread?)                → #t if on the main OS thread
;;   (call-on-main-thread thunk)      → run thunk on main thread
;;   (call-on-main-thread-after s th) → run thunk on main thread after s seconds

(require ffi/unsafe)

(provide on-main-thread?
         call-on-main-thread
         call-on-main-thread-after)

;; ─── FFI Bindings ────────────────────────────────────────────

;; pthread_main_np() returns 1 if called on the main POSIX thread.
(define pthread_main_np
  (get-ffi-obj "pthread_main_np" (ffi-lib #f)
    (_fun -> _int)))

;; dispatch_async_f(queue, context, work) — GCD async dispatch.
;; Uses the function-pointer variant to avoid Objective-C block ABI.
(define dispatch_async_f
  (get-ffi-obj "dispatch_async_f" (ffi-lib #f)
    (_fun _pointer _pointer _fpointer -> _void)))

;; dispatch_after_f(when, queue, context, work) — GCD delayed dispatch.
;; Schedules work on queue after a delay. Uses dispatch_time_t (uint64).
(define dispatch_after_f
  (get-ffi-obj "dispatch_after_f" (ffi-lib #f)
    (_fun _uint64 _pointer _pointer _fpointer -> _void)))

;; dispatch_time(base, delta_ns) — create a dispatch_time_t.
;; DISPATCH_TIME_NOW = 0, delta is in nanoseconds.
(define dispatch_time
  (get-ffi-obj "dispatch_time" (ffi-lib #f)
    (_fun _uint64 _int64 -> _uint64)))

;; _dispatch_main_q is the GCD main queue (a global struct).
;; dispatch_get_main_queue() is a macro: (&_dispatch_main_q).
;; We need the ADDRESS of the symbol, not the value at it.
;; Use dlsym to get the symbol address directly.
(define dlsym
  (get-ffi-obj "dlsym" (ffi-lib #f)
    (_fun _pointer _string -> _pointer)))
(define RTLD_DEFAULT (cast -2 _intptr _pointer))
(define main-queue (dlsym RTLD_DEFAULT "_dispatch_main_q"))

;; ─── Thunk Registry ─────────────────────────────────────────
;; Maps integer IDs to Racket thunks. Background threads register
;; thunks here; the GCD callback retrieves and invokes them on the
;; main thread. Each ID is unique, so there's no contention between
;; the registering thread and the consuming main thread.

(define next-thunk-id 0)
(define thunk-registry (make-hash))

(define (register-thunk! thunk)
  (define id next-thunk-id)
  (set! next-thunk-id (add1 id))
  (hash-set! thunk-registry id thunk)
  id)

;; ─── GCD Callback ───────────────────────────────────────────
;; Created at module level for GC stability — the function-ptr and
;; the proc it wraps must both be module-level to prevent collection.

(define _dispatch_function_t
  (_cprocedure (list _pointer) _void))

(define dispatch-callback-proc
  (lambda (context)
    (define id (cast context _pointer _intptr))
    (define thunk (hash-ref thunk-registry id #f))
    (when thunk
      (hash-remove! thunk-registry id)
      (with-handlers ([exn:fail?
                       (lambda (e)
                         (displayln
                          (format "main-thread dispatch error: ~a"
                                  (exn-message e))))])
        (thunk)))))

(define dispatch-callback-fptr
  (function-ptr dispatch-callback-proc _dispatch_function_t))

;; ─── Public API ─────────────────────────────────────────────

;; (on-main-thread?) → boolean
;; Returns #t if executing on the main OS thread.
(define (on-main-thread?)
  (= 1 (pthread_main_np)))

;; (call-on-main-thread thunk) → void
;; If already on the main thread, calls thunk directly (synchronous).
;; Otherwise, dispatches thunk to the GCD main queue (asynchronous —
;; fires on the next Cocoa run loop iteration).
(define (call-on-main-thread thunk)
  (if (on-main-thread?)
      (thunk)
      (let ([id (register-thunk! thunk)])
        (dispatch_async_f main-queue
                          (cast id _intptr _pointer)
                          dispatch-callback-fptr))))

;; (call-on-main-thread-after seconds thunk) → void
;; Dispatches thunk to the main thread after a delay (in seconds).
;; Uses GCD dispatch_after_f — integrated with the Cocoa run loop,
;; does NOT depend on Racket's green thread scheduler.
(define (call-on-main-thread-after seconds thunk)
  (define id (register-thunk! thunk))
  (define delay-ns (inexact->exact (round (* seconds 1e9))))
  (define when-time (dispatch_time 0 delay-ns))
  (dispatch_after_f when-time
                    main-queue
                    (cast id _intptr _pointer)
                    dispatch-callback-fptr))
