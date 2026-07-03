;;;; dump.lisp — `save-lisp-and-die` the drawing-canvas standalone executable.
;;;;
;;;; Like mini-browser/note-editor this dumps WITH libAPIAnywareSbcl (ADR-0038 §5: the dylib
;;;; is NOT embedded — `save-lisp-and-die` keeps it in `*shared-objects*`, so the revived
;;;; image auto-reopens it by the recorded namestring). The bundler (`bundle-sbcl`,
;;;; ADR-0041) drives this file with
;;;; `AW_NATIVE_DYLIB_RECORD_AS=@executable_path/../Frameworks/...` set, so the recorded
;;;; namestring points at the VENDORED copy inside the .app and the bundle travels alone
;;;; (the k137 rebuild retired this app's original 060-era /tmp staging, as the k128
;;;; note-editor rebuild did for its). Here the dylib is needed ONLY for the SUBCLASS
;;;; bounce shim BOTH subclasses use (`canvas-view`: drawRect:/mouse events;
;;;; `canvas-controller`: target-actions + the terminate delegate). No block bridge → no
;;;; `aw-init-block-dispatcher`.
;;;;
;;;; Framework loads mirror run.lisp: Foundation `:load-residual nil`, AppKit
;;;; `:load-residual nil`, CoreGraphics `:load-residual t` (for the `ns:cg-*` stroke functions).
;;;;
;;;; At revive, `sb-ext:*init-hooks*` runs the mandatory startup re-resolution pass BEFORE
;;;; the toplevel: re-dlopen frameworks, re-resolve objc_msgSend, re-mask FP traps, and
;;;; re-register the subclass forwarding dispatcher with the reopened dylib. `-main` then
;;;; re-synthesizes both subclasses via `ensure-canvas-classes`.
;;;;
;;;; Invoked by build.sh:
;;;;   SDKROOT=macosx sbcl --non-interactive --disable-debugger \
;;;;     --load .../apps/drawing-canvas/dump.lisp -- <output-exe-path> <dylib-path>

(in-package #:cl-user)

(defparameter *app-dir*
  (make-pathname :name nil :type nil :defaults (or *load-truename* *load-pathname*)))

;; Post-`--` args: 1 = output exe path, 2 = dylib path to record for revive.
(defparameter *post-args* (rest (member "--" sb-ext:*posix-argv* :test #'string=)))
(defparameter *out-exe*
  (or (first *post-args*) (namestring (merge-pathnames "drawing-canvas" *app-dir*))))
(defparameter *dylib*
  (or (second *post-args*) "/tmp/libAPIAnywareSbcl.dylib"))

(load (merge-pathnames "../_support/load-bindings.lisp" *app-dir*))

(in-package #:apianyware-sbcl-impl)

(setf *native-dylib-path* cl-user::*dylib*)
(aw-load-native-dylib)

(aw-app-load-framework "Foundation" :load-residual nil)
(aw-app-load-framework "AppKit" :load-residual nil)
(aw-app-load-framework "CoreGraphics" :load-residual t)

;; events.lisp first (pure CL — the dc-events package drawing-canvas.lisp references).
(load (merge-pathnames "events.lisp" cl-user::*app-dir*))
(load (merge-pathnames "drawing-canvas.lisp" cl-user::*app-dir*))

(format t "~&== dumping ~A (dylib recorded: ~A) ==~%" cl-user::*out-exe* cl-user::*dylib*)
(finish-output)

(sb-ext:save-lisp-and-die cl-user::*out-exe*
  :executable t
  :save-runtime-options t          ; standalone GUI: do not parse argv as SBCL options
  :toplevel (lambda ()
              ;; Env AW_CANVAS_SMOKE makes the REVIVED image a construction smoke: it
              ;; re-synthesizes both subclasses (exercising the startup re-resolution pass —
              ;; frameworks, dispatcher — in the dumped image), builds the window + canvas +
              ;; toolbar + wires everything, then exits 0 without the run loop — a host revive
              ;; smoke before the VM.
              (let ((smoke (sb-ext:posix-getenv "AW_CANVAS_SMOKE")))
                (handler-case (drawing-canvas-main :run (not smoke))
                  (error (e)
                    (format *error-output* "drawing-canvas fatal: ~A~%" e)
                    (finish-output *error-output*)
                    (sb-ext:exit :code 1)))
                (when smoke
                  (format t "### revived drawing-canvas construction OK~%")
                  (finish-output)))
              (sb-ext:exit :code 0)))
