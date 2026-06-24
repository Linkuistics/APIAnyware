;;; runtime/tests/smoke-native-bridges.ss — leaf 050/020 smoke.
;;;
;;; Exercises the two ObjC-native-core callback bridges against REAL framework
;;; callbacks (CLI smoke; VM-verify of real apps is node 070/090):
;;;
;;;   - `make-delegate`: a synthesized delegate receives an `-[NSTimer fire]`
;;;     target/action callback (synchronous — no run loop needed) and the Gerbil
;;;     proc runs, receiving the timer wrapped as a bound instance.
;;;   - `make-objc-block`: a block built from a Gerbil proc is invoked by
;;;     `-[NSArray enumerateObjectsUsingBlock:]`, once per element, each arg
;;;     marshalled per its FFI token (object → bound instance, index → integer).
;;;
;;; The bespoke `define-c-lambda`s below are test scaffolding (the hand-written
;;; stand-in for what the emitter generates per method); the bridges themselves
;;; are the runtime under test. Links the clang companion `native_block.o`
;;; (run-smokes.sh) for the block literals.

(export main)
(import :std/foreign
        :gerbil-bindings/runtime/ffi
        :gerbil-bindings/runtime/objc)

;; Bound NSString node (as emit_class emits it) so wrapped callback objects
;; resolve to the exact type and we can read their text back.
(defclass (NSString NSObject) () transparent: #t)
(register-objc-class! (lambda (p) (make-NSString ptr: p)) NSString::t "NSString" "NSObject")

;; --- test scaffolding: framework crossings the smoke drives --------------
(begin-ffi (make-timer fire-timer make-test-array array-enumerate)
  (c-declare "#include <objc/runtime.h>")
  (c-declare "#include <objc/message.h>")
  ;; +[NSTimer timerWithTimeInterval:target:selector:userInfo:repeats:]
  (define-c-lambda make-timer
    (double (pointer void) (pointer void) (pointer void) bool) (pointer void)
    "SEL s = sel_registerName(\"timerWithTimeInterval:target:selector:userInfo:repeats:\");
     id (*send)(Class,SEL,double,id,SEL,id,signed char) =
       (id (*)(Class,SEL,double,id,SEL,id,signed char))objc_msgSend;
     ___return((void*)send(objc_getClass(\"NSTimer\"), s,
                           ___arg1, (id)___arg2, (SEL)___arg3, (id)___arg4,
                           (signed char)___arg5));")
  ;; -[NSTimer fire] — synchronously invokes the target/action.
  (define-c-lambda fire-timer ((pointer void)) void
    "void (*send)(id,SEL)=(void(*)(id,SEL))objc_msgSend;
     send((id)___arg1, sel_registerName(\"fire\"));")
  ;; an NSMutableArray of two NSStrings.
  (define-c-lambda make-test-array () (pointer void)
    "id (*nw)(id,SEL)=(id(*)(id,SEL))objc_msgSend;
     id arr = nw(nw((id)objc_getClass(\"NSMutableArray\"), sel_registerName(\"alloc\")),
                 sel_registerName(\"init\"));
     void (*add)(id,SEL,id)=(void(*)(id,SEL,id))objc_msgSend;
     id (*sw)(Class,SEL,const char*)=(id(*)(Class,SEL,const char*))objc_msgSend;
     SEL ssw = sel_registerName(\"stringWithUTF8String:\");
     Class sc = objc_getClass(\"NSString\");
     add(arr, sel_registerName(\"addObject:\"), sw(sc, ssw, \"alpha\"));
     add(arr, sel_registerName(\"addObject:\"), sw(sc, ssw, \"beta\"));
     ___return((void*)arr);")
  ;; -[NSArray enumerateObjectsUsingBlock:]
  (define-c-lambda array-enumerate ((pointer void) (pointer void)) void
    "void (*send)(id,SEL,id)=(void(*)(id,SEL,id))objc_msgSend;
     send((id)___arg1, sel_registerName(\"enumerateObjectsUsingBlock:\"), (id)___arg2);"))

(def failures 0)
(def (check tag ok?)
  (displayln (if ok? "  ok   " "  FAIL ") tag)
  (unless ok? (set! failures (##fx+ failures 1))))

(def (main . _)
  (with-autorelease-pool
   ;; --- make-delegate: NSTimer fire -> Gerbil proc -----------------------
   (let ((fired #f)
         (got-timer #f))
     (let* ((delegate
             (make-delegate
              ;; (selector proc (param-token …) return-token) — as emit_protocol
              ;; bakes from the IR. timerFired: takes one object (the timer).
              (list (list "timerFired:"
                          (lambda (timer)
                            (set! fired #t)
                            (set! got-timer (NSObject? timer)))
                          (list 'object)           ; the timer is an ObjC object → wrapped
                          'void))))
            (timer (make-timer 0.0 (->ptr delegate)
                               (sel-register "timerFired:") (null-ptr) #f)))
       (check "delegate instance is a bound object" (NSObject? delegate))
       (fire-timer timer)
       (check "delegate proc ran on NSTimer fire" fired)
       (check "callback arg wrapped to a bound instance" got-timer)))

   ;; --- make-objc-block: NSArray enumerate -> Gerbil proc ----------------
   (let ((seen '()))
     (let ((block (make-objc-block
                   (lambda (obj idx stop)
                     (set! seen (cons (nsstring->string (->ptr obj)) seen)))
                   ;; block sig: void (^)(id obj, NSUInteger idx, BOOL* stop) —
                   ;; obj is an object (wrapped); stop is a raw BOOL* (passed
                   ;; through, NOT wrapped — that is exactly the crash this
                   ;; object/(pointer void) split prevents).
                   (list 'object 'unsigned-int64 '(pointer void))
                   'void)))
       (array-enumerate (make-test-array) block)
       (check "block ran for every element" (= (length seen) 2))
       (check "block received wrapped NSString args"
              (and (member "alpha" seen) (member "beta" seen) #t))))

   ;; --- make-objc-block with #f proc → null block ------------------------
   (check "nil proc yields the null block" (ptr-null? (make-objc-block #f '() 'void)))

   (displayln (if (##fxzero? failures) "BRIDGES-OK" "BRIDGES-FAIL"))))
