;;; runtime/native-core.ss — the ObjC native core (ADR-0017 §6).
;;;
;;; The two callback bridges (`make-delegate`, `make-objc-block`, both defined a
;;; layer up in `objc.ss`) and 030's subclass synthesis all need ONE thing the
;;; data plane cannot give: a way for ObjC — an IMP the runtime installs, or a
;;; block the framework invokes — to call BACK into a Gerbil procedure chosen at
;;; runtime. That is this module. It owns:
;;;
;;;   - the generic C trampolines (Gambit `c-define`, one per return shape) that
;;;     ObjC calls and that re-enter Gerbil;
;;;   - the dispatch tables those trampolines consult (IMP closures keyed by
;;;     (class-address . selector); block closures keyed by an integer id);
;;;   - the `objc_allocateClassPair` / `class_addMethod` / `objc_registerClassPair`
;;;     plumbing (shared with leaf 030's subclass synthesis).
;;;
;;; Toolchain (FINDINGS, leaf 050/020): IMP synthesis is pure `<objc/runtime.h>`,
;;; so THIS unit stays gcc-15 C-safe (no `-x objective-c`). ObjC *block literals*
;;; (`^`) are the one thing gcc-15 cannot parse; they live in the companion
;;; `native_block.c`, compiled separately by `clang -fblocks` and linked in (its
;;; block bodies call the `c-define`d `aw_blk_*` symbols declared `extern` here).
;;; So the whole native core builds without ever feeding `^`/umbrella headers to
;;; gcc-15. See `README.md` "native bridges" + the 060/070 build note.
;;;
;;; ## Why a registry of closures, not direct calls
;;;
;;; A `c-define` body compiles in the raw Gambit namespace, so it can reach a
;;; Gerbil binding only by its FULLY-QUALIFIED mangled name
;;; (`gerbil-bindings/runtime/native-core#…`). That pins two choices: the
;;; trampolines and the Scheme dispatch procs they call MUST live in one module
;;; (stable self-referential prefix); and this module hands `objc.ss` a registry
;;; to populate rather than calling "up" into it — which also breaks what would
;;; otherwise be an import cycle (`objc.ss` needs the bridges; the bridges need
;;; `wrap`/`->ptr`). Everything here deals only in raw pointers + opaque closures.
;;;
;;; ## Generic-trampoline arg model (and its known gaps)
;;;
;;; `c-define` fixes a C signature, so one trampoline cannot have per-selector
;;; arity. Each trampoline therefore takes a FIXED maximum of pointer-width args
;;; (IMP: self,_cmd + 4; block: id + 3) and the registered closure uses only the
;;; first k it declared — exactly the racket/Swift `DelegateBridge` shape. On
;;; arm64 reading the unused argument registers is benign. Consequence: object /
;;; integer / bool / C-string args ride through fine (pointer-width, integer
;;; registers); **`float`/`double` args (FP registers) and by-value structs are
;;; NOT delivered by this model** — the marshalling layer (`objc.ss`) rejects
;;; those tokens rather than pass garbage. Lifting that is a later concern.

(import :std/foreign
        :gerbil-bindings/runtime/ffi)

(export allocate-class-pair register-class-pair class-add-method
        class-new-instance
        register-imp-closure! make-block register-block-closure! next-block-id!
        ;; return-kind tags shared with objc.ss (keep the int encoding in sync
        ;; with the C `switch`es below)
        kind-void kind-id kind-bool kind-long)

;; --- return-kind encoding (Scheme symbol → the int the C switches read) -----
;; objc.ss maps an FFI token to one of these; `class-add-method` / `make-block`
;; pass the int on to pick the matching `c-define`d trampoline.
(def kind-void 0)
(def kind-id   1)
(def kind-bool 2)
(def kind-long 3)

;; --- dispatch tables --------------------------------------------------------
;; IMP closures keyed by (class-address . selector-string); one synthesized
;; class's selectors all live here, shared across its instances (so 030's
;; subclass overrides — many instances, one class — key the same way a delegate
;; does). Block closures keyed by the integer id captured in the block struct.
(def *imp-table* (make-hash-table))
(def *block-table* (make-hash-table))
(def *block-counter* 0)

(def (register-imp-closure! class-ptr sel-name closure)
  (hash-put! *imp-table* (cons (ptr->int class-ptr) sel-name) closure))
(def (register-block-closure! id closure)
  (hash-put! *block-table* id closure))
(def (next-block-id!)
  (let (id *block-counter*) (set! *block-counter* (##fx+ id 1)) id))

;; The IMP trampoline has only (self,_cmd); recover the class + selector to key.
(def (imp-lookup self cmd)
  (hash-get *imp-table*
            (cons (ptr->int (object-get-class self)) (sel-get-name cmd))))

;; --- Scheme dispatch (one per return shape; reached from the c-define bodies
;;     by full namespace) -----------------------------------------------------
;; The registered closure already does input coercion (per its param tokens) and
;; returns the C-ready value for its return kind (a foreign pointer for `id`, a
;; boolean for `bool`, an integer for `long`); these procs just route + supply a
;; benign default when no closure is registered (shouldn't happen post-build).
;;
;; `self` is passed THROUGH to the closure as its leading argument (leaf 050/030):
;; a transparent-subclass override needs the receiver to recover its Gerbil
;; instance from the back-reference table; a delegate closure simply ignores it
;; (its `make-imp-callback-closure` drops the leading self). The block dispatchers
;; below take no self — a block has no receiver.
(def (imp-dispatch-void self cmd a1 a2 a3 a4)
  (let (p (imp-lookup self cmd)) (when p (p self a1 a2 a3 a4))))
(def (imp-dispatch-id self cmd a1 a2 a3 a4)
  (let (p (imp-lookup self cmd)) (if p (p self a1 a2 a3 a4) (null-ptr))))
(def (imp-dispatch-bool self cmd a1 a2 a3 a4)
  (let (p (imp-lookup self cmd)) (if p (p self a1 a2 a3 a4) #f)))
(def (imp-dispatch-long self cmd a1 a2 a3 a4)
  (let (p (imp-lookup self cmd)) (if p (p self a1 a2 a3 a4) 0)))

(def (block-dispatch-void id a1 a2 a3)
  (let (p (hash-get *block-table* id)) (when p (p a1 a2 a3))))
(def (block-dispatch-id id a1 a2 a3)
  (let (p (hash-get *block-table* id)) (if p (p a1 a2 a3) (null-ptr))))
(def (block-dispatch-bool id a1 a2 a3)
  (let (p (hash-get *block-table* id)) (if p (p a1 a2 a3) #f)))
(def (block-dispatch-long id a1 a2 a3)
  (let (p (hash-get *block-table* id)) (if p (p a1 a2 a3) 0)))

;; --- the native core (C-safe: <objc/runtime.h>/<objc/message.h> only) -------
(begin-ffi (allocate-class-pair register-class-pair class-add-method
            class-new-instance make-block)
  (c-declare "#include <objc/runtime.h>")
  (c-declare "#include <objc/message.h>")

  ;; The generic IMP trampolines: (id self, SEL _cmd, id a1..a4). Declared with a
  ;; fixed 4-arg tail; a selector with fewer args simply leaves the upper
  ;; registers unread (see header). One per return shape so the C return type is
  ;; correct for `objc_msgSend`'s ABI; each re-enters the matching Scheme proc.
  (c-define (imp-v self cmd a1 a2 a3 a4)
            ((pointer void) (pointer void) (pointer void)
             (pointer void) (pointer void) (pointer void)) void
            "aw_imp_void" ""
    (gerbil-bindings/runtime/native-core#imp-dispatch-void self cmd a1 a2 a3 a4))
  (c-define (imp-i self cmd a1 a2 a3 a4)
            ((pointer void) (pointer void) (pointer void)
             (pointer void) (pointer void) (pointer void)) (pointer void)
            "aw_imp_id" ""
    (gerbil-bindings/runtime/native-core#imp-dispatch-id self cmd a1 a2 a3 a4))
  (c-define (imp-b self cmd a1 a2 a3 a4)
            ((pointer void) (pointer void) (pointer void)
             (pointer void) (pointer void) (pointer void)) bool
            "aw_imp_bool" ""
    (gerbil-bindings/runtime/native-core#imp-dispatch-bool self cmd a1 a2 a3 a4))
  (c-define (imp-l self cmd a1 a2 a3 a4)
            ((pointer void) (pointer void) (pointer void)
             (pointer void) (pointer void) (pointer void)) long
            "aw_imp_long" ""
    (gerbil-bindings/runtime/native-core#imp-dispatch-long self cmd a1 a2 a3 a4))

  ;; The block dispatchers: (int block-id, id a1..a3). The companion's `^` block
  ;; captures the id and forwards here; these are plain C-safe `c-define`s (no
  ;; `^`), so they compile under gcc-15 in THIS unit.
  (c-define (blk-v id a1 a2 a3)
            (int (pointer void) (pointer void) (pointer void)) void
            "aw_blk_void" ""
    (gerbil-bindings/runtime/native-core#block-dispatch-void id a1 a2 a3))
  (c-define (blk-i id a1 a2 a3)
            (int (pointer void) (pointer void) (pointer void)) (pointer void)
            "aw_blk_id" ""
    (gerbil-bindings/runtime/native-core#block-dispatch-id id a1 a2 a3))
  (c-define (blk-b id a1 a2 a3)
            (int (pointer void) (pointer void) (pointer void)) bool
            "aw_blk_bool" ""
    (gerbil-bindings/runtime/native-core#block-dispatch-bool id a1 a2 a3))
  (c-define (blk-l id a1 a2 a3)
            (int (pointer void) (pointer void) (pointer void)) long
            "aw_blk_long" ""
    (gerbil-bindings/runtime/native-core#block-dispatch-long id a1 a2 a3))

  ;; --- class-pair synthesis (shared with leaf 030) --------------------------
  ;; Returns the new, NOT-yet-registered class (NULL if the name is taken — the
  ;; caller mints unique names). Methods must be added BEFORE registration.
  (define-c-lambda allocate-class-pair (char-string char-string) (pointer void)
    "Class sup = objc_getClass(___arg2);
     ___return((void*)objc_allocateClassPair(sup, ___arg1, 0));")
  (define-c-lambda register-class-pair ((pointer void)) void
    "objc_registerClassPair((Class)___arg1);")
  ;; Install one selector's IMP, choosing the trampoline by return kind. `types`
  ;; is the ObjC @encode signature string (objc.ss builds it from the tokens).
  (define-c-lambda class-add-method ((pointer void) char-string char-string int) bool
    "IMP imp;
     switch (___arg4) {
       case 0:  imp = (IMP)aw_imp_void; break;
       case 1:  imp = (IMP)aw_imp_id;   break;
       case 2:  imp = (IMP)aw_imp_bool; break;
       default: imp = (IMP)aw_imp_long; break;
     }
     ___return(class_addMethod((Class)___arg1, sel_registerName(___arg2), imp, ___arg3));")
  ;; alloc+init a fresh instance of a registered class.
  (define-c-lambda class-new-instance ((pointer void)) (pointer void)
    "id (*send)(id, SEL) = (id (*)(id, SEL))objc_msgSend;
     id o = send((id)___arg1, sel_registerName(\"alloc\"));
     ___return((void*)send(o, sel_registerName(\"init\")));")

  ;; --- block construction (bodies in the clang companion native_block.c) ----
  ;; The companion takes the dispatcher as an opaque fn-pointer (kept self-
  ;; contained so it links cleanly); we hand it the address of OUR own `aw_blk_*`
  ;; `c-define` (same TU — no cross-module symbol), picking maker + dispatcher by
  ;; return kind. Build returns a heap (Block_copy'd) block for the block-id.
  (c-declare "extern void* aw_make_block_void(int, void*);")
  (c-declare "extern void* aw_make_block_id(int, void*);")
  (c-declare "extern void* aw_make_block_bool(int, void*);")
  (c-declare "extern void* aw_make_block_long(int, void*);")
  (define-c-lambda make-block (int int) (pointer void)
    "void* b;
     switch (___arg2) {
       case 0:  b = aw_make_block_void(___arg1, (void*)aw_blk_void); break;
       case 1:  b = aw_make_block_id(___arg1,   (void*)aw_blk_id);   break;
       case 2:  b = aw_make_block_bool(___arg1, (void*)aw_blk_bool); break;
       default: b = aw_make_block_long(___arg1, (void*)aw_blk_long); break;
     }
     ___return(b);"))
