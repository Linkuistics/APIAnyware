;; tests/smoke-emit-foundation.ss — end-to-end smoke check that the
;; 070 scaffold's emitted Foundation class libraries load alongside the
;; runtime and that NSString / NSArray can be constructed via the
;; emitted surface.
;;
;; Run from the repository root:
;;   chez --libdirs targets/chez/bindings/macos \
;;        --script targets/chez/bindings/macos/apianyware/runtime/tests/smoke-emit-foundation.ss
;;
;; Exits 0 on success, raises on failure. Each step prints as it passes
;; so a regression localises to the last-printed line.

(import (apianyware runtime ffi)
        (apianyware runtime objc)
        (apianyware runtime types)
        (apianyware foundation nsstring)
        (apianyware foundation nsarray))

(define (check who expected actual)
  (unless (equal? expected actual)
    (error who "expected" expected "got" actual)))

(define (boolish? v) (or (boolean? v) (and (integer? v) (or (= v 0) (= v 1)))))

(with-autorelease-pool

 ;; --- NSString via runtime helper, queried via emitted accessors ---
 (let* ([s (string->nsstring "hello chez emit")]
        [len (nsstring-length s)])
   (check 'nsstring-length 15 len)
   (display "[smoke] 1. nsstring-length OK\n"))

 ;; UTF8String round-trip via the emitted property getter.
 (let* ([s (string->nsstring "round-trip")]
        [c (nsstring-utf8-string s)])
   (check 'nsstring-utf8-string "round-trip" c)
   (display "[smoke] 2. nsstring-utf8-string OK\n"))

 ;; supportsSecureCoding — emitted class method (zero-arg, boolean return).
 (let ([sc (nsstring-supports-secure-coding)])
   (check 'supports-secure-coding-bool #t (boolish? sc))
   (display "[smoke] 3. nsstring-supports-secure-coding OK\n"))

 ;; --- NSArray via runtime helper, queried via emitted accessors ---
 (let* ([a (list->nsarray
             (list (string->nsstring "one")
                   (string->nsstring "two")
                   (string->nsstring "three")))]
        [n (nsarray-count a)])
   (check 'nsarray-count 3 n)
   (display "[smoke] 4. nsarray-count OK\n"))

 ;; objectAtIndex: — emitted instance method, takes uint64 arg.
 (let* ([a (list->nsarray
             (list (string->nsstring "alpha")
                   (string->nsstring "beta")))]
        [first (nsarray-object-at-index a 0)]
        [back  (nsstring-utf8-string first)])
   (check 'nsarray-object-at-index "alpha" back)
   (display "[smoke] 5. nsarray-object-at-index OK\n")))

(display "[smoke] all tests passed\n")
