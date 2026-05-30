#lang racket/base
;; objc-interop.rkt — Curated re-export of ObjC interop primitives.
;;
;; Lets consumer modules (apps and downstream binding consumers)
;; write `(require ".../runtime/objc-interop.rkt")` instead of pulling in
;; `ffi/unsafe` and `ffi/unsafe/objc` directly. A grep for `ffi/unsafe` in
;; consumer code then flags genuine escape-hatch usage rather than benign
;; macro/type imports.
;;
;; Add a name here only when consumer code outside `runtime/` legitimately
;; needs it — this is a curated allowlist, not a wholesale re-export.

(require ffi/unsafe
         ffi/unsafe/objc)

(provide ;; ffi/unsafe/objc — message send and runtime lookup
         tell
         import-class
         sel_registerName

         ;; ffi/unsafe — primitive C types
         _string
         _long
         _int32
         _uint64
         _bool
         _double
         _pointer
         _id
         _fpointer
         _void
         _intptr

         ;; ffi/unsafe — pointer ops
         cast
         cpointer?
         ptr-equal?

         ;; ffi/unsafe — C callback construction
         ;; Needed for IMP creation (class_addMethod) and any tell that
         ;; passes a function-pointer argument to an ObjC method.
         _cprocedure
         function-ptr)
