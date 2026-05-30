;; ui-controls-gallery.sls — UI Controls Gallery sample app (chez target).
;;
;; Scrollable window showcasing all major AppKit UI controls. Serves
;; as the visual-regression baseline for generated bindings. Mirrors
;; generation/targets/racket/apps/ui-controls-gallery/ui-controls-gallery.rkt.
;;
;; The body of `(define-entry-point (main) ...)` is a procedure body
;; in R6RS terms — all internal `define`s precede every expression.
;; Mixing them is what `(import (chezscheme))` rejects at script load
;; with "invalid context for definition".
;;
;; Run unbundled with:
;;   chez --libdirs generation/targets/chez \
;;        --script generation/targets/chez/apps/ui-controls-gallery/ui-controls-gallery.sls
;; Bundled via `cargo run --example bundle_app -p apianyware-macos-bundle-chez
;;              -- ui-controls-gallery`.

(import (chezscheme)
        (apianyware appkit)
        (apianyware foundation)
        (apianyware runtime cocoa)
        (apianyware runtime objc)
        (apianyware runtime types)
        (apianyware runtime dispatch))

(define-entry-point (main)
  ;; ============================================================
  ;; Definitions
  ;; ============================================================

  ;; --- Helpers ---
  (define (make-section-header title)
    (let ([label (make-nstextfield-init-with-frame (make-nsrect 0 0 460 22))])
      (nstextfield-set-string-value! label title)
      (nstextfield-set-font! label (nsfont-bold-system-font-of-size 14.0))
      (nstextfield-set-editable! label #f)
      (nstextfield-set-selectable! label #f)
      (nstextfield-set-bezeled! label #f)
      (nstextfield-set-draws-background! label #f)
      label))

  (define (make-value-label text)
    (let ([label (make-nstextfield-init-with-frame (make-nsrect 0 0 460 20))])
      (nstextfield-set-string-value! label text)
      (nstextfield-set-font! label (nsfont-system-font-of-size 12.0))
      (nstextfield-set-editable! label #f)
      (nstextfield-set-selectable! label #f)
      (nstextfield-set-bezeled! label #f)
      (nstextfield-set-draws-background! label #f)
      label))

  ;; --- Application + window ---
  (define app (nsapplication-shared-application))

  (define window
    (make-nswindow-init-with-content-rect-style-mask-backing-defer
      (make-nsrect 0 0 500 600)
      (bitwise-ior NSWindowStyleMaskTitled
                   NSWindowStyleMaskClosable
                   NSWindowStyleMaskMiniaturizable
                   NSWindowStyleMaskResizable)
      NSBackingStoreBuffered
      #f))

  (define content-view (nswindow-content-view window))
  (define content-frame (nsview-frame content-view))

  (define scroll-view (make-nsscrollview-init-with-frame content-frame))
  (define stack-view
    (make-nsstackview-init-with-frame (make-nsrect 0 0 480 0)))

  ;; --- Text fields ---
  (define text-field
    (make-nstextfield-init-with-frame (make-nsrect 0 0 460 24)))
  (define secure-field
    (make-nssecuretextfield-init-with-frame (make-nsrect 0 0 460 24)))

  ;; --- Buttons ---
  (define push-button
    (make-nsbutton-init-with-frame (make-nsrect 0 0 120 32)))
  (define checkbox
    (make-nsbutton-init-with-frame (make-nsrect 0 0 200 24)))

  (define radio-container
    (make-nsview-init-with-frame (make-nsrect 0 0 460 24)))
  (define radio-a (make-nsbutton-init-with-frame (make-nsrect 0 0 100 24)))
  (define radio-b (make-nsbutton-init-with-frame (make-nsrect 105 0 100 24)))
  (define radio-c (make-nsbutton-init-with-frame (make-nsrect 210 0 100 24)))

  ;; Radio mutual exclusion. Sender arrives from the Swift trampoline
  ;; as a raw void* (a uptr at the Scheme level); wrap with
  ;; borrow-objc-object so the generated setter accepts it cleanly.
  (define radio-target
    (make-delegate
      `(("selectRadio:"
         ,(lambda (sender)
            (nsbutton-set-int-value! radio-a 0)
            (nsbutton-set-int-value! radio-b 0)
            (nsbutton-set-int-value! radio-c 0)
            (nsbutton-set-int-value! (borrow-objc-object sender) 1))
         (void*) void))))

  ;; --- Sliders ---
  (define slider (make-nsslider-init-with-frame (make-nsrect 0 0 460 24)))
  (define slider-value-label (make-value-label "Value: 50"))
  (define slider-target
    (make-delegate
      `(("sliderChanged:"
         ,(lambda (sender)
            (let ([val (nsslider-double-value (borrow-objc-object sender))])
              (nstextfield-set-string-value!
                slider-value-label
                (format #f "Value: ~a" (exact (round val))))))
         (void*) void))))

  ;; --- Popup & combo ---
  (define popup (make-nspopupbutton-init-with-frame (make-nsrect 0 0 200 28)))
  (define combo (make-nscombobox-init-with-frame (make-nsrect 0 0 200 28)))

  ;; --- Date picker ---
  (define date-picker (make-nsdatepicker-init-with-frame (make-nsrect 0 0 300 28)))

  ;; --- Progress indicators ---
  (define progress-bar
    (make-nsprogressindicator-init-with-frame (make-nsrect 0 0 460 20)))
  (define spinner
    (make-nsprogressindicator-init-with-frame (make-nsrect 0 0 32 32)))

  ;; --- Stepper ---
  (define stepper (make-nsstepper-init-with-frame (make-nsrect 0 0 100 28)))
  (define stepper-value-label (make-value-label "Value: 5"))
  (define stepper-target
    (make-delegate
      `(("stepperChanged:"
         ,(lambda (sender)
            (let ([val (nsstepper-int-value (borrow-objc-object sender))])
              (nstextfield-set-string-value!
                stepper-value-label
                (format #f "Value: ~a" val))))
         (void*) void))))

  ;; --- Color & image ---
  (define color-well (make-nscolorwell-init-with-frame (make-nsrect 0 0 44 28)))
  (define image-view (make-nsimageview-init-with-frame (make-nsrect 0 0 48 48)))

  ;; ============================================================
  ;; Expressions
  ;; ============================================================

  (nsapplication-set-activation-policy! app NSApplicationActivationPolicyRegular)
  (install-standard-app-menu! app "UI Controls Gallery")

  ;; Window
  (nswindow-set-title! window "UI Controls Gallery")
  (nswindow-center! window)
  (nswindow-set-min-size! window (make-nssize 400 400))

  ;; Layout containers
  (nsscrollview-set-has-vertical-scroller! scroll-view #t)
  (nsscrollview-set-autohides-scrollers! scroll-view #t)
  (nsscrollview-set-autoresizing-mask! scroll-view
    (bitwise-ior NSViewWidthSizable NSViewHeightSizable))

  (nsstackview-set-orientation! stack-view NSUserInterfaceLayoutOrientationVertical)
  (nsstackview-set-spacing! stack-view 16.0)
  ;; Parity with racket: insets left unset. NSEdgeInsets is now emitted
  ;; by-value under chez (geometry-only filter, leaf 050/100/010), so
  ;; nsstackview-set-edge-insets! is available if needed in future.

  ;; Section 1: Text Fields
  (nsstackview-add-arranged-subview! stack-view (make-section-header "Text Fields"))
  (nstextfield-set-placeholder-string! text-field "Type here...")
  (nsstackview-add-arranged-subview! stack-view text-field)
  (nssecuretextfield-set-placeholder-string! secure-field "Password")
  (nsstackview-add-arranged-subview! stack-view secure-field)

  ;; Section 2: Buttons
  (nsstackview-add-arranged-subview! stack-view (make-section-header "Buttons"))

  (nsbutton-set-title! push-button "Click Me")
  (nsbutton-set-bezel-style! push-button NSBezelStyleRounded)
  (nsstackview-add-arranged-subview! stack-view push-button)

  (nsbutton-set-button-type! checkbox NSButtonTypeSwitch)
  (nsbutton-set-title! checkbox "Enable Feature")
  (nsstackview-add-arranged-subview! stack-view checkbox)

  (nsbutton-set-button-type! radio-a NSButtonTypeRadio)
  (nsbutton-set-title! radio-a "Option A")
  (nsbutton-set-int-value! radio-a 1)
  (nsview-add-subview! radio-container radio-a)

  (nsbutton-set-button-type! radio-b NSButtonTypeRadio)
  (nsbutton-set-title! radio-b "Option B")
  (nsview-add-subview! radio-container radio-b)

  (nsbutton-set-button-type! radio-c NSButtonTypeRadio)
  (nsbutton-set-title! radio-c "Option C")
  (nsview-add-subview! radio-container radio-c)

  (for-each
    (lambda (btn)
      (nsbutton-set-target! btn (delegate-ptr radio-target))
      (nsbutton-set-action! btn "selectRadio:"))
    (list radio-a radio-b radio-c))

  (nsstackview-add-arranged-subview! stack-view radio-container)

  ;; Section 3: Sliders
  (nsstackview-add-arranged-subview! stack-view (make-section-header "Sliders"))

  (nsslider-set-min-value! slider 0.0)
  (nsslider-set-max-value! slider 100.0)
  (nsslider-set-double-value! slider 50.0)
  (nsslider-set-continuous! slider #t)
  (nsstackview-add-arranged-subview! stack-view slider)

  (nsstackview-add-arranged-subview! stack-view slider-value-label)

  (nsslider-set-target! slider (delegate-ptr slider-target))
  (nsslider-set-action! slider "sliderChanged:")

  ;; Section 4: Popup & Combo
  (nsstackview-add-arranged-subview! stack-view (make-section-header "Popup & Combo"))

  (nspopupbutton-add-item-with-title! popup "Small")
  (nspopupbutton-add-item-with-title! popup "Medium")
  (nspopupbutton-add-item-with-title! popup "Large")
  (nsstackview-add-arranged-subview! stack-view popup)

  (nscombobox-add-item-with-object-value! combo "Red")
  (nscombobox-add-item-with-object-value! combo "Green")
  (nscombobox-add-item-with-object-value! combo "Blue")
  (nsstackview-add-arranged-subview! stack-view combo)

  ;; Section 5: Date Picker
  (nsstackview-add-arranged-subview! stack-view (make-section-header "Date Picker"))

  (nsdatepicker-set-date-picker-style! date-picker NSDatePickerStyleTextFieldAndStepper)
  (nsdatepicker-set-date-picker-elements! date-picker
    (bitwise-ior NSDatePickerElementFlagYearMonthDay
                 NSDatePickerElementFlagHourMinuteSecond))
  (nsdatepicker-set-date-value! date-picker (nsdate-now))
  (nsstackview-add-arranged-subview! stack-view date-picker)

  ;; Section 6: Progress Indicators
  (nsstackview-add-arranged-subview! stack-view (make-section-header "Progress Indicators"))

  (nsprogressindicator-set-indeterminate! progress-bar #f)
  (nsprogressindicator-set-double-value! progress-bar 65.0)
  (nsstackview-add-arranged-subview! stack-view progress-bar)

  (nsstackview-add-arranged-subview! stack-view (make-value-label "65% complete"))

  (nsprogressindicator-set-style! spinner NSProgressIndicatorStyleSpinning)
  (nsprogressindicator-set-indeterminate! spinner #t)
  (nsprogressindicator-start-animation spinner #f)
  (nsstackview-add-arranged-subview! stack-view spinner)

  ;; Section 7: Stepper
  (nsstackview-add-arranged-subview! stack-view (make-section-header "Stepper"))

  (nsstepper-set-min-value! stepper 0.0)
  (nsstepper-set-max-value! stepper 10.0)
  (nsstepper-set-int-value! stepper 5)
  (nsstepper-set-increment! stepper 1.0)
  (nsstepper-set-continuous! stepper #t)
  (nsstackview-add-arranged-subview! stack-view stepper)

  (nsstackview-add-arranged-subview! stack-view stepper-value-label)

  (nsstepper-set-target! stepper (delegate-ptr stepper-target))
  (nsstepper-set-action! stepper "stepperChanged:")

  ;; Section 8: Color & Image
  (nsstackview-add-arranged-subview! stack-view (make-section-header "Color & Image"))

  (nscolorwell-set-color! color-well (nscolor-system-blue-color))
  (nsstackview-add-arranged-subview! stack-view color-well)

  (let ([star-image (nsimage-image-named "NSActionTemplate")])
    (unless (zero? (objc-object-ptr star-image))
      (nsimageview-set-image! image-view star-image)))
  (nsstackview-add-arranged-subview! stack-view image-view)

  ;; Assemble: stack → scroll → window
  (nsview-set-frame! stack-view (make-nsrect 0 0 480 900))
  (nsscrollview-set-document-view! scroll-view stack-view)
  (nsview-add-subview! content-view scroll-view)

  ;; Show window and run
  (nswindow-make-key-and-order-front window #f)
  (nsapplication-activate-ignoring-other-apps app #t)

  (display "UI Controls Gallery running. Close window or Ctrl+C to exit.\n")
  (nsapplication-run app))

(main)
