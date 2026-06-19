;; runtime/async-bridge.sls — chez-side driver for async method trampolines
;; (D5/R4; ADR-0030 addendum, ported from racket's async-bridge.rkt under ADR-0011
;; hermetic isolation; ADR-0015 Scheme-side marshalling).
;;
;; A Swift-native `async` method cannot return a value across the C ABI. The
;; generated `@_cdecl` (emit-chez `trampoline.rs`) takes a trailing completion
;; context + C callback and drives `awChezAsyncDispatch` (AsyncBridge.swift): it
;; kicks a `Task`, marshals the result on the cooperative pool, and invokes the C
;; callback **on the main thread** (the same SIGILL/foreign-thread hazard racket
;; names — a Scheme callback entered from a non-main OS thread is unsafe; the
;; `MainActor.run` hop on the Swift side moves it back). This module is the chez
;; end of that callback.
;;
;; The surface is the **non-blocking callback form** (R4, user-confirmed): a chez
;; async binding takes a `complete` continuation and returns immediately; the
;; result is delivered to `complete` on a later main-run-loop iteration. There is
;; NO blocking await — a synchronous block would freeze the Cocoa run loop the
;; completion needs to drain. The app must already be servicing its run loop (under
;; `nsapplication-run`, or a CLI smoke that pumps) for the completion to fire.
;;
;; The registry + single module-level `foreign-callable` mirror racket's
;; `async-bridge.rkt`: registration (on the calling/main thread) and consumption
;; (on the main thread via the MainActor hop) never race, so no lock is needed, and
;; the one callback code object stays locked for the process lifetime.

(library (apianyware runtime async-bridge)
  (export aw-async-call)
  (import (chezscheme)
          (apianyware runtime ffi))

  ;; In chez a `void*` value crossing the FFI boundary is an exact integer machine
  ;; address (0 = NULL) or #f. Same NULL test the trampoline string coercer uses.
  (define (%null? p)
    (or (not p) (and (integer? p) (zero? p))))

  ;; Registry: ctx-id -> delivery thunk. Registered on the calling (main) thread;
  ;; consumed by the callback (also the main thread). Single-threaded ⇒ no lock.
  (define %async-completions (make-eqv-hashtable))
  (define %async-next-id 0)
  (define (%register-completion! deliver)
    (let ([id %async-next-id])
      (set! %async-next-id (+ id 1))
      (hashtable-set! %async-completions id deliver)
      id))

  ;; Looks up + removes the delivery thunk for `id` and runs it with the raw
  ;; value/error pointers. Fires on the MAIN thread (post `MainActor.run`).
  (define (%async-deliver id value err)
    (let ([deliver (hashtable-ref %async-completions id #f)])
      (when deliver
        (hashtable-delete! %async-completions id)
        (deliver value err))))

  ;; Release a +1-retained `NSError *` and build (do not raise) a chez condition
  ;; describing the failure — the callback form delivers errors to `complete`
  ;; rather than raising into the run loop. Richer `-localizedDescription`
  ;; extraction is the verification leaf's concern (kept dependency-free here, like
  ;; swift-trampoline.sls's `aw-raise-swift-error`).
  (define (aw-async-error err)
    (objc_release err)
    (condition (make-error)
               (make-who-condition 'swift-trampoline)
               (make-message-condition "Swift-native async call raised an NSError")))

  ;; The single GC-stable C completion callback the generated async `@_cdecl`
  ;; invokes: (ctx-id, value-ptr, error-ptr) -> void. `ctx-id` is the integer the
  ;; kicker was handed; `value-ptr` is the marshalled success rep (a boxed handle /
  ;; +1 NSString / NULL); `error-ptr` is a +1-retained `NSError *` on the throwing
  ;; path (exactly one of value/error is non-NULL). `__collect_safe` makes the entry
  ;; safe even if a collection is in flight when the main thread re-enters Scheme
  ;; (ADR-0016, same modifier the dispatch block/IMP callables use).
  (define %async-callback-code
    (foreign-callable __collect_safe
      (lambda (id value err) (%async-deliver id value err))
      (integer-64 void* void*)
      void))
  ;; R6RS library bodies require definitions before expressions; hide the
  ;; `lock-object` in a dummy `define` RHS so the code object stays GC-stable for
  ;; the process lifetime (the callback is never released — one per process).
  (define %async-callback-locked
    (begin (lock-object %async-callback-code) #t))
  (define %async-callback-entry
    (foreign-callable-entry-point %async-callback-code))

  ;; (aw-async-call kicker coerce complete) — drive an async trampoline (R4).
  ;;   kicker   : (id cb) -> void    invokes the generated `@_cdecl` with a fresh
  ;;                                 ctx id + the shared C callback entry (the
  ;;                                 generated binding threads receiver + args in
  ;;                                 front).
  ;;   coerce   : value-ptr -> any   success post-processing (`values` for a boxed
  ;;                                 handle / void, `aw-string-result` for String).
  ;;   complete : (result err) -> any  the chez continuation, invoked on the main
  ;;                                 thread: on success `err` is #f and `result` is
  ;;                                 the coerced value; on failure `result` is #f
  ;;                                 and `err` is a swift-error condition.
  ;; Returns immediately (non-blocking); `complete` fires on a later run-loop pass.
  (define (aw-async-call kicker coerce complete)
    (let ([id (%register-completion!
                (lambda (value err)
                  (if (%null? err)
                      (complete (coerce value) #f)
                      (complete #f (aw-async-error err)))))])
      (kicker id %async-callback-entry))))
