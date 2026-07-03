;;;; events.lisp — Drawing Canvas structured event log (sbcl target).
;;;;
;;;; The k132 logging contract
;;;; (apps/macos/drawing-canvas/docs/logging-contract.md): the three hello-window
;;;; lifecycle events plus the five [canvas] state transitions the spec §14
;;;; assertions ride (the canvas is a custom NSView whose strokes are framebuffer
;;;; pixels — OCR-meaningless and AX-invisible, spec §12 — so without log events
;;;; stroke lifecycle and tool state are not assertable at all; the scenekit
;;;; [scene] channel mirror):
;;;;   [lifecycle] startup                      — readiness probe (`wait-ready`)
;;;;   Drawing Canvas opened. …                 — §3 step 6 launch diagnostic; BARE line
;;;;   [lifecycle] shutdown reason=<r>          — terminate; reason ∈ {menu,signal,error}
;;;;   [canvas] stroke-begun r= g= b= width=    — end of the §7.2 mouse-down rule; the
;;;;                                              stroke's FROZEN colour+width
;;;;   [canvas] stroke-committed r= g= b= width= points=
;;;;                                            — end of the §7.2 mouse-up rule; same
;;;;                                              frozen tuple + stored point count
;;;;   [canvas] color-changed r= g= b=          — panel handler success path, post-store
;;;;   [canvas] width-changed width=            — slider action, post-store
;;;;   [canvas] cleared count=<n>               — end of every Clear; 0 on empty
;;;;
;;;; The runner tails this file (AppSpec/runner/log-tail.rkt) rather than reading
;;;; stdout: `launch-via 'open` discards an app's stdout via LaunchServices.
;;;; Reference emitters: the note-editor events.lisp (this target's k128 sibling)
;;;; and the racket drawing-canvas events.rkt (the k134 reference pattern). No
;;;; event in this app carries a string value, so the quote-string helper is
;;;; omitted — every value is a bare integer or symbol per the contract's line
;;;; format.
;;;;
;;;; Single writer: every event is emitted on the main thread — startup and the
;;;; launch line before `-run`; the [canvas] events from the canvas subclass's
;;;; mouse overrides (AppKit event dispatch), the slider and Clear action
;;;; handlers, and the colour panel's continuous colorChanged: action (the shared
;;;; NSColorPanel is in-process; the Cocoa run loop serialises its sends; the
;;;; subclass bounce is a main-thread pass-through there — ADR-0035/0036) —
;;;; shutdown on the terminate path — so one stream with a post-write
;;;; `finish-output` suffices.
;;;;
;;;; Integer formatting (contract "Canvas events"): r/g/b are the stored
;;;; device-RGB components × 255, width the stored width, each rounded to the
;;;; nearest integer at emit from the stored doubles — rounded ONCE, here, so
;;;; every event formatting the same stored double agrees (the freeze proof
;;;; rides that agreement). CL `round` is round-half-to-even, the same rule as
;;;; the racket/chez/gerbil emitters' `round` — cross-impl byte agreement.
;;;;
;;;; PURE Common Lisp — no AppKit / CoreGraphics / dylib dependency — so it
;;;; loads + unit-tests in isolation (`sbcl --script` loads this file then calls
;;;; the emitters; the only non-ANSI surface is `sb-ext:posix-getenv`).
;;;; drawing-canvas.lisp references it through the `dc-events` nickname;
;;;; run.lisp / dump.lisp load this file first.

(defpackage #:apianyware-sbcl-drawing-canvas-events
  (:use #:cl)
  (:nicknames #:dc-events)
  (:export #:events-init! #:emit-startup #:emit-launch-line #:emit-shutdown
           #:emit-stroke-begun #:emit-stroke-committed
           #:emit-color-changed #:emit-width-changed #:emit-cleared
           #:close-events! #:events-log-path))

(in-package #:apianyware-sbcl-drawing-canvas-events)

;; Fixed default the descriptor's #:events-path mirrors, so the runner tails the
;; same file whether or not #:log-env (DRAWING_CANVAS_EVENTS_LOG) propagates
;; through LaunchServices.
(defparameter *default-events-path* "/tmp/drawing-canvas/events.log")

(defvar *port* nil)
(defvar *path* nil)

;; DRAWING_CANVAS_EVENTS_LOG if set and non-empty, else the fixed default.
(defun resolve-path ()
  (let ((env (sb-ext:posix-getenv "DRAWING_CANVAS_EVENTS_LOG")))
    (if (and env (plusp (length env))) env *default-events-path*)))

(defun events-log-path () *path*)

;; Open + truncate the events.log the runner tails. :supersede truncates an
;; existing file and creates the parent dir (via ensure-directories-exist). The
;; runner also truncates it between scenarios (setup-scenario!), so the two
;; truncates compose cleanly.
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
    ;; Swallow only I/O-level failures (out-of-disk, closed-stream races on
    ;; shutdown). A genuine programmer error still surfaces during dev.
    (handler-case
        (progn
          (write-string line *port*)
          (terpri *port*)
          (finish-output *port*))
      ((or stream-error file-error) () nil))))

;; Stored double -> bare integer, rounded to nearest (the one rounding site).
(defun component->255 (c) (round (* c 255.0d0)))
(defun width->int (w) (round w))

(defun emit-startup () (emit-line "[lifecycle] startup"))

;; The §3 step 6 launch diagnostic — the bare line beginning `Drawing Canvas`
;; the runner's `wait-for-log` matches; dual-emitted (the stdout print stays in
;; drawing-canvas.lisp for unbundled runs). The sbcl wording differs from
;; racket/chez/gerbil by design — the contract asserts the prefix only.
(defun emit-launch-line ()
  (emit-line "Drawing Canvas opened. Drag to draw; Color… changes the stroke colour, the slider its width, Clear empties the canvas. Quit with Cmd-Q."))

;; `~(~a~)` downcases REASON: CL's default *print-case* is :upcase, so a bare ~a
;; on the symbol 'menu would emit `reason=MENU` — but the contract mandates
;; lowercase `reason ∈ {menu, signal, error}`.
(defun emit-shutdown (reason)
  (emit-line (format nil "[lifecycle] shutdown reason=~(~a~)" reason)))

;;; The two stroke events (contract "Canvas events"): the caller passes the
;;; STROKE'S OWN frozen components/width (captured at its mouse-down — read from
;;; the stroke record, never from the current tool state), plus the stored point
;;; count on commit (down point + drag points; the release is not appended).
;;; Fixed key order r · g · b · width (· points).
(defun emit-stroke-begun (r g b width)
  (emit-line (format nil "[canvas] stroke-begun r=~d g=~d b=~d width=~d"
                     (component->255 r) (component->255 g) (component->255 b)
                     (width->int width))))

(defun emit-stroke-committed (r g b width points)
  (emit-line (format nil "[canvas] stroke-committed r=~d g=~d b=~d width=~d points=~d"
                     (component->255 r) (component->255 g) (component->255 b)
                     (width->int width) points)))

;; Success-path only (§8.1 step 4): emitted after the device-RGB components are
;; stored; the silent no-ops (nil panel colour, failed conversion) emit nothing.
(defun emit-color-changed (r g b)
  (emit-line (format nil "[canvas] color-changed r=~d g=~d b=~d"
                     (component->255 r) (component->255 g) (component->255 b))))

(defun emit-width-changed (width)
  (emit-line (format nil "[canvas] width-changed width=~d" (width->int width))))

;; Always emitted, including on an already-empty canvas (count=0) — the
;; positive channel for stroke-set cardinality.
(defun emit-cleared (count)
  (emit-line (format nil "[canvas] cleared count=~d" count)))

(defun close-events! ()
  (when *port*
    (handler-case (progn (finish-output *port*) (close *port*))
      ((or stream-error file-error) () nil))
    (setf *port* nil *path* nil)))
