;;; Generated binding for NSString (Foundation) — do not edit
(import :std/foreign
        (rename-in :std/generic (defgeneric g:defgeneric) (defmethod g:defmethod))
        :gerbil-bindings/generics
        :gerbil-bindings/runtime/objc)
(export
  NSString
  NSString?
  absolute-path
  bool-value
  capitalized-string
  character-at-index
  custom-playground-quick-look
  decomposed-string-with-canonical-mapping
  decomposed-string-with-compatibility-mapping
  description
  double-value
  fastest-encoding
  file-system-representation
  float-value
  hash
  int-value
  integer-value
  last-path-component
  length
  localized-capitalized-string
  localized-lowercase-string
  localized-uppercase-string
  long-long-value
  lowercase-string
  make-nsstring-init-with-coder
  nsstring-absolute-path
  nsstring-available-string-encodings
  nsstring-bool-value
  nsstring-capitalized-string
  nsstring-character-at-index
  nsstring-custom-playground-quick-look
  nsstring-decomposed-string-with-canonical-mapping
  nsstring-decomposed-string-with-compatibility-mapping
  nsstring-default-c-string-encoding
  nsstring-description
  nsstring-double-value
  nsstring-fastest-encoding
  nsstring-file-system-representation
  nsstring-float-value
  nsstring-hash
  nsstring-int-value
  nsstring-integer-value
  nsstring-last-path-component
  nsstring-length
  nsstring-localized-capitalized-string
  nsstring-localized-lowercase-string
  nsstring-localized-uppercase-string
  nsstring-long-long-value
  nsstring-lowercase-string
  nsstring-path-components
  nsstring-path-extension
  nsstring-precomposed-string-with-canonical-mapping
  nsstring-precomposed-string-with-compatibility-mapping
  nsstring-smallest-encoding
  nsstring-string-by-abbreviating-with-tilde-in-path
  nsstring-string-by-deleting-last-path-component
  nsstring-string-by-deleting-path-extension
  nsstring-string-by-expanding-tilde-in-path
  nsstring-string-by-removing-percent-encoding
  nsstring-string-by-resolving-symlinks-in-path
  nsstring-string-by-standardizing-path
  nsstring-uppercase-string
  nsstring-utf8-string
  path-components
  path-extension
  precomposed-string-with-canonical-mapping
  precomposed-string-with-compatibility-mapping
  smallest-encoding
  string-by-abbreviating-with-tilde-in-path
  string-by-deleting-last-path-component
  string-by-deleting-path-extension
  string-by-expanding-tilde-in-path
  string-by-removing-percent-encoding
  string-by-resolving-symlinks-in-path
  string-by-standardizing-path
  uppercase-string
  utf8-string
  )

;; --- Class graph (ADR-0020) ---
(defclass (NSString NSObject) () transparent: #t)
(register-objc-class! (lambda (p) (make-NSString ptr: p)) NSString::t "NSString" "NSObject")

(begin-ffi (objc_getClass sel_registerName
            %msg-p->p
            %msg-u64->u16
            %msg-v->b
            %msg-v->d
            %msg-v->f
            %msg-v->i32
            %msg-v->i64
            %msg-v->p
            %msg-v->str
            %msg-v->u64
            )
  (c-declare "#include <objc/runtime.h>")
  (c-declare "#include <objc/message.h>")
  (c-declare "#include <stdint.h>")

  (define-c-lambda objc_getClass (char-string) (pointer void) "objc_getClass")
  (define-c-lambda sel_registerName (char-string) (pointer void) "sel_registerName")
  (define-c-lambda %msg-p->p ((pointer void) (pointer void) (pointer void)) (pointer void)
    "___return( ((id (*)(id, SEL, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3) );")
  (define-c-lambda %msg-u64->u16 ((pointer void) (pointer void) unsigned-int64) unsigned-int16
    "___return( ((uint16_t (*)(id, SEL, uint64_t))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3) );")
  (define-c-lambda %msg-v->b ((pointer void) (pointer void)) bool
    "___return( ((BOOL (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  (define-c-lambda %msg-v->d ((pointer void) (pointer void)) double
    "___return( ((double (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  (define-c-lambda %msg-v->f ((pointer void) (pointer void)) float
    "___return( ((float (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  (define-c-lambda %msg-v->i32 ((pointer void) (pointer void)) int32
    "___return( ((int32_t (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  (define-c-lambda %msg-v->i64 ((pointer void) (pointer void)) int64
    "___return( ((int64_t (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  (define-c-lambda %msg-v->p ((pointer void) (pointer void)) (pointer void)
    "___return( ((id (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  (define-c-lambda %msg-v->str ((pointer void) (pointer void)) char-string
    "___return( ___CAST(char*, ((const char* (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2)) );")
  (define-c-lambda %msg-v->u64 ((pointer void) (pointer void)) unsigned-int64
    "___return( ((uint64_t (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  )

(define %sel-nsstring-init-with-coder (sel_registerName "initWithCoder:"))
(define %sel-nsstring-character-at-index (sel_registerName "characterAtIndex:"))
(define %sel-nsstring-length (sel_registerName "length"))
(define %sel-nsstring-double-value (sel_registerName "doubleValue"))
(define %sel-nsstring-float-value (sel_registerName "floatValue"))
(define %sel-nsstring-int-value (sel_registerName "intValue"))
(define %sel-nsstring-integer-value (sel_registerName "integerValue"))
(define %sel-nsstring-long-long-value (sel_registerName "longLongValue"))
(define %sel-nsstring-bool-value (sel_registerName "boolValue"))
(define %sel-nsstring-uppercase-string (sel_registerName "uppercaseString"))
(define %sel-nsstring-lowercase-string (sel_registerName "lowercaseString"))
(define %sel-nsstring-capitalized-string (sel_registerName "capitalizedString"))
(define %sel-nsstring-localized-uppercase-string (sel_registerName "localizedUppercaseString"))
(define %sel-nsstring-localized-lowercase-string (sel_registerName "localizedLowercaseString"))
(define %sel-nsstring-localized-capitalized-string (sel_registerName "localizedCapitalizedString"))
(define %sel-nsstring-utf8-string (sel_registerName "UTF8String"))
(define %sel-nsstring-fastest-encoding (sel_registerName "fastestEncoding"))
(define %sel-nsstring-smallest-encoding (sel_registerName "smallestEncoding"))
(define %sel-nsstring-available-string-encodings (sel_registerName "availableStringEncodings"))
(define %sel-nsstring-default-c-string-encoding (sel_registerName "defaultCStringEncoding"))
(define %sel-nsstring-decomposed-string-with-canonical-mapping (sel_registerName "decomposedStringWithCanonicalMapping"))
(define %sel-nsstring-precomposed-string-with-canonical-mapping (sel_registerName "precomposedStringWithCanonicalMapping"))
(define %sel-nsstring-decomposed-string-with-compatibility-mapping (sel_registerName "decomposedStringWithCompatibilityMapping"))
(define %sel-nsstring-precomposed-string-with-compatibility-mapping (sel_registerName "precomposedStringWithCompatibilityMapping"))
(define %sel-nsstring-description (sel_registerName "description"))
(define %sel-nsstring-hash (sel_registerName "hash"))
(define %sel-nsstring-path-components (sel_registerName "pathComponents"))
(define %sel-nsstring-absolute-path (sel_registerName "absolutePath"))
(define %sel-nsstring-last-path-component (sel_registerName "lastPathComponent"))
(define %sel-nsstring-string-by-deleting-last-path-component (sel_registerName "stringByDeletingLastPathComponent"))
(define %sel-nsstring-path-extension (sel_registerName "pathExtension"))
(define %sel-nsstring-string-by-deleting-path-extension (sel_registerName "stringByDeletingPathExtension"))
(define %sel-nsstring-string-by-abbreviating-with-tilde-in-path (sel_registerName "stringByAbbreviatingWithTildeInPath"))
(define %sel-nsstring-string-by-expanding-tilde-in-path (sel_registerName "stringByExpandingTildeInPath"))
(define %sel-nsstring-string-by-standardizing-path (sel_registerName "stringByStandardizingPath"))
(define %sel-nsstring-string-by-resolving-symlinks-in-path (sel_registerName "stringByResolvingSymlinksInPath"))
(define %sel-nsstring-file-system-representation (sel_registerName "fileSystemRepresentation"))
(define %sel-nsstring-string-by-removing-percent-encoding (sel_registerName "stringByRemovingPercentEncoding"))
(define %sel-nsstring-custom-playground-quick-look (sel_registerName "customPlaygroundQuickLook"))

;; --- Dispatch surfaces (ADR-0020): inlinable proc core; generics are
;;     declared once in :gerbil-bindings/generics and extended below ---
(declare (inline))

;; --- Constructors ---
(define (make-nsstring-init-with-coder coder)
  (wrap (%msg-p->p (%msg-v->p (objc_getClass "NSString") (sel_registerName "alloc")) %sel-nsstring-init-with-coder (->ptr coder)) #t))

;; --- Properties ---
(define (nsstring-length self)
  (%msg-v->u64 (NSObject-ptr self) %sel-nsstring-length))
(defmethod {length NSString} (lambda (self) (nsstring-length self)))
(g:defmethod (length (o NSString)) (nsstring-length o))

(define (nsstring-double-value self)
  (%msg-v->d (NSObject-ptr self) %sel-nsstring-double-value))
(defmethod {double-value NSString} (lambda (self) (nsstring-double-value self)))
(g:defmethod (double-value (o NSString)) (nsstring-double-value o))

(define (nsstring-float-value self)
  (%msg-v->f (NSObject-ptr self) %sel-nsstring-float-value))
(defmethod {float-value NSString} (lambda (self) (nsstring-float-value self)))
(g:defmethod (float-value (o NSString)) (nsstring-float-value o))

(define (nsstring-int-value self)
  (%msg-v->i32 (NSObject-ptr self) %sel-nsstring-int-value))
(defmethod {int-value NSString} (lambda (self) (nsstring-int-value self)))
(g:defmethod (int-value (o NSString)) (nsstring-int-value o))

(define (nsstring-integer-value self)
  (%msg-v->i64 (NSObject-ptr self) %sel-nsstring-integer-value))
(defmethod {integer-value NSString} (lambda (self) (nsstring-integer-value self)))
(g:defmethod (integer-value (o NSString)) (nsstring-integer-value o))

(define (nsstring-long-long-value self)
  (%msg-v->i64 (NSObject-ptr self) %sel-nsstring-long-long-value))
(defmethod {long-long-value NSString} (lambda (self) (nsstring-long-long-value self)))
(g:defmethod (long-long-value (o NSString)) (nsstring-long-long-value o))

(define (nsstring-bool-value self)
  (%msg-v->b (NSObject-ptr self) %sel-nsstring-bool-value))
(defmethod {bool-value NSString} (lambda (self) (nsstring-bool-value self)))
(g:defmethod (bool-value (o NSString)) (nsstring-bool-value o))

(define (nsstring-uppercase-string self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsstring-uppercase-string)))
(defmethod {uppercase-string NSString} (lambda (self) (nsstring-uppercase-string self)))
(g:defmethod (uppercase-string (o NSString)) (nsstring-uppercase-string o))

(define (nsstring-lowercase-string self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsstring-lowercase-string)))
(defmethod {lowercase-string NSString} (lambda (self) (nsstring-lowercase-string self)))
(g:defmethod (lowercase-string (o NSString)) (nsstring-lowercase-string o))

(define (nsstring-capitalized-string self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsstring-capitalized-string)))
(defmethod {capitalized-string NSString} (lambda (self) (nsstring-capitalized-string self)))
(g:defmethod (capitalized-string (o NSString)) (nsstring-capitalized-string o))

(define (nsstring-localized-uppercase-string self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsstring-localized-uppercase-string)))
(defmethod {localized-uppercase-string NSString} (lambda (self) (nsstring-localized-uppercase-string self)))
(g:defmethod (localized-uppercase-string (o NSString)) (nsstring-localized-uppercase-string o))

(define (nsstring-localized-lowercase-string self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsstring-localized-lowercase-string)))
(defmethod {localized-lowercase-string NSString} (lambda (self) (nsstring-localized-lowercase-string self)))
(g:defmethod (localized-lowercase-string (o NSString)) (nsstring-localized-lowercase-string o))

(define (nsstring-localized-capitalized-string self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsstring-localized-capitalized-string)))
(defmethod {localized-capitalized-string NSString} (lambda (self) (nsstring-localized-capitalized-string self)))
(g:defmethod (localized-capitalized-string (o NSString)) (nsstring-localized-capitalized-string o))

(define (nsstring-utf8-string self)
  (%msg-v->str (NSObject-ptr self) %sel-nsstring-utf8-string))
(defmethod {utf8-string NSString} (lambda (self) (nsstring-utf8-string self)))
(g:defmethod (utf8-string (o NSString)) (nsstring-utf8-string o))

(define (nsstring-fastest-encoding self)
  (%msg-v->u64 (NSObject-ptr self) %sel-nsstring-fastest-encoding))
(defmethod {fastest-encoding NSString} (lambda (self) (nsstring-fastest-encoding self)))
(g:defmethod (fastest-encoding (o NSString)) (nsstring-fastest-encoding o))

(define (nsstring-smallest-encoding self)
  (%msg-v->u64 (NSObject-ptr self) %sel-nsstring-smallest-encoding))
(defmethod {smallest-encoding NSString} (lambda (self) (nsstring-smallest-encoding self)))
(g:defmethod (smallest-encoding (o NSString)) (nsstring-smallest-encoding o))

(define (nsstring-available-string-encodings)
  (%msg-v->p (objc_getClass "NSString") %sel-nsstring-available-string-encodings))

(define (nsstring-default-c-string-encoding)
  (%msg-v->u64 (objc_getClass "NSString") %sel-nsstring-default-c-string-encoding))

(define (nsstring-decomposed-string-with-canonical-mapping self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsstring-decomposed-string-with-canonical-mapping)))
(defmethod {decomposed-string-with-canonical-mapping NSString} (lambda (self) (nsstring-decomposed-string-with-canonical-mapping self)))
(g:defmethod (decomposed-string-with-canonical-mapping (o NSString)) (nsstring-decomposed-string-with-canonical-mapping o))

(define (nsstring-precomposed-string-with-canonical-mapping self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsstring-precomposed-string-with-canonical-mapping)))
(defmethod {precomposed-string-with-canonical-mapping NSString} (lambda (self) (nsstring-precomposed-string-with-canonical-mapping self)))
(g:defmethod (precomposed-string-with-canonical-mapping (o NSString)) (nsstring-precomposed-string-with-canonical-mapping o))

(define (nsstring-decomposed-string-with-compatibility-mapping self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsstring-decomposed-string-with-compatibility-mapping)))
(defmethod {decomposed-string-with-compatibility-mapping NSString} (lambda (self) (nsstring-decomposed-string-with-compatibility-mapping self)))
(g:defmethod (decomposed-string-with-compatibility-mapping (o NSString)) (nsstring-decomposed-string-with-compatibility-mapping o))

(define (nsstring-precomposed-string-with-compatibility-mapping self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsstring-precomposed-string-with-compatibility-mapping)))
(defmethod {precomposed-string-with-compatibility-mapping NSString} (lambda (self) (nsstring-precomposed-string-with-compatibility-mapping self)))
(g:defmethod (precomposed-string-with-compatibility-mapping (o NSString)) (nsstring-precomposed-string-with-compatibility-mapping o))

(define (nsstring-description self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsstring-description)))
(defmethod {description NSString} (lambda (self) (nsstring-description self)))
(g:defmethod (description (o NSString)) (nsstring-description o))

(define (nsstring-hash self)
  (%msg-v->u64 (NSObject-ptr self) %sel-nsstring-hash))
(defmethod {hash NSString} (lambda (self) (nsstring-hash self)))
(g:defmethod (hash (o NSString)) (nsstring-hash o))

(define (nsstring-path-components self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsstring-path-components)))
(defmethod {path-components NSString} (lambda (self) (nsstring-path-components self)))
(g:defmethod (path-components (o NSString)) (nsstring-path-components o))

(define (nsstring-absolute-path self)
  (%msg-v->b (NSObject-ptr self) %sel-nsstring-absolute-path))
(defmethod {absolute-path NSString} (lambda (self) (nsstring-absolute-path self)))
(g:defmethod (absolute-path (o NSString)) (nsstring-absolute-path o))

(define (nsstring-last-path-component self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsstring-last-path-component)))
(defmethod {last-path-component NSString} (lambda (self) (nsstring-last-path-component self)))
(g:defmethod (last-path-component (o NSString)) (nsstring-last-path-component o))

(define (nsstring-string-by-deleting-last-path-component self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsstring-string-by-deleting-last-path-component)))
(defmethod {string-by-deleting-last-path-component NSString} (lambda (self) (nsstring-string-by-deleting-last-path-component self)))
(g:defmethod (string-by-deleting-last-path-component (o NSString)) (nsstring-string-by-deleting-last-path-component o))

(define (nsstring-path-extension self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsstring-path-extension)))
(defmethod {path-extension NSString} (lambda (self) (nsstring-path-extension self)))
(g:defmethod (path-extension (o NSString)) (nsstring-path-extension o))

(define (nsstring-string-by-deleting-path-extension self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsstring-string-by-deleting-path-extension)))
(defmethod {string-by-deleting-path-extension NSString} (lambda (self) (nsstring-string-by-deleting-path-extension self)))
(g:defmethod (string-by-deleting-path-extension (o NSString)) (nsstring-string-by-deleting-path-extension o))

(define (nsstring-string-by-abbreviating-with-tilde-in-path self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsstring-string-by-abbreviating-with-tilde-in-path)))
(defmethod {string-by-abbreviating-with-tilde-in-path NSString} (lambda (self) (nsstring-string-by-abbreviating-with-tilde-in-path self)))
(g:defmethod (string-by-abbreviating-with-tilde-in-path (o NSString)) (nsstring-string-by-abbreviating-with-tilde-in-path o))

(define (nsstring-string-by-expanding-tilde-in-path self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsstring-string-by-expanding-tilde-in-path)))
(defmethod {string-by-expanding-tilde-in-path NSString} (lambda (self) (nsstring-string-by-expanding-tilde-in-path self)))
(g:defmethod (string-by-expanding-tilde-in-path (o NSString)) (nsstring-string-by-expanding-tilde-in-path o))

(define (nsstring-string-by-standardizing-path self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsstring-string-by-standardizing-path)))
(defmethod {string-by-standardizing-path NSString} (lambda (self) (nsstring-string-by-standardizing-path self)))
(g:defmethod (string-by-standardizing-path (o NSString)) (nsstring-string-by-standardizing-path o))

(define (nsstring-string-by-resolving-symlinks-in-path self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsstring-string-by-resolving-symlinks-in-path)))
(defmethod {string-by-resolving-symlinks-in-path NSString} (lambda (self) (nsstring-string-by-resolving-symlinks-in-path self)))
(g:defmethod (string-by-resolving-symlinks-in-path (o NSString)) (nsstring-string-by-resolving-symlinks-in-path o))

(define (nsstring-file-system-representation self)
  (%msg-v->str (NSObject-ptr self) %sel-nsstring-file-system-representation))
(defmethod {file-system-representation NSString} (lambda (self) (nsstring-file-system-representation self)))
(g:defmethod (file-system-representation (o NSString)) (nsstring-file-system-representation o))

(define (nsstring-string-by-removing-percent-encoding self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsstring-string-by-removing-percent-encoding)))
(defmethod {string-by-removing-percent-encoding NSString} (lambda (self) (nsstring-string-by-removing-percent-encoding self)))
(g:defmethod (string-by-removing-percent-encoding (o NSString)) (nsstring-string-by-removing-percent-encoding o))

(define (nsstring-custom-playground-quick-look self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsstring-custom-playground-quick-look)))
(defmethod {custom-playground-quick-look NSString} (lambda (self) (nsstring-custom-playground-quick-look self)))
(g:defmethod (custom-playground-quick-look (o NSString)) (nsstring-custom-playground-quick-look o))

;; --- Instance methods ---
(define (nsstring-character-at-index self index)
  (%msg-u64->u16 (NSObject-ptr self) %sel-nsstring-character-at-index index))
(defmethod {character-at-index NSString} (lambda (self index) (nsstring-character-at-index self index)))

;; --- Class methods ---
