;;;; events.lisp — Hello Window structured event log (sbcl target).
;;;;
;;;; The de-Modalisered v1 logging contract
;;;; (apps/macos/hello-window/docs/logging-contract.md), narrowed to the three events
;;;; Hello Window's scenario suite consumes:
;;;;   [lifecycle] startup             — readiness probe (runner `wait-ready`)
;;;;   Hello Window opened.            — §10 launch diagnostic; BARE line; scenario 01
;;;;   [lifecycle] shutdown reason=<r> — terminate; scenario 03 / `quit-impl!`
;;;;
;;;; The runner tails this file (AppSpec/runner/log-tail.rkt) rather than reading stdout:
;;;; `launch-via 'open` discards an app's stdout via LaunchServices. Reference emitter:
;;;; the v1 Modaliser lib/events.rkt; sibling impls' racket events.rkt / chez inline.
;;;;
;;;; PURE Common Lisp — no AppKit / Foundation / dylib dependency — so it loads + unit-tests
;;;; in isolation (`sbcl --script events.lisp` then call the emitters; the only non-ANSI
;;;; surface is `sb-ext:posix-getenv`, present in any SBCL). hello-window.lisp references it
;;;; through the `hw-events` nickname; run.lisp / dump.lisp load this file first.
;;;;
;;;; Single writer: the Cocoa run loop serialises the main-thread callbacks that emit, so
;;;; one stream with a post-write `finish-output` suffices (no lock needed for this app).

(defpackage #:apianyware-sbcl-hello-window-events
  (:use #:cl)
  (:nicknames #:hw-events)
  (:export #:events-init! #:emit-startup #:emit-opened #:emit-shutdown
           #:close-events! #:events-log-path))

(in-package #:apianyware-sbcl-hello-window-events)

;; Fixed default the descriptor's #:events-path mirrors, so the runner tails the same file
;; whether or not #:log-env (HELLO_WINDOW_EVENTS_LOG) propagates through LaunchServices.
(defparameter *default-events-path* "/tmp/hello-window/events.log")

(defvar *port* nil)
(defvar *path* nil)

;; HELLO_WINDOW_EVENTS_LOG if set and non-empty, else the fixed default.
(defun resolve-path ()
  (let ((env (sb-ext:posix-getenv "HELLO_WINDOW_EVENTS_LOG")))
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

(defun emit-startup ()        (emit-line "[lifecycle] startup"))
(defun emit-opened ()         (emit-line "Hello Window opened."))
;; `~(~a~)` downcases REASON: CL's default *print-case* is :upcase, so a bare ~a on the
;; symbol 'menu would emit `reason=MENU` — but the contract (and the racket/chez siblings,
;; whose symbols print lowercase) mandate lowercase `reason ∈ {menu, signal, error}`.
(defun emit-shutdown (reason) (emit-line (format nil "[lifecycle] shutdown reason=~(~a~)" reason)))

(defun close-events! ()
  (when *port*
    (handler-case (progn (finish-output *port*) (close *port*))
      ((or stream-error file-error) () nil))
    (setf *port* nil *path* nil)))
