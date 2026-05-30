#lang racket/base
;; delegate.rkt — Create ObjC delegate objects from Racket lambdas
;;
;; When libAPIAnywareRacket.dylib is available, uses aw_racket_register_delegate
;; and aw_racket_set_method for delegate creation and dispatch. The Swift helper
;; handles ObjC class creation, IMP trampolines, and dispatch table management.
;;
;; Falls back to pure-Racket delegate creation when the dylib is absent.
;;
;; IMPORTANT: Cocoa delegate properties are weak — the owning object does NOT
;; retain its delegate. The Racket code must keep a reference to the delegate
;; for as long as it is set on an owner. If the delegate reference is dropped,
;; the GC may collect the callbacks, causing a crash.
;;
;; Usage:
;;   (define my-delegate
;;     (make-delegate
;;       "windowWillClose:"    (lambda (notif) (displayln "closing!"))
;;       "windowShouldClose:"  (lambda (sender) #t)
;;       "windowDidResize:"    (lambda (notif) (displayln "resized!"))))
;;   (tell window setDelegate: my-delegate)
;;   ;; Keep my-delegate reachable for the window's lifetime!
;;   ;; When done: (tell window setDelegate: #f) then (free-delegate my-delegate)

(require ffi/unsafe
         ffi/unsafe/objc
         racket/string
         racket/list
         "swift-helpers.rkt"
         "objc-base.rkt")

(provide make-delegate
         delegate-set!
         delegate-remove!
         free-delegate
         delegate-class-count)

;; --- Return type detection (shared by both implementations) ---

;; Determine return kind from the selector name.
;; Selectors starting with "should"/"can"/"validate" return bool.
;; Selectors starting with "willReturn"/"willUse" return id.
;; Everything else returns void.
(define (guess-return-kind sel)
  (define first-kw (car (string-split sel ":")))
  (cond
    [(regexp-match? #rx"^(should|canDrag|canPerform|validate|acceptDrop|writeRows|shouldSelect|shouldEdit|shouldBegin|shouldType)" first-kw)
     'bool]
    [(regexp-match? #rx"Should" sel) 'bool]
    [(regexp-match? #rx"willReturn|willUse|^customWindows" first-kw) 'id]
    [else 'void]))

;; Count colons in a selector to determine param count
(define (selector-param-count sel)
  (for/sum ([c (in-string sel)])
    (if (char=? c #\:) 1 0)))

;; Convert symbol return kind to the string the Swift API expects.
;; Supported kinds:
;;   void → no return
;;   bool → C BOOL (Racket _bool)
;;   id   → ObjC object pointer (Racket _pointer)
;;   int  → C int32 (Racket _int32) — for headers declaring plain `int`
;;   long → C int64 / NSInteger (Racket _int64) — preferred over the
;;          historical pointer-smuggle for delegate methods returning
;;          NSInteger such as -numberOfRowsInTableView:
(define (return-kind->string kind)
  (case kind
    [(void) "void"]
    [(bool) "bool"]
    [(id)   "id"]
    [(int)  "int"]
    [(long) "long"]
    [else   "void"]))

;; --- Param-type coercion for delegate callback args ---

;; Coerce a single callback arg based on its declared param-type symbol.
;; Called by the trampoline wrapper before passing args to the user's handler.
;;
;; The Swift/Racket trampoline delivers ALL params as _pointer. Coercion
;; reinterprets the bits according to the declared IR type:
;;   'object  → borrow-objc-object (no retain, satisfies objc-object? contract)
;;   'long    → cast _pointer → _int64 (same width on 64-bit, lossless)
;;   'int     → cast _pointer → _int32 (truncates upper 32 bits)
;;   'bool    → null-pointer test (#f → #f, non-null → #t)
;;   'pointer → identity (raw _pointer, no wrapping)
;;   else     → identity (unknown type, pass through)
(define (coerce-callback-arg type-sym raw-arg)
  (case type-sym
    [(object)  (borrow-objc-object raw-arg)]
    [(long)    (cast raw-arg _pointer _int64)]
    [(int)     (cast raw-arg _pointer _int32)]
    [(bool)    (and raw-arg (not (ptr-equal? raw-arg #f)))]
    [else raw-arg]))

;; Wrap a handler with param-type coercion. If param-types is #f or empty,
;; return the handler unchanged. Otherwise, coerce each arg positionally.
(define (wrap-handler-with-param-types handler param-types)
  (if (or (not param-types) (null? param-types))
      handler
      (lambda args
        (define coerced
          (for/list ([arg (in-list args)]
                     [type-sym (in-list param-types)]
                     [_i (in-naturals)])
            (coerce-callback-arg type-sym arg)))
        ;; Pass any extra args beyond param-types unchanged
        (define extra (if (> (length args) (length param-types))
                         (drop args (length param-types))
                         '()))
        (apply handler (append coerced extra)))))

;; --- Swift-backed implementation ---

;; GC prevention for Swift delegate callbacks.
;; Maps delegate-key → list of (callback gc-handle callback-proc) entries.
(define swift-gc-handles (make-hash))

;; Return type tracking for Swift delegates.
;; Maps delegate-key → hash(selector → return-kind symbol).
;; Used by delegate-set! to create callbacks with the correct return type.
(define swift-delegate-ret-types (make-hash))

;; Param-type tracking for all delegates (shared by Swift and Racket paths).
;; Maps delegate-key → hash(selector → (listof symbol)).
;; Used by delegate-set! to wrap new handlers with the same coercion.
(define delegate-param-types (make-hash))

(define (make-delegate/swift return-types handlers-alist)
  (define selectors (map car handlers-alist))
  (define ret-kinds (map (lambda (p)
                           (hash-ref return-types (car p)
                                     (guess-return-kind (car p))))
                         handlers-alist))
  (define ret-strings (map return-kind->string ret-kinds))

  ;; Create the delegate via Swift helper
  (define instance
    (swift:register-delegate selectors ret-strings (length selectors)))
  (unless instance
    (error 'make-delegate "Swift register-delegate failed"))

  ;; Register each handler
  (define instance-key (cast instance _pointer _intptr))
  (define gc-entries '())

  ;; Store return types for delegate-set! to use later
  (define ret-type-map (make-hash))
  (for ([sel (in-list selectors)]
        [kind (in-list ret-kinds)])
    (hash-set! ret-type-map sel kind))
  (hash-set! swift-delegate-ret-types instance-key ret-type-map)

  (for ([pair (in-list handlers-alist)])
    (define sel (car pair))
    (define handler (cdr pair))
    (define n-params (selector-param-count sel))
    (define ret-kind (hash-ref return-types sel (guess-return-kind sel)))

    ;; Create C callback for this handler.
    ;; The Swift trampoline calls our callback with just the method args
    ;; (self and _cmd are stripped by the trampoline).
    (define param-types (make-list n-params _pointer))
    (define ret-type
      (case ret-kind
        [(void) _void]
        [(bool) _bool]
        [(id)   _pointer]
        [(int)  _int32]
        [(long) _int64]
        [else   _void]))

    (define default-ret
      (case ret-kind
        [(void) (void)]
        [(bool) #f]
        [(id)   #f]
        [(int)  0]
        [(long) 0]
        [else   (void)]))

    ;; Wrap: apply handler with correct arity, return default if handler fails
    (define callback-proc
      (lambda args
        (apply handler (take args (min (length args) n-params)))))

    (define callback-ctype (_cprocedure param-types ret-type))
    (define callback-fptr (function-ptr callback-proc callback-ctype))

    ;; Register with Swift dispatch table
    (swift:set-method instance sel callback-fptr)

    ;; Prevent GC of the Racket callback
    (define gc-handle (swift:prevent-gc callback-fptr))
    (set! gc-entries (cons (list callback-fptr gc-handle callback-proc) gc-entries)))

  ;; Store GC prevention data
  (hash-set! swift-gc-handles instance-key gc-entries)

  ;; Return as _id for compatibility with `tell`
  (cast instance _pointer _id))

;; --- Pure-Racket implementation (fallback) ---

(define objc-lib (ffi-lib "libobjc"))

(define objc_allocateClassPair
  (get-ffi-obj "objc_allocateClassPair" objc-lib
    (_fun _pointer _string _uint64 -> _pointer)))

(define class_addMethod
  (get-ffi-obj "class_addMethod" objc-lib
    (_fun _pointer _pointer _fpointer _string -> _bool)))

(define objc_registerClassPair
  (get-ffi-obj "objc_registerClassPair" objc-lib
    (_fun _pointer -> _void)))

(define objc_getClass
  (get-ffi-obj "objc_getClass" objc-lib
    (_fun _string -> _pointer)))

(define objc_msgSend-alloc
  (get-ffi-obj "objc_msgSend" objc-lib
    (_fun _pointer _pointer -> _pointer)))

(define objc_msgSend-init
  (get-ffi-obj "objc_msgSend" objc-lib
    (_fun _pointer _pointer -> _pointer)))

(define NSObject-class (objc_getClass "NSObject"))

;; Dispatch table and class cache for fallback mode.
(define dispatch-table (make-hash))
(define class-counter 0)
(define class-cache (make-hash))

(define (type-encoding-void n-params)
  (string-append "v@:" (make-string n-params #\@)))

(define (type-encoding-bool n-params)
  (string-append "B@:" (make-string n-params #\@)))

(define (type-encoding-id n-params)
  (string-append "@@:" (make-string n-params #\@)))

;; "i" = C int32. "q" = C int64; NSInteger on 64-bit Apple platforms is
;; typedef'd to `long` and clang encodes it as "q", so the long branch
;; covers the NSInteger case used by NSTableViewDataSource etc.
(define (type-encoding-int n-params)
  (string-append "i@:" (make-string n-params #\@)))

(define (type-encoding-long n-params)
  (string-append "q@:" (make-string n-params #\@)))

(define (get-or-create-delegate-class method-sigs)
  (define cache-key
    (sort method-sigs string<? #:key car))
  (define cached (hash-ref class-cache cache-key #f))
  (if cached
      (car cached)
      (let ()
        (define name (format "APIAnywareDelegate~a" class-counter))
        (set! class-counter (add1 class-counter))

        (define cls (objc_allocateClassPair NSObject-class name 0))
        (unless cls
          (error 'make-delegate "failed to create ObjC class ~a" name))

        (define imps '())

        (for ([sig (in-list method-sigs)])
          (define sel-str (car sig))
          (define ret-kind (cdr sig))
          (define n-params (selector-param-count sel-str))
          (define sel (sel_registerName sel-str))

          (define all-param-types
            (make-list (+ 2 n-params) _pointer))

          (define ret-type
            (case ret-kind
              [(void) _void]
              [(bool) _bool]
              [(id)   _pointer]
              [(int)  _int32]
              [(long) _int64]
              [else   _void]))

          (define default-ret
            (case ret-kind
              [(void) (void)]
              [(bool) #f]
              [(id)   #f]
              [(int)  0]
              [(long) 0]
              [else   (void)]))

          (define imp-proc
            (lambda args
              (define self-ptr (car args))
              (define method-args (cddr args))
              (define key (cast self-ptr _pointer _intptr))
              (define handlers (hash-ref dispatch-table key #hash()))
              (define handler (hash-ref handlers sel-str #f))
              (if handler
                  (apply handler method-args)
                  default-ret)))

          (define imp-ctype (_cprocedure all-param-types ret-type))
          (define imp-fptr (function-ptr imp-proc imp-ctype))
          (set! imps (cons imp-fptr imps))

          (define encoding
            (case ret-kind
              [(void) (type-encoding-void n-params)]
              [(bool) (type-encoding-bool n-params)]
              [(id)   (type-encoding-id n-params)]
              [(int)  (type-encoding-int n-params)]
              [(long) (type-encoding-long n-params)]
              [else   (type-encoding-void n-params)]))

          (class_addMethod cls sel imp-fptr encoding))

        (objc_registerClassPair cls)
        (hash-set! class-cache cache-key (list cls imps))
        cls)))

(define (make-delegate/racket return-types handlers-alist)
  (define method-sigs
    (map (lambda (pair)
           (define sel (car pair))
           (define ret-kind (hash-ref return-types sel (guess-return-kind sel)))
           (cons sel ret-kind))
         handlers-alist))

  (define cls (get-or-create-delegate-class method-sigs))

  (define raw-instance
    (objc_msgSend-init
     (objc_msgSend-alloc cls (sel_registerName "alloc"))
     (sel_registerName "init")))
  (define instance (cast raw-instance _pointer _id))

  (define key (cast raw-instance _pointer _intptr))
  (define handlers-hash (make-hash))
  (for ([pair (in-list handlers-alist)])
    (hash-set! handlers-hash (car pair) (cdr pair)))
  (hash-set! dispatch-table key handlers-hash)

  instance)

;; --- Public API ---

;; Create a delegate instance.
;;
;; Arguments: alternating selector-string and handler-procedure pairs.
;; Optional keyword args:
;;   #:return-types — hash of selector -> 'void/'bool/'id/'int/'long
;;                    (overrides auto-detection)
;;   #:param-types  — hash of selector -> (listof symbol) describing each
;;                    callback parameter's type. Supported type symbols:
;;                      'object  — auto-wrap via borrow-objc-object
;;                      'bool    — pass through (trampoline delivers _bool)
;;                      'int     — pass through (trampoline delivers _int32)
;;                      'long    — pass through (trampoline delivers _int64)
;;                      'pointer — pass through (raw _pointer)
;;                    When provided, the trampoline auto-coerces callback args
;;                    so handlers receive wrapped objects instead of raw pointers.
;;
;; Returns: an ObjC object pointer (pass to setDelegate: etc.)
(define (make-delegate #:return-types [return-types #hash()]
                       #:param-types  [param-types  #hash()]
                       . args)
  (unless (even? (length args))
    (error 'make-delegate "expected alternating selector handler pairs"))

  ;; Parse into alist, wrapping handlers with param-type coercion
  (define handlers-alist
    (let loop ([rest args] [result '()])
      (if (null? rest)
          (reverse result)
          (let ([sel (car rest)]
                [handler (cadr rest)])
            (unless (string? sel)
              (error 'make-delegate "expected selector string, got ~a" sel))
            (unless (procedure? handler)
              (error 'make-delegate "expected procedure for ~a, got ~a" sel handler))
            (define types (hash-ref param-types sel #f))
            (define wrapped (wrap-handler-with-param-types handler types))
            (loop (cddr rest) (cons (cons sel wrapped) result))))))

  (define instance
    (if swift-available?
        (make-delegate/swift return-types handlers-alist)
        (make-delegate/racket return-types handlers-alist)))

  ;; Store param-types for delegate-set! to use on future handler updates
  (unless (hash-empty? param-types)
    (define key (cast instance _pointer _intptr))
    (hash-set! delegate-param-types key param-types))

  ;; Return as objc-object so the delegate satisfies objc-object? contracts
  ;; when passed to wrappers like nsbutton-set-target!. No retain/finalizer
  ;; — the delegate's lifetime is managed by the app holding this reference.
  (borrow-objc-object instance))

;; Update a handler on a live delegate instance.
(define (delegate-set! delegate selector handler)
  (define raw (unwrap-objc-object delegate))
  ;; Apply param-type wrapping if registered for this delegate
  (define delegate-key (cast raw _pointer _intptr))
  (define stored-param-types (hash-ref delegate-param-types delegate-key #hash()))
  (define types-for-sel (hash-ref stored-param-types selector #f))
  (define wrapped-handler (wrap-handler-with-param-types handler types-for-sel))

  (if swift-available?
      ;; Swift mode: update callback in Swift dispatch table
      (let ()
        (define instance-ptr (cast raw _pointer _pointer))
        (define key (cast instance-ptr _pointer _intptr))
        (define n-params (selector-param-count selector))
        ;; Look up the return type from registration
        (define ret-types (hash-ref swift-delegate-ret-types key #hash()))
        (define ret-kind (hash-ref ret-types selector 'void))
        (define ffi-param-types (make-list n-params _pointer))
        (define ret-type
          (case ret-kind
            [(void) _void]
            [(bool) _bool]
            [(id)   _pointer]
            [(int)  _int32]
            [(long) _int64]
            [else   _void]))
        (define callback-proc
          (lambda args (apply wrapped-handler (take args (min (length args) n-params)))))
        (define callback-ctype (_cprocedure ffi-param-types ret-type))
        (define callback-fptr (function-ptr callback-proc callback-ctype))

        (swift:set-method instance-ptr selector callback-fptr)

        ;; Prevent GC of new callback
        (define gc-handle (swift:prevent-gc callback-fptr))
        (define existing (hash-ref swift-gc-handles key '()))
        (hash-set! swift-gc-handles key
                   (cons (list callback-fptr gc-handle callback-proc) existing)))
      ;; Racket fallback mode
      (let ()
        (define key (cast raw _pointer _intptr))
        (define handlers (hash-ref dispatch-table key #f))
        (unless handlers
          (error 'delegate-set! "not a managed delegate: ~a" delegate))
        (hash-set! handlers selector wrapped-handler))))

;; Remove a handler (method will use default return).
(define (delegate-remove! delegate selector)
  (define raw (unwrap-objc-object delegate))
  (if swift-available?
      (let ()
        (define instance-ptr (cast raw _pointer _pointer))
        (swift:set-method instance-ptr selector #f))
      (let ()
        (define key (cast raw _pointer _intptr))
        (define handlers (hash-ref dispatch-table key #f))
        (when handlers
          (hash-remove! handlers selector)))))

;; Release a delegate's dispatch table entry.
(define (free-delegate delegate)
  (define raw (unwrap-objc-object delegate))
  (define delegate-key (cast raw _pointer _intptr))
  (hash-remove! delegate-param-types delegate-key)
  (if swift-available?
      (let ()
        (define instance-ptr (cast raw _pointer _pointer))
        (define key (cast instance-ptr _pointer _intptr))
        ;; Release GC prevention handles
        (for ([entry (in-list (hash-ref swift-gc-handles key '()))])
          (swift:allow-gc (cadr entry)))
        (hash-remove! swift-gc-handles key)
        (hash-remove! swift-delegate-ret-types key)
        (swift:free-delegate instance-ptr))
      (let ()
        (define key (cast raw _pointer _intptr))
        (hash-remove! dispatch-table key))))

;; Return the number of delegate classes created (for testing).
(define (delegate-class-count) class-counter)
