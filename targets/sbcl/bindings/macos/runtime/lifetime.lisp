;;;; runtime/lifetime.lisp — wrapped-`id` lifetime: `sb-ext:finalize` + a main-thread
;;;; release queue + the entry-point autorelease pool (ADR-0036). Leaf 050/050.
;;;;
;;;; The two-mechanism chez/gerbil shape (ADR-0007/0019) with ONE SBCL twist neither
;;;; precedent faced: SBCL finalizers run OFF the main thread (a dedicated "finalizer"
;;;; thread, verified first-hand on 2.6.5). An off-main FINAL `release` that triggers
;;;; `dealloc` of an AppKit object (NSWindow, NSView, …) is undefined behaviour — and
;;;; all 7 sample apps are GUI apps. So the finalizer must NEVER `release` directly:
;;;;
;;;;   - a `sb-ext:finalize` on a +1-owned wrap captures ONLY the raw `id` (never the
;;;;     CLOS instance — that would resurrect it, so the finalizer would never fire)
;;;;     and ENQUEUES it onto a release queue (a cheap, lock-guarded push);
;;;;   - a MAIN-THREAD drain at the entry-point `with-autorelease-pool` boundary sends
;;;;     `release` to each queued `id`, keeping every `dealloc` UI-safe;
;;;;   - +0 autoreleased transients (RETAINED nil at the wrap, ffi.lisp) own nothing —
;;;;     the SAME pool boundary drains them, so they never reach a finalizer.
;;;;
;;;; This is a UI-AFFINITY fix, not the GC-safety concern of threading (050/060): the
;;;; finalizer thread is SBCL-native, hence suspendable for stop-the-world GC. Needs
;;;; 020 (the seam: `%objc-release`, the `ptr` slot, `*release-finalizer-installer*`).

(in-package #:apianyware-sbcl-impl)

;;; ---------------------------------------------------------------------------
;;; The entry-point autorelease pool — libobjc's ARC primitives, exactly what an
;;; ObjC `@autoreleasepool {}` compiles to. They live in always-mapped libobjc, so
;;; the `define-alien-routine`s resolve with no framework `dlopen` (like the libobjc
;;; primitives in ffi.lisp). `objc_autoreleasePoolPush` returns an opaque token the
;;; matching `…Pop` consumes; nesting is well-defined.
;;; ---------------------------------------------------------------------------

(sb-alien:define-alien-routine ("objc_autoreleasePoolPush" %autorelease-pool-push)
    sb-alien:system-area-pointer)

(sb-alien:define-alien-routine ("objc_autoreleasePoolPop" %autorelease-pool-pop)
    sb-alien:void
  (token sb-alien:system-area-pointer))

;;; ---------------------------------------------------------------------------
;;; The main-thread release queue.
;;;
;;; The finalizer thread PUSHES (it owns no UI affinity, so it may only enqueue);
;;; the main thread DRAINS (it alone may send `release` and trigger `dealloc`). The
;;; cross-thread surface is one small mutex-guarded list — not a concurrent guardian
;;; (ADR-0036: "the finalizer thread only enqueues … never releases"). Entries are
;;; raw `id`s as INTEGERS (`sap-int`), never SAPs — the finalizer must capture a value
;;; copy, not anything that could re-root the dead object.
;;; ---------------------------------------------------------------------------

(defvar *release-queue* '()
  "A list of raw `id`s (as integers) awaiting a main-thread `release`. Pushed by the
   finalizer thread, drained on main at each pool boundary. Guarded by the lock below.")

(defvar *release-queue-lock* (sb-thread:make-mutex :name "aw-objc-release-queue")
  "Guards `*release-queue*` against the finalizer-thread push racing the main drain.")

(defun aw-enqueue-release (id-int)
  "Push a raw `id` (as an integer) onto the release queue. Called BY THE FINALIZER
   THREAD — so it does the absolute minimum (a lock-guarded push) and never touches
   ObjC: the `release` itself must happen on main (`aw-drain-release-queue`)."
  (sb-thread:with-mutex (*release-queue-lock*)
    (push id-int *release-queue*)))

(defun aw-drain-release-queue ()
  "Send `release` to every queued `id`, ON THE CURRENT THREAD (the caller guarantees
   this is main, via the pool boundary). Snapshots + clears the queue under the lock,
   then releases outside it so a `dealloc` re-entering Lisp cannot deadlock on a push.
   Returns the count released (for the smoke / instrumentation)."
  (let ((batch (sb-thread:with-mutex (*release-queue-lock*)
                 (prog1 *release-queue* (setf *release-queue* '())))))
    (dolist (id-int batch (length batch))
      (%objc-release (sb-sys:int-sap id-int)))))

;; 050/070 startup reset: a queued `id` is a baked foreign pointer (an integer
;; captured in the generating process); after a dump it is garbage, and finalizers
;; are `:dont-save t` so nothing re-enqueues it. DROP the queue at startup — draining
;; it would `release` a stale pointer (the "never reuse a baked pointer" invariant).
(aw-register-startup-hook
 :release-queue
 (lambda () (sb-thread:with-mutex (*release-queue-lock*) (setf *release-queue* '()))))

;;; ---------------------------------------------------------------------------
;;; Finalizer registration — armed by `aw-wrap` (020 seam) on a +1-owned wrap via
;;; the `*release-finalizer-installer*` hook this file installs.
;;; ---------------------------------------------------------------------------

(defun aw-register-release (instance)
  "Register a release finalizer on INSTANCE, a +1-owned wrap. CRITICAL: the finalizer
   closure captures ONLY the raw `id` integer (`id-int`), never INSTANCE — closing
   over INSTANCE would keep it reachable from its own finalizer, so it could never be
   collected and the finalizer would never run. On collection (off-main, the SBCL
   `finalizer` thread, ADR-0036) it merely ENQUEUES the `id`; the next main-thread pool
   drain sends the balancing `release`. `:dont-save t` drops the finalizer at
   `save-lisp-and-die` — a dumped image's foreign `id`s are stale (050/070), so a
   revived process must not `release` garbage."
  (let ((id-int (sb-sys:sap-int (slot-value instance 'ptr))))   ; value copy — NOT instance
    (sb-ext:finalize instance
                     (lambda () (aw-enqueue-release id-int))
                     :dont-save t)))

;; Install the hook into the 020 seam: from here on, every `aw-wrap … t` arms a
;; release finalizer. Before this point `*release-finalizer-installer*` is nil, which
;; is what the seam / object-model smokes (no pool, no drain) rely on.
(setf *release-finalizer-installer* #'aw-register-release)

;;; ---------------------------------------------------------------------------
;;; The entry-point pool macros (contract observable behaviour; mechanism private —
;;; ADR-0036 consequence). Bare in the impl package, like `define-objc-subclass`
;;; (050/040) — application source uses this package; the macro NAME + semantics are
;;; the family-portable surface, the expansion is SBCL-private.
;;; ---------------------------------------------------------------------------

(defmacro with-autorelease-pool (&body body)
  "Run BODY inside an ObjC autorelease pool, draining the main-thread release queue at
   the boundary. `unwind-protect`-based so a NON-LOCAL exit — a signalled `ns:cocoa-error`
   (050 conditions, ADR-0037), a Lisp `throw`/`return` — still drains the queue and pops
   the pool. Drain THEN pop: the queued `release`s run first, so any autoreleases their
   `dealloc`s emit are caught by this very pool and reclaimed at the pop. Multiple values
   of BODY are preserved (`unwind-protect` returns all values of its protected form).

   Every main-thread entry wraps its body in this: app `main`, run-loop event handlers,
   and callbacks bounced to main (050/060, ADR-0035). The drain point is where +1-owned
   finalized objects and +0 autoreleased transients are both reclaimed (ADR-0036)."
  (let ((token (gensym "POOL")))
    `(let ((,token (%autorelease-pool-push)))
       (unwind-protect
            (progn ,@body)
         (aw-drain-release-queue)
         (%autorelease-pool-pop ,token)))))

(defmacro define-entry-point ((name &rest args) &body body)
  "Define function NAME whose body runs inside `with-autorelease-pool`. The ergonomic
   form for an entry point — app `main`, a run-loop event handler, a bounced callback."
  `(defun ,name ,args
     (with-autorelease-pool ,@body)))
