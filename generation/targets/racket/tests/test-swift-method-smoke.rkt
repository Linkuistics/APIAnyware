#lang racket/base
;; test-swift-method-smoke.rkt — end-to-end proof of the Swift-native receiver-handle
;; METHOD trampolines (ADR-0030, spec §8/§9) on REAL recovered residual, through the
;; GENERATED require-tree (not raw binds), against the freshly built dylib. The method
;; analogue of test-swift-trampoline-smoke.rkt (which covers free functions/constants).
;; Grove leaf 030-racket/040-swift-residual-verify.
;;
;; Two exemplars, picked in the 030 build/async leaves and now driven through the
;; generated bindings:
;;
;;   pop-B — Foundation.IndexSet (Swift-native VALUE struct, objc_exposed: false):
;;     init(integer:) producer → contains(_:) → insert(_:) mutating write-back.
;;     `make-indexset-integer` boxes an AwValueBox; `indexset-insert!` mutates the
;;     SAME box (D3 write-back), so a follow-up `indexset-contains` observes the
;;     inserted member — proving init producer → value-receiver unbox → mutating
;;     write-back on one stable handle, all through aw_racket_swift_{init,m}_*.
;;
;;   pop-A — Foundation.URLSession.data(from:) (Swift-native ASYNC method, the
;;     headline): the generated `urlsession-data-from` drives async-bridge.rkt's
;;     callback runtime (R4) against a deterministic local file:// source. The
;;     completion delivers a real (Data, URLResponse) on the main thread.
;;
;; Requiring the generated modules already proves the bindings RESOLVE (a stale or
;; mismatched dylib makes get-ffi-obj raise at module load); the bodies prove they RUN.

(require rackunit
         rackunit/text-ui
         ffi/unsafe
         racket/file
         "../runtime/swift-trampoline.rkt"
         ;; `coerce-arg` unwraps an objc-object wrapper to the raw `id` cpointer the
         ;; R1 object-ref async param expects (spec §9.3 — passed `_pointer` straight).
         (only-in "../runtime/coerce.rkt" coerce-arg)
         ;; pop-B: Swift-native value-struct method trampolines (init/contains/insert).
         "../generated/foundation/indexset.rkt"
         ;; pop-A: Swift-native async method trampoline + the objc receiver/URL it needs.
         (only-in "../generated/foundation/urlsession.rkt" urlsession-data-from)
         (only-in "../generated/foundation/nsurlsession.rkt" nsurlsession-shared-session)
         (only-in "../generated/foundation/nsurl.rkt" nsurl-file-url-with-path))

;; --- CFRunLoop pump (pop-A: the async binding never blocks; the smoke drives the
;;     loop, as a real Cocoa app's loop already does) ---
(define cf (ffi-lib #f))
(define CFRunLoopRunInMode
  (get-ffi-obj "CFRunLoopRunInMode" cf (_fun _pointer _double _bool -> _int32)))
(define dlsym (get-ffi-obj "dlsym" cf (_fun _pointer _string -> _pointer)))
(define RTLD_DEFAULT (cast -2 _intptr _pointer))
(define kCFRunLoopDefaultMode
  (ptr-ref (dlsym RTLD_DEFAULT "kCFRunLoopDefaultMode") _pointer))

(define swift-method-smoke-tests
  (test-suite
   "Swift-native method trampolines — real recovered residual via generated bindings"

   ;; --- pop-B: value-struct init producer → mutating write-back round-trip ---
   (test-case "IndexSet init(integer:) → contains → insert! write-back round-trip"
     ;; init producer (D2): boxes a Swift-native value-struct handle.
     (define is (make-indexset-integer 5))
     (check-true (cpointer? is) "init producer returns a boxed handle")

     ;; value-receiver unbox + by-value method: 5 is present, 7 is not (yet).
     (check-true  (indexset-contains is 5) "init(integer: 5) ⇒ contains 5")
     (check-false (indexset-contains is 7) "7 absent before insert")

     ;; mutating value-receiver (D3): insert! writes the mutated copy back into the
     ;; SAME box, so the next contains on the SAME handle observes it. A broken
     ;; write-back would leave 7 absent.
     (void (indexset-insert! is 7))
     (check-true (indexset-contains is 7)
                 "after insert!(7) the same handle contains 7 — D3 write-back proven")
     (check-true (indexset-contains is 5) "original member still present"))

   ;; --- pop-A: async method headline through the generated binding ---
   (test-case "URLSession.data(from: file://…) async method delivers real bytes"
     (define tmp (make-temporary-file "aw-method-smoke-~a.txt"))
     (define payload #"the swift-native method frontier resolves end-to-end")
     (void (call-with-output-file tmp #:exists 'truncate
             (lambda (out) (write-bytes payload out))))

     (define session (nsurlsession-shared-session))
     ;; The async binding does `(coerce-arg self)` on the receiver but passes the
     ;; object-ref param straight through, so unwrap the NSURL to its raw `id` here.
     (define nsurl (coerce-arg (nsurl-file-url-with-path (path->string tmp))))
     (check-true (and session #t) "URLSession.shared resolved")
     (check-true (and nsurl #t) "file NSURL constructed")

     (define result-box (box #f))
     (define err-box (box #f))
     (define done (box #f))

     ;; The generated async binding: (urlsession-data-from session url complete).
     (urlsession-data-from
      session nsurl
      (lambda (handle err)
        (set-box! result-box handle)
        (set-box! err-box err)
        (set-box! done #t)))

     ;; Pump until the completion fires (bounded ⇒ a deadlock surfaces as failure).
     (let loop ([i 0])
       (unless (or (unbox done) (>= i 500))
         (CFRunLoopRunInMode kCFRunLoopDefaultMode 0.02 #t)
         (loop (add1 i))))

     (delete-file tmp)
     (check-false (unbox err-box) "async call delivered no error")
     (check-true (unbox done) "completion fired (no deadlock/timeout)")
     (check-true (cpointer? (unbox result-box))
                 "completion delivered a real (Data, URLResponse) handle"))))

(module+ main
  (exit (run-tests swift-method-smoke-tests)))
