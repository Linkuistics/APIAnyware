#lang racket/base
;; test-swift-trampoline-smoke.rkt — end-to-end proof of the Swift-native
;; trampoline (ADR-0027 / docs/specs/2026-06-15-racket-trampoline.md) on REAL
;; recovered residual, not synthetic fixtures (grove leaf 040/030).
;;
;; Both exemplars are genuine Swift-native (`objc_exposed: false`, `s:` USR)
;; top-level decls recovered by 030-ir-boundary and trampolined by 040/020. They
;; have NO C symbol in the framework dylib — they are reachable ONLY through the
;; `aw_racket_swift_*` C-ABI trampolines compiled into libAPIAnywareRacket:
;;
;;   - CreateML.timestampSeed() -> Int      (s:8CreateML13timestampSeedSiyF)
;;       scalar function; binds aw_racket_swift_CreateML_timestampSeed via _aw-lib.
;;   - CreateML.MLCreateErrorDomain : String (s:8CreateML19MLCreateErrorDomainSSvp)
;;       pointer-valued Swift constant; binds
;;       aw_racket_swift_const_CreateML_MLCreateErrorDomain via _aw-lib, the
;;       trampoline returning a +1-retained NSString opaque pointer that
;;       aw-string-result copies + releases.
;;   - CoreGraphics.acos(CGFloat) -> CGFloat   (s:12CoreGraphics4acosy…)
;;       scalar-typedef function (grove leaf 040/040/010): CGFloat is lossily
;;       lowered to a named type but is a Double scalar at the ABI, so this
;;       trampolines as a clean `_double -> _double` — the dominant recovery of
;;       the deferred_nonbridged_struct_param bucket (44 of 69 functions). Proves
;;       a CGFloat PARAM round-trips (the leaf's target), not just a CGFloat return.
;;
;; Requiring the generated modules already proves the bindings RESOLVE (a stale
;; or mismatched dylib makes get-ffi-obj raise at module load); the test bodies
;; prove they RUN and return live values.

(require rackunit
         rackunit/text-ui
         ffi/unsafe
         racket/math
         "../runtime/swift-trampoline.rkt"
         ;; Generated CreateML residual bindings (trampolined, not _fw-lib).
         "../generated/createml/functions.rkt"
         "../generated/createml/constants.rkt"
         ;; Generated CoreGraphics residual: the CGFloat scalar-typedef exemplar.
         (only-in "../generated/coregraphics/functions.rkt" acos))

(define trampoline-smoke-tests
  (test-suite
   "Swift-native trampoline — real recovered residual"

   (test-case "_aw-lib resolves the raw trampoline symbols to live addresses"
     ;; The flat-C entries the generated bindings wrap must exist in
     ;; libAPIAnywareRacket; get-ffi-obj raises if a symbol is absent.
     (check-true (procedure?
                  (get-ffi-obj 'aw_racket_swift_CreateML_timestampSeed
                               _aw-lib (_fun -> _int64)))
                 "scalar-function trampoline symbol present")
     (check-true (procedure?
                  (get-ffi-obj 'aw_racket_swift_const_CreateML_MLCreateErrorDomain
                               _aw-lib (_fun -> _pointer)))
                 "constant trampoline symbol present"))

   (test-case "CreateML.timestampSeed() runs through the trampoline"
     ;; Swift-native scalar free function with no C symbol — reachable only via
     ;; the trampoline. Returns a time-derived seed: a positive Int.
     (define seed (timestampSeed))
     (check-pred exact-integer? seed "seed is an exact integer")
     (check-true (> seed 0) "seed is positive (time-derived)")
     ;; Two calls advance (or at least don't go backwards) — it is time-derived.
     (check-true (>= (timestampSeed) seed) "successive seeds are non-decreasing"))

   (test-case "CreateML.MLCreateErrorDomain reads through the trampoline"
     ;; Pointer-valued Swift constant: the trampoline hands back a live NSString
     ;; address that aw-string-result copies into a Racket string.
     (check-pred string? MLCreateErrorDomain "constant resolves to a string")
     (check-true (> (string-length MLCreateErrorDomain) 0)
                 "error-domain string is non-empty"))

   (test-case "CoreGraphics.acos(CGFloat) runs through the scalar-typedef trampoline"
     ;; The leaf's headline: a CGFloat *parameter* round-trips. The @_cdecl takes a
     ;; Double, re-wraps it as CGFloat for the by-name call, and converts the
     ;; CGFloat result back to a Double — racket sees a plain `_double -> _double`.
     ;; acos(1) = 0, acos(0) = π/2: real math through the real CoreGraphics symbol,
     ;; which has NO C symbol of its own (reachable only via the trampoline).
     (check-pred real? (acos 1.0) "acos returns a real")
     (check-= (acos 1.0) 0.0 1e-9 "acos(1) = 0")
     (check-= (acos 0.0) (/ pi 2) 1e-9 "acos(0) = π/2")
     (check-= (acos -1.0) pi 1e-9 "acos(-1) = π"))))

(define result (run-tests trampoline-smoke-tests))
(exit (if (zero? result) 0 1))
