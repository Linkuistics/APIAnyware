;; runtime/objc.sls — chez target ObjC object wrapping and lifetime.
;;
;; Implements the lifetime model from ADR-0007: every wrapped ObjC `id`
;; becomes an `objc-object` record registered with a Chez guardian;
;; entry-point bodies wrap in `(with-autorelease-pool ...)`; the
;; guardian is drained on every pool boundary to send `release` to
;; collected pointers.
;;
;; Also defines the `nserror` record that fallible procedures return as
;; the second value (per ADR-0006 — `(values result error)`).
;;
;; Absorbs from the racket runtime: objc-base.rkt, objc-interop.rkt
;; (forced rewrite per ADR-0007).

(library (apianyware runtime objc)
  (export
    make-objc-object objc-object? objc-object-ptr
    objc-guardian
    wrap-objc-object
    borrow-objc-object
    unwrap-objc-object
    with-autorelease-pool
    drain-objc-guardian
    define-entry-point
    make-nserror nserror? nserror-domain nserror-code
    nserror-localised-description nserror-userinfo)
  (import (chezscheme)
          (apianyware runtime ffi))

  (define-record-type objc-object
    (fields ptr))

  ;; Per ADR-0006: the error half of `(values result error)`. `#f` on
  ;; success, an nserror record on failure.
  (define-record-type nserror
    (fields domain code localised-description userinfo))

  ;; One process-wide guardian collecting orphaned objc-objects. Drained
  ;; on every `with-autorelease-pool` boundary (and explicitly via
  ;; `drain-objc-guardian`); on drain each collected wrapper's pointer
  ;; is sent `objc_release`.
  (define objc-guardian (make-guardian))

  ;; Wrap a raw ObjC `id` (an address-integer from the FFI) into an
  ;; `objc-object` record and register it with the guardian.
  ;;
  ;;   (wrap-objc-object ptr)        — caller had +0 (autoreleased
  ;;                                     return); retain immediately so
  ;;                                     the pool boundary cannot drop
  ;;                                     the object before we release.
  ;;   (wrap-objc-object ptr #t)     — caller already owns +1
  ;;                                     (alloc/init/copy/new/mutableCopy);
  ;;                                     no retain.
  ;;
  ;; Either way, the eventual guardian-drain pass sends exactly one
  ;; `objc_release`, balancing the +1 and returning the object to +0.
  (define wrap-objc-object
    (case-lambda
      [(ptr) (wrap-objc-object ptr #f)]
      [(ptr retained?)
       (cond
         [(or (not ptr) (and (integer? ptr) (zero? ptr)))
          (make-objc-object 0)]
         [else
          (unless retained? (objc_retain ptr))
          (let ([obj (make-objc-object ptr)])
            (objc-guardian obj)
            obj)])]))

  ;; Borrow: wrap WITHOUT retain or guardian registration. The caller
  ;; promises the pointer is valid only for the borrow's lexical scope
  ;; (delegate callback args from the Swift trampoline, NSNotification
  ;; userInfo lookups, etc.). Storing the borrow beyond that scope is
  ;; a use-after-free waiting to happen.
  (define (borrow-objc-object ptr)
    (cond
      [(or (not ptr) (and (integer? ptr) (zero? ptr)))
       (make-objc-object 0)]
      [else (make-objc-object ptr)]))

  (define (unwrap-objc-object obj) (objc-object-ptr obj))

  ;; Drain the guardian — for each collected wrapper, send `release` to
  ;; its pointer. Called on every pool boundary; callers may invoke
  ;; explicitly for long-running loops outside the run-loop's
  ;; entry-point wrapping.
  (define (drain-objc-guardian)
    (let loop ()
      (let ([o (objc-guardian)])
        (when o
          (let ([p (objc-object-ptr o)])
            (unless (or (not p) (and (integer? p) (zero? p)))
              (objc_release p)))
          (loop)))))

  ;; (with-autorelease-pool body ...) — push an NSAutoreleasePool, run
  ;; body, pop the pool, then drain the guardian. The pool catches
  ;; transient +0 returns; the post-pool drain catches +1-owned wrappers
  ;; whose Scheme refs have been collected.
  (define-syntax with-autorelease-pool
    (syntax-rules ()
      [(_ body0 body ...)
       (let ([pool (objc_autoreleasePoolPush)])
         (call-with-values
           (lambda () body0 body ...)
           (lambda vs
             (objc_autoreleasePoolPop pool)
             (drain-objc-guardian)
             (apply values vs))))]))

  ;; (define-entry-point (name arg ...) body ...) — define `name` as
  ;; a procedure whose body is wrapped in `(with-autorelease-pool ...)`.
  ;; Use for every outer entry into Scheme-driven ObjC code: app
  ;; `main`, event handlers dispatched from NSRunLoop, foreign-callable
  ;; trampolines. The convention is named in CONTEXT.md
  ;; ("Entry-point autoreleasepool") and load-bears for ADR-0007.
  (define-syntax define-entry-point
    (syntax-rules ()
      [(_ (name arg ...) body0 body ...)
       (define (name arg ...)
         (with-autorelease-pool body0 body ...))])))
