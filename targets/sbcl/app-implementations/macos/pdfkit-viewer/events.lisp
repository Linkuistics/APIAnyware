;;;; events.lisp — PDFKit Viewer structured event log (sbcl target).
;;;;
;;;; The k96 logging contract
;;;; (apps/macos/pdfkit-viewer/docs/logging-contract.md): the three hello-window
;;;; lifecycle events plus the two [document] state-transition events the spec §13
;;;; document assertions ride (the nav-button enabled flags are dropped by the
;;;; AX-snapshot transform, and the label's OCR can catch a pre-repaint frame):
;;;;   [lifecycle] startup                          — readiness probe (`wait-ready`)
;;;;   PDFKit Viewer opened. …                      — §3 step 7 launch diagnostic; BARE line
;;;;   [lifecycle] shutdown reason=<r>              — terminate; reason ∈ {menu,signal,error}
;;;;   [document] opened file="…" pages=N           — open-button success path, POST-state
;;;;   [document] page-changed page=n pages=N       — pageChanged: observer, POST-refresh
;;;;
;;;; `emit-launch-line` (not `emit-opened`, the gallery emitter's name): this app has a
;;;; real `[document] opened` event, so the launch diagnostic keeps its distinct name
;;;; (the racket k98 reference pattern).
;;;;
;;;; The runner tails this file (AppSpec/runner/log-tail.rkt) rather than reading stdout:
;;;; `launch-via 'open` discards an app's stdout via LaunchServices. Reference emitters:
;;;; the ui-controls-gallery events.lisp (this target's k92 worked template) and the
;;;; racket pdfkit-viewer events.rkt (the k98 reference pattern).
;;;;
;;;; PURE Common Lisp — no AppKit / PDFKit / dylib dependency — so it loads + unit-tests
;;;; in isolation (`sbcl --script` loads this file then calls the emitters; the only
;;;; non-ANSI surface is `sb-ext:posix-getenv`). pdfkit-viewer.lisp references it
;;;; through the `pv-events` nickname; run.lisp / dump.lisp load this file first.
;;;;
;;;; Single writer: the Cocoa run loop serialises the main-thread callbacks that emit —
;;;; startup/launch before `-run`, `opened` from the open-button action, `page-changed`
;;;; from the notification observer (the default center delivers on the posting thread,
;;;; and PDFKit posts on main), shutdown on the terminate path — so one stream with a
;;;; post-write `finish-output` suffices.

(defpackage #:apianyware-sbcl-pdfkit-viewer-events
  (:use #:cl)
  (:nicknames #:pv-events)
  (:export #:events-init! #:emit-startup #:emit-launch-line #:emit-shutdown
           #:emit-document-opened #:emit-page-changed
           #:close-events! #:events-log-path))

(in-package #:apianyware-sbcl-pdfkit-viewer-events)

;; Fixed default the descriptor's #:events-path mirrors, so the runner tails the same
;; file whether or not #:log-env (PDFKIT_VIEWER_EVENTS_LOG) propagates through
;; LaunchServices.
(defparameter *default-events-path* "/tmp/pdfkit-viewer/events.log")

(defvar *port* nil)
(defvar *path* nil)

;; PDFKIT_VIEWER_EVENTS_LOG if set and non-empty, else the fixed default.
(defun resolve-path ()
  (let ((env (sb-ext:posix-getenv "PDFKIT_VIEWER_EVENTS_LOG")))
    (if (and env (plusp (length env))) env *default-events-path*)))

(defun events-log-path () *path*)

;; Open + truncate the events.log the runner tails. :supersede truncates an existing file
;; and creates the parent dir (via ensure-directories-exist). The runner also truncates it
;; between scenarios (setup-scenario!), so the two truncates compose cleanly.
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

(defun emit-startup () (emit-line "[lifecycle] startup"))

;; The §3 step 7 launch diagnostic — the bare line beginning `PDFKit Viewer` the
;; runner's `wait-for-log` matches; dual-emitted (the stdout print stays in
;; pdfkit-viewer.lisp for unbundled runs).
(defun emit-launch-line ()
  (emit-line "PDFKit Viewer opened. Open a .pdf, navigate with ◀/▶. Quit with Cmd-Q."))

;; `~(~a~)` downcases REASON: CL's default *print-case* is :upcase, so a bare ~a on the
;; symbol 'menu would emit `reason=MENU` — but the contract mandates lowercase
;; `reason ∈ {menu, signal, error}`.
(defun emit-shutdown (reason)
  (emit-line (format nil "[lifecycle] shutdown reason=~(~a~)" reason)))

;;; The two [document] events — each emitted AFTER the state change it names is applied
;;; (label text + nav-button enabled states already set; contract "Document events").
;;; Callers pass the state `refresh-pdf-ui` returned, so the events mirror the §7.2
;;; label by construction.

;; `file` is the opened URL's LAST PATH COMPONENT (the panel canonicalizes paths, so the
;; basename is the stable identity the suite exact-matches); `pages` = pageCount.
(defun emit-document-opened (file pages)
  (emit-line (format nil "[document] opened file=~a pages=~d" (quote-string file) pages)))

;; `page` is 1-based and always equals the label's n (`Page n of N`); `pages` = N.
(defun emit-page-changed (page pages)
  (emit-line (format nil "[document] page-changed page=~d pages=~d" page pages)))

(defun close-events! ()
  (when *port*
    (handler-case (progn (finish-output *port*) (close *port*))
      ((or stream-error file-error) () nil))
    (setf *port* nil *path* nil)))
