;; runtime/ffi.sls — chez target FFI primitives.
;;
;; Holds:
;;   - mandatory load of the chez runtime dylib (per ADR-0005 / decision 7).
;;     During the chez bring-up (`.grove/050-chez-target/030`..060) the
;;     loader points at the existing `libAPIAnywareRacket.dylib` because its
;;     `aw_common_*` surface is target-agnostic. Leaf 060 builds the
;;     chez-specific dylib (`libAPIAnywareChez.dylib`) and the default
;;     candidate list flips order.
;;   - libobjc class/sel/msgSend/retain/release surface
;;   - autorelease pool primitives via the dylib's `aw_common_*` wrappers
;;   - NSString round-trip helpers used by `(apianyware runtime types)`
;;
;; Absorbs from the racket runtime: swift-helpers.rkt (full rewrite,
;; with the `swift-available?` fallback removed — chez requires the
;; dylib, fails hard otherwise).

(library (apianyware runtime ffi)
  (export
    libapianyware-chez-path
    libobjc-loaded?
    objc_getClass
    objc_msgSend
    objc_allocateClassPair
    objc_registerClassPair
    class_addMethod
    sel_registerName
    sel-register
    class_getInstanceMethod
    method_getTypeEncoding
    objc_autoreleasePoolPush
    objc_autoreleasePoolPop
    objc_retain
    objc_release
    string->nsstring-ptr
    nsstring-ptr->string)
  (import (chezscheme))

  ;; --- Dylib discovery and load ---------------------------------------

  (define libapianyware-chez-path (make-parameter #f))

  ;; Candidate paths checked relative to (current-directory). Order: the
  ;; chez-specific dylib first (preferred once 060 ships), then the
  ;; racket dylib whose `aw_common_*` surface we borrow during bring-up.
  (define default-dylib-candidates
    '("generation/targets/chez/lib/libAPIAnywareChez.dylib"
      "generation/targets/racket/lib/libAPIAnywareRacket.dylib"
      "../lib/libAPIAnywareChez.dylib"
      "../../racket/lib/libAPIAnywareRacket.dylib"))

  (define (resolve-dylib-path)
    (let ([explicit (libapianyware-chez-path)])
      (or explicit
          (let loop ([cs default-dylib-candidates])
            (cond
              [(null? cs)
               (error 'apianyware-runtime-ffi
                      "could not locate libAPIAnywareChez.dylib; searched"
                      default-dylib-candidates)]
              [(file-exists? (car cs)) (car cs)]
              [else (loop (cdr cs))])))))

  ;; Load happens at library instantiation. `load-shared-object` raises
  ;; on failure — that is the hard error ADR-0005 calls for. The loads
  ;; are bundled inside a dummy `define` RHS to satisfy Chez's
  ;; library-body rule that all definitions precede all expressions.
  (define %dylib-loaded
    (begin
      (load-shared-object (resolve-dylib-path))
      (load-shared-object "libobjc.dylib")
      #t))

  (define libobjc-loaded? (make-parameter %dylib-loaded))

  ;; --- Dylib `aw_common_*` surface ------------------------------------

  (define aw-common-get-class
    (foreign-procedure "aw_common_get_class" (string) void*))

  (define aw-common-sel-register
    (foreign-procedure "aw_common_sel_register" (string) void*))

  (define aw-common-retain
    (foreign-procedure "aw_common_retain" (void*) void*))

  (define aw-common-release
    (foreign-procedure "aw_common_release" (void*) void))

  (define aw-common-autorelease-push
    (foreign-procedure "aw_common_autorelease_push" () void*))

  (define aw-common-autorelease-pop
    (foreign-procedure "aw_common_autorelease_pop" (void*) void))

  (define aw-common-string-to-nsstring
    (foreign-procedure "aw_common_string_to_nsstring" (string) void*))

  (define aw-common-nsstring-to-string
    (foreign-procedure "aw_common_nsstring_to_string" (void*) string))

  ;; --- libobjc raw surface --------------------------------------------

  ;; objc_msgSend's variadic signature is realised per-call-site: this
  ;; module exposes the simplest (id, SEL) -> id form that covers
  ;; alloc/init/release-style messages. Emitted class libraries declare
  ;; additional foreign-procedure variants for their specific selector
  ;; signatures — that is the chez idiom and is one of the reasons
  ;; ADR-0005 keeps the target out of portable R6RS.
  (define objc_msgSend
    (foreign-procedure "objc_msgSend" (void* void*) void*))

  (define objc_allocateClassPair
    (foreign-procedure "objc_allocateClassPair"
                       (void* string unsigned-64) void*))

  (define objc_registerClassPair
    (foreign-procedure "objc_registerClassPair" (void*) void))

  (define class_addMethod
    (foreign-procedure "class_addMethod"
                       (void* void* void* string) boolean))

  (define class_getInstanceMethod
    (foreign-procedure "class_getInstanceMethod" (void* void*) void*))

  (define method_getTypeEncoding
    (foreign-procedure "method_getTypeEncoding" (void*) string))

  ;; --- Public surface -------------------------------------------------

  (define objc_getClass aw-common-get-class)
  (define sel_registerName aw-common-sel-register)

  ;; sel_registerName is idempotent but each call still crosses the FFI
  ;; boundary; cache results to keep emitted call sites cheap.
  (define sel-cache (make-hashtable string-hash string=?))

  (define (sel-register name)
    (or (hashtable-ref sel-cache name #f)
        (let ([sel (aw-common-sel-register name)])
          (hashtable-set! sel-cache name sel)
          sel)))

  (define objc_autoreleasePoolPush aw-common-autorelease-push)
  (define objc_autoreleasePoolPop  aw-common-autorelease-pop)

  (define objc_retain  aw-common-retain)
  (define objc_release aw-common-release)

  (define string->nsstring-ptr aw-common-string-to-nsstring)
  (define nsstring-ptr->string aw-common-nsstring-to-string))
