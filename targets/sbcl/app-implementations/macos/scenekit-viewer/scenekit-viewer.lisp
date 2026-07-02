;;;; scenekit-viewer.lisp — SceneKit Viewer sample app (sbcl target, the 060 ladder's
;;;; fourth app). A lit, continuously-spinning 3D geometry the user swaps via an
;;;; NSPopUpButton (cube / sphere / torus / cylinder) and recolours via NSColorPanel.
;;;; SCNView's `allowsCameraControl` gives orbit-on-drag + scroll-to-zoom for free.
;;;;
;;;; Written against the CL-family interface contract (ADR-0033 / the contract spec): it
;;;; names only the `ns:` surface, `make-instance` typed inits (§3.3), the per-selector
;;;; generics (§3.2 — including the SceneKit geometry/action class factories via the
;;;; `(eql (find-class 'ns:…))` specializer), the `@"…"` NSString reader (§3.2), and the
;;;; subclass macros `define-objc-subclass` / `define-objc-method` (§3.4/§3.5).
;;;;
;;;; FIRST GUI ladder app with a CUSTOM Lisp target-action delegate (hello-window/gallery
;;;; used only built-in selectors / static controls). The `scene-controller` is a real
;;;; ObjC subclass of NSObject; its three target-action selectors get the synthesized
;;;; default `v@:@` encoding (void return, one object arg) and are forwarded — bounced to
;;;; main, GC-safe — into CLOS `defmethod`s. So unlike the pure-ObjC gallery, this app
;;;; LOADS `libAPIAnywareSbcl` (the `aw_sbcl_subclass_*` bounce shim) and the VM is
;;;; provisioned with the dylib (as for swift-native-probe), even though every SceneKit /
;;;; AppKit call itself is plain ObjC (no Swift-native trampoline residual → `:load-residual
;;;; nil`; the dylib is loaded purely for the subclass machinery).
;;;;
;;;; DUMP/REVIVE of a synthesized subclass: the ObjC class pair lives in libobjc, not the
;;;; Lisp heap, so it does not survive `save-lisp-and-die`. The runtime startup pass clears
;;;; the synth tables AND (the scenekit-viewer fix) re-registers the forwarding dispatcher
;;;; with the reopened dylib; the app re-synthesizes by calling its `define-objc-subclass`
;;;; from `-main` (which is the revived image's toplevel) via `ensure-scene-controller`.
;;;;
;;;; INSTRUMENTED to the k105 logging contract
;;;; (apps/macos/scenekit-viewer/docs/logging-contract.md, sbcl-instrument-build-k110):
;;;; events.lisp (the `sv-events` package, loaded first by run.lisp/dump.lisp) writes the
;;;; structured events.log the AppSpec runner tails — [lifecycle] startup/shutdown, the
;;;; bare launch line, and the two [scene] state-transition events (geometry-changed /
;;;; color-changed) that make the spec §13 scene assertions runner-verifiable (the
;;;; SCNView's rendered contents are pixel-level, invisible to OCR/AX). One cond arms
;;;; both the applied geometry and the event's `shape` (`make-geometry+title`, the k107
;;;; single-source shape); the folded r/g/b are the STORED colour as device-RGB ×255,
;;;; converted at emit time (`current-color-rgb255`). §7.4: a nil panel colour and a
;;;; failed device-RGB conversion are silent KEEP-PREVIOUS no-ops (this leaf aligned the
;;;; old stores-raw fallback — the stored colour is now always device-RGB); the stderr
;;;; guard stays stderr, never events.log. The `applicationWillTerminate:` delegate hook
;;;; is the instrumentation's one addition (spec §12: no visible-behaviour change).
;;;;
;;;; Package: `apianyware-sbcl-impl` (the dev-harness home, like the other ladder apps).

(in-package #:apianyware-sbcl-impl)

;;; ---------------------------------------------------------------------------
;;; The standard app menu (Quit -> -[NSApplication terminate:]), as hello-window/gallery.
;;; ---------------------------------------------------------------------------
(defun install-app-menu (app app-name)
  (let ((main-menu   (make-instance 'ns:ns-menu :init-with-title @""))
        (app-item    (make-instance 'ns:ns-menu-item
                       :init-with-title @"" :action "" :key-equivalent @""))
        (app-submenu (make-instance 'ns:ns-menu :init-with-title @""))
        (quit-item   (make-instance 'ns:ns-menu-item
                       :init-with-title (aw-wrap (aw-make-nsstring
                                                  (format nil "Quit ~A" app-name)) t)
                       :action "terminate:"
                       :key-equivalent @"q")))
    (ns:add-item_ app-submenu quit-item)
    (ns:add-item_ main-menu app-item)
    (ns:set-submenu_for-item_ main-menu app-submenu app-item)
    (ns:set-main-menu_ app main-menu)))

;;; ---------------------------------------------------------------------------
;;; Geometry + material helpers (pure functions — no controller dependency).
;;; ---------------------------------------------------------------------------

(defun make-geometry+title (index)
  "An SCNGeometry for popup INDEX plus its catalogue title, as two values, via the
   geometry class factories (contract §3.2 `(eql (find-class 'ns:…))` class methods).
   Dimensions are CGFloat (double-float). One case arms both the applied geometry and
   the `shape` the [scene] geometry-changed event reports, so event and state cannot
   diverge (the k107 single-source-of-truth shape). The fall-through arm realizes the
   §6 out-of-range → cube defensive default (unreachable through the four-item picker)."
  (case index
    (1 (values (ns:sphere-with-radius_ (find-class 'ns:scn-sphere) 1.2d0) "Sphere"))
    (2 (values (ns:torus-with-ring-radius_pipe-radius_ (find-class 'ns:scn-torus) 1.0d0 0.35d0)
               "Torus"))
    (3 (values (ns:cylinder-with-radius_height_ (find-class 'ns:scn-cylinder) 1.0d0 2.0d0)
               "Cylinder"))
    (t (values (ns:box-with-width_height_length_chamfer-radius_
                (find-class 'ns:scn-box) 2.0d0 2.0d0 2.0d0 0.1d0)
               "Cube"))))

(defun own-color (color)
  "Take +1 ownership of COLOR (a +0 borrow from a `ns:` colour accessor) so it survives
   independently of whatever material currently holds it.

   The diffuse `contents` colour is kept alive ONLY by the material that retains it. But
   SceneKit allocates a fresh `firstMaterial` for every geometry, so `geometryChanged:`'s
   `setGeometry:` deallocates the old material — and with it the +0 colour — BEFORE
   `apply-color-to-node` recolours the new one, leaving a dangling slot (manifests as
   white). Retaining to +1 and arming the balancing main-thread release finalizer
   (`aw-wrap … t`, ADR-0036) decouples the stored colour's lifetime from any material's.
   Mirrors `aw-make-nsstring`'s +0→+1 promotion of an autoreleased transient."
  (when color
    (aw-wrap (%objc-retain (aw-ptr color)) t)))

(defun apply-color-to-node (node color)
  "Set NODE's geometry's firstMaterial.diffuse.contents to COLOR. SceneKit creates a
   fresh firstMaterial for every geometry, so this is re-applied after each swap (else
   the swap would reset the colour to white)."
  (let ((geom (ns:geometry node)))
    (when geom
      (let ((material (ns:first-material geom)))
        (when material
          (let ((prop (ns:diffuse material)))
            (when prop (ns:set-contents_ prop color))))))))

(defun current-color-rgb255 (color)
  "The stored current COLOR folded to the logging contract's integer components:
   device-RGB ×255, rounded to nearest (bare integers 0–255). Converts at emit time via
   colorUsingColorSpace: device-RGB — a §7.4-stored colour is already device-RGB, so
   only the initial systemRedColor actually converts here (and its numeric components
   are OS/appearance-dependent; consumers never assume the initial values). Returns
   (r g b) as a list, or NIL if COLOR is nil or the conversion fails — practically
   unreachable, and the caller then skips the event rather than emit fabricated
   components. NIL-safety rides the bindings: aw-wrap maps a NULL id to nil, so a bare
   `when` IS the objc-null check (the k107 tightening, already idiomatic here)."
  (when color
    (handler-case
        (let ((rgb (ns:color-using-color-space_
                    color (ns:device-rgb-color-space (find-class 'ns:ns-color-space)))))
          (when rgb
            (list (round (* 255 (ns:red-component rgb)))
                  (round (* 255 (ns:green-component rgb)))
                  (round (* 255 (ns:blue-component rgb))))))
      (error () nil))))

;;; ---------------------------------------------------------------------------
;;; The target-action delegate — a real ObjC subclass of NSObject (contract §3.4/§3.5).
;;;
;;; Defined INSIDE a function (not at file toplevel) so it re-synthesizes in a revived
;;; dumped image: `-main` is the dumped image's toplevel, and `aw-synthesize-subclass` /
;;; `aw-install-override` must re-run there (the ObjC class pair + the dispatch routing
;;; did not survive the dump). defclass/defmethod re-evaluation is idempotent.
;;; ---------------------------------------------------------------------------

(defvar *scene-controller-ready* nil
  "nil until `ensure-scene-controller` has defined the class in THIS process. Reset to
   nil by the dump (a fresh `defvar` value is NOT baked — but the symbol is, so a
   revived image starts nil again and re-defines).")

(defun ensure-scene-controller ()
  "Define the `scene-controller` ObjC subclass + its three target-action methods. Called
   from `-main` so it runs in whatever process actually shows the UI (host pre-flight or
   revived dump). Idempotent within a process via `*scene-controller-ready*`."
  (unless *scene-controller-ready*
    ;; Slots are read with `slot-value` (not per-class `:accessor`s) inside the method
    ;; bodies: the bodies are compiled when this file loads, but the accessor functions
    ;; would only exist once the inner `defclass` RUNS — `slot-value` is always defined,
    ;; so the methods compile warning-free.
    (define-objc-subclass scene-controller (ns:ns-object)
      (:slots
       (geometry-node :initarg :geometry-node)
       (current-color :initarg :current-color)))

    ;; geometryChanged: — SENDER is the NSPopUpButton; swap geometry to its selection
    ;; and re-apply the current colour to the new material.
    (define-objc-method (scene-controller "geometryChanged:") (self sender)
      (let ((idx  (ns:index-of-selected-item sender))
            (node (slot-value self 'geometry-node)))
        (multiple-value-bind (geom title) (make-geometry+title idx)
          (ns:set-geometry_ node geom)
          (apply-color-to-node node (slot-value self 'current-color))
          ;; [scene] geometry-changed — POST-state (geometry assigned + §7.2 colour
          ;; re-apply done), carrying the folded stored colour so the §13 key
          ;; behaviour (colour persists across a swap) is a single-line assertion.
          (let ((rgb (current-color-rgb255 (slot-value self 'current-color))))
            (when rgb
              (sv-events:emit-geometry-changed
               title (first rgb) (second rgb) (third rgb)))))))

    ;; openColor: — open the shared NSColorPanel, wired to fire colorChanged: continuously.
    (define-objc-method (scene-controller "openColor:") (self sender)
      (declare (ignore sender))
      (let ((panel (ns:shared-color-panel (find-class 'ns:ns-color-panel))))
        (ns:set-target_ panel self)
        (ns:set-action_ panel "colorChanged:")
        (ns:set-continuous_ panel t)
        (ns:make-key-and-order-front_ panel nil)))

    ;; colorChanged: — SENDER is the NSColorPanel. Normalise to device-RGB (NSColorPanel
    ;; colours can be in any colour space; SceneKit samples device-RGB cleanly) then
    ;; re-colour the live material. Guarded so a colour-space conversion failure never
    ;; unwinds into ObjC.
    (define-objc-method (scene-controller "colorChanged:") (self sender)
      (handler-case
          (let ((raw (ns:color sender)))
            ;; A nil panel colour and a failed device-RGB conversion are §7.4 silent
            ;; KEEP-PREVIOUS no-ops: no store, no apply, no event (absence IS the
            ;; contract; the stderr guard below is the only diagnostic channel — never
            ;; events.log). k110 aligned this from the old stores-raw `(or rgb raw)`
            ;; fallback, so the stored colour is ALWAYS device-RGB and the emit-time
            ;; fold is exact. aw-wrap maps a NULL id to nil, so `when` IS the
            ;; objc-null check.
            (when raw
              (let ((rgb (ns:color-using-color-space_
                          raw (ns:device-rgb-color-space (find-class 'ns:ns-color-space)))))
                (when rgb
                  ;; Own the colour (+1) before storing: it must outlive the material
                  ;; swap in `geometryChanged:` (see `own-color`).
                  (setf (slot-value self 'current-color) (own-color rgb))
                  (apply-color-to-node (slot-value self 'geometry-node)
                                       (slot-value self 'current-color))
                  ;; [scene] color-changed — success path only, POST store+apply.
                  ;; current-color is the just-stored device-RGB colour, so the fold
                  ;; is exact (no conversion drift).
                  (let ((folded (current-color-rgb255 (slot-value self 'current-color))))
                    (when folded
                      (sv-events:emit-color-changed
                       (first folded) (second folded) (third folded))))))))
        (error (e) (format *error-output* "~&colorChanged: ~A~%" e))))

    ;; `applicationWillTerminate:` is the only hook that fires on the menu/Cmd-Q quit
    ;; path: -[NSApplication terminate:] ends in a C exit(), which bypasses
    ;; sb-ext:*exit-hooks*. NSApplication auto-observes the notification for a delegate
    ;; that responds to this selector (informal conformance suffices). The logging
    ;; contract's one addition (k110), as in the prior three apps.
    (define-objc-method (scene-controller "applicationWillTerminate:") (self notification)
      (declare (ignore self notification))
      (handler-case
          (progn (sv-events:emit-shutdown 'menu) (sv-events:close-events!))
        (error (e)
          (format *error-output* "applicationWillTerminate: callback error: ~A~%" e)
          (finish-output *error-output*))))

    (setf *scene-controller-ready* t)))

;;; ---------------------------------------------------------------------------
;;; The window.
;;; ---------------------------------------------------------------------------
(defun scenekit-viewer-main (&key (run t))
  "Build the SceneKit-viewer UI and, unless RUN is nil, enter the AppKit run loop.

   RUN nil is the host construction PRE-FLIGHT (060): it synthesizes the delegate class,
   builds the scene graph + every control, wires target-action — every FFI crossing the
   app does — then returns WITHOUT blocking on `-run`, so a bare `sbcl --load` validates
   marshalling (and, in the revived image, the startup re-resolution + re-synthesis path)
   before the VM round-trip. The dumped image's toplevel calls RUN t."
  (ensure-scene-controller)
  (let ((app (ns:shared-application (find-class 'ns:ns-application))))
    (ns:set-activation-policy_ app ns:ns-application-activation-policy-regular)
    (install-app-menu app "SceneKit Viewer")

    ;; --- Structured event log: open + [lifecycle] startup BEFORE construction ---
    ;; `startup` must land before the app blocks in (ns:run app) or the runner's
    ;; `wait-ready` readiness probe times out; the contract wants it ahead of
    ;; window/scene construction. Gated on the real run — the build-time smoke needs
    ;; no log file (the emitters no-op on a nil port). Test-config compatibility: the
    ;; viewer reads no runtime config, so it honours SCENEKIT_VIEWER_TEST_CONFIG by
    ;; reading the env var and treating absent/empty as "no config" — a deliberate
    ;; no-op.
    (when run
      (sv-events:events-init!)
      (sv-events:emit-startup)
      (sb-ext:posix-getenv "SCENEKIT_VIEWER_TEST_CONFIG"))

    (aw-with-rect (frame 0 0 640 480)
      (let* ((window (make-instance 'ns:ns-window
                       :init-with-content-rect frame
                       :style-mask (logior ns:ns-window-style-mask-titled
                                           ns:ns-window-style-mask-closable
                                           ns:ns-window-style-mask-miniaturizable
                                           ns:ns-window-style-mask-resizable)
                       :backing ns:ns-backing-store-buffered
                       :defer nil))
             (content (ns:content-view window)))
        (ns:set-title_ window @"SceneKit Viewer")
        (ns:center window)
        (aw-with-size (minsz 480 360) (ns:set-min-size_ window minsz))

        ;; --- SCNView (fills below the toolbar; camera control + default lighting) ---
        (let ((scn-view (aw-with-rect (vframe 0 0 640 432)
                          (make-instance 'ns:scn-view :init-with-frame vframe :options nil))))
          (ns:set-autoresizing-mask_ scn-view
            (logior ns:ns-view-width-sizable ns:ns-view-height-sizable))
          (ns:set-allows-camera-control_ scn-view t)
          (ns:set-autoenables-default-lighting_ scn-view t)   ; SCNSceneRenderer protocol
          (ns:set-background-color_ scn-view (ns:dark-gray-color (find-class 'ns:ns-color)))
          (ns:add-subview_ content scn-view)

          ;; --- Scene + spinning, coloured geometry node ---
          (let* ((scene (ns:scene (find-class 'ns:scn-scene)))
                 (root  (progn (ns:set-scene_ scn-view scene)
                               (ns:root-node scene)))
                 ;; make-geometry+title's secondary value (the title) is discarded
                 ;; here — CL argument positions take the primary value only.
                 (geometry-node (ns:node-with-geometry_ (find-class 'ns:scn-node)
                                                        (make-geometry+title 0)))
                 ;; Own the initial colour (+1) too — same material-swap survival concern.
                 (current-color (own-color (ns:system-red-color (find-class 'ns:ns-color)))))
            (ns:add-child-node_ root geometry-node)
            (apply-color-to-node geometry-node current-color)
            ;; rotateBy is a single finite rotate; repeatActionForever makes it a
            ;; continuous spin that survives geometry swaps (swapping node.geometry does
            ;; not cancel actions on the node).  SCNActionable protocol: run-action_.
            (ns:run-action_ geometry-node
              (ns:repeat-action-forever_ (find-class 'ns:scn-action)
                (ns:rotate-by-x_y_z_duration_ (find-class 'ns:scn-action)
                                              0.0d0 1.5d0 0.0d0 4.0d0)))

            ;; --- The delegate, holding the live node + current colour ---
            (let ((controller (make-instance 'scene-controller
                                :geometry-node geometry-node
                                :current-color current-color)))

              ;; App delegate for the terminate hook (logging contract; k110). Installed
              ;; unconditionally so the pre-flight / revive smoke exercises set-delegate.
              ;; The controller instance is pinned in *subclass-instances* (a STRONG
              ;; table — subclass.lisp), so Cocoa's weak delegate reference and the
              ;; controls' weak target references never reap it.
              (ns:set-delegate_ app controller)

              ;; --- Toolbar: geometry popup + Colour button in a horizontal stack ---
              (let ((picker (aw-with-rect (pframe 0 0 150 26)
                              (make-instance 'ns:ns-pop-up-button
                                :init-with-frame pframe :pulls-down nil))))
                (ns:add-item-with-title_ picker @"Cube")
                (ns:add-item-with-title_ picker @"Sphere")
                (ns:add-item-with-title_ picker @"Torus")
                (ns:add-item-with-title_ picker @"Cylinder")
                (ns:set-target_ picker controller)
                (ns:set-action_ picker "geometryChanged:")

                (let ((color-button (ns:button-with-title_target_action_
                                     (find-class 'ns:ns-button) @"Colour…"
                                     controller "openColor:"))
                      (stack (make-instance 'ns:ns-stack-view)))
                  (aw-with-rect (sframe 12 440 616 32) (ns:set-frame_ stack sframe))
                  (ns:set-orientation_ stack ns:ns-user-interface-layout-orientation-horizontal)
                  (ns:set-spacing_ stack 8.0d0)
                  (ns:add-arranged-subview_ stack picker)
                  (ns:add-arranged-subview_ stack color-button)
                  (ns:set-autoresizing-mask_ stack
                    (logior ns:ns-view-width-sizable ns:ns-view-min-y-margin))
                  (ns:add-subview_ content stack)

                  ;; --- Show + run ---
                  (ns:make-key-and-order-front_ window nil)
                  (ns:activate-ignoring-other-apps_ app t)
                  ;; Keep the controller alive for the process (target/action does not
                  ;; retain; the synthesized-instance back-ref already retains it, but
                  ;; bind it so the compiler does not flag it unused).
                  ;; Launch diagnostic (spec §3 step 6): the bare line beginning
                  ;; `SceneKit Viewer` the runner's `wait-for-log` matches in
                  ;; events.log, plus the human-friendly stdout line (kept for
                  ;; unbundled runs; LaunchServices discards stdout under `open`) —
                  ;; dual emission.
                  (when run
                    (sv-events:emit-launch-line)
                    (format t "~&SceneKit Viewer opened. Quit with Cmd-Q.~%")
                    (finish-output)
                    (ns:run app))
                  controller)))))))))
