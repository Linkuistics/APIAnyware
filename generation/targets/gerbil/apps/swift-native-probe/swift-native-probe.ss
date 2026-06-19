;;; swift-native-probe.ss — Swift-native API coverage probe (gerbil target).
;;;
;;; Closes the gerbil slice of the add-swift-native-api-coverage grove (leaf
;;; 070/030): proves the complete-API trampoline mechanism (ADR-0025 / ADR-0027,
;;; ported to gerbil in ADR-0029) works end-to-end in a real GUI app, not just
;;; the in-process CLI smoke (runtime/tests/smoke-swift-trampoline.ss).
;;;
;;; It calls a Swift-native FREE FUNCTION (CreateML.timestampSeed -> Int) and
;;; reads a Swift-native CONSTANT (CreateML.MLCreateErrorDomain: String). Neither
;;; has a C symbol in CreateML.framework — both carry objc_exposed: false and are
;;; reachable only through libAPIAnywareGerbil's @_cdecl trampolines, bound here
;;; via define-c-lambda (the ADR-0017 idiom, the thing `gsc` structurally cannot
;;; do). A window showing their live values is unambiguous evidence the
;;; Swift-native path is bound.
;;;
;;; Per ADR-0015 the gerbil String coercion is Scheme-side: the constant
;;; trampoline returns an `id` (NSString) and (gerbil-bindings createml constants)
;;; coerces it with the existing aw-swift-string-result — no native string bridge.
;;;
;;; Mirrors generation/targets/chez/apps/swift-native-probe/swift-native-probe.sls
;;; (and the racket original) one control at a time.
;;;
;;; Build the standalone bundle (compiles the whole closure + links + relocates
;;; libAPIAnywareGerbil into Contents/Frameworks):
;;;   cargo run --example bundle_app -p apianyware-macos-bundle-gerbil -- swift-native-probe
;;; (prerequisite: SDKROOT=macosx cargo run -p apianyware-macos-generate -- --target gerbil
;;;  then  (cd swift && SDKROOT=macosx swift build -c release --product APIAnywareGerbil)).
;;; GUI testing uses TestAnyware (see README); never run the app from the CLI.
(import :gerbil-bindings/runtime/objc
        :gerbil-bindings/runtime/cocoa
        :gerbil-bindings/appkit/nsapplication
        :gerbil-bindings/appkit/nswindow
        :gerbil-bindings/appkit/nsview
        :gerbil-bindings/appkit/nscontrol
        :gerbil-bindings/appkit/nstextfield
        :gerbil-bindings/appkit/nsfont
        :gerbil-bindings/appkit/nscolor
        :gerbil-bindings/appkit/enums
        ;; The Swift-native residual — trampolined through libAPIAnywareGerbil:
        :gerbil-bindings/createml/functions    ; timestampSeed (free function)
        :gerbil-bindings/createml/constants)   ; MLCreateErrorDomain (constant)
(export main)

(define-entry-point (main)
  ;; --- Call the Swift-native residual NOW (before any UI) so a failure to bind
  ;;     the trampolines surfaces loudly rather than as an empty window. ---
  (let ((seed-value (timestampSeed))            ; Swift-native Int via trampoline
        (error-domain MLCreateErrorDomain))     ; Swift-native String constant
    (displayln (string-append "Swift-native CreateML.timestampSeed() = "
                              (number->string seed-value)))
    (displayln (string-append "Swift-native MLCreateErrorDomain = " error-domain))

    ;; --- Application setup ---
    (let (app (nsapplication-shared-application))
      (nsapplication-set-activation-policy! app NSApplicationActivationPolicyRegular)
      (install-standard-app-menu! app "Swift Native Probe")

      ;; --- Window (560x240, centred) ---
      (let* ((window (make-nswindow-init-with-content-rect-style-mask-backing-defer
                       (make-rect 0. 0. 560. 240.)
                       (bitwise-ior NSWindowStyleMaskTitled
                                    NSWindowStyleMaskClosable
                                    NSWindowStyleMaskMiniaturizable)
                       NSBackingStoreBuffered
                       #f))
             (content-view (nswindow-content-view window)))
        ;; --- Label factory (internal defines precede body expressions) ---
        (define (add-label! text x y w h size align color)
          (let (field (make-nstextfield))
            (nsview-set-frame! field (make-rect x y w h))
            (nscontrol-set-string-value! field (string->nsstring text))
            (nscontrol-set-font! field (nsfont-system-font-of-size size))
            (nscontrol-set-alignment! field align)
            (nstextfield-set-editable! field #f)
            (nstextfield-set-selectable! field #f)
            (nstextfield-set-bezeled! field #f)
            (nstextfield-set-draws-background! field #f)
            (when color (nstextfield-set-text-color! field color))
            (nsview-add-subview! content-view field)
            field))

        (nswindow-set-title! window (string->nsstring "Swift-Native API Coverage"))
        (nswindow-center! window)

        ;; --- Heading ---
        (add-label! "Swift-native APIs via libAPIAnywareGerbil trampolines"
                    20. 190. 520. 28. 17. NSTextAlignmentCenter #f)

        ;; --- Function row: CreateML.timestampSeed() -> Int (Swift-native free function) ---
        (add-label! "CreateML.timestampSeed()"
                    30. 142. 280. 24. 15. NSTextAlignmentLeft #f)
        (add-label! (string-append "→ " (number->string seed-value))
                    310. 142. 220. 24. 15. NSTextAlignmentLeft
                    (nscolor-system-blue-color))

        ;; --- Constant row: CreateML.MLCreateErrorDomain: String (Swift-native constant) ---
        (add-label! "CreateML.MLCreateErrorDomain"
                    30. 106. 280. 24. 15. NSTextAlignmentLeft #f)
        (add-label! (string-append "→ " error-domain)
                    310. 106. 220. 24. 15. NSTextAlignmentLeft
                    (nscolor-system-blue-color))

        ;; --- Footer ---
        (add-label! "Neither symbol exists as a C symbol in CreateML.framework —"
                    20. 52. 520. 20. 12. NSTextAlignmentCenter (nscolor-secondary-label-color))
        (add-label! "both are Swift-native (objc_exposed: false), reached only via @_cdecl trampolines."
                    20. 32. 520. 20. 12. NSTextAlignmentCenter (nscolor-secondary-label-color))

        ;; --- Show window and run ---
        (nswindow-make-key-and-order-front window #f)
        (nsapplication-activate-ignoring-other-apps app #t)
        (displayln "Swift-Native Probe opened. Close the window or press Ctrl+C to exit.")
        (nsapplication-run app)))))

(main)
