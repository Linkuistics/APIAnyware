#lang racket/base
;; test-ffi2-seam.rkt — the ffi2 seam round-trips across the ObjC boundary.
;;
;; The leaf's load-bearing claim is that a value can cross between the ffi2
;; C-function layer and the retained `ffi/unsafe/objc` dispatch layer and back,
;; intact. We mint a real ObjC object (an NSString) on the *retained* layer
;; itself — `import-class` + `tell`, exactly the boundary the seam bridges —
;; then push it through `id->ffi2-ptr` (cpointer -> ffi2 ptr_t) and
;; `ffi2-ptr->id` (ptr_t -> _id-tagged cpointer), proving (a) pointer identity
;; survives and (b) the round-tripped object still answers ObjC messages via
;; `tell` — i.e. it really crossed the boundary, not merely a bit-pattern.
;;
;; Minting via `import-class`/`tell` (not the Swift helper dylib) keeps the test
;; self-contained on the always-present ObjC runtime and tests precisely the
;; ffi2 <-> ffi/unsafe/objc seam this leaf builds.
;;
;; `->` discipline: this module mixes ffi2 (the seam) with ffi/unsafe's `tell`
;; oracle, so it drops ffi/unsafe's `->` via `except-in` (the seam already keeps
;; ffi2's). It uses `#:type _uint64` on `tell`, no `_fun`, so no `->` is needed.

(require rackunit
         rackunit/text-ui
         ffi2
         (except-in ffi/unsafe ->)
         ffi/unsafe/objc
         "../runtime/ffi2-seam.rkt")

(import-class NSString)

;; Mint an autoreleased NSString on the retained ObjC layer.
(define (make-nsstring str)
  (tell NSString stringWithUTF8String: #:type _string str))

(define ffi2-seam-tests
  (test-suite
   "ffi2 seam — ptr_t<->cpointer across the ObjC boundary"

   (test-suite
    "Bridge round-trip"

    (test-case "cpointer -> ptr_t -> cpointer preserves pointer identity"
      (define nsstr (make-nsstring "seam"))
      (define as-ptr (id->ffi2-ptr nsstr))      ; ffi/unsafe cpointer -> ffi2 ptr_t
      (check-pred ptr_t? as-ptr "id->ffi2-ptr should yield a ffi2 ptr_t")
      (define back (ffi2-ptr->id as-ptr))        ; ffi2 ptr_t -> _id-tagged cpointer
      (check-pred cpointer? back "ffi2-ptr->id should yield a cpointer")
      (check-true (ptr-equal? nsstr back)
                  "Round-trip through the ffi2 seam must preserve identity"))

    (test-case "round-tripped object still answers ObjC messages via tell"
      ;; The real test of "across the ObjC boundary": after crossing into ffi2
      ;; ptr_t land and back, the object must still dispatch as an NSString.
      (define nsstr (make-nsstring "hello"))
      (define back (ffi2-ptr->id (id->ffi2-ptr nsstr)))
      (define len (tell #:type _uint64 back length))
      (check-equal? len 5 "length of round-tripped NSString should be 5"))

    (test-case "raw ffi2 bridge (no _id tag) also round-trips identity"
      (define nsstr (make-nsstring "raw"))
      (define back (ptr_t->cpointer (cpointer->ptr_t nsstr)))
      (check-true (ptr-equal? nsstr back)
                  "Raw cpointer<->ptr_t bridge must preserve identity")))

   (test-suite
    "Base types and sizes (ffi2-sizeof — closes the 020 ctype-sizeof gap)"

    (test-case "arm64 width aliases have the expected sizes"
      (check-equal? (ffi2-sizeof NSInteger_t) 8 "NSInteger is 64-bit on arm64")
      (check-equal? (ffi2-sizeof NSUInteger_t) 8 "NSUInteger is 64-bit on arm64")
      (check-equal? (ffi2-sizeof CGFloat_t) 8 "CGFloat is a double on arm64")
      (check-equal? (ffi2-sizeof ptr_t) 8 "pointer is 64-bit on arm64"))

    (test-case "define-ffi2-definer binds a C function through the seam"
      ;; Proves the definer + arrow type + base types compose via the seam's
      ;; re-export (the shape emit_functions.rs will generate in leaf 050).
      (define-ffi2-definer define-libc #:lib (ffi2-lib "libSystem"))
      (define-libc strlen (-> string_t size_t))
      (check-equal? (strlen "hello") 5 "strlen via ffi2 definer should be 5")))

   (test-suite
    "struct_t geometry crossing (define-ffi2-type)"

    (test-case "a struct_t type allocates and reports its size"
      ;; The ffi2 counterpart of type-mapping.rkt's `(define-cstruct _NSPoint …)`.
      ;; Geometry structs move to struct_t in the emitter cutover (leaf 050);
      ;; here we only prove the seam's `struct_t`/`ffi2-malloc`/`ffi2-sizeof`
      ;; primitives compose.
      (define-ffi2-type NSPoint_t (struct_t [x double_t] [y double_t]))
      (check-equal? (ffi2-sizeof NSPoint_t) 16 "NSPoint is two doubles")
      (define pt (ffi2-malloc NSPoint_t))
      (check-pred ptr_t? pt "ffi2-malloc should yield a ffi2 pointer")))))

(run-tests ffi2-seam-tests)
