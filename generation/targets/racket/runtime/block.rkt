#lang racket/base
;; block.rkt — Create ObjC blocks from Racket lambdas
;;
;; When libAPIAnywareRacket.dylib is available, uses aw_racket_create_block
;; for correct block struct construction (arm64e PAC, _NSConcreteGlobalBlock,
;; BLOCK_HAS_COPY_DISPOSE flag with copy/dispose helpers).
;;
;; With the dylib, blocks passed to async ObjC APIs are auto-managed:
;;   - Block_copy increments an internal refcount
;;   - Block_release decrements it; when it hits 0, GC prevention is released
;;   - No explicit free-objc-block needed for async APIs
;;
;; For synchronous-only APIs (enumeration, sorting), ObjC does NOT call
;; Block_copy, so auto-dispose does not fire. Call free-objc-block explicitly.
;;
;; Falls back to pure-Racket block ABI construction when the dylib is absent.

(require ffi/unsafe
         "swift-helpers.rkt")

(provide make-objc-block
         free-objc-block
         call-with-objc-block)

;; --- GC prevention ---
;; Store references to prevent GC of the C function pointer and block struct.
;; Keys are integer IDs returned to the caller.

(define active-blocks (make-hash))
(define next-id 0)

;; --- Pure-Racket block ABI (fallback) ---

(define-cstruct _BlockDescriptor
  ([reserved _uint64]
   [size _uint64]))

(define-cstruct _BlockLiteral
  ([isa _pointer]
   [flags _int32]
   [reserved _int32]
   [invoke _fpointer]
   [descriptor _pointer]))

(define _NSConcreteStackBlock
  (get-ffi-obj "_NSConcreteStackBlock" #f _pointer))

(define shared-descriptor
  (make-BlockDescriptor 0 (ctype-sizeof _BlockLiteral)))

;; --- Public API ---

;; Create an ObjC block from a Racket procedure.
;;
;; proc:         Racket procedure (arity must match param-types)
;; param-types:  list of FFI ctypes for the block's parameters
;; return-type:  FFI ctype for the block's return value
;;
;; Returns two values: (values block-pointer block-id)
;;   block-pointer: cpointer to pass to ObjC methods expecting a block
;;   block-id:      integer handle — pass to free-objc-block when done
;;
;; With the Swift dylib, blocks use _NSConcreteGlobalBlock and
;; BLOCK_HAS_COPY_DISPOSE. For async APIs (completion handlers, etc.),
;; the block is auto-managed via copy/dispose helpers. For synchronous
;; APIs (enumerateObjectsUsingBlock:, etc.), call free-objc-block after.
(define (make-objc-block proc param-types return-type)
  ;; nil proc → NULL block pointer (ObjC nil — "no callback")
  (if (not proc)
      (values #f #f)
      (let ()
        ;; The block invoke signature: (block_ptr, param1, param2, ...) -> return
        (define all-param-types (cons _pointer param-types))

        ;; Wrapper that skips the block-self pointer
        (define wrapper-proc
          (lambda args (apply proc (cdr args))))

        ;; Create C function pointer from Racket procedure
        (define invoke-ctype (_cprocedure all-param-types return-type))
        (define callback (function-ptr wrapper-proc invoke-ctype))

        ;; Create the block struct
        (define block
          (if swift-available?
              ;; Swift helper: _NSConcreteGlobalBlock + BLOCK_HAS_COPY_DISPOSE
              (swift:create-block callback)
              ;; Pure Racket fallback: manual block ABI construction
              (make-BlockLiteral _NSConcreteStackBlock
                                 0         ; flags
                                 0         ; reserved
                                 callback
                                 shared-descriptor)))

        ;; Store references to prevent GC
        (define id next-id)
        (set! next-id (add1 next-id))

        ;; Note: with Swift dylib, create-block calls prevent_gc internally.
        ;; We still store the Racket-side reference to prevent Racket GC.
        (hash-set! active-blocks id (list callback block proc))

        (values block id))))

;; Release a block's GC-preventing references.
;;
;; For synchronous-only APIs where ObjC does NOT call Block_copy,
;; this must be called explicitly after the method returns.
;;
;; For async APIs, this is optional — the dispose helper auto-frees
;; the GC prevention handle when Block_release fires. But calling
;; free-objc-block explicitly is harmless (it just releases the
;; Racket-side reference earlier).
(define (free-objc-block block-id)
  (define entry (hash-ref active-blocks block-id #f))
  (when entry
    (when swift-available?
      (define block (cadr entry))
      (swift:release-block block))
    (hash-remove! active-blocks block-id)))

;; Convenience: create a block, call body with it, keep it alive.
;; Returns (values result block-id) so the caller can free when safe.
(define (call-with-objc-block proc param-types return-type body)
  (define-values (block-ptr block-id)
    (make-objc-block proc param-types return-type))
  (values (body block-ptr) block-id))
