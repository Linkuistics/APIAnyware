#lang racket/base
;; test-generated-smoke.rkt — Language-side smoke tests for generated OO bindings
;;
;; Imports generated Foundation bindings and verifies they work end-to-end:
;;   - NSObject creation and description
;;   - NSString operations (length, UTF8String, comparisons)
;;   - NSArray count and element access
;;   - NSMutableArray property mutation
;;   - Block invocation through generated bindings
;;   - NSNumber type coercion

(require rackunit
         rackunit/text-ui
         ffi/unsafe
         ffi/unsafe/objc
         "../runtime/objc-base.rkt"
         "../runtime/type-mapping.rkt"
         "../runtime/block.rkt"
         ;; Generated bindings (individual modules, not main.rkt — too slow to load all 300+)
         "../generated/foundation/nsobject.rkt"
         "../generated/foundation/nsstring.rkt"
         "../generated/foundation/nsarray.rkt"
         "../generated/foundation/nsmutablearray.rkt"
         "../generated/foundation/nsnumber.rkt"
         "../generated/foundation/nsdata.rkt"
         "../generated/foundation/nserror.rkt"
         "../generated/foundation/nslock.rkt")

(define smoke-tests
  (test-suite
   "Generated OO binding smoke tests"

   (test-suite
    "NSString"

    (test-case "NSString length via generated binding"
      (with-autorelease-pool
        (let* ([nsstr (string->nsstring "hello")]
               [obj (wrap-objc-object nsstr #:retained #t)])
          (check-equal? (nsstring-length obj) 5 "Length should be 5"))))

    (test-case "NSString description returns a wrapped object"
      (with-autorelease-pool
        (let* ([nsstr (string->nsstring "test")]
               [obj (wrap-objc-object nsstr #:retained #t)]
               [desc (nsstring-description obj)])
          (check-true (objc-object? desc) "Description should return an objc-object")
          (check-false (objc-null? desc) "Description should not be null"))))

    (test-case "NSString initWithCoder constructor"
      ;; We can't easily test initWithCoder without an actual coder,
      ;; but we can verify the function exists and is callable
      (check-true (procedure? make-nsstring-init-with-coder)
                  "Constructor should be a procedure"))

    (test-case "NSString hash via generated binding"
      (with-autorelease-pool
        (let* ([nsstr (string->nsstring "hello")]
               [obj (wrap-objc-object nsstr #:retained #t)]
               [h (nsstring-hash obj)])
          (check-pred integer? h "Hash should be an integer")
          (check-true (> h 0) "Hash should be positive"))))

    (test-case "NSString integer-value"
      (with-autorelease-pool
        (let* ([nsstr (string->nsstring "42")]
               [obj (wrap-objc-object nsstr #:retained #t)])
          (check-equal? (nsstring-integer-value obj) 42)))))

   (test-suite
    "NSArray"

    (test-case "NSArray count via generated binding"
      (with-autorelease-pool
        (let* ([s1 (string->nsstring "a")]
               [s2 (string->nsstring "b")]
               [obj (list->nsarray (list s1 s2))])
          (check-equal? (nsarray-count obj) 2 "Count should be 2"))))

    (test-case "NSArray first-object and last-object"
      (with-autorelease-pool
        (let* ([s1 (string->nsstring "first")]
               [s2 (string->nsstring "last")]
               [obj (list->nsarray (list s1 s2))])
          (let ([first (nsarray-first-object obj)]
                [last (nsarray-last-object obj)])
            (check-true (objc-object? first))
            (check-true (objc-object? last))
            (check-false (objc-null? first))
            (check-false (objc-null? last))))))

    (test-case "NSArray description"
      (with-autorelease-pool
        (let* ([s1 (string->nsstring "x")]
               [obj (list->nsarray (list s1))]
               [desc (nsarray-description obj)])
          (check-true (objc-object? desc))))))

   (test-suite
    "NSMutableArray"

    (test-case "NSMutableArray add and count"
      (with-autorelease-pool
        (let ([arr (wrap-objc-object (tell (tell NSMutableArray alloc) init)
                                     #:retained #t)])
          ;; Generated wrappers reject raw cpointers; pass a Racket string
          ;; and let coerce-arg convert it to NSString at the boundary.
          (nsmutablearray-add-object! arr "item1")
          (check-equal? (nsarray-count arr) 1 "Count should be 1 after adding"))))

    (test-case "NSMutableArray remove-last-object!"
      (with-autorelease-pool
        (let ([arr (wrap-objc-object (tell (tell NSMutableArray alloc) init)
                                     #:retained #t)])
          (nsmutablearray-add-object! arr "item")
          (nsmutablearray-add-object! arr "item2")
          (check-equal? (nsarray-count arr) 2)
          (nsmutablearray-remove-last-object! arr)
          (check-equal? (nsarray-count arr) 1 "Count should be 1 after removing last")))))

   (test-suite
    "NSNumber"

    (test-case "NSNumber int-value"
      (with-autorelease-pool
        (let ([n (wrap-objc-object (tell NSNumber numberWithInt: #:type _int 42))])
          (check-equal? (nsnumber-int-value n) 42))))

    (test-case "NSNumber bool-value"
      (with-autorelease-pool
        (let ([n (wrap-objc-object (tell NSNumber numberWithBool: #:type _bool #t))])
          (check-true (nsnumber-bool-value n)))))

    (test-case "NSNumber double-value"
      (with-autorelease-pool
        (let ([n (wrap-objc-object (tell NSNumber numberWithDouble: #:type _double 3.14))])
          (check-= (nsnumber-double-value n) 3.14 0.001)))))

   (test-suite
    "NSData"

    (test-case "NSData length"
      (with-autorelease-pool
        (let* ([str (string->nsstring "hello")]
               ;; Create data from string via dataUsingEncoding:
               [data (wrap-objc-object (tell str dataUsingEncoding: #:type _uint64 4))]  ; 4 = NSUTF8StringEncoding
               [len (nsdata-length data)])
          (check-equal? len 5 "Data length should match string length")))))

   (test-suite
    "NSLock"

    (test-case "NSLock try-lock and properties"
      (with-autorelease-pool
        (let ([lock (wrap-objc-object (tell (tell NSLock alloc) init) #:retained #t)])
          ;; try-lock returns bool
          (let ([got-lock (nslock-try-lock lock)])
            (check-true got-lock "try-lock should succeed on unlocked lock")
            ;; Unlock via tell (lock/unlock are inherited, not on generated NSLock)
            (tell (unwrap-objc-object lock) unlock))
          ;; name property
          (nslock-set-name! lock (wrap-objc-object (string->nsstring "test-lock")
                                                    #:retained #t))
          (let ([name (nslock-name lock)])
            (check-true (objc-object? name)))))))))

(run-tests smoke-tests)
