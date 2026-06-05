;;; hello-window.ss — Hello Window sample app (gerbil target).
;;;
;;; Minimal macOS GUI: a window with a centred label. Exercises NSApplication
;;; setup, the standard app menu, NSWindow creation (NSRect by value), an
;;; NSTextField label, inherited-method dispatch via the proc cores of the
;;; declaring superclass (NSControl/NSView), object lifecycle, and the event
;;; loop. Mirrors generation/targets/chez/apps/hello-window/hello-window.sls
;;; one control at a time.
;;;
;;; Build via the bottle toolchain (which already embeds the Gerbil/Gambit
;;; runtime — `gxc -exe` links libgambit.a; no static source toolchain needed,
;;; see the app README + spec §7). The link line carries -lobjc, -framework
;;; AppKit/Foundation, and the clang-compiled native_block.o companion.
(import :gerbil-bindings/runtime/objc
        :gerbil-bindings/runtime/cocoa
        :gerbil-bindings/appkit/nsapplication
        :gerbil-bindings/appkit/nswindow
        :gerbil-bindings/appkit/nsview
        :gerbil-bindings/appkit/nscontrol
        :gerbil-bindings/appkit/nstextfield
        :gerbil-bindings/appkit/nsfont
        :gerbil-bindings/appkit/enums)
(export main)

(define-entry-point (main)
  (let (app (nsapplication-shared-application))
    (nsapplication-set-activation-policy! app NSApplicationActivationPolicyRegular)

    ;; Standard macOS app menu (About / Hide / Quit). The bold app-name slot in
    ;; the menu bar comes from CFBundleName when launched as a .app bundle
    ;; (leaf 070/030); unbundled it reads the exe name.
    (install-standard-app-menu! app "Hello Window")

    ;; --- Window (400x200, centred) ---
    (let (window (make-nswindow-init-with-content-rect-style-mask-backing-defer
                   (make-rect 0. 0. 400. 200.)
                   (bitwise-ior NSWindowStyleMaskTitled
                                NSWindowStyleMaskClosable
                                NSWindowStyleMaskMiniaturizable)
                   NSBackingStoreBuffered
                   #f))
      (nswindow-set-title! window (string->nsstring "Hello from Gerbil"))
      (nswindow-center! window)

      ;; --- Label (centred in window) ---
      (let (label (make-nstextfield))
        (nsview-set-frame! label (make-rect 0. 70. 400. 60.))
        (nscontrol-set-string-value! label (string->nsstring "Hello, macOS!"))
        (nscontrol-set-font! label (nsfont-system-font-of-size 24.))
        (nscontrol-set-alignment! label NSTextAlignmentCenter)
        (nstextfield-set-editable! label #f)
        (nstextfield-set-selectable! label #f)
        (nstextfield-set-bezeled! label #f)
        (nstextfield-set-draws-background! label #f)
        (nsview-add-subview! (nswindow-content-view window) label))

      ;; --- Show and run ---
      (nswindow-make-key-and-order-front window #f)
      (nsapplication-activate-ignoring-other-apps app #t)
      (displayln "Hello Window opened. Close the window or press Ctrl+C to exit.")
      (nsapplication-run app))))

(main)
