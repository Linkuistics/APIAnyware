;; runtime/ffi.sls — chez target FFI primitives.
;;
;; Holds:
;;   - mandatory load of `libAPIAnywareChez.dylib` (per ADR-0005 /
;;     decision 7). The dylib is self-contained (ADR-0011): it owns its
;;     entire `aw_chez_*` surface with no shared substrate.
;;   - libobjc class/sel/msgSend/retain/release surface
;;   - autorelease pool primitives via the dylib's `aw_chez_*` wrappers
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

  ;; Probe `<libdir>/lib/libAPIAnywareChez.dylib` for every directory in
  ;; (library-directories). Subsumes both layouts: unbundled CLI use
  ;; (`--libdirs generation/targets/chez/` → repo dylib) and bundled
  ;; .app launch (`--libdirs <Resources>/chez-app/` → bundled dylib).
  ;; The chez stub-launcher always passes --libdirs, so this is the
  ;; one mechanism that covers both call sites without environment
  ;; injection.
  (define (libdir->path d)
    (if (pair? d) (car d) d))

  (define (resolve-dylib-path)
    (or (libapianyware-chez-path)
        (let loop ([dirs (library-directories)])
          (cond
            [(null? dirs)
             (error 'apianyware-runtime-ffi
                    "could not locate libAPIAnywareChez.dylib; probed lib/libAPIAnywareChez.dylib under each (library-directories) entry"
                    (map libdir->path (library-directories)))]
            [else
             (let ([candidate (string-append (libdir->path (car dirs))
                                             "/lib/libAPIAnywareChez.dylib")])
               (if (file-exists? candidate)
                   candidate
                   (loop (cdr dirs))))]))))

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

  ;; --- Dylib `aw_chez_*` surface --------------------------------------

  (define aw-chez-get-class
    (foreign-procedure "aw_chez_get_class" (string) void*))

  (define aw-chez-sel-register
    (foreign-procedure "aw_chez_sel_register" (string) void*))

  (define aw-chez-retain
    (foreign-procedure "aw_chez_retain" (void*) void*))

  (define aw-chez-release
    (foreign-procedure "aw_chez_release" (void*) void))

  (define aw-chez-autorelease-push
    (foreign-procedure "aw_chez_autorelease_push" () void*))

  (define aw-chez-autorelease-pop
    (foreign-procedure "aw_chez_autorelease_pop" (void*) void))

  (define aw-chez-string-to-nsstring
    (foreign-procedure "aw_chez_string_to_nsstring" (string) void*))

  (define aw-chez-nsstring-to-string
    (foreign-procedure "aw_chez_nsstring_to_string" (void*) string))

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

  (define objc_getClass aw-chez-get-class)
  (define sel_registerName aw-chez-sel-register)

  ;; sel_registerName is idempotent but each call still crosses the FFI
  ;; boundary; cache results to keep emitted call sites cheap.
  (define sel-cache (make-hashtable string-hash string=?))

  (define (sel-register name)
    (or (hashtable-ref sel-cache name #f)
        (let ([sel (aw-chez-sel-register name)])
          (hashtable-set! sel-cache name sel)
          sel)))

  (define objc_autoreleasePoolPush aw-chez-autorelease-push)
  (define objc_autoreleasePoolPop  aw-chez-autorelease-pop)

  (define objc_retain  aw-chez-retain)
  (define objc_release aw-chez-release)

  (define string->nsstring-ptr aw-chez-string-to-nsstring)
  (define nsstring-ptr->string aw-chez-nsstring-to-string))
