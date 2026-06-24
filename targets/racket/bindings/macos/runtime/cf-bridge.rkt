#lang racket/base
;; cf-bridge.rkt — High-level CoreFoundation type conversions
;;
;; Wraps CFString, CFNumber, CFBoolean, CFArray, and CFDictionary
;; operations so consumer code never touches ffi/unsafe directly.
;; Create/Copy-rule objects are released internally via with-cf-value,
;; or returned with +1 ownership for the caller to manage.
;;
;; API:
;;   (racket-string->cfstring str)        → cpointer (+1 ownership)
;;   (cfstring->racket-string cfstr)      → string? or #f
;;   (cfboolean->boolean cfbool)          → boolean?
;;   (cfnumber->integer cfnum)            → exact-integer? or #f
;;   (cfnumber->real cfnum)               → real? or #f
;;   (cfarray->list arr [convert])        → list?
;;   (make-cfdictionary keys vals)        → cpointer (+1 ownership)
;;   (with-cf-value [id expr] body ...)   → releases CF object after body
;;   (cf-release ptr)                     → void (safe with #f)

(require ffi/unsafe)

(provide racket-string->cfstring
         cfstring->racket-string
         cfboolean->boolean
         cfnumber->integer
         cfnumber->real
         cfarray->list
         make-cfdictionary
         with-cf-value
         cf-release)

;; ─── FFI Bindings ────────────────────────────────────────────

(define cf-lib (ffi-lib "/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation"))

;; Memory management
(define _CFRelease
  (get-ffi-obj 'CFRelease cf-lib
    (_fun _pointer -> _void)))

(define _CFRetain
  (get-ffi-obj 'CFRetain cf-lib
    (_fun _pointer -> _pointer)))

;; String
(define _kCFStringEncodingUTF8 #x08000100)

(define _CFStringCreateWithCString
  (get-ffi-obj 'CFStringCreateWithCString cf-lib
    (_fun _pointer _string _uint32 -> _pointer)))

(define _CFStringGetCStringPtr
  (get-ffi-obj 'CFStringGetCStringPtr cf-lib
    (_fun _pointer _uint32 -> _pointer)))

(define _CFStringGetLength
  (get-ffi-obj 'CFStringGetLength cf-lib
    (_fun _pointer -> _long)))

(define _CFStringGetCString
  (get-ffi-obj 'CFStringGetCString cf-lib
    (_fun _pointer _pointer _long _uint32 -> _bool)))

;; Boolean
(define _CFBooleanGetValue
  (get-ffi-obj 'CFBooleanGetValue cf-lib
    (_fun _pointer -> _bool)))

;; Number — type constants from CFNumber.h
(define _kCFNumberSInt64Type 4)
(define _kCFNumberFloat64Type 13)

(define _CFNumberGetValue
  (get-ffi-obj 'CFNumberGetValue cf-lib
    (_fun _pointer _int _pointer -> _bool)))

;; Array
(define _CFArrayGetCount
  (get-ffi-obj 'CFArrayGetCount cf-lib
    (_fun _pointer -> _long)))

(define _CFArrayGetValueAtIndex
  (get-ffi-obj 'CFArrayGetValueAtIndex cf-lib
    (_fun _pointer _long -> _pointer)))

;; Dictionary
(define _CFDictionaryCreate
  (get-ffi-obj 'CFDictionaryCreate cf-lib
    (_fun _pointer _pointer _pointer _long _pointer _pointer -> _pointer)))

;; kCFTypeDictionaryKeyCallBacks / kCFTypeDictionaryValueCallBacks are
;; global structs — we need their addresses, not dereferenced values.
(define _dlsym
  (get-ffi-obj "dlsym" (ffi-lib #f)
    (_fun _pointer _string -> _pointer)))
(define _RTLD_DEFAULT (cast -2 _intptr _pointer))
(define _kCFTypeDictionaryKeyCallBacks
  (_dlsym _RTLD_DEFAULT "kCFTypeDictionaryKeyCallBacks"))
(define _kCFTypeDictionaryValueCallBacks
  (_dlsym _RTLD_DEFAULT "kCFTypeDictionaryValueCallBacks"))

;; ─── Public API ─────────────────────────────────────────────

;; (cf-release ptr) → void
;; Release a CoreFoundation object. No-op for #f.
(define (cf-release ptr)
  (when (and ptr (not (equal? ptr #f)))
    (_CFRelease ptr)))

;; (with-cf-value [id expr] body ...) → result of body
;; Evaluates expr, binds to id, runs body, releases the CF object.
;; Safe even if body raises — dynamic-wind ensures release.
(define-syntax-rule (with-cf-value [id expr] body ...)
  (let ([id expr])
    (dynamic-wind
      void
      (lambda () body ...)
      (lambda () (cf-release id)))))

;; (racket-string->cfstring str) → cpointer or #f
;; Creates a CFStringRef (+1 ownership) from a Racket string.
;; Caller owns the result — use with-cf-value or cf-release.
(define (racket-string->cfstring str)
  (_CFStringCreateWithCString #f str _kCFStringEncodingUTF8))

;; (cfstring->racket-string cfstr) → string? or #f
;; Extracts a Racket string from a CFStringRef. Returns #f for #f input.
;; Tries fast path (CFStringGetCStringPtr) first, falls back to
;; buffer-copy via CFStringGetCString.
(define (cfstring->racket-string cfstr)
  (cond
    [(not cfstr) #f]
    [(equal? cfstr #f) #f]
    [else
     (define fast (_CFStringGetCStringPtr cfstr _kCFStringEncodingUTF8))
     (if (and fast (not (equal? fast #f)))
         (cast fast _pointer _string)
         ;; Slow path: UTF-8 can use up to 4 bytes per character + null
         (let* ([len (_CFStringGetLength cfstr)]
                [buf-size (+ (* len 4) 1)]
                [buf (malloc buf-size)])
           (if (_CFStringGetCString cfstr buf buf-size _kCFStringEncodingUTF8)
               (cast buf _pointer _string)
               #f)))]))

;; (cfboolean->boolean cfbool) → boolean?
;; Converts a CFBooleanRef to a Racket boolean.
(define (cfboolean->boolean cfbool)
  (and cfbool
       (not (equal? cfbool #f))
       (_CFBooleanGetValue cfbool)))

;; (cfnumber->integer cfnum) → exact-integer? or #f
;; Extracts a 64-bit signed integer from a CFNumberRef.
(define (cfnumber->integer cfnum)
  (cond
    [(not cfnum) #f]
    [(equal? cfnum #f) #f]
    [else
     (let ([buf (malloc _int64)])
       (if (_CFNumberGetValue cfnum _kCFNumberSInt64Type buf)
           (ptr-ref buf _int64)
           #f))]))

;; (cfnumber->real cfnum) → real? or #f
;; Extracts a 64-bit float from a CFNumberRef.
(define (cfnumber->real cfnum)
  (cond
    [(not cfnum) #f]
    [(equal? cfnum #f) #f]
    [else
     (let ([buf (malloc _double)])
       (if (_CFNumberGetValue cfnum _kCFNumberFloat64Type buf)
           (ptr-ref buf _double)
           #f))]))

;; (cfarray->list arr [convert]) → list?
;; Converts a CFArrayRef to a Racket list. Each element is passed
;; through convert (default: identity). Returns '() for #f input.
(define (cfarray->list arr [convert values])
  (cond
    [(not arr) '()]
    [(equal? arr #f) '()]
    [else
     (define count (_CFArrayGetCount arr))
     (for/list ([i (in-range count)])
       (convert (_CFArrayGetValueAtIndex arr i)))]))

;; (make-cfdictionary keys vals) → cpointer or #f
;; Creates a CFDictionaryRef (+1 ownership) from parallel lists of
;; CF object pointers. Caller owns the result.
(define (make-cfdictionary keys vals)
  (define count (length keys))
  (define key-arr (malloc _pointer count))
  (define val-arr (malloc _pointer count))
  (for ([k (in-list keys)]
        [v (in-list vals)]
        [i (in-naturals)])
    (ptr-set! key-arr _pointer i k)
    (ptr-set! val-arr _pointer i v))
  (_CFDictionaryCreate #f key-arr val-arr count
                       _kCFTypeDictionaryKeyCallBacks
                       _kCFTypeDictionaryValueCallBacks))
