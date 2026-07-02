;; scenekit-viewer.sls — SceneKit Viewer sample app (chez target).
;;
;; A rotating 3D geometry (cube / sphere / torus / cylinder) the user
;; can swap via an NSPopUpButton and recolor via NSColorPanel. SCNView's
;; allowsCameraControl gives orbit-on-drag and scroll-to-zoom for free.
;; Mirrors targets/racket/app-implementations/macos/scenekit-viewer/.
;;
;; Exercises one chez `make-delegate` carrying three selectors
;; (geometryChanged:, openColor:, colorChanged:), one of which is
;; the NSColorPanel target — the first chez sample to drive the
;; shared color panel — plus the app delegate's terminate hook.
;;
;; The body of `(define-entry-point (main) ...)` is a procedure body
;; in R6RS terms — all internal `define`s precede every expression.
;; Mixing them is what `(import (chezscheme))` rejects at script load
;; with "invalid context for definition".
;;
;; Instrumented for the AppSpec scenario runner per the SceneKit Viewer
;; logging contract (apps/macos/scenekit-viewer/docs/logging-contract.md):
;; it writes a structured events.log the runner tails — [lifecycle]
;; startup/shutdown, the bare launch line, and the two [scene]
;; state-transition events (geometry-changed / color-changed) that make
;; the spec §13 scene assertions observable at all (the SCNView's rendered
;; contents are pixel-level, invisible to both OCR and the AX tree, and
;; the closed verb set has no drag or pixel-diff verb). Under `launch-via
;; 'open` LaunchServices discards the app's stdout, so the log file (not
;; stdout) is the runner's read path; the stdout line is kept too
;; (human-friendly when run unbundled).
;;
;; The logging is inlined here rather than extracted to a sibling
;; `events.sls` for the same reason as hello-window / ui-controls-gallery /
;; pdfkit-viewer: chez resolves `(import …)` by library-name→path against
;; the whole-program compile tree, so a sibling library would need an
;; `apps/`-prefixed name. These top-level defines use only (chezscheme)
;; names, so the standalone bundler resolves them with no new library on
;; the path.
;;
;; Run unbundled with:
;;   chez --libdirs targets/chez/bindings/macos \
;;        --script targets/chez/app-implementations/macos/scenekit-viewer/scenekit-viewer.sls
;; Bundled (the runnable artifact) via build.sh, which wraps
;;   `cargo run --example bundle_app -p apianyware-bundle-chez
;;    -- scenekit-viewer`.

(import (chezscheme)
        (apianyware appkit)
        (apianyware scenekit)
        (apianyware foundation)
        (apianyware runtime cocoa)
        (apianyware runtime objc)
        (apianyware runtime types)
        (apianyware runtime dispatch))

;; --- Structured event log (logging contract) -------------------------------
;; Single writer: the Cocoa run loop serialises the main-thread callbacks that
;; emit — startup/launch before -run, the [scene] events from the picker's
;; action callback and the colour panel's continuous action callback (the
;; shared NSColorPanel is in-process and sends its action on the main thread),
;; shutdown on terminate — so one port with a post-write flush suffices (no
;; lock needed).

;; Fixed default the descriptor's #:events-path mirrors, so the runner tails
;; the same file whether or not #:log-env (SCENEKIT_VIEWER_EVENTS_LOG)
;; propagates through LaunchServices.
(define sv-default-events-path "/tmp/scenekit-viewer/events.log")
(define sv-events-port #f)

;; SCENEKIT_VIEWER_EVENTS_LOG if set and non-empty, else the fixed default.
(define (sv-resolve-events-path)
  (let ([env (getenv "SCENEKIT_VIEWER_EVENTS_LOG")])
    (if (and env (not (string=? env ""))) env sv-default-events-path)))

;; Directory component of `p` (everything before the last '/'), or #f.
(define (sv-path-parent p)
  (let loop ([i (- (string-length p) 1)])
    (cond
      [(< i 0) #f]
      [(char=? (string-ref p i) #\/) (substring p 0 i)]
      [else (loop (- i 1))])))

;; Open + truncate the events.log: (file-options no-fail) creates it if absent
;; and truncates it if present. Line-buffered so a tail sees each record
;; promptly. The parent dir is created if missing (guarded against a race).
(define (sv-events-init!)
  (let* ([target (sv-resolve-events-path)]
         [parent (sv-path-parent target)])
    (when (and parent (not (string=? parent "")) (not (file-directory? parent)))
      (guard (e [#t (void)]) (mkdir parent)))
    (set! sv-events-port
      (open-file-output-port target
        (file-options no-fail)
        (buffer-mode line)
        (make-transcoder (utf-8-codec))))))

(define (sv-emit-line line)
  (when sv-events-port
    ;; Swallow only I/O-level failures (out-of-disk, closed-port races on
    ;; shutdown). A genuine programmer error still surfaces during dev.
    (guard (e [#t (void)])
      (put-string sv-events-port line)
      (put-char sv-events-port #\newline)
      (flush-output-port sv-events-port))))

;; Contract "Line format": strings are double-quoted with \\ / \" / newline
;; escaped; numbers/booleans/symbols emit bare.
(define (sv-quote-string s)
  (let ([out (open-output-string)])
    (put-char out #\")
    (string-for-each
      (lambda (c)
        (case c
          [(#\\) (put-string out "\\\\")]
          [(#\") (put-string out "\\\"")]
          [(#\newline) (put-string out "\\n")]
          [else (put-char out c)]))
      s)
    (put-char out #\")
    (get-output-string out)))

(define (sv-emit-startup)
  (sv-emit-line "[lifecycle] startup"))
(define (sv-emit-launch-line)
  (sv-emit-line "SceneKit Viewer running. Close window or Ctrl+C to exit."))
(define (sv-emit-shutdown reason)
  (sv-emit-line (format "[lifecycle] shutdown reason=~a" reason)))

;; The two [scene] events — each emitted AFTER the state change it names is
;; fully applied (post-state; contract "Scene events").

;; `shape` is the applied catalogue title (Cube/Sphere/Torus/Cylinder);
;; `r`/`g`/`b` are the stored current colour's device-RGB components ×255,
;; rounded to nearest (bare integers 0–255). Carrying the colour makes the
;; §13 key behaviour — the chosen colour survives a swap — a single-line
;; assertion.
(define (sv-emit-geometry-changed shape r g b)
  (sv-emit-line (format "[scene] geometry-changed shape=~a r=~a g=~a b=~a"
                        (sv-quote-string shape) r g b)))

;; Success path only — a nil panel colour and a failed device-RGB conversion
;; are §7.4 silent no-ops (no event, no error line).
(define (sv-emit-color-changed r g b)
  (sv-emit-line (format "[scene] color-changed r=~a g=~a b=~a" r g b)))

(define (sv-close-events!)
  (when sv-events-port
    (guard (e [#t (void)])
      (flush-output-port sv-events-port)
      (close-output-port sv-events-port)))
  (set! sv-events-port #f))

(define-entry-point (main)
  ;; ============================================================
  ;; Definitions
  ;; ============================================================

  (define app (nsapplication-shared-application))

  ;; --- App delegate (terminate hook → [lifecycle] shutdown reason=menu) ---
  ;; The osascript graceful quit the runner uses (quit-impl! / the Command-Q
  ;; scenario) routes through applicationWillTerminate:. Cocoa holds the
  ;; delegate weakly, so keep `app-delegate` reachable — this define lives for
  ;; the whole of `main`, which spans the run loop. The callback body is
  ;; guarded because an unhandled exception in an ObjC callback crashes the
  ;; app with no Scheme backtrace.
  (define app-delegate
    (make-delegate
      `(("applicationWillTerminate:"
         ,(lambda (notification)
            (guard (e [#t (void)])
              (sv-emit-shutdown 'menu)
              (sv-close-events!)))
         (void*) void))))

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

  ;; index → (values geometry catalogue-title). One cond arms both the applied
  ;; geometry and the `shape` the [scene] geometry-changed event reports, so
  ;; event and state cannot diverge (the k98 single-source-of-truth shape). The
  ;; else arm realizes the §6 out-of-range → cube defensive default
  ;; (unreachable through the four-item picker).
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

  ;; Track the current NSColor in Scheme state so geometry swaps re-apply
  ;; the user's choice to the new material. SceneKit creates a fresh
  ;; firstMaterial for every geometry — without this, every swap would
  ;; reset the color to white.
  (define current-color (nscolor-system-red-color))

  ;; The stored colour folded to the logging contract's integer components:
  ;; device-RGB ×255, rounded to nearest (bare integers 0–255). Converts at
  ;; emit time via colorUsingColorSpace: device-RGB — a §7.4-stored colour is
  ;; already device-RGB, so only the initial systemRedColor actually converts
  ;; here (and its numeric components are OS/appearance-dependent; consumers
  ;; never assume the initial values). Returns (r g b), or #f if the
  ;; conversion fails — practically unreachable, and the caller then skips
  ;; the event rather than emit fabricated components.
  (define (current-color-rgb255)
    (let ([rgb (nscolor-color-using-color-space
                 current-color (nscolorspace-device-rgb-color-space))])
      (and (not (zero? (objc-object-ptr rgb)))
           (list (exact (round (* 255 (nscolor-red-component rgb))))
                 (exact (round (* 255 (nscolor-green-component rgb))))
                 (exact (round (* 255 (nscolor-blue-component rgb))))))))

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
              (let-values ([(geom title) (make-geometry+title idx)])
                (scnnode-set-geometry! geometry-node geom)
                (apply-current-color!)
                ;; [scene] geometry-changed — POST-state (geometry assigned +
                ;; §7.2 colour re-apply done), carrying the folded stored
                ;; colour so the §13 key behaviour (colour persists across a
                ;; swap) is a single-line assertion.
                (let ([rgb (current-color-rgb255)])
                  (when rgb
                    (sv-emit-geometry-changed title (car rgb) (cadr rgb) (caddr rgb)))))))
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
            ;; to device-RGB so downstream component accessors (the rgb
            ;; fold, future serialization) don't raise. SceneKit's
            ;; material path doesn't sample directly, but the conversion
            ;; is cheap insurance against a space SceneKit can't read.
            ;; A nil panel colour / failed conversion are §7.4 silent
            ;; no-ops: keep-previous, no event.
            (let ([raw (nscolorpanel-color (borrow-objc-object sender))])
              (unless (zero? (objc-object-ptr raw))
                (let ([rgb (nscolor-color-using-color-space
                             raw (nscolorspace-device-rgb-color-space))])
                  (unless (zero? (objc-object-ptr rgb))
                    (set! current-color rgb)
                    (apply-current-color!)
                    ;; [scene] color-changed — success path only, POST
                    ;; store+apply. current-color is the just-stored
                    ;; device-RGB colour, so the fold is exact (no
                    ;; conversion drift).
                    (let ([folded (current-color-rgb255)])
                      (when folded
                        (sv-emit-color-changed (car folded) (cadr folded) (caddr folded)))))))))
         (void*) void))))

  ;; ============================================================
  ;; Expressions
  ;; ============================================================

  (nsapplication-set-activation-policy! app NSApplicationActivationPolicyRegular)
  (nsapplication-set-delegate! app (delegate-ptr app-delegate))
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

  ;; Launch diagnostic (spec §3 step 6): the bare line beginning `SceneKit
  ;; Viewer` the runner's `wait-for-log` matches, dual-emitted to events.log
  ;; (the runner's read path) and stdout (human-friendly when run unbundled;
  ;; LaunchServices discards stdout under `open`).
  (sv-emit-launch-line)
  (display "SceneKit Viewer running. Close window or Ctrl+C to exit.\n")
  (nsapplication-run app))

;; --- Structured event log: open + [lifecycle] startup BEFORE (main) --------
;; The viewer builds its window/scene in `main`'s defines section (R6RS body:
;; all defines precede every expression), so `startup` cannot be main's first
;; expression as in hello-window — it lands here instead, before (main) is
;; entered and thus before window/scene construction, well before the run
;; loop (or the runner's `wait-ready` readiness probe times out).
(sv-events-init!)
(sv-emit-startup)

;; Test-config compatibility (logging-contract.md): the viewer reads no
;; runtime config, so it honours SCENEKIT_VIEWER_TEST_CONFIG by reading the
;; env var and treating absent/empty (and a missing file) as "no config" — a
;; deliberate no-op.
(getenv "SCENEKIT_VIEWER_TEST_CONFIG")

(main)
