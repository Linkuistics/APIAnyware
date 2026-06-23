;; hello-window.sls — Hello Window sample app (chez target).
;;
;; Minimal macOS GUI: creates a window with a centred label. Exercises
;; NSApplication setup, NSWindow creation, NSTextField as label,
;; property setters, object lifecycle, and the event loop. Mirrors
;; generation/targets/racket/apps/hello-window/hello-window.rkt one
;; control at a time.
;;
;; Run unbundled with:
;;   chez --libdirs generation/targets/chez \
;;        --script generation/targets/chez/apps/hello-window/hello-window.sls
;; Bundled via `cargo run --example bundle_app -p apianyware-bundle-chez
;;              -- hello-window`.

(import (chezscheme)
        (apianyware appkit)
        (apianyware foundation)
        (apianyware runtime cocoa)
        (apianyware runtime objc)
        (apianyware runtime types))

(define-entry-point (main)
  (let ([app (nsapplication-shared-application)])
    (nsapplication-set-activation-policy! app NSApplicationActivationPolicyRegular)

    ;; Standard macOS app menu (About / Hide / Quit). The bold app-name
    ;; slot in the menu bar comes from CFBundleName when launched as a
    ;; .app bundle (see bundle-chez); unbundled it reads "chez".
    (install-standard-app-menu! app "Hello Window")

    ;; --- Create window (400x200, centred) ---
    (let ([window (make-nswindow-init-with-content-rect-style-mask-backing-defer
                    (make-nsrect 0 0 400 200)
                    (bitwise-ior NSWindowStyleMaskTitled
                                 NSWindowStyleMaskClosable
                                 NSWindowStyleMaskMiniaturizable)
                    NSBackingStoreBuffered
                    #f)])
      (nswindow-set-title! window "Hello from Chez")
      (nswindow-center! window)

      ;; --- Create label (centred in window) ---
      (let ([label (make-nstextfield-init-with-frame
                     (make-nsrect 0 70 400 60))])
        (nstextfield-set-string-value! label "Hello, macOS!")
        (nstextfield-set-font! label (nsfont-system-font-of-size 24.0))
        (nstextfield-set-alignment! label NSTextAlignmentCenter)
        (nstextfield-set-editable! label #f)
        (nstextfield-set-selectable! label #f)
        (nstextfield-set-bezeled! label #f)
        (nstextfield-set-draws-background! label #f)

        (nsview-add-subview! (nswindow-content-view window) label))

      ;; --- Show window and run ---
      (nswindow-make-key-and-order-front window #f)
      (nsapplication-activate-ignoring-other-apps app #t)

      (display "Hello Window opened. Close the window or press Ctrl+C to exit.\n")
      (nsapplication-run app))))

(main)
