;;; Spike item 3: OO-layering tax (validates Q2 layering direction).
;;; Prices the OO veneer over a procedural core for -[NSString length]:
;;;   raw-ffi — call the FFI wrapper directly with a raw pointer (no wrapper obj)
;;;   proc    — plain Scheme proc over a handle struct (the procedural CORE layer)
;;;   method  — Gerbil generic method {length o} dispatch (the OO VENEER layer)
;;; The (method - proc) delta is the opt-in dynamic-dispatch tax.

(import :std/foreign)
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

;; Procedural CORE: a handle struct + plain procedures keyed by "class"
(defstruct objc-obj (ptr) transparent: #t)
(def (nsstring-length o sel) (len-raw (objc-obj-ptr o) sel))

;; OO VENEER: a Gerbil generic method dispatching on the handle struct
(defmethod {mlength objc-obj} (lambda (self sel) (len-raw (objc-obj-ptr self) sel)))

(def (bench name iters thunk)
  (let loop ((i 0) (acc 0)) (when (##fx< i 1000000) (loop (##fx+ i 1) (##fx+ acc (thunk)))))
  (let* ((t0 (now-ns))
         (acc (let loop ((i 0) (acc 0))
                (if (##fx< i iters) (loop (##fx+ i 1) (##fx+ acc (thunk))) acc)))
         (dt (- (now-ns) t0)))
    (displayln name ": " (/ (exact->inexact dt) iters) " ns/call  (checksum " acc ")")))

(def (main . _)
  (let* ((p   (ns-of "the quick brown fox"))
         (o   (make-objc-obj p))
         (sel (sel_registerName "length"))
         (n   30000000))
    (displayln "length = " (len-raw p sel))
    (bench "raw-ffi (ptr)      " n (lambda () (len-raw p sel)))
    (bench "proc over struct   " n (lambda () (nsstring-length o sel)))
    (bench "method {} dispatch " n (lambda () {mlength o sel}))))
