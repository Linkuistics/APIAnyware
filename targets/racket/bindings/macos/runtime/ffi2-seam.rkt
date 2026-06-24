#lang racket/base
;; ffi2-seam.rkt — the thin, static ffi2 seam for the C-function layer.
;;
;; This is the ffi2 counterpart to `objc-interop.rkt`. Where `objc-interop.rkt`
;; curates the *retained* `ffi/unsafe`/`ffi/unsafe/objc` surface (message
;; dispatch — the boundary ffi2 cannot cross, per the 020 research doc), this
;; module owns the *ffi2* side: framework C exports, CoreFoundation functions,
;; C structs, and the typed entry points into the generated native dispatch
;; library (leaf 040). Consumers do `(require ".../runtime/ffi2-seam.rkt")` and
;; get ffi2's forms plus the `ptr_t<->cpointer` bridge, with the `->` collision
;; already resolved.
;;
;; Design refs:
;;   targets/racket/docs/design/2026-05-31-racket-native-binding-design.md §5 (ffi2 role + hybrid
;;   boundary); targets/racket/docs/research/2026-05-31-racket-9.2-ffi2-migration.md §2–§3.
;;
;; The `->` discipline (spike finding, 010): ffi2 and ffi/unsafe BOTH export
;; `->`. We keep ffi2's (it is needed for arrow types, including the *nested*
;; arrow of a callback parameter type) and drop ffi/unsafe's via
;; `(except-in ffi/unsafe ->)`. Renaming on ffi2's side instead
;; (`rename-in`) is NOT an option — it breaks ffi2's nested-arrow parser.
;; A module that needs ffi/unsafe's `_fun` as well must require it under that
;; same `except-in`, or live in a separate module.

(require ffi2
         (except-in ffi/unsafe ->)
         ffi/unsafe/objc)

;; ffi2's full surface is the intended primary FFI for the C-function layer
;; (not an escape hatch like ffi/unsafe), so we re-export it wholesale: base
;; types (`int_t`/`uint64_t`/`double_t`/`ptr_t`/`string_t`/`void_t`/…), the
;; definers (`ffi2-lib`, `define-ffi2-definer`, `define-ffi2-procedure`),
;; compound types (`define-ffi2-type`, `struct_t`, `array_t`, `union_t`),
;; memory (`ffi2-malloc`/`ffi2-free`/`ffi2-sizeof`/`ffi2-ref`/`ffi2-set!`),
;; casting (`ffi2-cast`/`ffi2-add`), callbacks (`ffi2-callback`), and the arrow
;; `->`. The seam's own additions are the arm64 width aliases and the bridge.
(provide (all-from-out ffi2)

         ;; arm64 width aliases — the ffi2 counterparts of `type-mapping.rkt`'s
         ;; `_NSInteger`/`_NSUInteger`. On macOS arm64 NSInteger is 64-bit
         ;; signed and NSUInteger 64-bit unsigned; CGFloat is a double. These
         ;; are ABI-identical re-namings (same `ffi2-sizeof`), provided so the
         ;; emitter can spell platform typedefs readably.
         NSInteger_t
         NSUInteger_t
         CGFloat_t

         ;; The seam bridge (020 §2). ffi2 and ffi/unsafe have different pointer
         ;; representations; these are the only sanctioned crossing points.
         ptr_t->cpointer    ; ffi2 ptr_t  -> ffi/unsafe cpointer  (re-exported)
         cpointer->ptr_t    ; ffi/unsafe cpointer -> ffi2 ptr_t   (re-exported)
         ffi2-ptr->id       ; ffi2 ptr_t  -> _id-tagged cpointer  (for `tell`)
         id->ffi2-ptr)      ; _id/cpointer -> ffi2 ptr_t          (for ffi2 fns)

;; --- arm64 width aliases ---
;; ffi2 types are syntax (phase-1 `#<ffi2-type>`), so these must be defined
;; through ffi2's own type machinery, not `(define NSInteger_t int64_t)`.
(define-ffi2-type NSInteger_t int64_t)
(define-ffi2-type NSUInteger_t uint64_t)
(define-ffi2-type CGFloat_t double_t)

;; --- the seam bridge ---
;;
;; `ptr_t->cpointer` / `cpointer->ptr_t` are ffi2's raw pointer-representation
;; converters. The two helpers below add the `_id`-tagging step the hybrid
;; boundary needs (research §2's "central bridging cost"): a `ptr_t` produced by
;; a ffi2 C-function carries no ObjC object tag, so before the retained
;; `ffi/unsafe/objc` dispatch layer (`tell`) will accept it as a receiver it
;; must be re-tagged as `_id`; conversely an `_id` returned by `tell` must lose
;; its tag to become a bare `ptr_t` a ffi2 function (or a generated native
;; dispatch entry — leaf 040) accepts.

;; A ffi2 ptr_t holding an ObjC object -> an `_id`-tagged cpointer for `tell`.
(define (ffi2-ptr->id p)
  (cast (ptr_t->cpointer p) _pointer _id))

;; An `_id`/cpointer from `tell` -> a bare ffi2 ptr_t for a ffi2 function or a
;; generated native dispatch entry. (Same representation change as
;; `cpointer->ptr_t`; named for the boundary direction and intent.)
(define (id->ffi2-ptr obj)
  (cpointer->ptr_t obj))
