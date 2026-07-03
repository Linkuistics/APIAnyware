#lang racket/base
;; drawing-canvas.rkt — Drawing Canvas sample app (OO style)
;;
;; Freehand drawing app with per-stroke color and line width. A dynamic
;; ObjC subclass of NSView (`DrawingCanvasView`) overrides drawRect: and
;; the three mouse event methods; stroke state lives in module-level
;; mutable bindings and is read from inside the ObjC callbacks.
;;
;; Exercises:
;;   - Multi-method dynamic NSView subclass via make-dynamic-subclass
;;   - CoreGraphics drawing via CGContext* functions in drawRect:
;;   - NSColorPanel with target-action for color selection
;;   - Mouse event coordinate extraction + window→view conversion
;;   - IMP retention via module-level function-ptr bindings
;;
;; Run with: racket drawing-canvas.rkt

(require racket/list
         ffi/unsafe
         ;; ffi/unsafe/objc supplies sel_registerName, needed only for the
         ;; alloc/init dance on the dynamic class. _SEL and objc-get-class
         ;; collide with dynamic-class.rkt; except-in prefers the
         ;; runtime's versions.
         (except-in ffi/unsafe/objc _SEL objc-get-class)
         "../../generated/appkit/nsapplication.rkt"
         "../../generated/appkit/nswindow.rkt"
         "../../generated/appkit/nsview.rkt"
         "../../generated/appkit/nsbutton.rkt"
         "../../generated/appkit/nsslider.rkt"
         "../../generated/appkit/nscolor.rkt"
         "../../generated/appkit/nscolorpanel.rkt"
         "../../generated/appkit/nscolorspace.rkt"
         "../../generated/appkit/nsgraphicscontext.rkt"
         (only-in "../../generated/coregraphics/functions.rkt"
                  CGContextMoveToPoint
                  CGContextAddLineToPoint
                  CGContextBeginPath
                  CGContextStrokePath
                  CGContextSetLineWidth
                  CGContextSetLineCap
                  CGContextSetLineJoin
                  CGContextSetRGBStrokeColor
                  CGContextFillRect
                  CGContextSetRGBFillColor)
         "../../runtime/objc-base.rkt"
         "../../runtime/type-mapping.rkt"
         "../../runtime/coerce.rkt"
         "../../runtime/delegate.rkt"
         "../../runtime/app-menu.rkt"
         "../../runtime/nsevent-helpers.rkt"
         "../../runtime/objc-subclass.rkt"
         "events.rkt")

;; --- Constants (not yet extracted by collector) ---
;; NSWindowStyleMask
(define NSWindowStyleMaskTitled         1)
(define NSWindowStyleMaskClosable       2)
(define NSWindowStyleMaskMiniaturizable 4)
(define NSWindowStyleMaskResizable      8)
;; NSBackingStoreType
(define NSBackingStoreBuffered 2)
;; NSBezelStyle
(define NSBezelStyleRounded 1)
;; NSViewAutoresizingMask
(define NSViewWidthSizable  2)
(define NSViewHeightSizable 16)
(define NSViewMinYMargin    8)
;; CGLineCap / CGLineJoin
(define kCGLineCapRound  1)
(define kCGLineJoinRound 1)

;; --- Structured event log (logging contract) ---
;; Open + truncate the events.log the runner tails, then record [lifecycle]
;; startup BEFORE window/canvas construction / the AppKit run loop (or
;; `wait-ready` times out).
(events-init!)
(emit-startup)

;; Test-config compatibility (logging-contract.md "Test-config compatibility"):
;; the canvas reads no runtime config, so it honours DRAWING_CANVAS_TEST_CONFIG
;; by reading the env var and treating an absent/empty value (and a missing
;; file) as "no config" — a deliberate no-op.
(void (getenv "DRAWING_CANVAS_TEST_CONFIG"))

;; --- Shutdown wiring (signal / error paths) ---
;; The logging contract requires a [lifecycle] shutdown line on terminate.
;; The menu/Cmd-Q path goes through applicationWillTerminate: (delegate below);
;; SIGTERM/SIGINT reach Racket as exn:break → reason=signal, and any other
;; uncaught exception → reason=error.
(uncaught-exception-handler
 (lambda (exn)
   (with-handlers ([exn:fail? (lambda (_) (void))])
     (if (exn:break? exn)
         (emit-shutdown 'signal)
         (emit-shutdown 'error))
     (close-events!))
   (exit (if (exn:break? exn) 130 1))))

;; --- Application setup ---
(define app (nsapplication-shared-application))
(nsapplication-set-activation-policy! app 0)
(install-standard-app-menu! app "Drawing Canvas")

;; --- App delegate (terminate hook → [lifecycle] shutdown reason=menu) ---
;; Cocoa holds delegates weakly, so keep a module-scope reference. The body is
;; wrapped in with-handlers because an unhandled exception in an ObjC callback
;; crashes the app with no Racket stack trace.
(define app-delegate
  (make-delegate
   "applicationWillTerminate:"
   (lambda (notification)
     (with-handlers ([exn:fail?
                      (lambda (e)
                        (eprintf "applicationWillTerminate delegate error: ~a\n"
                                 (exn-message e)))])
       (emit-shutdown 'menu)
       (close-events!)))))
(void (nsapplication-set-delegate! app app-delegate))

;; --- Mutable drawing state ---
;;
;; A stroke = (vector r g b width (listof (cons x y))). RGB and width are
;; captured at mouse-down time so changing color/width mid-drag would not
;; affect the in-progress stroke — and changing them later does not
;; retroactively alter existing strokes.
;;
;; `strokes` holds completed + in-progress strokes in chronological order.
;; `current-stroke-points` accumulates points for the active stroke as a
;; reverse list (cheaper than append); finalized into the last entry on
;; mouseUp:.
(define strokes '())
(define current-r 0.0)
(define current-g 0.0)
(define current-b 0.0)
(define current-width 2.0)
(define drawing? #f)
(define current-points '())  ; reverse list of (cons x y), newest first

;; Hold the canvas view reference so mouse handlers can request redraw.
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
    (define rev (reverse (cdr (reverse strokes))))
    (define last (car (reverse strokes)))
    (define updated
      (vector (vector-ref last 0) (vector-ref last 1) (vector-ref last 2)
              (vector-ref last 3)
              (reverse current-points)))
    (set! strokes (append rev (list updated)))))

(define (end-stroke!)
  (set! drawing? #f)
  (set! current-points '()))

(define (clear-strokes!)
  (set! strokes '())
  (set! drawing? #f)
  (set! current-points '()))

;; --- Stroke rendering ---

;; Iterate strokes, rendering each as a stroked polyline. Per-stroke
;; color/width forces one BeginPath/StrokePath pair per stroke — they
;; can't be batched into a single path because stroke color is
;; graphics-state, not per-subpath.
;;
;; Line cap/join use `kCGLineCapRound` + `kCGLineJoinRound` so:
;;   - Single-point strokes paint a filled disc (the round cap itself
;;     draws a circle of diameter = line width), letting a bare click
;;     produce a visible dot without any special-case branch.
;;   - Direction changes during a drag look smooth instead of mitred.
(define (render-strokes ctx strokes)
  (for ([stroke (in-list strokes)])
    (define r (vector-ref stroke 0))
    (define g (vector-ref stroke 1))
    (define b (vector-ref stroke 2))
    (define width (vector-ref stroke 3))
    (define points (vector-ref stroke 4))
    (unless (null? points)
      (CGContextSetRGBStrokeColor ctx r g b 1.0)
      (CGContextSetLineWidth ctx width)
      (CGContextSetLineCap ctx kCGLineCapRound)
      (CGContextSetLineJoin ctx kCGLineJoinRound)
      (CGContextBeginPath ctx)
      (define first (car points))
      (CGContextMoveToPoint ctx (car first) (cdr first))
      ;; For a single-point stroke, add a coincident second point so
      ;; StrokePath has a non-empty path to paint; the round cap then
      ;; produces a circular dot centred on the click.
      (cond
        [(null? (cdr points))
         (CGContextAddLineToPoint ctx (car first) (cdr first))]
        [else
         (for ([pt (in-list (cdr points))])
           (CGContextAddLineToPoint ctx (car pt) (cdr pt)))])
      (CGContextStrokePath ctx))))

;; Event → view-local point. locationInWindow is in window coords;
;; passing fromView: #f converts to the receiver's own coord system
;; (NSView default: bottom-left origin, unflipped).
(define (event->view-point self event)
  (define window-pt (nsevent-location-in-window event))
  (nsview-convert-point-from-view (borrow-objc-object self) window-pt #f))

;; --- DrawingCanvasView dynamic subclass ---
;;
;; `define-objc-subclass` auto-handles the four bits that used to be
;; boilerplate:
;;   - module-level function-ptr + GC pinning per method
;;   - _cprocedure signature assembly including the (self SEL) prefix
;;   - ObjC type-encoding lookup from NSView's own method table (the
;;     NSRect encoding is ABI-defined and version-sensitive; pulling
;;     from the live superclass method is always correct)
;;   - Racket FFI arg/return types, inferred from the same superclass
;;     encoding (drawRect: → _NSRect; mouseDown: etc. → _pointer id)
(define-objc-subclass DrawingCanvasView NSView
  [(drawRect:)
   (lambda (self rect)
     (with-handlers ([exn:fail? (lambda (e)
                                  (eprintf "drawRect: error: ~a\n" (exn-message e)))])
       (define gc (nsgraphicscontext-current-context))
       (when gc
         (define ctx (nsgraphicscontext-cg-context gc))
         (render-strokes ctx strokes))))]
  [(mouseDown:)
   (lambda (self event)
     (with-handlers ([exn:fail? (lambda (e)
                                  (eprintf "mouseDown: error: ~a\n" (exn-message e)))])
       (define pt (event->view-point self event))
       (start-stroke! (NSPoint-x pt) (NSPoint-y pt))
       (nsview-set-needs-display! (borrow-objc-object self) #t)
       ;; [canvas] stroke-begun — end of the §7.2 mouse-down rule, post-state.
       ;; Format the STROKE'S OWN frozen colour+width (the vector captured
       ;; them at seed time), never the current-* tool state at emit time.
       (define stroke (last strokes))
       (emit-stroke-begun (vector-ref stroke 0) (vector-ref stroke 1)
                          (vector-ref stroke 2) (vector-ref stroke 3))))]
  [(mouseDragged:)
   (lambda (self event)
     (with-handlers ([exn:fail? (lambda (e)
                                  (eprintf "mouseDragged: error: ~a\n" (exn-message e)))])
       (define pt (event->view-point self event))
       (extend-stroke! (NSPoint-x pt) (NSPoint-y pt))
       (nsview-set-needs-display! (borrow-objc-object self) #t)))]
  [(mouseUp:)
   (lambda (self event)
     (with-handlers ([exn:fail? (lambda (e)
                                  (eprintf "mouseUp: error: ~a\n" (exn-message e)))])
       ;; Capture the in-progress stroke before the flags clear; its vector
       ;; (frozen colour/width + final point list) stays in `strokes`. A
       ;; mouseUp with no stroke in progress (AppKit routes the up to the
       ;; mouseDown view, so this should not occur) emits nothing — the
       ;; stroke events fire only for gestures that reached the canvas.
       (define stroke (and drawing? (pair? strokes) (last strokes)))
       (end-stroke!)
       (nsview-set-needs-display! (borrow-objc-object self) #t)
       ;; [canvas] stroke-committed — end of the §7.2 mouse-up rule,
       ;; post-state. Same frozen tuple as its stroke-begun; points = the
       ;; stored count (down point + drag points; the release is never
       ;; appended).
       (when stroke
         (emit-stroke-committed (vector-ref stroke 0) (vector-ref stroke 1)
                                (vector-ref stroke 2) (vector-ref stroke 3)
                                (length (vector-ref stroke 4))))))])

;; Allocate + init a DrawingCanvasView instance. Uses raw objc_msgSend
;; because the class is dynamic (no generated wrapper). initWithFrame:
;; lives on NSView, so the subclass inherits it.
(define _objc-lib (ffi-lib "libobjc"))
(define _msg-alloc
  (get-ffi-obj "objc_msgSend" _objc-lib
               (_fun _pointer _pointer -> _pointer)))
(define _msg-init-with-frame
  (get-ffi-obj "objc_msgSend" _objc-lib
               (_fun _pointer _pointer _NSRect -> _pointer)))

(define (make-drawing-canvas-view frame)
  (borrow-objc-object
   (_msg-init-with-frame
    (_msg-alloc DrawingCanvasView (sel_registerName "alloc"))
    (sel_registerName "initWithFrame:")
    frame)))

;; --- Window + layout ---
(define window-width  640)
(define window-height 480)
(define toolbar-height 36)

(define window
  (make-nswindow-init-with-content-rect-style-mask-backing-defer
   (make-nsrect 0 0 window-width window-height)
   (bitwise-ior NSWindowStyleMaskTitled
                NSWindowStyleMaskClosable
                NSWindowStyleMaskMiniaturizable
                NSWindowStyleMaskResizable)
   NSBackingStoreBuffered
   #f))
(nswindow-set-title! window "Drawing Canvas")
(nswindow-center! window)
(nswindow-set-min-size! window (make-nssize 400 300))

(define content-view (nswindow-content-view window))

;; Canvas fills everything below the toolbar. Frame uses NSView's
;; unflipped coordinate system: origin (0,0) at bottom-left.
(define canvas
  (make-drawing-canvas-view
   (make-nsrect 0 0 window-width (- window-height toolbar-height))))
(set! canvas-view-ref canvas)
(nsview-set-autoresizing-mask! canvas
  (bitwise-ior NSViewWidthSizable NSViewHeightSizable))
(nsview-add-subview! content-view canvas)

;; --- Toolbar controls ---
;; Toolbar lives at the top; autoresizes with window width, pinned to
;; bottom-margin (MinYMargin) so it stays glued to the top edge as the
;; window resizes.
(define toolbar-y (- window-height toolbar-height))

(define color-button
  (make-nsbutton-init-with-frame (make-nsrect 12 (+ toolbar-y 4) 96 28)))
(nsbutton-set-title! color-button "Color…")
(nsbutton-set-bezel-style! color-button NSBezelStyleRounded)
(nsview-set-autoresizing-mask! color-button NSViewMinYMargin)
(nsview-add-subview! content-view color-button)

(define width-slider
  (make-nsslider-init-with-frame (make-nsrect 120 (+ toolbar-y 6) 200 24)))
(nsslider-set-min-value! width-slider 1.0)
(nsslider-set-max-value! width-slider 20.0)
(nsslider-set-double-value! width-slider current-width)
(nsslider-set-continuous! width-slider #t)
(nsview-set-autoresizing-mask! width-slider NSViewMinYMargin)
(nsview-add-subview! content-view width-slider)

(define clear-button
  (make-nsbutton-init-with-frame
   (make-nsrect (- window-width 88) (+ toolbar-y 4) 76 28)))
(nsbutton-set-title! clear-button "Clear")
(nsbutton-set-bezel-style! clear-button NSBezelStyleRounded)
;; Clear button anchors to the right edge: MinXMargin keeps left-margin
;; elastic (button slides with the right edge) while MinYMargin pins
;; vertical position.
(define NSViewMinXMargin 1)
(nsview-set-autoresizing-mask! clear-button
  (bitwise-ior NSViewMinXMargin NSViewMinYMargin))
(nsview-add-subview! content-view clear-button)

;; --- Target-action wiring ---
;; All three actions live on one delegate object so the module-level
;; binding `toolbar-target` anchors them against GC.
(define toolbar-target
  (make-delegate
   #:return-types (hash "openColor:"    'void
                        "widthChanged:" 'void
                        "clearCanvas:"  'void
                        "colorChanged:" 'void)
   ;; colorChanged: sends messages back to `sender` (the NSColorPanel) —
   ;; without 'object the arg arrives as a raw cpointer and every
   ;; nscolorpanel-* call trips its objc-object? self contract.
   #:param-types  (hash "colorChanged:" '(object))
   "openColor:"
   (lambda (_sender)
     (define panel (nscolorpanel-shared-color-panel))
     ;; The panel fires its action selector on `target` every time the
     ;; user changes the color (continuous); routing through this same
     ;; delegate keeps state in one place.
     (nscolorpanel-set-target! panel toolbar-target)
     (nscolorpanel-set-action! panel "colorChanged:")
     (nscolorpanel-set-continuous! panel #t)
     (nscolorpanel-make-key-and-order-front panel #f))
   "widthChanged:"
   (lambda (_sender)
     (set! current-width (nsslider-double-value width-slider))
     ;; [canvas] width-changed — post-store (§8.2). Continuous slider: many
     ;; lines per drag is contract-conformant (never count events).
     (emit-width-changed current-width))
   "clearCanvas:"
   (lambda (_sender)
     ;; count = strokes removed (an in-progress stroke is in `strokes`, so a
     ;; mid-gesture Clear counts it); captured before the collection empties.
     (define count (length strokes))
     (clear-strokes!)
     (nsview-set-needs-display! canvas #t)
     ;; [canvas] cleared — end of the §8.3 Clear rule, post-state; ALWAYS
     ;; emitted, count=0 on an already-empty canvas (the stroke-set
     ;; cardinality channel).
     (emit-cleared count))
   "colorChanged:"
   (lambda (sender)
     ;; sender is NSColorPanel. `color` is an NSColor in the panel's
     ;; current color space; redComponent/greenComponent/blueComponent
     ;; only work on RGB-family colors (pattern, named, and greyscale
     ;; colors raise NSException). Normalize to device RGB first so
     ;; component extraction is always safe.
     (with-handlers ([exn:fail?
                      (lambda (e)
                        (eprintf "colorChanged: ~a\n" (exn-message e)))])
       (define raw (nscolorpanel-color sender))
       (when raw
         (define rgb (nscolor-color-using-color-space
                      raw (nscolorspace-device-rgb-color-space)))
         (when rgb
           (set! current-r (nscolor-red-component rgb))
           (set! current-g (nscolor-green-component rgb))
           (set! current-b (nscolor-blue-component rgb))
           ;; [canvas] color-changed — success path only, post-store (§8.1
           ;; step 4). The silent no-ops above (nil panel colour, failed
           ;; device-RGB conversion) emit nothing; the stderr guard in the
           ;; surrounding with-handlers stays off events.log.
           (emit-color-changed current-r current-g current-b)))))))

(nsbutton-set-target! color-button toolbar-target)
(nsbutton-set-action! color-button "openColor:")
(nsslider-set-target! width-slider toolbar-target)
(nsslider-set-action! width-slider "widthChanged:")
(nsbutton-set-target! clear-button toolbar-target)
(nsbutton-set-action! clear-button "clearCanvas:")

;; --- Show window and run ---
(nswindow-make-key-and-order-front window #f)
(nsapplication-activate-ignoring-other-apps app #t)

;; §3 step 6 launch diagnostic — dual emission (logging contract): keep the
;; human-friendly stdout line AND write the same line bare to events.log
;; (LaunchServices discards stdout under `open`).
(displayln "Drawing Canvas running. Close window or Ctrl+C to exit.")
(emit-launch-line)
(nsapplication-run app)
