;;;; dump.lisp — `save-lisp-and-die` the hello-window standalone executable (060/020).
;;;;
;;;; Produces a self-contained executable embedding the SBCL runtime, the loaded binding
;;;; library (runtime + Foundation + AppKit, `:load-residual nil` — pure-ObjC calls, no
;;;; trampoline residual), and the app. It is NOT fully standalone: the AppSpec logging
;;;; contract's `applicationWillTerminate:` delegate needs libAPIAnywareSbcl's subclass bounce
;;;; shim, so — like note-editor — the dump loads the dylib from a FIXED path
;;;; (`/tmp/libAPIAnywareSbcl.dylib`, build.sh stages the copy). ADR-0038 §5: the dylib is NOT
;;;; embedded — `save-lisp-and-die` keeps it in `*shared-objects*` and the revived image
;;;; auto-reopens it by that recorded path, so the VM needs only that one dylib at that path.
;;;; At revive, `sb-ext:*init-hooks*` runs the mandatory startup re-resolution pass (ADR-0034
;;;; §6 / ADR-0038 §5) BEFORE the toplevel — re-`dlopen`ing Foundation+AppKit + the dylib,
;;;; re-resolving `objc_msgSend`, re-masking the FP traps, re-registering the subclass
;;;; forwarding dispatcher — so every baked Class/SEL is live and the delegate works before the
;;;; first dispatch. `-main` then re-synthesizes the delegate class via `ensure-hw-delegate`.
;;;; This is a dev build script; the `bundle-sbcl` crate (070-distribution) generalizes it.
;;;;
;;;; Invoked by build.sh:
;;;;   SDKROOT=macosx sbcl --non-interactive --disable-debugger \
;;;;     --load .../apps/hello-window/dump.lisp -- <output-exe-path> <dylib-path>

(in-package #:cl-user)

(defparameter *app-dir*
  (make-pathname :name nil :type nil :defaults (or *load-truename* *load-pathname*)))

;; Post-`--` args: 1 = output exe path, 2 = dylib path to record for revive (build.sh
;; passes both; the dylib path defaults to the fixed /tmp stage if omitted).
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
