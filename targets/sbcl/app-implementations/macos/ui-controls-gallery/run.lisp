;;;; run.lisp — dev host runner for ui-controls-gallery (interpreted `sbcl --load`).
;;;;
;;;; Loads the dev binding library (runtime + Foundation + AppKit, `:load-residual nil` —
;;;; every AppKit/Foundation call is pure ObjC, no trampoline residual). It DOES load
;;;; libAPIAnywareSbcl, but ONLY for the subclass bounce shim the AppSpec logging
;;;; contract's callbacks need (the terminate delegate + the four [controls]
;;;; target-actions; no block factory, no residual) — see ui-controls-gallery.lisp's
;;;; header. Loads events.lisp (the structured event log) before the app, then runs it.
;;;; Two modes:
;;;;   - default                  : enter the AppKit run loop (an interactive dev run;
;;;;                                needs a WindowServer session — use the dumped .app);
;;;;   - env AW_GALLERY_SMOKE set : the host construction PRE-FLIGHT — build every control
;;;;                                + the window + the controller wiring (every FFI
;;;;                                crossing) then return without blocking, so a CLI load
;;;;                                validates marshalling first.
;;;;
;;;; Run the pre-flight from the repo root:
;;;;   SDKROOT=macosx AW_GALLERY_SMOKE=1 sbcl --script \
;;;;     targets/sbcl/app-implementations/macos/ui-controls-gallery/run.lisp

(in-package #:cl-user)

(defparameter *app-dir*
  (make-pathname :name nil :type nil :defaults (or *load-truename* *load-pathname*))
  "Absolute directory of this app (apps/ui-controls-gallery/).")

(load (merge-pathnames "../_support/load-bindings.lisp" *app-dir*))

(in-package #:apianyware-sbcl-impl)

;; The dev dylib is the per-target adapter package's `swift build` output
;; (targets/sbcl/adapters/macos/.build/), resolved against the SBCL target root. Needed
;; for the `aw_sbcl_subclass_*` bounce shim the controller callbacks use; the subclass
;; dispatcher self-registers on the first `define-objc-method`.
(setf *native-dylib-path*
      (namestring (merge-pathnames "adapters/macos/.build/arm64-apple-macosx/debug/libAPIAnywareSbcl.dylib"
                                   cl-user::*aw-sbcl-root*)))
(aw-load-native-dylib)

(aw-app-load-framework "Foundation" :load-residual nil)
(aw-app-load-framework "AppKit" :load-residual nil)

(load (merge-pathnames "events.lisp" cl-user::*app-dir*))
(load (merge-pathnames "ui-controls-gallery.lisp" cl-user::*app-dir*))

(let ((smoke (sb-ext:posix-getenv "AW_GALLERY_SMOKE")))
  (ui-controls-gallery-main :run (not smoke))
  (when smoke
    (format t "~&### ui-controls-gallery construction pre-flight OK~%")
    (finish-output)))
