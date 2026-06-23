;;;; run.lisp — dev host runner for swift-native-probe (interpreted `sbcl --load`).
;;;;
;;;; Unlike hello-window (pure ObjC, `:load-residual nil`), this app DEPENDS on
;;;; libAPIAnywareSbcl: it loads the dylib (`aw-load-native-dylib`) and the generated
;;;; Swift-native residual (`:load-residual t`) for Foundation + CoreGraphics + AppKit.
;;;; Two modes:
;;;;   - default                : enter the AppKit run loop (interactive dev run; needs a
;;;;                              WindowServer session — use the dumped .app for the VM);
;;;;   - env AW_PROBE_SMOKE set  : the host construction PRE-FLIGHT — call every Swift-native
;;;;                              trampoline + build the whole UI, then return without the
;;;;                              run loop, so a CLI load validates residual marshalling.
;;;;
;;;; Run the pre-flight from the repo root:
;;;;   SDKROOT=macosx AW_PROBE_SMOKE=1 sbcl --non-interactive --disable-debugger \
;;;;     --load generation/targets/sbcl/apps/swift-native-probe/run.lisp

(in-package #:cl-user)

(defparameter *app-dir*
  (make-pathname :name nil :type nil :defaults (or *load-truename* *load-pathname*))
  "Absolute directory of this app (apps/swift-native-probe/).")

(load (merge-pathnames "../_support/load-bindings.lisp" *app-dir*))

(in-package #:apianyware-sbcl-impl)

;; The dev dylib lives in the swift build output; the repo root is three dirs up from
;; the SBCL target root (generation/targets/sbcl/ -> generation/targets/ -> generation/ -> repo).
(defparameter *repo-root*
  (make-pathname :directory (butlast (pathname-directory cl-user::*aw-sbcl-root*) 3)
                 :host (pathname-host cl-user::*aw-sbcl-root*)
                 :device (pathname-device cl-user::*aw-sbcl-root*)))
(setf *native-dylib-path*
      (namestring (merge-pathnames "swift/.build/arm64-apple-macosx/debug/libAPIAnywareSbcl.dylib"
                                   *repo-root*)))
(aw-load-native-dylib)

(aw-app-load-framework "Foundation" :load-residual t)
(aw-app-load-framework "CoreGraphics" :load-residual t)
(aw-app-load-framework "AppKit" :load-residual t)

(load (merge-pathnames "swift-native-probe.lisp" cl-user::*app-dir*))

(let ((smoke (sb-ext:posix-getenv "AW_PROBE_SMOKE")))
  (swift-native-probe-main :run (not smoke))
  (when smoke
    (format t "~&### swift-native-probe construction pre-flight OK~%")
    (finish-output)))
