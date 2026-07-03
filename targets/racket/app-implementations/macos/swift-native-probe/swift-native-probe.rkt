#lang racket/base
;; swift-native-probe.rkt — Swift-native API coverage probe (OO style)
;;
;; Closes the racket slice of the add-swift-native-api-coverage grove (leaf 050):
;; proves the complete-API trampoline mechanism (ADR-0025 / ADR-0027) works
;; end-to-end in a real GUI app, not just the in-process CLI smoke.
;;
;; It calls a Swift-native FREE FUNCTION (CreateML.timestampSeed -> Int) and reads
;; a Swift-native CONSTANT (CreateML.MLCreateErrorDomain: String). Neither has a C
;; symbol in CreateML.framework — both carry objc_exposed: false and are reachable
;; only through libAPIAnywareRacket's @_cdecl trampolines (_aw-lib). A window that
;; shows their live values is unambiguous evidence the Swift-native path is bound.
;;
;; Exercises: NSApplication setup, NSWindow, NSTextField labels — plus the two
;;            Swift-native trampoline exemplars from spec §6a.
;;
;; AppSpec instrumentation (racket-impl-k144): the k141 logging contract
;; (apps/macos/swift-native-probe/docs/logging-contract.md). Beyond the shown
;; values, each of the two shapes is checked against a known-good expected and
;; emitted as a [probe] result to the events.log the runner tails, plus a
;; [probe] complete all-ok summary (scenario 01's target-agnostic coverage
;; assertion) and the lifecycle triad. Under `launch-via 'open` LaunchServices
;; discards stdout, so events.log — not stdout — is the runner's read path; the
;; stdout echo below is kept for humans running the app unbundled.
;;
;; Run with: racket swift-native-probe.rkt  (GUI testing uses TestAnyware — §README)

(require "../../generated/appkit/nsapplication.rkt"
         "../../generated/appkit/nswindow.rkt"
         "../../generated/appkit/nstextfield.rkt"
         "../../generated/appkit/nsview.rkt"
         "../../generated/appkit/nsfont.rkt"
         "../../generated/appkit/nscolor.rkt"
         ;; The Swift-native residual — trampolined through libAPIAnywareRacket:
         "../../generated/createml/functions.rkt"   ; timestampSeed (free function)
         "../../generated/createml/constants.rkt"   ; MLCreateErrorDomain (constant)
         "../../runtime/objc-base.rkt"
         "../../runtime/type-mapping.rkt"
         "../../runtime/delegate.rkt"                ; make-delegate (terminate hook)
         "../../runtime/app-menu.rkt"
         "events.rkt")                               ; structured event log (logging contract)

;; --- Constants (window/text styling) ---
(define NSWindowStyleMaskTitled 1)
(define NSWindowStyleMaskClosable 2)
(define NSWindowStyleMaskMiniaturizable 4)
(define NSBackingStoreBuffered 2)
(define NSTextAlignmentLeft 0)
(define NSTextAlignmentCenter 1)

;; --- Structured event log (logging contract) ---
;; Open + truncate the events.log the runner tails, then record [lifecycle]
;; startup BEFORE probing / window construction / the AppKit run loop (or
;; `wait-ready` times out).
(events-init!)
(emit-startup)

;; Test-config compatibility (logging-contract.md "Test-config compatibility"):
;; the probe reads no runtime config — its coverage set is fixed — so it honours
;; SWIFT_NATIVE_PROBE_TEST_CONFIG by reading the env var and treating an
;; absent/empty value (and a missing file) as "no config" — a deliberate no-op.
(void (getenv "SWIFT_NATIVE_PROBE_TEST_CONFIG"))

;; --- Shutdown wiring (signal / error paths) ---
;; The logging contract requires a [lifecycle] shutdown line on terminate.
;; The menu/Cmd-Q path goes through applicationWillTerminate: (delegate below);
;; SIGTERM/SIGINT reach Racket as exn:break -> reason=signal, and any other
;; uncaught exception -> reason=error.
(uncaught-exception-handler
 (lambda (exn)
   (with-handlers ([exn:fail? (lambda (_) (void))])
     (if (exn:break? exn)
         (emit-shutdown 'signal)
         (emit-shutdown 'error))
     (close-events!))
   (exit (if (exn:break? exn) 130 1))))

;; --- Probe each shape NOW (before any UI) so a binding failure surfaces loudly
;;     rather than as an empty window; each result is checked vs its known-good
;;     expected and emitted as a [probe] result, then the coverage summary. Do
;;     NOT abort on a failed probe — the window stays diagnostic. ---
(define seed-value (timestampSeed))                 ; shape 1: Swift-native Int via trampoline
(define error-domain MLCreateErrorDomain)           ; shape 2: Swift-native String constant

;; Per-shape ok-checks (contract "Known-good expecteds"):
;;   - timestampSeed is time-derived, never value-equality: the check is STRUCTURAL
;;     (an exact Int was returned — the binding produced a well-typed result).
;;   - MLCreateErrorDomain is the fixed domain string.
(define ok-fn    (exact-integer? seed-value))
(define ok-const (and (string? error-domain)
                      (string=? error-domain "com.apple.CreateML")))
(emit-probe-result 'function "CreateML.timestampSeed"       ok-fn    (number->string seed-value))
(emit-probe-result 'constant "CreateML.MLCreateErrorDomain" ok-const (format "~s" error-domain))
(let ([ok-count (+ (if ok-fn 1 0) (if ok-const 1 0))])
  (emit-probe-complete 2 ok-count (= ok-count 2)))

;; Human-friendly stdout echo (kept for unbundled runs; not the contract).
(printf "Swift-native CreateML.timestampSeed() = ~a\n" seed-value)
(printf "Swift-native MLCreateErrorDomain = ~a\n" error-domain)

;; --- Application setup ---
(define app (nsapplication-shared-application))
(nsapplication-set-activation-policy! app 0)        ; NSApplicationActivationPolicyRegular
(install-standard-app-menu! app "Swift-Native Probe")

;; --- App delegate (terminate hook -> [lifecycle] shutdown reason=menu) ---
;; Cocoa holds delegates weakly, so keep a module-scope reference. The body is
;; wrapped in with-handlers because an unhandled exception in an ObjC callback
;; crashes the app with no Racket stack trace.
(define app-delegate
  (make-delegate
   "applicationWillTerminate:"
   (lambda (notification)
     (with-handlers ([exn:fail?
                      (lambda (e)
                        (eprintf "applicationWillTerminate delegate error: ~a\n"
                                 (exn-message e)))])
       (emit-shutdown 'menu)
       (close-events!)))))
(void (nsapplication-set-delegate! app app-delegate))

;; --- Create window (560x240, centered) ---
(define window
  (make-nswindow-init-with-content-rect-style-mask-backing-defer
   (make-nsrect 0 0 560 240)
   (bitwise-ior NSWindowStyleMaskTitled
                NSWindowStyleMaskClosable
                NSWindowStyleMaskMiniaturizable)
   NSBackingStoreBuffered
   #f))
(nswindow-set-title! window "Swift-Native API Coverage")
(nswindow-center! window)

(define content-view (nswindow-content-view window))

;; --- Label factory ---
(define (add-label! text x y w h size align color)
  (define field (make-nstextfield-init-with-frame (make-nsrect x y w h)))
  (nstextfield-set-string-value! field text)
  (nstextfield-set-font! field (nsfont-system-font-of-size size))
  (nstextfield-set-alignment! field align)
  (nstextfield-set-editable! field #f)
  (nstextfield-set-selectable! field #f)
  (nstextfield-set-bezeled! field #f)
  (nstextfield-set-draws-background! field #f)
  (when color (nstextfield-set-text-color! field color))
  (nsview-add-subview! content-view field)
  field)

;; --- Heading ---
(add-label! "Swift-native APIs via libAPIAnywareRacket trampolines"
            20 190 520 28 17.0 NSTextAlignmentCenter #f)

;; --- Function row: CreateML.timestampSeed() -> Int (Swift-native free function) ---
(add-label! "CreateML.timestampSeed()"
            30 142 280 24 15.0 NSTextAlignmentLeft #f)
(add-label! (string-append "→ " (number->string seed-value))
            310 142 220 24 15.0 NSTextAlignmentLeft
            (nscolor-system-blue-color))

;; --- Constant row: CreateML.MLCreateErrorDomain: String (Swift-native constant) ---
(add-label! "CreateML.MLCreateErrorDomain"
            30 106 280 24 15.0 NSTextAlignmentLeft #f)
(add-label! (string-append "→ " (if error-domain error-domain "<unbound>"))
            310 106 220 24 15.0 NSTextAlignmentLeft
            (nscolor-system-blue-color))

;; --- Footer ---
(add-label! "Neither symbol exists as a C symbol in CreateML.framework —"
            20 52 520 20 12.0 NSTextAlignmentCenter (nscolor-secondary-label-color))
(add-label! "both are Swift-native (objc_exposed: false), reached only via @_cdecl trampolines."
            20 32 520 20 12.0 NSTextAlignmentCenter (nscolor-secondary-label-color))

;; --- Show window and run ---
(nswindow-make-key-and-order-front window #f)
(nsapplication-activate-ignoring-other-apps app #t)

;; §step-6 launch diagnostic — dual emission (logging contract): keep the
;; human-friendly stdout line AND write the same bare line to events.log
;; (LaunchServices discards stdout under `open`). Emitted UNCONDITIONALLY so the
;; headless smoke below sees it.
(displayln "Swift-Native Probe opened. Close the window or press Ctrl+C to exit.")
(emit-launch-line)

;; AW_PROBE_SMOKE is the host construction pre-flight (racket has no sbcl-style
;; `:run nil` entry): the whole probe + full k141 contract has now been emitted and
;; the window built + ordered-front, so exit WITHOUT the run loop — the window is
;; never serviced/composited (no event loop) so no GUI grabs the host. This CLI-
;; smokes the [probe] vocabulary before the VM round-trip; the live GUI verify is
;; forward-gen-live-run's ([[use_testanyware]] — never run the GUI from the CLI).
(unless (getenv "AW_PROBE_SMOKE")
  (nsapplication-run app))
