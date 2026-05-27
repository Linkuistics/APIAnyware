;; runtime/dispatch.sls — chez target Scheme→ObjC trampolines.
;;
;; Three sub-machineries share one substrate: `foreign-callable` exposes a
;; Scheme procedure as a C function pointer, `lock-object` keeps that code
;; alive across the boundary, and every callable body wraps in
;; `with-autorelease-pool` so transient +0 returns drain before the call
;; unwinds (ADR-0007).
;;
;;   1. Block bridge — `make-objc-block` / `free-objc-block` /
;;      `call-with-objc-block`. The Scheme proc is wrapped in a
;;      `foreign-callable` whose entry pointer is handed to
;;      `aw_chez_create_block`; that helper allocates the Block_literal
;;      with `_NSConcreteGlobalBlock` isa and `BLOCK_HAS_COPY_DISPOSE`,
;;      and (on arm64e) PAC-signs the invoke pointer.
;;
;;      During the 030..060 bring-up the loader borrows
;;      `libAPIAnywareRacket.dylib` (see runtime/ffi.sls), so we call the
;;      racket-flavoured entry points by their as-shipped names —
;;      `aw_racket_create_block` and friends. The block ABI does not
;;      depend on the callable's source language; only the symbol names
;;      flip when leaf 060 produces `libAPIAnywareChez.dylib` with
;;      `aw_chez_*` aliases.
;;
;;   2. Delegate bridge — `make-delegate` / `set-delegate-method` /
;;      `free-delegate`. The Swift dylib's `aw_racket_register_delegate`
;;      builds a per-instance dispatch table behind a generic IMP
;;      trampoline that strips self/_cmd and forwards to our callback.
;;      Our `foreign-callable` therefore takes ONLY the method args, not
;;      self/_cmd. Return type is encoded as one of "void"/"bool"/
;;      "id"/"int"/"long" (the trampoline variants Swift defines).
;;
;;   3. Dynamic-class bridge — `allocate-subclass` / `add-method!` /
;;      `register-subclass!` / `make-dynamic-subclass`. Wraps the
;;      libobjc surface from (apianyware runtime ffi). IMPs ARE the
;;      foreign-callable pointers directly (no Swift trampoline), so the
;;      callable signature must include self and _cmd as the first two
;;      `void*` args. The Scheme proc that backs the IMP receives the
;;      full `(self _cmd arg ...)` tuple, matching the racket
;;      `make-dynamic-subclass` consumer convention.
;;
;; Across all three, the GC-prevention story is the same: the locked
;; foreign-callable `code` object is stashed in the returned record, and
;; `free-*` calls `unlock-object` so chez can collect it. The Swift dylib
;; additionally tracks block refcounts (copy/dispose helpers) and
;; per-delegate GC handles via `preventGC`/`allowGC`; we let it own those
;; — our side only has to keep the chez code object alive while the
;; entry pointer is referenced by the C side.

(library (apianyware runtime dispatch)
  (export
    ;; Block bridge
    objc-block? objc-block-ptr
    make-objc-block free-objc-block call-with-objc-block
    ;; Delegate bridge
    delegate? delegate-ptr
    make-delegate set-delegate-method free-delegate
    ;; Dynamic-class bridge
    allocate-subclass add-method! register-subclass!
    make-dynamic-subclass)
  (import (chezscheme)
          (apianyware runtime ffi)
          (apianyware runtime objc))

  ;; --- Dylib surface ---------------------------------------------------
  ;;
  ;; These are exposed as `aw_racket_*` in `libAPIAnywareRacket.dylib`
  ;; today. Leaf 060 ships `libAPIAnywareChez.dylib` with `aw_chez_*`
  ;; aliases pointing at the same symbols; until then, the racket names
  ;; are the only ones the loader resolves.

  (define aw-create-block
    (foreign-procedure "aw_racket_create_block" (void*) void*))

  (define aw-release-block
    (foreign-procedure "aw_racket_release_block" (void*) void))

  (define aw-register-delegate
    ;; (selectors[], return-types[], count) -> instance
    (foreign-procedure "aw_racket_register_delegate"
                       (void* void* int) void*))

  (define aw-set-method
    ;; (instance, selector-cstring, callback-fp-or-null) -> void
    (foreign-procedure "aw_racket_set_method"
                       (void* string void*) void))

  (define aw-free-delegate
    (foreign-procedure "aw_racket_free_delegate" (void*) void))

  ;; --- foreign-callable construction -----------------------------------
  ;;
  ;; `foreign-callable` is syntax: its parameter and result types must be
  ;; literal tokens. To support the arbitrary signatures the three
  ;; bridges produce, we build the form with `quasiquote` and run it
  ;; through `eval`. Eval needs an environment in which the form's free
  ;; identifiers resolve — and chez's `(environment '(lib) ...)`
  ;; produces an *immutable snapshot* that does not see top-level
  ;; bindings we set later. The mutable env is `(interaction-environment)`.
  ;;
  ;; Strategy:
  ;;   - Per-callable state (the user proc, the type-appropriate default
  ;;     return value used on error) lives in a library-private
  ;;     hashtable indexed by integer id.
  ;;   - Helpers the eval'd body needs (the lookup, the
  ;;     autoreleasepool push/pop, the guardian drain, condition
  ;;     display) are installed once into the interaction-environment
  ;;     at library invoke time under `%aw-chez-*` names.
  ;;   - The eval'd `foreign-callable` body bakes the id in as a
  ;;     literal and calls through the helpers — so the form's only
  ;;     free identifiers are chezscheme builtins and our `%aw-chez-*`
  ;;     helpers, all of which the script's interaction-environment
  ;;     resolves.
  ;;
  ;; Callable behaviour: every callable wraps its body in an
  ;; autoreleasepool push/pop + guardian drain (the with-autorelease-pool
  ;; expansion inlined into the eval'd form's body), so transient +0
  ;; objects from inside the call drain before control returns to C.
  ;; Errors in the user proc are trapped with `guard` and replaced by
  ;; the stored default so a Scheme bug doesn't propagate as an
  ;; unhandled C exception (which would abort the process).
  ;; display-condition prints the cause to (current-error-port) for
  ;; debuggability — sample-app authors who want different recovery
  ;; install their own exception handler around the entry point.

  (define %callable-table (make-eqv-hashtable))
  (define %callable-counter 0)

  (define (%callable-register! proc default)
    (let ([id %callable-counter])
      (set! %callable-counter (+ id 1))
      (hashtable-set! %callable-table id (cons proc default))
      id))

  (define (%callable-unregister! id)
    (hashtable-delete! %callable-table id))

  (define (%callable-invoke id args)
    (let ([entry (hashtable-ref %callable-table id #f)])
      (let ([pool (objc_autoreleasePoolPush)])
        (call-with-values
          (lambda ()
            (guard (c [#t
                       (let ([p (current-error-port)])
                         (display "[chez dispatch] callable raised: " p)
                         (display-condition c p)
                         (newline p))
                       (cdr entry)])
              (apply (car entry) args)))
          (lambda vs
            (objc_autoreleasePoolPop pool)
            (drain-objc-guardian)
            (apply values vs))))))

  ;; Install %aw-chez-callable-invoke in the interaction-environment so
  ;; the eval'd foreign-callable body can reach it. Bundled inside a
  ;; dummy `define` RHS to satisfy chez's library-body rule that all
  ;; definitions precede all expressions.
  (define %helpers-installed
    (begin
      (set-top-level-value! '%aw-chez-callable-invoke %callable-invoke)
      #t))

  (define (default-value-for-type type-sym)
    (case type-sym
      [(void)                (void)]
      [(boolean)             #f]
      [(int unsigned-int
        int-8 unsigned-8
        int-16 unsigned-16
        int-32 unsigned-32
        int-64 unsigned-64
        long unsigned-long)  0]
      [(double-float)        0.0]
      [(single-float)        0.0]
      [(void* uptr)          0]
      [else                  0]))

  (define-record-type (callable-handle %make-callable-handle callable-handle?)
    (fields code id))

  ;; Build a locked foreign-callable wrapping `proc`. Returns a
  ;; callable-handle record holding the (locked) code object and the
  ;; integer id under which `proc` is registered. Caller uses
  ;; `(foreign-callable-entry-point (callable-handle-code h))` to get the
  ;; C-callable address, and `release-callable!` to tear it down.
  (define (build-callable proc param-type-syms return-type-sym)
    (let* ([default (default-value-for-type return-type-sym)]
           [id      (%callable-register! proc default)]
           [arity   (length param-type-syms)]
           [arg-names
                    (let loop ([i 0])
                      (if (= i arity)
                          '()
                          (cons (string->symbol
                                  (string-append "a" (number->string i)))
                                (loop (+ i 1)))))]
           [form
            `(foreign-callable
               (lambda ,arg-names
                 (%aw-chez-callable-invoke ,id (list ,@arg-names)))
               ,param-type-syms
               ,return-type-sym)]
           [code (eval form (interaction-environment))])
      (lock-object code)
      (%make-callable-handle code id)))

  (define (release-callable! h)
    (unlock-object (callable-handle-code h))
    (%callable-unregister! (callable-handle-id h)))

  ;; --- Block bridge ----------------------------------------------------

  (define-record-type (objc-block %make-objc-block objc-block?)
    (fields
      ptr        ; block-literal pointer (uptr from aw_*_create_block)
      handle     ; callable-handle for the invoke trampoline (or #f)
      freed?-box ; mutable box: #t once free-objc-block has run
      ))

  ;; Build the foreign-callable for a block. Block invoke convention is
  ;; (block-self, arg1, ...); the user's proc receives only (arg1, ...).
  ;;   param-types — list of chez FFI type syms for the user-visible args
  ;;   return-type — chez FFI type sym
  ;; The block-self prefix is added internally.
  (define (build-block-callable proc param-types return-type)
    ;; Wrap the user proc with a stripper that drops the first arg.
    (build-callable
      (lambda args
        (apply proc (cdr args)))
      (cons 'void* param-types)
      return-type))

  ;; Create an ObjC block wrapping a Scheme procedure.
  ;;
  ;;   (make-objc-block proc param-types return-type) → objc-block
  ;;
  ;; param-types: list of chez FFI type symbols for the block's
  ;;              user-visible args (do NOT include the block-self
  ;;              pointer — it is added internally to satisfy the ABI).
  ;; return-type: chez FFI type symbol.
  ;;
  ;; The Swift helper allocates a `_NSConcreteGlobalBlock` with
  ;; `BLOCK_HAS_COPY_DISPOSE` and arm64e PAC-signing. For async APIs
  ;; (completion handlers, GCD), the dispose helper auto-frees the
  ;; Swift-side GC handle once Block_release fires; the chez-side code
  ;; object lives until `free-objc-block` runs. For synchronous APIs
  ;; (enumerate, sort), ObjC does not call Block_copy, so call
  ;; `free-objc-block` explicitly after the method returns.
  ;;
  ;; If proc is #f, returns an objc-block whose ptr is 0 — the ObjC
  ;; "no block" sentinel. `free-objc-block` is a no-op on this case.
  (define (make-objc-block proc param-types return-type)
    (cond
      [(not proc)
       (%make-objc-block 0 #f (box #t))]
      [else
       (let* ([h     (build-block-callable proc param-types return-type)]
              [entry (foreign-callable-entry-point (callable-handle-code h))]
              [blk   (aw-create-block entry)])
         (when (or (not blk) (zero? blk))
           (release-callable! h)
           (error 'make-objc-block "aw_*_create_block returned NULL"))
         (%make-objc-block blk h (box #f)))]))

  ;; Release a block's chez-side code object and (if the dispose helper
  ;; hasn't already fired) the Swift-side GC handle.
  ;;
  ;; Required for synchronous-only block APIs; harmless but optional for
  ;; async APIs. Idempotent: calling twice is safe.
  (define (free-objc-block blk)
    (unless (unbox (objc-block-freed?-box blk))
      (set-box! (objc-block-freed?-box blk) #t)
      (let ([ptr (objc-block-ptr blk)]
            [h   (objc-block-handle blk)])
        (when (and ptr (not (zero? ptr)))
          (aw-release-block ptr))
        (when h (release-callable! h)))))

  ;; Convenience: create a block, hand it to body, free unconditionally.
  ;; Use ONLY for synchronous APIs where the block is guaranteed not to
  ;; outlive the call (e.g. enumerateObjectsUsingBlock:). For async APIs
  ;; the block may be retained past `body`'s return, so manage lifetime
  ;; with `make-objc-block` + `free-objc-block` instead.
  (define (call-with-objc-block proc param-types return-type body)
    (let ([blk (make-objc-block proc param-types return-type)])
      (dynamic-wind
        (lambda () #f)
        (lambda () (body blk))
        (lambda () (free-objc-block blk)))))

  ;; --- Delegate bridge -------------------------------------------------

  (define-record-type (delegate %make-delegate delegate?)
    (fields
      ptr           ; instance pointer from aw_*_register_delegate
      method-table  ; hashtable: selector-string → callable-handle
      freed?-box))

  ;; The Swift trampoline expects one of these return-type tokens.
  (define (return-type->cstring sym)
    (case sym
      [(void)        "void"]
      [(boolean)     "bool"]
      [(void* uptr)  "id"]
      [(int int-32 unsigned-32)
                     "int"]
      [(int-64 unsigned-64 long unsigned-long)
                     "long"]
      [else
       (error 'return-type->cstring
              "unsupported delegate return type (Swift trampoline only \
defines void/bool/id/int/long)" sym)]))

  ;; Allocate a foreign-managed array of C strings from a list of
  ;; Scheme strings. Returns (values array-ptr buf-list); caller must
  ;; `foreign-free` array-ptr and each entry of buf-list when done.
  (define ptr-size 8) ; arm64 / x86_64: void* is 8 bytes.

  (define (alloc-cstring-array strs)
    (let* ([n    (length strs)]
           [arr  (foreign-alloc (* ptr-size n))]
           [bufs (map (lambda (s)
                        (let* ([bv  (string->utf8 s)]
                               [len (bytevector-length bv)]
                               [p   (foreign-alloc (+ 1 len))])
                          (let loop ([i 0])
                            (cond
                              [(= i len)
                               (foreign-set! 'unsigned-8 p i 0)]
                              [else
                               (foreign-set! 'unsigned-8 p i
                                             (bytevector-u8-ref bv i))
                               (loop (+ i 1))]))
                          p))
                      strs)])
      (let loop ([i 0] [bs bufs])
        (cond
          [(null? bs) (void)]
          [else
           (foreign-set! 'uptr arr (* ptr-size i) (car bs))
           (loop (+ i 1) (cdr bs))]))
      (values arr bufs)))

  (define (free-cstring-array arr bufs)
    (foreign-free arr)
    (for-each foreign-free bufs))

  ;; Create a delegate instance.
  ;;
  ;;   (make-delegate method-specs) → delegate
  ;;
  ;; method-specs: list of `(selector proc param-types return-type)`
  ;;   selector    — string (e.g. "windowWillClose:")
  ;;   proc        — procedure; the Swift trampoline strips self and
  ;;                 _cmd, so proc receives ONLY the method args
  ;;                 (e.g. `(lambda (notification) ...)`).
  ;;   param-types — list of chez FFI type syms for the args proc sees
  ;;                 (Swift trampoline always delivers them as void*,
  ;;                 so this is almost always a list of `void*`).
  ;;   return-type — chez FFI type sym; the Swift trampoline must have
  ;;                 a variant matching this — see return-type->cstring.
  ;;
  ;; Important: the delegate's Cocoa-side property is weak — the owning
  ;; object does NOT retain the delegate. Keep the returned record
  ;; reachable for the owner's lifetime, then call `free-delegate`.
  (define (make-delegate method-specs)
    (let* ([n (length method-specs)]
           [selectors    (map (lambda (s) (list-ref s 0)) method-specs)]
           [procs        (map (lambda (s) (list-ref s 1)) method-specs)]
           [param-types* (map (lambda (s) (list-ref s 2)) method-specs)]
           [return-types (map (lambda (s) (list-ref s 3)) method-specs)]
           [ret-strings  (map return-type->cstring return-types)])
      (let-values ([(sels-arr sels-bufs)
                    (alloc-cstring-array selectors)]
                   [(rets-arr rets-bufs)
                    (alloc-cstring-array ret-strings)])
        (let ([inst (aw-register-delegate sels-arr rets-arr n)])
          (free-cstring-array sels-arr sels-bufs)
          (free-cstring-array rets-arr rets-bufs)
          (when (or (not inst) (zero? inst))
            (error 'make-delegate
                   "aw_*_register_delegate returned NULL"))
          (let ([table (make-hashtable string-hash string=?)])
            (let loop ([sels selectors]
                       [ps procs]
                       [pts param-types*]
                       [rts return-types])
              (cond
                [(null? sels) (void)]
                [else
                 (let* ([sel   (car sels)]
                        [h     (build-callable
                                 (car ps) (car pts) (car rts))]
                        [entry (foreign-callable-entry-point
                                 (callable-handle-code h))])
                   (aw-set-method inst sel entry)
                   (hashtable-set! table sel h))
                 (loop (cdr sels) (cdr ps)
                       (cdr pts) (cdr rts))]))
            (%make-delegate inst table (box #f)))))))

  ;; Replace the handler for an existing selector on a live delegate,
  ;; or install a handler for a new selector that was not in the
  ;; original `make-delegate` spec.
  ;;
  ;; If a previous handler exists for that selector, its code object is
  ;; unlocked so chez can collect it.
  (define (set-delegate-method d selector proc param-types return-type)
    (let* ([table (delegate-method-table d)]
           [prev  (hashtable-ref table selector #f)]
           [h     (build-callable proc param-types return-type)]
           [entry (foreign-callable-entry-point (callable-handle-code h))])
      (aw-set-method (delegate-ptr d) selector entry)
      (hashtable-set! table selector h)
      (when prev (release-callable! prev))))

  ;; Release a delegate's chez-side resources. After this:
  ;;   - The Swift dispatch table entry is removed (method calls return
  ;;     the default for their return type).
  ;;   - All per-selector foreign-callable code objects are unlocked
  ;;     and the hashtable is cleared.
  ;; The owning ObjC object must have dropped its delegate reference
  ;; FIRST (typically `[owner setDelegate:nil]`), otherwise Cocoa may
  ;; still try to invoke a now-defunct delegate and crash.
  ;;
  ;; Idempotent.
  (define (free-delegate d)
    (unless (unbox (delegate-freed?-box d))
      (set-box! (delegate-freed?-box d) #t)
      (aw-free-delegate (delegate-ptr d))
      (let ([table (delegate-method-table d)])
        (vector-for-each
          (lambda (h) (release-callable! h))
          (hashtable-values table))
        (hashtable-clear! table))))

  ;; --- Dynamic-class bridge --------------------------------------------
  ;;
  ;; libobjc surface (declared in (apianyware runtime ffi)):
  ;;   - objc_allocateClassPair (super, name, extra) -> Class
  ;;   - class_addMethod (cls, sel, imp, types) -> bool
  ;;   - objc_registerClassPair (cls) -> void
  ;;
  ;; The libobjc ABI rule that drives this surface: methods may only be
  ;; added BEFORE register-subclass!. After registration, class_addMethod
  ;; silently fails.

  ;; Allocate (but don't register) a new subclass. `parent-class` is the
  ;; Class pointer (e.g. `(objc_getClass "NSObject")`); `name` is the
  ;; subclass's globally-unique name string. Returns the un-registered
  ;; Class pointer. Errors if allocation fails (typically a duplicate
  ;; name).
  (define (allocate-subclass parent-class name)
    (let ([cls (objc_allocateClassPair parent-class name 0)])
      (when (or (not cls) (zero? cls))
        (error 'allocate-subclass
               "objc_allocateClassPair returned NULL (name taken?)"
               name))
      cls))

  ;; Attach an IMP (a foreign-callable entry pointer wrapping a Scheme
  ;; proc) to a Class under `selector`. `type-encoding` is the standard
  ;; ObjC type encoding for the method (e.g. "v@:" for -(void)foo).
  ;; Returns #t on success.
  ;;
  ;; Important: the IMP must remain alive for the lifetime of the class
  ;; (which, for dynamically-allocated classes, is the process). The
  ;; caller manages this — see `make-dynamic-subclass` for the
  ;; reference idiom.
  (define (add-method! cls selector imp-entry type-encoding)
    (class_addMethod cls (sel-register selector) imp-entry type-encoding))

  ;; Finalize a class after all methods have been added. Must be called
  ;; exactly once per allocate-subclass.
  (define (register-subclass! cls)
    (objc_registerClassPair cls))

  ;; Module-level table of locked foreign-callable code objects for
  ;; every IMP attached via `make-dynamic-subclass`. Indexed by Class
  ;; pointer (a uptr). Holds the codes for the process lifetime, which
  ;; matches what libobjc expects: IMP pointers handed to a registered
  ;; class are referenced from the method list forever.
  (define dynamic-class-imps (make-eqv-hashtable))

  ;; Convenience: allocate a subclass, attach a list of methods, and
  ;; register — in the order libobjc requires. Idempotent across
  ;; module reloads: if `name` is already a registered class, returns
  ;; the existing class without re-allocating, mirroring the racket
  ;; `make-dynamic-subclass` contract.
  ;;
  ;;   method-specs: list of (selector proc param-types return-type
  ;;                          type-encoding)
  ;;     selector       — string
  ;;     proc           — procedure receiving (self _cmd arg ...)
  ;;     param-types    — chez FFI type syms for the user args, NOT
  ;;                      including self and _cmd. We prepend
  ;;                      (void* void*) when building the callable.
  ;;     return-type    — chez FFI type sym
  ;;     type-encoding  — ObjC type encoding string. We do not derive
  ;;                      it from the FFI types because complex
  ;;                      encodings (NSRect → "{CGRect={CGPoint=dd}{CGSize=dd}}")
  ;;                      live outside what FFI symbols capture, and
  ;;                      sample apps already carry the encodings they
  ;;                      need from the racket port.
  (define (make-dynamic-subclass parent-class name method-specs)
    (let ([existing (objc_getClass name)])
      (cond
        [(and existing (not (zero? existing))) existing]
        [else
         (let ([cls (allocate-subclass parent-class name)])
           (let ([handles
                  (let loop ([specs method-specs] [acc '()])
                    (cond
                      [(null? specs) (reverse acc)]
                      [else
                       (let* ([spec        (car specs)]
                              [selector    (list-ref spec 0)]
                              [proc        (list-ref spec 1)]
                              [param-types (list-ref spec 2)]
                              [return-type (list-ref spec 3)]
                              [encoding    (list-ref spec 4)]
                              ;; IMPs receive (self, _cmd, args...)
                              [h (build-callable
                                   proc
                                   (cons* 'void* 'void* param-types)
                                   return-type)]
                              [entry (foreign-callable-entry-point
                                       (callable-handle-code h))])
                         (unless (add-method! cls selector entry encoding)
                           (error 'make-dynamic-subclass
                                  "class_addMethod failed"
                                  name selector))
                         (loop (cdr specs) (cons h acc)))]))])
             (register-subclass! cls)
             (hashtable-set! dynamic-class-imps cls handles)
             cls))]))))
