;;; scenekit-viewer.ss — SceneKit Viewer sample app (gerbil target).
;;;
;;; A rotating 3D geometry (cube / sphere / torus / cylinder) the user can swap
;;; via an NSPopUpButton and recolor via NSColorPanel. SCNView's
;;; allowsCameraControl gives orbit-on-drag and scroll-to-zoom for free. Mirrors
;;; generation/targets/chez/apps/scenekit-viewer/scenekit-viewer.sls
;;; (and racket's scenekit-viewer.rkt) one piece at a time.
;;;
;;; One `make-delegate` carries three selectors (geometryChanged:, openColor:,
;;; colorChanged:), one of which is the NSColorPanel target.
;;;
;;; Two members this app needs are declared on conformed protocols, not on the
;;; classes themselves — `runAction:` on SCNActionable (SCNNode conforms) and
;;; `setAutoenablesDefaultLighting:` on SCNSceneRenderer (SCNView conforms).
;;; The emitter flattens conformed-protocol members onto each bound class
;;; (grove leaf 120), so both come straight from the generated bindings; this
;;; app once carried an app-local raw-`objc_msgSend` shim for them (100/050).
;;;
;;; Build via bundle-gerbil; uses the bottle toolchain.
(import :gerbil-bindings/runtime/objc
        :gerbil-bindings/runtime/cocoa
        :gerbil-bindings/appkit/nsapplication
        :gerbil-bindings/appkit/nswindow
        :gerbil-bindings/appkit/nsview
        :gerbil-bindings/appkit/nscontrol
        :gerbil-bindings/appkit/nsbutton
        :gerbil-bindings/appkit/nspopupbutton
        :gerbil-bindings/appkit/nsstackview
        :gerbil-bindings/appkit/nscolor
        :gerbil-bindings/appkit/nscolorpanel
        :gerbil-bindings/appkit/nscolorspace
        :gerbil-bindings/appkit/enums
        :gerbil-bindings/scenekit/scnview
        :gerbil-bindings/scenekit/scnscene
        :gerbil-bindings/scenekit/scnnode
        :gerbil-bindings/scenekit/scngeometry
        :gerbil-bindings/scenekit/scnmaterial
        :gerbil-bindings/scenekit/scnmaterialproperty
        :gerbil-bindings/scenekit/scnbox
        :gerbil-bindings/scenekit/scnsphere
        :gerbil-bindings/scenekit/scntorus
        :gerbil-bindings/scenekit/scncylinder
        :gerbil-bindings/scenekit/scnaction)
(export main)

;; Track the current NSColor in Scheme state so geometry swaps re-apply the
;; user's choice: SceneKit creates a fresh firstMaterial per geometry, so without
;; this every swap would reset to white.
(def current-color #f)

(define-entry-point (main)
  ;; ============================================================
  ;; Definitions
  ;; ============================================================
  (def app (nsapplication-shared-application))

  (def window
    (make-nswindow-init-with-content-rect-style-mask-backing-defer
      (make-rect 0. 0. 640. 480.)
      (bitwise-ior NSWindowStyleMaskTitled
                   NSWindowStyleMaskClosable
                   NSWindowStyleMaskMiniaturizable
                   NSWindowStyleMaskResizable)
      NSBackingStoreBuffered
      #f))

  (def content-view (nswindow-content-view window))

  (def geometry-picker
    (make-nspopupbutton-init-with-frame-pulls-down (make-rect 0. 0. 140. 28.) #f))
  (def color-button (make-nsbutton))
  (def toolbar-stack (make-nsstackview))

  ;; SCNView fills below the toolbar. allowsCameraControl installs a default
  ;; camera controller (orbit/zoom on mouse); autoenablesDefaultLighting (via the
  ;; shim) gives ambient+key light without an SCNLight node. nil options → #f.
  (def scn-view (make-scnview-init-with-frame-options (make-rect 0. 0. 640. 432.) #f))

  (def scene (scnscene-scene))
  (def root-node (scnscene-root-node scene))

  (def (make-geometry index)
    (cond
      ((= index 0) (scnbox-box-with-width-height-length-chamfer-radius 2.0 2.0 2.0 0.1))
      ((= index 1) (scnsphere-sphere-with-radius 1.2))
      ((= index 2) (scntorus-torus-with-ring-radius-pipe-radius 1.0 0.35))
      ((= index 3) (scncylinder-cylinder-with-radius-height 1.0 2.0))
      (else (scnbox-box-with-width-height-length-chamfer-radius 2.0 2.0 2.0 0.1))))

  (def geometry-node (scnnode-node-with-geometry (make-geometry 0)))

  (def (apply-current-color!)
    (let (geom (scnnode-geometry geometry-node))
      (when geom
        (let (material (scngeometry-first-material geom))
          (when material
            (let (property (scnmaterial-diffuse material))
              (when property
                (scnmaterialproperty-set-contents! property current-color))))))))

  ;; rotateByX:y:z:duration: wrapped in repeatActionForever: → continuous spin.
  ;; Installed once; survives geometry swaps (swapping node.geometry doesn't
  ;; cancel node actions).
  (def spin-action
    (scnaction-repeat-action-forever
      (scnaction-rotate-by-x-y-z-duration 0.0 1.5 0.0 4.0)))

  ;; One delegate, three selectors. sender arrives wrapped (the 'object token);
  ;; nscolorpanel-color reads it directly.
  (def toolbar-target
    (make-delegate
      (list
        (list "geometryChanged:"
              (lambda (sender)
                (let (idx (nspopupbutton-index-of-selected-item geometry-picker))
                  (scnnode-set-geometry! geometry-node (make-geometry idx))
                  (apply-current-color!)))
              (list 'object) 'void)
        (list "openColor:"
              (lambda (sender)
                (let (panel (nscolorpanel-shared-color-panel))
                  (nscolorpanel-set-target! panel toolbar-target)
                  (nscolorpanel-set-action! panel "colorChanged:")
                  (nscolorpanel-set-continuous! panel #t)
                  (nswindow-make-key-and-order-front panel #f)))
              (list 'object) 'void)
        (list "colorChanged:"
              (lambda (sender)
                ;; Normalise to device-RGB so the material gets a space SceneKit
                ;; can read.
                (let (raw (nscolorpanel-color sender))
                  (when raw
                    (let (rgb (nscolor-color-using-color-space
                                raw (nscolorspace-device-rgb-color-space)))
                      (when rgb
                        (set! current-color rgb)
                        (apply-current-color!))))))
              (list 'object) 'void))))

  ;; ============================================================
  ;; Expressions
  ;; ============================================================
  (set! current-color (nscolor-system-red-color))

  (nsapplication-set-activation-policy! app NSApplicationActivationPolicyRegular)
  (install-standard-app-menu! app "SceneKit Viewer")

  (nswindow-set-title! window (string->nsstring "SceneKit Viewer"))
  (nswindow-center! window)
  (nswindow-set-min-size! window (make-size 480. 360.))

  ;; Toolbar
  (nspopupbutton-add-item-with-title! geometry-picker (string->nsstring "Cube"))
  (nspopupbutton-add-item-with-title! geometry-picker (string->nsstring "Sphere"))
  (nspopupbutton-add-item-with-title! geometry-picker (string->nsstring "Torus"))
  (nspopupbutton-add-item-with-title! geometry-picker (string->nsstring "Cylinder"))

  (nsbutton-set-title! color-button (string->nsstring "Color…"))
  (nsbutton-set-bezel-style! color-button NSBezelStyleRounded)

  (nsview-set-frame! toolbar-stack (make-rect 12. 440. 616. 32.))
  (nsstackview-set-orientation! toolbar-stack NSUserInterfaceLayoutOrientationHorizontal)
  (nsstackview-set-alignment! toolbar-stack NSLayoutAttributeFirstBaseline)
  (nsstackview-set-spacing! toolbar-stack 8.)
  (nsstackview-add-arranged-subview! toolbar-stack geometry-picker)
  (nsstackview-add-arranged-subview! toolbar-stack color-button)
  (nsview-set-autoresizing-mask! toolbar-stack
    (bitwise-ior NSViewWidthSizable NSViewMinYMargin))
  (nsview-add-subview! content-view toolbar-stack)

  ;; SCNView
  (nsview-set-frame! scn-view (make-rect 0. 0. 640. 432.))
  (nsview-set-autoresizing-mask! scn-view
    (bitwise-ior NSViewWidthSizable NSViewHeightSizable))
  (scnview-set-allows-camera-control! scn-view #t)
  (scnview-set-autoenables-default-lighting! scn-view #t)   ; via SCNSceneRenderer
  (scnview-set-background-color! scn-view (nscolor-dark-gray-color))
  (nsview-add-subview! content-view scn-view)

  ;; Scene + geometry node
  (scnview-set-scene! scn-view scene)
  (scnnode-add-child-node! root-node geometry-node)
  (apply-current-color!)
  (scnnode-run-action geometry-node spin-action)   ; via SCNActionable

  ;; Target-action wiring (popup + button inherit set-target!/action! from NSControl)
  (nscontrol-set-target! geometry-picker toolbar-target)
  (nscontrol-set-action! geometry-picker "geometryChanged:")
  (nscontrol-set-target! color-button toolbar-target)
  (nscontrol-set-action! color-button "openColor:")

  ;; Show window and run
  (nswindow-make-key-and-order-front window #f)
  (nsapplication-activate-ignoring-other-apps app #t)

  (displayln "SceneKit Viewer running. Close window or Ctrl+C to exit.")
  (nsapplication-run app))

(main)
