;;;; dump.lisp — `save-lisp-and-die` the ui-controls-gallery standalone exe (060/040).
;;;;
;;;; Embeds the SBCL runtime + the loaded binding library (runtime + Foundation + AppKit)
;;;; + the app into one self-contained executable. Like hello-window it travels alone:
;;;; pure ObjC, no libAPIAnywareSbcl dylib (only system frameworks + libobjc + libzstd),
;;;; so the VM needs NO SBCL provisioning. At revive, `sb-ext:*init-hooks*` runs the
;;;; startup re-resolution pass (re-`dlopen`, re-resolve `objc_msgSend`, re-mask FP traps)
;;;; BEFORE the toplevel.
;;;;
;;;; Invoked by build.sh:
;;;;   SDKROOT=macosx sbcl --non-interactive --disable-debugger \
;;;;     --load .../apps/ui-controls-gallery/dump.lisp -- <output-exe-path>

(in-package #:cl-user)

(defparameter *app-dir*
  (make-pathname :name nil :type nil :defaults (or *load-truename* *load-pathname*)))

(defparameter *out-exe*
  (or (first (rest (member "--" sb-ext:*posix-argv* :test #'string=)))
      (namestring (merge-pathnames "ui-controls-gallery" *app-dir*))))

(load (merge-pathnames "../_support/load-bindings.lisp" *app-dir*))

(in-package #:apianyware-sbcl-impl)

(aw-app-load-framework "Foundation" :load-residual nil)
(aw-app-load-framework "AppKit" :load-residual nil)

(load (merge-pathnames "ui-controls-gallery.lisp" cl-user::*app-dir*))

(format t "~&== dumping ~A ==~%" cl-user::*out-exe*)
(finish-output)

(sb-ext:save-lisp-and-die cl-user::*out-exe*
  :executable t
  :save-runtime-options t          ; standalone GUI: do not parse argv as SBCL options
  :toplevel (lambda ()
              ;; Env AW_GALLERY_SMOKE makes the REVIVED image a construction smoke: it
              ;; builds the whole UI (exercising the startup re-resolution pass in the
              ;; dumped image) then exits 0 without the run loop — a host revive smoke
              ;; before the VM round-trip.
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
