;;; runtime/tests/smoke-geometry.ss — leaf 050/040 geometry-struct smoke.
;;;
;;; Proves the emitter's by-value geometry-struct tags (FINDINGS §4, ADR-0020)
;;; round-trip through Gambit's struct ABI end-to-end, the way emit_class emits
;;; them: a `begin-ffi` block declaring the `(c-define-type <Tok> (struct
;;; "<tag>"))` for each geometry token + the matching header `#include`, then
;;; `define-c-lambda`s that take/return the struct **by value**. arm64 returns a
;;; 4-double CGRect via the x8 hidden pointer; the plain C cast on objc_msgSend
;;; handles it (FINDINGS §4) — this smoke is the gsc-level confirmation the
;;; node-040 contract called for.
;;;
;;; Scope: the **CoreGraphics** tokens (CGRect/CGPoint/CGSize/CGVector/
;;; CGAffineTransform) only — their headers are plain-C-safe, so this smoke runs
;;; on the existing gcc-15 gxc path with no special compiler mode. The
;;; NS-prefixed / affine tokens (NSRange, NSEdgeInsets, NSDirectionalEdgeInsets,
;;; NSAffineTransformStruct) need `-x objective-c` (their Foundation/AppKit
;;; headers are not C-safe); their tag+header spellings are compile-verified at
;;; 050/040 by a standalone `cc -x objective-c` probe, and the build wiring that
;;; selects clang for those modules is the node-055 umbrella-header decision.
;;;
;;; CLI smoke only; VM-verify of real apps is node 070/090.

(export main)
(import :std/foreign
        :gerbil-bindings/runtime/ffi
        :gerbil-bindings/runtime/objc)

;; The geometry begin-ffi block, byte-for-byte the shape emit_class's
;; `emit_ffi_block` emits for the CoreGraphics tokens (headers + c-define-types),
;; plus the per-field accessors + constructors the smoke drives them with.
(begin-ffi (cg-make-rect cgrect-x cgrect-y cgrect-w cgrect-h
            cg-make-point cgpoint-x cgpoint-y
            cg-make-size cgsize-w cgsize-h
            cg-make-vector cgvector-dx cgvector-dy
            cg-make-affine cgaffine-a cgaffine-tx
            screen-frame)
  (c-declare "#include <objc/runtime.h>")
  (c-declare "#include <objc/message.h>")
  (c-declare "#include <stdint.h>")
  (c-declare "#include <CoreGraphics/CGGeometry.h>")
  (c-declare "#include <CoreGraphics/CGAffineTransform.h>")
  ;; The emitter's exact c-define-types (emit_ffi_block).
  (c-define-type CGRect (struct "CGRect"))
  (c-define-type CGPoint (struct "CGPoint"))
  (c-define-type CGSize (struct "CGSize"))
  (c-define-type CGVector (struct "CGVector"))
  (c-define-type CGAffineTransform (struct "CGAffineTransform"))

  ;; --- CGRect: by-value return + by-value arg (the >16-byte x8 path) -------
  (define-c-lambda cg-make-rect (double double double double) CGRect
    "CGRect r = CGRectMake(___arg1, ___arg2, ___arg3, ___arg4); ___return(r);")
  (define-c-lambda cgrect-x (CGRect) double "___return(___arg1.origin.x);")
  (define-c-lambda cgrect-y (CGRect) double "___return(___arg1.origin.y);")
  (define-c-lambda cgrect-w (CGRect) double "___return(___arg1.size.width);")
  (define-c-lambda cgrect-h (CGRect) double "___return(___arg1.size.height);")

  ;; --- CGPoint / CGSize: 16-byte structs (register pair) -------------------
  (define-c-lambda cg-make-point (double double) CGPoint
    "CGPoint p = CGPointMake(___arg1, ___arg2); ___return(p);")
  (define-c-lambda cgpoint-x (CGPoint) double "___return(___arg1.x);")
  (define-c-lambda cgpoint-y (CGPoint) double "___return(___arg1.y);")
  (define-c-lambda cg-make-size (double double) CGSize
    "CGSize s = CGSizeMake(___arg1, ___arg2); ___return(s);")
  (define-c-lambda cgsize-w (CGSize) double "___return(___arg1.width);")
  (define-c-lambda cgsize-h (CGSize) double "___return(___arg1.height);")

  ;; --- CGVector ------------------------------------------------------------
  (define-c-lambda cg-make-vector (double double) CGVector
    "CGVector v = CGVectorMake(___arg1, ___arg2); ___return(v);")
  (define-c-lambda cgvector-dx (CGVector) double "___return(___arg1.dx);")
  (define-c-lambda cgvector-dy (CGVector) double "___return(___arg1.dy);")

  ;; --- CGAffineTransform: 6-double struct (a..tx) --------------------------
  (define-c-lambda cg-make-affine (double double) CGAffineTransform
    "CGAffineTransform t = CGAffineTransformMakeTranslation(___arg1, ___arg2);
     ___return(t);")
  (define-c-lambda cgaffine-a (CGAffineTransform) double "___return(___arg1.a);")
  (define-c-lambda cgaffine-tx (CGAffineTransform) double "___return(___arg1.tx);")

  ;; --- a REAL objc_msgSend struct return: -[NSScreen frame] ----------------
  ;; The exact crossing shape emit_class emits for a CGRect-returning method.
  ;; Headless mainScreen may be nil → msgSend to nil yields a zero rect (no
  ;; crash); we only assert the struct-return path itself is sound.
  (define-c-lambda screen-frame () CGRect
    "id (*cls)(id,SEL)=(id(*)(id,SEL))objc_msgSend;
     id scr = cls((id)objc_getClass(\"NSScreen\"), sel_registerName(\"mainScreen\"));
     CGRect (*frame)(id,SEL)=(CGRect(*)(id,SEL))objc_msgSend;
     ___return(scr ? frame(scr, sel_registerName(\"frame\"))
                   : CGRectMake(0,0,0,0));"))

(def failures 0)
(def (check tag ok?)
  (displayln (if ok? "  ok   " "  FAIL ") tag)
  (unless ok? (set! failures (##fx+ failures 1))))

(def (about= a b) (< (abs (- a b)) 1e-9))

(def (main . _)
  ;; --- CGRect by-value round-trip (return + arg, >16-byte x8 path) --------
  (let (r (cg-make-rect 1.0 2.0 3.0 4.0))
    (check "CGRect round-trip (origin.x/y, size.w/h)"
           (and (about= (cgrect-x r) 1.0) (about= (cgrect-y r) 2.0)
                (about= (cgrect-w r) 3.0) (about= (cgrect-h r) 4.0))))

  ;; --- CGPoint / CGSize (16-byte register-pair structs) -------------------
  (let (p (cg-make-point 5.0 6.0))
    (check "CGPoint round-trip" (and (about= (cgpoint-x p) 5.0) (about= (cgpoint-y p) 6.0))))
  (let (s (cg-make-size 7.0 8.0))
    (check "CGSize round-trip" (and (about= (cgsize-w s) 7.0) (about= (cgsize-h s) 8.0))))

  ;; --- CGVector -----------------------------------------------------------
  (let (v (cg-make-vector 9.0 10.0))
    (check "CGVector round-trip" (and (about= (cgvector-dx v) 9.0) (about= (cgvector-dy v) 10.0))))

  ;; --- CGAffineTransform (6-double by-value struct) -----------------------
  (let (t (cg-make-affine 11.0 12.0))
    (check "CGAffineTransform round-trip (a=1 identity scale, tx=translation)"
           (and (about= (cgaffine-a t) 1.0) (about= (cgaffine-tx t) 11.0))))

  ;; --- real objc_msgSend CGRect return (emit_class's actual crossing) -----
  (let (f (screen-frame))
    (check "msgSend CGRect return path sound (frame w/h >= 0)"
           (and (>= (cgrect-w f) 0.0) (>= (cgrect-h f) 0.0))))

  (displayln (if (##fxzero? failures) "GEOMETRY-OK" "GEOMETRY-FAIL")))
