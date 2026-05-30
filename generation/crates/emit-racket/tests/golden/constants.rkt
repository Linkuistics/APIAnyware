#lang racket/base
;; Generated constant definitions for TestKit

(require ffi/unsafe
         ffi/unsafe/objc
         (rename-in racket/contract [-> c->]))

(provide/contract
  [TKVersionString cpointer?]
  [TKDefaultTimeout real?]
  [TKStatusAttribute (or/c cpointer? #f)]
  )

(define _fw-lib (ffi-lib "/System/Library/Frameworks/TestKit.framework/TestKit"))

;; CFSTR macro constant support
(define _cfstr-lib (ffi-lib "/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation"))
(define _cfstr-create (get-ffi-obj 'CFStringCreateWithCString _cfstr-lib
                                   (_fun _pointer _string _uint32 -> _pointer)))
(define (_make-cfstr s) (_cfstr-create #f s #x08000100))

(define TKVersionString (get-ffi-obj 'TKVersionString _fw-lib _id))
(define TKDefaultTimeout (get-ffi-obj 'TKDefaultTimeout _fw-lib _double))
(define TKStatusAttribute (_make-cfstr "TKStatus"))
