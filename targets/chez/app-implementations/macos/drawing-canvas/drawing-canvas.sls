;; drawing-canvas.sls — Drawing Canvas sample app (chez target).
;;
;; Freehand drawing app with per-stroke colour and line width. A dynamic
;; ObjC subclass of NSView (`DrawingCanvasView`) overrides drawRect: and the
;; three mouse-event methods; stroke state lives in mutable bindings inside
;; `main` and is read from inside the ObjC callbacks. Mirrors
;; generation/targets/racket/apps/drawing-canvas/drawing-canvas.rkt.
;;
;; This is the first — and only — chez app with a **dynamic NSView
;; subclass**, so it is where `make-dynamic-subclass` (runtime/dispatch.sls)
;; gets exercised under live AppKit dispatch: AppKit calls *into* Scheme for
;; drawRect: and the mouse events, on its own schedule, for the view's
;; lifetime. Three things make that safe:
;;
;;   1. IMP retention. `make-dynamic-subclass` builds one `foreign-callable`
;;      per method, `lock-object`s its code, and stashes the handles in a
;;      process-lifetime hashtable keyed by Class pointer. The IMP entry
;;      pointers libobjc holds therefore stay live forever — which is what
;;      a registered class expects. So unlike the racket port (whose
;;      dynamic-class.rkt mandates *module-level* function-ptr bindings to
;;      pin the IMPs), the chez IMP procedures can be ordinary `letrec*`
;;      locals inside `main`: `lock-object` + the runtime hashtable do the
;;      pinning, and the procedures stay reachable because the runtime's
;;      callable table holds them. Module-level binding is unnecessary.
;;
;;   2. (self _cmd arg ...) convention. A dynamic-class IMP is the
;;      foreign-callable pointer *directly* (no Swift trampoline), so the
;;      callable signature carries self and _cmd as the first two void*
;;      args and the Scheme proc receives the full `(self _cmd arg ...)`
;;      tuple — matching the racket make-dynamic-subclass consumer
;;      convention.
;;
;;   3. drawRect:'s CGRect by value. The IMP receives the dirty rect as a
;;      by-value `(& NSRect)`. `foreign-callable`'s type tokens must be
;;      literals, so dispatch.sls builds the form with `eval` in the
;;      interaction-environment — where `NSRect` resolves only because this
;;      script imports `(apianyware runtime types)` at top level. (We ignore
;;      the rect, as the racket port does, but declare it so the ABI is
;;      exact on every arch, not just arm64.)
;;
;; Run unbundled with:
;;   chez --libdirs targets/chez/bindings/macos \
;;        --script targets/chez/app-implementations/macos/drawing-canvas/drawing-canvas.sls
;; Bundled via `cargo run --example bundle_app -p apianyware-bundle-chez
;;              -- drawing-canvas`.

(import (chezscheme)
        (apianyware appkit)
        (apianyware coregraphics)
        (apianyware runtime cocoa)
        (apianyware runtime objc)
        (apianyware runtime ffi)
        (apianyware runtime types)
        (apianyware runtime dispatch))

(define-entry-point (main)

  ;; ============================================================
  ;; Definitions
  ;; ============================================================

  ;; --- Raw objc_msgSend for the dynamic class alloc/init dance ---
  ;; The class is dynamic (no generated wrapper), so alloc + initWithFrame:
  ;; go through bare objc_msgSend. initWithFrame: lives on NSView, which the
  ;; subclass inherits.
  (define %msg-alloc
    (foreign-procedure "objc_msgSend" (void* void*) void*))
  (define %msg-init-with-frame
    (foreign-procedure "objc_msgSend" (void* void* (& NSRect)) void*))

  (define app (nsapplication-shared-application))

  ;; --- Window geometry ---
  (define window-width  640)
  (define window-height 480)
  (define toolbar-height 36)

  ;; --- Mutable drawing state ---
  ;;
  ;; A stroke = (vector r g b width (listof (cons x y))). RGB and width are
  ;; captured at mouse-down time so changing colour/width mid-drag would not
  ;; affect the in-progress stroke — and changing them later does not
  ;; retroactively alter existing strokes.
  ;;
  ;; `strokes` holds completed + in-progress strokes in chronological order.
  ;; `current-points` accumulates points for the active stroke as a reverse
  ;; list (cheaper than append); finalised into the last entry on mouseUp:.
  (define strokes '())
  (define current-r 0.0)
  (define current-g 0.0)
  (define current-b 0.0)
  (define current-width 2.0)
  (define drawing? #f)
  (define current-points '())  ; reverse list of (cons x y), newest first

  ;; Hold the canvas view reference so toolbar handlers can request redraw.
  (define canvas-view-ref #f)

  (define (start-stroke! x y)
    (set! drawing? #t)
    (set! current-points (list (cons x y)))
    (set! strokes
          (append strokes
                  (list (vector current-r current-g current-b current-width
                                (list (cons x y)))))))

  (define (extend-stroke! x y)
    (when drawing?
      (set! current-points (cons (cons x y) current-points))
      ;; Replace last stroke in-place with the extended point list.
      (let* ([rev  (reverse (cdr (reverse strokes)))]
             [last (car (reverse strokes))]
             [updated
              (vector (vector-ref last 0) (vector-ref last 1)
                      (vector-ref last 2) (vector-ref last 3)
                      (reverse current-points))])
        (set! strokes (append rev (list updated))))))

  (define (end-stroke!)
    (set! drawing? #f)
    (set! current-points '()))

  (define (clear-strokes!)
    (set! strokes '())
    (set! drawing? #f)
    (set! current-points '()))

  ;; --- Stroke rendering ---
  ;;
  ;; Iterate strokes, rendering each as a stroked polyline. Per-stroke
  ;; colour/width forces one BeginPath/StrokePath pair per stroke — they
  ;; can't be batched into a single path because stroke colour is
  ;; graphics-state, not per-subpath.
  ;;
  ;; Line cap/join use kCGLineCapRound + kCGLineJoinRound so:
  ;;   - Single-point strokes paint a filled disc (the round cap itself
  ;;     draws a circle of diameter = line width), letting a bare click
  ;;     produce a visible dot without any special-case branch.
  ;;   - Direction changes during a drag look smooth instead of mitred.
  (define (render-strokes ctx strokes)
    (for-each
      (lambda (stroke)
        (let ([r      (vector-ref stroke 0)]
              [g      (vector-ref stroke 1)]
              [b      (vector-ref stroke 2)]
              [width  (vector-ref stroke 3)]
              [points (vector-ref stroke 4)])
          (unless (null? points)
            (CGContextSetRGBStrokeColor ctx r g b 1.0)
            (CGContextSetLineWidth ctx width)
            (CGContextSetLineCap ctx kCGLineCapRound)
            (CGContextSetLineJoin ctx kCGLineJoinRound)
            (CGContextBeginPath ctx)
            (let ([first (car points)])
              (CGContextMoveToPoint ctx (car first) (cdr first))
              ;; For a single-point stroke, add a coincident second point so
              ;; StrokePath has a non-empty path to paint; the round cap then
              ;; produces a circular dot centred on the click.
              (cond
                [(null? (cdr points))
                 (CGContextAddLineToPoint ctx (car first) (cdr first))]
                [else
                 (for-each
                   (lambda (pt)
                     (CGContextAddLineToPoint ctx (car pt) (cdr pt)))
                   (cdr points))]))
            (CGContextStrokePath ctx))))
      strokes))

  ;; Event → view-local point. locationInWindow is in window coords;
  ;; passing fromView: #f converts to the receiver's own coord system
  ;; (NSView default: bottom-left origin, unflipped). `self` arrives from
  ;; the IMP as a raw void* pointer; coerce-arg passes it through.
  (define (event->view-point self event)
    (let ([window-pt (nsevent-location-in-window event)])
      (nsview-convert-point-from-view self window-pt #f)))

  ;; --- DrawingCanvasView dynamic subclass ---
  ;;
  ;; Each method-spec is (selector proc param-types return-type encoding):
  ;;   - proc receives (self _cmd arg ...); self/_cmd are raw void*.
  ;;   - param-types are the FFI types of the *user* args (self/_cmd are
  ;;     prepended by make-dynamic-subclass).
  ;;   - encoding is the ObjC type encoding, carried verbatim from the
  ;;     racket port (the NSRect aggregate encoding is ABI-defined).
  (define DrawingCanvasView
    (make-dynamic-subclass
      (objc_getClass "NSView")
      "DrawingCanvasView"
      (list
        (list "drawRect:"
              (lambda (self _cmd rect)
                (let ([gc (nsgraphicscontext-current-context)])
                  (unless (zero? (objc-object-ptr gc))
                    (render-strokes (nsgraphicscontext-cg-context gc)
                                    strokes))))
              (list '(& NSRect)) 'void
              "v@:{CGRect={CGPoint=dd}{CGSize=dd}}")
        (list "mouseDown:"
              (lambda (self _cmd event)
                (let ([pt (event->view-point self event)])
                  (start-stroke! (nspoint-x pt) (nspoint-y pt))
                  (nsview-set-needs-display! self #t)))
              (list 'void*) 'void "v@:@")
        (list "mouseDragged:"
              (lambda (self _cmd event)
                (let ([pt (event->view-point self event)])
                  (extend-stroke! (nspoint-x pt) (nspoint-y pt))
                  (nsview-set-needs-display! self #t)))
              (list 'void*) 'void "v@:@")
        (list "mouseUp:"
              (lambda (self _cmd event)
                (end-stroke!)
                (nsview-set-needs-display! self #t))
              (list 'void*) 'void "v@:@"))))

  ;; Allocate + init a DrawingCanvasView instance. alloc/init yields a
  ;; +1-owned object, so wrap-objc-object with retained? = #t.
  (define (make-drawing-canvas-view frame)
    (wrap-objc-object
      (%msg-init-with-frame
        (%msg-alloc DrawingCanvasView (sel-register "alloc"))
        (sel-register "initWithFrame:")
        frame)
      #t))

  ;; --- Window + layout ---
  (define window
    (make-nswindow-init-with-content-rect-style-mask-backing-defer
      (make-nsrect 0 0 window-width window-height)
      (bitwise-ior NSWindowStyleMaskTitled
                   NSWindowStyleMaskClosable
                   NSWindowStyleMaskMiniaturizable
                   NSWindowStyleMaskResizable)
      NSBackingStoreBuffered
      #f))

  (define content-view (nswindow-content-view window))

  ;; Canvas fills everything below the toolbar. Frame uses NSView's
  ;; unflipped coordinate system: origin (0,0) at bottom-left.
  (define canvas
    (make-drawing-canvas-view
      (make-nsrect 0 0 window-width (- window-height toolbar-height))))

  ;; --- Toolbar controls ---
  ;; Toolbar lives at the top; autoresizes with window width, pinned to
  ;; bottom-margin (MinYMargin) so it stays glued to the top edge as the
  ;; window resizes.
  (define toolbar-y (- window-height toolbar-height))

  (define color-button
    (make-nsbutton-init-with-frame (make-nsrect 12 (+ toolbar-y 4) 96 28)))

  (define width-slider
    (make-nsslider-init-with-frame (make-nsrect 120 (+ toolbar-y 6) 200 24)))

  (define clear-button
    (make-nsbutton-init-with-frame
      (make-nsrect (- window-width 88) (+ toolbar-y 4) 76 28)))

  ;; --- Target-action wiring ---
  ;; All three actions plus the colour-panel callback live on one delegate
  ;; object so the single binding `toolbar-target` anchors them. The Swift
  ;; trampoline strips self/_cmd, so each proc receives only `sender` (a raw
  ;; void*); borrow-objc-object wraps it for the generated setters.
  (define toolbar-target
    (make-delegate
      `(("openColor:"
         ,(lambda (sender)
            ;; The panel fires its action selector on `target` every time
            ;; the user changes the colour (continuous); routing through
            ;; this same delegate keeps state in one place.
            (let ([panel (nscolorpanel-shared-color-panel)])
              (nscolorpanel-set-target! panel (delegate-ptr toolbar-target))
              (nscolorpanel-set-action! panel "colorChanged:")
              (nscolorpanel-set-continuous! panel #t)
              (nscolorpanel-make-key-and-order-front panel #f)))
         (void*) void)
        ("widthChanged:"
         ,(lambda (sender)
            (set! current-width (nsslider-double-value width-slider)))
         (void*) void)
        ("clearCanvas:"
         ,(lambda (sender)
            (clear-strokes!)
            (nsview-set-needs-display! canvas #t))
         (void*) void)
        ("colorChanged:"
         ,(lambda (sender)
            ;; sender is the NSColorPanel. Its `color` is in the panel's
            ;; current colour space; redComponent/greenComponent/
            ;; blueComponent only work on RGB-family colours (pattern,
            ;; named, greyscale raise NSException). Normalise to device RGB
            ;; first so component extraction is always safe; guard for any
            ;; Scheme-level condition belt-and-suspenders.
            (guard (c [#t
                       (let ([p (current-error-port)])
                         (display "colorChanged: " p)
                         (display-condition c p)
                         (newline p))])
              (let ([raw (nscolorpanel-color (borrow-objc-object sender))])
                (unless (zero? (objc-object-ptr raw))
                  (let ([rgb (nscolor-color-using-color-space
                               raw (nscolorspace-device-rgb-color-space))])
                    (unless (zero? (objc-object-ptr rgb))
                      (set! current-r (nscolor-red-component rgb))
                      (set! current-g (nscolor-green-component rgb))
                      (set! current-b (nscolor-blue-component rgb))))))))
         (void*) void))))

  ;; ============================================================
  ;; Expressions
  ;; ============================================================

  (nsapplication-set-activation-policy! app NSApplicationActivationPolicyRegular)
  (install-standard-app-menu! app "Drawing Canvas")

  (nswindow-set-title! window "Drawing Canvas")
  (nswindow-center! window)
  (nswindow-set-min-size! window (make-nssize 400 300))

  ;; Canvas
  (set! canvas-view-ref canvas)
  (nsview-set-autoresizing-mask! canvas
    (bitwise-ior NSViewWidthSizable NSViewHeightSizable))
  (nsview-add-subview! content-view canvas)

  ;; Colour button (top-left, pinned to top edge)
  (nsbutton-set-title! color-button "Color…")
  (nsbutton-set-bezel-style! color-button NSBezelStyleRounded)
  (nsview-set-autoresizing-mask! color-button NSViewMinYMargin)
  (nsview-add-subview! content-view color-button)

  ;; Width slider (continuous, 1–20 px)
  (nsslider-set-min-value! width-slider 1.0)
  (nsslider-set-max-value! width-slider 20.0)
  (nsslider-set-double-value! width-slider current-width)
  (nsslider-set-continuous! width-slider #t)
  (nsview-set-autoresizing-mask! width-slider NSViewMinYMargin)
  (nsview-add-subview! content-view width-slider)

  ;; Clear button anchors to the right edge: MinXMargin keeps left-margin
  ;; elastic (button slides with the right edge) while MinYMargin pins
  ;; vertical position.
  (nsbutton-set-title! clear-button "Clear")
  (nsbutton-set-bezel-style! clear-button NSBezelStyleRounded)
  (nsview-set-autoresizing-mask! clear-button
    (bitwise-ior NSViewMinXMargin NSViewMinYMargin))
  (nsview-add-subview! content-view clear-button)

  ;; Wire target-action
  (nsbutton-set-target! color-button (delegate-ptr toolbar-target))
  (nsbutton-set-action! color-button "openColor:")
  (nsslider-set-target! width-slider (delegate-ptr toolbar-target))
  (nsslider-set-action! width-slider "widthChanged:")
  (nsbutton-set-target! clear-button (delegate-ptr toolbar-target))
  (nsbutton-set-action! clear-button "clearCanvas:")

  ;; Show window and run
  (nswindow-make-key-and-order-front window #f)
  (nsapplication-activate-ignoring-other-apps app #t)

  (display "Drawing Canvas running. Close window or Ctrl+C to exit.\n")
  (nsapplication-run app))

(main)
