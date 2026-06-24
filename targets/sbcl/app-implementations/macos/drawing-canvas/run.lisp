;;;; run.lisp — dev host runner for drawing-canvas (interpreted `sbcl --load`).
;;;;
;;;; Like mini-browser/note-editor this app LOADS libAPIAnywareSbcl — here for ONE native
;;;; facility: the `aw_sbcl_subclass_*` bounce shim its TWO subclasses need (`canvas-view`,
;;;; an NSView override driving drawRect:/mouse events; `canvas-controller`, the toolbar
;;;; target-actions). NO block bridge (no completion handlers), so — unlike note-editor —
;;;; there is no `aw-init-block-dispatcher`; the subclass dispatcher self-registers lazily on
;;;; the first `define-objc-method` (via `aw-install-override`). It is NOT for Swift-native
;;;; trampoline residual — every AppKit/Foundation call is plain ObjC, and the CoreGraphics
;;;; calls are direct `ns:cg-*` C aliens.
;;;;
;;;; Framework loads:
;;;;   - Foundation `:load-residual nil`   — pure-ObjC (NSMenu/NSColorSpace/…); no residual.
;;;;   - AppKit `:load-residual nil`       — every enum we use (NSWindowStyleMask*, NSBezelStyle*,
;;;;                NSView*Sizable, NSApplicationActivationPolicy*, NSBackingStore*) is in the
;;;;                ALWAYS-loaded enums.lisp; no AppKit constant/function residual is named.
;;;;   - CoreGraphics `:load-residual t`   — the `ns:cg-*` stroke FUNCTIONS live in
;;;;                coregraphics/functions.lisp, which the loader only loads with residual t.
;;;;                (The first ladder app needing the residual flag for FUNCTIONS, not constants.)
;;;;
;;;; Two modes:
;;;;   - default                  : enter the AppKit run loop (interactive dev run; needs a
;;;;                                WindowServer session — use the dumped .app for the VM);
;;;;   - env AW_CANVAS_SMOKE set  : the host construction PRE-FLIGHT — synthesize BOTH
;;;;                                subclasses, build the window + canvas + toolbar, wire
;;;;                                target-action, assert the NSView subclass instance is live +
;;;;                                back-referenced, then return without the run loop — a CLI
;;;;                                load that validates marshalling + (NSView!) subclass synthesis
;;;;                                + the CoreGraphics framework load.
;;;;
;;;; Run the pre-flight from the repo root:
;;;;   SDKROOT=macosx AW_CANVAS_SMOKE=1 sbcl --non-interactive --disable-debugger \
;;;;     --load targets/sbcl/app-implementations/macos/drawing-canvas/run.lisp

(in-package #:cl-user)

(defparameter *app-dir*
  (make-pathname :name nil :type nil :defaults (or *load-truename* *load-pathname*))
  "Absolute directory of this app (apps/drawing-canvas/).")

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
(aw-app-load-framework "CoreGraphics" :load-residual t)

(load (merge-pathnames "drawing-canvas.lisp" cl-user::*app-dir*))

(let ((smoke (sb-ext:posix-getenv "AW_CANVAS_SMOKE")))
  (drawing-canvas-main :run (not smoke))
  (when smoke
    (format t "~&### drawing-canvas construction pre-flight OK~%")
    (finish-output)))
