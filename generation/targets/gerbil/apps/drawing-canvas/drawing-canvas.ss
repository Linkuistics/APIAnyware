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
    (nsview-set-needs-display! self #t)))

(defmethod (DrawingCanvasView "mouseDragged:") (self event)
  (let (pt (event->view-point self event))
    (extend-stroke! (point-x pt) (point-y pt))
    (nsview-set-needs-display! self #t)))

(defmethod (DrawingCanvasView "mouseUp:") (self event)
  (end-stroke!)
  (nsview-set-needs-display! self #t))

;; ============================================================
;; main
;; ============================================================
(define-entry-point (main)

  ;; --- Definitions (all internal defs precede every expression) ---
  (def app (nsapplication-shared-application))

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
                (set! current-width (nscontrol-double-value width-slider)))
              (list 'object) 'void)
        (list "clearCanvas:"
              (lambda (sender)
                (clear-strokes!)
                (nsview-set-needs-display! canvas #t))
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
                        (set! current-b (nscolor-blue-component rgb)))))))
              (list 'object) 'void))))

  ;; --- Expressions ---

  (nsapplication-set-activation-policy! app NSApplicationActivationPolicyRegular)
  (install-standard-app-menu! app "Drawing Canvas")

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

  (displayln "Drawing Canvas running. Close window or Ctrl+C to exit.")
  (nsapplication-run app))

(main)
