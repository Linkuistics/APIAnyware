#lang racket/base
;; diag.rkt — isolate the ffi2-main "#f not a procedure" anomaly. THROWAWAY.
(require ffi/unsafe
         (rename-in ffi2 [-> ffi2->])
         racket/runtime-path)

(define-runtime-path libspike-path "libspike.dylib")
(define lib-str (path->string libspike-path))
(define spike-ffi2 (ffi2-lib lib-str))
(define-ffi2-definer define-spike2 #:lib spike-ffi2)

(define-spike2 aw_spike_call_on_main    (ffi2-> ptr_t void_t))
(define-spike2 aw_spike_call_on_pthread (ffi2-> ptr_t void_t))
(define-spike2 aw_spike_call_on_gcd     (ffi2-> ptr_t void_t))

(printf "main    proc? ~a\n" (procedure? aw_spike_call_on_main))
(printf "pthread proc? ~a\n" (procedure? aw_spike_call_on_pthread))
(printf "gcd     proc? ~a\n" (procedure? aw_spike_call_on_gcd))

(define fired (box #f))
(define cb (ffi2-callback (lambda () (set-box! fired 'yes) (printf "  CALLBACK FIRED on main\n")) (ffi2-> void_t)))
(printf "cb = ~a   (ptr_t? ~a)\n" cb (ptr_t? cb))

(printf "calling aw_spike_call_on_main...\n")
(flush-output)
(aw_spike_call_on_main cb)
(printf "returned OK, fired=~a\n" (unbox fired))
(flush-output)
