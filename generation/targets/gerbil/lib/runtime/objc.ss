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
        :gerbil-bindings/runtime/ffi)
(export NSObject NSObject? NSObject-ptr make-NSObject
        register-objc-class!
        wrap ->ptr
        with-autorelease-pool define-entry-point
        ;; nserror / error model (ADR-0006)
        make-nserror nserror? nserror-domain nserror-code
        nserror-localised-description nserror-userinfo
        call-with-nserror-out
        ;; native-core stubs (leaves 020/030)
        make-delegate make-objc-block)

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

;; --- native-core stubs (leaves 050/020 + 050/030) -------------------------
(def (make-delegate . _)
  (error "make-delegate: native delegate bridge not yet implemented (leaf 050/020)"))
(def (make-objc-block . _)
  (error "make-objc-block: native block bridge not yet implemented (leaf 050/020)"))
