;;;; run.lisp — dev host runner for scenekit-viewer (interpreted `sbcl --load`).
;;;;
;;;; Like swift-native-probe, this app LOADS libAPIAnywareSbcl — but for a different
;;;; reason: not the Swift-native trampoline residual (every SceneKit/AppKit call here is
;;;; plain ObjC, so frameworks load `:load-residual nil`), but the `aw_sbcl_subclass_*`
;;;; bounce shim the custom target-action delegate (`scene-controller`) needs. Loading the
;;;; dylib also lets the class-file residual `aw_sbcl_*` aliens resolve (harmless, unused).
;;;; Two modes:
;;;;   - default                  : enter the AppKit run loop (interactive dev run; needs a
;;;;                                WindowServer session — use the dumped .app for the VM);
;;;;   - env AW_SCENEKIT_SMOKE set : the host construction PRE-FLIGHT — synthesize the
;;;;                                delegate subclass, build the scene + controls, wire
;;;;                                target-action, then return without the run loop, so a
;;;;                                CLI load validates marshalling + the subclass machinery.
;;;;
;;;; Run the pre-flight from the repo root:
;;;;   SDKROOT=macosx AW_SCENEKIT_SMOKE=1 sbcl --non-interactive --disable-debugger \
;;;;     --load generation/targets/sbcl/apps/scenekit-viewer/run.lisp

(in-package #:cl-user)

(defparameter *app-dir*
  (make-pathname :name nil :type nil :defaults (or *load-truename* *load-pathname*))
  "Absolute directory of this app (apps/scenekit-viewer/).")

(load (merge-pathnames "../_support/load-bindings.lisp" *app-dir*))

(in-package #:apianyware-sbcl-impl)

;; The dev dylib lives in the swift build output; the repo root is three dirs up from
;; the SBCL target root (generation/targets/sbcl/ -> generation/targets/ -> generation/ -> repo).
(defparameter *repo-root*
  (make-pathname :directory (butlast (pathname-directory cl-user::*aw-sbcl-root*) 3)
                 :host (pathname-host cl-user::*aw-sbcl-root*)
                 :device (pathname-device cl-user::*aw-sbcl-root*)))
(setf *native-dylib-path*
      (namestring (merge-pathnames "swift/.build/arm64-apple-macosx/debug/libAPIAnywareSbcl.dylib"
                                   *repo-root*)))
(aw-load-native-dylib)

(aw-app-load-framework "Foundation" :load-residual nil)
(aw-app-load-framework "AppKit" :load-residual nil)
(aw-app-load-framework "SceneKit" :load-residual nil)

(load (merge-pathnames "scenekit-viewer.lisp" cl-user::*app-dir*))

(let ((smoke (sb-ext:posix-getenv "AW_SCENEKIT_SMOKE")))
  (scenekit-viewer-main :run (not smoke))
  (when smoke
    (format t "~&### scenekit-viewer construction pre-flight OK~%")
    (finish-output)))
