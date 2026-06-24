;;; ui-controls-gallery.ss — UI Controls Gallery sample app (gerbil target).
;;;
;;; Scrollable window showcasing every major AppKit control: text/secure
;;; fields, push/checkbox/radio buttons, slider, popup, combo, date picker,
;;; progress indicators, stepper, color well, image view — laid out in an
;;; NSStackView inside an NSScrollView. Serves as the visual-regression
;;; baseline for the generated bindings. Mirrors
;;; generation/targets/chez/apps/ui-controls-gallery/ui-controls-gallery.sls
;;; one control at a time.
;;;
;;; Gerbil idiom differences from the chez source:
;;;   - Strings cross as NSStrings: `(string->nsstring "...")`, never raw.
;;;   - Geometry: `make-rect`/`make-size` (cocoa.ss), doubles by value.
;;;   - Most controls have only a bare `make-<class>` initializer; the frame is
;;;     set afterwards with `nsview-set-frame!` (the stack view re-lays them out).
;;;   - Inherited methods dispatch through the DECLARING superclass's proc core
;;;     (e.g. a slider's value is `nscontrol-double-value`, a field's font is
;;;     `nscontrol-set-font!`), so nscontrol/nsview are imported explicitly.
;;;   - Target-action callbacks use `make-delegate`: a spec list of
;;;     (selector proc (param-token …) return-token); the `'object` token wraps
;;;     `sender` to a bound instance, and the delegate object is passed straight
;;;     to `nscontrol-set-target!` (no chez `delegate-ptr` accessor).
;;;
;;; Build via build.sh (bottle toolchain); bundle via bundle-gerbil.
(import :gerbil-bindings/runtime/objc
        :gerbil-bindings/runtime/cocoa
        :gerbil-bindings/appkit/nsapplication
        :gerbil-bindings/appkit/nswindow
        :gerbil-bindings/appkit/nsview
        :gerbil-bindings/appkit/nscontrol
        :gerbil-bindings/appkit/nstextfield
        :gerbil-bindings/appkit/nssecuretextfield
        :gerbil-bindings/appkit/nsbutton
        :gerbil-bindings/appkit/nsslider
        :gerbil-bindings/appkit/nspopupbutton
        :gerbil-bindings/appkit/nscombobox
        :gerbil-bindings/appkit/nsdatepicker
        :gerbil-bindings/appkit/nsprogressindicator
        :gerbil-bindings/appkit/nsstepper
        :gerbil-bindings/appkit/nscolorwell
        :gerbil-bindings/appkit/nsimageview
        :gerbil-bindings/appkit/nsscrollview
        :gerbil-bindings/appkit/nsstackview
        :gerbil-bindings/appkit/nsfont
        :gerbil-bindings/appkit/nscolor
        :gerbil-bindings/appkit/nsimage
        :gerbil-bindings/appkit/enums
        :gerbil-bindings/foundation/nsdate)
(export main)

(define-entry-point (main)
  ;; ============================================================
  ;; Definitions (all internal defs precede every expression)
  ;; ============================================================

  ;; --- Helpers ---
  (def (make-label text font-size width height)
    (let (label (make-nstextfield))
      (nsview-set-frame! label (make-rect 0. 0. width height))
      (nscontrol-set-string-value! label (string->nsstring text))
      (nscontrol-set-font! label (nsfont-system-font-of-size font-size))
      (nstextfield-set-editable! label #f)
      (nstextfield-set-selectable! label #f)
      (nstextfield-set-bezeled! label #f)
      (nstextfield-set-draws-background! label #f)
      label))

  (def (make-section-header title)
    (let (label (make-nstextfield))
      (nsview-set-frame! label (make-rect 0. 0. 460. 22.))
      (nscontrol-set-string-value! label (string->nsstring title))
      (nscontrol-set-font! label (nsfont-bold-system-font-of-size 14.))
      (nstextfield-set-editable! label #f)
      (nstextfield-set-selectable! label #f)
      (nstextfield-set-bezeled! label #f)
      (nstextfield-set-draws-background! label #f)
      label))

  (def (make-value-label text) (make-label text 12. 460. 20.))

  ;; --- Application + window ---
  (def app (nsapplication-shared-application))

  (def window
    (make-nswindow-init-with-content-rect-style-mask-backing-defer
      (make-rect 0. 0. 500. 600.)
      (bitwise-ior NSWindowStyleMaskTitled
                   NSWindowStyleMaskClosable
                   NSWindowStyleMaskMiniaturizable
                   NSWindowStyleMaskResizable)
      NSBackingStoreBuffered
      #f))

  (def content-view (nswindow-content-view window))
  (def content-frame (nsview-frame content-view))

  (def scroll-view (make-nsscrollview-init-with-frame content-frame))
  (def stack-view (make-nsstackview))

  ;; --- Text fields ---
  (def text-field (make-nstextfield))
  (def secure-field (make-nssecuretextfield))

  ;; --- Buttons ---
  (def push-button (make-nsbutton))
  (def checkbox (make-nsbutton))

  (def radio-container (make-nsview-init-with-frame (make-rect 0. 0. 460. 24.)))
  (def radio-a (make-nsbutton))
  (def radio-b (make-nsbutton))
  (def radio-c (make-nsbutton))

  ;; Radio mutual exclusion. `sender` arrives wrapped as a bound instance
  ;; (the `'object` param token), so it flows straight into the setter.
  (def radio-target
    (make-delegate
      (list (list "selectRadio:"
                  (lambda (sender)
                    (nscontrol-set-int-value! radio-a 0)
                    (nscontrol-set-int-value! radio-b 0)
                    (nscontrol-set-int-value! radio-c 0)
                    (nscontrol-set-int-value! sender 1))
                  (list 'object) 'void))))

  ;; --- Sliders ---
  (def slider (make-nsslider))
  (def slider-value-label (make-value-label "Value: 50"))
  (def slider-target
    (make-delegate
      (list (list "sliderChanged:"
                  (lambda (sender)
                    (let (val (nscontrol-double-value sender))
                      (nscontrol-set-string-value!
                        slider-value-label
                        (string->nsstring
                          (string-append "Value: "
                                         (number->string (inexact->exact (round val))))))))
                  (list 'object) 'void))))

  ;; --- Popup & combo ---
  (def popup (make-nspopupbutton-init-with-frame-pulls-down (make-rect 0. 0. 200. 28.) #f))
  (def combo (make-nscombobox))

  ;; --- Date picker ---
  (def date-picker (make-nsdatepicker))

  ;; --- Progress indicators ---
  (def progress-bar (make-nsprogressindicator))
  (def spinner (make-nsprogressindicator))

  ;; --- Stepper ---
  (def stepper (make-nsstepper))
  (def stepper-value-label (make-value-label "Value: 5"))
  (def stepper-target
    (make-delegate
      (list (list "stepperChanged:"
                  (lambda (sender)
                    (let (val (nscontrol-int-value sender))
                      (nscontrol-set-string-value!
                        stepper-value-label
                        (string->nsstring
                          (string-append "Value: " (number->string val))))))
                  (list 'object) 'void))))

  ;; --- Color & image ---
  (def color-well (make-nscolorwell))
  (def image-view (make-nsimageview))

  ;; ============================================================
  ;; Expressions
  ;; ============================================================

  (nsapplication-set-activation-policy! app NSApplicationActivationPolicyRegular)
  (install-standard-app-menu! app "UI Controls Gallery")

  ;; Window
  (nswindow-set-title! window (string->nsstring "UI Controls Gallery"))
  (nswindow-center! window)
  (nswindow-set-min-size! window (make-size 400. 400.))

  ;; Layout containers
  (nsscrollview-set-has-vertical-scroller! scroll-view #t)
  (nsscrollview-set-autohides-scrollers! scroll-view #t)
  (nsview-set-autoresizing-mask! scroll-view
    (bitwise-ior NSViewWidthSizable NSViewHeightSizable))

  (nsview-set-frame! stack-view (make-rect 0. 0. 480. 0.))
  (nsstackview-set-orientation! stack-view NSUserInterfaceLayoutOrientationVertical)
  (nsstackview-set-spacing! stack-view 16.)

  ;; Section 1: Text Fields
  (nsstackview-add-arranged-subview! stack-view (make-section-header "Text Fields"))
  (nsview-set-frame! text-field (make-rect 0. 0. 460. 24.))
  (nstextfield-set-placeholder-string! text-field (string->nsstring "Type here..."))
  (nsstackview-add-arranged-subview! stack-view text-field)
  (nsview-set-frame! secure-field (make-rect 0. 0. 460. 24.))
  ;; setPlaceholderString: is declared on NSTextField (inherited by the secure field).
  (nstextfield-set-placeholder-string! secure-field (string->nsstring "Password"))
  (nsstackview-add-arranged-subview! stack-view secure-field)

  ;; Section 2: Buttons
  (nsstackview-add-arranged-subview! stack-view (make-section-header "Buttons"))

  (nsview-set-frame! push-button (make-rect 0. 0. 120. 32.))
  (nsbutton-set-title! push-button (string->nsstring "Click Me"))
  (nsbutton-set-bezel-style! push-button NSBezelStyleRounded)
  (nsstackview-add-arranged-subview! stack-view push-button)

  (nsview-set-frame! checkbox (make-rect 0. 0. 200. 24.))
  (nsbutton-set-button-type! checkbox NSButtonTypeSwitch)
  (nsbutton-set-title! checkbox (string->nsstring "Enable Feature"))
  (nsstackview-add-arranged-subview! stack-view checkbox)

  (nsview-set-frame! radio-a (make-rect 0. 0. 100. 24.))
  (nsbutton-set-button-type! radio-a NSButtonTypeRadio)
  (nsbutton-set-title! radio-a (string->nsstring "Option A"))
  (nscontrol-set-int-value! radio-a 1)
  (nsview-add-subview! radio-container radio-a)

  (nsview-set-frame! radio-b (make-rect 105. 0. 100. 24.))
  (nsbutton-set-button-type! radio-b NSButtonTypeRadio)
  (nsbutton-set-title! radio-b (string->nsstring "Option B"))
  (nsview-add-subview! radio-container radio-b)

  (nsview-set-frame! radio-c (make-rect 210. 0. 100. 24.))
  (nsbutton-set-button-type! radio-c NSButtonTypeRadio)
  (nsbutton-set-title! radio-c (string->nsstring "Option C"))
  (nsview-add-subview! radio-container radio-c)

  (for-each
    (lambda (btn)
      (nscontrol-set-target! btn radio-target)
      (nscontrol-set-action! btn "selectRadio:"))
    (list radio-a radio-b radio-c))

  (nsstackview-add-arranged-subview! stack-view radio-container)

  ;; Section 3: Sliders
  (nsstackview-add-arranged-subview! stack-view (make-section-header "Sliders"))

  (nsview-set-frame! slider (make-rect 0. 0. 460. 24.))
  (nsslider-set-min-value! slider 0.)
  (nsslider-set-max-value! slider 100.)
  (nscontrol-set-double-value! slider 50.)
  (nscontrol-set-continuous! slider #t)
  (nsstackview-add-arranged-subview! stack-view slider)
  (nsstackview-add-arranged-subview! stack-view slider-value-label)
  (nscontrol-set-target! slider slider-target)
  (nscontrol-set-action! slider "sliderChanged:")

  ;; Section 4: Popup & Combo
  (nsstackview-add-arranged-subview! stack-view (make-section-header "Popup & Combo"))

  (nspopupbutton-add-item-with-title! popup (string->nsstring "Small"))
  (nspopupbutton-add-item-with-title! popup (string->nsstring "Medium"))
  (nspopupbutton-add-item-with-title! popup (string->nsstring "Large"))
  (nsstackview-add-arranged-subview! stack-view popup)

  (nsview-set-frame! combo (make-rect 0. 0. 200. 28.))
  (nscombobox-add-item-with-object-value! combo (string->nsstring "Red"))
  (nscombobox-add-item-with-object-value! combo (string->nsstring "Green"))
  (nscombobox-add-item-with-object-value! combo (string->nsstring "Blue"))
  (nsstackview-add-arranged-subview! stack-view combo)

  ;; Section 5: Date Picker
  (nsstackview-add-arranged-subview! stack-view (make-section-header "Date Picker"))

  (nsview-set-frame! date-picker (make-rect 0. 0. 300. 28.))
  (nsdatepicker-set-date-picker-style! date-picker NSDatePickerStyleTextFieldAndStepper)
  (nsdatepicker-set-date-picker-elements! date-picker
    (bitwise-ior NSDatePickerElementFlagYearMonthDay
                 NSDatePickerElementFlagHourMinuteSecond))
  (nsdatepicker-set-date-value! date-picker (nsdate-now))
  (nsstackview-add-arranged-subview! stack-view date-picker)

  ;; Section 6: Progress Indicators
  (nsstackview-add-arranged-subview! stack-view (make-section-header "Progress Indicators"))

  (nsview-set-frame! progress-bar (make-rect 0. 0. 460. 20.))
  (nsprogressindicator-set-indeterminate! progress-bar #f)
  (nsprogressindicator-set-double-value! progress-bar 65.)
  (nsstackview-add-arranged-subview! stack-view progress-bar)
  (nsstackview-add-arranged-subview! stack-view (make-value-label "65% complete"))

  (nsview-set-frame! spinner (make-rect 0. 0. 32. 32.))
  (nsprogressindicator-set-style! spinner NSProgressIndicatorStyleSpinning)
  (nsprogressindicator-set-indeterminate! spinner #t)
  (nsprogressindicator-start-animation spinner #f)
  (nsstackview-add-arranged-subview! stack-view spinner)

  ;; Section 7: Stepper
  (nsstackview-add-arranged-subview! stack-view (make-section-header "Stepper"))

  (nsview-set-frame! stepper (make-rect 0. 0. 100. 28.))
  (nsstepper-set-min-value! stepper 0.)
  (nsstepper-set-max-value! stepper 10.)
  (nscontrol-set-int-value! stepper 5)
  (nsstepper-set-increment! stepper 1.)
  (nscontrol-set-continuous! stepper #t)
  (nsstackview-add-arranged-subview! stack-view stepper)
  (nsstackview-add-arranged-subview! stack-view stepper-value-label)
  (nscontrol-set-target! stepper stepper-target)
  (nscontrol-set-action! stepper "stepperChanged:")

  ;; Section 8: Color & Image
  (nsstackview-add-arranged-subview! stack-view (make-section-header "Color & Image"))

  (nsview-set-frame! color-well (make-rect 0. 0. 44. 28.))
  (nscolorwell-set-color! color-well (nscolor-system-blue-color))
  (nsstackview-add-arranged-subview! stack-view color-well)

  (nsview-set-frame! image-view (make-rect 0. 0. 48. 48.))
  (let (star-image (nsimage-image-named (string->nsstring "NSActionTemplate")))
    (unless (ptr-null? (->ptr star-image))
      (nsimageview-set-image! image-view star-image)))
  (nsstackview-add-arranged-subview! stack-view image-view)

  ;; Assemble: stack → scroll → window
  (nsview-set-frame! stack-view (make-rect 0. 0. 480. 900.))
  (nsscrollview-set-document-view! scroll-view stack-view)
  (nsview-add-subview! content-view scroll-view)

  ;; Show window and run
  (nswindow-make-key-and-order-front window #f)
  (nsapplication-activate-ignoring-other-apps app #t)

  (displayln "UI Controls Gallery running. Close window or Ctrl+C to exit.")
  (nsapplication-run app))

(main)
