;; runtime/dispatch.sls — chez target block / delegate / dynamic-subclass.
;;
;; Scaffold: record types are real; FFI-touching bodies are
;; `(error ... "not yet implemented")` stubs. Real bodies land in
;; `.grove/050-chez-target/040-runtime-dispatch.md`.
;;
;; Eventually holds:
;;   - block machinery: Block_layout / Block_descriptor_1 ftypes,
;;     `make-objc-block` wrapping a Scheme proc via `foreign-callable`.
;;     The Swift side (`aw_chez_create_block` in libAPIAnywareChez)
;;     handles _NSConcreteGlobalBlock, BLOCK_HAS_COPY_DISPOSE, and
;;     arm64e PAC signing — chez only supplies the invoke pointer.
;;   - delegate machinery: `make-delegate` constructs an instance of a
;;     Swift-defined APIAnywareChezDelegate class with per-call
;;     selector→foreign-callable mappings.
;;   - dynamic-class machinery: `make-dynamic-subclass` wraps the
;;     libobjc surface from (apianyware runtime ffi), using
;;     `foreign-callable` for IMPs.
;;
;; Absorbs from the racket runtime: block.rkt, delegate.rkt,
;; dynamic-class.rkt (forced rewrite per ADR-0007, decision 6).

(library (apianyware runtime dispatch)
  (export
    make-objc-block objc-block? objc-block-ptr
    free-objc-block
    make-delegate delegate? delegate-ptr
    free-delegate
    make-dynamic-subclass)
  (import (chezscheme)
          (apianyware runtime ffi)
          (apianyware runtime objc))

  (define-record-type (objc-block %make-objc-block objc-block?)
    (fields ptr))

  (define-record-type (delegate %make-delegate delegate?)
    (fields ptr))

  (define (make-objc-block proc signature)
    (error 'make-objc-block "not yet implemented"))

  (define (free-objc-block blk)
    (error 'free-objc-block "not yet implemented"))

  (define (make-delegate selector-map)
    (error 'make-delegate "not yet implemented"))

  (define (free-delegate d)
    (error 'free-delegate "not yet implemented"))

  (define (make-dynamic-subclass parent-class name impl-map)
    (error 'make-dynamic-subclass "not yet implemented")))
