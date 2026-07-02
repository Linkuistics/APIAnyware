;;;; run.lisp — dev host runner for pdfkit-viewer (interpreted `sbcl --load`).
;;;;
;;;; Like scenekit-viewer this app LOADS libAPIAnywareSbcl for the `aw_sbcl_subclass_*`
;;;; bounce shim its custom delegate (`pdf-controller`) needs — NOT the Swift-native
;;;; trampoline residual (every PDFKit/AppKit call here is plain ObjC). Framework load
;;;; residual policy differs per framework, though:
;;;;   - Foundation / AppKit : `:load-residual nil` (no constants/functions needed);
;;;;   - PDFKit              : `:load-residual t`  — the app needs the
;;;;                           `PDFViewPageChangedNotification` constant from its
;;;;                           `constants.lisp` (the first ladder app to need a framework
;;;;                           string constant; re-resolved at startup in a dumped image).
;;;; Two modes:
;;;;   - default                : enter the AppKit run loop (interactive dev run; needs a
;;;;                              WindowServer session — use the dumped .app for the VM);
;;;;   - env AW_PDFKIT_SMOKE set : the host construction PRE-FLIGHT — synthesize the
;;;;                              delegate, build the window + controls, wire target-action,
;;;;                              register the observer, then return without the run loop,
;;;;                              so a CLI load validates marshalling + the subclass + the
;;;;                              constant-surface machinery.
;;;;
;;;; Run the pre-flight from the repo root:
;;;;   SDKROOT=macosx AW_PDFKIT_SMOKE=1 sbcl --non-interactive --disable-debugger \
;;;;     --load targets/sbcl/app-implementations/macos/pdfkit-viewer/run.lisp

(in-package #:cl-user)

(defparameter *app-dir*
  (make-pathname :name nil :type nil :defaults (or *load-truename* *load-pathname*))
  "Absolute directory of this app (apps/pdfkit-viewer/).")

(load (merge-pathnames "../_support/load-bindings.lisp" *app-dir*))

(in-package #:apianyware-sbcl-impl)

;; The dev dylib is the per-target adapter package's `swift build` output
;; (targets/sbcl/adapters/macos/.build/), resolved against the SBCL target root.
(setf *native-dylib-path*
      (namestring (merge-pathnames "adapters/macos/.build/arm64-apple-macosx/debug/libAPIAnywareSbcl.dylib"
                                   cl-user::*aw-sbcl-root*)))
(aw-load-native-dylib)

(aw-app-load-framework "Foundation" :load-residual nil)
(aw-app-load-framework "AppKit" :load-residual nil)
(aw-app-load-framework "PDFKit" :load-residual t)

;; events.lisp first (pure CL — the pv-events package pdfkit-viewer.lisp references).
(load (merge-pathnames "events.lisp" cl-user::*app-dir*))
(load (merge-pathnames "pdfkit-viewer.lisp" cl-user::*app-dir*))

(let ((smoke (sb-ext:posix-getenv "AW_PDFKIT_SMOKE")))
  (pdfkit-viewer-main :run (not smoke))
  (when smoke
    (format t "~&### pdfkit-viewer construction pre-flight OK~%")
    (finish-output)))
