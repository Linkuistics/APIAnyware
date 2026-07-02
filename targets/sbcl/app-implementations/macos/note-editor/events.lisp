;;;; events.lisp — Note Editor structured event log (sbcl target).
;;;;
;;;; The k123 logging contract
;;;; (apps/macos/note-editor/docs/logging-contract.md): the three hello-window
;;;; lifecycle events plus the six [document] document-state events and the one
;;;; [preview] render event the spec §15 assertions ride (the save sheet's completion
;;;; handler resolves on the sheet's schedule — save completion is not assertable
;;;; without a log record — the 11-pt status label is the app's only per-operation
;;;; message surface, and preview render completion is entirely unobservable):
;;;;   [lifecycle] startup                          — readiness probe (`wait-ready`)
;;;;   Note Editor opened. …                        — §3 step 8 launch diagnostic; BARE line
;;;;   [lifecycle] shutdown reason=<r>              — terminate; reason ∈ {menu,signal,error}
;;;;   [document] <event> path="…" dirty=<b>        — new/opened/saved/open-failed/
;;;;                                                  save-failed/dirty-changed, post-state
;;;;   [preview] rendered placeholder=<b> chars=<n> — after every loadHTMLString: hand-off
;;;;
;;;; The runner tails this file (AppSpec/runner/log-tail.rkt) rather than reading
;;;; stdout: `launch-via 'open` discards an app's stdout via LaunchServices. Reference
;;;; emitters: the mini-browser events.lisp (this target's k119 sibling) and the racket
;;;; note-editor events.rkt (the k125 reference pattern — one 6-event document emitter).
;;;;
;;;; Single writer: every event is emitted on the main thread — startup/the initial
;;;; render/launch before `-run`, the [document]/[preview] events from the five
;;;; target-actions, the text-change observer, and the save sheet's completion handler
;;;; (AppKit delivers all of these on main; the block bounce is a pass-through there —
;;;; ADR-0035/0036, no finalizer-thread emission), shutdown on the terminate path — so
;;;; one stream with a post-write `finish-output` suffices.
;;;;
;;;; PURE Common Lisp — no AppKit / WebKit / dylib dependency — so it loads +
;;;; unit-tests in isolation (`sbcl --script` loads this file then calls the emitters;
;;;; the only non-ANSI surface is `sb-ext:posix-getenv`). note-editor.lisp references
;;;; it through the `ne-events` nickname; run.lisp / dump.lisp load this file first.

(defpackage #:apianyware-sbcl-note-editor-events
  (:use #:cl)
  (:nicknames #:ne-events)
  (:export #:events-init! #:emit-startup #:emit-launch-line #:emit-shutdown
           #:emit-document #:emit-preview-rendered
           #:close-events! #:events-log-path))

(in-package #:apianyware-sbcl-note-editor-events)

;; Fixed default the descriptor's #:events-path mirrors, so the runner tails the same
;; file whether or not #:log-env (NOTE_EDITOR_EVENTS_LOG) propagates through
;; LaunchServices.
(defparameter *default-events-path* "/tmp/note-editor/events.log")

(defvar *port* nil)
(defvar *path* nil)

;; NOTE_EDITOR_EVENTS_LOG if set and non-empty, else the fixed default.
(defun resolve-path ()
  (let ((env (sb-ext:posix-getenv "NOTE_EDITOR_EVENTS_LOG")))
    (if (and env (plusp (length env))) env *default-events-path*)))

(defun events-log-path () *path*)

;; Open + truncate the events.log the runner tails. :supersede truncates an existing
;; file and creates the parent dir (via ensure-directories-exist). The runner also
;; truncates it between scenarios (setup-scenario!), so the two truncates compose
;; cleanly.
(defun events-init! ()
  (close-events!)
  (let ((target (resolve-path)))
    (ensure-directories-exist target)
    (setf *port* (open target :direction :output
                              :if-exists :supersede :if-does-not-exist :create
                              :external-format :utf-8)
          *path* target)
    target))

(defun emit-line (line)
  (when *port*
    ;; Swallow only I/O-level failures (out-of-disk, closed-stream races on shutdown).
    ;; A genuine programmer error still surfaces during dev.
    (handler-case
        (progn
          (write-string line *port*)
          (terpri *port*)
          (finish-output *port*))
      ((or stream-error file-error) () nil))))

;; Contract "Line format": strings are double-quoted with \\ / \" / newline
;; escaped; numbers/booleans/symbols emit bare.
(defun quote-string (s)
  (with-output-to-string (out)
    (write-char #\" out)
    (loop for ch across s
          do (case ch
               (#\\ (write-string "\\\\" out))
               (#\" (write-string "\\\"" out))
               (#\Newline (write-string "\\n" out))
               (t (write-char ch out))))
    (write-char #\" out)))

;; Booleans emit as the bare bytes `true` / `false` (contract "Line format") — never a
;; runtime print form like T/NIL.
(defun bool-word (b) (if b "true" "false"))

(defun emit-startup () (emit-line "[lifecycle] startup"))

;; The §3 step 8 launch diagnostic — the bare line beginning `Note Editor` the
;; runner's `wait-for-log` matches; dual-emitted (the stdout print stays in
;; note-editor.lisp for unbundled runs). The sbcl wording differs from
;; racket/chez/gerbil by design — the contract asserts the prefix only.
(defun emit-launch-line ()
  (emit-line "Note Editor opened. Type Markdown on the left; preview renders on the right. Quit with Cmd-Q."))

;; `~(~a~)` downcases REASON: CL's default *print-case* is :upcase, so a bare ~a on the
;; symbol 'menu would emit `reason=MENU` — but the contract mandates lowercase
;; `reason ∈ {menu, signal, error}`.
(defun emit-shutdown (reason)
  (emit-line (format nil "[lifecycle] shutdown reason=~(~a~)" reason)))

;;; The six [document] events — one emitter, the k125 reference shape (the event name
;;; is data; every event carries the same two keys in the contract's fixed order
;;; `path` then `dirty`). EVENT is the contract spelling as a string
;;; ("new" / "opened" / "saved" / "open-failed" / "save-failed" / "dirty-changed").
;;; PATH is a Lisp string or nil — nil folds to the contract's unset-path "" here, so
;;; call sites pass the slot through unfixed. DIRTY is a generalized boolean.
;;; State events carry the POST-STATE path+flag; failure events carry the ATTEMPTED
;;; path + the (unchanged) flag — that split is the caller's (rule-end vs
;;; failure-handler emission points), not this emitter's.
(defun emit-document (event path dirty)
  (emit-line (format nil "[document] ~a path=~a dirty=~a"
                     event (quote-string (or path "")) (bool-word dirty))))

;; The one [preview] event, at every §7 render immediately after the loadHTMLString:
;; hand-off (it witnesses the hand-off, not the pixels — render completion is
;; unobservable by design). Fixed key order `placeholder` then `chars`; CHARS is the
;; count of Unicode scalar values of the Markdown consumed (an SBCL string is a
;; code-point sequence, so the caller's `length` IS that count).
(defun emit-preview-rendered (placeholder chars)
  (emit-line (format nil "[preview] rendered placeholder=~a chars=~d"
                     (bool-word placeholder) chars)))

(defun close-events! ()
  (when *port*
    (handler-case (progn (finish-output *port*) (close *port*))
      ((or stream-error file-error) () nil))
    (setf *port* nil *path* nil)))
