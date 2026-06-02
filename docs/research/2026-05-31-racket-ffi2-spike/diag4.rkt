#lang racket/base
;; diag4.rkt — root-cause probe for the ffi2 void-returning-callback bug.
;; Tries several spellings/options to see if any makes a void callback work.
;; NO ffi/unsafe. THROWAWAY.
(require ffi2 racket/runtime-path)

(define-runtime-path libspike-path "libspike.dylib")
(define spike (ffi2-lib (path->string libspike-path)))
(define-ffi2-definer define-spike #:lib spike)

;; callouts taking a void->void callback, and an int->int callback that ignores
;; result, and one returning int while taking a void callback.
(define-spike aw_spike_call_void_cb (-> (-> void_t) void_t))
(define-spike aw_spike_call_int_cb  (-> (-> int_t int_t) int_t))

(define (try label thunk)
  (printf "~a: " label) (flush-output)
  (with-handlers ([(lambda (_) #t)
                   (lambda (e) (printf "FAIL ~a\n"
                                       (if (exn? e) (car (regexp-split #rx"\n" (exn-message e))) e))
                            (flush-output))])
    (define r (thunk))
    (printf "OK -> ~a\n" r) (flush-output)))

;; A: baseline void callback, lambda returns (void)
(try "A void-cb returns (void)"
     (lambda () (aw_spike_call_void_cb (lambda () (void)))))

;; B: void callback, lambda returns a number (maybe ffi2 wants a value?)
(try "B void-cb returns 0"
     (lambda () (aw_spike_call_void_cb (lambda () 0))))

;; C: void callback, lambda returns (values) (no values)
(try "C void-cb returns (values)"
     (lambda () (aw_spike_call_void_cb (lambda () (values)))))

;; D: explicit ffi2-callback with void_t on a ptr_t-less arrow param — pass it raw
;;    (this is a type error per diag3, but record the message)
(try "D pre-made ffi2-callback void"
     (lambda () (aw_spike_call_void_cb (ffi2-callback (lambda () (void)) (-> void_t)))))

;; E: control — int callback works (sanity)
(try "E int-cb (control)"
     (lambda () (aw_spike_call_int_cb (lambda (x) (* x 2)))))

(printf "diag4 done.\n") (flush-output)
