#lang racket/base
;; diag3.rkt — isolate the ffi2 `#f` glitch: void callout vs int-callback vs
;; void-callback, plus explicit ffi2-callback. NO ffi/unsafe. THROWAWAY.
(require ffi2 racket/runtime-path)

(define-runtime-path libspike-path "libspike.dylib")
(define spike (ffi2-lib (path->string libspike-path)))
(define-ffi2-definer define-spike #:lib spike)

(define-spike aw_spike_void_noop    (-> uint64_t void_t))
(define-spike aw_spike_call_int_cb  (-> (-> int_t int_t) int_t))
(define-spike aw_spike_call_void_cb (-> (-> void_t) void_t))

(define (try label thunk)
  (printf "~a: " label) (flush-output)
  (with-handlers ([(lambda (_) #t)
                   (lambda (e) (printf "ERROR ~a\n" (if (exn? e) (exn-message e) e)) (flush-output))])
    (define r (thunk))
    (printf "OK -> ~a\n" r) (flush-output)))

(try "void-callout (no cb)"     (lambda () (aw_spike_void_noop 5)))
(try "int-callback raw-lambda"  (lambda () (aw_spike_call_int_cb (lambda (x) (* x 2)))))
(try "void-callback raw-lambda" (lambda () (aw_spike_call_void_cb (lambda () (void)))))
(try "int-callback ffi2-callback"
     (lambda () (aw_spike_call_int_cb (ffi2-callback (lambda (x) (* x 2)) (-> int_t int_t)))))
(try "void-callback ffi2-callback"
     (lambda () (aw_spike_call_void_cb (ffi2-callback (lambda () (void)) (-> void_t)))))

(printf "diag3 done.\n") (flush-output)
