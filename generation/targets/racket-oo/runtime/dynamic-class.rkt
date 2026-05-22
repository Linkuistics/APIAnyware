#lang racket/base
;; dynamic-class.rkt — Curated libobjc bridge for runtime subclass construction
;;
;; Exposes the minimal libobjc surface needed to define ObjC subclasses at
;; Racket runtime — useful when an app must override an ObjC method (e.g. a
;; window-class hook like canBecomeKeyWindow) without writing Swift.
;;
;; libobjc lives in dyld's shared cache and resolves without an explicit
;; path. This module has no Racket-side dependencies beyond ffi/unsafe, so
;; it can be required at any point in the load order.
;;
;; ABI rules baked into the API contract:
;;   - allocate-subclass returns an UN-registered Class. Methods may only
;;     be added before register-subclass! is called; the runtime forbids
;;     class_addMethod after registration.
;;   - Class names share a single global namespace. objc_allocateClassPair
;;     returns NULL for a duplicate name — make-dynamic-subclass guards
;;     against this by returning an existing class with the requested name
;;     instead of re-allocating, so the bridge is idempotent across module
;;     reloads.
;;   - IMPs are _fpointer values produced by `function-ptr` from a Racket
;;     proc. The proc itself must be held by a module-level binding (not a
;;     closure-captured local) to prevent GC of the underlying _cprocedure.
;;
;; Curated API:
;;
;;   (objc-get-class name)
;;     Look up an existing ObjC class by name. Returns the Class pointer or
;;     #f if no class with that name is registered.
;;
;;   (allocate-subclass superclass new-name [extra-bytes 0])
;;     Allocate (but not yet register) a new subclass. Returns a Class
;;     pointer. Errors if allocation fails (typically because new-name is
;;     already taken).
;;
;;   (add-method! cls selector imp type-encoding)
;;     Attach `imp` (an _fpointer wrapping a Racket _cprocedure) to `cls`
;;     under `selector`. `type-encoding` is the ObjC type-encoding string
;;     for the method signature, e.g. "B@:" for BOOL (id, SEL).
;;     Returns #t on success.
;;
;;   (register-subclass! cls)
;;     Finalize a class allocated by allocate-subclass. Must be called
;;     exactly once, after all methods have been added.
;;
;;   (get-instance-method cls selector)
;;     Returns the Method pointer for `selector` on `cls` (searching
;;     superclasses), or #f if the selector is not implemented.
;;
;;   (method-type-encoding method)
;;     Returns the ObjC type-encoding string for a Method pointer. Useful
;;     for discovering the encoding of an inherited method when overriding.
;;
;;   (make-dynamic-subclass superclass-name new-name method-specs)
;;     Convenience wrapper: chains the three libobjc calls in the correct
;;     order. method-specs is a list of (list selector imp type-encoding).
;;     Returns the registered Class pointer. Idempotent: returns an existing
;;     class with the requested name without re-allocating.
;;
;; Reference consumer:
;;   - apps/drawing-canvas/drawing-canvas.rkt subclasses NSView via
;;     make-dynamic-subclass, overriding drawRect: and the mouse-event
;;     methods to bridge Cocoa event handling into Racket-level state.

(require ffi/unsafe)

(provide _Class
         _SEL
         _Method
         _IMP
         objc-get-class
         allocate-subclass
         add-method!
         register-subclass!
         get-instance-method
         method-type-encoding
         make-dynamic-subclass)

;; ─── Opaque type aliases ────────────────────────────────────
;; ObjC runtime types are all opaque pointers at the C ABI level. Aliasing
;; them gives consumers a documentation-grade type at call sites that build
;; raw objc_msgSend wrappers, without changing FFI behavior.

(define _Class _pointer)
(define _SEL _pointer)
(define _Method _pointer)
(define _IMP _fpointer)

;; ─── libobjc handle ─────────────────────────────────────────

(define libobjc (ffi-lib "libobjc"))

;; ─── Raw libobjc bindings ───────────────────────────────────

(define objc_getClass-raw
  (get-ffi-obj "objc_getClass" libobjc
    (_fun _string -> _pointer)))

(define objc_allocateClassPair-raw
  (get-ffi-obj "objc_allocateClassPair" libobjc
    (_fun _pointer _string _uint64 -> _pointer)))

(define class_addMethod-raw
  (get-ffi-obj "class_addMethod" libobjc
    (_fun _pointer _pointer _fpointer _string -> _bool)))

(define objc_registerClassPair-raw
  (get-ffi-obj "objc_registerClassPair" libobjc
    (_fun _pointer -> _void)))

(define sel_registerName-raw
  (get-ffi-obj "sel_registerName" libobjc
    (_fun _string -> _pointer)))

(define class_getInstanceMethod-raw
  (get-ffi-obj "class_getInstanceMethod" libobjc
    (_fun _pointer _pointer -> _pointer)))

(define method_getTypeEncoding-raw
  (get-ffi-obj "method_getTypeEncoding" libobjc
    (_fun _pointer -> _string)))

;; ─── Public API ─────────────────────────────────────────────

(define (null-pointer? p)
  (or (not p) (ptr-equal? p #f)))

(define (objc-get-class name)
  (define cls (objc_getClass-raw name))
  (if (null-pointer? cls) #f cls))

(define (allocate-subclass superclass new-name [extra-bytes 0])
  (define cls (objc_allocateClassPair-raw superclass new-name extra-bytes))
  (when (null-pointer? cls)
    (error 'allocate-subclass
           "objc_allocateClassPair returned NULL for ~a (name already taken?)"
           new-name))
  cls)

(define (add-method! cls selector imp type-encoding)
  (class_addMethod-raw cls (sel_registerName-raw selector) imp type-encoding))

(define (register-subclass! cls)
  (objc_registerClassPair-raw cls))

(define (get-instance-method cls selector)
  (define m (class_getInstanceMethod-raw cls (sel_registerName-raw selector)))
  (if (null-pointer? m) #f m))

(define (method-type-encoding method)
  (method_getTypeEncoding-raw method))

;; (make-dynamic-subclass superclass-name new-name method-specs) → Class
;; Convenience: looks up the superclass by name, allocates a subclass,
;; attaches each method, and registers the class — in the correct order.
;;
;; method-specs is a list of three-element lists:
;;   (list selector-string imp-fpointer type-encoding-string)
;;
;; Idempotent: if a class with new-name is already registered (e.g. on
;; module reload during development), returns the existing class without
;; re-allocating. This avoids the NULL-from-objc_allocateClassPair trap
;; that would otherwise fire on the second call.
(define (make-dynamic-subclass superclass-name new-name method-specs)
  (define existing (objc-get-class new-name))
  (cond
    [existing existing]
    [else
     (define superclass
       (or (objc-get-class superclass-name)
           (error 'make-dynamic-subclass
                  "superclass not found: ~a" superclass-name)))
     (define cls (allocate-subclass superclass new-name))
     (for ([spec (in-list method-specs)])
       (define selector (list-ref spec 0))
       (define imp (list-ref spec 1))
       (define type-encoding (list-ref spec 2))
       (unless (add-method! cls selector imp type-encoding)
         (error 'make-dynamic-subclass
                "class_addMethod failed for ~a on ~a" selector new-name)))
     (register-subclass! cls)
     cls]))
