;;;; runtime/threading.lisp — the foreign-thread callback model + the native-worker
;;;; boundary (ADR-0035, contract "callback activation"). Leaf 050/060.
;;;;
;;;; THE ADR-0035 SPINE, in one sentence: a FOREIGN OS thread (a GCD worker, a framework
;;;; completion thread SBCL never created) must NEVER run Lisp — the threading spike
;;;; crashed 5/5 (`ENOTSUP` in `GC-STOP-THE-WORLD`: SBCL cannot stop-the-world-suspend a
;;;; thread it merely *attached* for a callback). So this unit splits the world in two:
;;;;
;;;;   FOREIGN entry (a block the framework invokes, a delegate IMP) → BOUNCE TO MAIN.
;;;;     The bounce is NATIVE — the dylib's block body / `forwardInvocation:` hops to
;;;;     main via `awSbclOnMain` (CallbackBounce, 050/010) BEFORE any Lisp runs. This
;;;;     unit owns only the LISP half: the closure registry + the post-bounce dispatcher,
;;;;     which is therefore only ever entered on the main thread (GC-safe by construction).
;;;;
;;;;   NATIVE entry (an `sb-thread` worker) → SAFE, runs concurrent Lisp directly.
;;;;     The spike's `native-concurrent` control SURVIVED: SBCL-native threads ARE
;;;;     stop-the-world-suspendable. So background COMPUTE belongs on `sb-thread`
;;;;     (`with-background-work`); a result that must touch ObjC/UI is delivered to main
;;;;     with `aw-on-main`. The bounce scopes to FOREIGN entry only — this is the point
;;;;     where sbcl is RICHER than gerbil (whose single-VM Gambit runs Lisp on main only).
;;;;
;;;; ## `aw-block` — a Lisp closure projected as an ObjC block
;;;;
;;;; The DISPATCH-BODY helper the emitted bindings call `(aw-block <closure>)` for a
;;;; block-typed argument (node BRIEF). The block FACTORY is native (`BlockBridge.swift`
;;;; — SBCL cannot author a `^`-literal); this unit registers the closure under an integer
;;;; id and asks the dylib for a block capturing that id. The dylib's block bounces to
;;;; main, then calls `aw-block-dispatcher` (below) with the id + the raw args.
;;;;
;;;; The emitter emits a TOKEN-LESS `(aw-block closure)` — no block signature reaches the
;;;; call site — so, unlike gerbil's four return-kind makers, there is ONE universal
;;;; block: `(void*,void*,void*) -> void*`. The arm64 ABI makes that exact for the whole
;;;; bridgeable set (every slot integer-class: pointer / `BOOL` / `NSInteger` /
;;;; `NSComparisonResult`, all in the general registers; result in x0). The closure
;;;; receives the block's raw arguments (SAPs / integer-class values as SAPs) and returns
;;;; nil (void / null / NO), a bound instance, a raw SAP, an integer, or `t` (YES);
;;;; `aw-block-dispatcher` coerces that to the x0 result. Per-slot object/scalar coercion
;;;; (`aw-wrap` an `id` arg, `sap-int` an index) is the closure's job — the token-less
;;;; call cannot do it here; an ergonomic surface is a 060-sample-apps / contract concern.
;;;;
;;;; Needs 050/010 (the dylib: `aw_sbcl_make_block`, `awSbclOnMain`, `aw_sbcl_on_main_run`)
;;;; and the seam/object-model (`aw-ptr`, `ns:ns-object`). Reference: gerbil
;;;; `native-core.ss` (`*block-table*` / `block-dispatch-*`) + `native_block.c`.

(in-package #:apianyware-sbcl-impl)

;;; sb-introspect (a stock contrib) gives a block closure its NATURAL arity, so app code
;;; writes `(lambda (obj idx stop) …)` / `(lambda (response) …)` — not a fixed 3-arg form.
(eval-when (:compile-toplevel :load-toplevel :execute)
  (require :sb-introspect))

;;; ---------------------------------------------------------------------------
;;; The `BlockBridge.swift` dylib entries (ADR-0038 §4) — bound via sb-alien.
;;; `aw_sbcl_make_block` builds a block capturing a block-id; the block's body bounces
;;; to main, then calls our ONE registered dispatcher with that id.
;;; ---------------------------------------------------------------------------

(sb-alien:define-alien-routine ("aw_sbcl_block_register_dispatcher" %aw-block-register-dispatcher)
    sb-alien:void
  (dispatcher sb-alien:system-area-pointer))

(sb-alien:define-alien-routine ("aw_sbcl_make_block" %aw-make-block)
    sb-alien:system-area-pointer
  (bid sb-alien:int))

;;; The general "run this on main" bounce (CallbackBounce.swift `aw_sbcl_on_main_run`):
;;; `dispatch_sync` to the main queue (direct call when already on main). Backs
;;; `aw-on-main` below — a native worker's UI-safe result delivery.
(sb-alien:define-alien-routine ("aw_sbcl_on_main_run" %aw-on-main-run)
    sb-alien:void
  (fn  sb-alien:system-area-pointer)
  (ctx sb-alien:system-area-pointer))

;;; ---------------------------------------------------------------------------
;;; The block closure registry. The block (native) captures only an INTEGER id, so no
;;; GC-managed reference ever crosses the C ABI; the closure is reachable only here, a
;;; Lisp root. Matching gerbil's `*block-table*`, a registered closure + its block live
;;; for the process (the emitter's inline `(aw-block …)` arg has no post-call free hook) —
;;; a bounded cost for app-lifetime callbacks; a hot transient block is a future refinement.
;;; ---------------------------------------------------------------------------

(defvar *block-table* (make-hash-table)
  "Block id (fixnum) -> the normalized 3-arg invoker for the user closure.")
(defvar *block-counter* 0)
(defvar *block-lock* (sb-thread:make-mutex :name "aw-block-table")
  "Guards `*block-table*` + `*block-counter*` (the dispatcher reads on main while an
   `sb-thread` worker may register a block).")

(defun aw-block-arity (fn)
  "How many of the (up to 3) raw block args to hand FN: its positional arg count
   (required + optional), capped at 3. `&rest`/`&key`/unintrospectable -> 3 (pass all)."
  (let ((ll (ignore-errors (sb-introspect:function-lambda-list fn))))
    (if (or (null ll) (member '&rest ll) (member '&body ll) (member '&key ll))
        3
        (min 3 (count-if-not (lambda (x) (member x lambda-list-keywords)) ll)))))

(defun aw-block-return->sap (val)
  "Coerce a block closure's return value to the SAP the universal block hands back in x0:
   nil -> null (void / null id / NO); `t` -> YES; a bound instance -> its `id`; a raw SAP
   -> itself; an integer (NSComparisonResult, count, …) -> its bits. ANYTHING ELSE -> null:
   token-less, `aw-block` cannot know a block is VOID, and a void block closure's body
   naturally ends in some Lisp value the framework will ignore (it never reads x0) — so an
   unrecognized return is treated as void rather than an error. A value-returning block's
   closure must therefore end in a coercible value (an instance / integer / SAP / t / nil)."
  (cond
    ((null val) (aw-null-sap))
    ((eq val t) (sb-sys:int-sap 1))
    ((sb-sys:system-area-pointer-p val) val)
    ((typep val 'ns:ns-object) (aw-ptr val))
    ((integerp val) (sb-sys:int-sap val))
    (t (aw-null-sap))))

(defun aw-block (closure)
  "Project a Lisp CLOSURE as an ObjC block SAP (the DISPATCH-BODY helper for a block-typed
   argument). nil -> the null block (\"no callback\"). The closure receives the block's raw
   arguments (its natural arity, up to 3) and returns a value `aw-block-return->sap`
   accepts. Its invocation bounces to main (ADR-0035) before it runs."
  (cond
    ((null closure) (aw-null-sap))
    ((functionp closure)
     (let* ((arity (aw-block-arity closure))
            ;; Normalize to a fixed 3-arg invoker so the dispatcher is arity-agnostic.
            (invoker (ecase arity
                       (0 (lambda (a1 a2 a3) (declare (ignore a1 a2 a3)) (funcall closure)))
                       (1 (lambda (a1 a2 a3) (declare (ignore a2 a3))    (funcall closure a1)))
                       (2 (lambda (a1 a2 a3) (declare (ignore a3))       (funcall closure a1 a2)))
                       (3 (lambda (a1 a2 a3)                             (funcall closure a1 a2 a3)))))
            (id (sb-thread:with-mutex (*block-lock*)
                  (let ((id *block-counter*))
                    (setf (gethash id *block-table*) invoker)
                    (incf *block-counter*)
                    id)))
            (blk (%aw-make-block id)))
       (when (aw-null-sap-p blk)
         (error "aw-block: the dylib returned a null block — was ~
                 `aw-init-block-dispatcher` run after `aw-load-native-dylib`?"))
       blk))
    (t (error "aw-block: expected a function or nil, got ~S" closure))))

;;; ADR-0035: the post-bounce Lisp entry. The dylib's block body has ALREADY hopped to the
;;; main thread, so entering Lisp here is GC-safe — it is NEVER called from a foreign
;;; thread directly. A toplevel `handler-case` keeps a Lisp error from unwinding into the
;;; ObjC block frame (it would corrupt the framework's call). The result rides x0 back.
(sb-alien:define-alien-callable aw-block-dispatcher sb-alien:system-area-pointer
    ((bid sb-alien:int)
     (a1  sb-alien:system-area-pointer)
     (a2  sb-alien:system-area-pointer)
     (a3  sb-alien:system-area-pointer))
  (handler-case
      (let ((invoker (sb-thread:with-mutex (*block-lock*) (gethash bid *block-table*))))
        (if invoker
            (aw-block-return->sap (funcall invoker a1 a2 a3))
            (aw-null-sap)))
    (error (e)
      (format *error-output* "~&aw-block-dispatcher[~D]: ~A~%" bid e)
      (aw-null-sap))))

(defvar *block-dispatcher-registered* nil)

(defun aw-init-block-dispatcher ()
  "Register our ONE block dispatcher with the dylib (idempotent). Run once after
   `aw-load-native-dylib`, before any `aw-block` call. 050/070's startup pass calls this;
   the dev smoke calls it explicitly."
  (unless *block-dispatcher-registered*
    (%aw-block-register-dispatcher
     (sb-alien:alien-sap (sb-alien:alien-callable-function 'aw-block-dispatcher)))
    (setf *block-dispatcher-registered* t)))

;;; ===========================================================================
;;; `aw-on-main` — deliver a thunk onto the main thread (a native worker's UI-safe
;;; hand-off). Rides the same `(fn, ctx)` bounce as the release-queue drain: ctx carries a
;;; thunk-id the dispatcher pops + runs on main. Synchronous (`dispatch_sync`) — blocks
;;; the caller until the thunk has run main-side. Direct call when already on main.
;;; ===========================================================================

(defvar *on-main-thunks* (make-hash-table))
(defvar *on-main-counter* 0)
(defvar *on-main-lock* (sb-thread:make-mutex :name "aw-on-main"))

(sb-alien:define-alien-callable aw-on-main-dispatcher sb-alien:void
    ((ctx sb-alien:system-area-pointer))
  (let ((thunk (sb-thread:with-mutex (*on-main-lock*)
                 (let* ((id (sb-sys:sap-int ctx))
                        (th (gethash id *on-main-thunks*)))
                   (remhash id *on-main-thunks*)
                   th))))
    (when thunk
      (handler-case (funcall thunk)
        (error (e) (format *error-output* "~&aw-on-main: ~A~%" e))))))

(defun aw-on-main (thunk)
  "Run THUNK on the main thread (SBCL-native, the run-loop owner) and BLOCK until it
   finishes. Safe from an `sb-thread` worker — the vehicle by which background compute
   delivers a UI/ObjC result main-side (ADR-0035). On main already, runs inline."
  (let ((id (sb-thread:with-mutex (*on-main-lock*)
              (let ((id *on-main-counter*))
                (setf (gethash id *on-main-thunks*) thunk)
                (incf *on-main-counter*)
                id))))
    (%aw-on-main-run
     (sb-alien:alien-sap (sb-alien:alien-callable-function 'aw-on-main-dispatcher))
     (sb-sys:int-sap id))))

;;; ===========================================================================
;;; The native-worker boundary (ADR-0035 "richer than gerbil"). SBCL-native `sb-thread`
;;; workers run concurrent Lisp SAFELY — use them for pure-Lisp background compute; hand a
;;; UI/ObjC result to `aw-on-main`. NEVER let a foreign (framework/GCD) thread enter Lisp
;;; without the native bounce — that is the 5/5 crash this whole unit exists to prevent.
;;; ===========================================================================

(defun aw-spawn-worker (thunk &key (name "aw-worker"))
  "Run THUNK on a fresh SBCL-NATIVE worker thread (`sb-thread`) and return the thread.
   For PURE-Lisp background compute (safe — the spike's native control survived). To
   touch ObjC/UI with the result, hand it to `aw-on-main`."
  (sb-thread:make-thread thunk :name name))

(defmacro with-background-work ((&key (name "aw-worker")) &body body)
  "Ergonomic `aw-spawn-worker`: run BODY on a fresh native worker thread, returning it.
   The family-portable safe-background-compute surface; see `aw-spawn-worker` for the
   foreign-vs-native thread rule (ADR-0035)."
  `(aw-spawn-worker (lambda () ,@body) :name ,name))

;;; ===========================================================================
;;; Async-method completion (ADR-0035) — the bridge is `AsyncBridge.swift`
;;; (`awSbclAsyncDispatch`): it runs the async op on the cooperative pool, then delivers
;;; the marshalled completion ON THE MAIN THREAD (proven in `APIAnywareSbclTests`). The
;;; Lisp continuation a generated async trampoline calls therefore runs main-side, GC-safe
;;; — the same guarantee blocks get. The Lisp-side async continuation seam binds against
;;; that bridge when `async` residual trampolines are EMITTED (deferred follow-up — the
;;; emitter currently routes `is_async` methods to the §6d deferred count, trampoline.rs);
;;; that leaf knows the generated completion-callback signature, so the seam lands with
;;; its consumer rather than speculatively here.
;;; ===========================================================================
