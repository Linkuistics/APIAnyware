;;;; drawing-canvas.lisp — Drawing Canvas sample app (sbcl target). The 060 ladder's
;;;; NINTH and final app: the transparent-subclass showcase. A freehand drawing surface
;;;; with per-stroke colour + line width. A REAL ObjC subclass of NSView (`canvas-view`)
;;;; overrides `drawRect:` and the three mouse-event selectors; a second subclass of
;;;; NSObject (`canvas-controller`) carries the four toolbar/colour-panel target-actions.
;;;; The sbcl analogue of racket/chez/gerbil's drawing-canvas (mirrors
;;;; generation/targets/gerbil/apps/drawing-canvas/drawing-canvas.ss one piece at a time).
;;;;
;;;; Written against the CL-family interface contract (ADR-0033 / the contract spec): it
;;;; names only the `ns:`/`ns:cg-*` surface, the per-selector generics (§3.2), the subclass
;;;; macros `define-objc-subclass` / `define-objc-method` (§3.4/§3.5), and `make-instance`
;;;; for the bound NSWindow init (§3.3).
;;;;
;;;; Distinctive (vs. the prior eight apps) — three sbcl firsts, each diverging from the
;;;; gerbil precedent (see learnings.md):
;;;;
;;;;   1. FIRST app to subclass NSVIEW and be driven by AppKit's own display/event loop:
;;;;      `drawRect:` + `mouseDown:`/`mouseDragged:`/`mouseUp:`. The note-editor/mini-browser
;;;;      controllers subclassed NSObject for target-action/notification callbacks; here the
;;;;      framework calls INTO Lisp on its own schedule for the view's lifetime. The forwarding
;;;;      dispatcher (ADR-0034 §5 / ADR-0035 — `_objc_msgForward` → bounce to main → the one
;;;;      Lisp dispatcher) is the same machinery, now framework-initiated.
;;;;
;;;;   2. `drawRect:`'s NSRect arg IS DELIVERED, not dropped. The dispatcher reads the LIVE
;;;;      NSInvocation signature — recovered from NSView's real `drawRect:` encoding via
;;;;      `class_getInstanceMethod` (subclass.lisp `aw-resolve-method-encoding` step 2) — so the
;;;;      override is `(self rect)` with `rect` a raw SAP we IGNORE (we repaint the whole
;;;;      bounds, as the racket/chez/gerbil ports do). Gerbil's generic trampoline instead
;;;;      DROPS the undeliverable struct, making its override `(self)`-only. The mouse selectors
;;;;      take a deliverable NSEvent object → `(self event)`.
;;;;
;;;;   3. FIRST app to make direct CoreGraphics C calls and to read a by-value struct RETURN.
;;;;      CGContext* are `ns:cg-*` `define-alien-routine`s in coregraphics/functions.lisp —
;;;;      so CoreGraphics loads `:load-residual t` (the first app needing that flag for
;;;;      FUNCTIONS, not constants). `-[NSEvent locationInWindow]` and
;;;;      `-[NSView convertPoint:fromView:]` return `(sb-alien:struct ns-point)` by value;
;;;;      arm64 routes the HFA return through `alien-funcall` cleanly, so x/y are read with a
;;;;      plain `(sb-alien:slot p 'x)` and a returned struct chains straight into the next
;;;;      call's struct arg — NO `point-x`/`point-y` accessor helper (gerbil needed one).
;;;;
;;;; STATE lives in the `canvas-view` instance SLOTS (the sbcl idiom; gerbil used top-level
;;;; mutable bindings): the completed+in-progress strokes, the current RGB+width, and the
;;;; drag flag. `drawRect:`/the mouse methods read+mutate the view's own slots; the controller
;;;; reaches into the same canvas slots for colour/width/clear. All slot access is via
;;;; `slot-value` (not per-class accessors): the helper bodies compile when this file LOADS,
;;;; but accessors would only exist once the inner `define-objc-subclass` RUNS (the
;;;; mini-browser/note-editor pattern). The `canvas-controller` holds the live `canvas` +
;;;; `width-slider` refs as `:initarg` slots.
;;;;
;;;; Framework loads: Foundation `:load-residual nil`, AppKit `:load-residual nil` (no AppKit
;;;; constant/function residual is named — every enum we use lives in the always-loaded
;;;; enums.lisp), CoreGraphics `:load-residual t` (for the `ns:cg-*` stroke functions). The
;;;; dylib is loaded ONLY for the `aw_sbcl_subclass_*` bounce shim BOTH subclasses need — NO
;;;; block bridge (no completion handlers), so unlike note-editor there is no
;;;; `aw-init-block-dispatcher` (the subclass dispatcher self-registers lazily on the first
;;;; `define-objc-method`).
;;;;
;;;; DUMP/REVIVE: the ObjC class pairs live in libobjc, not the Lisp heap, so
;;;; `ensure-canvas-classes` re-synthesizes BOTH subclasses from `-main` in the revived image
;;;; (the startup re-resolution pass re-registers the forwarding dispatcher with the reopened
;;;; dylib). defclass/defmethod re-evaluation is idempotent.
;;;;
;;;; INSTRUMENTED to the k132 logging contract
;;;; (apps/macos/drawing-canvas/docs/logging-contract.md; child k137): events.lisp
;;;; (the `dc-events` package, loaded first by run.lisp/dump.lisp) writes the structured
;;;; events.log the AppSpec runner tails — [lifecycle] startup/shutdown + the launch line,
;;;; and the five [canvas] events from the mouse overrides + action handlers. The stroke
;;;; events format the STROKE'S OWN frozen colour/width (read from the stroke record,
;;;; never the current-* tool slots — the §7.2 capture-at-mouse-down freeze proof).
;;;;
;;;; Package: `apianyware-sbcl-impl` (the dev-harness home, like the other ladder apps).

(in-package #:apianyware-sbcl-impl)

;;; ---------------------------------------------------------------------------
;;; Geometry.
;;; ---------------------------------------------------------------------------
(defconstant +window-w+ 640)
(defconstant +window-h+ 480)
(defconstant +toolbar-h+ 36)

;;; ---------------------------------------------------------------------------
;;; NSString helper (a fresh autoreleased NSString from a Lisp string, +0 transient).
;;; ---------------------------------------------------------------------------
(defun nsstr (text)
  (aw-wrap (aw-make-nsstring text) t))

;;; ---------------------------------------------------------------------------
;;; The standard app menu (Quit -> -[NSApplication terminate:]), as the other apps.
;;; ---------------------------------------------------------------------------
(defun install-app-menu (app app-name)
  (let ((main-menu   (make-instance 'ns:ns-menu :init-with-title @""))
        (app-item    (make-instance 'ns:ns-menu-item
                       :init-with-title @"" :action "" :key-equivalent @""))
        (app-submenu (make-instance 'ns:ns-menu :init-with-title @""))
        (quit-item   (make-instance 'ns:ns-menu-item
                       :init-with-title (nsstr (format nil "Quit ~A" app-name))
                       :action "terminate:"
                       :key-equivalent @"q")))
    (ns:add-item_ app-submenu quit-item)
    (ns:add-item_ main-menu app-item)
    (ns:set-submenu_for-item_ main-menu app-submenu app-item)
    (ns:set-main-menu_ app main-menu)))

;;; ============================================================
;;; Stroke model
;;; ============================================================
;;
;; A STROKE captures its colour + width at mouse-DOWN time (a `defstruct`), so changing
;; colour/width mid-drag or afterwards never retroactively alters it. `points` is a list of
;; `(x . y)` view-coordinate conses, newest-first (an O(1) push per `mouseDragged:`),
;; reversed to chronological order at render time. `r`/`g`/`b`/`width` are double-floats (the
;; ns:cg-* aliens demand `sb-alien:double` — no coercion at the call site).
(defstruct (stroke (:constructor make-stroke (r g b width points)))
  r g b width points)

;;; --- State accessors over the canvas-view's slots (slot-value, not accessors:
;;; these compile before `define-objc-subclass` runs; the mini-browser pattern). ---
(defun start-stroke (canvas x y)
  "Begin a stroke at view point (X Y), capturing the canvas's current RGB+width."
  (setf (slot-value canvas 'drawing) t)
  (push (make-stroke (slot-value canvas 'current-r) (slot-value canvas 'current-g)
                     (slot-value canvas 'current-b) (slot-value canvas 'current-width)
                     (list (cons x y)))
        (slot-value canvas 'strokes)))

(defun extend-stroke (canvas x y)
  "Add view point (X Y) to the in-progress stroke (the head of `strokes`)."
  (when (slot-value canvas 'drawing)
    (push (cons x y) (stroke-points (first (slot-value canvas 'strokes))))))

(defun end-stroke (canvas)
  (setf (slot-value canvas 'drawing) nil))

(defun clear-strokes (canvas)
  (setf (slot-value canvas 'strokes) nil
        (slot-value canvas 'drawing) nil))

;;; --- Stroke rendering (direct CoreGraphics) ---
;;
;; Per-stroke colour/width is graphics-STATE, not per-subpath, so each stroke is its own
;; BeginPath/StrokePath pair. Round line cap + join means:
;;   - a single-point stroke (a bare click) paints a filled disc — we add a coincident
;;     second point so StrokePath has a non-empty path and the round cap draws a dot;
;;   - direction changes during a drag look smooth, not mitred.
;; `ctx` is the raw CGContextRef SAP from `(ns:cg-context (ns:current-context …))`. STROKES
;; arrives oldest-first (so later strokes paint on top).
(defun render-strokes (ctx strokes)
  (dolist (s strokes)
    (let ((points (reverse (stroke-points s))))      ; chronological
      (when points
        (ns:cg-context-set-rgb-stroke-color ctx (stroke-r s) (stroke-g s) (stroke-b s) 1.0d0)
        (ns:cg-context-set-line-width ctx (stroke-width s))
        (ns:cg-context-set-line-cap ctx ns:k-cg-line-cap-round)
        (ns:cg-context-set-line-join ctx ns:k-cg-line-join-round)
        (ns:cg-context-begin-path ctx)
        (let ((first (first points)))
          (ns:cg-context-move-to-point ctx (car first) (cdr first))
          (if (null (rest points))
              ;; single point → coincident line so the round cap paints a disc.
              (ns:cg-context-add-line-to-point ctx (car first) (cdr first))
              (dolist (p (rest points))
                (ns:cg-context-add-line-to-point ctx (car p) (cdr p)))))
        (ns:cg-context-stroke-path ctx)))))

;;; Event → view-local point. `locationInWindow` is in window coords; `convertPoint:fromView:`
;;; with a nil source view converts to the receiver's own (unflipped, bottom-left-origin)
;;; coords. Both calls return `(sb-alien:struct ns-point)` BY VALUE — the returned struct is
;;; fed straight into the convert call's struct arg, and x/y are read with `sb-alien:slot`.
(defun event->view-point (view event)
  (let ((vp (ns:convert-point_from-view_ view (ns:location-in-window event) nil)))
    (values (sb-alien:slot vp 'x) (sb-alien:slot vp 'y))))

;;; ---------------------------------------------------------------------------
;;; Subclass definitions — synthesized inside a function so they re-synthesize in a
;;; revived dumped image (the ObjC class pairs + dispatch routing did not survive the
;;; dump; defclass/defmethod re-evaluation is idempotent). Called from `-main`.
;;; ---------------------------------------------------------------------------
(defvar *canvas-classes-ready* nil
  "nil until `ensure-canvas-classes` has defined both subclasses in THIS process. A revived
   image starts nil again and re-defines.")

(defun ensure-canvas-classes ()
  (unless *canvas-classes-ready*
    ;; --- canvas-view: a real ObjC subclass of NSView holding the drawing state. ---
    (define-objc-subclass canvas-view (ns:ns-view)
      (:slots
       (strokes       :initform nil)
       (current-r     :initform 0.0d0)
       (current-g     :initform 0.0d0)
       (current-b     :initform 0.0d0)
       (current-width :initform 2.0d0)
       (drawing       :initform nil)))

    ;; drawRect: — the NSRect arg IS delivered (subclass.lisp recovers NSView's real
    ;; encoding), so the override is (self rect); we ignore rect and repaint the whole
    ;; bounds. Pull the current NSGraphicsContext's CGContextRef and render.
    (define-objc-method (canvas-view "drawRect:") (self rect)
      (declare (ignore rect))
      (let ((gc (ns:current-context (find-class 'ns:ns-graphics-context))))
        (when gc
          (render-strokes (ns:cg-context gc)
                          (reverse (slot-value self 'strokes))))))

    (define-objc-method (canvas-view "mouseDown:") (self event)
      (multiple-value-bind (x y) (event->view-point self event)
        (start-stroke self x y)
        (ns:set-needs-display_ self t)
        ;; §7.2 mouse-down rule end: the stroke's FROZEN colour+width, read from
        ;; the just-seeded stroke record (never the current-* tool slots).
        (let ((s (first (slot-value self 'strokes))))
          (dc-events:emit-stroke-begun (stroke-r s) (stroke-g s) (stroke-b s)
                                       (stroke-width s)))))

    (define-objc-method (canvas-view "mouseDragged:") (self event)
      (multiple-value-bind (x y) (event->view-point self event)
        (extend-stroke self x y)
        (ns:set-needs-display_ self t)))

    (define-objc-method (canvas-view "mouseUp:") (self event)
      (declare (ignore event))
      ;; Capture the in-progress stroke BEFORE `end-stroke` clears the flag (the
      ;; k134 freeze rule). A mouseUp with no stroke in progress (defensive —
      ;; AppKit delivers the up to the mouseDown view, so this should not occur)
      ;; emits nothing: the stroke events fire only for gestures that reached
      ;; the canvas.
      (let ((s (and (slot-value self 'drawing)
                    (first (slot-value self 'strokes)))))
        (end-stroke self)
        (ns:set-needs-display_ self t)
        (when s
          (dc-events:emit-stroke-committed (stroke-r s) (stroke-g s) (stroke-b s)
                                           (stroke-width s)
                                           (length (stroke-points s))))))

    ;; --- canvas-controller: a real ObjC subclass of NSObject carrying the four
    ;; toolbar/colour-panel target-actions; holds the live canvas + width-slider refs. ---
    (define-objc-subclass canvas-controller (ns:ns-object)
      (:slots
       (canvas       :initarg :canvas)
       (width-slider :initarg :width-slider)))

    ;; Open the shared colour panel, routing its CONTINUOUS action back to colorChanged:.
    (define-objc-method (canvas-controller "openColor:") (self sender)
      (declare (ignore sender))
      (let ((panel (ns:shared-color-panel (find-class 'ns:ns-color-panel))))
        (ns:set-target_ panel self)
        (ns:set-action_ panel "colorChanged:")
        (ns:set-continuous_ panel t)
        (ns:make-key-and-order-front_ panel nil)))

    ;; The panel fires this on every colour change. Its `color` is in the panel's current
    ;; colour space; redComponent/etc. only work on an RGB-family colour, so normalise to
    ;; device RGB first, then capture the components into the canvas's current-RGB slots.
    (define-objc-method (canvas-controller "colorChanged:") (self sender)
      (let ((raw (ns:color sender)))
        (when raw
          (let ((rgb (ns:color-using-color-space_
                       raw (ns:device-rgb-color-space (find-class 'ns:ns-color-space)))))
            (when rgb
              (let ((canvas (slot-value self 'canvas)))
                (setf (slot-value canvas 'current-r) (ns:red-component rgb)
                      (slot-value canvas 'current-g) (ns:green-component rgb)
                      (slot-value canvas 'current-b) (ns:blue-component rgb))
                ;; §8.1 step 4 success path, post-store; the silent no-ops (nil
                ;; panel colour, failed conversion) emit nothing. The panel is
                ;; continuous — many lines per drag is contract-conformant.
                (dc-events:emit-color-changed (slot-value canvas 'current-r)
                                              (slot-value canvas 'current-g)
                                              (slot-value canvas 'current-b))))))))

    (define-objc-method (canvas-controller "widthChanged:") (self sender)
      (declare (ignore sender))
      (let ((canvas (slot-value self 'canvas)))
        (setf (slot-value canvas 'current-width)
              (ns:double-value (slot-value self 'width-slider)))
        ;; §8.2 post-store; the slider is wired continuous — many lines per
        ;; drag is contract-conformant (never count events).
        (dc-events:emit-width-changed (slot-value canvas 'current-width))))

    (define-objc-method (canvas-controller "clearCanvas:") (self sender)
      (declare (ignore sender))
      (let* ((canvas (slot-value self 'canvas))
             ;; §8.3: strokes removed, captured PRE-clear; always emitted at
             ;; rule end, count=0 on an already-empty canvas (the stroke-set
             ;; cardinality channel).
             (count (length (slot-value canvas 'strokes))))
        (clear-strokes canvas)
        (ns:set-needs-display_ canvas t)
        (dc-events:emit-cleared count)))

    ;; `applicationWillTerminate:` is the only hook that fires on the menu/Cmd-Q
    ;; quit path: -[NSApplication terminate:] ends in a C exit(), which bypasses
    ;; sb-ext:*exit-hooks*. NSApplication auto-observes the notification for a
    ;; delegate that responds to this selector (informal conformance suffices).
    ;; The logging contract's one structural addition (k137), as in the prior
    ;; six apps.
    (define-objc-method (canvas-controller "applicationWillTerminate:") (self notification)
      (declare (ignore self notification))
      (handler-case
          (progn (dc-events:emit-shutdown 'menu) (dc-events:close-events!))
        (error (e)
          (format *error-output* "applicationWillTerminate: callback error: ~A~%" e)
          (finish-output *error-output*))))

    (setf *canvas-classes-ready* t)))

;;; ---------------------------------------------------------------------------
;;; The window.
;;; ---------------------------------------------------------------------------
(defun drawing-canvas-main (&key (run t))
  "Build the Drawing-Canvas UI and, unless RUN is nil, enter the AppKit run loop.

   RUN nil is the host construction PRE-FLIGHT (060): it synthesizes BOTH subclasses,
   builds the window + canvas + toolbar, wires target-action, and asserts the NSView
   subclass instance is live + back-referenced — then returns WITHOUT blocking on `-run`,
   so a bare `sbcl --load` validates marshalling, subclass synthesis (incl. an NSView
   subclass — a first), and the CoreGraphics framework load before the VM round-trip. The
   dumped image's toplevel calls RUN t."
  (ensure-canvas-classes)
  (let ((app (ns:shared-application (find-class 'ns:ns-application))))
    (ns:set-activation-policy_ app ns:ns-application-activation-policy-regular)
    (install-app-menu app "Drawing Canvas")

    ;; --- Structured event log: open + [lifecycle] startup BEFORE construction ---
    ;; `startup` must land before the app blocks in (ns:run app) or the runner's
    ;; `wait-ready` readiness probe times out; the contract wants it ahead of
    ;; window/canvas construction. Gated on the real run — the build-time smoke
    ;; needs no log file (the emitters no-op on a nil port).
    ;; Test-config compatibility: the canvas reads no runtime config, so it
    ;; honours DRAWING_CANVAS_TEST_CONFIG by reading the env var and treating
    ;; absent/empty as "no config" — a deliberate no-op.
    (when run
      (dc-events:events-init!)
      (dc-events:emit-startup)
      (sb-ext:posix-getenv "DRAWING_CANVAS_TEST_CONFIG"))

    (aw-with-rect (frame 0 0 +window-w+ +window-h+)
      (let* ((window (make-instance 'ns:ns-window
                       :init-with-content-rect frame
                       :style-mask (logior ns:ns-window-style-mask-titled
                                           ns:ns-window-style-mask-closable
                                           ns:ns-window-style-mask-miniaturizable
                                           ns:ns-window-style-mask-resizable)
                       :backing ns:ns-backing-store-buffered
                       :defer nil))
             (content     (ns:content-view window))
             (toolbar-y   (- +window-h+ +toolbar-h+))
             ;; The synthesized NSView subclass: bare alloc/init (no initWithFrame: through
             ;; make-instance for a subclass — the inherited bare init covers the view case,
             ;; subclass.lisp), then size it with setFrame:.
             (canvas        (make-instance 'canvas-view))
             (color-button  (make-instance 'ns:ns-button))
             (width-slider  (make-instance 'ns:ns-slider))
             (clear-button  (make-instance 'ns:ns-button)))
        (ns:set-title_ window (nsstr "Drawing Canvas"))
        (ns:center window)
        (aw-with-size (minsz 400 300) (ns:set-min-size_ window minsz))

        ;; --- Canvas: fills everything below the toolbar; grows with the window. ---
        (aw-with-rect (cf 0 0 +window-w+ (- +window-h+ +toolbar-h+))
          (ns:set-frame_ canvas cf))
        (ns:set-autoresizing-mask_ canvas
          (logior ns:ns-view-width-sizable ns:ns-view-height-sizable))
        (ns:add-subview_ content canvas)

        ;; --- Colour button (top-left, pinned to the top edge via MinYMargin). ---
        (aw-with-rect (bf 12 (+ toolbar-y 4) 96 28) (ns:set-frame_ color-button bf))
        (ns:set-title_ color-button (nsstr "Color…"))
        (ns:set-bezel-style_ color-button ns:ns-bezel-style-rounded)
        (ns:set-autoresizing-mask_ color-button ns:ns-view-min-y-margin)
        (ns:add-subview_ content color-button)

        ;; --- Width slider (continuous, 1–20 px). ---
        (aw-with-rect (sf 120 (+ toolbar-y 6) 200 24) (ns:set-frame_ width-slider sf))
        (ns:set-min-value_ width-slider 1.0d0)
        (ns:set-max-value_ width-slider 20.0d0)
        (ns:set-double-value_ width-slider 2.0d0)
        (ns:set-continuous_ width-slider t)
        (ns:set-autoresizing-mask_ width-slider ns:ns-view-min-y-margin)
        (ns:add-subview_ content width-slider)

        ;; --- Clear button anchors to the right edge: MinXMargin keeps the left margin
        ;; elastic (the button slides with the right edge), MinYMargin pins vertical. ---
        (aw-with-rect (clf (- +window-w+ 88) (+ toolbar-y 4) 76 28) (ns:set-frame_ clear-button clf))
        (ns:set-title_ clear-button (nsstr "Clear"))
        (ns:set-bezel-style_ clear-button ns:ns-bezel-style-rounded)
        (ns:set-autoresizing-mask_ clear-button
          (logior ns:ns-view-min-x-margin ns:ns-view-min-y-margin))
        (ns:add-subview_ content clear-button)

        ;; --- The controller, holding the live canvas + width-slider refs. ---
        (let ((controller (make-instance 'canvas-controller
                            :canvas canvas :width-slider width-slider)))

          ;; App delegate for the terminate hook (logging contract; k137).
          ;; Installed unconditionally so the pre-flight / revive smoke
          ;; exercises set-delegate. The controller instance is pinned in
          ;; *subclass-instances* (a STRONG table — subclass.lisp), so Cocoa's
          ;; weak delegate reference and the controls' weak target references
          ;; never reap it.
          (ns:set-delegate_ app controller)

          ;; --- Target-action wiring (after the controller exists). ---
          (ns:set-target_ color-button controller) (ns:set-action_ color-button "openColor:")
          (ns:set-target_ width-slider controller) (ns:set-action_ width-slider "widthChanged:")
          (ns:set-target_ clear-button controller) (ns:set-action_ clear-button "clearCanvas:")

          ;; --- Subclass-synthesis liveness gate (host pre-flight evidence): the NSView
          ;; subclass instance must be live + recorded in *subclass-instances* so the
          ;; forwarding dispatcher can recover the typed self for drawRect:/mouse events. ---
          (unless (gethash (sb-sys:sap-int (aw-ptr canvas)) *subclass-instances*)
            (error "drawing-canvas: canvas-view instance not back-referenced — subclass ~
                    synthesis or make-instance failed"))

          ;; --- Show + run. ---
          (ns:make-key-and-order-front_ window nil)
          (ns:activate-ignoring-other-apps_ app t)
          ;; Launch diagnostic (spec §3 step 6): the bare line beginning
          ;; `Drawing Canvas` the runner's `wait-for-log` matches in events.log,
          ;; plus the human-friendly stdout line (kept for unbundled runs;
          ;; LaunchServices discards stdout under `open`) — dual emission.
          (when run
            (dc-events:emit-launch-line)
            (format t "~&Drawing Canvas opened. Drag to draw; Color… changes the stroke colour, ~
                       the slider its width, Clear empties the canvas. Quit with Cmd-Q.~%")
            (finish-output)
            (ns:run app))
          controller)))))
