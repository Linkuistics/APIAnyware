;; tests/smoke-objc.sls — end-to-end smoke check for the chez `ffi` and
;; `objc` runtime clusters.
;;
;; Run from the repository root:
;;   chez --libdirs targets/chez/bindings/macos \
;;        --script targets/chez/bindings/macos/apianyware/runtime/tests/smoke-objc.sls
;;
;; Exits 0 on success, raises on failure. Output names each test as it
;; passes so a regression localises to the most-recently-printed line.

(import (apianyware runtime ffi)
        (apianyware runtime objc))

(define (check who expected actual)
  (unless (equal? expected actual)
    (error who "expected" expected "got" actual)))

;; --- 1. NSObject alloc/init/wrap/drop/drain ---------------------------
;;
;; Exercises the lifetime model end-to-end:
;;   - libobjc resolution (objc_getClass + sel-register)
;;   - objc_msgSend (id, SEL) -> id signature
;;   - wrap-objc-object retained-path
;;   - guardian collection + drain-objc-guardian releasing
(let* ([nsobject (objc_getClass "NSObject")]
       [_ (check 'nsobject-lookup #t
                 (and (integer? nsobject) (not (zero? nsobject))))]
       [alloc-sel (sel-register "alloc")]
       [init-sel  (sel-register "init")]
       [_ (check 'alloc-sel-nonnull #t (not (zero? alloc-sel)))]
       [raw (objc_msgSend (objc_msgSend nsobject alloc-sel) init-sel)]
       [_ (check 'init-result-nonnull #t (not (zero? raw)))])

  ;; alloc/init yields +1 ownership — wrap as retained.
  (let ([obj (wrap-objc-object raw #t)])
    (check 'wrap-keeps-ptr raw (objc-object-ptr obj))
    (check 'unwrap-roundtrip raw (unwrap-objc-object obj)))

  ;; Wrapper now unreachable; force GC and drain. The drain must not
  ;; raise (release pointer is valid; guardian-collected wrapper sees a
  ;; non-zero ptr) and must not leak the object — but the latter is only
  ;; observable in Activity Monitor.
  (collect (collect-maximum-generation))
  (drain-objc-guardian)
  (display "[smoke] 1. NSObject alloc/init/wrap/drain OK\n"))

;; --- 2. Autoreleasepool with NSString round-trip ----------------------
;;
;; Exercises with-autorelease-pool around an autoreleased NSString
;; from the dylib's string conversion surface, confirming the pool
;; boundary doesn't break value flow (the multiple-value-preserving
;; `call-with-values` shape).
(let ([result
       (with-autorelease-pool
         (let* ([ns (string->nsstring-ptr "hello chez")]
                [back (nsstring-ptr->string ns)])
           back))])
  (check 'nsstring-roundtrip "hello chez" result)
  (display "[smoke] 2. NSString autoreleasepool roundtrip OK\n"))

;; --- 3. define-entry-point expansion and invocation -------------------
;;
;; The macro must expand without error and the produced procedure must
;; run its body inside an autoreleasepool (observed indirectly via
;; the inner `(objc_getClass …)` call succeeding under the pool).
(define-entry-point (demo-entry)
  (let ([cls (objc_getClass "NSString")])
    (check 'entry-point-nsstring-lookup #t (not (zero? cls)))
    cls))

(let ([cls (demo-entry)])
  (check 'entry-point-returns-cls #t (not (zero? cls)))
  (display "[smoke] 3. define-entry-point OK\n"))

;; --- 4. (values result error) shape demonstration ---------------------
;;
;; ADR-0006: every fallible procedure returns two values. No NSError
;; production yet (that needs msgSend variants emit-chez generates), so
;; this is a shape check: a synthetic fallible procedure round-trips
;; through let-values cleanly.
(define (faux-fallible succeed?)
  (if succeed?
      (values "payload" #f)
      (values #f (make-nserror "FauxDomain" -1 "demo failure" '()))))

(let-values ([(v e) (faux-fallible #t)])
  (check 'fallible-success-value "payload" v)
  (check 'fallible-success-error  #f       e))

(let-values ([(v e) (faux-fallible #f)])
  (check 'fallible-failure-value #f v)
  (check 'fallible-failure-error #t (nserror? e))
  (check 'fallible-failure-code  -1 (nserror-code e))
  (check 'fallible-failure-domain "FauxDomain" (nserror-domain e)))

(display "[smoke] 4. (values result nserror) shape OK\n")

(display "[smoke] all tests passed\n")
