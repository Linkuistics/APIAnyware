;;; tests/smoke-swift-trampoline.ss — end-to-end CLI smoke for the gerbil
;;; Swift-native trampolines (ADR-0029, leaf 070/020).
;;;
;;; Built + run by `run-swift-trampoline-smoke.sh`, which links the gerbil exe
;;; against a freshly built libAPIAnywareGerbil.dylib. Proves the canonical
;;; residual exemplars (spec §6a) resolve through the dylib's `@_cdecl`
;;; trampolines and run from a gerbil program, reached via `define-c-lambda`:
;;;   - CreateML.timestampSeed() -> Int   (a scalar free function, no C symbol)
;;;   - CreateML.MLCreateErrorDomain      (a Swift-native String global)
;;; Neither has a C export in CreateML.framework; both reach gerbil only via the
;;; aw_gerbil_swift_* entries (the thing `gsc` structurally cannot do).
;;;
;;; Prints SWIFT-TRAMPOLINE-OK on success; exits non-zero on failure.

(export main)
(import :gerbil-bindings/createml/functions    ; timestampSeed
        :gerbil-bindings/createml/constants)    ; MLCreateErrorDomain

(def (main . _)
  (def failures 0)
  (def (check who ok?)
    (if ok?
      (begin (display "  ok   ") (displayln who))
      (begin (set! failures (+ failures 1)) (display "  FAIL ") (displayln who))))

  ;; 1. Scalar function trampoline: CreateML.timestampSeed() -> Int. Time-derived,
  ;;    so just assert a positive integer came back through the trampoline.
  (let (seed (timestampSeed))
    (check 'timestampSeed-is-positive-integer (and (integer? seed) (> seed 0)))
    (display "       timestampSeed => ") (displayln seed))

  ;; 2. Constant trampoline + Scheme-side string coercion (ADR-0015):
  ;;    CreateML.MLCreateErrorDomain == "com.apple.CreateML".
  (check 'MLCreateErrorDomain-value (equal? MLCreateErrorDomain "com.apple.CreateML"))
  (display "       MLCreateErrorDomain => ") (write MLCreateErrorDomain) (newline)

  (if (zero? failures)
    (begin (displayln "SWIFT-TRAMPOLINE-OK (2/2)") (exit 0))
    (begin (displayln "SWIFT-TRAMPOLINE-FAILED") (exit 1))))
