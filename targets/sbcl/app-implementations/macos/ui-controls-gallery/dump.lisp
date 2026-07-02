;;;; dump.lisp — `save-lisp-and-die` the ui-controls-gallery standalone exe (060/040).
;;;;
;;;; Embeds the SBCL runtime + the loaded binding library (runtime + Foundation + AppKit)
;;;; + the app into one self-contained executable. The AppSpec logging contract's
;;;; callbacks (terminate delegate + the four [controls] target-actions) need
;;;; libAPIAnywareSbcl's subclass bounce shim, so the dump loads the dylib (arg 2) — like
;;;; hello-window/note-editor. ADR-0038 §5: the dylib is NOT embedded — `save-lisp-and-die`
;;;; keeps it in `*shared-objects*` and the revived image auto-reopens it by the recorded
;;;; namestring. The bundler (`bundle-sbcl`, ADR-0041) drives this file with
;;;; `AW_NATIVE_DYLIB_RECORD_AS=@executable_path/../Frameworks/...` set, so the recorded
;;;; namestring points at the VENDORED copy inside the .app and the bundle travels alone
;;;; (sbcl-vendor-libzstd-k75 retired the /tmp staging).
;;;; At revive, `sb-ext:*init-hooks*` runs the mandatory startup re-resolution pass
;;;; (ADR-0034 §6 / ADR-0038 §5) BEFORE the toplevel — re-`dlopen`ing Foundation+AppKit +
;;;; the dylib, re-resolving `objc_msgSend`, re-masking the FP traps, re-registering the
;;;; subclass forwarding dispatcher. `-main` then re-synthesizes the controller class via
;;;; `ensure-gallery-controller`.
;;;;
;;;; Invoked by the bundler (via build.sh step [2/3]):
;;;;   [AW_NATIVE_DYLIB_RECORD_AS=@executable_path/../Frameworks/libAPIAnywareSbcl.dylib]
;;;;   SDKROOT=… sbcl --non-interactive --disable-debugger \
;;;;     --load .../ui-controls-gallery/dump.lisp -- <output-exe-path> <dylib-path>

(in-package #:cl-user)

(defparameter *app-dir*
  (make-pathname :name nil :type nil :defaults (or *load-truename* *load-pathname*)))

;; Post-`--` args: 1 = output exe path, 2 = dylib path to load at dump time (the bundler
;; passes its discovered build path; a bare manual invocation falls back to /tmp).
(defparameter *post-args* (rest (member "--" sb-ext:*posix-argv* :test #'string=)))
(defparameter *out-exe*
  (or (first *post-args*)
      (namestring (merge-pathnames "ui-controls-gallery" *app-dir*))))
(defparameter *dylib*
  (or (second *post-args*) "/tmp/libAPIAnywareSbcl.dylib"))

(load (merge-pathnames "../_support/load-bindings.lisp" *app-dir*))

(in-package #:apianyware-sbcl-impl)

;; Load the dylib from the path we record for revive (ADR-0038 §5 auto-reopen). Needed for
;; the subclass bounce shim the controller callbacks use; the subclass dispatcher
;; self-registers on the first `define-objc-method`.
(setf *native-dylib-path* cl-user::*dylib*)
(aw-load-native-dylib)

(aw-app-load-framework "Foundation" :load-residual nil)
(aw-app-load-framework "AppKit" :load-residual nil)

(load (merge-pathnames "events.lisp" cl-user::*app-dir*))
(load (merge-pathnames "ui-controls-gallery.lisp" cl-user::*app-dir*))

(format t "~&== dumping ~A (dylib recorded: ~A) ==~%" cl-user::*out-exe* cl-user::*dylib*)
(finish-output)

(sb-ext:save-lisp-and-die cl-user::*out-exe*
  :executable t
  :save-runtime-options t          ; standalone GUI: do not parse argv as SBCL options
  :toplevel (lambda ()
              ;; Env AW_GALLERY_SMOKE makes the REVIVED image a construction smoke: it
              ;; builds the whole UI (exercising the startup re-resolution pass — re-dlopen,
              ;; re-resolve objc_msgSend, re-mask FP traps, re-register the subclass
              ;; dispatcher — plus the controller re-synthesis) then exits 0 without the
              ;; run loop — a host revive smoke before the VM round-trip.
              (let ((smoke (sb-ext:posix-getenv "AW_GALLERY_SMOKE")))
                (handler-case (ui-controls-gallery-main :run (not smoke))
                  (error (e)
                    (format *error-output* "ui-controls-gallery fatal: ~A~%" e)
                    (finish-output *error-output*)
                    (sb-ext:exit :code 1)))
                (when smoke
                  (format t "### revived ui-controls-gallery construction OK~%")
                  (finish-output)))
              (sb-ext:exit :code 0)))
