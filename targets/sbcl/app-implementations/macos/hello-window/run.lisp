;;;; run.lisp — dev host runner for hello-window (interpreted `sbcl --load`/`--script`).
;;;;
;;;; Loads the dev binding library (runtime + Foundation + AppKit, `:load-residual nil` —
;;;; every AppKit/Foundation call is pure ObjC, no trampoline residual). It DOES load
;;;; libAPIAnywareSbcl, but ONLY for the subclass bounce shim the AppSpec logging contract's
;;;; `applicationWillTerminate:` delegate needs (no block factory, no residual) — see
;;;; hello-window.lisp's header. Loads events.lisp (the structured event log) before the app,
;;;; then runs it. Two modes:
;;;;   - default                : enter the AppKit run loop (an interactive dev run; needs
;;;;                              a WindowServer session — use the dumped .app for the VM);
;;;;   - env AW_HELLO_SMOKE set : the host construction PRE-FLIGHT — build the whole UI
;;;;                              (every FFI crossing) then return without blocking, so a
;;;;                              CLI load validates marshalling before the VM round-trip.
;;;;
;;;; Run the pre-flight from the repo root:
;;;;   SDKROOT=macosx AW_HELLO_SMOKE=1 sbcl --script \
;;;;     targets/sbcl/app-implementations/macos/hello-window/run.lisp

(in-package #:cl-user)

(defparameter *app-dir*
  (make-pathname :name nil :type nil :defaults (or *load-truename* *load-pathname*))
  "Absolute directory of this app (apps/hello-window/).")

(load (merge-pathnames "../_support/load-bindings.lisp" *app-dir*))

(in-package #:apianyware-sbcl-impl)

;; The dev dylib is the per-target adapter package's `swift build` output
;; (targets/sbcl/adapters/macos/.build/), resolved against the SBCL target root. Needed for
;; the `aw_sbcl_subclass_*` bounce shim the terminate delegate uses; the subclass dispatcher
;; self-registers on the first `define-objc-method` (no explicit block-dispatcher init).
(setf *native-dylib-path*
      (namestring (merge-pathnames "adapters/macos/.build/arm64-apple-macosx/debug/libAPIAnywareSbcl.dylib"
                                   cl-user::*aw-sbcl-root*)))
(aw-load-native-dylib)

(aw-app-load-framework "Foundation" :load-residual nil)
(aw-app-load-framework "AppKit" :load-residual nil)

(load (merge-pathnames "events.lisp" cl-user::*app-dir*))
(load (merge-pathnames "hello-window.lisp" cl-user::*app-dir*))

(let ((smoke (sb-ext:posix-getenv "AW_HELLO_SMOKE")))
  (hello-window-main :run (not smoke))
  (when smoke
    (format t "~&### hello-window construction pre-flight OK~%")
    (finish-output)))
