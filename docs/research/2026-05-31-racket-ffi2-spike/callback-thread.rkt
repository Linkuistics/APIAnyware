#lang racket/base
;; callback-thread.rkt — spike: does an IDIOMATIC ffi2 callback survive
;; invocation from a non-main OS thread, where today's _cprocedure SIGILLs on
;; Racket CS? (020 §3.7, the biggest unknown). THROWAWAY (leaf 040/010).
;;
;; ffi2's idiom (procedure.html / cairo example): declare the callback PARAMETER
;; as an arrow type in the callout signature and pass the RAW Racket lambda;
;; ffi2 creates + auto-retains the callback for the (synchronous) call's
;; duration. We compare that against today's _cprocedure + function-ptr.
;;
;; Run ONE mode per process (a SIGILL kills the process, so isolate each):
;;   racket callback-thread.rkt <mode>
;; modes: cproc-main cproc-gcd cproc-pthread ffi2-main ffi2-gcd ffi2-pthread

(require ffi/unsafe
         (rename-in ffi2 [-> ffi2->])
         racket/runtime-path)

(define-runtime-path libspike-path "libspike.dylib")
(define lib-str (path->string libspike-path))

(define spike-unsafe (ffi-lib lib-str))
(define spike-ffi2 (ffi2-lib lib-str))
(define-ffi2-definer define-spike2 #:lib spike-ffi2)

(define mode
  (if (>= (vector-length (current-command-line-arguments)) 1)
      (vector-ref (current-command-line-arguments) 0)
      "cproc-main"))

(define hit (box #f))

;; OLD way: _cprocedure + function-ptr (ffi/unsafe). Returns an fpointer.
(define (make-cproc-cb)
  (function-ptr (lambda () (set-box! hit 'cproc) (void))
                (_cprocedure '() _void)))

;; NEW way (idiomatic): just a Racket procedure; ffi2 wraps it because the
;; callout parameter is declared as the arrow type (ffi2-> void_t).
(define (ffi2-cb-proc) (set-box! hit 'ffi2) (void))

;; invokers — ffi/unsafe variants take a raw _fpointer; ffi2 variants declare
;; the parameter as a callback arrow type and accept a raw Racket procedure.
(define call-main/unsafe    (get-ffi-obj "aw_spike_call_on_main"    spike-unsafe (_fun _fpointer -> _void)))
(define call-gcd/unsafe     (get-ffi-obj "aw_spike_call_on_gcd"     spike-unsafe (_fun _fpointer -> _void)))
(define call-pthread/unsafe (get-ffi-obj "aw_spike_call_on_pthread" spike-unsafe (_fun _fpointer -> _void)))

(define-spike2 aw_spike_call_on_main    (ffi2-> (ffi2-> void_t) void_t))
(define-spike2 aw_spike_call_on_gcd     (ffi2-> (ffi2-> void_t) void_t))
(define-spike2 aw_spike_call_on_pthread (ffi2-> (ffi2-> void_t) void_t))

(printf "mode=~a starting...\n" mode)
(flush-output)

(case mode
  [("cproc-main")    (call-main/unsafe    (make-cproc-cb))]
  [("cproc-gcd")     (call-gcd/unsafe     (make-cproc-cb))]
  [("cproc-pthread") (call-pthread/unsafe (make-cproc-cb))]
  [("ffi2-main")     (aw_spike_call_on_main    ffi2-cb-proc)]
  [("ffi2-gcd")      (aw_spike_call_on_gcd     ffi2-cb-proc)]
  [("ffi2-pthread")  (aw_spike_call_on_pthread ffi2-cb-proc)]
  [else (error 'callback-thread "unknown mode ~a" mode)])

(printf "mode=~a hit=~a EXIT-OK\n" mode (unbox hit))
(flush-output)
