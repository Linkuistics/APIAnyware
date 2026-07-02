;;;; run.lisp — dev host runner for mini-browser (interpreted `sbcl --load`).
;;;;
;;;; Like scenekit-viewer/pdfkit-viewer this app LOADS libAPIAnywareSbcl for the
;;;; `aw_sbcl_subclass_*` bounce shim its custom delegate (`browser-controller`) needs —
;;;; NOT the Swift-native trampoline residual (every WebKit/AppKit/Foundation call here is
;;;; plain ObjC). Every framework loads `:load-residual nil`: the app uses no framework
;;;; constants or free functions, and WebKit is pure ObjC for the WKWebView surface
;;;; (WKNavigationDelegate conformance reads its ABI LIVE off the protocol via libobjc,
;;;; not from any emitted residual). WebKit's protocol metadata is registered by the
;;;; framework dlopen, so `(:protocols "WKNavigationDelegate")` resolves without
;;;; protocols.lisp.
;;;;
;;;; Two modes:
;;;;   - default                 : enter the AppKit run loop (interactive dev run; needs a
;;;;                               WindowServer session — use the dumped .app for the VM);
;;;;   - env AW_BROWSER_SMOKE set : the host construction PRE-FLIGHT — synthesize the
;;;;                               controller (incl. WKNavigationDelegate conformance),
;;;;                               build the window + controls, wire target-action + the
;;;;                               nav delegate, kick the initial load, then return without
;;;;                               the run loop, so a CLI load validates marshalling + the
;;;;                               subclass + the protocol-conformance machinery.
;;;;
;;;; Run the pre-flight from the repo root:
;;;;   SDKROOT=macosx AW_BROWSER_SMOKE=1 sbcl --non-interactive --disable-debugger \
;;;;     --load targets/sbcl/app-implementations/macos/mini-browser/run.lisp

(in-package #:cl-user)

(defparameter *app-dir*
  (make-pathname :name nil :type nil :defaults (or *load-truename* *load-pathname*))
  "Absolute directory of this app (apps/mini-browser/).")

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
(aw-app-load-framework "WebKit" :load-residual nil)

;; events.lisp first (pure CL — the mb-events package mini-browser.lisp references).
(load (merge-pathnames "events.lisp" cl-user::*app-dir*))
(load (merge-pathnames "mini-browser.lisp" cl-user::*app-dir*))

(let ((smoke (sb-ext:posix-getenv "AW_BROWSER_SMOKE")))
  (mini-browser-main :run (not smoke))
  (when smoke
    (format t "~&### mini-browser construction pre-flight OK~%")
    (finish-output)))
