;; tests/smoke-types-cocoa.sls — end-to-end smoke check for the chez
;; `types`, `cocoa`, and `cocoa-helpers` runtime clusters.
;;
;; Run from the repository root:
;;   chez --script generation/targets/chez/runtime/tests/smoke-types-cocoa.sls
;;
;; Covers the "Done when" set of .grove/050-chez-target/050:
;;   - libraries load
;;   - NSString round-trip
;;   - geometry ftype construction + nested-accessor round-trip
;;   - install-standard-app-menu! installs a menu without crashing

(define here "generation/targets/chez/runtime")
(load (string-append here "/ffi.sls"))
(load (string-append here "/objc.sls"))
(load (string-append here "/dispatch.sls"))
(load (string-append here "/types.sls"))
(load (string-append here "/cocoa.sls"))
(load (string-append here "/cocoa-helpers.sls"))

(import (apianyware runtime ffi)
        (apianyware runtime objc)
        (apianyware runtime types)
        (apianyware runtime cocoa)
        (apianyware runtime cocoa-helpers))

(define (check who expected actual)
  (unless (equal? expected actual)
    (error who "expected" expected "got" actual)))

;; --- 1. NSString round-trip via (apianyware runtime types) -----------
(let ([result
       (with-autorelease-pool
         (let* ([ns (string->nsstring "hi from chez types")]
                [s  (nsstring->string ns)])
           s))])
  (check 'nsstring-roundtrip "hi from chez types" result)
  (display "[smoke] 1. NSString roundtrip OK\n"))

;; --- 2. Geometry ftypes ----------------------------------------------
;;
;; Validates the value-by-copy ftype layout: build an NSRect with
;; make-nsrect, pull its origin sub-struct via NSRect-origin, then read
;; the inner NSPoint's x/y through the aliasing pointer. This exercises
;; ftype-set!, ftype-&ref, and ftype-ref end-to-end.
(let* ([r (make-nsrect 12.5 34.0 100.0 200.0)]
       [o (nsrect-origin r)]
       [s (nsrect-size r)])
  (check 'nsrect-origin-x 12.5  (nspoint-x o))
  (check 'nsrect-origin-y 34.0  (nspoint-y o))
  (check 'nsrect-size-w   100.0 (nssize-width s))
  (check 'nsrect-size-h   200.0 (nssize-height s))
  (display "[smoke] 2. NSRect roundtrip OK\n"))

;; --- 3. install-standard-app-menu! against a stub NSApplication ------
;;
;; [NSApplication sharedApplication] returns the singleton; passing it
;; through install-standard-app-menu! exercises the full chain of
;; allocations and msgSends. We don't run the run-loop — we just confirm
;; the menu install completes without crashing.
;;
;; The runtime dylib (libAPIAnywareChez) links Foundation but not AppKit;
;; load AppKit explicitly so NSApplication and NSMenu register with the
;; objc runtime.
(load-shared-object "/System/Library/Frameworks/AppKit.framework/AppKit")

(with-autorelease-pool
  (let* ([cls (objc_getClass "NSApplication")]
         [app (objc_msgSend cls (sel-register "sharedApplication"))])
    (check 'nsapp-nonnull #t (not (zero? app)))
    (install-standard-app-menu! app "Smoke")
    (display "[smoke] 3. install-standard-app-menu! OK\n")))

;; --- 4. NSArray round-trip with mixed-style items --------------------
;;
;; Exercises the Foundation collection helpers — list->nsarray builds
;; from objc-objects, nsarray->list returns borrowed wrappers, and
;; objects survive an autoreleasepool boundary because the array
;; retains its elements.
(with-autorelease-pool
  (let* ([a (string->nsstring "alpha")]
         [b (string->nsstring "beta")]
         [arr (list->nsarray (list a b))]
         [items (nsarray->list arr)])
    (check 'array-len 2 (length items))
    (check 'array-item-0 "alpha" (nsstring->string (car items)))
    (check 'array-item-1 "beta"  (nsstring->string (cadr items)))
    (display "[smoke] 4. NSArray roundtrip OK\n")))

;; --- 5. CoreFoundation string round-trip -----------------------------
;;
;; Round-trips via CFStringCreateWithCString + CFStringGetCStringPtr
;; (fast path). Both halves are exercised; failure of one half is
;; observable through the value comparison.
(let* ([cf (string->cfstring "cf-ping")]
       [s  (cfstring->string cf)])
  (cf-release cf)
  (check 'cfstring-roundtrip "cf-ping" s)
  (display "[smoke] 5. CFString roundtrip OK\n"))

(display "[smoke] all tests passed\n")
