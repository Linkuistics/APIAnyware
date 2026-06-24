;; tests/smoke-dispatch.sls — end-to-end smoke check for the chez
;; `dispatch` cluster (block / delegate / dynamic-class bridges).
;;
;; Run from the repository root:
;;   chez --libdirs targets/chez/bindings/macos \
;;        --script targets/chez/bindings/macos/apianyware/runtime/tests/smoke-dispatch.sls
;;
;; Exits 0 on success, raises on failure. Each test prints when it
;; passes so regression localises to the most-recently-printed line.
;;
;; All three demos run inside `define-entry-point` so the autoreleasepool
;; wrap from apianyware/runtime/objc.sls is active during the ObjC callbacks
;; (ADR-0007).

(import (apianyware runtime ffi)
        (apianyware runtime objc)
        (apianyware runtime dispatch))

(define (check who expected actual)
  (unless (equal? expected actual)
    (error who "expected" expected "got" actual)))

;; --- 1. Block bridge: create, validate, free --------------------------
;;
;; Build a block whose invoke signature matches
;; `enumerateObjectsUsingBlock:` (id obj, NSUInteger idx, BOOL *stop) →
;; void. We don't invoke it through a real Cocoa method here — that
;; needs an NSArray-of-ids, which in turn needs msgSend variants the
;; emitter will generate but the runtime doesn't carry. Sample apps
;; exercise the invocation path; here we verify the block can be
;; constructed and torn down without crashing.

(define-entry-point (block-smoke)
  (let ([calls 0])
    (let ([blk
           (make-objc-block
             (lambda (obj idx stop)
               (set! calls (+ calls 1)))
             '(void* unsigned-64 void*)
             'void)])
      (check 'block-record         #t (objc-block? blk))
      (check 'block-ptr-nonzero    #t (and (objc-block-ptr blk)
                                           (not (zero? (objc-block-ptr blk)))))
      (free-objc-block blk)
      ;; Double-free is safe (idempotent).
      (free-objc-block blk))))

(block-smoke)
(display "[smoke-dispatch] 1. Block create+free OK\n")

;; --- 2. Delegate bridge: invocation via performSelector:withObject: ---
;;
;; Build a 1-method delegate, send it a message via
;; NSObject's performSelector:withObject:, and verify our Scheme
;; callback fired. The Swift trampoline (in libAPIAnywareChez)
;; strips self/_cmd, so the handler receives just the single arg.
;;
;; Selector arg is delivered to us as a void* — we don't dereference
;; it (it would be an NSNumber wrapping 42 in this case) because that
;; would require msgSend variants for `intValue`.

(define-entry-point (delegate-smoke)
  (let ([fired?  #f]
        [arg-ptr 0])
    (let ([d (make-delegate
               `(("awSmokeMethod:"
                  ,(lambda (arg)
                     (set! fired? #t)
                     (set! arg-ptr arg)
                     0)
                  (void*)
                  void*)))])
      (check 'delegate-record       #t (delegate? d))
      (check 'delegate-ptr-nonzero  #t (not (zero? (delegate-ptr d))))

      ;; Synthesise an arg that's any non-null pointer so we can verify
      ;; the trampoline forwarded it. NSObject's `class` method returns
      ;; the Class pointer of self — handy and always non-zero.
      (let* ([msgsend4
              (foreign-procedure "objc_msgSend"
                                 (void* void* void* void*) void*)]
             [perform (sel-register "performSelector:withObject:")]
             [sel     (sel-register "awSmokeMethod:")]
             [nsobject-cls (objc_getClass "NSObject")])
        (msgsend4 (delegate-ptr d) perform sel nsobject-cls))

      (check 'delegate-callback-fired #t fired?)
      (check 'delegate-arg-forwarded  #t (not (zero? arg-ptr)))

      ;; set-delegate-method should swap in a new handler.
      (let ([fired-2? #f])
        (set-delegate-method d "awSmokeMethod:"
          (lambda (arg)
            (set! fired-2? #t)
            0)
          '(void*) 'void*)

        (let ([msgsend4
               (foreign-procedure "objc_msgSend"
                                  (void* void* void* void*) void*)]
              [perform (sel-register "performSelector:withObject:")]
              [sel     (sel-register "awSmokeMethod:")])
          (msgsend4 (delegate-ptr d) perform sel
                    (objc_getClass "NSObject")))

        (check 'delegate-method-replaced #t fired-2?))

      (free-delegate d)
      ;; Idempotent.
      (free-delegate d))))

(delegate-smoke)
(display "[smoke-dispatch] 2. Delegate invocation OK\n")

;; --- 3. Dynamic subclass: override fires when ObjC dispatches ---------
;;
;; Build an NSObject subclass with a single custom method, instantiate
;; it via alloc/init, send the method via objc_msgSend, and verify
;; our IMP body ran. This is the same path AppKit takes when calling
;; into a Scheme-defined drawRect: override.

(define-entry-point (subclass-smoke)
  (let ([fired? #f])
    (let* ([nsobject (objc_getClass "NSObject")]
           ;; Our IMP receives (self _cmd) — type encoding "@@:" means
           ;; "returns id, args self+_cmd". We return self so the
           ;; msgSend below has a non-zero result we can sanity-check.
           [cls
            (make-dynamic-subclass nsobject "AWChezSmokeSub"
              `(("awSmokeMark"
                 ,(lambda (self _cmd)
                    (set! fired? #t)
                    self)
                 ()
                 void*
                 "@@:")))])
      (check 'subclass-allocated #t (not (zero? cls)))

      (let* ([alloc-sel (sel-register "alloc")]
             [init-sel  (sel-register "init")]
             [mark-sel  (sel-register "awSmokeMark")]
             [allocated (objc_msgSend cls alloc-sel)]
             [inst      (objc_msgSend allocated init-sel)]
             [result    (objc_msgSend inst mark-sel)])
        (check 'subclass-instance-nonzero #t (not (zero? inst)))
        (check 'subclass-override-fired   #t fired?)
        (check 'subclass-returned-self    inst result))

      ;; Idempotent: a second make-dynamic-subclass with the same name
      ;; returns the existing class without re-allocating.
      (let ([again
             (make-dynamic-subclass nsobject "AWChezSmokeSub" '())])
        (check 'subclass-idempotent cls again)))))

(subclass-smoke)
(display "[smoke-dispatch] 3. Dynamic subclass override OK\n")

;; --- 4. Block invoked on a real background (dispatch_async) thread -----
;;
;; ADR-0016 regression guard. A bare `foreign-callable` entered from a
;; Scheme-unregistered OS thread crashes hard ("nonrecoverable invalid
;; memory reference" — spike FINDINGS.md §C). The `__collect_safe`
;; modifier on `build-callable` activates the calling thread in the
;; callable's C prologue (and destroys a freshly-created thread context
;; on exit, so transient GCD workers don't leak). This test submits a
;; block to the GCD global concurrent queue via `dispatch_async` — a
;; genuine worker thread, not the caller — has the Scheme callback do
;; real heap work, and asserts: it ran, off the main thread, with the
;; right result. Looping many times exercises the no-crash / no-leak
;; claim: a leaked thread context or a guardian race would surface as a
;; crash or hang well before the loop completes.

(define dispatch_get_global_queue
  (foreign-procedure "dispatch_get_global_queue" (long unsigned-long) void*))
(define dispatch_async
  (foreign-procedure "dispatch_async" (void* void*) void))
(define dispatch_semaphore_create
  (foreign-procedure "dispatch_semaphore_create" (long) void*))
(define dispatch_semaphore_signal
  (foreign-procedure "dispatch_semaphore_signal" (void*) long))
;; `__collect_safe` on the BLOCKING wait is mandatory, not cosmetic: it
;; deactivates this (main) thread while it is parked in C. Without it the
;; main thread stays an *active* Scheme thread stuck in a foreign call and
;; never reaches a GC safe point — so when the background callback
;; allocates (make-vector) and triggers a stop-the-world GC, the collector
;; waits on the blocked main thread forever and the whole thing deadlocks.
;; The outbound dual of the inbound callable activation (ADR-0016).
(define dispatch_semaphore_wait
  (foreign-procedure __collect_safe
                     "dispatch_semaphore_wait" (void* unsigned-64) long))

(define DISPATCH_TIME_FOREVER #xFFFFFFFFFFFFFFFF)

;; +[NSThread isMainThread] → BOOL. msgSend returns the BOOL in x0; read
;; as a pointer-width int, 0 = NO, non-zero = YES.
(define (on-main-thread?)
  (not (zero? (objc_msgSend (objc_getClass "NSThread")
                            (sel-register "isMainThread")))))

(define-entry-point (background-block-smoke)
  (let ([iterations 500]
        [queue (dispatch_get_global_queue 0 0)]  ; DEFAULT priority
        [sem   (dispatch_semaphore_create 0)])
    (let loop ([i 0])
      (cond
        [(= i iterations)
         (objc_release sem)
         (check 'background-iterations-done #t #t)]
        [else
         (let ([result   (box #f)]
               [main-flag (box 'unset)])
           ;; void(^)(void): make-objc-block adds the block-self prefix
           ;; internally, so the proc takes no user args.
           (let ([blk
                  (make-objc-block
                    (lambda ()
                      ;; Real Scheme heap allocation + mutation on the
                      ;; worker thread — this is what crashed pre-ADR-0016.
                      (let ([v (make-vector 8 0)])
                        (do ([k 0 (+ k 1)]) ((= k 8))
                          (vector-set! v k (* k k)))
                        (set-box! result (vector-ref v 7)))     ; 7*7 = 49
                      (set-box! main-flag (on-main-thread?))
                      (dispatch_semaphore_signal sem))
                    '()
                    'void)])
             (dispatch_async queue (objc-block-ptr blk))
             (dispatch_semaphore_wait sem DISPATCH_TIME_FOREVER)
             (check 'background-result   49 (unbox result))
             (check 'background-off-main #f (unbox main-flag))
             (free-objc-block blk)
             (loop (+ i 1))))]))))

(background-block-smoke)
(display "[smoke-dispatch] 4. Background dispatch_async callback OK\n")

(display "[smoke-dispatch] all tests passed\n")
