;;; runtime/async-bridge.ss — gerbil-side driver for async method trampolines
;;; (D5/R4; ADR-0030 addendum, ported from chez's async-bridge.sls / racket's
;;; async-bridge.rkt under ADR-0011 hermetic isolation; ADR-0015 Scheme-side
;;; marshalling). gerbil's free-function async bucket was empty (ADR-0029 §5), so
;;; the method frontier is the FIRST gerbil async path.
;;;
;;; A Swift-native `async` method cannot return a value across the C ABI. The
;;; generated `@_cdecl` (emit-gerbil `trampoline.rs`) takes a trailing completion
;;; context + C callback and drives `awGerbilAsyncDispatch` (AsyncBridge.swift): it
;;; kicks a `Task`, marshals the result on the cooperative pool, and invokes the C
;;; callback **on the main thread** (the `MainActor.run` hop on the Swift side). That
;;; is the same hazard the native core's main-thread bounce (ADR-0022) guards: a
;;; Scheme re-entry from a non-main OS thread corrupts the single Gambit VM. Because
;;; Swift already delivers on the main thread, this callback is entered on the main
;;; thread directly — exactly like the native-core IMP *inner* dispatchers (no extra
;;; outer-trampoline bounce needed here).
;;;
;;; The surface is the **non-blocking callback form** (R4, user-confirmed): a gerbil
;;; async binding takes a `complete` continuation and returns immediately; the result
;;; is delivered to `complete` on a later main-run-loop iteration. There is NO
;;; blocking await — a synchronous block would freeze the Cocoa run loop the
;;; completion needs to drain. The app must already be servicing its run loop (under
;;; `nsapplication-run`, or a CLI smoke that pumps) for the completion to fire.
;;;
;;; The registry + single `c-define` callback mirror chez's `async-bridge.sls`:
;;; registration (on the calling/main thread) and consumption (on the main thread via
;;; the MainActor hop) never race, so no lock is needed, and the one C entry stays
;;; valid for the process lifetime.

(import :std/foreign
        :gerbil-bindings/runtime/ffi)
(export aw-async-call)

;; Registry: ctx-id -> delivery thunk. Registered on the calling (main) thread;
;; consumed by the callback (also the main thread). Single-threaded ⇒ no lock.
(def *async-completions* (make-hash-table))
(def *async-next-id* 0)
(def (register-completion! deliver)
  (let (id *async-next-id*)
    (set! *async-next-id* (##fx+ id 1))
    (hash-put! *async-completions* id deliver)
    id))

;; Looks up + removes the delivery thunk for `id` and runs it with the raw
;; value/error pointers. Fires on the MAIN thread (post `MainActor.run`). Reached
;; from the `c-define` body below by its fully-qualified mangled name (the c-define
;; compiles in the raw Gambit namespace — same constraint native-core.ss documents).
(def (aw-async-deliver id value err)
  (let (deliver (hash-get *async-completions* id))
    (when deliver
      (hash-remove! *async-completions* id)
      (deliver value err))))

;; Release a +1-retained `NSError *` and BUILD (do not raise) an error object
;; describing the failure — the callback form delivers errors to `complete` rather
;; than raising into the run loop. `with-catch` captures the raised error as a value.
;; Richer `-localizedDescription` extraction is the verification leaf's concern (kept
;; dependency-free here, like swift-trampoline.ss's `aw-swift-call/error`).
(def (aw-async-error err)
  (objc-release err)
  (with-catch (lambda (e) e)
    (lambda () (error "Swift-native async call raised an NSError"))))

;; The single C completion callback the generated async `@_cdecl` invokes:
;; (ctx-id, value-ptr, error-ptr) -> void. `ctx-id` is the int64 the kicker was
;; handed (Swift `Int`); `value-ptr` is the marshalled success rep (a boxed handle /
;; wrapped id / +1 NSString / NULL); `error-ptr` is a +1-retained `NSError *` on the
;; throwing path (exactly one of value/error is non-NULL). The body re-enters Scheme
;; by the fully-qualified name; `aw-async-callback-entry` exposes its address (same
;; translation unit, so the C symbol is in scope) as the pointer the trampoline takes.
(begin-ffi (aw-async-callback-entry)
  (c-define (async-cb id value err)
            (int64 (pointer void) (pointer void)) void
            "aw_async_cb" ""
    (gerbil-bindings/runtime/async-bridge#aw-async-deliver id value err))
  (define-c-lambda aw-async-callback-entry () (pointer void)
    "___return((void*)aw_async_cb);"))

;; The GC-stable C callback address, resolved once at module load (the `c-define`d
;; function lives for the process lifetime — one per process).
(def *async-callback-entry* (aw-async-callback-entry))

;; (aw-async-call kicker coerce complete) — drive an async trampoline (R4).
;;   kicker   : (id cb) -> void    invokes the generated `@_cdecl` with a fresh ctx
;;                                 id + the shared C callback entry (the generated
;;                                 binding threads receiver + args in front).
;;   coerce   : value-ptr -> any   success post-processing (`values` for a boxed
;;                                 handle / void, `aw-swift-string-result` for String,
;;                                 a `(lambda (p) (wrap p #t))` thunk for an object).
;;   complete : (result err) -> any  the gerbil continuation, invoked on the main
;;                                 thread: on success `err` is #f and `result` is the
;;                                 coerced value; on failure `result` is #f and `err`
;;                                 is the captured swift-error object.
;; Returns immediately (non-blocking); `complete` fires on a later run-loop pass.
(def (aw-async-call kicker coerce complete)
  (let (id (register-completion!
             (lambda (value err)
               (if (ptr-null? err)
                 (complete (coerce value) #f)
                 (complete #f (aw-async-error err))))))
    (kicker id *async-callback-entry*)))
