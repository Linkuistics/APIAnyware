;; runtime/types.sls — chez target geometry ftypes and value bridging.
;;
;; Scaffold: ftype layouts are real (pure type declarations); bridging
;; bodies are `(error ... "not yet implemented")` stubs. Real bodies land
;; in `.grove/050-chez-target/050-runtime-types-cocoa.md`.
;;
;; Eventually holds:
;;   - NSString / NSArray / NSDictionary marshal helpers
;;   - geometry ftypes (NSPoint, NSSize, NSRect, NSRange, NSEdgeInsets)
;;   - CoreFoundation bridging helpers
;;
;; Layouts target 64-bit macOS: CGFloat = double-float, NSUInteger /
;; NSInteger = (un)signed-64. ftypes replace racket's `define-cstruct`.
;;
;; Absorbs from the racket runtime: type-mapping.rkt, coerce.rkt,
;; cf-bridge.rkt (mechanical port).

(library (apianyware runtime types)
  (export
    NSPoint NSSize NSRect NSRange NSEdgeInsets
    make-nspoint nspoint-x nspoint-y
    make-nssize nssize-width nssize-height
    make-nsrect nsrect-origin nsrect-size
    make-nsrange nsrange-location nsrange-length
    string->nsstring
    nsstring->string
    list->nsarray
    nsarray->list
    hash->nsdictionary
    nsdictionary->hash
    cf-bridge-retain
    cf-bridge-release)
  (import (chezscheme)
          (apianyware runtime ffi)
          (apianyware runtime objc))

  (define-ftype NSPoint
    (struct [x double-float]
            [y double-float]))

  (define-ftype NSSize
    (struct [width double-float]
            [height double-float]))

  (define-ftype NSRect
    (struct [origin NSPoint]
            [size NSSize]))

  (define-ftype NSRange
    (struct [location unsigned-64]
            [length unsigned-64]))

  (define-ftype NSEdgeInsets
    (struct [top double-float]
            [left double-float]
            [bottom double-float]
            [right double-float]))

  (define (make-nspoint x y) (error 'make-nspoint "not yet implemented"))
  (define (nspoint-x p) (error 'nspoint-x "not yet implemented"))
  (define (nspoint-y p) (error 'nspoint-y "not yet implemented"))

  (define (make-nssize w h) (error 'make-nssize "not yet implemented"))
  (define (nssize-width s) (error 'nssize-width "not yet implemented"))
  (define (nssize-height s) (error 'nssize-height "not yet implemented"))

  (define (make-nsrect origin size) (error 'make-nsrect "not yet implemented"))
  (define (nsrect-origin r) (error 'nsrect-origin "not yet implemented"))
  (define (nsrect-size r) (error 'nsrect-size "not yet implemented"))

  (define (make-nsrange location length) (error 'make-nsrange "not yet implemented"))
  (define (nsrange-location r) (error 'nsrange-location "not yet implemented"))
  (define (nsrange-length r) (error 'nsrange-length "not yet implemented"))

  (define (string->nsstring s) (error 'string->nsstring "not yet implemented"))
  (define (nsstring->string ns) (error 'nsstring->string "not yet implemented"))
  (define (list->nsarray lst) (error 'list->nsarray "not yet implemented"))
  (define (nsarray->list arr) (error 'nsarray->list "not yet implemented"))
  (define (hash->nsdictionary h) (error 'hash->nsdictionary "not yet implemented"))
  (define (nsdictionary->hash d) (error 'nsdictionary->hash "not yet implemented"))

  (define (cf-bridge-retain cf-ptr) (error 'cf-bridge-retain "not yet implemented"))
  (define (cf-bridge-release cf-ptr) (error 'cf-bridge-release "not yet implemented")))
