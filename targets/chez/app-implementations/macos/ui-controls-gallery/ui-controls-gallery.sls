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
;; Instrumented for the AppSpec scenario runner per the UI Controls Gallery
;; logging contract (apps/macos/ui-controls-gallery/docs/logging-contract.md):
;; it writes a structured events.log the runner tails — [lifecycle]
;; startup/shutdown, the bare launch line, and the four [controls]
;; state-change events (radio/checkbox/slider/stepper) that make the spec §13
;; interaction assertions observable (the runner's expect-ax has no
;; value/state read). Under `launch-via 'open` LaunchServices discards the
;; app's stdout, so the log file (not stdout) is the runner's read path; the
;; stdout line is kept too (human-friendly when run unbundled, §3.6).
;;
;; The logging is inlined here rather than extracted to a sibling `events.sls`
;; for the same reason as hello-window: chez resolves `(import …)` by
;; library-name→path against the whole-program compile tree, so a sibling
;; library would need an `apps/`-prefixed name. These top-level defines use
;; only (chezscheme) names, so the standalone bundler resolves them with no
;; new library on the path.
;;
;; Run unbundled with:
;;   chez --libdirs targets/chez/bindings/macos \
;;        --script targets/chez/app-implementations/macos/ui-controls-gallery/ui-controls-gallery.sls
;; Bundled (the runnable artifact) via build.sh, which wraps
;;   `cargo run --example bundle_app -p apianyware-bundle-chez
;;    -- ui-controls-gallery`.

(import (chezscheme)
        (apianyware appkit)
        (apianyware foundation)
        (apianyware runtime cocoa)
        (apianyware runtime objc)
        (apianyware runtime types)
        (apianyware runtime dispatch))

;; --- Structured event log (logging contract) -------------------------------
;; Single writer: the Cocoa run loop serialises the main-thread callbacks that
;; emit — startup/launch before -run, the [controls] events from action
;; callbacks, shutdown on terminate — so one port with a post-write flush
;; suffices (no lock needed).

;; Fixed default the descriptor's #:events-path mirrors, so the runner tails
;; the same file whether or not #:log-env (UI_CONTROLS_GALLERY_EVENTS_LOG)
;; propagates through LaunchServices.
(define ucg-default-events-path "/tmp/ui-controls-gallery/events.log")
(define ucg-events-port #f)

;; UI_CONTROLS_GALLERY_EVENTS_LOG if set and non-empty, else the fixed default.
(define (ucg-resolve-events-path)
  (let ([env (getenv "UI_CONTROLS_GALLERY_EVENTS_LOG")])
    (if (and env (not (string=? env ""))) env ucg-default-events-path)))

;; Directory component of `p` (everything before the last '/'), or #f.
(define (ucg-path-parent p)
  (let loop ([i (- (string-length p) 1)])
    (cond
      [(< i 0) #f]
      [(char=? (string-ref p i) #\/) (substring p 0 i)]
      [else (loop (- i 1))])))

;; Open + truncate the events.log: (file-options no-fail) creates it if absent
;; and truncates it if present. Line-buffered so a tail sees each record
;; promptly. The parent dir is created if missing (guarded against a race).
(define (ucg-events-init!)
  (let* ([target (ucg-resolve-events-path)]
         [parent (ucg-path-parent target)])
    (when (and parent (not (string=? parent "")) (not (file-directory? parent)))
      (guard (e [#t (void)]) (mkdir parent)))
    (set! ucg-events-port
      (open-file-output-port target
        (file-options no-fail)
        (buffer-mode line)
        (make-transcoder (utf-8-codec))))))

(define (ucg-emit-line line)
  (when ucg-events-port
    ;; Swallow only I/O-level failures (out-of-disk, closed-port races on
    ;; shutdown). A genuine programmer error still surfaces during dev.
    (guard (e [#t (void)])
      (put-string ucg-events-port line)
      (put-char ucg-events-port #\newline)
      (flush-output-port ucg-events-port))))

;; Contract "Line format": strings are double-quoted with \\ / \" / newline
;; escaped; numbers/booleans/symbols emit bare.
(define (ucg-quote-string s)
  (let ([out (open-output-string)])
    (put-char out #\")
    (string-for-each
      (lambda (c)
        (case c
          [(#\\) (put-string out "\\\\")]
          [(#\") (put-string out "\\\"")]
          [(#\newline) (put-string out "\\n")]
          [else (put-char out c)]))
      s)
    (put-char out #\")
    (get-output-string out)))

(define (ucg-emit-startup)
  (ucg-emit-line "[lifecycle] startup"))
(define (ucg-emit-opened)
  (ucg-emit-line "UI Controls Gallery running. Close window or Ctrl+C to exit."))
(define (ucg-emit-shutdown reason)
  (ucg-emit-line (format "[lifecycle] shutdown reason=~a" reason)))

;; The four [controls] events — each emitted from its control's action
;; callback AFTER the state change it names is applied.
(define (ucg-emit-radio-selected title)
  (ucg-emit-line (format "[controls] radio-selected option=~a" (ucg-quote-string title))))

(define (ucg-emit-checkbox-changed on?)
  (ucg-emit-line (format "[controls] checkbox-changed state=~a" (if on? "on" "off"))))

;; Slider carries a double; the contract formats values as integers so the
;; clamped ends are exactly 0/100.
(define (ucg-emit-slider-changed value)
  (ucg-emit-line (format "[controls] slider-changed value=~a" (exact (round value)))))

;; Stepper values (0–10 step 1) are integral already.
(define (ucg-emit-stepper-changed value)
  (ucg-emit-line (format "[controls] stepper-changed value=~a" value)))

(define (ucg-close-events!)
  (when ucg-events-port
    (guard (e [#t (void)])
      (flush-output-port ucg-events-port)
      (close-output-port ucg-events-port)))
  (set! ucg-events-port #f))

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

  ;; --- App delegate (terminate hook → [lifecycle] shutdown reason=menu) ---
  ;; The osascript graceful quit the runner uses (quit-impl! / the Command-Q
  ;; scenario) routes through applicationWillTerminate:. Cocoa holds the
  ;; delegate weakly, so keep `app-delegate` reachable — this define lives for
  ;; the whole of `main`, which spans the run loop. The callback body is
  ;; guarded because an unhandled exception in an ObjC callback crashes the
  ;; app with no Scheme backtrace.
  (define app-delegate
    (make-delegate
      `(("applicationWillTerminate:"
         ,(lambda (notification)
            (guard (e [#t (void)])
              (ucg-emit-shutdown 'menu)
              (ucg-close-events!)))
         (void*) void))))

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

  ;; Checkbox target-action (logging contract): AppKit toggles a switch
  ;; button's state before the action fires, so the sender's state IS the
  ;; post-toggle state — `on` iff NSControlStateValueOn (1).
  (define checkbox-target
    (make-delegate
      `(("checkboxChanged:"
         ,(lambda (sender)
            (ucg-emit-checkbox-changed
              (= (nsbutton-state (borrow-objc-object sender)) 1)))
         (void*) void))))

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
            (let ([btn (borrow-objc-object sender)])
              (nsbutton-set-int-value! radio-a 0)
              (nsbutton-set-int-value! radio-b 0)
              (nsbutton-set-int-value! radio-c 0)
              (nsbutton-set-int-value! btn 1)
              ;; Logging contract: radio-selected names the group's sole
              ;; selection, emitted AFTER the exclusion above is applied.
              ;; (The FFI's `string` return maps a NULL UTF8String to #f.)
              (ucg-emit-radio-selected
                (or (nsstring-utf8-string (nsbutton-title btn)) ""))))
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
                (format #f "Value: ~a" (exact (round val))))
              ;; Logging contract: post-state, double → nearest int.
              (ucg-emit-slider-changed val)))
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
                (format #f "Value: ~a" val))
              ;; Logging contract: post-state, integral value.
              (ucg-emit-stepper-changed val)))
         (void*) void))))

  ;; --- Color & image ---
  (define color-well (make-nscolorwell-init-with-frame (make-nsrect 0 0 44 28)))
  (define image-view (make-nsimageview-init-with-frame (make-nsrect 0 0 48 48)))

  ;; ============================================================
  ;; Expressions
  ;; ============================================================

  (nsapplication-set-activation-policy! app NSApplicationActivationPolicyRegular)
  (nsapplication-set-delegate! app (delegate-ptr app-delegate))
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
  (nsbutton-set-target! checkbox (delegate-ptr checkbox-target))
  (nsbutton-set-action! checkbox "checkboxChanged:")
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

  ;; Launch diagnostic (spec §3.6): the bare line containing `Controls
  ;; Gallery` the runner's `wait-for-log` matches, dual-emitted to events.log
  ;; (the runner's read path) and stdout (human-friendly when run unbundled;
  ;; LaunchServices discards stdout under `open`).
  (ucg-emit-opened)
  (display "UI Controls Gallery running. Close window or Ctrl+C to exit.\n")
  (nsapplication-run app))

;; --- Structured event log: open + [lifecycle] startup BEFORE (main) --------
;; The gallery builds its controls in `main`'s defines section (R6RS body:
;; all defines precede every expression), so `startup` cannot be main's first
;; expression as in hello-window — it lands here instead, before (main) is
;; entered and thus before gallery construction, well before the run loop
;; (or the runner's `wait-ready` readiness probe times out).
(ucg-events-init!)
(ucg-emit-startup)

;; Test-config compatibility (logging-contract.md): the gallery reads no
;; runtime config, so it honours UI_CONTROLS_GALLERY_TEST_CONFIG by reading
;; the env var and treating absent/empty (and a missing file) as "no config"
;; — a deliberate no-op.
(getenv "UI_CONTROLS_GALLERY_TEST_CONFIG")

(main)
