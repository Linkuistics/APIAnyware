;; callback-thread.ss — foreign-thread callback probe harness. THROWAWAY.
;;
;; Run from this directory:  chez --script callback-thread.ss <stage>
;; <stage> in {direct, pthread, gcd}. Run each in a SEPARATE process so a crash
;; in one stage does not mask the others; the last printed line before a crash
;; tells us where Chez died.

(import (chezscheme))
(load-shared-object "./libthreadprobe.dylib")

(define probe-direct      (foreign-procedure "probe_call_direct"            (void*) void))
(define probe-pthread     (foreign-procedure "probe_call_pthread"           (void*) void))
(define probe-pthread-act (foreign-procedure "probe_call_pthread_activated" (void*) void))
(define probe-gcd         (foreign-procedure "probe_call_gcd_async"         (void*) void))
(define probe-gcd-act     (foreign-procedure "probe_call_gcd_async_activated" (void*) void))

(printf "threaded? = ~a\n" (threaded?))
(flush-output-port (current-output-port))

(define hits 0)
(define cb
  (foreign-callable
    (lambda ()
      ;; A trivial bit of real Scheme work: allocate + mutate (touches the heap,
      ;; so an unactivated thread will fault here if anywhere).
      (set! hits (+ hits 1))
      (let ([v (make-vector 4 'x)]) (vector-set! v 0 hits)))
    () void))
(lock-object cb)
(define cb-ptr (foreign-callable-entry-point cb))

(define stage (if (>= (length (command-line-arguments)) 1)
                  (car (command-line-arguments)) "direct"))

(printf "stage=~a : calling foreign-callable ...\n" stage)
(flush-output-port (current-output-port))

(case (string->symbol stage)
  [(direct)      (probe-direct      cb-ptr)]
  [(pthread)     (probe-pthread     cb-ptr)]
  [(pthread-act) (probe-pthread-act cb-ptr)]
  [(gcd)         (probe-gcd         cb-ptr)]
  [(gcd-act)     (probe-gcd-act     cb-ptr)]
  [else (error 'probe "unknown stage" stage)])

(printf "stage=~a : SURVIVED. hits=~a\n" stage hits)
(flush-output-port (current-output-port))
