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
         "../../runtime/app-menu.rkt")

;; --- Constants (window/text styling) ---
(define NSWindowStyleMaskTitled 1)
(define NSWindowStyleMaskClosable 2)
(define NSWindowStyleMaskMiniaturizable 4)
(define NSBackingStoreBuffered 2)
(define NSTextAlignmentLeft 0)
(define NSTextAlignmentCenter 1)

;; --- Call the Swift-native residual NOW (before any UI) so a failure to bind
;;     the trampolines surfaces loudly rather than as an empty window. ---
(define seed-value (timestampSeed))                 ; Swift-native Int via trampoline
(define error-domain MLCreateErrorDomain)           ; Swift-native String constant
(printf "Swift-native CreateML.timestampSeed() = ~a\n" seed-value)
(printf "Swift-native MLCreateErrorDomain = ~a\n" error-domain)

;; --- Application setup ---
(define app (nsapplication-shared-application))
(nsapplication-set-activation-policy! app 0)        ; NSApplicationActivationPolicyRegular
(install-standard-app-menu! app "Swift-Native Probe")

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

(displayln "Swift-Native Probe opened. Close the window or press Ctrl+C to exit.")
(nsapplication-run app)
