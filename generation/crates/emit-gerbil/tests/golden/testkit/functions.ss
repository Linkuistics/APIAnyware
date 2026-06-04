;;; Generated C function bindings for TestKit — do not edit
(import :std/foreign)
(export
  TKComputeDistance
  TKTransformPoint
  TKReset
  TKCreateBuffer
  TKGetName
  TKRegisterCallback
  )

(begin-ffi (
            TKComputeDistance
            TKTransformPoint
            TKReset
            TKCreateBuffer
            TKGetName
            TKRegisterCallback
            )
  (c-declare "#include <CoreGraphics/CGGeometry.h>")
  (c-define-type CGPoint (struct "CGPoint"))
  (c-declare "extern double TKComputeDistance(double, double);")
  (c-declare "extern struct CGPoint TKTransformPoint(struct CGPoint);")
  (c-declare "extern void TKReset(void);")
  (c-declare "extern void * TKCreateBuffer(void *, unsigned int);")
  (c-declare "extern const char * TKGetName(unsigned int);")
  (c-declare "extern void TKRegisterCallback(void *, void *);")

  (define-c-lambda TKComputeDistance (double double) double "TKComputeDistance")
  (define-c-lambda TKTransformPoint (CGPoint) CGPoint "TKTransformPoint")
  (define-c-lambda TKReset () void "TKReset")
  (define-c-lambda TKCreateBuffer ((pointer void) unsigned-int32) (pointer void) "TKCreateBuffer")
  (define-c-lambda TKGetName (unsigned-int32) char-string "TKGetName")
  (define-c-lambda TKRegisterCallback ((pointer void) (pointer void)) void "TKRegisterCallback")
  )
