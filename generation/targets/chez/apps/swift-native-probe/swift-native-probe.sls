;; swift-native-probe.sls — Swift-native API coverage probe (chez target).
;;
;; Closes the chez slice of the add-swift-native-api-coverage grove (leaf 060/020):
;; proves the complete-API trampoline mechanism (ADR-0025 / ADR-0027, ported to
;; chez in ADR-0028) works end-to-end in a real GUI app, not just the in-process
;; CLI smoke (smoke-swift-trampoline.sls).
;;
;; It calls a Swift-native FREE FUNCTION (CreateML.timestampSeed -> Int) and reads
;; a Swift-native CONSTANT (CreateML.MLCreateErrorDomain: String). Neither has a C
;; symbol in CreateML.framework — both carry objc_exposed: false and are reachable
;; only through libAPIAnywareChez's @_cdecl trampolines. A window that shows their
;; live values is unambiguous evidence the Swift-native path is bound.
;;
;; Per ADR-0015 the chez String coercion is Scheme-side: the constant trampoline
;; returns an `id` (NSString) and (apianyware createml constants) coerces it with
;; the existing aw-string-result — no native string bridge (the racket↔chez
;; divergence the 060 brief flags).
;;
;; Mirrors generation/targets/racket/apps/swift-native-probe/swift-native-probe.rkt
;; one control at a time.
;;
;; Run unbundled with:
;;   chez --libdirs generation/targets/chez \
;;        --script generation/targets/chez/apps/swift-native-probe/swift-native-probe.sls
;; Bundled via `cargo run --example bundle_app -p apianyware-bundle-chez
;;              -- swift-native-probe`. GUI testing uses TestAnyware (see README).

(import (chezscheme)
        (apianyware appkit)
        (apianyware foundation)
        (apianyware runtime cocoa)
        (apianyware runtime objc)
        (apianyware runtime types)
        ;; The Swift-native residual — trampolined through libAPIAnywareChez:
        (apianyware createml functions)    ; timestampSeed (free function)
        (apianyware createml constants))   ; MLCreateErrorDomain (constant)

(define-entry-point (main)
  ;; --- Call the Swift-native residual NOW (before any UI) so a failure to bind
  ;;     the trampolines surfaces loudly rather than as an empty window. ---
  (let ([seed-value (timestampSeed)]            ; Swift-native Int via trampoline
        [error-domain MLCreateErrorDomain])     ; Swift-native String constant
    (printf "Swift-native CreateML.timestampSeed() = ~a\n" seed-value)
    (printf "Swift-native MLCreateErrorDomain = ~a\n" error-domain)

    ;; --- Application setup ---
    (let ([app (nsapplication-shared-application)])
      (nsapplication-set-activation-policy! app NSApplicationActivationPolicyRegular)
      (install-standard-app-menu! app "Swift-Native Probe")

      ;; --- Create window (560x240, centred) ---
      (let* ([window (make-nswindow-init-with-content-rect-style-mask-backing-defer
                       (make-nsrect 0 0 560 240)
                       (bitwise-ior NSWindowStyleMaskTitled
                                    NSWindowStyleMaskClosable
                                    NSWindowStyleMaskMiniaturizable)
                       NSBackingStoreBuffered
                       #f)]
             [content-view (nswindow-content-view window)])
        ;; --- Label factory (internal defines must precede body expressions) ---
        (define (add-label! text x y w h size align color)
          (let ([field (make-nstextfield-init-with-frame (make-nsrect x y w h))])
            (nstextfield-set-string-value! field text)
            (nstextfield-set-font! field (nsfont-system-font-of-size size))
            (nstextfield-set-alignment! field align)
            (nstextfield-set-editable! field #f)
            (nstextfield-set-selectable! field #f)
            (nstextfield-set-bezeled! field #f)
            (nstextfield-set-draws-background! field #f)
            (when color (nstextfield-set-text-color! field color))
            (nsview-add-subview! content-view field)
            field))

        (nswindow-set-title! window "Swift-Native API Coverage")
        (nswindow-center! window)

        ;; --- Heading ---
        (add-label! "Swift-native APIs via libAPIAnywareChez trampolines"
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
        (add-label! (string-append "→ " error-domain)
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

        (display "Swift-Native Probe opened. Close the window or press Ctrl+C to exit.\n")
        (nsapplication-run app)))))

(main)
