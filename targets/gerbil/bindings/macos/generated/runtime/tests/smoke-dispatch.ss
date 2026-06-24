;;; runtime/tests/smoke-dispatch.ss — leaf 080/020 smoke (threading / ADR-0022).
;;;
;;; The background-callback test: a Gerbil proc wrapped as an ObjC block is
;;; invoked from REAL GCD worker threads (clang harness smoke_dispatch.c), under
;;; a live main run loop. ADR-0022's main-thread bounce must make every such
;;; off-main invocation land back on the main thread before any Scheme runs —
;;; otherwise the single-VM Gambit heap corrupts (the spike measured 30/30
;;; crashes for direct concurrent entry). Gerbil analogue of chez
;;; tests/smoke-dispatch.sls test 4.
;;;
;;; The harness calls (dispatch/CFRunLoop/^blocks) live in the clang companion;
;;; this gcc-15 unit only extern-declares + calls them. Links smoke_dispatch.o
;;; AND native_block.o (run-smokes.sh).

(export main)
(import :std/foreign
        :gerbil-bindings/runtime/ffi
        :gerbil-bindings/runtime/objc)

(begin-ffi (smoke-fire smoke-done smoke-on-main smoke-pump smoke-reset)
  (c-declare "extern void aw_smoke_fire(void*,int);")
  (c-declare "extern int  aw_smoke_done(void);")
  (c-declare "extern int  aw_smoke_on_main(void);")
  (c-declare "extern void aw_smoke_pump(double);")
  (c-declare "extern void aw_smoke_reset(void);")
  (define-c-lambda smoke-fire ((pointer void) int) void "aw_smoke_fire(___arg1, ___arg2);")
  (define-c-lambda smoke-done () int "___return(aw_smoke_done());")
  (define-c-lambda smoke-on-main () bool "___return(aw_smoke_on_main());")
  (define-c-lambda smoke-pump (double) void "aw_smoke_pump(___arg1);")
  (define-c-lambda smoke-reset () void "aw_smoke_reset();"))

(def *cb-count* 0)     ; bumped by the callback — ON MAIN, so race-free
(def *off-main* 0)     ; bumped if a callback ever runs off the main thread

(def (callback)
  (unless (smoke-on-main) (set! *off-main* (##fx+ *off-main* 1)))
  ;; real Scheme heap work — this is what corrupts if it runs off-main while the
  ;; main thread also allocates (the hazard the bounce removes).
  (let loop ((i 0) (acc '()))
    (if (##fx< i 5000) (loop (##fx+ i 1) (cons i acc)) (void)))
  (set! *cb-count* (##fx+ *cb-count* 1)))

(def failures 0)
(def (check tag ok?)
  (displayln (if ok? "  ok   " "  FAIL ") tag)
  (unless ok? (set! failures (##fx+ failures 1))))

(def (main . _)
  (let* ((n 500)
         (blk (make-objc-block callback '() 'void)))
    (smoke-reset)
    (set! *cb-count* 0) (set! *off-main* 0)
    (displayln "firing " n " background callbacks through the ADR-0022 bounce...")
    (smoke-fire blk n)
    ;; pump the main run loop until every callback has bounced + run (or timeout)
    (let loop ((waited 0.0))
      (cond
        ((##fx>= *cb-count* n) (void))
        ((> waited 30.0) (void))
        (else (smoke-pump 0.05) (loop (+ waited 0.05)))))
    (displayln "   ran=" *cb-count* "/" n
               "  off-main=" *off-main*
               "  worker-returns=" (smoke-done))
    (check "all background callbacks ran" (##fx= *cb-count* n))
    (check "every callback landed on the main thread (bounce held)" (##fx= *off-main* 0))
    (check "all worker invocations returned (no deadlock/crash)" (##fx= (smoke-done) n))
    (displayln (if (##fxzero? failures) "DISPATCH-OK" "DISPATCH-FAIL"))))
