#lang racket/base
;; async-method-smoke.rkt — the racket side of the async-method in-process smoke
;; (030-racket/020-async-method). Drives the REAL async-bridge.rkt callback runtime
;; (R4) against the hand-authored `URLSession.data(from:)` async trampoline compiled
;; into the dylib (async-method-smoke.swift), proving a real recovered `async throws`
;; method resolves and runs end-to-end. Run via run.sh.
;;
;; The binding is exactly what `render_async_racket_method` emits (the callback form,
;; no blocking await). Because there is no `nsapplication-run` here, the SMOKE itself
;; pumps the main run loop until the completion fires — in a real app the Cocoa loop
;; already does. The completion arrives on the main thread (the SIGILL-safe hop).

(require ffi/unsafe
         racket/file
         (only-in "../async-bridge.rkt" aw-async-call)
         (only-in "../swift-helpers.rkt" anyware-lib swift:string-to-nsstring))

;; --- smoke @_cdecls bound raw from the dylib ---
(define url-session-shared
  (get-ffi-obj 'aw_smoke_url_session_shared anyware-lib (_fun -> _pointer)))
(define file-url
  (get-ffi-obj 'aw_smoke_file_url anyware-lib (_fun _pointer -> _pointer)))
(define url-session-data-raw
  (get-ffi-obj 'aw_smoke_url_session_data anyware-lib
               (_fun _pointer _pointer _intptr _fpointer -> _void)))
(define tuple-data-count
  (get-ffi-obj 'aw_smoke_tuple_data_count anyware-lib (_fun _pointer -> _intptr)))

;; --- CFRunLoop pump (the smoke drives the loop; the binding never blocks) ---
(define cf (ffi-lib #f))
(define CFRunLoopRunInMode
  (get-ffi-obj "CFRunLoopRunInMode" cf (_fun _pointer _double _bool -> _int32)))
(define dlsym (get-ffi-obj "dlsym" cf (_fun _pointer _string -> _pointer)))
(define RTLD_DEFAULT (cast -2 _intptr _pointer))
(define kCFRunLoopDefaultMode
  (ptr-ref (dlsym RTLD_DEFAULT "kCFRunLoopDefaultMode") _pointer))

;; --- a deterministic local source ---
(define tmp (make-temporary-file "aw-async-smoke-~a.txt"))
(define payload #"the swift-native async method frontier resolves end-to-end")
(void (call-with-output-file tmp #:exists 'truncate
        (lambda (out) (write-bytes payload out))))

;; --- the async binding, byte-for-byte render_async_racket_method's shape ---
(define (url-session-data self url complete)
  (aw-async-call
   (lambda (id cb) (url-session-data-raw self url id cb))
   values
   complete))

(define result-box (box #f))
(define err-box (box #f))
(define done (box #f))

(define session (url-session-shared))
(define nsurl (file-url (swift:string-to-nsstring (path->string tmp))))

(url-session-data
 session nsurl
 (lambda (handle err)
   (set-box! result-box handle)
   (set-box! err-box err)
   (set-box! done #t)))

;; Pump until the completion fires (bounded so a deadlock surfaces as failure).
(let loop ([i 0])
  (unless (or (unbox done) (>= i 500))
    (CFRunLoopRunInMode kCFRunLoopDefaultMode 0.02 #t)
    (loop (add1 i))))

(delete-file tmp)

(cond
  [(unbox err-box)
   (eprintf "SMOKE FAIL: async call delivered an error: ~a\n"
            (exn-message (unbox err-box)))
   (exit 1)]
  [(not (unbox done))
   (eprintf "SMOKE FAIL: completion never fired (deadlock / timeout)\n")
   (exit 1)]
  [else
   (define n (tuple-data-count (unbox result-box)))
   (printf "async URLSession.data(from: file://…) delivered ~a bytes (expected ~a)\n"
           n (bytes-length payload))
   (cond
     [(= n (bytes-length payload))
      (printf "SMOKE PASS — real (Data, URLResponse) crossed the async bridge\n")
      (exit 0)]
     [else
      (eprintf "SMOKE FAIL: byte count mismatch\n")
      (exit 1)])])
