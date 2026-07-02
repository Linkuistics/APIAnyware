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
;;; Instrumented for the AppSpec scenario runner per the UI Controls Gallery
;;; logging contract (apps/macos/ui-controls-gallery/docs/logging-contract.md):
;;; it writes a structured events.log the runner tails — [lifecycle]
;;; startup/shutdown, the bare launch line, and the four [controls]
;;; state-change events (radio/checkbox/slider/stepper) that make the spec §13
;;; interaction assertions observable (the runner's expect-ax has no
;;; value/state read). Under `launch-via 'open` LaunchServices discards the
;;; app's stdout, so the log file (not stdout) is the runner's read path; the
;;; stdout line is kept too (human-friendly when run unbundled, §3.6).
;;;
;;; The logging is inlined here rather than split to a sibling events.ss for
;;; the same reason as hello-window: the bundler's closure walk (deps.rs)
;;; follows only `:gerbil-bindings/…` references, and these defines use only
;;; Gambit primitives (open-output-file, getenv, create-directory,
;;; force-output), so they ride the statically-linked prelude with no new
;;; import.
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
        :gerbil-bindings/foundation/nsdate
        :gerbil-bindings/foundation/nsstring)
(export main)

;; --- Structured event log (logging contract) -------------------------------
;; Single writer: the Cocoa run loop serialises the main-thread callbacks that
;; emit — startup/launch before -run, the [controls] events from action
;; callbacks, shutdown on terminate — so one port with a post-write
;; force-output suffices (no lock needed).

;; Fixed default the descriptor's #:events-path mirrors, so the runner tails
;; the same file whether or not #:log-env (UI_CONTROLS_GALLERY_EVENTS_LOG)
;; propagates through LaunchServices.
(define ucg-default-events-path "/tmp/ui-controls-gallery/events.log")
(define ucg-events-port #f)

;; UI_CONTROLS_GALLERY_EVENTS_LOG if set and non-empty, else the fixed default.
(define (ucg-resolve-events-path)
  (let ((env (getenv "UI_CONTROLS_GALLERY_EVENTS_LOG" #f)))
    (if (and env (not (string=? env ""))) env ucg-default-events-path)))

;; Directory component of `p` (everything before the last '/'), or #f.
(define (ucg-path-parent p)
  (let loop ((i (- (string-length p) 1)))
    (cond
      ((< i 0) #f)
      ((char=? (string-ref p i) #\/) (substring p 0 i))
      (else (loop (- i 1))))))

;; Open + truncate the events.log: (create: 'maybe truncate: #t) creates it if
;; absent and truncates it if present. The parent dir is created if missing
;; (guarded against a race). Records are flushed per-line in ucg-emit-line, so
;; a tail sees each promptly.
(define (ucg-events-init!)
  (let* ((target (ucg-resolve-events-path))
         (parent (ucg-path-parent target)))
    (when (and parent (not (string=? parent "")) (not (file-exists? parent)))
      (with-exception-catcher (lambda (e) #f) (lambda () (create-directory parent))))
    (set! ucg-events-port
      (open-output-file (list path: target truncate: #t create: 'maybe)))))

(define (ucg-emit-line line)
  (when ucg-events-port
    ;; Swallow only I/O-level failures (out-of-disk, closed-port races on
    ;; shutdown). A genuine programmer error still surfaces during dev.
    (with-exception-catcher
      (lambda (e) #f)
      (lambda ()
        (display line ucg-events-port)
        (newline ucg-events-port)
        (force-output ucg-events-port)))))

;; Contract "Line format": strings are double-quoted with \\ / \" / newline
;; escaped; numbers/booleans/symbols emit bare.
(define (ucg-quote-string s)
  (let ((out (open-output-string)))
    (write-char #\" out)
    (let loop ((i 0))
      (when (< i (string-length s))
        (let ((c (string-ref s i)))
          (cond
            ((char=? c #\\) (display "\\\\" out))
            ((char=? c #\") (display "\\\"" out))
            ((char=? c #\newline) (display "\\n" out))
            (else (write-char c out))))
        (loop (+ i 1))))
    (write-char #\" out)
    (get-output-string out)))

(define (ucg-emit-startup)
  (ucg-emit-line "[lifecycle] startup"))
(define (ucg-emit-opened)
  (ucg-emit-line "UI Controls Gallery running. Close window or Ctrl+C to exit."))
(define (ucg-emit-shutdown reason)
  (ucg-emit-line (string-append "[lifecycle] shutdown reason=" (symbol->string reason))))

;; The four [controls] events — each emitted from its control's action
;; callback AFTER the state change it names is applied.
(define (ucg-emit-radio-selected title)
  (ucg-emit-line (string-append "[controls] radio-selected option=" (ucg-quote-string title))))

(define (ucg-emit-checkbox-changed on?)
  (ucg-emit-line (string-append "[controls] checkbox-changed state=" (if on? "on" "off"))))

;; Slider carries a double; the contract formats values as integers so the
;; clamped ends are exactly 0/100.
(define (ucg-emit-slider-changed value)
  (ucg-emit-line (string-append "[controls] slider-changed value="
                                (number->string (inexact->exact (round value))))))

;; Stepper values (0–10 step 1) are integral already.
(define (ucg-emit-stepper-changed value)
  (ucg-emit-line (string-append "[controls] stepper-changed value=" (number->string value))))

(define (ucg-close-events!)
  (when ucg-events-port
    (with-exception-catcher (lambda (e) #f)
      (lambda ()
        (force-output ucg-events-port)
        (close-output-port ucg-events-port))))
  (set! ucg-events-port #f))
;; --- End structured event log ----------------------------------------------

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

  ;; --- App delegate (terminate hook → [lifecycle] shutdown reason=menu) ---
  ;; The osascript graceful quit the runner uses (quit-impl! / the Command-Q
  ;; scenario) routes through applicationWillTerminate:. make-delegate pins
  ;; the synthesized instance in *delegate-roots* for the process (AppKit
  ;; holds the delegate weakly); this def keeps it lexically reachable too.
  ;; The body is guarded because an unhandled exception in an ObjC callback
  ;; would crash the app with no Scheme backtrace.
  (def app-delegate
    (make-delegate
      (list (list "applicationWillTerminate:"
                  (lambda (notification)
                    (with-exception-catcher (lambda (e) #f)
                      (lambda ()
                        (ucg-emit-shutdown 'menu)
                        (ucg-close-events!))))
                  (list 'object) 'void))))

  ;; Content height must exceed the 900px stack document (spec §4: the launch
  ;; size presents the whole roster): a smaller viewport starts bottom-scrolled
  ;; (the non-flipped document anchors at its origin), hiding the upper sections.
  (def window
    (make-nswindow-init-with-content-rect-style-mask-backing-defer
      (make-rect 0. 0. 500. 920.)
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

  ;; Checkbox target-action (logging contract): AppKit toggles a switch
  ;; button's state before the action fires, so the sender's state IS the
  ;; post-toggle state — `on` iff NSControlStateValueOn (1).
  (def checkbox-target
    (make-delegate
      (list (list "checkboxChanged:"
                  (lambda (sender)
                    (ucg-emit-checkbox-changed (= (nsbutton-state sender) 1)))
                  (list 'object) 'void))))

  ;; Radio container must be a stack view, not a plain NSView: the outer
  ;; stack turns off the container's autoresizing translation when arranging
  ;; it, and a plain NSView has no intrinsic size, so its ambiguous height
  ;; resolved differently per launch, shifting every row below it
  ;; nondeterministically. A nested stack view derives its intrinsic size
  ;; from the radios (orientation/spacing set alongside the outer stack's).
  (def radio-container (make-nsstackview))
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
                    (nscontrol-set-int-value! sender 1)
                    ;; Logging contract: radio-selected names the group's sole
                    ;; selection, emitted AFTER the exclusion above is applied.
                    ;; (Gambit's char-string return maps a NULL UTF8String to #f.)
                    (ucg-emit-radio-selected
                      (or (nsstring-utf8-string (nsbutton-title sender)) "")))
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
                                         (number->string (inexact->exact (round val))))))
                      ;; Logging contract: post-state, double → nearest int.
                      (ucg-emit-slider-changed val)))
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
                          (string-append "Value: " (number->string val))))
                      ;; Logging contract: post-state, integral value.
                      (ucg-emit-stepper-changed val)))
                  (list 'object) 'void))))

  ;; --- Color & image ---
  (def color-well (make-nscolorwell))
  (def image-view (make-nsimageview))

  ;; ============================================================
  ;; Expressions
  ;; ============================================================

  (nsapplication-set-activation-policy! app NSApplicationActivationPolicyRegular)
  (nsapplication-set-delegate! app app-delegate)
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
  (nscontrol-set-target! checkbox checkbox-target)
  (nscontrol-set-action! checkbox "checkboxChanged:")
  (nsstackview-add-arranged-subview! stack-view checkbox)

  (nsview-set-frame! radio-container (make-rect 0. 0. 460. 24.))
  (nsstackview-set-orientation! radio-container NSUserInterfaceLayoutOrientationHorizontal)
  (nsstackview-set-spacing! radio-container 5.)

  (nsview-set-frame! radio-a (make-rect 0. 0. 100. 24.))
  (nsbutton-set-button-type! radio-a NSButtonTypeRadio)
  (nsbutton-set-title! radio-a (string->nsstring "Option A"))
  (nscontrol-set-int-value! radio-a 1)
  (nsstackview-add-arranged-subview! radio-container radio-a)

  (nsview-set-frame! radio-b (make-rect 105. 0. 100. 24.))
  (nsbutton-set-button-type! radio-b NSButtonTypeRadio)
  (nsbutton-set-title! radio-b (string->nsstring "Option B"))
  (nsstackview-add-arranged-subview! radio-container radio-b)

  (nsview-set-frame! radio-c (make-rect 210. 0. 100. 24.))
  (nsbutton-set-button-type! radio-c NSButtonTypeRadio)
  (nsbutton-set-title! radio-c (string->nsstring "Option C"))
  (nsstackview-add-arranged-subview! radio-container radio-c)

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

  ;; Launch diagnostic (spec §3.6): the bare line containing `Controls
  ;; Gallery` the runner's `wait-for-log` matches, dual-emitted to events.log
  ;; (the runner's read path) and stdout (human-friendly when run unbundled;
  ;; LaunchServices discards stdout under `open`).
  (ucg-emit-opened)
  (displayln "UI Controls Gallery running. Close window or Ctrl+C to exit.")
  (nsapplication-run app))

;; --- Structured event log: open + [lifecycle] startup BEFORE (main) --------
;; The gallery builds its controls in main's *defines* section (the def
;; initializers evaluate before main's first expression), so `startup` cannot
;; be main's first expression as in hello-window — it lands here instead,
;; before (main) is entered and thus before gallery construction, well before
;; the run loop (or the runner's `wait-ready` readiness probe times out).
(ucg-events-init!)
(ucg-emit-startup)

;; Test-config compatibility (logging-contract.md): the gallery reads no
;; runtime config, so it honours UI_CONTROLS_GALLERY_TEST_CONFIG by reading
;; the env var and treating absent/empty (and a missing file) as "no config"
;; — a deliberate no-op.
(getenv "UI_CONTROLS_GALLERY_TEST_CONFIG" #f)

(main)
