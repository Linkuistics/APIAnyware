;;; drawing-canvas.ss — Drawing Canvas sample app (gerbil target).
;;;
;;; Freehand drawing app with per-stroke colour and line width. A real ObjC
;;; subclass of NSView (`DrawingCanvasView`) overrides drawRect: and the three
;;; mouse-event methods; stroke state lives in top-level mutable bindings the
;;; overrides close over. Mirrors
;;; generation/targets/chez/apps/drawing-canvas/drawing-canvas.sls
;;; (and racket's drawing-canvas.rkt) one piece at a time.
;;;
;;; This is the gerbil target's showcase for transparent extensible subclassing
;;; (ADR-0020, runtime/subclass.ss): AppKit calls *into* Gerbil for drawRect: and
;;; the mouse events, on its own schedule, for the view's lifetime. Three things
;;; make that safe and idiomatic:
;;;
;;;   1. `(defclass (DrawingCanvasView NSView) ())` synthesizes + registers a real
;;;      ObjC subclass at load (objc_allocateClassPair + objc_registerClassPair);
;;;      each `(defmethod (DrawingCanvasView "sel") …)` installs an IMP via a
;;;      post-registration class_addMethod. `(new DrawingCanvasView)` alloc+inits
;;;      an instance and records the ObjC-ptr → Gerbil-instance back-reference, so
;;;      the instance is retained for the process and the overrides recover the
;;;      typed self. No manual alloc/initWithFrame: msgSend.
;;;
;;;   2. drawRect:'s `CGRect dirtyRect` is a struct → UNDELIVERABLE by the generic
;;;      trampoline (it rides struct/FP registers), so the override receives ONLY
;;;      `self`. We draw the whole bounds, as the racket/chez ports do. The mouse
;;;      selectors take an `event` object (deliverable) → `(self event)`.
;;;
;;;   3. State + the subclass live at TOP LEVEL (cf. racket's module-level
;;;      dynamic-class bindings), not inside `main`: Gerbil's `defclass` is a
;;;      definition form, and a single-window app's drawing state is naturally
;;;      process-scoped. The toolbar delegate (in `main`) closes over the same
;;;      top-level state plus its main-local view/control bindings.
;;;
;;; Instrumented for the AppSpec scenario runner per the Drawing Canvas
;;; logging contract (apps/macos/drawing-canvas/docs/logging-contract.md,
;;; k132): it writes a structured events.log the runner tails — [lifecycle]
;;; startup/shutdown, the bare launch line, and the five [canvas] stroke/tool
;;; events (inline dc- emitter below, the note-editor k127 house style;
;;; gerbil-instrument-build-k136). Under `launch-via 'open` LaunchServices
;;; discards the app's stdout, so the log file (not stdout) is the runner's
;;; read path; the stdout line is kept too (human-friendly when run
;;; unbundled).
;;;
;;; Build via build.sh (bottle toolchain); bundle via bundle-gerbil.
(import :gerbil-bindings/runtime/objc
        :gerbil-bindings/runtime/cocoa
        :gerbil-bindings/runtime/subclass
        :gerbil-bindings/appkit/nsapplication
        :gerbil-bindings/appkit/nswindow
        :gerbil-bindings/appkit/nsview
        :gerbil-bindings/appkit/nscontrol
        :gerbil-bindings/appkit/nsbutton
        :gerbil-bindings/appkit/nsslider
        :gerbil-bindings/appkit/nsevent
        :gerbil-bindings/appkit/nsgraphicscontext
        :gerbil-bindings/appkit/nscolorpanel
        :gerbil-bindings/appkit/nscolor
        :gerbil-bindings/appkit/nscolorspace
        :gerbil-bindings/appkit/enums
        :gerbil-bindings/coregraphics/functions
        :gerbil-bindings/coregraphics/enums)
(export main)

;; ============================================================
;; Mutable drawing state (top-level; overrides close over it)
;; ============================================================
;;
;; A stroke = (vector r g b width (listof (cons x y))). RGB and width are
;; captured at mouse-down time so changing colour/width mid-drag would not
;; affect the in-progress stroke — and changing them later does not
;; retroactively alter existing strokes.
;;
;; `strokes` holds completed + in-progress strokes in chronological order.
;; `current-points` accumulates points for the active stroke as a reverse list
;; (cheaper than append); finalised into the last entry on mouseUp:.
(def strokes '())
(def current-r 0.0)
(def current-g 0.0)
(def current-b 0.0)
(def current-width 2.0)
(def drawing? #f)
(def current-points '())  ; reverse list of (cons x y), newest first

(def (start-stroke! x y)
  (set! drawing? #t)
  (set! current-points (list (cons x y)))
  (set! strokes
    (append strokes
            (list (vector current-r current-g current-b current-width
                          (list (cons x y)))))))

(def (extend-stroke! x y)
  (when drawing?
    (set! current-points (cons (cons x y) current-points))
    ;; Replace last stroke in-place with the extended point list.
    (let* ((rev  (reverse (cdr (reverse strokes))))
           (last (car (reverse strokes)))
           (updated
            (vector (vector-ref last 0) (vector-ref last 1)
                    (vector-ref last 2) (vector-ref last 3)
                    (reverse current-points))))
      (set! strokes (append rev (list updated))))))

(def (end-stroke!)
  (set! drawing? #f)
  (set! current-points '()))

(def (clear-strokes!)
  (set! strokes '())
  (set! drawing? #f)
  (set! current-points '()))

;; ============================================================
;; Structured event log (logging contract)
;; ============================================================
;; The k132 logging contract (apps/macos/drawing-canvas/docs/
;; logging-contract.md): the three hello-window lifecycle events plus the
;; five [canvas] state transitions the spec §14 assertions ride — the canvas
;; is a custom NSView whose strokes are framebuffer pixels, OCR-meaningless
;; and AX-invisible (spec §12), so without log events stroke lifecycle and
;; tool state are not assertable at all. No event in this app carries a
;; string value, so the quote-string helper is omitted — every value is a
;; bare integer or symbol per the contract's line format.
;;
;; The logging is inlined here rather than split to a sibling events.ss for
;; the same reason as the prior instrumented gerbil apps: the bundler's
;; closure walk (deps.rs) follows only `:gerbil-bindings/…` references, and
;; these defines use only Gambit primitives (open-output-file, getenv,
;; create-directory, force-output), so they ride the statically-linked
;; prelude with no new import.
;;
;; Single writer: every event is emitted on the main thread — startup and
;; the launch line before -run; the [canvas] events from the canvas
;; subclass's mouse overrides (AppKit event dispatch), the slider and Clear
;; action handlers, and the colour panel's continuous colorChanged: action
;; (the shared NSColorPanel is in-process; the Cocoa run loop serialises its
;; sends); shutdown on the terminate path — so one port with a post-write
;; force-output suffices (no lock).

;; Fixed default the descriptor's #:events-path mirrors, so the runner tails
;; the same file whether or not #:log-env (DRAWING_CANVAS_EVENTS_LOG)
;; propagates through LaunchServices.
(define dc-default-events-path "/tmp/drawing-canvas/events.log")
(define dc-events-port #f)

;; DRAWING_CANVAS_EVENTS_LOG if set and non-empty, else the fixed default.
(define (dc-resolve-events-path)
  (let ((env (getenv "DRAWING_CANVAS_EVENTS_LOG" #f)))
    (if (and env (not (string=? env ""))) env dc-default-events-path)))

;; Directory component of `p` (everything before the last '/'), or #f.
(define (dc-path-parent p)
  (let loop ((i (- (string-length p) 1)))
    (cond
      ((< i 0) #f)
      ((char=? (string-ref p i) #\/) (substring p 0 i))
      (else (loop (- i 1))))))

;; Open + truncate the events.log: (create: 'maybe truncate: #t) creates it
;; if absent and truncates it if present. The parent dir is created if
;; missing (guarded against a race). Records are flushed per-line in
;; dc-emit-line, so a tail sees each promptly.
(define (dc-events-init!)
  (let* ((target (dc-resolve-events-path))
         (parent (dc-path-parent target)))
    (when (and parent (not (string=? parent "")) (not (file-exists? parent)))
      (with-exception-catcher (lambda (e) #f) (lambda () (create-directory parent))))
    (set! dc-events-port
      (open-output-file (list path: target truncate: #t create: 'maybe)))))

(define (dc-emit-line line)
  (when dc-events-port
    ;; Swallow only I/O-level failures (out-of-disk, closed-port races on
    ;; shutdown). A genuine programmer error still surfaces during dev.
    (with-exception-catcher
      (lambda (e) #f)
      (lambda ()
        (display line dc-events-port)
        (newline dc-events-port)
        (force-output dc-events-port)))))

;; Stored double -> bare integer, rounded to nearest (the ONE rounding
;; site): r/g/b are the stored device-RGB components x 255, width the stored
;; width (contract "Canvas events"). Rounding once here means every event
;; formatting the same stored double agrees — the freeze proof rides that
;; agreement.
(define (dc-component->255 c) (number->string (inexact->exact (round (* c 255.)))))
(define (dc-width->int w)     (number->string (inexact->exact (round w))))

(define (dc-emit-startup)
  (dc-emit-line "[lifecycle] startup"))
(define (dc-emit-launch-line)
  (dc-emit-line "Drawing Canvas running. Close window or Ctrl+C to exit."))
(define (dc-emit-shutdown reason)
  (dc-emit-line (string-append "[lifecycle] shutdown reason=" (symbol->string reason))))

;; The two stroke events (contract "Canvas events"): the caller passes the
;; STROKE'S OWN frozen components/width (captured into the stroke vector at
;; its mouse-down — read from the stroke, never from the current-* tool
;; state), plus the stored point count on commit (down point + drag points;
;; the release is not appended). Fixed key order r · g · b · width (· points).
(define (dc-emit-stroke-begun r g b width)
  (dc-emit-line (string-append "[canvas] stroke-begun"
                               " r=" (dc-component->255 r)
                               " g=" (dc-component->255 g)
                               " b=" (dc-component->255 b)
                               " width=" (dc-width->int width))))

(define (dc-emit-stroke-committed r g b width points)
  (dc-emit-line (string-append "[canvas] stroke-committed"
                               " r=" (dc-component->255 r)
                               " g=" (dc-component->255 g)
                               " b=" (dc-component->255 b)
                               " width=" (dc-width->int width)
                               " points=" (number->string points))))

;; Success-path only (§8.1 step 4): emitted after the device-RGB components
;; are stored; the silent no-ops (nil panel colour, failed conversion) emit
;; nothing.
(define (dc-emit-color-changed r g b)
  (dc-emit-line (string-append "[canvas] color-changed"
                               " r=" (dc-component->255 r)
                               " g=" (dc-component->255 g)
                               " b=" (dc-component->255 b))))

(define (dc-emit-width-changed width)
  (dc-emit-line (string-append "[canvas] width-changed width=" (dc-width->int width))))

;; Always emitted, including on an already-empty canvas (count=0) — the
;; positive channel for stroke-set cardinality.
(define (dc-emit-cleared count)
  (dc-emit-line (string-append "[canvas] cleared count=" (number->string count))))

(define (dc-close-events!)
  (when dc-events-port
    (with-exception-catcher (lambda (e) #f)
      (lambda ()
        (force-output dc-events-port)
        (close-output-port dc-events-port))))
  (set! dc-events-port #f))
;; --- End structured event log ----------------------------------------------

;; --- Stroke rendering ---
;;
;; Iterate strokes, rendering each as a stroked polyline. Per-stroke
;; colour/width forces one BeginPath/StrokePath pair per stroke — they can't
;; be batched into a single path because stroke colour is graphics-state, not
;; per-subpath. `ctx` is the raw CGContextRef from nsgraphicscontext-cg-context.
;;
;; Line cap/join use kCGLineCapRound + kCGLineJoinRound so:
;;   - A single-point stroke paints a filled disc (the round cap draws a circle
;;     of diameter = line width), letting a bare click produce a visible dot
;;     without any special-case branch.
;;   - Direction changes during a drag look smooth instead of mitred.
(def (render-strokes ctx strokes)
  (for-each
    (lambda (stroke)
      (let ((r      (vector-ref stroke 0))
            (g      (vector-ref stroke 1))
            (b      (vector-ref stroke 2))
            (width  (vector-ref stroke 3))
            (points (vector-ref stroke 4)))
        (unless (null? points)
          (CGContextSetRGBStrokeColor ctx r g b 1.0)
          (CGContextSetLineWidth ctx width)
          (CGContextSetLineCap ctx kCGLineCapRound)
          (CGContextSetLineJoin ctx kCGLineJoinRound)
          (CGContextBeginPath ctx)
          (let (first (car points))
            (CGContextMoveToPoint ctx (car first) (cdr first))
            ;; For a single-point stroke, add a coincident second point so
            ;; StrokePath has a non-empty path to paint; the round cap then
            ;; produces a circular dot centred on the click.
            (if (null? (cdr points))
              (CGContextAddLineToPoint ctx (car first) (cdr first))
              (for-each
                (lambda (pt) (CGContextAddLineToPoint ctx (car pt) (cdr pt)))
                (cdr points))))
          (CGContextStrokePath ctx))))
    strokes))

;; Event → view-local point. locationInWindow is in window coords; passing
;; fromView: #f converts to the receiver's own coord system (NSView default:
;; bottom-left origin, unflipped). `self` is the typed DrawingCanvasView the
;; override received; the returned CGPoint crosses by value into point-x/point-y.
(def (event->view-point self event)
  (let (window-pt (nsevent-location-in-window event))
    (nsview-convert-point-from-view self window-pt #f)))

;; ============================================================
;; DrawingCanvasView — a real ObjC subclass of NSView (ADR-0020)
;; ============================================================
(defclass (DrawingCanvasView NSView) ())

;; drawRect: — the CGRect dirtyRect is undeliverable, so the override gets only
;; `self`. Pull the current NSGraphicsContext's CGContextRef and repaint.
(defmethod (DrawingCanvasView "drawRect:") (self)
  (let (gc (nsgraphicscontext-current-context))
    (when gc
      (render-strokes (nsgraphicscontext-cg-context gc) strokes))))

(defmethod (DrawingCanvasView "mouseDown:") (self event)
  (let (pt (event->view-point self event))
    (start-stroke! (point-x pt) (point-y pt))
    (nsview-set-needs-display! self #t)
    ;; [canvas] stroke-begun — end of the §7.2 mouse-down rule, post-state.
    ;; Format the STROKE'S OWN frozen colour+width (the vector captured them
    ;; at seed time), never the current-* tool state at emit time.
    (let (stroke (car (reverse strokes)))
      (dc-emit-stroke-begun
        (vector-ref stroke 0) (vector-ref stroke 1)
        (vector-ref stroke 2) (vector-ref stroke 3)))))

(defmethod (DrawingCanvasView "mouseDragged:") (self event)
  (let (pt (event->view-point self event))
    (extend-stroke! (point-x pt) (point-y pt))
    (nsview-set-needs-display! self #t)))

(defmethod (DrawingCanvasView "mouseUp:") (self event)
  ;; Capture the in-progress stroke before the flags clear; its vector
  ;; (frozen colour/width + final point list) stays in `strokes`. A mouseUp
  ;; with no stroke in progress (AppKit routes the up to the mouseDown view,
  ;; so this should not occur) emits nothing — the stroke events fire only
  ;; for gestures that reached the canvas.
  (let (stroke (and drawing? (pair? strokes) (car (reverse strokes))))
    (end-stroke!)
    (nsview-set-needs-display! self #t)
    ;; [canvas] stroke-committed — end of the §7.2 mouse-up rule, post-state.
    ;; Same frozen tuple as its stroke-begun; points = the stored count
    ;; (down point + drag points; the release is never appended).
    (when stroke
      (dc-emit-stroke-committed
        (vector-ref stroke 0) (vector-ref stroke 1)
        (vector-ref stroke 2) (vector-ref stroke 3)
        (length (vector-ref stroke 4))))))

;; ============================================================
;; main
;; ============================================================
(define-entry-point (main)

  ;; --- Definitions (all internal defs precede every expression) ---
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
                        (dc-emit-shutdown 'menu)
                        (dc-close-events!))))
                  (list 'object) 'void))))

  (def window-width  640.)
  (def window-height 480.)
  (def toolbar-height 36.)
  (def toolbar-y (- window-height toolbar-height))

  (def window
    (make-nswindow-init-with-content-rect-style-mask-backing-defer
      (make-rect 0. 0. window-width window-height)
      (bitwise-ior NSWindowStyleMaskTitled
                   NSWindowStyleMaskClosable
                   NSWindowStyleMaskMiniaturizable
                   NSWindowStyleMaskResizable)
      NSBackingStoreBuffered
      #f))

  (def content-view (nswindow-content-view window))

  ;; Canvas fills everything below the toolbar. NSView's unflipped coordinate
  ;; system: origin (0,0) at bottom-left. Instantiate via `new` (the runtime
  ;; alloc+inits the synthesized class and records the back-reference), then
  ;; size it with setFrame:.
  (def canvas (new DrawingCanvasView))

  ;; --- Toolbar controls (Color… / width slider / Clear) ---
  (def color-button (make-nsbutton))
  (def width-slider (make-nsslider))
  (def clear-button (make-nsbutton))

  ;; All three actions plus the colour-panel callback live on one delegate so a
  ;; single binding anchors them. The `'object` token wraps `sender` to a bound
  ;; instance; the delegate object flows straight into the *-set-target! setters.
  (def toolbar-target
    (make-delegate
      (list
        (list "openColor:"
              (lambda (sender)
                ;; The panel fires its action selector on `target` every time the
                ;; user changes the colour (continuous); routing through this same
                ;; delegate keeps state in one place.
                (let (panel (nscolorpanel-shared-color-panel))
                  (nscolorpanel-set-target! panel toolbar-target)
                  (nscolorpanel-set-action! panel "colorChanged:")
                  (nscolorpanel-set-continuous! panel #t)
                  (nswindow-make-key-and-order-front panel #f)))
              (list 'object) 'void)
        (list "widthChanged:"
              (lambda (sender)
                (set! current-width (nscontrol-double-value width-slider))
                ;; [canvas] width-changed — post-store (§8.2). Continuous
                ;; slider: many lines per drag is contract-conformant (never
                ;; count events).
                (dc-emit-width-changed current-width))
              (list 'object) 'void)
        (list "clearCanvas:"
              (lambda (sender)
                ;; count = strokes removed (an in-progress stroke is in
                ;; `strokes`, so a mid-gesture Clear counts it); captured
                ;; before the collection empties.
                (let (count (length strokes))
                  (clear-strokes!)
                  (nsview-set-needs-display! canvas #t)
                  ;; [canvas] cleared — end of the §8.3 Clear rule,
                  ;; post-state; ALWAYS emitted, count=0 on an already-empty
                  ;; canvas (the stroke-set cardinality channel).
                  (dc-emit-cleared count)))
              (list 'object) 'void)
        (list "colorChanged:"
              (lambda (sender)
                ;; sender is the NSColorPanel. Its `color` is in the panel's
                ;; current colour space; red/green/blueComponent only work on
                ;; RGB-family colours. Normalise to device RGB first so component
                ;; extraction is always safe.
                (let (raw (nscolorpanel-color sender))
                  (when raw
                    (let (rgb (nscolor-color-using-color-space
                                raw (nscolorspace-device-rgb-color-space)))
                      (when rgb
                        (set! current-r (nscolor-red-component rgb))
                        (set! current-g (nscolor-green-component rgb))
                        (set! current-b (nscolor-blue-component rgb))
                        ;; [canvas] color-changed — success path only,
                        ;; post-store (§8.1 step 4). The silent no-ops above
                        ;; (nil panel colour, failed device-RGB conversion)
                        ;; emit nothing; gerbil carries no stderr guard and
                        ;; needs none (contract note).
                        (dc-emit-color-changed
                          current-r current-g current-b))))))
              (list 'object) 'void))))

  ;; --- Expressions ---

  (nsapplication-set-activation-policy! app NSApplicationActivationPolicyRegular)
  (install-standard-app-menu! app "Drawing Canvas")
  (nsapplication-set-delegate! app app-delegate)

  (nswindow-set-title! window (string->nsstring "Drawing Canvas"))
  (nswindow-center! window)
  (nswindow-set-min-size! window (make-size 400. 300.))

  ;; Canvas — fills below the toolbar, grows with the window.
  (nsview-set-frame! canvas (make-rect 0. 0. window-width (- window-height toolbar-height)))
  (nsview-set-autoresizing-mask! canvas
    (bitwise-ior NSViewWidthSizable NSViewHeightSizable))
  (nsview-add-subview! content-view canvas)

  ;; Colour button (top-left, pinned to top edge via MinYMargin).
  (nsview-set-frame! color-button (make-rect 12. (+ toolbar-y 4.) 96. 28.))
  (nsbutton-set-title! color-button (string->nsstring "Color…"))
  (nsbutton-set-bezel-style! color-button NSBezelStyleRounded)
  (nsview-set-autoresizing-mask! color-button NSViewMinYMargin)
  (nsview-add-subview! content-view color-button)

  ;; Width slider (continuous, 1–20 px).
  (nsview-set-frame! width-slider (make-rect 120. (+ toolbar-y 6.) 200. 24.))
  (nsslider-set-min-value! width-slider 1.)
  (nsslider-set-max-value! width-slider 20.)
  (nscontrol-set-double-value! width-slider current-width)
  (nscontrol-set-continuous! width-slider #t)
  (nsview-set-autoresizing-mask! width-slider NSViewMinYMargin)
  (nsview-add-subview! content-view width-slider)

  ;; Clear button anchors to the right edge: MinXMargin keeps the left margin
  ;; elastic (button slides with the right edge) while MinYMargin pins vertical.
  (nsview-set-frame! clear-button (make-rect (- window-width 88.) (+ toolbar-y 4.) 76. 28.))
  (nsbutton-set-title! clear-button (string->nsstring "Clear"))
  (nsbutton-set-bezel-style! clear-button NSBezelStyleRounded)
  (nsview-set-autoresizing-mask! clear-button
    (bitwise-ior NSViewMinXMargin NSViewMinYMargin))
  (nsview-add-subview! content-view clear-button)

  ;; Wire target-action.
  (nscontrol-set-target! color-button toolbar-target)
  (nscontrol-set-action! color-button "openColor:")
  (nscontrol-set-target! width-slider toolbar-target)
  (nscontrol-set-action! width-slider "widthChanged:")
  (nscontrol-set-target! clear-button toolbar-target)
  (nscontrol-set-action! clear-button "clearCanvas:")

  ;; Show window and run.
  (nswindow-make-key-and-order-front window #f)
  (nsapplication-activate-ignoring-other-apps app #t)

  ;; §3 step 6 launch diagnostic — dual emission (contract "Lifecycle
  ;; events"): the stdout line stays (human-friendly when run unbundled,
  ;; literally true to §3); the same BARE line goes to events.log, where the
  ;; runner can see it (LaunchServices discards stdout under `open`).
  (dc-emit-launch-line)
  (displayln "Drawing Canvas running. Close window or Ctrl+C to exit.")
  (nsapplication-run app))

;; --- Structured event log: open + [lifecycle] startup BEFORE (main) --------
;; The app builds its window/canvas in `main`'s defines section (the def
;; initializers evaluate before main's first expression), so `startup`
;; cannot be main's first expression — it lands here instead, before (main)
;; is entered and thus before window/canvas construction, well before the
;; run loop (or the runner's `wait-ready` readiness probe times out).
(dc-events-init!)
(dc-emit-startup)

;; Test-config compatibility (logging-contract.md): the canvas reads no
;; runtime config, so it honours DRAWING_CANVAS_TEST_CONFIG by reading the
;; env var and treating absent/empty (and a missing file) as "no config" — a
;; deliberate no-op.
(getenv "DRAWING_CANVAS_TEST_CONFIG" #f)

(main)
