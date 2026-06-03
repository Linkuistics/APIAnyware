;;; Spike item 4: CGRect struct-by-value over the FFI. Load-bearing for AppKit
;;; geometry (-[NSView frame] etc.). Two probes:
;;;   A) construct a CGRect in C, return by value, read fields back (the Gambit
;;;      struct-return ABI question — the core risk)
;;;   B) a real objc_msgSend returning a struct: +[NSValue valueWithBytes:objCType:]
;;;      to box an NSRect, then -[NSValue rectValue] cast to return CGRect by value
;;;      (the msgSend struct-return ABI, arm64 x8 hidden pointer).

(import :std/foreign)
(export main)

(begin-ffi (make-rect rect-x rect-y rect-w rect-h box-rect unbox-rect)
  (c-declare "#include <objc/runtime.h>")
  (c-declare "#include <objc/message.h>")
  (c-declare "#include <CoreGraphics/CGGeometry.h>")    ; C-safe: CGRect/CGFloat/CGRectMake

  (c-define-type CGRect (struct "CGRect"))

  ;; A) construct + return by value; field accessors take CGRect (passed by ref)
  (define-c-lambda make-rect (double double double double) CGRect
    "CGRect r = CGRectMake(___arg1, ___arg2, ___arg3, ___arg4); ___return(r);")
  (define-c-lambda rect-x (CGRect) double "___return(___arg1.origin.x);")
  (define-c-lambda rect-y (CGRect) double "___return(___arg1.origin.y);")
  (define-c-lambda rect-w (CGRect) double "___return(___arg1.size.width);")
  (define-c-lambda rect-h (CGRect) double "___return(___arg1.size.height);")

  ;; B) box an NSRect into an NSValue, then read it back via -rectValue (struct ret)
  (define-c-lambda box-rect (double double double double) (pointer void)
    "CGRect r = CGRectMake(___arg1, ___arg2, ___arg3, ___arg4);
     Class c = objc_getClass(\"NSValue\");
     SEL s = sel_registerName(\"valueWithBytes:objCType:\");
     id v = ((id (*)(id, SEL, const void *, const char *))objc_msgSend)
              ((id)c, s, &r, \"{CGRect={CGPoint=dd}{CGSize=dd}}\");
     ___return(v);")
  (define-c-lambda unbox-rect ((pointer void)) CGRect
    "SEL s = sel_registerName(\"rectValue\");
     CGRect r = ((CGRect (*)(id, SEL))objc_msgSend)((id)___arg1, s);
     ___return(r);"))

(def (show tag r)
  (displayln tag ": x=" (rect-x r) " y=" (rect-y r) " w=" (rect-w r) " h=" (rect-h r)))

(def (main . _)
  (let (r (make-rect 10. 20. 300. 400.))
    (show "A constructed " r)
    (if (and (= (rect-x r) 10.) (= (rect-w r) 300.))
      (displayln "A: PASS — Gambit returns CGRect by value, fields readable")
      (displayln "A: FAIL")))
  (let* ((v  (box-rect 1. 2. 3. 4.))
         (r2 (unbox-rect v)))
    (show "B msgSend     " r2)
    (if (and (= (rect-x r2) 1.) (= (rect-h r2) 4.))
      (displayln "B: PASS — objc_msgSend struct-return (CGRect by value) works")
      (displayln "B: FAIL"))))
