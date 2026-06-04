;;; runtime/tests/smoke-subclass.ss — leaf 050/030 smoke.
;;;
;;; The transparent extensible subclassing bridge (ADR-0020, the centre): a
;;; synthesized ObjC subclass of NSView whose `drawRect:` / `isFlipped` overrides
;;; route the macOS frameworks' selector dispatch into Gerbil method bodies, with
;;; the typed Gerbil instance recovered from the ObjC `self`.
;;;
;;; This mirrors real app code: a framework module defines the bound `NSView`
;;; with the BUILT-IN `defclass` (here `%defclass`, as `emit_class` emits it); the
;;; app derives from it with the SHADOWING `defclass`/`defmethod` from
;;; `:gerbil-bindings/runtime/subclass`. Because the override `defmethod`s textually
;;; follow the `defclass`, each does a legal post-registration `class_addMethod`.
;;;
;;; CLI smoke (gxc): it drives the override selectors through the ObjC runtime —
;;; the exact dispatch AppKit's display/layout machinery uses — and observes the
;;; Gerbil bodies run with the right `self`. The full framework-driven repaint is
;;; node 090's drawing-canvas VM-verify. Links the clang companion (run-smokes.sh).

(export main)
(import :std/foreign
        (rename-in :gerbil/core (defclass %defclass) (defmethod %defmethod))
        :gerbil-bindings/runtime/ffi
        :gerbil-bindings/runtime/objc
        :gerbil-bindings/runtime/subclass)

;; --- the bound NSView, as a framework module emits it (built-in defclass) ---
(%defclass (NSView NSObject) () transparent: #t)
(register-objc-class! (lambda (p) (make-NSView ptr: p)) NSView::t "NSView" "NSResponder")

;; --- test scaffolding: the framework crossings the smoke drives ------------
(begin-ffi (make-window window-set-content-view force-draw-rect view-is-flipped
            app-prime)
  (c-declare "#include <objc/runtime.h>")
  (c-declare "#include <objc/message.h>")
  (c-declare "typedef struct { double x,y,w,h; } AWRect;")
  ;; Prime AppKit (sharedApplication) so window/view object graph is well-formed
  ;; headless; activation policy keeps it out of the Dock. Returns the app id.
  (define-c-lambda app-prime () (pointer void)
    "id (*s)(id,SEL)=(id(*)(id,SEL))objc_msgSend;
     id app = s((id)objc_getClass(\"NSApplication\"), sel_registerName(\"sharedApplication\"));
     void (*sp)(id,SEL,long)=(void(*)(id,SEL,long))objc_msgSend;
     sp(app, sel_registerName(\"setActivationPolicy:\"), 1);
     ___return((void*)app);")
  ;; [[NSWindow alloc] init] — a default window (object graph only; never shown).
  (define-c-lambda make-window () (pointer void)
    "id (*s)(id,SEL)=(id(*)(id,SEL))objc_msgSend;
     id w = s(s((id)objc_getClass(\"NSWindow\"), sel_registerName(\"alloc\")),
              sel_registerName(\"init\"));
     ___return((void*)w);")
  ;; -[NSWindow setContentView:] — installs the view IN the window (retains it,
  ;; and AppKit may already query the overridden selectors during this).
  (define-c-lambda window-set-content-view ((pointer void) (pointer void)) void
    "void (*s)(id,SEL,id)=(void(*)(id,SEL,id))objc_msgSend;
     s((id)___arg1, sel_registerName(\"setContentView:\"), (id)___arg2);")
  ;; -[NSView drawRect:] with a zero rect — dispatches through the ObjC runtime to
  ;; the installed IMP (the rect rides struct registers our override ignores).
  (define-c-lambda force-draw-rect ((pointer void)) void
    "AWRect r = {0,0,0,0};
     void (*s)(id,SEL,AWRect)=(void(*)(id,SEL,AWRect))objc_msgSend;
     s((id)___arg1, sel_registerName(\"drawRect:\"), r);")
  ;; -[NSView isFlipped] — bool-return override (exercises return marshalling).
  (define-c-lambda view-is-flipped ((pointer void)) bool
    "signed char (*s)(id,SEL)=(signed char(*)(id,SEL))objc_msgSend;
     ___return(s((id)___arg1, sel_registerName(\"isFlipped\")) != 0);"))

;; --- observable side effects the overrides write -------------------------
(def *draws* 0)
(def *draw-self-is-canvas* #f)
(def *canvas-ref* #f)               ; identity check: override self === our instance

;; --- the user subclass (SHADOWING defclass/defmethod) ---------------------
;; A real ObjC subclass is synthesized at this `defclass`; the two `defmethod`
;; overrides install IMPs on it (post-registration class_addMethod).
(defclass (CanvasView NSView) (strokes) transparent: #t)

;; drawRect: — void, no deliverable args (the CGRect can't ride the generic
;; trampoline, so the override formals are just `(self)`). self is the TYPED
;; CanvasView, recovered from the ObjC receiver via the back-ref table.
(defmethod (CanvasView "drawRect:") (self)
  (set! *draws* (##fx+ *draws* 1))
  (set! *draw-self-is-canvas*
    (and (CanvasView? self) (eq? self *canvas-ref*))))

;; isFlipped — bool return; AppKit queries this to choose the coordinate system.
(defmethod (CanvasView "isFlipped") (self)
  #t)

(def failures 0)
(def (check tag ok?)
  (displayln (if ok? "  ok   " "  FAIL ") tag)
  (unless ok? (set! failures (##fx+ failures 1))))

(def (main . _)
  (with-autorelease-pool
   (app-prime)
   (let* ((view (new CanvasView)))
     (set! *canvas-ref* view)
     (check "new yields a bound CanvasView instance"
            (and (CanvasView? view) (NSView? view) (NSObject? view)))

     ;; install it in a window (setContentView: retains it; AppKit may already
     ;; dispatch the overrides here)
     (let ((win (make-window)))
       (window-set-content-view win (->ptr view))
       (check "view installed as window content (no crash through framework)" #t))

     ;; bool-return override reached through the ObjC runtime
     (check "isFlipped override returns the Gerbil value (#t) via msgSend"
            (eq? (view-is-flipped (->ptr view)) #t))

     ;; void override: framework selector dispatch routes into the Gerbil body
     ;; with the correct typed self
     (force-draw-rect (->ptr view))
     (force-draw-rect (->ptr view))
     (check "drawRect: override ran for each dispatch (count)" (= *draws* 2))
     (check "drawRect: received the right typed CanvasView self" *draw-self-is-canvas*))

   (displayln (if (##fxzero? failures) "SUBCLASS-OK" "SUBCLASS-FAIL"))))
