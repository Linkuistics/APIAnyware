#lang racket/base
;; ui-controls-gallery.rkt — UI Controls Gallery sample app (OO style)
;;
;; Scrollable window showcasing all major AppKit UI controls.
;; Serves as a visual regression baseline for generated bindings.
;; Exercises: NSScrollView, NSStackView, target-action on slider/stepper,
;;            diverse property types, enum constants, container views.
;;
;; Run with: racket ui-controls-gallery.rkt

(require "../../generated/appkit/nsapplication.rkt"
         "../../generated/appkit/nswindow.rkt"
         "../../generated/appkit/nsview.rkt"
         "../../generated/appkit/nsscrollview.rkt"
         "../../generated/appkit/nsstackview.rkt"
         "../../generated/appkit/nstextfield.rkt"
         "../../generated/appkit/nssecuretextfield.rkt"
         "../../generated/appkit/nsbutton.rkt"
         "../../generated/appkit/nsslider.rkt"
         "../../generated/appkit/nspopupbutton.rkt"
         "../../generated/appkit/nscombobox.rkt"
         "../../generated/appkit/nsdatepicker.rkt"
         "../../generated/appkit/nsprogressindicator.rkt"
         "../../generated/appkit/nsstepper.rkt"
         "../../generated/appkit/nscolorwell.rkt"
         "../../generated/appkit/nsimageview.rkt"
         "../../generated/appkit/nsimage.rkt"
         "../../generated/appkit/nscolor.rkt"
         "../../generated/appkit/nsfont.rkt"
         "../../generated/foundation/nsdate.rkt"
         "../../runtime/objc-base.rkt"
         "../../runtime/type-mapping.rkt"
         "../../runtime/delegate.rkt"
         "../../runtime/app-menu.rkt")

;; --- Constants (not yet extracted by collector) ---

;; NSWindowStyleMask
(define NSWindowStyleMaskTitled        1)
(define NSWindowStyleMaskClosable      2)
(define NSWindowStyleMaskMiniaturizable 4)
(define NSWindowStyleMaskResizable     8)
;; NSBackingStoreType
(define NSBackingStoreBuffered 2)
;; NSTextAlignment
(define NSTextAlignmentLeft   0)
(define NSTextAlignmentCenter 1)
;; NSBezelStyle
(define NSBezelStyleRounded 1)
;; NSButtonType
(define NSButtonTypeSwitch       3)  ; checkbox
(define NSButtonTypeRadio        4)  ; radio button
;; NSUserInterfaceLayoutOrientation
(define NSUserInterfaceLayoutOrientationVertical 1)
;; NSStackViewGravity
(define NSStackViewGravityTop    1)
;; NSDatePickerStyle
(define NSDatePickerStyleTextFieldAndStepper 0)
;; NSDatePickerElementFlags (from NSDatePickerCell.h)
(define NSDatePickerElementFlagYearMonthDay #x00e0)      ; 224
(define NSDatePickerElementFlagHourMinuteSecond #x000e)   ; 14
;; NSProgressIndicatorStyle
(define NSProgressIndicatorStyleBar      0)
(define NSProgressIndicatorStyleSpinning 1)
;; NSViewAutoresizingMask
(define NSViewWidthSizable  2)
(define NSViewHeightSizable 16)

;; --- Application setup ---
(define app (nsapplication-shared-application))
(nsapplication-set-activation-policy! app 0) ; NSApplicationActivationPolicyRegular

;; Standard macOS app menu (About / Hide / Quit). Bold app-name slot
;; in the menu bar comes from CFBundleName when launched as a .app
;; bundle (see `apianyware-macos-bundle-racket`).
(install-standard-app-menu! app "UI Controls Gallery")

;; --- Window (500x600, centered, resizable) ---
(define window
  (make-nswindow-init-with-content-rect-style-mask-backing-defer
   (make-nsrect 0 0 500 600)
   (bitwise-ior NSWindowStyleMaskTitled
                NSWindowStyleMaskClosable
                NSWindowStyleMaskMiniaturizable
                NSWindowStyleMaskResizable)
   NSBackingStoreBuffered
   #f))

(nswindow-set-title! window "UI Controls Gallery")
(nswindow-center! window)
(nswindow-set-min-size! window (make-nssize 400 400))

;; --- Layout: NSScrollView containing an NSStackView ---
(define content-view (nswindow-content-view window))
(define content-frame (nsview-frame content-view))

(define scroll-view
  (make-nsscrollview-init-with-frame content-frame))
(nsscrollview-set-has-vertical-scroller! scroll-view #t)
(nsscrollview-set-autohides-scrollers! scroll-view #t)
(nsscrollview-set-autoresizing-mask! scroll-view
  (bitwise-ior NSViewWidthSizable NSViewHeightSizable))

;; The stack view holds all sections vertically
(define stack-view
  (make-nsstackview-init-with-frame (make-nsrect 0 0 480 0)))
(nsstackview-set-orientation! stack-view NSUserInterfaceLayoutOrientationVertical)
(nsstackview-set-spacing! stack-view 16.0)
;; Note: set-edge-insets! omitted — the generated binding uses _uint64
;; instead of the NSEdgeInsets struct type, so passing the struct would crash.
;; The stack view works fine without explicit insets.

;; Helper: create a section header label
(define (make-section-header title)
  (let ([label (make-nstextfield-init-with-frame (make-nsrect 0 0 460 22))])
    (nstextfield-set-string-value! label title)
    (nstextfield-set-font! label (nsfont-bold-system-font-of-size 14.0))
    (nstextfield-set-editable! label #f)
    (nstextfield-set-selectable! label #f)
    (nstextfield-set-bezeled! label #f)
    (nstextfield-set-draws-background! label #f)
    label))

;; Helper: create a non-editable value label
(define (make-value-label text)
  (let ([label (make-nstextfield-init-with-frame (make-nsrect 0 0 460 20))])
    (nstextfield-set-string-value! label text)
    (nstextfield-set-font! label (nsfont-system-font-of-size 12.0))
    (nstextfield-set-editable! label #f)
    (nstextfield-set-selectable! label #f)
    (nstextfield-set-bezeled! label #f)
    (nstextfield-set-draws-background! label #f)
    label))

;; ===================================================================
;; Section 1: Text Fields
;; ===================================================================
(nsstackview-add-arranged-subview! stack-view (make-section-header "Text Fields"))

(define text-field
  (make-nstextfield-init-with-frame (make-nsrect 0 0 460 24)))
(nstextfield-set-placeholder-string! text-field "Type here...")
(nsstackview-add-arranged-subview! stack-view text-field)

(define secure-field
  (make-nssecuretextfield-init-with-frame (make-nsrect 0 0 460 24)))
(nssecuretextfield-set-placeholder-string! secure-field "Password")
(nsstackview-add-arranged-subview! stack-view secure-field)

;; ===================================================================
;; Section 2: Buttons
;; ===================================================================
(nsstackview-add-arranged-subview! stack-view (make-section-header "Buttons"))

;; Push button
(define push-button
  (make-nsbutton-init-with-frame (make-nsrect 0 0 120 32)))
(nsbutton-set-title! push-button "Click Me")
(nsbutton-set-bezel-style! push-button NSBezelStyleRounded)
(nsstackview-add-arranged-subview! stack-view push-button)

;; Checkbox
(define checkbox
  (make-nsbutton-init-with-frame (make-nsrect 0 0 200 24)))
(nsbutton-set-button-type! checkbox NSButtonTypeSwitch)
(nsbutton-set-title! checkbox "Enable Feature")
(nsstackview-add-arranged-subview! stack-view checkbox)

;; Radio buttons (container view for horizontal layout)
(define radio-container
  (make-nsview-init-with-frame (make-nsrect 0 0 460 24)))

(define radio-a (make-nsbutton-init-with-frame (make-nsrect 0 0 100 24)))
(nsbutton-set-button-type! radio-a NSButtonTypeRadio)
(nsbutton-set-title! radio-a "Option A")
(nsbutton-set-int-value! radio-a 1) ; selected by default
(nsview-add-subview! radio-container radio-a)

(define radio-b (make-nsbutton-init-with-frame (make-nsrect 105 0 100 24)))
(nsbutton-set-button-type! radio-b NSButtonTypeRadio)
(nsbutton-set-title! radio-b "Option B")
(nsview-add-subview! radio-container radio-b)

(define radio-c (make-nsbutton-init-with-frame (make-nsrect 210 0 100 24)))
(nsbutton-set-button-type! radio-c NSButtonTypeRadio)
(nsbutton-set-title! radio-c "Option C")
(nsview-add-subview! radio-container radio-c)

;; Radio button mutual exclusion via target-action
(define radio-target
  (make-delegate
   #:return-types (hash "selectRadio:" 'void)
   #:param-types  (hash "selectRadio:" '(object))
   "selectRadio:" (lambda (sender)
                    ;; Deselect all via the wrapper (radio-a/b/c are objc-object structs).
                    (nsbutton-set-int-value! radio-a 0)
                    (nsbutton-set-int-value! radio-b 0)
                    (nsbutton-set-int-value! radio-c 0)
                    ;; sender is auto-wrapped by #:param-types as borrow-objc-object,
                    ;; satisfying the wrapper's objc-object? contract.
                    (nsbutton-set-int-value! sender 1))))

(for ([btn (list radio-a radio-b radio-c)])
  (nsbutton-set-target! btn radio-target)
  (nsbutton-set-action! btn "selectRadio:"))

(nsstackview-add-arranged-subview! stack-view radio-container)

;; ===================================================================
;; Section 3: Sliders
;; ===================================================================
(nsstackview-add-arranged-subview! stack-view (make-section-header "Sliders"))

(define slider
  (make-nsslider-init-with-frame (make-nsrect 0 0 460 24)))
(nsslider-set-min-value! slider 0.0)
(nsslider-set-max-value! slider 100.0)
(nsslider-set-double-value! slider 50.0)
(nsslider-set-continuous! slider #t)
(nsstackview-add-arranged-subview! stack-view slider)

(define slider-value-label (make-value-label "Value: 50"))
(nsstackview-add-arranged-subview! stack-view slider-value-label)

;; Target-action for live slider updates
(define slider-target
  (make-delegate
   #:return-types (hash "sliderChanged:" 'void)
   #:param-types  (hash "sliderChanged:" '(object))
   "sliderChanged:" (lambda (sender)
                      (let ([val (nsslider-double-value sender)])
                        (nstextfield-set-string-value!
                         slider-value-label
                         (format "Value: ~a" (inexact->exact (round val))))))))

(nsslider-set-target! slider slider-target)
(nsslider-set-action! slider "sliderChanged:")

;; ===================================================================
;; Section 4: Popup & Combo
;; ===================================================================
(nsstackview-add-arranged-subview! stack-view (make-section-header "Popup & Combo"))

(define popup
  (make-nspopupbutton-init-with-frame (make-nsrect 0 0 200 28)))
(nspopupbutton-add-item-with-title! popup "Small")
(nspopupbutton-add-item-with-title! popup "Medium")
(nspopupbutton-add-item-with-title! popup "Large")
(nsstackview-add-arranged-subview! stack-view popup)

(define combo
  (make-nscombobox-init-with-frame (make-nsrect 0 0 200 28)))
(nscombobox-add-item-with-object-value! combo "Red")
(nscombobox-add-item-with-object-value! combo "Green")
(nscombobox-add-item-with-object-value! combo "Blue")
(nsstackview-add-arranged-subview! stack-view combo)

;; ===================================================================
;; Section 5: Date Picker
;; ===================================================================
(nsstackview-add-arranged-subview! stack-view (make-section-header "Date Picker"))

(define date-picker
  (make-nsdatepicker-init-with-frame (make-nsrect 0 0 300 28)))
(nsdatepicker-set-date-picker-style! date-picker NSDatePickerStyleTextFieldAndStepper)
(nsdatepicker-set-date-picker-elements! date-picker
  (bitwise-ior NSDatePickerElementFlagYearMonthDay
               NSDatePickerElementFlagHourMinuteSecond))
(nsdatepicker-set-date-value! date-picker (nsdate-now))
(nsstackview-add-arranged-subview! stack-view date-picker)

;; ===================================================================
;; Section 6: Progress Indicators
;; ===================================================================
(nsstackview-add-arranged-subview! stack-view (make-section-header "Progress Indicators"))

;; Determinate bar at 65%
(define progress-bar
  (make-nsprogressindicator-init-with-frame (make-nsrect 0 0 460 20)))
(nsprogressindicator-set-indeterminate! progress-bar #f)
(nsprogressindicator-set-double-value! progress-bar 65.0)
(nsstackview-add-arranged-subview! stack-view progress-bar)

(nsstackview-add-arranged-subview! stack-view (make-value-label "65% complete"))

;; Indeterminate spinner
(define spinner
  (make-nsprogressindicator-init-with-frame (make-nsrect 0 0 32 32)))
(nsprogressindicator-set-style! spinner NSProgressIndicatorStyleSpinning)
(nsprogressindicator-set-indeterminate! spinner #t)
(nsprogressindicator-start-animation spinner #f)
(nsstackview-add-arranged-subview! stack-view spinner)

;; ===================================================================
;; Section 7: Stepper
;; ===================================================================
(nsstackview-add-arranged-subview! stack-view (make-section-header "Stepper"))

(define stepper
  (make-nsstepper-init-with-frame (make-nsrect 0 0 100 28)))
(nsstepper-set-min-value! stepper 0.0)
(nsstepper-set-max-value! stepper 10.0)
(nsstepper-set-int-value! stepper 5)
(nsstepper-set-increment! stepper 1.0)
(nsstepper-set-continuous! stepper #t)
(nsstackview-add-arranged-subview! stack-view stepper)

(define stepper-value-label (make-value-label "Value: 5"))
(nsstackview-add-arranged-subview! stack-view stepper-value-label)

;; Target-action for stepper updates
(define stepper-target
  (make-delegate
   #:return-types (hash "stepperChanged:" 'void)
   #:param-types  (hash "stepperChanged:" '(object))
   "stepperChanged:" (lambda (sender)
                       (let ([val (nsstepper-int-value sender)])
                         (nstextfield-set-string-value!
                          stepper-value-label
                          (format "Value: ~a" val))))))

(nsstepper-set-target! stepper stepper-target)
(nsstepper-set-action! stepper "stepperChanged:")

;; ===================================================================
;; Section 8: Color & Image
;; ===================================================================
(nsstackview-add-arranged-subview! stack-view (make-section-header "Color & Image"))

;; Color well with system blue
(define color-well
  (make-nscolorwell-init-with-frame (make-nsrect 0 0 44 28)))
(nscolorwell-set-color! color-well (nscolor-system-blue-color))
(nsstackview-add-arranged-subview! stack-view color-well)

;; Image view with a built-in system image
(define image-view
  (make-nsimageview-init-with-frame (make-nsrect 0 0 48 48)))
(let ([star-image (nsimage-image-named "NSActionTemplate")])
  (when star-image
    (nsimageview-set-image! image-view star-image)))
(nsstackview-add-arranged-subview! stack-view image-view)

;; ===================================================================
;; Assemble: stack → scroll → window
;; ===================================================================

;; Size the stack view to fit its content (approximate height for all sections)
(nsview-set-frame! stack-view (make-nsrect 0 0 480 900))
(nsscrollview-set-document-view! scroll-view stack-view)
(nsview-add-subview! content-view scroll-view)

;; --- Show window and run ---
(nswindow-make-key-and-order-front window #f)
(nsapplication-activate-ignoring-other-apps app #t)

(displayln "UI Controls Gallery running. Close window or Ctrl+C to exit.")
(nsapplication-run app)
