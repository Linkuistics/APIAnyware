;;;; dump.lisp — `save-lisp-and-die` the pdfkit-viewer standalone executable.
;;;;
;;;; Like scenekit-viewer this dumps WITH libAPIAnywareSbcl (ADR-0038 §5: the dylib is
;;;; NOT embedded — `save-lisp-and-die` keeps it in `*shared-objects*`, so the revived
;;;; image auto-reopens it by the recorded namestring). The bundler (`bundle-sbcl`,
;;;; ADR-0041) drives this file with
;;;; `AW_NATIVE_DYLIB_RECORD_AS=@executable_path/../Frameworks/...` set, so the recorded
;;;; namestring points at the VENDORED copy inside the .app and the bundle travels alone
;;;; (sbcl-vendor-libzstd-k75 retired the /tmp staging). Here the dylib is needed for the
;;;; SUBCLASS bounce shim (the `pdf-controller` delegate), not the trampoline residual;
;;;; Foundation/AppKit load `:load-residual nil`, but PDFKit loads `:load-residual t` for
;;;; its `constants.lisp` (`PDFViewPageChangedNotification`).
;;;;
;;;; At revive, `sb-ext:*init-hooks*` runs the mandatory startup re-resolution pass BEFORE
;;;; the toplevel: re-dlopen frameworks, re-resolve objc_msgSend, re-mask FP traps,
;;;; re-register the subclass forwarding dispatcher with the reopened dylib, AND — the
;;;; path this app is the first to need end-to-end — RE-RESOLVE the object/SAP-backed
;;;; `define-objc-constant` surface (the baked notification name is a dead pointer until
;;;; its value form is re-run). `-main` then re-synthesizes the delegate via
;;;; `ensure-pdf-controller` and registers the observer with the live constant.
;;;;
;;;; Invoked by the bundler (via build.sh step [2/3]):
;;;;   [AW_NATIVE_DYLIB_RECORD_AS=@executable_path/../Frameworks/libAPIAnywareSbcl.dylib]
;;;;   SDKROOT=… sbcl --non-interactive --disable-debugger \
;;;;     --load .../pdfkit-viewer/dump.lisp -- <output-exe-path> <dylib-path>

(in-package #:cl-user)

(defparameter *app-dir*
  (make-pathname :name nil :type nil :defaults (or *load-truename* *load-pathname*)))

;; Post-`--` args: 1 = output exe path, 2 = dylib path to record for revive.
(defparameter *post-args* (rest (member "--" sb-ext:*posix-argv* :test #'string=)))
(defparameter *out-exe*
  (or (first *post-args*) (namestring (merge-pathnames "pdfkit-viewer" *app-dir*))))
(defparameter *dylib*
  (or (second *post-args*) "/tmp/libAPIAnywareSbcl.dylib"))

(load (merge-pathnames "../_support/load-bindings.lisp" *app-dir*))

(in-package #:apianyware-sbcl-impl)

(setf *native-dylib-path* cl-user::*dylib*)
(aw-load-native-dylib)

(aw-app-load-framework "Foundation" :load-residual nil)
(aw-app-load-framework "AppKit" :load-residual nil)
(aw-app-load-framework "PDFKit" :load-residual t)

;; events.lisp first (pure CL — the pv-events package pdfkit-viewer.lisp references).
(load (merge-pathnames "events.lisp" cl-user::*app-dir*))
(load (merge-pathnames "pdfkit-viewer.lisp" cl-user::*app-dir*))

(format t "~&== dumping ~A (dylib recorded: ~A) ==~%" cl-user::*out-exe* cl-user::*dylib*)
(finish-output)

(sb-ext:save-lisp-and-die cl-user::*out-exe*
  :executable t
  :save-runtime-options t          ; standalone GUI: do not parse argv as SBCL options
  :toplevel (lambda ()
              ;; Env AW_PDFKIT_SMOKE makes the REVIVED image a construction smoke: it
              ;; re-synthesizes the delegate (exercising the startup re-resolution pass —
              ;; frameworks, dispatcher, AND the constant surface — in the dumped image)
              ;; and builds the window + registers the observer, then exits 0 without the
              ;; run loop — a host revive smoke before the VM.
              (let ((smoke (sb-ext:posix-getenv "AW_PDFKIT_SMOKE")))
                (handler-case (pdfkit-viewer-main :run (not smoke))
                  (error (e)
                    (format *error-output* "pdfkit-viewer fatal: ~A~%" e)
                    (finish-output *error-output*)
                    (sb-ext:exit :code 1)))
                (when smoke
                  (format t "### revived pdfkit-viewer construction OK~%")
                  (finish-output)))
              (sb-ext:exit :code 0)))
