#lang racket/base
;; objc-subclass.rkt — Declarative ObjC subclass macro over dynamic-class.rkt
;;
;; Wraps `make-dynamic-subclass` with per-method sugar that matches the one
;; place the flat racket-oo API hurts: dynamic subclassing. Sample-app
;; callers that previously hand-rolled `function-ptr`, _cprocedure signature
;; assembly, module-level GC pinning, and superclass type-encoding lookup
;; now get a single declarative form:
;;
;;   (define-objc-subclass DrawingCanvasView NSView
;;     [(drawRect:)     (lambda (self rect)  ...)]
;;     [(mouseDown:)    (lambda (self event) ...)]
;;     [(mouseDragged:) (lambda (self event) ...)]
;;     [(mouseUp:)      (lambda (self event) ...)])
;;
;; Each clause is `[(selector-id) opt-kw ... handler-expr]`. By default the
;; macro infers the Racket FFI arg and return types from the ObjC type
;; encoding of the superclass's own implementation of the selector — the
;; one ABI-correct source. Inference covers all primitive types, id (`@`),
;; SEL (`:`), class (`#`), pointer (`^...`, `*`), and the geometry structs
;; defined in `type-mapping.rkt` (NSPoint / NSSize / NSRect / NSRange /
;; NSEdgeInsets / NSDirectionalEdgeInsets / NSAffineTransformStruct /
;; CGAffineTransform / CGVector). Anything the inference can't resolve
;; hard-errors with a message pointing at the escape hatch:
;;
;;   [(foo:)
;;    #:arg-types (_some-unusual-cstruct)
;;    #:ret-type  _void
;;    (lambda (self x) ...)]
;;
;; Either keyword may appear on its own; both are optional. Explicit types
;; always override inference — the superclass-method lookup still runs (to
;; get the ObjC encoding string required by `class_addMethod`), but the
;; FFI signature assembly uses whatever the caller supplied.
;;
;; The macro also:
;;   - stringifies the selector identifier (Racket allows `:` in identifiers)
;;   - builds the `_cprocedure (list _pointer _pointer arg-types ...) ret-type`
;;     signature, inserting the `(self SEL)` prefix automatically
;;   - wraps the user lambda to drop the SEL argument before invoking it,
;;     so handlers are written as `(lambda (self args...) ...)` with no
;;     unused `sel` parameter
;;   - pins the user proc + wrapped proc + fptr against GC in a module-level
;;     list (classes live forever on macOS, so a growing pin-list is
;;     bounded by the number of subclasses)
;;
;; Returns the registered Class pointer (same as `make-dynamic-subclass`).
;; Idempotent on module reload because `make-dynamic-subclass` itself is.
;;
;; Non-goals: this macro does NOT cover class methods, ivars, or protocol
;; conformance. Those stay on raw libobjc until a use case appears.

(require (for-syntax racket/base
                     syntax/parse)
         racket/match
         ffi/unsafe
         "dynamic-class.rkt"
         "type-mapping.rkt")

(provide define-objc-subclass
         ;; Re-exports so users of the macro need not require dynamic-class
         ;; directly for the common-case helpers.
         objc-get-class)

;; ─── IMP / proc GC pin list ─────────────────────────────────
;; function-ptr's result retains the underlying Racket procedure only if the
;; procedure itself remains reachable (see dynamic-class.rkt commentary and
;; memory.md). Once an ObjC class is registered with libobjc, its IMPs must
;; live for the process lifetime — pinning them in a module-level list
;; achieves that. The list grows monotonically; the cost is O(N-subclasses).

(define imp-pin-list '())

(define (pin-imps! imps)
  (set! imp-pin-list (cons imps imp-pin-list)))

;; ─── ObjC type-encoding parser ──────────────────────────────
;; Input: strings like "v56@0:8{CGRect={CGPoint=dd}{CGSize=dd}}16".
;;   First token  = return type
;;   Next two     = self (@) and _cmd (:)
;;   Remainder    = argument types in declaration order
;;
;; Between tokens, Apple's encoding interleaves frame-size / offset digits;
;; these are stack layout hints for the legacy libffi and irrelevant to
;; Racket FFI, so the tokenizer skips them outright. Qualifier prefixes
;; (const / inout / byref / etc.) are also silently stripped — they don't
;; affect the wire format.

(define (encoding->tokens enc)
  (let loop ([pos 0] [acc '()])
    (cond
      [(>= pos (string-length enc)) (reverse acc)]
      [(char-numeric? (string-ref enc pos)) (loop (add1 pos) acc)]
      [else
       (define-values (token next-pos) (read-one-token enc pos))
       (loop next-pos (cons token acc))])))

(define (read-one-token enc pos)
  (define c (string-ref enc pos))
  (case c
    ;; Primitive, id, SEL, class, void, char*, unknown — one character each.
    [(#\v #\c #\C #\i #\I #\s #\S #\l #\L #\q #\Q #\f #\d #\B #\@ #\: #\# #\* #\?)
     (values (string c) (add1 pos))]
    ;; Pointer to inner type — `^` followed by the pointee's token.
    [(#\^)
     (define-values (inner next) (read-one-token enc (add1 pos)))
     (values (string-append "^" inner) next)]
    ;; Qualifiers: treat as a no-op prefix, recurse for the real type.
    [(#\r #\R #\n #\N #\o #\O #\V #\A)
     (read-one-token enc (add1 pos))]
    ;; Structs, unions, arrays — balanced-delimiter parse.
    [(#\{) (read-balanced enc pos #\{ #\})]
    [(#\() (read-balanced enc pos #\( #\))]
    [(#\[) (read-balanced enc pos #\[ #\])]
    ;; Bitfields: `b` followed by a decimal width.
    [(#\b)
     (let loop ([p (add1 pos)])
       (cond
         [(>= p (string-length enc)) (values (substring enc pos p) p)]
         [(char-numeric? (string-ref enc p)) (loop (add1 p))]
         [else (values (substring enc pos p) p)]))]
    [else
     (error 'objc-subclass
            "unrecognized character '~a' in type encoding ~s at position ~a"
            c enc pos)]))

(define (read-balanced enc start open close)
  (let loop ([pos (add1 start)] [depth 1])
    (cond
      [(>= pos (string-length enc))
       (error 'objc-subclass
              "unbalanced '~a' in type encoding ~s at position ~a"
              open enc start)]
      [(char=? (string-ref enc pos) open)  (loop (add1 pos) (add1 depth))]
      [(char=? (string-ref enc pos) close)
       (if (= depth 1)
           (values (substring enc start (add1 pos)) (add1 pos))
           (loop (add1 pos) (sub1 depth)))]
      [else (loop (add1 pos) depth)])))

;; Structs that encode as `{name=fields}` — we look up by name (the bit
;; between `{` and `=`). NS* and CG* geometry types are ABI-identical on
;; 64-bit Apple, so both names point at the same Racket cstruct.
(define known-structs
  (hash "NSPoint"                  _NSPoint
        "CGPoint"                  _NSPoint
        "_NSPoint"                 _NSPoint
        "NSSize"                   _NSSize
        "CGSize"                   _NSSize
        "_NSSize"                  _NSSize
        "NSRect"                   _NSRect
        "CGRect"                   _NSRect
        "_NSRect"                  _NSRect
        "NSRange"                  _NSRange
        "_NSRange"                 _NSRange
        "NSEdgeInsets"             _NSEdgeInsets
        "_NSEdgeInsets"            _NSEdgeInsets
        "NSDirectionalEdgeInsets"  _NSDirectionalEdgeInsets
        "_NSDirectionalEdgeInsets" _NSDirectionalEdgeInsets
        "_NSAffineTransformStruct" _NSAffineTransformStruct
        "CGAffineTransform"        _CGAffineTransform
        "_CGAffineTransform"       _CGAffineTransform
        "CGVector"                 _CGVector
        "_CGVector"                _CGVector))

(define (struct-token->ffi-type token sel-str)
  ;; Token looks like "{name=...}" — extract name up to `=`.
  (define eq (regexp-match-positions #rx"=" token))
  (define name
    (if eq
        (substring token 1 (car (car eq)))
        (substring token 1 (sub1 (string-length token)))))
  (or (hash-ref known-structs name #f)
      (error 'define-objc-subclass
             (string-append
              "can't infer FFI type for struct '~a' in ~a's type encoding.~n"
              "  Known structs: ~a~n"
              "  Use #:arg-types / #:ret-type to supply the type explicitly.")
             name sel-str
             (sort (hash-keys known-structs) string<?))))

(define (token->ffi-type token sel-str)
  (define c (string-ref token 0))
  (case c
    [(#\v) _void]
    [(#\B) _bool]
    [(#\c) _int8]     ; signed char — also legacy BOOL on older SDKs
    [(#\C) _uint8]
    [(#\s) _int16]
    [(#\S) _uint16]
    [(#\i) _int32]
    [(#\I) _uint32]
    [(#\l) _int32]    ; long on 32-bit; on 64-bit Apple, `long` encodes as `q`
    [(#\L) _uint32]
    [(#\q) _int64]    ; long long, and NSInteger on 64-bit Apple
    [(#\Q) _uint64]   ; unsigned long long, and NSUInteger on 64-bit Apple
    [(#\f) _float]
    [(#\d) _double]
    [(#\@) _pointer]  ; id
    [(#\:) _pointer]  ; SEL
    [(#\#) _pointer]  ; Class
    [(#\*) _pointer]  ; char*
    [(#\^) _pointer]  ; pointer to anything — same ABI as void*
    [(#\?) _pointer]  ; unknown/function pointer — treat as opaque pointer
    [(#\{) (struct-token->ffi-type token sel-str)]
    [(#\() (error 'define-objc-subclass
                  "union return/param type unsupported in ~a (encoding token ~a)"
                  sel-str token)]
    [(#\[) (error 'define-objc-subclass
                  "array return/param type unsupported in ~a (encoding token ~a)"
                  sel-str token)]
    [(#\b) (error 'define-objc-subclass
                  "bitfield return/param type unsupported in ~a (encoding token ~a)"
                  sel-str token)]
    [else (error 'define-objc-subclass
                 "unknown type encoding ~a in ~a" token sel-str)]))

;; Parse a full method encoding into (values arg-ffi-types ret-ffi-type).
(define (parse-method-encoding encoding sel-str)
  (define tokens (encoding->tokens encoding))
  (when (< (length tokens) 3)
    (error 'define-objc-subclass
           "malformed method encoding ~s for ~a (need at least ret+self+SEL)"
           encoding sel-str))
  (match-define (list* ret-tok _self _sel arg-toks) tokens)
  (values (for/list ([t (in-list arg-toks)]) (token->ffi-type t sel-str))
          (token->ffi-type ret-tok sel-str)))

;; ─── Per-clause assembly (runtime helper used by macro expansion) ──

;; The sentinel `'infer` in an arg-types or ret-type slot means "use whatever
;; the ObjC encoding tells us". An explicit value overrides.
(define infer-sentinel 'infer)

(define (build-method-spec super-name sel-str arg-types-or-infer ret-type-or-infer user-handler)
  (define super-cls
    (or (objc-get-class super-name)
        (error 'define-objc-subclass
               "superclass not found: ~a" super-name)))
  (define method
    (or (get-instance-method super-cls sel-str)
        (error 'define-objc-subclass
               "superclass ~a has no instance method ~a"
               super-name sel-str)))
  (define encoding (method-type-encoding method))
  (define-values (inferred-args inferred-ret)
    (if (or (eq? arg-types-or-infer infer-sentinel)
            (eq? ret-type-or-infer infer-sentinel))
        (parse-method-encoding encoding sel-str)
        (values #f #f)))
  (define arg-ffi-types
    (if (eq? arg-types-or-infer infer-sentinel) inferred-args arg-types-or-infer))
  (define ret-ffi-type
    (if (eq? ret-type-or-infer infer-sentinel) inferred-ret ret-type-or-infer))
  ;; The ObjC trampoline passes (self _cmd . args); the user lambda wants
  ;; only (self . args), so drop the second positional arg at the wrap.
  (define wrapped
    (lambda (self _sel . args) (apply user-handler self args)))
  (define fptr
    (function-ptr wrapped
                  (_cprocedure (list* _pointer _pointer arg-ffi-types)
                               ret-ffi-type)))
  (pin-imps! (list wrapped user-handler fptr))
  (list sel-str fptr encoding))

;; ─── Macro ──────────────────────────────────────────────────

(define-syntax (define-objc-subclass stx)
  (syntax-parse stx
    [(_ name:id super:id
        [(sel:id)
         (~alt (~optional (~seq #:arg-types (arg-type:expr ...)))
               (~optional (~seq #:ret-type ret-type:expr)))
         ...
         handler-expr:expr] ...)
     #'(define name
         (let ([super-name (symbol->string 'super)]
               [class-name (symbol->string 'name)])
           (make-dynamic-subclass
            super-name class-name
            (list
             (build-method-spec super-name
                                (symbol->string 'sel)
                                (~? (list arg-type ...) 'infer)
                                (~? ret-type 'infer)
                                handler-expr)
             ...))))]))
