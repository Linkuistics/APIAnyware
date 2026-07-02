#lang racket/base
;; scenekit-viewer.rkt — SceneKit Viewer sample app (OO style)
;;
;; A rotating 3D geometry (cube / sphere / torus / cylinder) the user
;; can swap via an NSPopUpButton and recolor via NSColorPanel. SCNView's
;; allowsCameraControl gives orbit-on-drag and scroll-to-zoom for free.
;;
;; Exercises: SceneKit framework end-to-end, chained object construction
;; (scene → node → geometry → material), NSColorPanel continuous
;; target-action, and protocol-inherited methods (runAction: on
;; SCNActionable, setAutoenablesDefaultLighting: on SCNSceneRenderer)
;; now generated as proper bindings by the protocol-inherited-methods fix.
;;
;; Instrumented to the AppSpec logging contract (racket-instrument-build-k107,
;; apps/macos/scenekit-viewer/docs/logging-contract.md): it writes a structured
;; events.log the runner tails — [lifecycle] startup/shutdown, the bare launch
;; line, and the two [scene] state-transition events (geometry-changed /
;; color-changed) that make the spec §13 scene assertions runner-verifiable
;; (the SCNView's rendered contents are pixel-level, invisible to OCR/AX).
;;
;; Run with: racket scenekit-viewer.rkt

(require "../../generated/appkit/nsapplication.rkt"
         "../../generated/appkit/nswindow.rkt"
         "../../generated/appkit/nsview.rkt"
         "../../generated/appkit/nsbutton.rkt"
         "../../generated/appkit/nspopupbutton.rkt"
         "../../generated/appkit/nsstackview.rkt"
         "../../generated/appkit/nscolor.rkt"
         "../../generated/appkit/nscolorpanel.rkt"
         "../../generated/appkit/nscolorspace.rkt"
         "../../generated/scenekit/scnview.rkt"
         "../../generated/scenekit/scnscene.rkt"
         "../../generated/scenekit/scnnode.rkt"
         "../../generated/scenekit/scnbox.rkt"
         "../../generated/scenekit/scnsphere.rkt"
         "../../generated/scenekit/scntorus.rkt"
         "../../generated/scenekit/scncylinder.rkt"
         "../../generated/scenekit/scngeometry.rkt"
         "../../generated/scenekit/scnmaterial.rkt"
         "../../generated/scenekit/scnmaterialproperty.rkt"
         "../../generated/scenekit/scnaction.rkt"
         "../../runtime/objc-base.rkt"
         "../../runtime/type-mapping.rkt"
         "../../runtime/coerce.rkt"
         "../../runtime/delegate.rkt"
         "../../runtime/app-menu.rkt"
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
;; NSUserInterfaceLayoutOrientation
(define NSUserInterfaceLayoutOrientationHorizontal 0)
;; NSLayoutAttribute
(define NSLayoutAttributeFirstBaseline 12)

;; --- Structured event log (logging contract) ---
;; Open + truncate the events.log the runner tails, then record [lifecycle]
;; startup BEFORE window/scene construction / the AppKit run loop (or
;; `wait-ready` times out).
(events-init!)
(emit-startup)

;; Test-config compatibility (logging-contract.md "Test-config compatibility"):
;; the viewer reads no runtime config, so it honours SCENEKIT_VIEWER_TEST_CONFIG
;; by reading the env var and treating an absent/empty value (and a missing
;; file) as "no config" — a deliberate no-op.
(void (getenv "SCENEKIT_VIEWER_TEST_CONFIG"))

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
(install-standard-app-menu! app "SceneKit Viewer")

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

;; --- Window ---
(define window
  (make-nswindow-init-with-content-rect-style-mask-backing-defer
   (make-nsrect 0 0 640 480)
   (bitwise-ior NSWindowStyleMaskTitled
                NSWindowStyleMaskClosable
                NSWindowStyleMaskMiniaturizable
                NSWindowStyleMaskResizable)
   NSBackingStoreBuffered
   #f))
(nswindow-set-title! window "SceneKit Viewer")
(nswindow-center! window)
(nswindow-set-min-size! window (make-nssize 480 360))

(define content-view (nswindow-content-view window))

;; --- Toolbar controls ---
(define geometry-picker
  (make-nspopupbutton-init-with-frame-pulls-down (make-nsrect 0 0 140 28) #f))
(nspopupbutton-add-item-with-title! geometry-picker "Cube")
(nspopupbutton-add-item-with-title! geometry-picker "Sphere")
(nspopupbutton-add-item-with-title! geometry-picker "Torus")
(nspopupbutton-add-item-with-title! geometry-picker "Cylinder")

(define color-button (make-nsbutton-init-with-frame (make-nsrect 0 0 80 28)))
(nsbutton-set-title! color-button "Color…")
(nsbutton-set-bezel-style! color-button NSBezelStyleRounded)

(define toolbar-stack
  (make-nsstackview-init-with-frame (make-nsrect 12 440 616 32)))
(nsstackview-set-orientation! toolbar-stack NSUserInterfaceLayoutOrientationHorizontal)
(nsstackview-set-alignment! toolbar-stack NSLayoutAttributeFirstBaseline)
(nsstackview-set-spacing! toolbar-stack 8.0)
(nsstackview-add-arranged-subview! toolbar-stack geometry-picker)
(nsstackview-add-arranged-subview! toolbar-stack color-button)
(nsview-set-autoresizing-mask! toolbar-stack
  (bitwise-ior NSViewWidthSizable NSViewMinYMargin))
(nsview-add-subview! content-view toolbar-stack)

;; --- SCNView ---
;; Fills the window below the toolbar. `allowsCameraControl` is the
;; whole reason this app doesn't need a custom SCNView subclass or any
;; SCNVector3 plumbing for camera positioning — SceneKit installs a
;; default camera controller that the user drives with the mouse.
;; `autoenablesDefaultLighting` gives the rendered geometry an ambient
;; + directional key light without having to wire an SCNLight node.
(define scn-view
  (make-scnview-init-with-frame (make-nsrect 0 0 640 432)))
(nsview-set-autoresizing-mask! scn-view
  (bitwise-ior NSViewWidthSizable NSViewHeightSizable))
(scnview-set-allows-camera-control! scn-view #t)
(scnview-set-autoenables-default-lighting! scn-view #t)
(scnview-set-background-color! scn-view (nscolor-dark-gray-color))
(nsview-add-subview! content-view scn-view)

;; --- Scene + geometry node ---
(define scene (scnscene-scene))
(scnview-set-scene! scn-view scene)
(define root-node (scnscene-root-node scene))

;; index → (values geometry catalogue-title). One cond arms both the applied
;; geometry and the `shape` the [scene] geometry-changed event reports, so
;; event and state cannot diverge (the k98 single-source-of-truth shape). The
;; else arm realizes the §6 out-of-range → cube defensive default (unreachable
;; through the four-item picker).
(define (make-geometry+title index)
  (cond
    [(= index 0) (values (scnbox-box-with-width-height-length-chamfer-radius 2.0 2.0 2.0 0.1) "Cube")]
    [(= index 1) (values (scnsphere-sphere-with-radius 1.2) "Sphere")]
    [(= index 2) (values (scntorus-torus-with-ring-radius-pipe-radius 1.0 0.35) "Torus")]
    [(= index 3) (values (scncylinder-cylinder-with-radius-height 1.0 2.0) "Cylinder")]
    [else (values (scnbox-box-with-width-height-length-chamfer-radius 2.0 2.0 2.0 0.1) "Cube")]))

(define geometry-node
  (scnnode-node-with-geometry
   (let-values ([(geom _title) (make-geometry+title 0)]) geom)))
(scnnode-add-child-node! root-node geometry-node)

;; --- Material color state ---
;;
;; Track the current NSColor in Racket state so geometry swaps re-apply
;; the user's choice to the new material. SceneKit creates a fresh
;; firstMaterial for every geometry — if we didn't re-apply, every swap
;; would reset the color to white.
(define current-color (nscolor-system-red-color))

;; The stored colour folded to the logging contract's integer components:
;; device-RGB ×255, rounded to nearest (bare integers 0–255). Converts at emit
;; time via colorUsingColorSpace: device-RGB — a §7.4-stored colour is already
;; device-RGB, so only the initial systemRedColor actually converts here (and
;; its numeric components are OS/appearance-dependent; consumers never assume
;; the initial values). Returns (list r g b), or #f if the conversion fails —
;; practically unreachable, and the caller then skips the event rather than
;; emit fabricated components.
(define (current-color-rgb255)
  (with-handlers ([exn:fail? (lambda (_) #f)])
    (define rgb (nscolor-color-using-color-space
                 current-color (nscolorspace-device-rgb-color-space)))
    (and rgb (not (objc-null? rgb))
         (map (lambda (c) (inexact->exact (round (* 255 c))))
              (list (nscolor-red-component rgb)
                    (nscolor-green-component rgb)
                    (nscolor-blue-component rgb))))))

(define (apply-current-color!)
  (define geom (scnnode-geometry geometry-node))
  (when geom
    (define material (scngeometry-first-material geom))
    (when material
      (define property (scnmaterial-diffuse material))
      (when property
        (scnmaterialproperty-set-contents! property current-color)))))

(apply-current-color!)

;; --- Rotation animation ---
;;
;; rotateByX:y:z:duration: is a single finite rotate; wrapping it in
;; repeatActionForever: yields a continuous spin. The action is
;; installed once via scnnode-run-action and runs independently of
;; geometry swaps — swapping `node.geometry` does not cancel actions on
;; the node, so the spin survives across picker changes without any
;; extra bookkeeping.
(define spin-action
  (scnaction-repeat-action-forever
   (scnaction-rotate-by-x-y-z-duration 0.0 1.5 0.0 4.0)))
(scnnode-run-action geometry-node spin-action)

;; --- Target-action wiring ---
(define toolbar-target
  (make-delegate
   #:return-types (hash "geometryChanged:" 'void
                        "openColor:"       'void
                        "colorChanged:"    'void)
   ;; colorChanged: sender is the NSColorPanel — wrap the raw cpointer
   ;; arg so nscolorpanel-color's self contract accepts it.
   #:param-types  (hash "colorChanged:" '(object))
   "geometryChanged:"
   (lambda (_sender)
     (define idx (nspopupbutton-index-of-selected-item geometry-picker))
     (define-values (geom title) (make-geometry+title idx))
     (scnnode-set-geometry! geometry-node geom)
     (apply-current-color!)
     ;; [scene] geometry-changed — POST-state (geometry assigned + §7.2 colour
     ;; re-apply done), carrying the folded stored colour so the §13 key
     ;; behaviour (colour persists across a swap) is a single-line assertion.
     (let ([rgb (current-color-rgb255)])
       (when rgb
         (emit-geometry-changed title (car rgb) (cadr rgb) (caddr rgb)))))
   "openColor:"
   (lambda (_sender)
     (define panel (nscolorpanel-shared-color-panel))
     (nscolorpanel-set-target! panel toolbar-target)
     (nscolorpanel-set-action! panel "colorChanged:")
     (nscolorpanel-set-continuous! panel #t)
     (nscolorpanel-make-key-and-order-front panel #f))
   "colorChanged:"
   (lambda (sender)
     ;; NSColorPanel colors can be in any color space — normalize to
     ;; device-RGB before use so downstream component accessors (if we
     ;; ever add them for HUD display) don't raise. Even for the
     ;; SceneKit material path, which doesn't call -redComponent etc.
     ;; directly, the conversion is cheap insurance against a color
     ;; space SceneKit can't sample from.
     (with-handlers ([exn:fail?
                      (lambda (e)
                        (eprintf "colorChanged: ~a\n" (exn-message e)))])
       (define raw (nscolorpanel-color sender))
       ;; Nil panel colour / failed device-RGB conversion are §7.4 silent
       ;; no-ops: keep-previous, no event (the stderr guard above is the only
       ;; diagnostic channel — never events.log).
       (when (and raw (not (objc-null? raw)))
         (define rgb (nscolor-color-using-color-space
                      raw (nscolorspace-device-rgb-color-space)))
         (when (and rgb (not (objc-null? rgb)))
           (set! current-color rgb)
           (apply-current-color!)
           ;; [scene] color-changed — success path only, POST store+apply.
           ;; current-color is the just-stored device-RGB colour, so the fold
           ;; is exact (no conversion drift).
           (let ([folded (current-color-rgb255)])
             (when folded
               (emit-color-changed (car folded) (cadr folded) (caddr folded))))))))))

(nspopupbutton-set-target! geometry-picker toolbar-target)
(nspopupbutton-set-action! geometry-picker "geometryChanged:")
(nsbutton-set-target! color-button toolbar-target)
(nsbutton-set-action! color-button "openColor:")

;; --- Show window and run ---
(nswindow-make-key-and-order-front window #f)
(nsapplication-activate-ignoring-other-apps app #t)

;; Launch diagnostic (spec §3 step 6): the bare line beginning `SceneKit Viewer`
;; the runner's `wait-for-log` matches, dual-emitted to stdout (human-friendly
;; when run unbundled) and events.log (the runner's read path).
(emit-launch-line)
(displayln "SceneKit Viewer running. Close window or Ctrl+C to exit.")
(nsapplication-run app)
