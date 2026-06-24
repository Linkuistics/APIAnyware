;;;; dump.lisp — `save-lisp-and-die` the mini-browser standalone executable (060).
;;;;
;;;; Like scenekit-viewer/pdfkit-viewer this dumps WITH libAPIAnywareSbcl (ADR-0038 §5: the
;;;; dylib is NOT embedded — `save-lisp-and-die` keeps it in `*shared-objects*`, so the
;;;; revived image auto-reopens it by the path it was loaded from). We load it from a FIXED
;;;; path — `/tmp/libAPIAnywareSbcl.dylib` (build.sh stages the copy) — so the VM needs only
;;;; that one dylib at that path. Here the dylib is needed for the SUBCLASS bounce shim (the
;;;; `browser-controller` delegate); every framework loads `:load-residual nil` (the app
;;;; uses no framework constants/functions, and the WKNavigationDelegate ABI is read live
;;;; off the protocol).
;;;;
;;;; At revive, `sb-ext:*init-hooks*` runs the mandatory startup re-resolution pass BEFORE
;;;; the toplevel: re-dlopen frameworks (re-registering WebKit's protocol metadata),
;;;; re-resolve objc_msgSend, re-mask FP traps, and re-register the subclass forwarding
;;;; dispatcher with the reopened dylib. `-main` then re-synthesizes the controller via
;;;; `ensure-browser-controller` — re-declaring WKNavigationDelegate conformance on the
;;;; freshly minted class pair — and wires the nav delegate.
;;;;
;;;; Invoked by build.sh:
;;;;   SDKROOT=macosx sbcl --non-interactive --disable-debugger \
;;;;     --load .../apps/mini-browser/dump.lisp -- <output-exe-path> <dylib-path>

(in-package #:cl-user)

(defparameter *app-dir*
  (make-pathname :name nil :type nil :defaults (or *load-truename* *load-pathname*)))

;; Post-`--` args: 1 = output exe path, 2 = dylib path to record for revive.
(defparameter *post-args* (rest (member "--" sb-ext:*posix-argv* :test #'string=)))
(defparameter *out-exe*
  (or (first *post-args*) (namestring (merge-pathnames "mini-browser" *app-dir*))))
(defparameter *dylib*
  (or (second *post-args*) "/tmp/libAPIAnywareSbcl.dylib"))

(load (merge-pathnames "../_support/load-bindings.lisp" *app-dir*))

(in-package #:apianyware-sbcl-impl)

(setf *native-dylib-path* cl-user::*dylib*)
(aw-load-native-dylib)

(aw-app-load-framework "Foundation" :load-residual nil)
(aw-app-load-framework "AppKit" :load-residual nil)
(aw-app-load-framework "WebKit" :load-residual nil)

(load (merge-pathnames "mini-browser.lisp" cl-user::*app-dir*))

(format t "~&== dumping ~A (dylib recorded: ~A) ==~%" cl-user::*out-exe* cl-user::*dylib*)
(finish-output)

(sb-ext:save-lisp-and-die cl-user::*out-exe*
  :executable t
  :save-runtime-options t          ; standalone GUI: do not parse argv as SBCL options
  :toplevel (lambda ()
              ;; Env AW_BROWSER_SMOKE makes the REVIVED image a construction smoke: it
              ;; re-synthesizes the controller (exercising the startup re-resolution pass —
              ;; frameworks, dispatcher, protocol conformance — in the dumped image) and
              ;; builds the window + wires the nav delegate, then exits 0 without the run
              ;; loop — a host revive smoke before the VM.
              (let ((smoke (sb-ext:posix-getenv "AW_BROWSER_SMOKE")))
                (handler-case (mini-browser-main :run (not smoke))
                  (error (e)
                    (format *error-output* "mini-browser fatal: ~A~%" e)
                    (finish-output *error-output*)
                    (sb-ext:exit :code 1)))
                (when smoke
                  (format t "### revived mini-browser construction OK~%")
                  (finish-output)))
              (sb-ext:exit :code 0)))
