#lang racket/base
;; test-ffi-roundtrip.rkt — FFI round-trip tests: Racket → Swift helper → verify
;;
;; Tests core Swift dylib functions:
;;   - Class and selector lookup
;;   - String conversion (Racket string → NSString → Racket string)
;;   - Autorelease pool push/pop
;;   - Retain/release cycle
;;   - GC prevention registry
;;   - NSString length via dylib

(require rackunit
         rackunit/text-ui
         ffi/unsafe
         ffi/unsafe/objc
         "../runtime/swift-helpers.rkt"
         "../runtime/objc-base.rkt"
         "../runtime/type-mapping.rkt")

(define ffi-roundtrip-tests
  (test-suite
   "FFI round-trip verification"

   (test-suite
    "Class and selector lookup"

    (test-case "Look up NSObject class"
      (define cls (swift:get-class "NSObject"))
      (check-not-false cls "NSObject class should be found")
      (check-pred cpointer? cls "Should return a pointer"))

    (test-case "Look up NSString class"
      (define cls (swift:get-class "NSString"))
      (check-not-false cls "NSString class should be found")
      (check-pred cpointer? cls "Should return a pointer"))

    (test-case "Look up nonexistent class returns null"
      (define cls (swift:get-class "NonExistentClass12345"))
      ;; null pointer check — ptr-equal? to #f means null
      (check-true (or (not cls) (ptr-equal? cls #f))
                  "Nonexistent class should return null pointer"))

    (test-case "Register selector"
      (define sel (swift:sel-register "init"))
      (check-not-false sel "init selector should be registerable")
      (check-pred cpointer? sel "Should return a pointer"))

    (test-case "Register multi-part selector"
      (define sel (swift:sel-register "initWithString:"))
      (check-not-false sel "initWithString: selector should be registerable")
      (check-pred cpointer? sel)))

   (test-suite
    "String conversion round-trip"

    (test-case "ASCII string round-trip"
      (define nsstr (swift:string-to-nsstring "hello"))
      (check-not-false nsstr "Should create NSString")
      (define result (swift:nsstring-to-string nsstr))
      (check-equal? result "hello" "Round-trip should preserve ASCII string")
      (swift:release nsstr))

    (test-case "Unicode string round-trip"
      (define nsstr (swift:string-to-nsstring "Hello, World! \u2603 \u00e9\u00e8\u00ea"))
      (define result (swift:nsstring-to-string nsstr))
      (check-equal? result "Hello, World! \u2603 \u00e9\u00e8\u00ea"
                    "Round-trip should preserve Unicode")
      (swift:release nsstr))

    (test-case "Empty string round-trip"
      (define nsstr (swift:string-to-nsstring ""))
      (define result (swift:nsstring-to-string nsstr))
      (check-equal? result "" "Empty string should round-trip")
      (swift:release nsstr))

    (test-case "NSString length via dylib"
      (define nsstr (swift:string-to-nsstring "hello"))
      (define len (swift:nsstring-length nsstr))
      (check-equal? len 5 "Length of 'hello' should be 5")
      (swift:release nsstr))

    (test-case "Unicode string length (UTF-16 units)"
      ;; NSString length counts UTF-16 code units, not characters
      (define nsstr (swift:string-to-nsstring "caf\u00e9"))
      (define len (swift:nsstring-length nsstr))
      (check-equal? len 4 "Length of 'caf\u00e9' should be 4 UTF-16 units")
      (swift:release nsstr)))

   (test-suite
    "Autorelease pool"

    (test-case "Push and pop autorelease pool"
      (define pool (swift:autorelease-push))
      (check-not-false pool "Pool push should return a token")
      (check-pred cpointer? pool "Pool token should be a pointer")
      ;; Create an autoreleased object inside the pool
      (define nsstr (swift:string-to-nsstring "pooled"))
      (check-not-false nsstr)
      ;; Pop — this drains the pool
      (swift:autorelease-pop pool))

    (test-case "with-autorelease-pool syntax works"
      (define result
        (with-autorelease-pool
          (let ([nsstr (swift:string-to-nsstring "in pool")])
            (swift:nsstring-to-string nsstr))))
      (check-equal? result "in pool"
                    "Should be able to use strings inside pool")))

   (test-suite
    "Retain/release"

    (test-case "Retain increments refcount, release decrements"
      ;; Create NSString (returns +1)
      (define nsstr (swift:string-to-nsstring "retained"))
      ;; Retain again (+2)
      (define same (swift:retain nsstr))
      (check-pred cpointer? same "Retain should return a pointer")
      ;; Release twice (back to +0, deallocated)
      (swift:release nsstr)
      (swift:release nsstr))

    (test-case "wrap-objc-object with retained flag"
      ;; string-to-nsstring returns +1 (retained)
      (define nsstr (swift:string-to-nsstring "wrapped"))
      (define obj (wrap-objc-object nsstr #:retained #t))
      (check-true (objc-object? obj) "Should be an objc-object")
      (check-false (objc-null? obj) "Should not be null")
      ;; The finalizer will release when obj is collected
      ;; Verify we can read it
      (define result (swift:nsstring-to-string (unwrap-objc-object obj)))
      (check-equal? result "wrapped")))

   (test-suite
    "GC prevention"

    (test-case "Prevent and allow GC"
      ;; Create a pointer to prevent from GC
      (define nsstr (swift:string-to-nsstring "gc-test"))
      (define handle (swift:prevent-gc nsstr))
      (check-pred integer? handle "Handle should be an integer")
      ;; GC count should increase
      (define count-before (swift:gc-count))
      (check-true (> count-before 0)
                  "GC count should be positive after prevention")
      ;; Allow GC
      (swift:allow-gc handle)
      (define count-after (swift:gc-count))
      (check-equal? count-after (sub1 count-before)
                    "GC count should decrease after allowing")
      (swift:release nsstr)))

   (test-suite
    "Type mapping integration"

    (test-case "string->nsstring and nsstring->string via type-mapping"
      (define nsstr (string->nsstring "via type-mapping"))
      (define result (nsstring->string nsstr))
      (check-equal? result "via type-mapping")
      (tell nsstr release))

    (test-case "NSPoint struct creation"
      (define pt (make-nspoint 10.5 20.3))
      (check-= (NSPoint-x pt) 10.5 0.001)
      (check-= (NSPoint-y pt) 20.3 0.001))

    (test-case "NSSize struct creation"
      (define sz (make-nssize 100 200))
      (check-= (NSSize-width sz) 100.0 0.001)
      (check-= (NSSize-height sz) 200.0 0.001))

    (test-case "NSRect struct creation"
      (define rect (make-nsrect 10 20 300 400))
      (check-= (NSPoint-x (NSRect-origin rect)) 10.0 0.001)
      (check-= (NSPoint-y (NSRect-origin rect)) 20.0 0.001)
      (check-= (NSSize-width (NSRect-size rect)) 300.0 0.001)
      (check-= (NSSize-height (NSRect-size rect)) 400.0 0.001))

    (test-case "list->nsarray and nsarray->list round-trip"
      (with-autorelease-pool
        (let* ([s1 (string->nsstring "a")]
               [s2 (string->nsstring "b")]
               [s3 (string->nsstring "c")]
               [arr (list->nsarray (list s1 s2 s3))]
               [back (nsarray->list arr)])
          (check-equal? (length back) 3 "Should have 3 elements")
          (check-equal? (nsstring->string (car back)) "a")
          (check-equal? (nsstring->string (cadr back)) "b")
          (check-equal? (nsstring->string (caddr back)) "c")))))))

(run-tests ffi-roundtrip-tests)
