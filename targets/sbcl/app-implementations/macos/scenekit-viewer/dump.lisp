;;;; dump.lisp — `save-lisp-and-die` the scenekit-viewer standalone executable (060).
;;;;
;;;; Like swift-native-probe this dumps WITH libAPIAnywareSbcl (ADR-0038 §5: the dylib is
;;;; NOT embedded — `save-lisp-and-die` keeps it in `*shared-objects*`, so the revived
;;;; image auto-reopens it by the path it was loaded from). We load it from a FIXED path
;;;; — `/tmp/libAPIAnywareSbcl.dylib` (build.sh stages the copy) — so the VM needs only
;;;; that one dylib at that path. Here the dylib is needed for the SUBCLASS bounce shim
;;;; (the target-action delegate), not the trampoline residual, so frameworks load
;;;; `:load-residual nil`.
;;;;
;;;; At revive, `sb-ext:*init-hooks*` runs the mandatory startup re-resolution pass BEFORE
;;;; the toplevel: re-dlopen frameworks, re-resolve objc_msgSend, re-mask FP traps, and —
;;;; the path this app is the first to exercise end-to-end — re-register the subclass
;;;; forwarding dispatcher with the reopened dylib + clear the stale synth-class tables.
;;;; `-main` then re-synthesizes the delegate subclass via `ensure-scene-controller`.
;;;;
;;;; Invoked by build.sh:
;;;;   SDKROOT=macosx sbcl --non-interactive --disable-debugger \
;;;;     --load .../apps/scenekit-viewer/dump.lisp -- <output-exe-path> <dylib-path>

(in-package #:cl-user)

(defparameter *app-dir*
  (make-pathname :name nil :type nil :defaults (or *load-truename* *load-pathname*)))

;; Post-`--` args: 1 = output exe path, 2 = dylib path to record for revive.
(defparameter *post-args* (rest (member "--" sb-ext:*posix-argv* :test #'string=)))
(defparameter *out-exe*
  (or (first *post-args*) (namestring (merge-pathnames "scenekit-viewer" *app-dir*))))
(defparameter *dylib*
  (or (second *post-args*) "/tmp/libAPIAnywareSbcl.dylib"))

(load (merge-pathnames "../_support/load-bindings.lisp" *app-dir*))

(in-package #:apianyware-sbcl-impl)

(setf *native-dylib-path* cl-user::*dylib*)
(aw-load-native-dylib)

(aw-app-load-framework "Foundation" :load-residual nil)
(aw-app-load-framework "AppKit" :load-residual nil)
(aw-app-load-framework "SceneKit" :load-residual nil)

(load (merge-pathnames "scenekit-viewer.lisp" cl-user::*app-dir*))

(format t "~&== dumping ~A (dylib recorded: ~A) ==~%" cl-user::*out-exe* cl-user::*dylib*)
(finish-output)

(sb-ext:save-lisp-and-die cl-user::*out-exe*
  :executable t
  :save-runtime-options t          ; standalone GUI: do not parse argv as SBCL options
  :toplevel (lambda ()
              ;; Env AW_SCENEKIT_SMOKE makes the REVIVED image a construction smoke: it
              ;; re-synthesizes the delegate subclass (exercising the startup re-resolution
              ;; pass + the dispatcher re-registration in the dumped image) and builds the
              ;; scene, then exits 0 without the run loop — a host revive smoke before the VM.
              (let ((smoke (sb-ext:posix-getenv "AW_SCENEKIT_SMOKE")))
                (handler-case (scenekit-viewer-main :run (not smoke))
                  (error (e)
                    (format *error-output* "scenekit-viewer fatal: ~A~%" e)
                    (finish-output *error-output*)
                    (sb-ext:exit :code 1)))
                (when smoke
                  (format t "### revived scenekit-viewer construction OK~%")
                  (finish-output)))
              (sb-ext:exit :code 0)))
