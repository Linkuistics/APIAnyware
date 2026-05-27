#lang racket/base
;; hello-window.rkt — Hello Window sample app (OO style)
;;
;; Minimal macOS GUI: creates a window with a centered label.
;; Exercises: NSApplication setup, NSWindow creation, NSTextField as label,
;;            property setters, object lifecycle, event loop.
;;
;; Run with: racket hello-window.rkt

(require "../../generated/appkit/nsapplication.rkt"
         "../../generated/appkit/nswindow.rkt"
         "../../generated/appkit/nstextfield.rkt"
         "../../generated/appkit/nsview.rkt"
         "../../generated/appkit/nsfont.rkt"
         "../../runtime/objc-base.rkt"
         "../../runtime/type-mapping.rkt"
         "../../runtime/app-menu.rkt")

;; --- Constants (not yet extracted by collector) ---
;; NSWindowStyleMask
(define NSWindowStyleMaskTitled 1)
(define NSWindowStyleMaskClosable 2)
(define NSWindowStyleMaskMiniaturizable 4)
;; NSBackingStoreType
(define NSBackingStoreBuffered 2)
;; NSTextAlignment (macOS modern values — Left=0, Center=1, Right=2)
(define NSTextAlignmentCenter 1)

;; --- Application setup ---
(define app (nsapplication-shared-application))
(nsapplication-set-activation-policy! app 0) ; NSApplicationActivationPolicyRegular

;; Standard macOS app menu (About / Hide / Quit). Bold app-name slot
;; in the menu bar comes from CFBundleName when launched as a .app
;; bundle (see `apianyware-macos-bundle-racket-oo`).
(install-standard-app-menu! app "Hello Window")

;; --- Create window (400x200, centered) ---
(define window
  (make-nswindow-init-with-content-rect-style-mask-backing-defer
   (make-nsrect 0 0 400 200)
   (bitwise-ior NSWindowStyleMaskTitled
                NSWindowStyleMaskClosable
                NSWindowStyleMaskMiniaturizable)
   NSBackingStoreBuffered
   #f))

(nswindow-set-title! window "Hello from Racket")
(nswindow-center! window)

;; --- Create label (centered in window) ---
(define label
  (make-nstextfield-init-with-frame (make-nsrect 0 70 400 60)))

(nstextfield-set-string-value! label "Hello, macOS!")
(nstextfield-set-font! label (nsfont-system-font-of-size 24.0))
(nstextfield-set-alignment! label NSTextAlignmentCenter)
(nstextfield-set-editable! label #f)
(nstextfield-set-selectable! label #f)
(nstextfield-set-bezeled! label #f)
(nstextfield-set-draws-background! label #f)

;; --- Add label to window ---
(define content-view (nswindow-content-view window))
(nsview-add-subview! content-view label)

;; --- Show window and run ---
(nswindow-make-key-and-order-front window #f)
(nsapplication-activate-ignoring-other-apps app #t)

(displayln "Hello Window opened. Close the window or press Ctrl+C to exit.")
(nsapplication-run app)
