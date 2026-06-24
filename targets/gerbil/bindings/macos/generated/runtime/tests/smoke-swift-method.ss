;;; tests/smoke-swift-method.ss — end-to-end CLI smoke for the gerbil Swift-native
;;; receiver-handle METHOD trampolines (ADR-0030; the gerbil port, leaf
;;; 050-gerbil/010-build). The method analogue of smoke-swift-trampoline.ss (which
;;; covers free functions/constants). Built + run by run-swift-method-smoke.sh,
;;; which links the gerbil exe against a freshly built libAPIAnywareGerbil.dylib.
;;;
;;; Two exemplars (the 030 known-good cases, D7), driven through the GENERATED
;;; bindings:
;;;
;;;   pop-B — Foundation.IndexSet (Swift-native VALUE struct, objc_exposed: false):
;;;     init(integer:) producer → contains(_:) → insert(_:) mutating write-back.
;;;     `make-indexset-integer` boxes an AwGerbilValueBox handle (a raw pointer, no
;;;     ObjC class to wrap to); `indexset-insert!` mutates the SAME box (D3
;;;     write-back), so a follow-up `indexset-contains` on the SAME handle observes
;;;     the inserted member — init producer → value-receiver unbox → mutating
;;;     write-back on one stable handle, all via aw_gerbil_swift_{init,m}_*.
;;;
;;;   pop-A — Foundation.URLSession.data(from:) (Swift-native ASYNC method): the
;;;     generated `nsurlsession-data-from` drives async-bridge.ss's callback runtime
;;;     (R4) against a deterministic local file:// source. The completion delivers a
;;;     real (Data, URLResponse) handle on the main thread (the MainActor hop), which
;;;     this script's CFRunLoop pump drains.
;;;
;;; Prints SWIFT-METHOD-OK on success; exits non-zero on failure.

(export main)
(import :gerbil-bindings/runtime/objc              ; ptr-null?, wrap/->ptr
        :gerbil-bindings/runtime/tests/cf-runloop   ; cf-run-loop-run-in-mode (async pump)
        :gerbil-bindings/foundation/indexset       ; make-indexset-integer, contains, insert!
        ;; After k38 (runtime-name class identity) the Swift-overlay `URLSession` class
        ;; merged into the runtime-name `NSURLSession`, so the async `data(from:)` method
        ;; binds as `nsurlsession-data-from` in the unified nsurlsession.ss (the renamed-
        ;; class auto-wrap path: the registry keys on the live class_getName "NSURLSession").
        :gerbil-bindings/foundation/nsurlsession   ; nsurlsession-shared-session, nsurlsession-data-from
        :gerbil-bindings/foundation/nsurl)         ; nsurl-file-url-with-path

(def (main . _)
  (def failures 0)
  (def total 0)
  (def (check who ok?)
    (set! total (+ total 1))
    (if ok?
      (begin (display "  ok   ") (displayln who))
      (begin (set! failures (+ failures 1)) (display "  FAIL ") (displayln who))))
  (def (handle? p) (and p (not (ptr-null? p))))

  ;; --- pop-B: value-struct init producer → mutating write-back round-trip -------
  ;; init producer (D2): boxes a Swift-native value-struct handle (a raw pointer).
  (def is (make-indexset-integer 5))
  (check 'indexset-init-producer-returns-handle (handle? is))
  ;; value-receiver unbox + by-value method: 5 present, 7 not yet.
  (check 'contains-5-after-init (eq? #t (indexset-contains is 5)))
  (check 'contains-7-absent-before-insert (eq? #f (indexset-contains is 7)))
  ;; mutating value-receiver (D3): insert! writes the mutated copy back into the SAME
  ;; box, so the next contains on the SAME handle observes it. A broken write-back
  ;; would leave 7 absent.
  (indexset-insert! is 7)
  (check 'contains-7-after-insert-D3-writeback (eq? #t (indexset-contains is 7)))
  (check 'contains-5-still-present (eq? #t (indexset-contains is 5)))

  ;; --- pop-A: async method headline through the generated binding ---------------
  ;; Write a deterministic local payload and read it back through the async method.
  (def tmp "/tmp/aw-gerbil-method-smoke.txt")
  (call-with-output-file tmp
    (lambda (p) (display "the gerbil swift-native method frontier resolves end-to-end" p)))

  (def session (nsurlsession-shared-session))
  ;; The ObjC `fileURLWithPath:` binding takes an NSString id (it `->ptr`s its arg);
  ;; bridge the Scheme path string first (gerbil's caller-side string convention).
  (def url (nsurl-file-url-with-path (string->nsstring tmp)))
  (check 'shared-session-resolved (handle? (->ptr session)))
  (check 'file-nsurl-constructed (handle? (->ptr url)))

  (def result #f)
  (def err #f)
  (def done #f)
  ;; (nsurlsession-data-from session url complete): complete is (lambda (result err) …).
  (nsurlsession-data-from
   session url
   (lambda (r e) (set! result r) (set! err e) (set! done #t)))

  ;; Pump until the completion fires (bounded ⇒ a deadlock surfaces as a timeout).
  (let loop ((i 0))
    (when (and (not done) (< i 500))
      (cf-run-loop-run-in-mode 0.02)
      (loop (+ i 1))))

  (check 'async-completion-fired done)
  (check 'async-no-error (not err))
  (check 'async-delivered-data-response-handle (handle? result))

  (if (zero? failures)
    (begin (display "SWIFT-METHOD-OK (") (display total) (display "/")
           (display total) (displayln ")") (exit 0))
    (begin (display "SWIFT-METHOD-FAILED (") (display failures) (display "/")
           (display total) (displayln " failed)") (exit 1))))
