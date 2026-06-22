;;;; run.lisp — dev host runner for ui-controls-gallery (interpreted `sbcl --load`).
;;;;
;;;; Loads the dev binding library (runtime + Foundation + AppKit, `:load-residual nil`
;;;; since the app is pure ObjC and needs no libAPIAnywareSbcl dylib), loads the app, and
;;;; runs it. Two modes:
;;;;   - default                  : enter the AppKit run loop (an interactive dev run;
;;;;                                needs a WindowServer session — use the dumped .app);
;;;;   - env AW_GALLERY_SMOKE set : the host construction PRE-FLIGHT — build every control
;;;;                                + the window (every FFI crossing) then return without
;;;;                                blocking, so a CLI load validates marshalling first.
;;;;
;;;; Run the pre-flight from the repo root:
;;;;   SDKROOT=macosx AW_GALLERY_SMOKE=1 sbcl --script \
;;;;     generation/targets/sbcl/apps/ui-controls-gallery/run.lisp

(in-package #:cl-user)

(defparameter *app-dir*
  (make-pathname :name nil :type nil :defaults (or *load-truename* *load-pathname*))
  "Absolute directory of this app (apps/ui-controls-gallery/).")

(load (merge-pathnames "../_support/load-bindings.lisp" *app-dir*))

(in-package #:apianyware-sbcl-impl)

(aw-app-load-framework "Foundation" :load-residual nil)
(aw-app-load-framework "AppKit" :load-residual nil)

(load (merge-pathnames "ui-controls-gallery.lisp" cl-user::*app-dir*))

(let ((smoke (sb-ext:posix-getenv "AW_GALLERY_SMOKE")))
  (ui-controls-gallery-main :run (not smoke))
  (when smoke
    (format t "~&### ui-controls-gallery construction pre-flight OK~%")
    (finish-output)))
