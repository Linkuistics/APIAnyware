;;; runtime/subclass.ss — transparent extensible subclassing (ADR-0020, the centre).
;;;
;;; *Deriving in Gerbil = deriving in ObjC.* This module re-exports `defclass` /
;;; `defmethod` forms that SHADOW Gerbil's built-ins (`:gerbil/core`): when the
;;; superclass is an ObjC-backed bound class, `(defclass (MyView NSView) …)`
;;; synthesizes a *real* ObjC subclass at runtime (`objc_allocateClassPair` +
;;; `objc_registerClassPair`), and each `(defmethod (MyView "drawRect:") …)`
;;; override installs an IMP trampoline so the macOS frameworks dispatch their
;;; callbacks into the user's Gerbil method. For a non-ObjC superclass both forms
;;; fall through to the built-ins cleanly.
;;;
;;; ## Why a SEPARATE module (not folded into objc.ss)
;;;
;;; The GENERATED binding modules (`:gerbil-bindings/<fw>/<class>`) use the
;;; built-in `defclass` to reify the manifest class graph — `NSButton`, `NSView`
;;; etc. ARE the bound classes, not user subclasses. If the shadowing `defclass`
;;; were in scope there, it would try to synthesize an ObjC subclass for every
;;; bound class. So the shadow lives here, imported ONLY by user app code that
;;; subclasses; generated code imports `objc.ss` and never sees it.
;;;
;;; ## Registration ordering (the wrinkle ADR-0020/leaf 050/030 had to settle)
;;;
;;; racket's `dynamic-class.rkt` adds all methods THEN registers the class pair,
;;; because its `make-dynamic-subclass` does it atomically. Gerbil's `(defclass …)`
;;; and the separate top-level `(defmethod …)`s are *distinct* forms, so the class
;;; is synthesized+registered at `defclass` and each override does a
;;; **post-registration `class_addMethod`** — which is legal on a registered class
;;; (only `class_addIvar` is forbidden after registration, and we add no ivars:
;;; the Gerbil instance, not the ObjC object, holds the extra slots). Verified by
;;; the 050/030 spike. This fits Gerbil's separate-forms model with no deferred
;;; bookkeeping; the only constraint imposed on user code is the natural one —
;;; a `defmethod` override must textually follow its `defclass`.
;;;
;;; ## Instance state + lifetime (main-thread, bounded-instance scope)
;;;
;;; When the framework calls e.g. `drawRect:` on the ObjC instance, the IMP
;;; trampoline gets only the raw ObjC `self`; the override body wants the TYPED
;;; Gerbil instance (its extra slots, its `defmethod`s). So `new` records a
;;; back-reference ObjC-ptr → Gerbil-instance in `*subclass-instances*`, which the
;;; override closure consults. That table is STRONG and never pruned, and the
;;; alloc `+1` is held implicitly, so a synthesized instance is retained for the
;;; PROCESS — exactly racket's proven drawing-canvas model (custom views/
;;; controllers are few and app-lifetime). A `dealloc`-driven reclaim (clear the
;;; table entry from a `dealloc` override, release the `+1`) is the natural future
;;; refinement; deferred to keep this first cut crash-free.

(import (rename-in :gerbil/core (defclass %defclass) (defmethod %defmethod))
        :gerbil-bindings/runtime/ffi
        :gerbil-bindings/runtime/native-core
        :gerbil-bindings/runtime/objc)
(export defclass defmethod new
        call-super call-super-id
        ;; runtime entries the macros expand into (also directly callable)
        register-objc-subclass! make-subclass-instance install-subclass-override!)

;; --- the subclass registry -------------------------------------------------
;; gerbil-class-name (symbol) → #(objc-class-ptr objc-super-name ctor).
;; `objc-class-ptr` is #f for a non-ObjC superclass (the fall-through case);
;; `ctor` is `(lambda (ptr) (make-<Class> ptr: ptr))`, supplied by the `defclass`
;; expansion (it captures the built-in keyword constructor).
(def *subclass-registry* (make-hash-table-eq))
;; ObjC instance ptr (as int) → the bound Gerbil instance (strong back-ref).
(def *subclass-instances* (make-hash-table))
(def *subclass-counter* 0)

;; (register-objc-subclass! 'MyView "NSView" ctor) — run once at `defclass` load.
;; If the ObjC superclass exists, synthesize + REGISTER an ObjC subclass pair now
;; (post-registration `class_addMethod` lets later `defmethod`s add IMPs); else
;; record a non-ObjC entry so `new`/overrides fall through cleanly.
(def (register-objc-subclass! name super-name ctor)
  (let (objc-super (objc-get-class super-name))
    (if (ptr-null? objc-super)
      (hash-put! *subclass-registry* name (vector #f super-name ctor))
      (let* ((n *subclass-counter*)
             (objc-name (string-append "AW_" (symbol->string name) "_" (number->string n)))
             (cls (allocate-class-pair objc-name super-name)))
        (set! *subclass-counter* (##fx+ n 1))
        (when (ptr-null? cls)
          (error "register-objc-subclass!: objc_allocateClassPair failed" objc-name))
        (register-class-pair cls)
        (hash-put! *subclass-registry* name (vector cls super-name ctor))))))

;; (make-subclass-instance 'MyView) — alloc+init the synthesized ObjC class, wrap
;; it as the typed Gerbil instance via the registered ctor, and record the
;; back-reference. Errors on a non-ObjC class (use `make-<Class>` directly).
(def (make-subclass-instance name)
  (let (rec (hash-get *subclass-registry* name))
    (unless rec (error "new: unknown subclass (defclass not loaded?)" name))
    (let ((cls (vector-ref rec 0))
          (ctor (vector-ref rec 2)))
      (unless cls
        (error "new: superclass is not ObjC-backed; use the plain constructor" name))
      (let* ((inst (class-new-instance cls))
             (obj  (ctor inst)))
        (hash-put! *subclass-instances* (ptr->int inst) obj)
        obj))))

;; --- @encode signature inference (the IMP-signature half of ADR-0020) -------
;; class_getInstanceMethod searches superclasses, so we read the INHERITED
;; selector's real `method_getTypeEncoding` off the ObjC superclass and parse it
;; into (return-token, deliverable-param-tokens) in the objc.ss token vocabulary.
;; The real encoding string is used VERBATIM for class_addMethod (ABI-exact); the
;; parsed tokens drive the trampoline's per-arg/return marshalling.

(def (enc-skip-qualifiers s i)
  (let loop ((i i))
    (if (and (##fx< i (string-length s))
             (memv (string-ref s i) '(#\r #\n #\N #\o #\R #\V #\A)))
      (loop (##fx+ i 1))
      i)))

(def (enc-skip-digits s i)
  (let loop ((i i))
    (if (and (##fx< i (string-length s)) (char-numeric? (string-ref s i)))
      (loop (##fx+ i 1))
      i)))

;; i points at an opening bracket; return the index just past its match (nested).
(def (enc-skip-balanced s i open close)
  (let loop ((i (##fx+ i 1)) (depth 1))
    (cond
      ((##fx= depth 0) i)
      ((##fx>= i (string-length s)) i)
      (else
       (let (c (string-ref s i))
         (cond ((char=? c open)  (loop (##fx+ i 1) (##fx+ depth 1)))
               ((char=? c close) (loop (##fx+ i 1) (##fx- depth 1)))
               (else             (loop (##fx+ i 1) depth))))))))

;; Read one @encode type → (values token next-index deliverable?). Deliverable? =
;; the generic pointer-width trampoline can carry it (object / int / bool /
;; pointer / C-string ride the integer registers); structs + float/double cannot.
(def (enc-read-type s i)
  (let* ((i (enc-skip-qualifiers s i))
         (c (string-ref s i)))
    (cond
      ((char=? c #\v) (values 'void (##fx+ i 1) #t))
      ((char=? c #\@)
       (if (and (##fx< (##fx+ i 1) (string-length s))
                (char=? (string-ref s (##fx+ i 1)) #\?))
         (values '(pointer void) (##fx+ i 2) #t)   ; @? — a block, raw pointer
         (values 'object (##fx+ i 1) #t)))
      ((char=? c #\:) (values '(pointer void) (##fx+ i 1) #t))   ; SEL
      ((char=? c #\#) (values '(pointer void) (##fx+ i 1) #t))   ; Class
      ((char=? c #\*) (values 'char-string (##fx+ i 1) #t))      ; char*
      ((char=? c #\B) (values 'bool (##fx+ i 1) #t))
      ((or (char=? c #\c) (char=? c #\C)) (values 'bool (##fx+ i 1) #t)) ; ObjC BOOL
      ((memv c '(#\i #\I #\s #\S #\l #\L #\q #\Q)) (values 'int64 (##fx+ i 1) #t))
      ((char=? c #\^)
       (let-values (((_t j _d) (enc-read-type s (##fx+ i 1))))
         (values '(pointer void) j #t)))
      ((char=? c #\{) (values 'struct (enc-skip-balanced s i #\{ #\}) #f))
      ((char=? c #\[) (values 'struct (enc-skip-balanced s i #\[ #\]) #f))
      ((char=? c #\() (values 'struct (enc-skip-balanced s i #\( #\)) #f))
      ((or (char=? c #\f) (char=? c #\d)) (values 'float (##fx+ i 1) #f))
      (else (values '(pointer void) (##fx+ i 1) #t)))))

;; Parse a full method encoding → (values return-token deliverable-param-tokens).
;; Skips the return type, then self (@) and _cmd (:), then collects parameter
;; tokens UP TO the first undeliverable one — a struct/float arg consumes
;; FP/struct registers and shifts everything after it out of the integer-register
;; sequence the generic trampoline reads, so later args can't be delivered either.
(def (parse-encoding enc)
  (let ((len (string-length enc)))
    (let*-values (((ret-tok i0 _r) (enc-read-type enc 0)))
      (let* ((i1 (enc-skip-digits enc i0)))
        (let*-values (((_self i2 _s) (enc-read-type enc i1)))
          (let (i3 (enc-skip-digits enc i2))
            (let*-values (((_cmd i4 _c) (enc-read-type enc i3)))
              (let loop ((i (enc-skip-digits enc i4)) (toks '()))
                (if (##fx>= i len)
                  (values ret-tok (reverse toks))
                  (let*-values (((tok j deliv?) (enc-read-type enc i)))
                    (let (k (enc-skip-digits enc j))
                      (if deliv?
                        (loop k (cons tok toks))
                        (values ret-tok (reverse toks))))))))))))))

(def (take-up-to lst n)
  (let loop ((l lst) (n n) (acc '()))
    (if (or (##fxzero? n) (null? l))
      (reverse acc)
      (loop (cdr l) (##fx- n 1) (cons (car l) acc)))))

;; The IMP closure for a synthesized-subclass override. Unlike a delegate's
;; closure it KEEPS the leading `self`: recover the bound Gerbil instance from the
;; back-ref table (falling back to a borrowed wrap if the instance was created
;; outside `new`), marshal the deliverable args, apply the user method, coerce the
;; result. `coerce-in`/`coerce-out`/`return-kind-int` are objc.ss's shared
;; vocabulary, so an override marshals exactly like every other ObjC crossing.
(def (make-override-closure user-proc param-toks ret-tok)
  (let (arity (length param-toks))
    (lambda (self . raw-args)
      (let ((obj  (or (hash-get *subclass-instances* (ptr->int self))
                      (wrap-borrowed self)))
            (args (map coerce-in param-toks (take-up-to raw-args arity))))
        (coerce-out ret-tok (apply user-proc obj args))))))

;; (install-subclass-override! 'MyView "drawRect:" proc) — run once per override
;; `defmethod`. Infers the signature from the ObjC superclass, installs the IMP
;; closure keyed by (synth-class . selector), and adds the method to the (already
;; registered) synthesized class. No-op for a non-ObjC class (fall-through).
(def (install-subclass-override! name objc-sel user-proc)
  (let (rec (hash-get *subclass-registry* name))
    (when (and rec (vector-ref rec 0))
      (let* ((cls       (vector-ref rec 0))
             (super     (vector-ref rec 1))
             (super-cls (objc-get-class super))
             (m         (and (not (ptr-null? super-cls))
                             (class-get-instance-method super-cls (sel-register objc-sel))))
             (real-enc  (and m (not (ptr-null? m)) (method-type-encoding m))))
        (let-values (((ret-tok param-toks)
                      (if real-enc (parse-encoding real-enc) (values 'void '()))))
          (register-imp-closure! cls objc-sel
                                 (make-override-closure user-proc param-toks ret-tok))
          (class-add-method cls objc-sel
                            (or real-enc (encode-signature ret-tok param-toks))
                            (return-kind-int ret-tok)))))))

;; --- super-dispatch ("call super then extend") -----------------------------
;; Send `objc-sel` to `self` starting method lookup at the synthesized class's
;; ObjC superclass (the bound class being extended). Argument-passing super-sends
;; are deferred (struct/typed args need per-signature crossings); these cover the
;; common zero-arg void / id chains. `self` is the typed Gerbil instance.
(def (call-super self objc-sel)
  (let* ((p (NSObject-ptr self))
         (super-name (class-get-name (class-get-superclass (object-get-class p)))))
    (msg-super-void p super-name (sel-register objc-sel))))

(def (call-super-id self objc-sel)
  (let* ((p (NSObject-ptr self))
         (super-name (class-get-name (class-get-superclass (object-get-class p)))))
    (wrap-borrowed (msg-super-id p super-name (sel-register objc-sel)))))

;; --- the shadowing forms ---------------------------------------------------
;; `(defclass (Sub Super) (extra-slot …) opt …)` — synthesize an ObjC subclass of
;; `Super` (when ObjC-backed) AND define the real Gerbil class (so `Sub?`,
;; `Sub-extra-slot`, the `ptr` slot inherited from the runtime `NSObject` root,
;; and the keyword constructor all exist). `(symbol->string 'Super)` is the ObjC
;; class name (Gerbil class id == ObjC name, by the emitter convention). Any other
;; shape (no superclass, multiple superclasses) falls through to the built-in.
(defsyntax (defclass stx)
  (syntax-case stx ()
    ((_ (sub super) (slot ...) opt ...)
     (and (identifier? #'sub) (identifier? #'super))
     (with-syntax ((make-sub (stx-identifier #'sub "make-" #'sub)))
       #'(begin
           (%defclass (sub super) (slot ...) transparent: #t opt ...)
           (register-objc-subclass! 'sub (symbol->string 'super)
                                    (lambda (p) (make-sub ptr: p))))))
    ((_ . rest) #'(%defclass . rest))))

;; `(defmethod (Sub "objcSelector:") (self arg …) body …)` — install an override
;; routing the ObjC selector's framework callbacks into this body (self = the
;; typed Gerbil instance; `arg …` = the DELIVERABLE args only — omit struct/float
;; args, which the generic trampoline cannot carry). Any other shape (`{sel Cls}`
;; built-in MOP method, etc.) falls through to the built-in `defmethod`.
(defsyntax (defmethod stx)
  (syntax-case stx ()
    ((_ (sub sel) (self arg ...) body ...)
     (and (identifier? #'sub) (string? (stx-e #'sel)))
     #'(install-subclass-override! 'sub sel (lambda (self arg ...) body ...)))
    ((_ . rest) #'(%defmethod . rest))))

;; `(new Sub)` — alloc+init a synthesized-subclass instance (extra slots take
;; their defaults; set them via accessors / an override afterward).
(defsyntax (new stx)
  (syntax-case stx ()
    ((_ sub) (identifier? #'sub) #'(make-subclass-instance 'sub))))
