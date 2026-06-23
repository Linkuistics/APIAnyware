;;;; dump.lisp — `save-lisp-and-die` the note-editor standalone executable (060).
;;;;
;;;; Like mini-browser/pdfkit-viewer this dumps WITH libAPIAnywareSbcl (ADR-0038 §5: the
;;;; dylib is NOT embedded — `save-lisp-and-die` keeps it in `*shared-objects*`, so the
;;;; revived image auto-reopens it by the path it was loaded from). We load it from a FIXED
;;;; path — `/tmp/libAPIAnywareSbcl.dylib` (build.sh stages the copy) — so the VM needs only
;;;; that one dylib at that path. Here the dylib is needed for BOTH the SUBCLASS bounce shim
;;;; (the `note-controller`: target-actions + the NSTextDidChangeNotification observer) AND
;;;; the `aw_sbcl_make_block` block factory (the Save completion handler).
;;;;
;;;; Framework loads mirror run.lisp: Foundation `:load-residual nil`, AppKit
;;;; `:load-residual t` (for the `NSTextDidChangeNotification` constant), WebKit
;;;; `:load-residual nil`.
;;;;
;;;; At revive, `sb-ext:*init-hooks*` runs the mandatory startup re-resolution pass BEFORE
;;;; the toplevel: re-dlopen frameworks, re-resolve objc_msgSend, re-mask FP traps,
;;;; re-register the subclass forwarding dispatcher AND the block dispatcher with the
;;;; reopened dylib, and re-resolve the AppKit constant surface (so the baked
;;;; `NSTextDidChangeNotification` pointer is re-derived). `-main` then re-synthesizes the
;;;; controller via `ensure-note-controller`.
;;;;
;;;; Invoked by build.sh:
;;;;   SDKROOT=macosx sbcl --non-interactive --disable-debugger \
;;;;     --load .../apps/note-editor/dump.lisp -- <output-exe-path> <dylib-path>

(in-package #:cl-user)

(defparameter *app-dir*
  (make-pathname :name nil :type nil :defaults (or *load-truename* *load-pathname*)))

;; Post-`--` args: 1 = output exe path, 2 = dylib path to record for revive.
(defparameter *post-args* (rest (member "--" sb-ext:*posix-argv* :test #'string=)))
(defparameter *out-exe*
  (or (first *post-args*) (namestring (merge-pathnames "note-editor" *app-dir*))))
(defparameter *dylib*
  (or (second *post-args*) "/tmp/libAPIAnywareSbcl.dylib"))

(load (merge-pathnames "../_support/load-bindings.lisp" *app-dir*))

(in-package #:apianyware-sbcl-impl)

(setf *native-dylib-path* cl-user::*dylib*)
(aw-load-native-dylib)
(aw-init-block-dispatcher)               ; the revive startup hook also re-registers

(aw-app-load-framework "Foundation" :load-residual nil)
(aw-app-load-framework "AppKit" :load-residual t)
(aw-app-load-framework "WebKit" :load-residual nil)

(load (merge-pathnames "note-editor.lisp" cl-user::*app-dir*))

(format t "~&== dumping ~A (dylib recorded: ~A) ==~%" cl-user::*out-exe* cl-user::*dylib*)
(finish-output)

(sb-ext:save-lisp-and-die cl-user::*out-exe*
  :executable t
  :save-runtime-options t          ; standalone GUI: do not parse argv as SBCL options
  :toplevel (lambda ()
              ;; Env AW_NOTE_SMOKE makes the REVIVED image a construction smoke: it
              ;; re-synthesizes the controller (exercising the startup re-resolution pass —
              ;; frameworks, dispatcher, block dispatcher, constant surface — in the dumped
              ;; image), builds the window + wires everything + renders the initial preview
              ;; + constructs an `aw-block`, then exits 0 without the run loop — a host
              ;; revive smoke before the VM.
              (let ((smoke (sb-ext:posix-getenv "AW_NOTE_SMOKE")))
                (handler-case (note-editor-main :run (not smoke))
                  (error (e)
                    (format *error-output* "note-editor fatal: ~A~%" e)
                    (finish-output *error-output*)
                    (sb-ext:exit :code 1)))
                (when smoke
                  (format t "### revived note-editor construction OK~%")
                  (finish-output)))
              (sb-ext:exit :code 0)))
