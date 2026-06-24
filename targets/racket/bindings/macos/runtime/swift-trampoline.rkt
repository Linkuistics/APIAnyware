#lang racket/base
;; swift-trampoline.rkt — racket-side support for the Swift-native trampolines
;; (ADR-0027 / targets/racket/docs/design/2026-06-15-racket-trampoline.md §4).
;;
;; The generated `@_cdecl` trampolines in libAPIAnywareRacket's Generated/
;; Trampolines.swift re-export Swift-native (`s:`) APIs behind a flat C ABI. The
;; generated `functions.rkt` / `constants.rkt` of a framework that has any such
;; residual bind those entries against `_aw-lib` (this module's handle to
;; libAPIAnywareRacket) rather than the framework dylib, and wrap them with the
;; coercers here. Everything is `aw_racket_*` / `aw-*` namespaced (ADR-0011
;; hermetic isolation); this module reuses the already-loaded dylib and the
;; existing String coercers rather than introducing a second native substrate.

(require ffi/unsafe
         "swift-helpers.rkt"   ; anyware-lib, swift:nsstring-to-string, swift:release
         "type-mapping.rkt")   ; string->nsstring

(provide _aw-lib
         aw-string-arg
         aw-string-result
         aw-raise-swift-error
         aw-call/error)

;; The libAPIAnywareRacket handle the generated trampoline bindings bind against.
;; Reuses swift-helpers' already-loaded, mandatory dylib (ADR-0010) — there is no
;; second load — re-exported under the spec's `_aw-lib` name.
(define _aw-lib anyware-lib)

;; A `String` argument crossing into a trampoline: the racket caller passes a
;; racket string, which becomes a +1-retained NSString `id` for the `@_cdecl`
;; body's `… as String` reconstruction. (`string->nsstring` owns the retain; the
;; trampoline takes it unretained, so the autorelease/return path frees it.)
(define (aw-string-arg s)
  (and s (string->nsstring s)))

;; A `String` result coming back from a trampoline: the `@_cdecl` handed us a
;; +1-retained NSString. Copy its bytes into a racket string, then release the
;; +1 so the bridge does not leak. `#f` (NULL) passes through as `#f`.
(define (aw-string-result p)
  (and p
       (let ([s (swift:nsstring-to-string p)])
         (swift:release p)
         s)))

;; Raise a racket exception for a Swift-native error. The trampoline wrote a
;; +1-retained `NSError *` through the error out-buffer (the dispatch `error_out`
;; shape). We release the +1 and raise — richer NSError message extraction (it
;; needs a live `-localizedDescription` crossing) is the verification leaf's
;; concern; here we keep the raise dependency-free.
(define (aw-raise-swift-error err)
  (swift:release err)
  (error 'swift-trampoline "Swift-native call raised an NSError"))

;; Invoke a throwing trampoline `raw` (whose last C argument is an `NSError **`
;; out-buffer) with `args`, then raise if it reported an error, else return the
;; (result-coerced) value. `coerce` post-processes the raw result on the success
;; path (e.g. `aw-string-result`, or `values` for a scalar/identity result).
(define (aw-call/error raw coerce . args)
  (define errbuf (malloc _pointer))
  (ptr-set! errbuf _pointer #f)
  (define result (apply raw (append args (list errbuf))))
  (define err (ptr-ref errbuf _pointer))
  (if err
      (aw-raise-swift-error err)
      (coerce result)))
