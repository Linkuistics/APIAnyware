;;; runtime/objc.ss — gerbil target object model + lifetime + error model.
;;;
;;; The single module every generated binding imports (`:gerbil-bindings/runtime/
;;; objc`). It owns, per ADR-0018/0020 (object model), ADR-0019 (lifetime) and
;;; ADR-0006 (error model):
;;;
;;;   - the manifest class-graph ROOT `(defclass NSObject (ptr) …)` — every
;;;     generated `defclass` chains up to it; the `ptr` slot is the only state;
;;;   - `register-objc-class!` + the ObjC-name → constructor registry the
;;;     class-aware `wrap` consults (`object_getClass` → exact bound type, nearest
;;;     bound ancestor as fallback);
;;;   - `wrap` / `->ptr` — the object boundary, registering the Gambit release
;;;     `will` (ADR-0019) on every wrapped +1;
;;;   - `with-autorelease-pool` / `define-entry-point` — the entry-point pool;
;;;   - the `nserror` record + `call-with-nserror-out` — `(values result error)`.
;;;
;;; The two native-core callback bridges (`make-delegate`, `make-objc-block`) and
;;; the transparent-subclassing forms are STUBBED here (leaf 050/010) — leaves
;;; 020/030 replace the stub bodies. This unit is C-safe (no `-x objective-c`).

(import :std/foreign
        :gerbil/gambit                       ; make-will
        :gerbil-bindings/runtime/ffi
        :gerbil-bindings/runtime/native-core)
(export NSObject NSObject? NSObject-ptr make-NSObject
        register-objc-class!
        wrap wrap-borrowed ->ptr
        with-autorelease-pool define-entry-point
        ;; nserror / error model (ADR-0006)
        make-nserror nserror? nserror-domain nserror-code
        nserror-localised-description nserror-userinfo
        call-with-nserror-out
        make-delegate make-objc-block
        ;; token marshalling reused by the transparent-subclass bridge (subclass.ss)
        token->kind return-kind-int coerce-in coerce-out encode-signature)

;; Re-export the FFI helpers the generated constants/functions modules call by
;; bare name (`string->nsstring`, and the libobjc seam advanced code may want).
;; Whole-module re-export keeps the one import path (`:gerbil-bindings/runtime/
;; objc`) the emitter targets sufficient.
(export (import: :gerbil-bindings/runtime/ffi))

;; --- class-graph root (ADR-0020) ------------------------------------------
;; Runtime-owned single root. The `ptr` slot holds the raw ObjC `id`; the
;; release `will` is registered by `wrap`, not the constructor (the bare
;; `make-NSObject` is also used by intermediate synthesized nodes).
(defclass NSObject (ptr) transparent: #t)

;; --- ObjC-name → constructor registry -------------------------------------
;; `wrap` maps a live instance's dynamic ObjC class name to the exact bound
;; Gerbil constructor; the stored ObjC superclass name backs the 030
;; subclassing bridge (unused here, retained for forward compatibility).
(def *class-registry* (make-hash-table))

;; Emitter contract (co-adjusted at leaf 050/010, see emit_class.rs): a class
;; module emits `(register-objc-class! make-<Class> <Class>::t "<ObjC>" "<Super>")`
;; — the keyword constructor, the runtime class descriptor, and the ObjC names.
(def (register-objc-class! ctor _descriptor objc-name objc-super)
  (hash-put! *class-registry* objc-name (cons ctor objc-super)))

;; NSObject is runtime-owned, so the emitter never registers it — do it here so
;; the wrap fallback always bottoms out in a real bound type.
(register-objc-class! (lambda (p) (make-NSObject ptr: p)) NSObject::t "NSObject" "")

;; Walk a Class pointer up its ObjC superclass chain to the nearest constructor
;; bound in the registry (exact hit is the common case under the full graph).
(def (registry-ctor-for-class cls)
  (let loop ((c cls))
    (if (ptr-null? c)
      (lambda (p) (make-NSObject ptr: p))      ; ultimate fallback
      (let (entry (hash-get *class-registry* (class-get-name c)))
        (if entry
          (car entry)
          (loop (class-get-superclass c)))))))

;; --- the object boundary (ADR-0019 + ADR-0020) ----------------------------
;; `(wrap p)`     — +0 autoreleased return: retain, so the will's release balances.
;; `(wrap p #t)`  — +1 retained return (alloc/init/copy/new/returns_retained): no
;;                  retain; the will's single release balances the +1.
;; A nil `id` wraps to #f (Scheme false), the natural "no object".
(def (wrap ptr (retained? #f))
  (if (ptr-null? ptr)
    #f
    (begin
      (unless retained? (objc-retain ptr))
      (let* ((ctor (registry-ctor-for-class (object-get-class ptr)))
             (obj  (ctor ptr)))
        ;; Gambit will: on collection, release the owned +1 (probe-validated —
        ;; fires at GC, no explicit drain needed, unlike chez's guardian).
        (make-will obj (lambda (dead) (objc-release (NSObject-ptr dead))))
        obj))))

;; `wrap-borrowed` — a class-aware wrap that does NOT retain and registers NO
;; release will: for an object handed to a callback (a delegate method arg, a
;; block arg), which we borrow for the callback's dynamic extent only. Keeping
;; the wrapper past the callback is the caller's risk (cf. racket
;; `borrow-objc-object`). nil → #f.
(def (wrap-borrowed ptr)
  (if (ptr-null? ptr)
    #f
    ((registry-ctor-for-class (object-get-class ptr)) ptr)))

;; Coerce an outbound `id` argument: a bound instance → its raw ptr; #f/nil →
;; the C NULL pointer. The proc core reads `self` directly via `(NSObject-ptr
;; self)`, so the receiver does not pass through here.
(def (->ptr x)
  (cond
    ((not x) (null-ptr))
    ((NSObject? x) (NSObject-ptr x))
    (else x)))                                ; already a raw foreign pointer

;; --- entry-point autorelease pool (ADR-0019) ------------------------------
;; Push an NSAutoreleasePool, run body (preserving multiple values), pop. No
;; guardian drain: Gambit wills self-execute at GC.
(defrules with-autorelease-pool ()
  ((_ body0 body ...)
   (let (pool (autorelease-pool-push))
     (call-with-values
      (lambda () body0 body ...)
      (lambda vs
        (autorelease-pool-pop pool)
        (apply values vs))))))

;; (define-entry-point (name arg ...) body ...) — define `name` with its body
;; wrapped in the entry-point pool. For app main, event handlers, callbacks.
(defrules define-entry-point ()
  ((_ (name arg ...) body0 body ...)
   (def (name arg ...)
     (with-autorelease-pool body0 body ...))))

;; --- error model (ADR-0006) -----------------------------------------------
(defstruct nserror (domain code localised-description userinfo)
  transparent: #t)

;; Build an `nserror` from a live NSError* (or #f when the pointer is null).
;; The error is +1/retained-owned by the caller (Cocoa hands back an
;; autoreleased/retained NSError* through the out-param); we read its fields
;; eagerly into Scheme values and do not retain the NSError itself (its Scheme
;; image outlives the pool). domain/localizedDescription are NSString*; code is
;; an NSInteger.
(def (nserror<-ptr err-ptr)
  (if (ptr-null? err-ptr)
    #f
    (let* ((sel-domain (sel-register "domain"))
           (sel-code   (sel-register "code"))
           (sel-desc   (sel-register "localizedDescription"))
           (dom-ptr  (msg-id err-ptr sel-domain))
           (desc-ptr (msg-id err-ptr sel-desc)))
      (make-nserror
       (and (not (ptr-null? dom-ptr))  (nsstring->string dom-ptr))
       (msg-long err-ptr sel-code)
       (and (not (ptr-null? desc-ptr)) (nsstring->string desc-ptr))
       #f))))                                 ; userInfo: dictionary marshalling TBD

;; (call-with-nserror-out thunk) — the out-param settler. `thunk` takes the
;; error cell, calls the emitted `%msg-…-e` crossing with it as the trailing
;; arg, and returns ONE (already-wrapped) value. We allocate/zero the cell, run
;; the thunk, read the captured NSError*, build the nserror, free the cell, and
;; return `(values <thunk-result> <nserror-or-#f>)`. Mirrors chez ADR-0006.
(def (call-with-nserror-out thunk)
  (let (cell (alloc-id-cell))
    (let* ((result (thunk cell))
           (err    (nserror<-ptr (id-cell-ref cell))))
      (free-cell cell)
      (values result err))))

;; --- callback bridges (leaf 050/020, ADR-0017 native core) ----------------
;; Both bridges sit on the native core (`native-core.ss`): a generic C
;; trampoline re-enters Gerbil and looks the registered closure up. This layer
;; owns the TOKEN MARSHALLING — turning the emitter's FFI tokens (the same
;; `GerbilFfiTypeMapper` vocabulary the class crossings use) into the per-arg /
;; per-return coercion the trampoline cannot do itself.

;; Spec token → coercion class. A token is a Scheme datum from the emitter's
;; per-selector spec (emit_protocol `spec_token`):
;;   `object`         — an ObjC object: WRAP it into a bound instance (in) /
;;                      coerce a bound instance back to a ptr (out).
;;   `(pointer void)` — a RAW C pointer (a `BOOL*` out-param, a block, a `SEL`):
;;                      passed straight through, NEVER wrapped (object_getClass
;;                      on a non-object crashes — leaf 050/020 finding).
;;   `bool` / intN / `char-string` — scalars.
;; `float`/`double`/by-value structs are NOT deliverable by the generic
;; trampoline (FP registers / struct ABI — see native-core.ss); we raise on them
;; rather than pass garbage, so an unsupported callback signature fails loudly.
(def (token->kind tok)
  (cond
    ((eq? tok 'object) 'obj)
    ((equal? tok '(pointer void)) 'ptr)
    ((eq? tok 'void) 'void)
    ((eq? tok 'bool) 'bool)
    ((memq tok '(int8 int16 int32 int64
                 unsigned-int8 unsigned-int16 unsigned-int32 unsigned-int64)) 'long)
    ((eq? tok 'char-string) 'string)
    (else
     (error "native callback bridge: unsupported FFI token in signature" tok))))

;; The ObjC @encode signature string class_addMethod wants: return, self (@),
;; _cmd (:), then each param. Approximate but consistent — for direct
;; objc_msgSend IMP dispatch only the arg COUNT / pointer-ness matters; the
;; runtime uses the string for introspection/forwarding.
(def (token->encode tok)
  (case (token->kind tok)
    ((void) "v") ((obj) "@") ((ptr) "^v") ((bool) "B") ((long) "q") ((string) "*")))
(def (encode-signature ret-tok param-toks)
  (string-append (token->encode ret-tok) "@:"
                 (apply string-append (map token->encode param-toks))))

;; Return token → the int native-core's trampoline `switch`es read. Both an
;; `object` and a raw `(pointer void)` return are a pointer-width return (kind-id).
(def (return-kind-int tok)
  (case (token->kind tok)
    ((void)     kind-void)
    ((obj ptr)  kind-id)
    ((bool)     kind-bool)
    ((long)     kind-long)
    (else (error "native callback bridge: unsupported return token" tok))))

;; Coerce one raw trampoline arg (delivered pointer-width) to a Gerbil value.
(def (coerce-in tok raw)
  (case (token->kind tok)
    ((obj)    (wrap-borrowed raw))            ; borrowed object → bound instance
    ((ptr)    raw)                            ; raw C pointer — passed through
    ((bool)   (not (ptr-null? raw)))          ; pointer bits as truth
    ((long)   (ptr->int raw))                 ; pointer bits as integer
    ((string) (and (not (ptr-null? raw)) (cstr->string raw)))
    (else (error "native callback bridge: unsupported param token" tok))))

;; Coerce the user proc's result to the C-ready value the trampoline returns.
(def (coerce-out tok val)
  (case (token->kind tok)
    ((void) (void))
    ((obj)  (->ptr val))                      ; bound instance / #f → ptr / null
    ((ptr)  (or val (null-ptr)))              ; raw pointer result (or null)
    ((bool) (and val #t))
    ((long) val)
    (else (error "native callback bridge: unsupported return token" tok))))

(def (take-up-to lst n)
  (let loop ((l lst) (n n) (acc '()))
    (if (or (##fxzero? n) (null? l))
      (reverse acc)
      (loop (cdr l) (##fx- n 1) (cons (car l) acc)))))

;; The BLOCK closure the trampoline runs: coerce the first `arity` raw args per
;; the param tokens, apply the user proc, coerce the result per the return token.
;; A block has no receiver, so the block trampoline passes only its arg tail (3).
(def (make-callback-closure proc param-toks ret-tok arity)
  (lambda raw-args
    (coerce-out ret-tok
                (apply proc (map coerce-in param-toks (take-up-to raw-args arity))))))

;; The IMP closure for a DELEGATE method: the IMP trampoline now passes the
;; receiver `self` as the leading arg (leaf 050/030), but a delegate proc closes
;; over its own state and does not want the synthesized delegate instance — so we
;; DROP the leading self and marshal only the method's visible args. (The
;; transparent-subclass bridge, by contrast, keeps self — see `subclass.ss`.)
(def (make-imp-callback-closure proc param-toks ret-tok arity)
  (lambda (_self . raw-args)
    (coerce-out ret-tok
                (apply proc (map coerce-in param-toks (take-up-to raw-args arity))))))

;; `make-delegate` (ADR-0017 §6, contract from emit_protocol). One arg: a list
;; of `(selector-string proc (param-token …) return-token)` specs. Synthesizes a
;; fresh ObjC class, installs an IMP per selector dispatching into `proc`, and
;; returns a +1-retained instance. The caller MUST keep the returned object
;; reachable: AppKit `setDelegate:` does not retain (ADR-0019); the will then
;; releases the +1 on GC. The synthesized class + its closures live for the
;; process (one class per call) — acceptable for the bounded delegate set.
(def *delegate-class-counter* 0)
(def (make-delegate specs)
  (let* ((n *delegate-class-counter*)
         (class-name (string-append "AWGerbilDelegate_" (number->string n)))
         (cls (allocate-class-pair class-name "NSObject")))
    (set! *delegate-class-counter* (##fx+ n 1))
    (when (ptr-null? cls)
      (error "make-delegate: objc_allocateClassPair failed" class-name))
    (for-each
     (lambda (spec)
       (let* ((sel        (car spec))
              (proc       (cadr spec))
              (param-toks (caddr spec))
              (ret-tok    (cadddr spec))
              (arity      (length param-toks)))
         (when (##fx> arity 4)
           (error "make-delegate: selector exceeds the 4-arg trampoline cap" sel))
         (register-imp-closure! cls sel
                                (make-imp-callback-closure proc param-toks ret-tok arity))
         (class-add-method cls sel (encode-signature ret-tok param-toks)
                           (return-kind-int ret-tok))))
     specs)
    (register-class-pair cls)
    (wrap (class-new-instance cls) #t)))

;; `make-objc-block` (ADR-0017 §6). Wraps a Gerbil proc as an ObjC block usable
;; as a block-typed argument. `param-toks`/`ret-tok` are the inner block
;; signature's FFI tokens (bridgeable set: scalar / `(pointer void)`; see
;; `is_bridgeable_block`). A `#f` proc → the null block ("no callback"). Returns
;; a raw block pointer (already a foreign pointer; passes through `->ptr`).
;; The closure is rooted by its block-id; the block is not yet released (see
;; native_block.c lifetime note).
(def (make-objc-block proc param-toks ret-tok)
  (if (not proc)
    (null-ptr)
    (let ((arity (length param-toks)))
      (when (##fx> arity 3)
        (error "make-objc-block: block exceeds the 3-arg trampoline cap"))
      (let ((id (next-block-id!)))
        (register-block-closure! id (make-callback-closure proc param-toks ret-tok arity))
        (make-block id (return-kind-int ret-tok))))))
