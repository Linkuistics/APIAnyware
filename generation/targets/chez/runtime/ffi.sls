;; runtime/ffi.sls — chez target FFI primitives.
;;
;; Scaffold: bodies are `(error ... "not yet implemented")` stubs. Real
;; FFI lands in `.grove/050-chez-target/030-runtime-ffi-objc.md`.
;;
;; Eventually holds:
;;   - mandatory load of libAPIAnywareChez.dylib (per ADR-0005)
;;   - libobjc / libdispatch `foreign-procedure` declarations
;;   - curated `objc_*` runtime bindings
;;
;; Absorbs from the racket runtime: swift-helpers.rkt (full rewrite).

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
    objc_release)
  (import (chezscheme))

  (define libapianyware-chez-path (make-parameter #f))

  (define libobjc-loaded? (make-parameter #f))

  (define (objc_getClass name)
    (error 'objc_getClass "not yet implemented"))

  (define (objc_msgSend . args)
    (error 'objc_msgSend "not yet implemented"))

  (define (objc_allocateClassPair . args)
    (error 'objc_allocateClassPair "not yet implemented"))

  (define (objc_registerClassPair cls)
    (error 'objc_registerClassPair "not yet implemented"))

  (define (class_addMethod cls sel imp type-encoding)
    (error 'class_addMethod "not yet implemented"))

  (define (sel_registerName name)
    (error 'sel_registerName "not yet implemented"))

  (define (sel-register name)
    (error 'sel-register "not yet implemented"))

  (define (class_getInstanceMethod cls sel)
    (error 'class_getInstanceMethod "not yet implemented"))

  (define (method_getTypeEncoding method)
    (error 'method_getTypeEncoding "not yet implemented"))

  (define (objc_autoreleasePoolPush)
    (error 'objc_autoreleasePoolPush "not yet implemented"))

  (define (objc_autoreleasePoolPop pool)
    (error 'objc_autoreleasePoolPop "not yet implemented"))

  (define (objc_retain ptr)
    (error 'objc_retain "not yet implemented"))

  (define (objc_release ptr)
    (error 'objc_release "not yet implemented")))
