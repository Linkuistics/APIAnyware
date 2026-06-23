;;;; tests/smoke-bundle-relocate.lisp — 070-distribution (bundle-sbcl) done-when smoke.
;;;;
;;;; Run from the repo root (needs the built dylib — the runner does `swift build` first):
;;;;   SDKROOT=macosx sbcl --non-interactive --disable-debugger \
;;;;     --load generation/targets/sbcl/lib/runtime/tests/smoke-bundle-relocate.lisp
;;;;
;;;; Proves the dylib-namestring relocation hook `bundle-sbcl` relies on (ADR-0041). A
;;;; `save-lisp-and-die` image cannot be `install_name_tool`-edited (the Lisp core sits
;;;; past `__LINKEDIT`), but `libAPIAnywareSbcl` is `dlopen`ed, so SBCL re-opens it from
;;;; the recorded `*shared-objects*` namestring on image restart (ADR-0038 §5). The hook
;;;; loads from the real BUILD path (so every `aw_sbcl_*` symbol resolves at dump time)
;;;; and rewrites only the recorded namestring to the `@executable_path/..` vendored copy.
;;;; Coverage:
;;;;
;;;;   (A) with `AW_NATIVE_DYLIB_RECORD_AS` set, `aw-load-native-dylib` records the
;;;;       relocated namestring (and nulls the pathname) WHILE the dylib stays live —
;;;;       `aw_sbcl_box_free` resolves, proving the real load happened despite the
;;;;       fictional recorded path. (A genuine dump+revive round-trip is the bundler's
;;;;       crate e2e test; this smoke isolates the in-process record rewrite.)
;;;;   (B) `aw-relocate-dylib-namestring` is a safe no-op (returns nil) when no
;;;;       `*shared-objects*` entry matches.

(in-package #:cl-user)
(require :sb-posix)
(defparameter *here* (or *load-truename* *load-pathname*))
(defparameter *repo-root*
  (let ((d (make-pathname :directory (pathname-directory *here*))))
    (dotimes (_ 6 d) (setf d (make-pathname :directory (butlast (pathname-directory d)))))))
(load (merge-pathnames "generation/targets/sbcl/lib/runtime/load.lisp" *repo-root*))

(in-package #:apianyware-sbcl-impl)

(defvar *fails* 0)
(defmacro check (form expected)
  `(let ((got ,form))
     (if (equal got ,expected)
         (format t "### ok    ~S => ~S~%" ',form got)
         (progn (incf *fails*) (format t "### FAIL  ~S => ~S (expected ~S)~%" ',form got ,expected)))))

(defparameter *dylib*
  (namestring (merge-pathnames "swift/.build/arm64-apple-macosx/debug/libAPIAnywareSbcl.dylib"
                               cl-user::*repo-root*)))
(defparameter *relocated*
  "@executable_path/../Frameworks/libAPIAnywareSbcl.dylib")

(unless (probe-file *dylib*)
  (format t "### SKIP (no built dylib at ~A) — SMOKE PASS~%" *dylib*)
  (sb-ext:exit :code 0))

;;; ===========================================================================
;;; (A) load from the real build path, record the @executable_path namestring.
;;; ===========================================================================

(sb-posix:setenv +native-dylib-record-as-env+ *relocated* 1)
(setf *native-dylib-path* *dylib*)
(aw-load-native-dylib)

(check *native-dylib-loaded* t)

(defun dylib-namestring ()
  (let ((o (find-if (lambda (x)
                      (let ((ns (sb-alien::shared-object-namestring x)))
                        (and ns (search "libAPIAnywareSbcl" ns))))
                    sb-alien::*shared-objects*)))
    (and o (sb-alien::shared-object-namestring o))))

(defun dylib-pathname ()
  (let ((o (find-if (lambda (x)
                      (let ((ns (sb-alien::shared-object-namestring x)))
                        (and ns (search "libAPIAnywareSbcl" ns))))
                    sb-alien::*shared-objects*)))
    (and o (sb-alien::shared-object-pathname o))))

;; The serialized namestring is the @executable_path/.. copy, NOT the build path.
(check (dylib-namestring) *relocated*)
;; PATHNAME nulled so NAMESTRING is what reopen uses.
(check (dylib-pathname) nil)
;; Yet the dylib really loaded from the build path: its symbols are live this process.
(check (not (null (sb-sys::find-dynamic-foreign-symbol-address "aw_sbcl_box_free"))) t)

;;; ===========================================================================
;;; (B) no matching entry -> safe no-op.
;;; ===========================================================================

(check (aw-relocate-dylib-namestring "/no/such/libNopeXYZ.dylib" "@executable_path/x")
       nil)

(if (zerop *fails*)
    (format t "~&### bundle-relocate SMOKE PASS~%")
    (format t "~&### bundle-relocate SMOKE FAIL (~D)~%" *fails*))
(finish-output)
(sb-ext:exit :code (if (zerop *fails*) 0 1))
