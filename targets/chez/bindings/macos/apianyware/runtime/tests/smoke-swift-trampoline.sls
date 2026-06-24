;; tests/smoke-swift-trampoline.sls — end-to-end smoke for the chez Swift-native
;; trampolines (ADR-0027 ported to chez, leaf 060).
;;
;; Run from the repository root, against a freshly built libAPIAnywareChez:
;;   (cd targets/chez/adapters/macos && SDKROOT=macosx swift build --product APIAnywareChez)
;;   chez --libdirs targets/chez/bindings/macos \
;;        --script targets/chez/bindings/macos/apianyware/runtime/tests/smoke-swift-trampoline.sls
;;
;; Exits 0 on success, raises on failure. Proves the canonical residual exemplars
;; (spec §6a) resolve through libAPIAnywareChez's @_cdecl trampolines and run:
;;   - CreateML.timestampSeed() -> Int   (a scalar free function, no C symbol)
;;   - CreateML.MLCreateErrorDomain      (a Swift-native String global)
;; Neither has a C export in CreateML.framework; both reach chez only via the
;; aw_chez_swift_* trampolines.

(import (apianyware createml functions)    ; timestampSeed (+ show overloads)
        (apianyware createml constants))   ; MLCreateErrorDomain

(define failures 0)
(define (check who ok?)
  (if ok?
      (begin (display "  ok  ") (display who) (newline))
      (begin (set! failures (+ failures 1))
             (display "  FAIL ") (display who) (newline))))

;; 1. Scalar function trampoline: CreateML.timestampSeed() -> Int. Time-derived,
;;    so just assert a positive integer came back through the trampoline.
(let ([seed (timestampSeed)])
  (check 'timestampSeed-is-integer (integer? seed))
  (check 'timestampSeed-is-positive (and (integer? seed) (> seed 0)))
  (display "      timestampSeed => ") (display seed) (newline))

;; 2. Constant trampoline + Scheme-side string coercion (ADR-0015):
;;    CreateML.MLCreateErrorDomain == "com.apple.CreateML".
(check 'MLCreateErrorDomain-value (string=? MLCreateErrorDomain "com.apple.CreateML"))
(display "      MLCreateErrorDomain => ") (write MLCreateErrorDomain) (newline)

(if (zero? failures)
    (begin (display "swift-trampoline smoke: 3/3 OK") (newline) (exit 0))
    (begin (display "swift-trampoline smoke: FAILED") (newline) (exit 1)))
