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
;;; Two scopes, both on the default gcc-15 gxc path (ADR-0021 — no `-x
;;; objective-c`, no umbrella `#include`):
;;;   - the **CoreGraphics** tokens (CGRect/CGPoint/CGSize/CGVector/
;;;     CGAffineTransform), whose headers are plain-C-safe, so emit_class
;;;     `#include`s them directly;
;;;   - the four **NS-prefixed** tokens (NSRange, NSEdgeInsets,
;;;     NSDirectionalEdgeInsets, NSAffineTransformStruct), whose Foundation/AppKit
;;;     headers are NOT C-safe — so emit_class emits an **inline plain-C tagged
;;;     struct** instead (`geometry_decl`'s `InlineStruct`; `CGFloat`→`double`,
;;;     `NSUInteger`→`unsigned long`), keeping the `(c-define-type Tok (struct
;;;     "tag"))` crossing. This block declares those four structs byte-for-byte as
;;;     the emitter does and round-trips each by value, proving they compile + are
;;;     ABI-exact under the default compiler (055/020, superseding 050/040's note
;;;     that they needed clang).
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

;; The NS-prefixed geometry structs (ADR-0021): emit_class declares each as an
;; INLINE plain-C tagged struct — byte-for-byte `geometry_decl`'s `InlineStruct`
;; spelling — never the non-C-safe Foundation/AppKit header, so this block
;; compiles on the same default gcc-15 path. SDK-verified layouts: `_NSRange`
;; {unsigned long location,length}; NSEdgeInsets {double top,left,bottom,right};
;; NSDirectionalEdgeInsets {double top,leading,bottom,trailing};
;; NSAffineTransformStruct {double m11,m12,m21,m22,tX,tY}.
(begin-ffi (ns-make-range nsrange-loc nsrange-len
            ns-make-edge nsedge-top nsedge-left nsedge-bottom nsedge-right
            ns-make-diredge nsdiredge-top nsdiredge-leading nsdiredge-bottom nsdiredge-trailing
            ns-make-affine nsaffine-m11 nsaffine-tx nsaffine-ty)
  (c-declare "struct _NSRange { unsigned long location; unsigned long length; };")
  (c-declare "struct NSEdgeInsets { double top; double left; double bottom; double right; };")
  (c-declare "struct NSDirectionalEdgeInsets { double top; double leading; double bottom; double trailing; };")
  (c-declare "struct NSAffineTransformStruct { double m11; double m12; double m21; double m22; double tX; double tY; };")
  (c-define-type NSRange (struct "_NSRange"))
  (c-define-type NSEdgeInsets (struct "NSEdgeInsets"))
  (c-define-type NSDirectionalEdgeInsets (struct "NSDirectionalEdgeInsets"))
  (c-define-type NSAffineTransformStruct (struct "NSAffineTransformStruct"))

  ;; --- NSRange: two unsigned-long fields (NSUInteger) by value -------------
  (define-c-lambda ns-make-range (unsigned-int64 unsigned-int64) NSRange
    "struct _NSRange r; r.location = ___arg1; r.length = ___arg2; ___return(r);")
  (define-c-lambda nsrange-loc (NSRange) unsigned-int64 "___return(___arg1.location);")
  (define-c-lambda nsrange-len (NSRange) unsigned-int64 "___return(___arg1.length);")

  ;; --- NSEdgeInsets: four doubles -----------------------------------------
  (define-c-lambda ns-make-edge (double double double double) NSEdgeInsets
    "struct NSEdgeInsets e; e.top=___arg1; e.left=___arg2; e.bottom=___arg3; e.right=___arg4; ___return(e);")
  (define-c-lambda nsedge-top (NSEdgeInsets) double "___return(___arg1.top);")
  (define-c-lambda nsedge-left (NSEdgeInsets) double "___return(___arg1.left);")
  (define-c-lambda nsedge-bottom (NSEdgeInsets) double "___return(___arg1.bottom);")
  (define-c-lambda nsedge-right (NSEdgeInsets) double "___return(___arg1.right);")

  ;; --- NSDirectionalEdgeInsets: top/leading/bottom/trailing ---------------
  (define-c-lambda ns-make-diredge (double double double double) NSDirectionalEdgeInsets
    "struct NSDirectionalEdgeInsets e; e.top=___arg1; e.leading=___arg2; e.bottom=___arg3; e.trailing=___arg4; ___return(e);")
  (define-c-lambda nsdiredge-top (NSDirectionalEdgeInsets) double "___return(___arg1.top);")
  (define-c-lambda nsdiredge-leading (NSDirectionalEdgeInsets) double "___return(___arg1.leading);")
  (define-c-lambda nsdiredge-bottom (NSDirectionalEdgeInsets) double "___return(___arg1.bottom);")
  (define-c-lambda nsdiredge-trailing (NSDirectionalEdgeInsets) double "___return(___arg1.trailing);")

  ;; --- NSAffineTransformStruct: 6 doubles (m11..tY) -----------------------
  (define-c-lambda ns-make-affine (double double double double double double) NSAffineTransformStruct
    "struct NSAffineTransformStruct t; t.m11=___arg1; t.m12=___arg2; t.m21=___arg3; t.m22=___arg4; t.tX=___arg5; t.tY=___arg6; ___return(t);")
  (define-c-lambda nsaffine-m11 (NSAffineTransformStruct) double "___return(___arg1.m11);")
  (define-c-lambda nsaffine-tx (NSAffineTransformStruct) double "___return(___arg1.tX);")
  (define-c-lambda nsaffine-ty (NSAffineTransformStruct) double "___return(___arg1.tY);"))

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

  ;; --- NS-prefixed structs via inline plain-C typedefs (ADR-0021) ---------
  (let (r (ns-make-range 3 7))
    (check "NSRange (_NSRange) round-trip (location/length, unsigned long)"
           (and (= (nsrange-loc r) 3) (= (nsrange-len r) 7))))
  (let (e (ns-make-edge 1.0 2.0 3.0 4.0))
    (check "NSEdgeInsets round-trip (top/left/bottom/right)"
           (and (about= (nsedge-top e) 1.0) (about= (nsedge-left e) 2.0)
                (about= (nsedge-bottom e) 3.0) (about= (nsedge-right e) 4.0))))
  (let (d (ns-make-diredge 5.0 6.0 7.0 8.0))
    (check "NSDirectionalEdgeInsets round-trip (top/leading/bottom/trailing)"
           (and (about= (nsdiredge-top d) 5.0) (about= (nsdiredge-leading d) 6.0)
                (about= (nsdiredge-bottom d) 7.0) (about= (nsdiredge-trailing d) 8.0))))
  (let (t (ns-make-affine 1.0 0.0 0.0 1.0 9.0 10.0))
    (check "NSAffineTransformStruct round-trip (m11 identity, tX/tY translation)"
           (and (about= (nsaffine-m11 t) 1.0) (about= (nsaffine-tx t) 9.0)
                (about= (nsaffine-ty t) 10.0))))

  (displayln (if (##fxzero? failures) "GEOMETRY-OK" "GEOMETRY-FAIL")))
