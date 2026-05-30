#lang racket/base
;; Generated C function bindings for TestKit

(require ffi/unsafe
         ffi/unsafe/objc
         (rename-in racket/contract [-> c->])
         "../../runtime/type-mapping.rkt")

(provide/contract
  [TKComputeDistance (c-> real? real? real?)]
  [TKTransformPoint (c-> any/c any/c)]
  [TKReset (c-> void?)]
  [TKCreateBuffer (c-> cpointer? exact-nonnegative-integer? (or/c cpointer? #f))]
  [TKGetName (c-> exact-nonnegative-integer? (or/c string? #f))]
  [TKRegisterCallback (c-> (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  )

(define _fw-lib (ffi-lib "/System/Library/Frameworks/TestKit.framework/TestKit"))

(define TKComputeDistance (get-ffi-obj 'TKComputeDistance _fw-lib (_fun _double _double -> _double)))
(define TKTransformPoint (get-ffi-obj 'TKTransformPoint _fw-lib (_fun _NSPoint -> _NSPoint)))
(define TKReset (get-ffi-obj 'TKReset _fw-lib (_fun -> _void)))
(define TKCreateBuffer (get-ffi-obj 'TKCreateBuffer _fw-lib (_fun _id _uint32 -> _pointer)))
(define TKGetName (get-ffi-obj 'TKGetName _fw-lib (_fun _uint32 -> _string)))

; WARNING: callback parameter — _cprocedure invoked from a foreign
;   OS thread (GCD worker, libdispatch) SIGILLs on Racket CS.
;   #:async-apply deadlocks under nsapplication-run.
(define TKRegisterCallback (get-ffi-obj 'TKRegisterCallback _fw-lib (_fun _pointer _pointer -> _void)))
