;; scenekit-viewer.sls — SceneKit Viewer sample app (chez target).
;;
;; A rotating 3D geometry (cube / sphere / torus / cylinder) the user
;; can swap via an NSPopUpButton and recolor via NSColorPanel. SCNView's
;; allowsCameraControl gives orbit-on-drag and scroll-to-zoom for free.
;; Mirrors generation/targets/racket/apps/scenekit-viewer/scenekit-viewer.rkt.
;;
;; Exercises one chez `make-delegate` carrying three selectors
;; (geometryChanged:, openColor:, colorChanged:), one of which is
;; the NSColorPanel target — the first chez sample to drive the
;; shared color panel.
;;
;; The body of `(define-entry-point (main) ...)` is a procedure body
;; in R6RS terms — all internal `define`s precede every expression.
;; Mixing them is what `(import (chezscheme))` rejects at script load
;; with "invalid context for definition".
;;
;; Run unbundled with:
;;   chez --libdirs targets/chez/bindings/macos \
;;        --script targets/chez/app-implementations/macos/scenekit-viewer/scenekit-viewer.sls
;; Bundled via `cargo run --example bundle_app -p apianyware-bundle-chez
;;              -- scenekit-viewer`.

(import (chezscheme)
        (apianyware appkit)
        (apianyware scenekit)
        (apianyware foundation)
        (apianyware runtime cocoa)
        (apianyware runtime objc)
        (apianyware runtime types)
        (apianyware runtime dispatch))

(define-entry-point (main)
  ;; ============================================================
  ;; Definitions
  ;; ============================================================

  (define app (nsapplication-shared-application))

  (define window
    (make-nswindow-init-with-content-rect-style-mask-backing-defer
      (make-nsrect 0 0 640 480)
      (bitwise-ior NSWindowStyleMaskTitled
                   NSWindowStyleMaskClosable
                   NSWindowStyleMaskMiniaturizable
                   NSWindowStyleMaskResizable)
      NSBackingStoreBuffered
      #f))

  (define content-view (nswindow-content-view window))

  (define geometry-picker
    (make-nspopupbutton-init-with-frame-pulls-down (make-nsrect 0 0 140 28) #f))
  (define color-button (make-nsbutton-init-with-frame (make-nsrect 0 0 80 28)))
  (define toolbar-stack
    (make-nsstackview-init-with-frame (make-nsrect 12 440 616 32)))

  ;; SCNView fills the window below the toolbar. `allowsCameraControl`
  ;; is the whole reason this app doesn't need a custom SCNView
  ;; subclass or any SCNVector3 plumbing for camera positioning —
  ;; SceneKit installs a default camera controller driven by the mouse.
  ;; `autoenablesDefaultLighting` gives an ambient + key light without
  ;; wiring an SCNLight node.
  (define scn-view
    (make-scnview-init-with-frame (make-nsrect 0 0 640 432)))

  (define scene (scnscene-scene))
  (define root-node (scnscene-root-node scene))

  (define (make-geometry index)
    (cond
      [(= index 0) (scnbox-box-with-width-height-length-chamfer-radius 2.0 2.0 2.0 0.1)]
      [(= index 1) (scnsphere-sphere-with-radius 1.2)]
      [(= index 2) (scntorus-torus-with-ring-radius-pipe-radius 1.0 0.35)]
      [(= index 3) (scncylinder-cylinder-with-radius-height 1.0 2.0)]
      [else (scnbox-box-with-width-height-length-chamfer-radius 2.0 2.0 2.0 0.1)]))

  (define geometry-node (scnnode-node-with-geometry (make-geometry 0)))

  ;; Track the current NSColor in Scheme state so geometry swaps re-apply
  ;; the user's choice to the new material. SceneKit creates a fresh
  ;; firstMaterial for every geometry — without this, every swap would
  ;; reset the color to white.
  (define current-color (nscolor-system-red-color))

  (define (apply-current-color!)
    (let ([geom (scnnode-geometry geometry-node)])
      (unless (zero? (objc-object-ptr geom))
        (let ([material (scngeometry-first-material geom)])
          (unless (zero? (objc-object-ptr material))
            (let ([property (scnmaterial-diffuse material)])
              (unless (zero? (objc-object-ptr property))
                (scnmaterialproperty-set-contents! property current-color))))))))

  ;; rotateByX:y:z:duration: is a single finite rotate; wrapping it in
  ;; repeatActionForever: yields a continuous spin. Installed once via
  ;; scnnode-run-action and runs independently of geometry swaps —
  ;; swapping `node.geometry` does not cancel actions on the node, so
  ;; the spin survives picker changes with no extra bookkeeping.
  (define spin-action
    (scnaction-repeat-action-forever
      (scnaction-rotate-by-x-y-z-duration 0.0 1.5 0.0 4.0)))

  ;; One chez delegate carries three selectors. Sender arrives from
  ;; the Swift trampoline as a raw void* — wrap with `borrow-objc-object`
  ;; where the generated accessor's self contract demands a record.
  ;; The delegate value lives in this top-level binding for the lifetime
  ;; of the run loop so the wrapping record outlives the weakly-held
  ;; Cocoa delegate properties, per `runtime/dispatch.sls`.
  (define toolbar-target
    (make-delegate
      `(("geometryChanged:"
         ,(lambda (_sender)
            (let ([idx (nspopupbutton-index-of-selected-item geometry-picker)])
              (scnnode-set-geometry! geometry-node (make-geometry idx))
              (apply-current-color!)))
         (void*) void)
        ("openColor:"
         ,(lambda (_sender)
            (let ([panel (nscolorpanel-shared-color-panel)])
              (nscolorpanel-set-target! panel (delegate-ptr toolbar-target))
              (nscolorpanel-set-action! panel "colorChanged:")
              (nscolorpanel-set-continuous! panel #t)
              (nscolorpanel-make-key-and-order-front panel #f)))
         (void*) void)
        ("colorChanged:"
         ,(lambda (sender)
            ;; NSColorPanel colors can be in any color space — normalize
            ;; to device-RGB so downstream component accessors (HUD
            ;; readout, future serialization) don't raise. SceneKit's
            ;; material path doesn't sample directly, but the conversion
            ;; is cheap insurance against a space SceneKit can't read.
            (let ([raw (nscolorpanel-color (borrow-objc-object sender))])
              (unless (zero? (objc-object-ptr raw))
                (let ([rgb (nscolor-color-using-color-space
                             raw (nscolorspace-device-rgb-color-space))])
                  (unless (zero? (objc-object-ptr rgb))
                    (set! current-color rgb)
                    (apply-current-color!))))))
         (void*) void))))

  ;; ============================================================
  ;; Expressions
  ;; ============================================================

  (nsapplication-set-activation-policy! app NSApplicationActivationPolicyRegular)
  (install-standard-app-menu! app "SceneKit Viewer")

  (nswindow-set-title! window "SceneKit Viewer")
  (nswindow-center! window)
  (nswindow-set-min-size! window (make-nssize 480 360))

  ;; Toolbar
  (nspopupbutton-add-item-with-title! geometry-picker "Cube")
  (nspopupbutton-add-item-with-title! geometry-picker "Sphere")
  (nspopupbutton-add-item-with-title! geometry-picker "Torus")
  (nspopupbutton-add-item-with-title! geometry-picker "Cylinder")

  (nsbutton-set-title! color-button "Color\x2026;")
  (nsbutton-set-bezel-style! color-button NSBezelStyleRounded)

  (nsstackview-set-orientation! toolbar-stack NSUserInterfaceLayoutOrientationHorizontal)
  (nsstackview-set-alignment! toolbar-stack NSLayoutAttributeFirstBaseline)
  (nsstackview-set-spacing! toolbar-stack 8.0)
  (nsstackview-add-arranged-subview! toolbar-stack geometry-picker)
  (nsstackview-add-arranged-subview! toolbar-stack color-button)
  (nsview-set-autoresizing-mask! toolbar-stack
    (bitwise-ior NSViewWidthSizable NSViewMinYMargin))
  (nsview-add-subview! content-view toolbar-stack)

  ;; SCNView
  (nsview-set-autoresizing-mask! scn-view
    (bitwise-ior NSViewWidthSizable NSViewHeightSizable))
  (scnview-set-allows-camera-control! scn-view #t)
  (scnview-set-autoenables-default-lighting! scn-view #t)
  (scnview-set-background-color! scn-view (nscolor-dark-gray-color))
  (nsview-add-subview! content-view scn-view)

  ;; Scene + geometry node
  (scnview-set-scene! scn-view scene)
  (scnnode-add-child-node! root-node geometry-node)
  (apply-current-color!)
  (scnnode-run-action geometry-node spin-action)

  ;; Target-action wiring
  (nspopupbutton-set-target! geometry-picker (delegate-ptr toolbar-target))
  (nspopupbutton-set-action! geometry-picker "geometryChanged:")
  (nsbutton-set-target! color-button (delegate-ptr toolbar-target))
  (nsbutton-set-action! color-button "openColor:")

  ;; Show window and run
  (nswindow-make-key-and-order-front window #f)
  (nsapplication-activate-ignoring-other-apps app #t)

  (display "SceneKit Viewer running. Close window or Ctrl+C to exit.\n")
  (nsapplication-run app))

(main)
