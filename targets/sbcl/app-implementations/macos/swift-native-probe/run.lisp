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
;;;;     --load targets/sbcl/app-implementations/macos/swift-native-probe/run.lisp

(in-package #:cl-user)

(defparameter *app-dir*
  (make-pathname :name nil :type nil :defaults (or *load-truename* *load-pathname*))
  "Absolute directory of this app (apps/swift-native-probe/).")

(load (merge-pathnames "../_support/load-bindings.lisp" *app-dir*))

(in-package #:apianyware-sbcl-impl)

;; The dev dylib is the per-target adapter package's `swift build` output
;; (targets/sbcl/adapters/macos/.build/), resolved against the SBCL target root.
(setf *native-dylib-path*
      (namestring (merge-pathnames "adapters/macos/.build/arm64-apple-macosx/debug/libAPIAnywareSbcl.dylib"
                                   cl-user::*aw-sbcl-root*)))
(aw-load-native-dylib)

(aw-app-load-framework "Foundation" :load-residual t)
(aw-app-load-framework "CoreGraphics" :load-residual t)
(aw-app-load-framework "AppKit" :load-residual t)

;; events.lisp first (pure CL — the snp-events package swift-native-probe.lisp references).
(load (merge-pathnames "events.lisp" cl-user::*app-dir*))
(load (merge-pathnames "swift-native-probe.lisp" cl-user::*app-dir*))

(let ((smoke (sb-ext:posix-getenv "AW_PROBE_SMOKE")))
  (swift-native-probe-main :run (not smoke))
  (when smoke
    (format t "~&### swift-native-probe construction pre-flight OK~%")
    (finish-output)))
