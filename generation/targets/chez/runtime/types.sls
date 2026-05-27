;; runtime/types.sls — chez target geometry ftypes and value bridging.
;;
;; Absorbs from the racket runtime: type-mapping.rkt, coerce.rkt, cf-bridge.rkt
;; (mechanical port per design spec §2).
;;
;; Layouts target 64-bit macOS: CGFloat = double-float, NSUInteger / NSInteger =
;; (un)signed-64. ftypes replace racket's `define-cstruct` — `define-ftype`
;; defines the type, `make-ftype-pointer` allocates an instance.
;;
;; Lifetime note: geometry constructors allocate via `foreign-alloc`. There is
;; no guardian sweep for these in this leaf — most uses are short-lived (one
;; rect per window, one point per click) so a leak per allocation is bounded.
;; A future leaf may surface the need for an explicit drain hook.

(library (apianyware runtime types)
  (export
    ;; Geometry ftype declarations
    NSPoint NSSize NSRect NSRange
    NSEdgeInsets NSDirectionalEdgeInsets
    NSAffineTransformStruct CGAffineTransform CGVector
    ;; Geometry constructors and accessors
    make-nspoint make-nssize make-nsrect make-nsrange
    make-nsedge-insets
    nspoint-x nspoint-y
    nssize-width nssize-height
    nsrect-origin nsrect-size
    nsrange-location nsrange-length
    ;; Foundation conversions
    string->nsstring nsstring->string ->string
    list->nsarray nsarray->list
    hash->nsdictionary nsdictionary->hash
    ;; Argument coercion for FFI call sites
    coerce-arg
    ;; CoreFoundation bridging
    string->cfstring cfstring->string
    cfboolean->boolean
    cfnumber->integer cfnumber->real
    cfarray->list
    make-cfdictionary
    with-cf-value
    cf-release cf-retain
    kCFTypeDictionaryKeyCallBacks
    kCFTypeDictionaryValueCallBacks)
  (import (chezscheme)
          (apianyware runtime ffi)
          (apianyware runtime objc))

  ;; --- Geometry ftypes ------------------------------------------------
  ;;
  ;; All fields are 64-bit on arm64/x86_64 macOS, matching CGFloat=double
  ;; and NSUInteger/NSInteger = (un)signed 64-bit.

  (define-ftype NSPoint
    (struct [x double-float]
            [y double-float]))

  (define-ftype NSSize
    (struct [width double-float]
            [height double-float]))

  (define-ftype NSRect
    (struct [origin NSPoint]
            [size NSSize]))

  (define-ftype NSRange
    (struct [location unsigned-64]
            [length unsigned-64]))

  (define-ftype NSEdgeInsets
    (struct [top double-float]
            [left double-float]
            [bottom double-float]
            [right double-float]))

  (define-ftype NSDirectionalEdgeInsets
    (struct [top double-float]
            [leading double-float]
            [bottom double-float]
            [trailing double-float]))

  (define-ftype NSAffineTransformStruct
    (struct [m11 double-float]
            [m12 double-float]
            [m21 double-float]
            [m22 double-float]
            [tX double-float]
            [tY double-float]))

  (define-ftype CGAffineTransform
    (struct [a  double-float]
            [b  double-float]
            [c  double-float]
            [d  double-float]
            [tx double-float]
            [ty double-float]))

  (define-ftype CGVector
    (struct [dx double-float]
            [dy double-float]))

  ;; --- Geometry constructors and accessors ----------------------------
  ;;
  ;; Constructors allocate via foreign-alloc and return an ftype-pointer.
  ;; Accessors use ftype-ref / ftype-&ref (the latter yields a sub-struct
  ;; pointer aliasing the parent's memory — no copy).

  (define (->double v)
    (if (flonum? v) v (exact->inexact v)))

  (define (make-nspoint x y)
    (let ([p (make-ftype-pointer NSPoint (foreign-alloc (ftype-sizeof NSPoint)))])
      (ftype-set! NSPoint (x) p (->double x))
      (ftype-set! NSPoint (y) p (->double y))
      p))

  (define (nspoint-x p) (ftype-ref NSPoint (x) p))
  (define (nspoint-y p) (ftype-ref NSPoint (y) p))

  (define (make-nssize w h)
    (let ([s (make-ftype-pointer NSSize (foreign-alloc (ftype-sizeof NSSize)))])
      (ftype-set! NSSize (width) s (->double w))
      (ftype-set! NSSize (height) s (->double h))
      s))

  (define (nssize-width s)  (ftype-ref NSSize (width) s))
  (define (nssize-height s) (ftype-ref NSSize (height) s))

  ;; make-nsrect supports two shapes for parity with racket's helper:
  ;;   (make-nsrect x y w h)         — four scalars
  ;;   (make-nsrect origin size)     — composing two existing ftype-pointers
  (define make-nsrect
    (case-lambda
      [(x y w h)
       (let ([r (make-ftype-pointer NSRect
                                    (foreign-alloc (ftype-sizeof NSRect)))])
         (ftype-set! NSRect (origin x) r (->double x))
         (ftype-set! NSRect (origin y) r (->double y))
         (ftype-set! NSRect (size width)  r (->double w))
         (ftype-set! NSRect (size height) r (->double h))
         r)]
      [(origin size)
       (make-nsrect (nspoint-x origin) (nspoint-y origin)
                    (nssize-width size) (nssize-height size))]))

  ;; nsrect-origin / nsrect-size return ftype-pointers aliasing the rect's
  ;; storage. Callers reading x/y/width/height through them see live values;
  ;; they must not outlive the rect.
  (define (nsrect-origin r) (ftype-&ref NSRect (origin) r))
  (define (nsrect-size r)   (ftype-&ref NSRect (size) r))

  (define (make-nsrange location length)
    (let ([r (make-ftype-pointer NSRange (foreign-alloc (ftype-sizeof NSRange)))])
      (ftype-set! NSRange (location) r location)
      (ftype-set! NSRange (length) r length)
      r))

  (define (nsrange-location r) (ftype-ref NSRange (location) r))
  (define (nsrange-length r)   (ftype-ref NSRange (length) r))

  (define (make-nsedge-insets top left bottom right)
    (let ([e (make-ftype-pointer NSEdgeInsets
                                 (foreign-alloc (ftype-sizeof NSEdgeInsets)))])
      (ftype-set! NSEdgeInsets (top) e (->double top))
      (ftype-set! NSEdgeInsets (left) e (->double left))
      (ftype-set! NSEdgeInsets (bottom) e (->double bottom))
      (ftype-set! NSEdgeInsets (right) e (->double right))
      e))

  ;; --- NSString ------------------------------------------------------
  ;;
  ;; string->nsstring returns a +1-retained NSString wrapped as objc-object.
  ;; nsstring->string accepts objc-object or raw pointer (integer).

  (define (string->nsstring s)
    (let ([ptr (string->nsstring-ptr s)])
      (wrap-objc-object ptr #t)))

  (define (nsstring->string ns)
    (cond
      [(not ns) ""]
      [(objc-object? ns)
       (let ([p (objc-object-ptr ns)])
         (if (or (not p) (zero? p)) ""
             (nsstring-ptr->string p)))]
      [(integer? ns)
       (if (zero? ns) "" (nsstring-ptr->string ns))]
      [else
       (error 'nsstring->string
              "expected objc-object or integer pointer" ns)]))

  ;; Permissive variant: accepts string passthrough as well, for code that
  ;; doesn't know whether it holds a Scheme string or an NSString.
  (define (->string v)
    (cond
      [(not v) ""]
      [(string? v) v]
      [(objc-object? v) (nsstring->string v)]
      [(integer? v)     (nsstring->string v)]
      [else
       (error '->string
              "expected objc-object, integer pointer, string, or #f" v)]))

  ;; --- coerce-arg ----------------------------------------------------
  ;;
  ;; Smart conversion for emitted-wrapper call sites: returns the raw
  ;; integer pointer (uptr address) suitable for objc_msgSend's void*.
  ;; Strings are auto-marshalled to NSStrings; lists and hashes are NOT
  ;; — that would hide allocation from the call site.
  (define (coerce-arg v)
    (cond
      [(not v) 0]
      [(string? v) (string->nsstring-ptr v)]
      [(objc-object? v) (objc-object-ptr v)]
      [(integer? v) v]
      [else
       (error 'coerce-arg
              "expected string, objc-object, integer pointer, or #f" v)]))

  ;; --- objc_msgSend variants used by NSArray / NSDictionary helpers ---
  ;;
  ;; ffi.sls exports objc_msgSend as (void* void*) -> void*. We declare
  ;; the additional signatures here once, as a small surface used only by
  ;; the Foundation collection helpers.

  (define msg-id+sel+id->void
    (foreign-procedure "objc_msgSend" (void* void* void*) void))

  (define msg-id+sel+id->id
    (foreign-procedure "objc_msgSend" (void* void* void*) void*))

  (define msg-id+sel+id+id->void
    (foreign-procedure "objc_msgSend" (void* void* void* void*) void))

  (define msg-id+sel->uint64
    (foreign-procedure "objc_msgSend" (void* void*) unsigned-64))

  (define msg-id+sel+uint64->id
    (foreign-procedure "objc_msgSend" (void* void* unsigned-64) void*))

  ;; Cached selectors and class lookups used inside this library.
  (define sel-alloc           (sel-register "alloc"))
  (define sel-init            (sel-register "init"))
  (define sel-release         (sel-register "release"))
  (define sel-add-object      (sel-register "addObject:"))
  (define sel-object-at-index (sel-register "objectAtIndex:"))
  (define sel-object-for-key  (sel-register "objectForKey:"))
  (define sel-set-object-for-key (sel-register "setObject:forKey:"))
  (define sel-count           (sel-register "count"))
  (define sel-all-keys        (sel-register "allKeys"))

  (define %nsmutablearray-class      #f)
  (define %nsmutabledictionary-class #f)

  (define (nsmutablearray-class)
    (or %nsmutablearray-class
        (let ([c (objc_getClass "NSMutableArray")])
          (set! %nsmutablearray-class c)
          c)))

  (define (nsmutabledictionary-class)
    (or %nsmutabledictionary-class
        (let ([c (objc_getClass "NSMutableDictionary")])
          (set! %nsmutabledictionary-class c)
          c)))

  ;; --- NSArray --------------------------------------------------------

  (define (list->nsarray lst)
    (let* ([cls (nsmutablearray-class)]
           [arr (objc_msgSend (objc_msgSend cls sel-alloc) sel-init)])
      (for-each
        (lambda (item) (msg-id+sel+id->void arr sel-add-object (coerce-arg item)))
        lst)
      (wrap-objc-object arr #t)))

  (define (nsarray->list arr)
    (let* ([raw   (cond [(objc-object? arr) (objc-object-ptr arr)]
                        [(integer? arr) arr]
                        [else (error 'nsarray->list
                                     "expected objc-object or integer" arr)])]
           [count (msg-id+sel->uint64 raw sel-count)])
      (let loop ([i 0] [acc '()])
        (cond
          [(= i count) (reverse acc)]
          [else
           (let ([elt (msg-id+sel+uint64->id raw sel-object-at-index i)])
             (loop (+ i 1)
                   (cons (borrow-objc-object elt) acc)))]))))

  ;; --- NSDictionary --------------------------------------------------

  (define (hash->nsdictionary ht)
    (let* ([cls  (nsmutabledictionary-class)]
           [dict (objc_msgSend (objc_msgSend cls sel-alloc) sel-init)])
      (let-values ([(keys vals)
                    (let loop ([ks (hashtable-keys ht)] [i 0]
                               [ka '()] [va '()])
                      (cond
                        [(= i (vector-length ks))
                         (values (reverse ka) (reverse va))]
                        [else
                         (let ([k (vector-ref ks i)])
                           (loop ks (+ i 1)
                                 (cons k ka)
                                 (cons (hashtable-ref ht k #f) va)))]))])
        (for-each
          (lambda (k v)
            (let ([nskey (string->nsstring-ptr k)])
              (msg-id+sel+id+id->void dict sel-set-object-for-key
                                      (coerce-arg v) nskey)
              ;; setObject:forKey: copies the key; release our +1.
              (msg-id+sel+id->void nskey sel-release 0)))
          keys vals))
      (wrap-objc-object dict #t)))

  (define (nsdictionary->hash dict)
    (let* ([raw  (cond [(objc-object? dict) (objc-object-ptr dict)]
                       [(integer? dict) dict]
                       [else (error 'nsdictionary->hash
                                    "expected objc-object or integer" dict)])]
           [keys (msg-id+sel+id->id raw sel-all-keys 0)]
           [count (msg-id+sel->uint64 keys sel-count)]
           [ht   (make-hashtable string-hash string=?)])
      (let loop ([i 0])
        (cond
          [(= i count) ht]
          [else
           (let* ([keyp (msg-id+sel+uint64->id keys sel-object-at-index i)]
                  [valp (msg-id+sel+id->id raw sel-object-for-key keyp)]
                  [key-str (nsstring-ptr->string keyp)])
             (hashtable-set! ht key-str (borrow-objc-object valp))
             (loop (+ i 1)))]))))

  ;; --- CoreFoundation surface -----------------------------------------
  ;;
  ;; Load CoreFoundation at library invoke. Idempotent — load_shared_object
  ;; returns silently if the lib is already loaded.

  (define %cf-loaded
    (begin
      (load-shared-object
        "/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation")
      #t))

  (define %kCFStringEncodingUTF8 #x08000100)
  (define %kCFNumberSInt64Type   4)
  (define %kCFNumberFloat64Type  13)

  (define cf-release
    (let ([f (foreign-procedure "CFRelease" (void*) void)])
      (lambda (p)
        (when (and p (not (and (integer? p) (zero? p))))
          (f p)))))

  (define cf-retain
    (let ([f (foreign-procedure "CFRetain" (void*) void*)])
      (lambda (p)
        (cond
          [(not p) 0]
          [(and (integer? p) (zero? p)) 0]
          [else (f p)]))))

  (define %CFStringCreateWithCString
    (foreign-procedure "CFStringCreateWithCString"
                       (void* string unsigned-32) void*))

  (define %CFStringGetCStringPtr
    (foreign-procedure "CFStringGetCStringPtr" (void* unsigned-32) void*))

  (define %CFStringGetLength
    (foreign-procedure "CFStringGetLength" (void*) integer-64))

  (define %CFStringGetCString
    (foreign-procedure "CFStringGetCString"
                       (void* void* integer-64 unsigned-32) boolean))

  (define %CFBooleanGetValue
    (foreign-procedure "CFBooleanGetValue" (void*) boolean))

  (define %CFNumberGetValue
    (foreign-procedure "CFNumberGetValue" (void* int void*) boolean))

  (define %CFArrayGetCount
    (foreign-procedure "CFArrayGetCount" (void*) integer-64))

  (define %CFArrayGetValueAtIndex
    (foreign-procedure "CFArrayGetValueAtIndex" (void* integer-64) void*))

  (define %CFDictionaryCreate
    (foreign-procedure "CFDictionaryCreate"
                       (void* void* void* integer-64 void* void*)
                       void*))

  ;; CF type-callbacks structs — addresses pulled from the loaded CF dylib.
  (define kCFTypeDictionaryKeyCallBacks
    (foreign-entry "kCFTypeDictionaryKeyCallBacks"))

  (define kCFTypeDictionaryValueCallBacks
    (foreign-entry "kCFTypeDictionaryValueCallBacks"))

  ;; (string->cfstring str) → CFStringRef (+1 ownership)
  (define (string->cfstring s)
    (%CFStringCreateWithCString 0 s %kCFStringEncodingUTF8))

  ;; (cfstring->string cf) → string or #f
  ;; Tries CFStringGetCStringPtr (fast path) before CFStringGetCString.
  (define (cfstring->string cf)
    (cond
      [(or (not cf) (and (integer? cf) (zero? cf))) #f]
      [else
       (let ([fast (%CFStringGetCStringPtr cf %kCFStringEncodingUTF8)])
         (cond
           [(and fast (not (zero? fast)))
            (cstring->string fast)]
           [else
            (let* ([len      (%CFStringGetLength cf)]
                   [buf-size (+ 1 (* len 4))]
                   [buf      (foreign-alloc buf-size)])
              (cond
                [(%CFStringGetCString cf buf buf-size %kCFStringEncodingUTF8)
                 (let ([s (cstring->string buf)])
                   (foreign-free buf)
                   s)]
                [else (foreign-free buf) #f]))]))]))

  ;; Read a NUL-terminated C string at `addr` into a Scheme string.
  (define (cstring->string addr)
    (let loop ([i 0] [bs '()])
      (let ([b (foreign-ref 'unsigned-8 addr i)])
        (if (zero? b)
            (utf8->string (u8-list->bytevector (reverse bs)))
            (loop (+ i 1) (cons b bs))))))

  (define (cfboolean->boolean cf)
    (and cf (not (and (integer? cf) (zero? cf)))
         (%CFBooleanGetValue cf)))

  (define (cfnumber->integer cf)
    (cond
      [(or (not cf) (and (integer? cf) (zero? cf))) #f]
      [else
       (let ([buf (foreign-alloc 8)])
         (cond
           [(%CFNumberGetValue cf %kCFNumberSInt64Type buf)
            (let ([n (foreign-ref 'integer-64 buf 0)])
              (foreign-free buf)
              n)]
           [else (foreign-free buf) #f]))]))

  (define (cfnumber->real cf)
    (cond
      [(or (not cf) (and (integer? cf) (zero? cf))) #f]
      [else
       (let ([buf (foreign-alloc 8)])
         (cond
           [(%CFNumberGetValue cf %kCFNumberFloat64Type buf)
            (let ([d (foreign-ref 'double-float buf 0)])
              (foreign-free buf)
              d)]
           [else (foreign-free buf) #f]))]))

  ;; (cfarray->list arr [convert]) → list
  ;; `convert` is applied to each element pointer (default: identity).
  (define cfarray->list
    (case-lambda
      [(arr) (cfarray->list arr (lambda (p) p))]
      [(arr convert)
       (cond
         [(or (not arr) (and (integer? arr) (zero? arr))) '()]
         [else
          (let ([count (%CFArrayGetCount arr)])
            (let loop ([i 0] [acc '()])
              (cond
                [(= i count) (reverse acc)]
                [else
                 (loop (+ i 1)
                       (cons (convert (%CFArrayGetValueAtIndex arr i))
                             acc))])))])]))

  ;; (make-cfdictionary keys vals) → CFDictionaryRef (+1 ownership)
  ;; keys and vals are parallel lists of CF object pointers (integers).
  (define (make-cfdictionary keys vals)
    (let* ([n        (length keys)]
           [bytes    (* 8 n)]
           [key-arr  (foreign-alloc bytes)]
           [val-arr  (foreign-alloc bytes)])
      (let loop ([i 0] [ks keys] [vs vals])
        (cond
          [(null? ks) (void)]
          [else
           (foreign-set! 'uptr key-arr (* 8 i) (car ks))
           (foreign-set! 'uptr val-arr (* 8 i) (car vs))
           (loop (+ i 1) (cdr ks) (cdr vs))]))
      (let ([dict (%CFDictionaryCreate 0 key-arr val-arr n
                                       kCFTypeDictionaryKeyCallBacks
                                       kCFTypeDictionaryValueCallBacks)])
        (foreign-free key-arr)
        (foreign-free val-arr)
        dict)))

  ;; (with-cf-value [id expr] body ...) — bind id to expr, run body,
  ;; CFRelease id unconditionally.
  (define-syntax with-cf-value
    (syntax-rules ()
      [(_ [id expr] body0 body ...)
       (let ([id expr])
         (dynamic-wind
           (lambda () #f)
           (lambda () body0 body ...)
           (lambda () (cf-release id))))])))
