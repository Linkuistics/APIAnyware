;;;; dump.lisp — `save-lisp-and-die` the hello-window standalone executable (060/020).
;;;;
;;;; Produces a self-contained executable embedding the SBCL runtime, the loaded binding
;;;; library (runtime + Foundation + AppKit, `:load-residual nil` — pure-ObjC calls, no
;;;; trampoline residual), and the app. The AppSpec logging contract's
;;;; `applicationWillTerminate:` delegate needs libAPIAnywareSbcl's subclass bounce shim, so
;;;; the dump loads the dylib (arg 2) — like note-editor. ADR-0038 §5: the dylib is NOT
;;;; embedded — `save-lisp-and-die` keeps it in `*shared-objects*` and the revived image
;;;; auto-reopens it by the recorded namestring. The bundler (`bundle-sbcl`, ADR-0041) drives
;;;; this file with `AW_NATIVE_DYLIB_RECORD_AS=@executable_path/../Frameworks/...` set, so
;;;; the recorded namestring points at the VENDORED copy inside the .app and the bundle
;;;; travels alone (sbcl-vendor-libzstd-k75 retired the /tmp staging).
;;;; At revive, `sb-ext:*init-hooks*` runs the mandatory startup re-resolution pass (ADR-0034
;;;; §6 / ADR-0038 §5) BEFORE the toplevel — re-`dlopen`ing Foundation+AppKit + the dylib,
;;;; re-resolving `objc_msgSend`, re-masking the FP traps, re-registering the subclass
;;;; forwarding dispatcher — so every baked Class/SEL is live and the delegate works before the
;;;; first dispatch. `-main` then re-synthesizes the delegate class via `ensure-hw-delegate`.
;;;;
;;;; Invoked by the bundler (via build.sh step [2/3]):
;;;;   [AW_NATIVE_DYLIB_RECORD_AS=@executable_path/../Frameworks/libAPIAnywareSbcl.dylib]
;;;;   SDKROOT=… sbcl --non-interactive --disable-debugger \
;;;;     --load .../hello-window/dump.lisp -- <output-exe-path> <dylib-path>

(in-package #:cl-user)

(defparameter *app-dir*
  (make-pathname :name nil :type nil :defaults (or *load-truename* *load-pathname*)))

;; Post-`--` args: 1 = output exe path, 2 = dylib path to load at dump time (the bundler
;; passes its discovered build path; a bare manual invocation falls back to /tmp).
(defparameter *post-args* (rest (member "--" sb-ext:*posix-argv* :test #'string=)))
(defparameter *out-exe*
  (or (first *post-args*) (namestring (merge-pathnames "hello-window" *app-dir*))))
(defparameter *dylib*
  (or (second *post-args*) "/tmp/libAPIAnywareSbcl.dylib"))

(load (merge-pathnames "../_support/load-bindings.lisp" *app-dir*))

(in-package #:apianyware-sbcl-impl)

;; Load the dylib from the path we record for revive (ADR-0038 §5 auto-reopen). Needed for
;; the subclass bounce shim the terminate delegate uses; the subclass dispatcher
;; self-registers on the first `define-objc-method` (no block-dispatcher init).
(setf *native-dylib-path* cl-user::*dylib*)
(aw-load-native-dylib)

(aw-app-load-framework "Foundation" :load-residual nil)
(aw-app-load-framework "AppKit" :load-residual nil)

(load (merge-pathnames "events.lisp" cl-user::*app-dir*))
(load (merge-pathnames "hello-window.lisp" cl-user::*app-dir*))

(format t "~&== dumping ~A (dylib recorded: ~A) ==~%" cl-user::*out-exe* cl-user::*dylib*)
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
