;; runtime/objc.sls — chez target ObjC object wrapping and lifetime.
;;
;; Scaffold: record type and guardian are real (pure Scheme); FFI-touching
;; bodies are `(error ... "not yet implemented")` stubs. Real bodies land
;; in `.grove/050-chez-target/030-runtime-ffi-objc.md`.
;;
;; Implements the lifetime model from ADR-0007: every ObjC `id` becomes
;; an `objc-object` record registered with a Chez guardian; entry-point
;; bodies wrap in `(with-autorelease-pool ...)`; the guardian is drained
;; at every pool boundary to send `release` to collected pointers.
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
    define-entry-point)
  (import (chezscheme)
          (apianyware runtime ffi))

  (define-record-type objc-object
    (fields ptr))

  (define objc-guardian (make-guardian))

  (define (wrap-objc-object ptr . opts)
    (error 'wrap-objc-object "not yet implemented"))

  (define (borrow-objc-object ptr)
    (error 'borrow-objc-object "not yet implemented"))

  (define (unwrap-objc-object obj)
    (objc-object-ptr obj))

  (define (drain-objc-guardian)
    (let loop ()
      (let ([o (objc-guardian)])
        (when o
          ;; real impl: (objc_release (objc-object-ptr o))
          (loop)))))

  (define-syntax with-autorelease-pool
    (syntax-rules ()
      [(_ body0 body ...)
       ;; real impl: push pool, run body, pop pool, drain guardian.
       (let () body0 body ...)]))

  (define-syntax define-entry-point
    (syntax-rules ()
      [(_ (name arg ...) body0 body ...)
       (define (name arg ...)
         (with-autorelease-pool body0 body ...))])))
