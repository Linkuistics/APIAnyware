;;;; dump.lisp — `save-lisp-and-die` the hello-window standalone executable (060/020).
;;;;
;;;; Produces a single self-contained executable embedding the SBCL runtime, the loaded
;;;; binding library (runtime + Foundation + AppKit), and the app — the lightest VM
;;;; artifact: it travels alone (pure ObjC, no libAPIAnywareSbcl dylib; only system
;;;; frameworks + libobjc, which the VM always has) and needs NO SBCL provisioning in the
;;;; VM. At revive, `sb-ext:*init-hooks*` runs the mandatory startup re-resolution pass
;;;; (ADR-0034 §6 / ADR-0038 §5) BEFORE the toplevel — re-`dlopen`ing Foundation+AppKit,
;;;; re-resolving `objc_msgSend`, re-masking the FP traps — so every baked Class/SEL is
;;;; live before the first dispatch. This is a dev build script; the `bundle-sbcl` crate
;;;; (070-distribution) generalizes it, exactly as gerbil's app `build.sh` (`gxc -exe`)
;;;; preceded `bundle-gerbil`.
;;;;
;;;; Invoked by build.sh:
;;;;   SDKROOT=macosx sbcl --non-interactive --disable-debugger \
;;;;     --load .../apps/hello-window/dump.lisp -- <output-exe-path>

(in-package #:cl-user)

(defparameter *app-dir*
  (make-pathname :name nil :type nil :defaults (or *load-truename* *load-pathname*)))

;; The output executable path is the first post-`--` argument (build.sh passes it).
(defparameter *out-exe*
  (or (first (rest (member "--" sb-ext:*posix-argv* :test #'string=)))
      (namestring (merge-pathnames "hello-window" *app-dir*))))

(load (merge-pathnames "../_support/load-bindings.lisp" *app-dir*))

(in-package #:apianyware-sbcl-impl)

(aw-app-load-framework "Foundation" :load-residual nil)
(aw-app-load-framework "AppKit" :load-residual nil)

(load (merge-pathnames "hello-window.lisp" cl-user::*app-dir*))

(format t "~&== dumping ~A ==~%" cl-user::*out-exe*)
(finish-output)

(sb-ext:save-lisp-and-die cl-user::*out-exe*
  :executable t
  :save-runtime-options t          ; standalone GUI: do not parse argv as SBCL options
  :toplevel (lambda ()
              ;; Env AW_HELLO_SMOKE makes the REVIVED image a construction smoke: it
              ;; builds the UI (so the startup re-resolution pass — re-dlopen, re-resolve
              ;; objc_msgSend, re-mask FP traps — is exercised in the dumped image) then
              ;; exits 0 without the run loop. A host revive smoke before the VM round-trip.
              (let ((smoke (sb-ext:posix-getenv "AW_HELLO_SMOKE")))
                (handler-case (hello-window-main :run (not smoke))
                  (error (e)
                    (format *error-output* "hello-window fatal: ~A~%" e)
                    (finish-output *error-output*)
                    (sb-ext:exit :code 1)))
                (when smoke
                  (format t "### revived hello-window construction OK~%")
                  (finish-output)))
              (sb-ext:exit :code 0)))
