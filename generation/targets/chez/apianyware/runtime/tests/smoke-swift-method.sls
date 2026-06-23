;; tests/smoke-swift-method.sls — end-to-end smoke for the chez Swift-native
;; receiver-handle METHOD trampolines (ADR-0030/0031), through the GENERATED
;; bindings, against a freshly built libAPIAnywareChez. The method analogue of
;; smoke-swift-trampoline.sls (which covers free functions/constants). Grove leaf
;; 040-chez/010-build.
;;
;; Run from the repository root, against a freshly built libAPIAnywareChez:
;;   (cd swift && SDKROOT=macosx swift build --target APIAnywareChez)
;;   chez --libdirs generation/targets/chez \
;;        --script generation/targets/chez/apianyware/runtime/tests/smoke-swift-method.sls
;;
;; Two exemplars (the 030 known-good cases, D7), driven through the generated
;; bindings:
;;
;;   pop-B — Foundation.IndexSet (Swift-native VALUE struct, objc_exposed: false):
;;     init(integer:) producer → contains(_:) → insert(_:) mutating write-back.
;;     `make-indexset-integer` boxes an AwChezValueBox; `indexset-insert!` mutates
;;     the SAME box (D3 write-back), so a follow-up `indexset-contains` observes the
;;     inserted member — init producer → value-receiver unbox → mutating write-back
;;     on one stable handle, all via aw_chez_swift_{init,m}_*.
;;
;;   pop-A — Foundation.URLSession.data(from:) (Swift-native ASYNC method): the
;;     generated `nsurlsession-data-from` drives async-bridge.sls's callback runtime
;;     (R4) against a deterministic local file:// source. The completion delivers a
;;     real (Data, URLResponse) handle on the main thread (the MainActor hop), which
;;     this script's CFRunLoop pump drains.

(import (chezscheme)
        (apianyware runtime types)                       ; coerce-arg
        (only (apianyware foundation indexset)
              make-indexset-integer indexset-contains indexset-insert!)
        ;; After k38 (runtime-name class identity) the Swift-overlay `URLSession` class
        ;; merged into the runtime-name `NSURLSession`, so the async `data(from:)` method
        ;; binds as `nsurlsession-data-from` in the unified nsurlsession.sls (the renamed-
        ;; class auto-wrap path: the registry keys on the live class_getName "NSURLSession").
        (only (apianyware foundation nsurlsession)
              nsurlsession-shared-session nsurlsession-data-from)
        (only (apianyware foundation nsurl) nsurl-file-url-with-path))

(define failures 0)
(define total 0)
(define (check who ok?)
  (set! total (+ total 1))
  (if ok?
      (begin (display "  ok   ") (display who) (newline))
      (begin (set! failures (+ failures 1))
             (display "  FAIL ") (display who) (newline))))

;; --- pop-B: value-struct init producer → mutating write-back round-trip ---------
;; init producer (D2): boxes a Swift-native value-struct handle (a raw void*).
(define is (make-indexset-integer 5))
(check 'indexset-init-producer-returns-handle (and (integer? is) (> is 0)))
;; value-receiver unbox + by-value method: 5 present, 7 not yet.
(check 'contains-5-after-init (eq? #t (indexset-contains is 5)))
(check 'contains-7-absent-before-insert (eq? #f (indexset-contains is 7)))
;; mutating value-receiver (D3): insert! writes the mutated copy back into the SAME
;; box, so the next contains on the SAME handle observes it. A broken write-back
;; would leave 7 absent.
(indexset-insert! is 7)
(check 'contains-7-after-insert-D3-writeback (eq? #t (indexset-contains is 7)))
(check 'contains-5-still-present (eq? #t (indexset-contains is 5)))

;; --- pop-A: async method headline through the generated binding -----------------
;; CFRunLoop pump: the async binding never blocks; this script drives the loop, as
;; a real Cocoa app's loop already does. The completion is delivered on the main
;; thread (MainActor hop) and drained here.
(load-shared-object "/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation")
(define %cf-run-loop-run-in-mode
  (foreign-procedure "CFRunLoopRunInMode" (void* double boolean) int))
(define kCFRunLoopDefaultMode
  (foreign-ref 'void* (foreign-entry "kCFRunLoopDefaultMode") 0))

;; Write a deterministic local payload and read it back through the async method.
(define tmp "/tmp/aw-chez-method-smoke.txt")
(call-with-port (open-file-output-port tmp (file-options no-fail))
  (lambda (p)
    (put-bytevector p (string->utf8 "the chez swift-native method frontier resolves end-to-end"))))

(define session (nsurlsession-shared-session))
;; The async binding `(coerce-arg self)`s the receiver but passes the object-ref URL
;; param straight through (R1: the @_cdecl reconstructs URL from NSURL), so unwrap
;; the NSURL wrapper to its raw id here.
(define nsurl (coerce-arg (nsurl-file-url-with-path tmp)))
(check 'shared-session-resolved (and session #t))
(check 'file-nsurl-constructed (and (integer? nsurl) (> nsurl 0)))

(define result #f)
(define err #f)
(define done #f)

;; (nsurlsession-data-from session url complete): complete is (lambda (result err) …).
(nsurlsession-data-from
 session nsurl
 (lambda (r e)
   (set! result r)
   (set! err e)
   (set! done #t)))

;; Pump until the completion fires (bounded ⇒ a deadlock surfaces as a timeout).
(let loop ([i 0])
  (when (and (not done) (< i 500))
    (%cf-run-loop-run-in-mode kCFRunLoopDefaultMode 0.02 #t)
    (loop (+ i 1))))

(check 'async-completion-fired done)
(check 'async-no-error (not err))
(check 'async-delivered-data-response-handle (and (integer? result) (> result 0)))

(if (zero? failures)
    (begin (display "swift-method smoke: ") (display total) (display "/")
           (display total) (display " OK") (newline) (exit 0))
    (begin (display "swift-method smoke: FAILED (") (display failures)
           (display "/") (display total) (display " failed)") (newline) (exit 1)))
