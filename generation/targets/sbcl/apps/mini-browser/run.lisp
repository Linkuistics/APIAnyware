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
;;;;     --load generation/targets/sbcl/apps/mini-browser/run.lisp

(in-package #:cl-user)

(defparameter *app-dir*
  (make-pathname :name nil :type nil :defaults (or *load-truename* *load-pathname*))
  "Absolute directory of this app (apps/mini-browser/).")

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

(aw-app-load-framework "Foundation" :load-residual nil)
(aw-app-load-framework "AppKit" :load-residual nil)
(aw-app-load-framework "WebKit" :load-residual nil)

(load (merge-pathnames "mini-browser.lisp" cl-user::*app-dir*))

(let ((smoke (sb-ext:posix-getenv "AW_BROWSER_SMOKE")))
  (mini-browser-main :run (not smoke))
  (when smoke
    (format t "~&### mini-browser construction pre-flight OK~%")
    (finish-output)))
