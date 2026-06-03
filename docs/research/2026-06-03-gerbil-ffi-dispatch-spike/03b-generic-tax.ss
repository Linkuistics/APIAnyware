;;; 030 follow-up: price :std/generic dispatch vs built-in {} and proc core.
;;; Same -[NSString length] harness as 03-oo-tax.ss. The OO veneer dispatches on
;;; the RECEIVER only ((length obj)) — the realistic veneer shape, selector baked
;;; into the method — so 030 can pick the veneer's dispatch mechanism on evidence.
;;; BUILD WITH THE BOTTLED gerbil (Cellar), matching the spike's baseline.

(import :std/foreign
        (rename-in :std/generic (defgeneric g:defgeneric) (defmethod g:defmethod)))
(export main)

(begin-ffi (now-ns objc_getClass sel_registerName ns-of len-raw)
  (c-declare "#include <objc/runtime.h>")
  (c-declare "#include <objc/message.h>")
  (c-declare "#include <time.h>")
  (c-declare "typedef unsigned long NSUInteger;")
  (define-c-lambda now-ns () unsigned-int64
    "struct timespec ts; clock_gettime(CLOCK_MONOTONIC, &ts);
     ___return((___U64)ts.tv_sec * 1000000000ULL + (___U64)ts.tv_nsec);")
  (define-c-lambda objc_getClass (char-string) (pointer void) "objc_getClass")
  (define-c-lambda sel_registerName (char-string) (pointer void) "sel_registerName")
  (define-c-lambda ns-of (char-string) (pointer void)
    "Class c = objc_getClass(\"NSString\");
     SEL s = sel_registerName(\"stringWithUTF8String:\");
     ___return( ((id (*)(id, SEL, const char *))objc_msgSend)((id)c, s, ___arg1) );")
  (define-c-lambda len-raw ((pointer void) (pointer void)) unsigned-int
    "___return( (unsigned)((NSUInteger (*)(id, SEL))objc_msgSend)((id)___arg1, (SEL)(void*)___arg2) );"))

;; selector baked in at load (the realistic veneer: (length obj), sel implicit)
(def the-sel (sel_registerName "length"))

;; Procedural CORE: a handle struct + plain procedure
(defstruct objc-obj (ptr) transparent: #t)
(def (nsstring-length o) (len-raw (objc-obj-ptr o) the-sel))

;; OO VENEER A: Gerbil built-in {} method-table dispatch (the spike's 42.9ns path)
(defmethod {mlength objc-obj} (lambda (self) (len-raw (objc-obj-ptr self) the-sel)))

;; OO VENEER B: :std/generic generic-function dispatch (receiver-only)
;; correct :std/generic form: (defmethod (generic (arg type)) body)
(g:defgeneric glength)
(g:defmethod (glength (self objc-obj)) (len-raw (objc-obj-ptr self) the-sel))

(def (bench name iters thunk)
  (let loop ((i 0) (acc 0)) (when (##fx< i 1000000) (loop (##fx+ i 1) (##fx+ acc (thunk)))))
  (let* ((t0 (now-ns))
         (acc (let loop ((i 0) (acc 0))
                (if (##fx< i iters) (loop (##fx+ i 1) (##fx+ acc (thunk))) acc)))
         (dt (- (now-ns) t0)))
    (displayln name ": " (/ (exact->inexact dt) iters) " ns/call  (checksum " acc ")")))

(def (main . _)
  (let* ((p (ns-of "the quick brown fox"))
         (o (make-objc-obj p))
         (n 30000000))
    (displayln "length = " (len-raw p the-sel))
    (bench "raw-ffi (ptr)        " n (lambda () (len-raw p the-sel)))
    (bench "proc over struct     " n (lambda () (nsstring-length o)))
    (bench "builtin {} dispatch  " n (lambda () {mlength o}))
    (bench "std/generic dispatch " n (lambda () (glength o)))))
