#lang racket/base
;; async-bridge.rkt — the racket-side driver for async method trampolines
;; (R4; targets/racket/docs/design/2026-06-15-racket-trampoline.md §method-async, ADR-0030).
;;
;; An `async` Swift-native method cannot return a value across the C ABI. The
;; generated `@_cdecl` (emit-racket `trampoline.rs`) takes a trailing completion
;; context + C callback and drives `awRacketAsyncDispatch` (AsyncBridge.swift): it
;; kicks a `Task`, marshals the result on the cooperative pool, and invokes the C
;; callback **on the main thread** (the SIGILL-safe hop — a Racket CS `_cprocedure`
;; SIGILLs if invoked from a foreign thread). This module is the racket end of that
;; callback.
;;
;; The surface is the **non-blocking callback form** (R4, user-confirmed): a racket
;; async binding takes a `complete` continuation and returns immediately; the result
;; is delivered to `complete` on a later main-run-loop iteration. There is NO
;; blocking await — a synchronous block would freeze the Cocoa run loop the
;; completion needs to drain (a mailbox/await layer can be built on top later). The
;; app must already be servicing its run loop (under `nsapplication-run`, or a CLI
;; smoke that pumps) for the completion to fire.
;;
;; The registry + single module-level `_cprocedure` mirror `main-thread.rkt`'s
;; thunk registry: registration (on the calling/main thread) and consumption (on the
;; main thread via the MainActor hop) never race, so no lock is needed, and the one
;; callback proc stays GC-stable for the process lifetime.

(require ffi/unsafe
         "swift-helpers.rkt") ; swift:release

(provide aw-async-call)

;; The C completion callback ctype the generated async `@_cdecl` invokes:
;;   (ctx-id, value-ptr, error-ptr) -> void
;; `ctx-id` is the intptr the kicker was handed; `value-ptr` is the marshalled
;; success rep (a boxed handle / +1 NSString / NULL); `error-ptr` is a +1-retained
;; `NSError *` on the throwing path (exactly one of value/error is non-NULL). Used
;; only to build the one stable callback fptr below; the generated binding passes
;; that fptr through an `_fpointer` param (not this ctype), so it is not exported.
(define _aw-async-callback
  (_cprocedure (list _intptr _pointer _pointer) _void))

;; Registry: ctx-id -> delivery thunk. Registered on the calling (main) thread;
;; consumed by the callback (also the main thread). Single-threaded ⇒ no lock.
(define async-completions (make-hasheqv))
(define next-async-id 0)
(define (register-completion! deliver)
  (define id next-async-id)
  (set! next-async-id (add1 id))
  (hash-set! async-completions id deliver)
  id)

;; Release a +1-retained `NSError *` and build (do not raise) a racket exception
;; describing the failure — the callback form delivers errors to `complete` rather
;; than raising into the run loop. Richer `-localizedDescription` extraction is the
;; verification leaf's concern (kept dependency-free here, like
;; swift-trampoline.rkt's `aw-raise-swift-error`).
(define (aw-async-error err)
  (swift:release err)
  (make-exn:fail "Swift-native async call raised an NSError"
                 (current-continuation-marks)))

;; The single GC-stable callback. Looks up + removes the delivery thunk for `id`
;; and runs it with the raw value/error pointers. Fires on the MAIN thread.
(define async-callback-proc
  (lambda (id value err)
    (define deliver (hash-ref async-completions id #f))
    (when deliver
      (hash-remove! async-completions id)
      (deliver value err))))
(define async-callback-fptr
  (function-ptr async-callback-proc _aw-async-callback))

;; (aw-async-call kicker coerce complete) — drive an async trampoline (R4).
;;   kicker   : (id cb-fptr) -> void   invokes the generated `@_cdecl` with a fresh
;;                                     ctx id + the shared C callback (the generated
;;                                     binding threads receiver + args in front).
;;   coerce   : value-ptr -> any       success post-processing (`values` for a boxed
;;                                     handle / void, `aw-string-result` for String).
;;   complete : (result err) -> any    the racket continuation, invoked on the main
;;                                     thread: on success `err` is #f and `result` is
;;                                     the coerced value; on failure `result` is #f
;;                                     and `err` is a swift-error exn.
;; Returns immediately (non-blocking); `complete` fires on a later run-loop pass.
(define (aw-async-call kicker coerce complete)
  (define id
    (register-completion!
     (lambda (value err)
       (if err
           (complete #f (aw-async-error err))
           (complete (coerce value) #f)))))
  (kicker id async-callback-fptr))
