;; tests/smoke-dispatch.sls — end-to-end smoke check for the chez
;; `dispatch` cluster (block / delegate / dynamic-class bridges).
;;
;; Run from the repository root:
;;   chez --libdirs generation/targets/chez \
;;        --script generation/targets/chez/apianyware/runtime/tests/smoke-dispatch.sls
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

(display "[smoke-dispatch] all tests passed\n")
