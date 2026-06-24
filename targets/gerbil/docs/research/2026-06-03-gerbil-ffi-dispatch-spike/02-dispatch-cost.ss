;;; Spike item 2: runtime dispatch cost (settles Q1, axis 1).
;;; Measures, per call, in a tight Scheme loop:
;;;   nop    — bare define-c-lambda crossing floor (C fn returns a constant)
;;;   direct — inline-cast objc_msgSend for -[NSString length] (chez ADR-0015 shape)
;;;   shim   — same msgSend routed through a separate C shim fn (ADR-0015's "extra hop")
;;; A monotonic ns clock (clock_gettime) via FFI removes Scheme-clock noise.

(import :std/foreign)
(export main)

(begin-ffi (now-ns objc_getClass sel_registerName ns-of len-direct len-shim nop)

  (c-declare "#include <objc/runtime.h>")
  (c-declare "#include <objc/message.h>")
  (c-declare "#include <time.h>")
  ;; NB: NO <Foundation/Foundation.h> — it is ObjC and gsc compiles this as C.
  ;; NSUInteger is just `unsigned long`.
  (c-declare "typedef unsigned long NSUInteger;")

  ;; --- timer ---
  (define-c-lambda now-ns () unsigned-int64
    "struct timespec ts; clock_gettime(CLOCK_MONOTONIC, &ts);
     ___return((___U64)ts.tv_sec * 1000000000ULL + (___U64)ts.tv_nsec);")

  ;; --- libobjc primitives ---
  (define-c-lambda objc_getClass (char-string) (pointer void) "objc_getClass")
  (define-c-lambda sel_registerName (char-string) (pointer void) "sel_registerName")

  ;; make an NSString once: +[NSString stringWithUTF8String:]
  (define-c-lambda ns-of (char-string) (pointer void)
    "Class c = objc_getClass(\"NSString\");
     SEL s = sel_registerName(\"stringWithUTF8String:\");
     id r = ((id (*)(id, SEL, const char *))objc_msgSend)((id)c, s, ___arg1);
     ___return(r);")

  ;; (a) DIRECT: inline-cast msgSend for -[NSString length]
  (define-c-lambda len-direct ((pointer void) (pointer void)) unsigned-int
    "___return( (unsigned)((NSUInteger (*)(id, SEL))objc_msgSend)((id)___arg1, (SEL)___arg2) );")

  ;; (b) SHIM: msgSend behind a separate C function (simulates a native-lib entry)
  (c-declare "static NSUInteger aw_len(id o, SEL s){
                return ((NSUInteger (*)(id, SEL))objc_msgSend)(o, s); }")
  (define-c-lambda len-shim ((pointer void) (pointer void)) unsigned-int
    "___return( (unsigned) aw_len((id)___arg1, (SEL)___arg2) );")

  ;; (c) NOP: bare crossing floor
  (define-c-lambda nop () unsigned-int "___return(0);"))

(def (bench name iters thunk)
  ;; warm up
  (let loop ((i 0) (acc 0)) (when (##fx< i 1000000) (loop (##fx+ i 1) (##fx+ acc (thunk)))))
  (let* ((t0 (now-ns))
         (acc (let loop ((i 0) (acc 0))
                (if (##fx< i iters) (loop (##fx+ i 1) (##fx+ acc (thunk))) acc)))
         (dt (- (now-ns) t0)))
    (displayln name ": " iters " calls, " dt " ns total, "
               (/ (exact->inexact dt) iters) " ns/call  (checksum " acc ")")))

(def (main . _)
  (let* ((str (ns-of "the quick brown fox"))   ; length 19
         (sel (sel_registerName "length"))
         (n   30000000))
    (displayln "NSString length via direct call = " (len-direct str sel))
    (bench "nop   " n (lambda () (nop)))
    (bench "direct" n (lambda () (len-direct str sel)))
    (bench "shim  " n (lambda () (len-shim str sel)))))
