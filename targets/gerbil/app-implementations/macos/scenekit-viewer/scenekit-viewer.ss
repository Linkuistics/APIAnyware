;;; scenekit-viewer.ss — SceneKit Viewer sample app (gerbil target).
;;;
;;; A rotating 3D geometry (cube / sphere / torus / cylinder) the user can swap
;;; via an NSPopUpButton and recolor via NSColorPanel. SCNView's
;;; allowsCameraControl gives orbit-on-drag and scroll-to-zoom for free. Mirrors
;;; targets/chez/app-implementations/macos/scenekit-viewer/scenekit-viewer.sls
;;; (and racket's scenekit-viewer.rkt) one piece at a time.
;;;
;;; One `make-delegate` carries three selectors (geometryChanged:, openColor:,
;;; colorChanged:), one of which is the NSColorPanel target — plus the app
;;; delegate's terminate hook.
;;;
;;; Two members this app needs are declared on conformed protocols, not on the
;;; classes themselves — `runAction:` on SCNActionable (SCNNode conforms) and
;;; `setAutoenablesDefaultLighting:` on SCNSceneRenderer (SCNView conforms).
;;; The emitter flattens conformed-protocol members onto each bound class
;;; (grove leaf 120), so both come straight from the generated bindings; this
;;; app once carried an app-local raw-`objc_msgSend` shim for them (100/050).
;;;
;;; Instrumented for the AppSpec scenario runner per the SceneKit Viewer
;;; logging contract (apps/macos/scenekit-viewer/docs/logging-contract.md): it
;;; writes a structured events.log the runner tails — [lifecycle]
;;; startup/shutdown, the bare launch line, and the two [scene]
;;; state-transition events (geometry-changed / color-changed) that make the
;;; spec §13 scene assertions observable at all (the SCNView's rendered
;;; contents are pixel-level, invisible to both OCR and the AX tree, and the
;;; closed verb set has no drag or pixel-diff verb). Under `launch-via 'open`
;;; LaunchServices discards the app's stdout, so the log file (not stdout) is
;;; the runner's read path; the stdout line is kept too (human-friendly when
;;; run unbundled).
;;;
;;; The logging is inlined here rather than split to a sibling events.ss for
;;; the same reason as hello-window / ui-controls-gallery / pdfkit-viewer: the
;;; bundler's closure walk (deps.rs) follows only `:gerbil-bindings/…`
;;; references, and these defines use only Gambit primitives (open-output-file,
;;; getenv, create-directory, force-output), so they ride the statically-linked
;;; prelude with no new import.
;;;
;;; Build via build.sh (bottle toolchain); bundle via bundle-gerbil.
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

;; --- Structured event log (logging contract) -------------------------------
;; Single writer: the Cocoa run loop serialises the main-thread callbacks that
;; emit — startup/launch before -run, the [scene] events from the picker's
;; action callback and the colour panel's continuous action callback (the
;; shared NSColorPanel is in-process and sends its action on the main thread),
;; shutdown on terminate — so one port with a post-write force-output suffices
;; (no lock needed).

;; Fixed default the descriptor's #:events-path mirrors, so the runner tails
;; the same file whether or not #:log-env (SCENEKIT_VIEWER_EVENTS_LOG)
;; propagates through LaunchServices.
(define sv-default-events-path "/tmp/scenekit-viewer/events.log")
(define sv-events-port #f)

;; SCENEKIT_VIEWER_EVENTS_LOG if set and non-empty, else the fixed default.
(define (sv-resolve-events-path)
  (let ((env (getenv "SCENEKIT_VIEWER_EVENTS_LOG" #f)))
    (if (and env (not (string=? env ""))) env sv-default-events-path)))

;; Directory component of `p` (everything before the last '/'), or #f.
(define (sv-path-parent p)
  (let loop ((i (- (string-length p) 1)))
    (cond
      ((< i 0) #f)
      ((char=? (string-ref p i) #\/) (substring p 0 i))
      (else (loop (- i 1))))))

;; Open + truncate the events.log: (create: 'maybe truncate: #t) creates it if
;; absent and truncates it if present. The parent dir is created if missing
;; (guarded against a race). Records are flushed per-line in sv-emit-line, so
;; a tail sees each promptly.
(define (sv-events-init!)
  (let* ((target (sv-resolve-events-path))
         (parent (sv-path-parent target)))
    (when (and parent (not (string=? parent "")) (not (file-exists? parent)))
      (with-exception-catcher (lambda (e) #f) (lambda () (create-directory parent))))
    (set! sv-events-port
      (open-output-file (list path: target truncate: #t create: 'maybe)))))

(define (sv-emit-line line)
  (when sv-events-port
    ;; Swallow only I/O-level failures (out-of-disk, closed-port races on
    ;; shutdown). A genuine programmer error still surfaces during dev.
    (with-exception-catcher
      (lambda (e) #f)
      (lambda ()
        (display line sv-events-port)
        (newline sv-events-port)
        (force-output sv-events-port)))))

;; Contract "Line format": strings are double-quoted with \\ / \" / newline
;; escaped; numbers/booleans/symbols emit bare.
(define (sv-quote-string s)
  (let ((out (open-output-string)))
    (write-char #\" out)
    (let loop ((i 0))
      (when (< i (string-length s))
        (let ((c (string-ref s i)))
          (cond
            ((char=? c #\\) (display "\\\\" out))
            ((char=? c #\") (display "\\\"" out))
            ((char=? c #\newline) (display "\\n" out))
            (else (write-char c out))))
        (loop (+ i 1))))
    (write-char #\" out)
    (get-output-string out)))

(define (sv-emit-startup)
  (sv-emit-line "[lifecycle] startup"))
(define (sv-emit-launch-line)
  (sv-emit-line "SceneKit Viewer running. Close window or Ctrl+C to exit."))
(define (sv-emit-shutdown reason)
  (sv-emit-line (string-append "[lifecycle] shutdown reason=" (symbol->string reason))))

;; The two [scene] events — each emitted AFTER the state change it names is
;; fully applied (post-state; contract "Scene events").

;; `shape` is the applied catalogue title (Cube/Sphere/Torus/Cylinder);
;; `r`/`g`/`b` are the stored current colour's device-RGB components ×255,
;; rounded to nearest (bare integers 0–255). Carrying the colour makes the
;; §13 key behaviour — the chosen colour survives a swap — a single-line
;; assertion.
(define (sv-emit-geometry-changed shape r g b)
  (sv-emit-line (string-append "[scene] geometry-changed shape=" (sv-quote-string shape)
                               " r=" (number->string r)
                               " g=" (number->string g)
                               " b=" (number->string b))))

;; Success path only — a nil panel colour and a failed device-RGB conversion
;; are §7.4 silent no-ops (no event, no error line).
(define (sv-emit-color-changed r g b)
  (sv-emit-line (string-append "[scene] color-changed r=" (number->string r)
                               " g=" (number->string g)
                               " b=" (number->string b))))

(define (sv-close-events!)
  (when sv-events-port
    (with-exception-catcher (lambda (e) #f)
      (lambda ()
        (force-output sv-events-port)
        (close-output-port sv-events-port))))
  (set! sv-events-port #f))
;; --- End structured event log ----------------------------------------------

;; Track the current NSColor in Scheme state so geometry swaps re-apply the
;; user's choice: SceneKit creates a fresh firstMaterial per geometry, so without
;; this every swap would reset to white.
(def current-color #f)

(define-entry-point (main)
  ;; ============================================================
  ;; Definitions
  ;; ============================================================
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
                        (sv-emit-shutdown 'menu)
                        (sv-close-events!))))
                  (list 'object) 'void))))

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
  ;; camera controller (orbit/zoom on mouse); autoenablesDefaultLighting (via
  ;; SCNSceneRenderer) gives ambient+key light without an SCNLight node.
  ;; nil options → #f.
  (def scn-view (make-scnview-init-with-frame-options (make-rect 0. 0. 640. 432.) #f))

  (def scene (scnscene-scene))
  (def root-node (scnscene-root-node scene))

  ;; index → (geometry . catalogue-title). One cond arms both the applied
  ;; geometry and the `shape` the [scene] geometry-changed event reports, so
  ;; event and state cannot diverge (the k98 single-source-of-truth shape,
  ;; realized as a pair — the gerbil pdfkit refresh-ui! precedent; a bare
  ;; `values` in gerbil risks the generics shadow). The else arm realizes the
  ;; §6 out-of-range → cube defensive default (unreachable through the
  ;; four-item picker).
  (def (make-geometry+title index)
    (cond
      ((= index 0) (cons (scnbox-box-with-width-height-length-chamfer-radius 2.0 2.0 2.0 0.1) "Cube"))
      ((= index 1) (cons (scnsphere-sphere-with-radius 1.2) "Sphere"))
      ((= index 2) (cons (scntorus-torus-with-ring-radius-pipe-radius 1.0 0.35) "Torus"))
      ((= index 3) (cons (scncylinder-cylinder-with-radius-height 1.0 2.0) "Cylinder"))
      (else (cons (scnbox-box-with-width-height-length-chamfer-radius 2.0 2.0 2.0 0.1) "Cube"))))

  (def geometry-node
    (scnnode-node-with-geometry (car (make-geometry+title 0))))

  ;; The stored colour folded to the logging contract's integer components:
  ;; device-RGB ×255, rounded to nearest (bare integers 0–255). Converts at
  ;; emit time via colorUsingColorSpace: device-RGB — a §7.4-stored colour is
  ;; already device-RGB, so only the initial systemRedColor actually converts
  ;; here (and its numeric components are OS/appearance-dependent; consumers
  ;; never assume the initial values). Returns (r g b), or #f if the
  ;; conversion fails — practically unreachable, and the caller then skips
  ;; the event rather than emit fabricated components. `wrap`→#f makes the
  ;; nil check plain truthiness.
  (def (current-color-rgb255)
    (let (rgb (nscolor-color-using-color-space
                current-color (nscolorspace-device-rgb-color-space)))
      (and rgb
           (list (inexact->exact (round (* 255 (nscolor-red-component rgb))))
                 (inexact->exact (round (* 255 (nscolor-green-component rgb))))
                 (inexact->exact (round (* 255 (nscolor-blue-component rgb))))))))

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
                (let* ((idx (nspopupbutton-index-of-selected-item geometry-picker))
                       (gt (make-geometry+title idx)))
                  (scnnode-set-geometry! geometry-node (car gt))
                  (apply-current-color!)
                  ;; [scene] geometry-changed — POST-state (geometry assigned +
                  ;; §7.2 colour re-apply done), carrying the folded stored
                  ;; colour so the §13 key behaviour (colour persists across a
                  ;; swap) is a single-line assertion.
                  (let (rgb (current-color-rgb255))
                    (when rgb
                      (sv-emit-geometry-changed (cdr gt) (car rgb) (cadr rgb) (caddr rgb))))))
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
                ;; can read. A nil panel colour / failed conversion are §7.4
                ;; silent no-ops: keep-previous, no event (`wrap`→#f, so the
                ;; nil checks are plain truthiness).
                (let (raw (nscolorpanel-color sender))
                  (when raw
                    (let (rgb (nscolor-color-using-color-space
                                raw (nscolorspace-device-rgb-color-space)))
                      (when rgb
                        (set! current-color rgb)
                        (apply-current-color!)
                        ;; [scene] color-changed — success path only, POST
                        ;; store+apply. current-color is the just-stored
                        ;; device-RGB colour, so the fold is exact (no
                        ;; conversion drift).
                        (let (folded (current-color-rgb255))
                          (when folded
                            (sv-emit-color-changed (car folded) (cadr folded) (caddr folded)))))))))
              (list 'object) 'void))))

  ;; ============================================================
  ;; Expressions
  ;; ============================================================
  (set! current-color (nscolor-system-red-color))

  (nsapplication-set-activation-policy! app NSApplicationActivationPolicyRegular)
  (nsapplication-set-delegate! app app-delegate)
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

  ;; Launch diagnostic (spec §3 step 6): the bare line beginning `SceneKit
  ;; Viewer` the runner's `wait-for-log` matches, dual-emitted to events.log
  ;; (the runner's read path) and stdout (human-friendly when run unbundled;
  ;; LaunchServices discards stdout under `open`).
  (sv-emit-launch-line)
  (displayln "SceneKit Viewer running. Close window or Ctrl+C to exit.")
  (nsapplication-run app))

;; --- Structured event log: open + [lifecycle] startup BEFORE (main) --------
;; The viewer builds its window/scene in main's *defines* section (the def
;; initializers evaluate before main's first expression), so `startup` cannot
;; be main's first expression as in hello-window — it lands here instead,
;; before (main) is entered and thus before window/scene construction, well
;; before the run loop (or the runner's `wait-ready` readiness probe times out).
(sv-events-init!)
(sv-emit-startup)

;; Test-config compatibility (logging-contract.md): the viewer reads no
;; runtime config, so it honours SCENEKIT_VIEWER_TEST_CONFIG by reading the
;; env var and treating absent/empty (and a missing file) as "no config" — a
;; deliberate no-op.
(getenv "SCENEKIT_VIEWER_TEST_CONFIG" #f)

(main)
