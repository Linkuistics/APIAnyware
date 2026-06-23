;;;; run.lisp — dev host runner for note-editor (interpreted `sbcl --load`).
;;;;
;;;; Like mini-browser/pdfkit-viewer this app LOADS libAPIAnywareSbcl — here for TWO
;;;; native facilities: the `aw_sbcl_subclass_*` bounce shim its `note-controller` needs
;;;; (target-actions + the NSTextDidChangeNotification observer), AND the
;;;; `aw_sbcl_make_block` block factory the Save completion handler needs (the FIRST sbcl
;;;; app to cross a block bridge). It is NOT for Swift-native trampoline residual — every
;;;; WebKit/AppKit/Foundation call is plain ObjC.
;;;;
;;;; Framework loads:
;;;;   - Foundation `:load-residual nil` — file I/O is Lisp-native; NSURL / NSUndoManager /
;;;;                NSNotificationCenter / NSMutableArray are pure-ObjC classes.
;;;;   - AppKit `:load-residual t`     — for the `NSTextDidChangeNotification` string
;;;;                constant (`ns:ns-text-did-change-notification`, from constants.lisp); the
;;;;                swift-native-probe path (re-resolved at startup in a dumped image).
;;;;   - WebKit `:load-residual nil`   — pure-ObjC WKWebView surface (as mini-browser).
;;;;
;;;; The block dispatcher has NO lazy self-init (unlike the subclass dispatcher, which
;;;; `aw-install-override` registers on the first `define-objc-method`), so this dev path
;;;; calls `aw-init-block-dispatcher` explicitly after `aw-load-native-dylib`. The dumped
;;;; image instead gets it via the `*init-hooks*` startup re-resolution pass.
;;;;
;;;; Two modes:
;;;;   - default                : enter the AppKit run loop (interactive dev run; needs a
;;;;                              WindowServer session — use the dumped .app for the VM);
;;;;   - env AW_NOTE_SMOKE set  : the host construction PRE-FLIGHT — synthesize the
;;;;                              controller, build the window + split view + controls, wire
;;;;                              target-action + the text-change observer, render the initial
;;;;                              preview, construct an `aw-block` (block-bridge liveness
;;;;                              gate), then return without the run loop — a CLI load that
;;;;                              validates marshalling + subclass + block machinery.
;;;;
;;;; Run the pre-flight from the repo root:
;;;;   SDKROOT=macosx AW_NOTE_SMOKE=1 sbcl --non-interactive --disable-debugger \
;;;;     --load generation/targets/sbcl/apps/note-editor/run.lisp

(in-package #:cl-user)

(defparameter *app-dir*
  (make-pathname :name nil :type nil :defaults (or *load-truename* *load-pathname*))
  "Absolute directory of this app (apps/note-editor/).")

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
(aw-init-block-dispatcher)               ; the block dispatcher has no lazy init

(aw-app-load-framework "Foundation" :load-residual nil)
(aw-app-load-framework "AppKit" :load-residual t)
(aw-app-load-framework "WebKit" :load-residual nil)

(load (merge-pathnames "note-editor.lisp" cl-user::*app-dir*))

(let ((smoke (sb-ext:posix-getenv "AW_NOTE_SMOKE")))
  (note-editor-main :run (not smoke))
  (when smoke
    (format t "~&### note-editor construction pre-flight OK~%")
    (finish-output)))
