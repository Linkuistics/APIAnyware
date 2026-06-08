;; callback.ss — gerbil side of the foreign-thread probe. THROWAWAY.
;; Defines `c-define`d callbacks that do genuine Scheme heap work, and drives one
;; probe stage per process (chosen by argv) so a hard crash isolates that stage.
;; Mirrors the chez callback-thread.ss spike, plus a `concurrent` stage that the
;; chez probe did not need (chez threads are independently registered; single-VM
;; Gambit shares one global heap, so concurrency is the real hazard here).
(import :std/foreign)
(export main)

(begin-ffi (probe-direct probe-pthread probe-gcd
            probe-concurrent-start worker-done?)
  (c-declare "extern void probe_direct(void);")
  (c-declare "extern void probe_pthread(void);")
  (c-declare "extern void probe_gcd(void);")
  (c-declare "extern void probe_concurrent_start(void);")
  (c-declare "extern int  worker_is_done(void);")

  ;; serialized-stage callback: ~100k pairs (forces pstate access + GC)
  (c-define (probe-cb) () void "aw_probe_cb" ""
    (let loop ((i 0) (acc '()))
      (if (##fx< i 100000)
        (loop (##fx+ i 1) (cons i acc))
        (begin
          (display "  [SCM] callback ran; list length=")
          (display (length acc))
          (newline)))))

  ;; concurrent-stage worker callback: ~2M pairs, run on a GCD thread WHILE the
  ;; main thread also allocates. Both bump the same global hp → race/GC hazard.
  (c-define (worker-cb) () void "aw_worker_cb" ""
    (let loop ((i 0) (acc '()))
      (if (##fx< i 2000000)
        (loop (##fx+ i 1) (cons i acc))
        (void))))

  (define-c-lambda probe-direct  () void "probe_direct();")
  (define-c-lambda probe-pthread () void "probe_pthread();")
  (define-c-lambda probe-gcd     () void "probe_gcd();")
  (define-c-lambda probe-concurrent-start () void "probe_concurrent_start();")
  (define-c-lambda worker-done?  () bool "___return(worker_is_done());"))

;; Main thread heap hammer: allocate ~20M pairs in chunks, polling the worker.
(def (concurrent-main-hammer)
  (let outer ((k 0))
    (cond
      ((worker-done?) (displayln "  [SCM] worker finished (main still hammering at k=" k ")"))
      ((##fx< k 400)
       (let loop ((i 0) (acc '()))
         (if (##fx< i 100000) (loop (##fx+ i 1) (cons i acc)) (void)))
       (outer (##fx+ k 1)))
      (else
       ;; main done its budget; bounded spin for the worker so we never hang
       (let spin ((s 0))
         (cond ((worker-done?) (displayln "  [SCM] worker finished (main exhausted budget)"))
               ((##fx< s 100000000) (spin (##fx+ s 1)))
               (else (displayln "  [SCM] gave up waiting for worker (no crash, but stalled)"))))))))

(def (main . args)
  (let (stage (if (pair? args) (car args) "direct"))
    (displayln "stage=" stage)
    (cond
      ((equal? stage "direct")     (probe-direct))
      ((equal? stage "pthread")    (probe-pthread))
      ((equal? stage "gcd")        (probe-gcd))
      ((equal? stage "concurrent") (probe-concurrent-start) (concurrent-main-hammer))
      (else (displayln "unknown stage")))
    (displayln "stage=" stage " : scheme reached end")))
