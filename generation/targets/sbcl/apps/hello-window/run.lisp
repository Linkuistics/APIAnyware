;;;; run.lisp — dev host runner for hello-window (interpreted `sbcl --load`/`--script`).
;;;;
;;;; Loads the dev binding library (runtime + Foundation + AppKit, `:load-residual nil`
;;;; since the app is pure ObjC and needs no libAPIAnywareSbcl dylib), loads the app, and
;;;; runs it. Two modes:
;;;;   - default                : enter the AppKit run loop (an interactive dev run; needs
;;;;                              a WindowServer session — use the dumped .app for the VM);
;;;;   - env AW_HELLO_SMOKE set : the host construction PRE-FLIGHT — build the whole UI
;;;;                              (every FFI crossing) then return without blocking, so a
;;;;                              CLI load validates marshalling before the VM round-trip.
;;;;
;;;; Run the pre-flight from the repo root:
;;;;   SDKROOT=macosx AW_HELLO_SMOKE=1 sbcl --script \
;;;;     generation/targets/sbcl/apps/hello-window/run.lisp

(in-package #:cl-user)

(defparameter *app-dir*
  (make-pathname :name nil :type nil :defaults (or *load-truename* *load-pathname*))
  "Absolute directory of this app (apps/hello-window/).")

(load (merge-pathnames "../_support/load-bindings.lisp" *app-dir*))

(in-package #:apianyware-sbcl-impl)

(aw-app-load-framework "Foundation" :load-residual nil)
(aw-app-load-framework "AppKit" :load-residual nil)

(load (merge-pathnames "hello-window.lisp" cl-user::*app-dir*))

(let ((smoke (sb-ext:posix-getenv "AW_HELLO_SMOKE")))
  (hello-window-main :run (not smoke))
  (when smoke
    (format t "~&### hello-window construction pre-flight OK~%")
    (finish-output)))
