;;; Generated binding for NSString (Foundation) — do not edit
(import :std/foreign
        (rename-in :std/generic (defgeneric g:defgeneric) (defmethod g:defmethod))
        :gerbil-bindings/generics
        :gerbil-bindings/runtime/objc
        :gerbil-bindings/runtime/swift-trampoline)
(export
  NSString
  NSString?
  absolute-path
  bool-value
  c-string-using-encoding
  can-be-converted-to-encoding
  capitalized-string
  capitalized-string-with-locale
  case-insensitive-compare
  character-at-index
  common-prefix-with-string-options
  compare
  compare-options
  compare-options-range
  compare-options-range-locale
  components-separated-by-characters-in-set
  components-separated-by-string
  contains-string
  custom-playground-quick-look
  data-using-encoding
  data-using-encoding-allow-lossy-conversion
  decomposed-string-with-canonical-mapping
  decomposed-string-with-compatibility-mapping
  description
  double-value
  encode-with-coder
  enumerate-lines-using-block
  fastest-encoding
  file-system-representation
  float-value
  has-prefix
  has-suffix
  hash
  int-value
  integer-value
  is-absolute-path
  is-equal-to-string
  item-provider-visibility-for-representation-with-type-identifier
  last-path-component
  length
  length-of-bytes-using-encoding
  line-range-for-range
  load-data-with-type-identifier-for-item-provider-completion-handler
  localized-capitalized-string
  localized-case-insensitive-compare
  localized-case-insensitive-contains-string
  localized-compare
  localized-lowercase-string
  localized-standard-compare
  localized-standard-contains-string
  localized-standard-range-of-string
  localized-uppercase-string
  long-long-value
  lowercase-string
  lowercase-string-with-locale
  make-nsstring-init-with-c-string-encoding
  make-nsstring-init-with-coder
  make-nsstring-init-with-data-encoding
  make-nsstring-init-with-string
  make-nsstring-init-with-utf8-string
  make-nsstring-string
  maximum-length-of-bytes-using-encoding
  nsstring-absolute-path
  nsstring-available-string-encodings
  nsstring-bool-value
  nsstring-c-string-using-encoding
  nsstring-can-be-converted-to-encoding
  nsstring-capitalized-string
  nsstring-capitalized-string-with-locale
  nsstring-case-insensitive-compare
  nsstring-character-at-index
  nsstring-common-prefix-with-string-options
  nsstring-compare
  nsstring-compare-options
  nsstring-compare-options-range
  nsstring-compare-options-range-locale
  nsstring-components-separated-by-characters-in-set
  nsstring-components-separated-by-string
  nsstring-contains-string
  nsstring-custom-playground-quick-look
  nsstring-data-using-encoding
  nsstring-data-using-encoding-allow-lossy-conversion
  nsstring-decomposed-string-with-canonical-mapping
  nsstring-decomposed-string-with-compatibility-mapping
  nsstring-default-c-string-encoding
  nsstring-description
  nsstring-double-value
  nsstring-encode-with-coder
  nsstring-enumerate-lines-using-block
  nsstring-fastest-encoding
  nsstring-file-system-representation
  nsstring-float-value
  nsstring-has-prefix
  nsstring-has-suffix
  nsstring-hash
  nsstring-int-value
  nsstring-integer-value
  nsstring-is-absolute-path
  nsstring-is-equal-to-string
  nsstring-item-provider-visibility-for-representation-with-type-identifier
  nsstring-last-path-component
  nsstring-length
  nsstring-length-of-bytes-using-encoding
  nsstring-line-range-for-range
  nsstring-load-data-with-type-identifier-for-item-provider-completion-handler
  nsstring-localized-capitalized-string
  nsstring-localized-case-insensitive-compare
  nsstring-localized-case-insensitive-contains-string
  nsstring-localized-compare
  nsstring-localized-lowercase-string
  nsstring-localized-name-of-string-encoding
  nsstring-localized-standard-compare
  nsstring-localized-standard-contains-string
  nsstring-localized-standard-range-of-string
  nsstring-localized-uppercase-string
  nsstring-long-long-value
  nsstring-lowercase-string
  nsstring-lowercase-string-with-locale
  nsstring-maximum-length-of-bytes-using-encoding
  nsstring-object-with-item-provider-data-type-identifier-error
  nsstring-paragraph-range-for-range
  nsstring-path-components
  nsstring-path-extension
  nsstring-path-with-components
  nsstring-precomposed-string-with-canonical-mapping
  nsstring-precomposed-string-with-compatibility-mapping
  nsstring-property-list
  nsstring-property-list-from-strings-file-format
  nsstring-range-of-character-from-set
  nsstring-range-of-character-from-set-options
  nsstring-range-of-character-from-set-options-range
  nsstring-range-of-composed-character-sequence-at-index
  nsstring-range-of-composed-character-sequences-for-range
  nsstring-range-of-string
  nsstring-range-of-string-options
  nsstring-range-of-string-options-range
  nsstring-range-of-string-options-range-locale
  nsstring-readable-type-identifiers-for-item-provider
  nsstring-smallest-encoding
  nsstring-string
  nsstring-string-by-abbreviating-with-tilde-in-path
  nsstring-string-by-adding-percent-encoding-with-allowed-characters
  nsstring-string-by-appending-path-component
  nsstring-string-by-appending-path-extension
  nsstring-string-by-appending-string
  nsstring-string-by-applying-transform-reverse
  nsstring-string-by-deleting-last-path-component
  nsstring-string-by-deleting-path-extension
  nsstring-string-by-expanding-tilde-in-path
  nsstring-string-by-folding-with-options-locale
  nsstring-string-by-padding-to-length-with-string-starting-at-index
  nsstring-string-by-removing-percent-encoding
  nsstring-string-by-replacing-characters-in-range-with-string
  nsstring-string-by-replacing-occurrences-of-string-with-string
  nsstring-string-by-replacing-occurrences-of-string-with-string-options-range
  nsstring-string-by-resolving-symlinks-in-path
  nsstring-string-by-standardizing-path
  nsstring-string-by-trimming-characters-in-set
  nsstring-string-with-c-string-encoding
  nsstring-string-with-contents-of-file-encoding-error
  nsstring-string-with-contents-of-url-encoding-error
  nsstring-string-with-string
  nsstring-string-with-utf8-string
  nsstring-strings-by-appending-paths
  nsstring-substring-from-index
  nsstring-substring-to-index
  nsstring-substring-with-range
  nsstring-supports-secure-coding
  nsstring-uppercase-string
  nsstring-uppercase-string-with-locale
  nsstring-utf8-string
  nsstring-variant-fitting-presentation-width
  nsstring-writable-type-identifiers-for-item-provider
  nsstring-write-to-file-atomically-encoding-error
  nsstring-write-to-url-atomically-encoding-error
  paragraph-range-for-range
  path-components
  path-extension
  precomposed-string-with-canonical-mapping
  precomposed-string-with-compatibility-mapping
  property-list
  property-list-from-strings-file-format
  range-of-character-from-set
  range-of-character-from-set-options
  range-of-character-from-set-options-range
  range-of-composed-character-sequence-at-index
  range-of-composed-character-sequences-for-range
  range-of-string
  range-of-string-options
  range-of-string-options-range
  range-of-string-options-range-locale
  smallest-encoding
  string-by-abbreviating-with-tilde-in-path
  string-by-adding-percent-encoding-with-allowed-characters
  string-by-appending-path-component
  string-by-appending-path-extension
  string-by-appending-string
  string-by-applying-transform-reverse
  string-by-deleting-last-path-component
  string-by-deleting-path-extension
  string-by-expanding-tilde-in-path
  string-by-folding-with-options-locale
  string-by-padding-to-length-with-string-starting-at-index
  string-by-removing-percent-encoding
  string-by-replacing-characters-in-range-with-string
  string-by-replacing-occurrences-of-string-with-string
  string-by-replacing-occurrences-of-string-with-string-options-range
  string-by-resolving-symlinks-in-path
  string-by-standardizing-path
  string-by-trimming-characters-in-set
  strings-by-appending-paths
  substring-from-index
  substring-to-index
  substring-with-range
  uppercase-string
  uppercase-string-with-locale
  utf8-string
  variant-fitting-presentation-width
  writable-type-identifiers-for-item-provider
  write-to-file-atomically-encoding-error
  write-to-url-atomically-encoding-error
  )

;; --- Class graph (ADR-0020) ---
(defclass (NSString NSObject) () transparent: #t)
(register-objc-class! (lambda (p) (make-NSString ptr: p)) NSString::t "NSString" "NSObject")

(begin-ffi (objc_getClass sel_registerName
            %msg-i64->p
            %msg-nsrange->nsrange
            %msg-nsrange->p
            %msg-nsrange-p->p
            %msg-p->b
            %msg-p->i64
            %msg-p->nsrange
            %msg-p->p
            %msg-p->v
            %msg-p-b->p
            %msg-p-b-u64-pp->b-e
            %msg-p-p->p
            %msg-p-p-pp->p-e
            %msg-p-p-u64-nsrange->p
            %msg-p-u64->i64
            %msg-p-u64->nsrange
            %msg-p-u64->p
            %msg-p-u64-nsrange->i64
            %msg-p-u64-nsrange->nsrange
            %msg-p-u64-nsrange-p->i64
            %msg-p-u64-nsrange-p->nsrange
            %msg-p-u64-pp->p-e
            %msg-str->p
            %msg-str-u64->p
            %msg-u64->b
            %msg-u64->nsrange
            %msg-u64->p
            %msg-u64->str
            %msg-u64->u16
            %msg-u64->u64
            %msg-u64-b->p
            %msg-u64-p->p
            %msg-u64-p-u64->p
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
  (c-declare "typedef struct _NSRange { unsigned long location; unsigned long length; } NSRange;")
  (c-define-type NSRange (struct "_NSRange"))

  (define-c-lambda objc_getClass (char-string) (pointer void) "objc_getClass")
  (define-c-lambda sel_registerName (char-string) (pointer void) "sel_registerName")
  (define-c-lambda %msg-i64->p ((pointer void) (pointer void) int64) (pointer void)
    "___return( ((id (*)(id, SEL, int64_t))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3) );")
  (define-c-lambda %msg-nsrange->nsrange ((pointer void) (pointer void) NSRange) NSRange
    "___return( ((NSRange (*)(id, SEL, NSRange))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3) );")
  (define-c-lambda %msg-nsrange->p ((pointer void) (pointer void) NSRange) (pointer void)
    "___return( ((id (*)(id, SEL, NSRange))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3) );")
  (define-c-lambda %msg-nsrange-p->p ((pointer void) (pointer void) NSRange (pointer void)) (pointer void)
    "___return( ((id (*)(id, SEL, NSRange, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4) );")
  (define-c-lambda %msg-p->b ((pointer void) (pointer void) (pointer void)) bool
    "___return( ((BOOL (*)(id, SEL, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3) );")
  (define-c-lambda %msg-p->i64 ((pointer void) (pointer void) (pointer void)) int64
    "___return( ((int64_t (*)(id, SEL, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3) );")
  (define-c-lambda %msg-p->nsrange ((pointer void) (pointer void) (pointer void)) NSRange
    "___return( ((NSRange (*)(id, SEL, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3) );")
  (define-c-lambda %msg-p->p ((pointer void) (pointer void) (pointer void)) (pointer void)
    "___return( ((id (*)(id, SEL, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3) );")
  (define-c-lambda %msg-p->v ((pointer void) (pointer void) (pointer void)) void
    "((void (*)(id, SEL, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3);")
  (define-c-lambda %msg-p-b->p ((pointer void) (pointer void) (pointer void) bool) (pointer void)
    "___return( ((id (*)(id, SEL, id, BOOL))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4) );")
  (define-c-lambda %msg-p-b-u64-pp->b-e ((pointer void) (pointer void) (pointer void) bool unsigned-int64 (pointer (pointer void))) bool
    "___return( ((BOOL (*)(id, SEL, id, BOOL, uint64_t, id*))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4, ___arg5, (id*)___arg6) );")
  (define-c-lambda %msg-p-p->p ((pointer void) (pointer void) (pointer void) (pointer void)) (pointer void)
    "___return( ((id (*)(id, SEL, id, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4) );")
  (define-c-lambda %msg-p-p-pp->p-e ((pointer void) (pointer void) (pointer void) (pointer void) (pointer (pointer void))) (pointer void)
    "___return( ((id (*)(id, SEL, id, id, id*))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4, (id*)___arg5) );")
  (define-c-lambda %msg-p-p-u64-nsrange->p ((pointer void) (pointer void) (pointer void) (pointer void) unsigned-int64 NSRange) (pointer void)
    "___return( ((id (*)(id, SEL, id, id, uint64_t, NSRange))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4, ___arg5, ___arg6) );")
  (define-c-lambda %msg-p-u64->i64 ((pointer void) (pointer void) (pointer void) unsigned-int64) int64
    "___return( ((int64_t (*)(id, SEL, id, uint64_t))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4) );")
  (define-c-lambda %msg-p-u64->nsrange ((pointer void) (pointer void) (pointer void) unsigned-int64) NSRange
    "___return( ((NSRange (*)(id, SEL, id, uint64_t))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4) );")
  (define-c-lambda %msg-p-u64->p ((pointer void) (pointer void) (pointer void) unsigned-int64) (pointer void)
    "___return( ((id (*)(id, SEL, id, uint64_t))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4) );")
  (define-c-lambda %msg-p-u64-nsrange->i64 ((pointer void) (pointer void) (pointer void) unsigned-int64 NSRange) int64
    "___return( ((int64_t (*)(id, SEL, id, uint64_t, NSRange))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4, ___arg5) );")
  (define-c-lambda %msg-p-u64-nsrange->nsrange ((pointer void) (pointer void) (pointer void) unsigned-int64 NSRange) NSRange
    "___return( ((NSRange (*)(id, SEL, id, uint64_t, NSRange))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4, ___arg5) );")
  (define-c-lambda %msg-p-u64-nsrange-p->i64 ((pointer void) (pointer void) (pointer void) unsigned-int64 NSRange (pointer void)) int64
    "___return( ((int64_t (*)(id, SEL, id, uint64_t, NSRange, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4, ___arg5, ___arg6) );")
  (define-c-lambda %msg-p-u64-nsrange-p->nsrange ((pointer void) (pointer void) (pointer void) unsigned-int64 NSRange (pointer void)) NSRange
    "___return( ((NSRange (*)(id, SEL, id, uint64_t, NSRange, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4, ___arg5, ___arg6) );")
  (define-c-lambda %msg-p-u64-pp->p-e ((pointer void) (pointer void) (pointer void) unsigned-int64 (pointer (pointer void))) (pointer void)
    "___return( ((id (*)(id, SEL, id, uint64_t, id*))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4, (id*)___arg5) );")
  (define-c-lambda %msg-str->p ((pointer void) (pointer void) char-string) (pointer void)
    "___return( ((id (*)(id, SEL, const char*))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3) );")
  (define-c-lambda %msg-str-u64->p ((pointer void) (pointer void) char-string unsigned-int64) (pointer void)
    "___return( ((id (*)(id, SEL, const char*, uint64_t))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4) );")
  (define-c-lambda %msg-u64->b ((pointer void) (pointer void) unsigned-int64) bool
    "___return( ((BOOL (*)(id, SEL, uint64_t))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3) );")
  (define-c-lambda %msg-u64->nsrange ((pointer void) (pointer void) unsigned-int64) NSRange
    "___return( ((NSRange (*)(id, SEL, uint64_t))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3) );")
  (define-c-lambda %msg-u64->p ((pointer void) (pointer void) unsigned-int64) (pointer void)
    "___return( ((id (*)(id, SEL, uint64_t))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3) );")
  (define-c-lambda %msg-u64->str ((pointer void) (pointer void) unsigned-int64) char-string
    "___return( ___CAST(char*, ((const char* (*)(id, SEL, uint64_t))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3)) );")
  (define-c-lambda %msg-u64->u16 ((pointer void) (pointer void) unsigned-int64) unsigned-int16
    "___return( ((uint16_t (*)(id, SEL, uint64_t))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3) );")
  (define-c-lambda %msg-u64->u64 ((pointer void) (pointer void) unsigned-int64) unsigned-int64
    "___return( ((uint64_t (*)(id, SEL, uint64_t))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3) );")
  (define-c-lambda %msg-u64-b->p ((pointer void) (pointer void) unsigned-int64 bool) (pointer void)
    "___return( ((id (*)(id, SEL, uint64_t, BOOL))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4) );")
  (define-c-lambda %msg-u64-p->p ((pointer void) (pointer void) unsigned-int64 (pointer void)) (pointer void)
    "___return( ((id (*)(id, SEL, uint64_t, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4) );")
  (define-c-lambda %msg-u64-p-u64->p ((pointer void) (pointer void) unsigned-int64 (pointer void) unsigned-int64) (pointer void)
    "___return( ((id (*)(id, SEL, uint64_t, id, uint64_t))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4, ___arg5) );")
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
(define %sel-nsstring-init-with-utf8-string (sel_registerName "initWithUTF8String:"))
(define %sel-nsstring-init-with-string (sel_registerName "initWithString:"))
(define %sel-nsstring-init-with-data-encoding (sel_registerName "initWithData:encoding:"))
(define %sel-nsstring-init-with-c-string-encoding (sel_registerName "initWithCString:encoding:"))
(define %sel-nsstring-character-at-index (sel_registerName "characterAtIndex:"))
(define %sel-nsstring-substring-from-index (sel_registerName "substringFromIndex:"))
(define %sel-nsstring-substring-to-index (sel_registerName "substringToIndex:"))
(define %sel-nsstring-substring-with-range (sel_registerName "substringWithRange:"))
(define %sel-nsstring-compare (sel_registerName "compare:"))
(define %sel-nsstring-compare-options (sel_registerName "compare:options:"))
(define %sel-nsstring-compare-options-range (sel_registerName "compare:options:range:"))
(define %sel-nsstring-compare-options-range-locale (sel_registerName "compare:options:range:locale:"))
(define %sel-nsstring-case-insensitive-compare (sel_registerName "caseInsensitiveCompare:"))
(define %sel-nsstring-localized-compare (sel_registerName "localizedCompare:"))
(define %sel-nsstring-localized-case-insensitive-compare (sel_registerName "localizedCaseInsensitiveCompare:"))
(define %sel-nsstring-localized-standard-compare (sel_registerName "localizedStandardCompare:"))
(define %sel-nsstring-is-equal-to-string (sel_registerName "isEqualToString:"))
(define %sel-nsstring-has-prefix (sel_registerName "hasPrefix:"))
(define %sel-nsstring-has-suffix (sel_registerName "hasSuffix:"))
(define %sel-nsstring-common-prefix-with-string-options (sel_registerName "commonPrefixWithString:options:"))
(define %sel-nsstring-contains-string (sel_registerName "containsString:"))
(define %sel-nsstring-localized-case-insensitive-contains-string (sel_registerName "localizedCaseInsensitiveContainsString:"))
(define %sel-nsstring-localized-standard-contains-string (sel_registerName "localizedStandardContainsString:"))
(define %sel-nsstring-localized-standard-range-of-string (sel_registerName "localizedStandardRangeOfString:"))
(define %sel-nsstring-range-of-string (sel_registerName "rangeOfString:"))
(define %sel-nsstring-range-of-string-options (sel_registerName "rangeOfString:options:"))
(define %sel-nsstring-range-of-string-options-range (sel_registerName "rangeOfString:options:range:"))
(define %sel-nsstring-range-of-string-options-range-locale (sel_registerName "rangeOfString:options:range:locale:"))
(define %sel-nsstring-range-of-character-from-set (sel_registerName "rangeOfCharacterFromSet:"))
(define %sel-nsstring-range-of-character-from-set-options (sel_registerName "rangeOfCharacterFromSet:options:"))
(define %sel-nsstring-range-of-character-from-set-options-range (sel_registerName "rangeOfCharacterFromSet:options:range:"))
(define %sel-nsstring-range-of-composed-character-sequence-at-index (sel_registerName "rangeOfComposedCharacterSequenceAtIndex:"))
(define %sel-nsstring-range-of-composed-character-sequences-for-range (sel_registerName "rangeOfComposedCharacterSequencesForRange:"))
(define %sel-nsstring-string-by-appending-string (sel_registerName "stringByAppendingString:"))
(define %sel-nsstring-uppercase-string-with-locale (sel_registerName "uppercaseStringWithLocale:"))
(define %sel-nsstring-lowercase-string-with-locale (sel_registerName "lowercaseStringWithLocale:"))
(define %sel-nsstring-capitalized-string-with-locale (sel_registerName "capitalizedStringWithLocale:"))
(define %sel-nsstring-line-range-for-range (sel_registerName "lineRangeForRange:"))
(define %sel-nsstring-paragraph-range-for-range (sel_registerName "paragraphRangeForRange:"))
(define %sel-nsstring-enumerate-lines-using-block (sel_registerName "enumerateLinesUsingBlock:"))
(define %sel-nsstring-data-using-encoding-allow-lossy-conversion (sel_registerName "dataUsingEncoding:allowLossyConversion:"))
(define %sel-nsstring-data-using-encoding (sel_registerName "dataUsingEncoding:"))
(define %sel-nsstring-can-be-converted-to-encoding (sel_registerName "canBeConvertedToEncoding:"))
(define %sel-nsstring-c-string-using-encoding (sel_registerName "cStringUsingEncoding:"))
(define %sel-nsstring-maximum-length-of-bytes-using-encoding (sel_registerName "maximumLengthOfBytesUsingEncoding:"))
(define %sel-nsstring-length-of-bytes-using-encoding (sel_registerName "lengthOfBytesUsingEncoding:"))
(define %sel-nsstring-components-separated-by-string (sel_registerName "componentsSeparatedByString:"))
(define %sel-nsstring-components-separated-by-characters-in-set (sel_registerName "componentsSeparatedByCharactersInSet:"))
(define %sel-nsstring-string-by-trimming-characters-in-set (sel_registerName "stringByTrimmingCharactersInSet:"))
(define %sel-nsstring-string-by-padding-to-length-with-string-starting-at-index (sel_registerName "stringByPaddingToLength:withString:startingAtIndex:"))
(define %sel-nsstring-string-by-folding-with-options-locale (sel_registerName "stringByFoldingWithOptions:locale:"))
(define %sel-nsstring-string-by-replacing-occurrences-of-string-with-string-options-range (sel_registerName "stringByReplacingOccurrencesOfString:withString:options:range:"))
(define %sel-nsstring-string-by-replacing-occurrences-of-string-with-string (sel_registerName "stringByReplacingOccurrencesOfString:withString:"))
(define %sel-nsstring-string-by-replacing-characters-in-range-with-string (sel_registerName "stringByReplacingCharactersInRange:withString:"))
(define %sel-nsstring-string-by-applying-transform-reverse (sel_registerName "stringByApplyingTransform:reverse:"))
(define %sel-nsstring-write-to-url-atomically-encoding-error (sel_registerName "writeToURL:atomically:encoding:error:"))
(define %sel-nsstring-write-to-file-atomically-encoding-error (sel_registerName "writeToFile:atomically:encoding:error:"))
(define %sel-nsstring-property-list (sel_registerName "propertyList"))
(define %sel-nsstring-property-list-from-strings-file-format (sel_registerName "propertyListFromStringsFileFormat"))
(define %sel-nsstring-variant-fitting-presentation-width (sel_registerName "variantFittingPresentationWidth:"))
(define %sel-nsstring-string-by-appending-path-component (sel_registerName "stringByAppendingPathComponent:"))
(define %sel-nsstring-string-by-appending-path-extension (sel_registerName "stringByAppendingPathExtension:"))
(define %sel-nsstring-strings-by-appending-paths (sel_registerName "stringsByAppendingPaths:"))
(define %sel-nsstring-is-absolute-path (sel_registerName "isAbsolutePath"))
(define %sel-nsstring-string-by-adding-percent-encoding-with-allowed-characters (sel_registerName "stringByAddingPercentEncodingWithAllowedCharacters:"))
(define %sel-nsstring-encode-with-coder (sel_registerName "encodeWithCoder:"))
(define %sel-nsstring-item-provider-visibility-for-representation-with-type-identifier (sel_registerName "itemProviderVisibilityForRepresentationWithTypeIdentifier:"))
(define %sel-nsstring-load-data-with-type-identifier-for-item-provider-completion-handler (sel_registerName "loadDataWithTypeIdentifier:forItemProviderCompletionHandler:"))
(define %sel-nsstring-writable-type-identifiers-for-item-provider (sel_registerName "writableTypeIdentifiersForItemProvider"))
(define %sel-nsstring-localized-name-of-string-encoding (sel_registerName "localizedNameOfStringEncoding:"))
(define %sel-nsstring-string (sel_registerName "string"))
(define %sel-nsstring-string-with-string (sel_registerName "stringWithString:"))
(define %sel-nsstring-string-with-utf8-string (sel_registerName "stringWithUTF8String:"))
(define %sel-nsstring-string-with-c-string-encoding (sel_registerName "stringWithCString:encoding:"))
(define %sel-nsstring-string-with-contents-of-url-encoding-error (sel_registerName "stringWithContentsOfURL:encoding:error:"))
(define %sel-nsstring-string-with-contents-of-file-encoding-error (sel_registerName "stringWithContentsOfFile:encoding:error:"))
(define %sel-nsstring-path-with-components (sel_registerName "pathWithComponents:"))
(define %sel-nsstring-object-with-item-provider-data-type-identifier-error (sel_registerName "objectWithItemProviderData:typeIdentifier:error:"))
(define %sel-nsstring-readable-type-identifiers-for-item-provider (sel_registerName "readableTypeIdentifiersForItemProvider"))
(define %sel-nsstring-supports-secure-coding (sel_registerName "supportsSecureCoding"))
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

(define (make-nsstring-init-with-utf8-string null-terminated-c-string)
  (wrap (%msg-str->p (%msg-v->p (objc_getClass "NSString") (sel_registerName "alloc")) %sel-nsstring-init-with-utf8-string null-terminated-c-string) #t))

(define (make-nsstring-init-with-string a-string)
  (wrap (%msg-p->p (%msg-v->p (objc_getClass "NSString") (sel_registerName "alloc")) %sel-nsstring-init-with-string (->ptr a-string)) #t))

(define (make-nsstring-init-with-data-encoding data encoding)
  (wrap (%msg-p-u64->p (%msg-v->p (objc_getClass "NSString") (sel_registerName "alloc")) %sel-nsstring-init-with-data-encoding (->ptr data) encoding) #t))

(define (make-nsstring-init-with-c-string-encoding null-terminated-c-string encoding)
  (wrap (%msg-str-u64->p (%msg-v->p (objc_getClass "NSString") (sel_registerName "alloc")) %sel-nsstring-init-with-c-string-encoding null-terminated-c-string encoding) #t))

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

(define (nsstring-substring-from-index self from)
  (wrap (%msg-u64->p (NSObject-ptr self) %sel-nsstring-substring-from-index from)))
(defmethod {substring-from-index NSString} (lambda (self from) (nsstring-substring-from-index self from)))

(define (nsstring-substring-to-index self to)
  (wrap (%msg-u64->p (NSObject-ptr self) %sel-nsstring-substring-to-index to)))
(defmethod {substring-to-index NSString} (lambda (self to) (nsstring-substring-to-index self to)))

(define (nsstring-substring-with-range self range)
  (wrap (%msg-nsrange->p (NSObject-ptr self) %sel-nsstring-substring-with-range range)))
(defmethod {substring-with-range NSString} (lambda (self range) (nsstring-substring-with-range self range)))

(define (nsstring-compare self string)
  (%msg-p->i64 (NSObject-ptr self) %sel-nsstring-compare (->ptr string)))
(defmethod {compare NSString} (lambda (self string) (nsstring-compare self string)))

(define (nsstring-compare-options self string mask)
  (%msg-p-u64->i64 (NSObject-ptr self) %sel-nsstring-compare-options (->ptr string) mask))
(defmethod {compare-options NSString} (lambda (self string mask) (nsstring-compare-options self string mask)))

(define (nsstring-compare-options-range self string mask range-of-receiver-to-compare)
  (%msg-p-u64-nsrange->i64 (NSObject-ptr self) %sel-nsstring-compare-options-range (->ptr string) mask range-of-receiver-to-compare))
(defmethod {compare-options-range NSString} (lambda (self string mask range-of-receiver-to-compare) (nsstring-compare-options-range self string mask range-of-receiver-to-compare)))

(define (nsstring-compare-options-range-locale self string mask range-of-receiver-to-compare locale)
  (%msg-p-u64-nsrange-p->i64 (NSObject-ptr self) %sel-nsstring-compare-options-range-locale (->ptr string) mask range-of-receiver-to-compare (->ptr locale)))
(defmethod {compare-options-range-locale NSString} (lambda (self string mask range-of-receiver-to-compare locale) (nsstring-compare-options-range-locale self string mask range-of-receiver-to-compare locale)))

(define (nsstring-case-insensitive-compare self string)
  (%msg-p->i64 (NSObject-ptr self) %sel-nsstring-case-insensitive-compare (->ptr string)))
(defmethod {case-insensitive-compare NSString} (lambda (self string) (nsstring-case-insensitive-compare self string)))

(define (nsstring-localized-compare self string)
  (%msg-p->i64 (NSObject-ptr self) %sel-nsstring-localized-compare (->ptr string)))
(defmethod {localized-compare NSString} (lambda (self string) (nsstring-localized-compare self string)))

(define (nsstring-localized-case-insensitive-compare self string)
  (%msg-p->i64 (NSObject-ptr self) %sel-nsstring-localized-case-insensitive-compare (->ptr string)))
(defmethod {localized-case-insensitive-compare NSString} (lambda (self string) (nsstring-localized-case-insensitive-compare self string)))

(define (nsstring-localized-standard-compare self string)
  (%msg-p->i64 (NSObject-ptr self) %sel-nsstring-localized-standard-compare (->ptr string)))
(defmethod {localized-standard-compare NSString} (lambda (self string) (nsstring-localized-standard-compare self string)))

(define (nsstring-is-equal-to-string self a-string)
  (%msg-p->b (NSObject-ptr self) %sel-nsstring-is-equal-to-string (->ptr a-string)))
(defmethod {is-equal-to-string NSString} (lambda (self a-string) (nsstring-is-equal-to-string self a-string)))

(define (nsstring-has-prefix self str)
  (%msg-p->b (NSObject-ptr self) %sel-nsstring-has-prefix (->ptr str)))
(defmethod {has-prefix NSString} (lambda (self str) (nsstring-has-prefix self str)))

(define (nsstring-has-suffix self str)
  (%msg-p->b (NSObject-ptr self) %sel-nsstring-has-suffix (->ptr str)))
(defmethod {has-suffix NSString} (lambda (self str) (nsstring-has-suffix self str)))

(define (nsstring-common-prefix-with-string-options self str mask)
  (wrap (%msg-p-u64->p (NSObject-ptr self) %sel-nsstring-common-prefix-with-string-options (->ptr str) mask)))
(defmethod {common-prefix-with-string-options NSString} (lambda (self str mask) (nsstring-common-prefix-with-string-options self str mask)))

(define (nsstring-contains-string self str)
  (%msg-p->b (NSObject-ptr self) %sel-nsstring-contains-string (->ptr str)))
(defmethod {contains-string NSString} (lambda (self str) (nsstring-contains-string self str)))

(define (nsstring-localized-case-insensitive-contains-string self str)
  (%msg-p->b (NSObject-ptr self) %sel-nsstring-localized-case-insensitive-contains-string (->ptr str)))
(defmethod {localized-case-insensitive-contains-string NSString} (lambda (self str) (nsstring-localized-case-insensitive-contains-string self str)))

(define (nsstring-localized-standard-contains-string self str)
  (%msg-p->b (NSObject-ptr self) %sel-nsstring-localized-standard-contains-string (->ptr str)))
(defmethod {localized-standard-contains-string NSString} (lambda (self str) (nsstring-localized-standard-contains-string self str)))

(define (nsstring-localized-standard-range-of-string self str)
  (%msg-p->nsrange (NSObject-ptr self) %sel-nsstring-localized-standard-range-of-string (->ptr str)))
(defmethod {localized-standard-range-of-string NSString} (lambda (self str) (nsstring-localized-standard-range-of-string self str)))

(define (nsstring-range-of-string self search-string)
  (%msg-p->nsrange (NSObject-ptr self) %sel-nsstring-range-of-string (->ptr search-string)))
(defmethod {range-of-string NSString} (lambda (self search-string) (nsstring-range-of-string self search-string)))

(define (nsstring-range-of-string-options self search-string mask)
  (%msg-p-u64->nsrange (NSObject-ptr self) %sel-nsstring-range-of-string-options (->ptr search-string) mask))
(defmethod {range-of-string-options NSString} (lambda (self search-string mask) (nsstring-range-of-string-options self search-string mask)))

(define (nsstring-range-of-string-options-range self search-string mask range-of-receiver-to-search)
  (%msg-p-u64-nsrange->nsrange (NSObject-ptr self) %sel-nsstring-range-of-string-options-range (->ptr search-string) mask range-of-receiver-to-search))
(defmethod {range-of-string-options-range NSString} (lambda (self search-string mask range-of-receiver-to-search) (nsstring-range-of-string-options-range self search-string mask range-of-receiver-to-search)))

(define (nsstring-range-of-string-options-range-locale self search-string mask range-of-receiver-to-search locale)
  (%msg-p-u64-nsrange-p->nsrange (NSObject-ptr self) %sel-nsstring-range-of-string-options-range-locale (->ptr search-string) mask range-of-receiver-to-search (->ptr locale)))
(defmethod {range-of-string-options-range-locale NSString} (lambda (self search-string mask range-of-receiver-to-search locale) (nsstring-range-of-string-options-range-locale self search-string mask range-of-receiver-to-search locale)))

(define (nsstring-range-of-character-from-set self search-set)
  (%msg-p->nsrange (NSObject-ptr self) %sel-nsstring-range-of-character-from-set (->ptr search-set)))
(defmethod {range-of-character-from-set NSString} (lambda (self search-set) (nsstring-range-of-character-from-set self search-set)))

(define (nsstring-range-of-character-from-set-options self search-set mask)
  (%msg-p-u64->nsrange (NSObject-ptr self) %sel-nsstring-range-of-character-from-set-options (->ptr search-set) mask))
(defmethod {range-of-character-from-set-options NSString} (lambda (self search-set mask) (nsstring-range-of-character-from-set-options self search-set mask)))

(define (nsstring-range-of-character-from-set-options-range self search-set mask range-of-receiver-to-search)
  (%msg-p-u64-nsrange->nsrange (NSObject-ptr self) %sel-nsstring-range-of-character-from-set-options-range (->ptr search-set) mask range-of-receiver-to-search))
(defmethod {range-of-character-from-set-options-range NSString} (lambda (self search-set mask range-of-receiver-to-search) (nsstring-range-of-character-from-set-options-range self search-set mask range-of-receiver-to-search)))

(define (nsstring-range-of-composed-character-sequence-at-index self index)
  (%msg-u64->nsrange (NSObject-ptr self) %sel-nsstring-range-of-composed-character-sequence-at-index index))
(defmethod {range-of-composed-character-sequence-at-index NSString} (lambda (self index) (nsstring-range-of-composed-character-sequence-at-index self index)))

(define (nsstring-range-of-composed-character-sequences-for-range self range)
  (%msg-nsrange->nsrange (NSObject-ptr self) %sel-nsstring-range-of-composed-character-sequences-for-range range))
(defmethod {range-of-composed-character-sequences-for-range NSString} (lambda (self range) (nsstring-range-of-composed-character-sequences-for-range self range)))

(define (nsstring-string-by-appending-string self a-string)
  (wrap (%msg-p->p (NSObject-ptr self) %sel-nsstring-string-by-appending-string (->ptr a-string))))
(defmethod {string-by-appending-string NSString} (lambda (self a-string) (nsstring-string-by-appending-string self a-string)))

(define (nsstring-uppercase-string-with-locale self locale)
  (wrap (%msg-p->p (NSObject-ptr self) %sel-nsstring-uppercase-string-with-locale (->ptr locale))))
(defmethod {uppercase-string-with-locale NSString} (lambda (self locale) (nsstring-uppercase-string-with-locale self locale)))

(define (nsstring-lowercase-string-with-locale self locale)
  (wrap (%msg-p->p (NSObject-ptr self) %sel-nsstring-lowercase-string-with-locale (->ptr locale))))
(defmethod {lowercase-string-with-locale NSString} (lambda (self locale) (nsstring-lowercase-string-with-locale self locale)))

(define (nsstring-capitalized-string-with-locale self locale)
  (wrap (%msg-p->p (NSObject-ptr self) %sel-nsstring-capitalized-string-with-locale (->ptr locale))))
(defmethod {capitalized-string-with-locale NSString} (lambda (self locale) (nsstring-capitalized-string-with-locale self locale)))

(define (nsstring-line-range-for-range self range)
  (%msg-nsrange->nsrange (NSObject-ptr self) %sel-nsstring-line-range-for-range range))
(defmethod {line-range-for-range NSString} (lambda (self range) (nsstring-line-range-for-range self range)))

(define (nsstring-paragraph-range-for-range self range)
  (%msg-nsrange->nsrange (NSObject-ptr self) %sel-nsstring-paragraph-range-for-range range))
(defmethod {paragraph-range-for-range NSString} (lambda (self range) (nsstring-paragraph-range-for-range self range)))

(define (nsstring-enumerate-lines-using-block self block)
  (%msg-p->v (NSObject-ptr self) %sel-nsstring-enumerate-lines-using-block block))
(defmethod {enumerate-lines-using-block NSString} (lambda (self block) (nsstring-enumerate-lines-using-block self block)))

(define (nsstring-data-using-encoding-allow-lossy-conversion self encoding lossy)
  (wrap (%msg-u64-b->p (NSObject-ptr self) %sel-nsstring-data-using-encoding-allow-lossy-conversion encoding lossy)))
(defmethod {data-using-encoding-allow-lossy-conversion NSString} (lambda (self encoding lossy) (nsstring-data-using-encoding-allow-lossy-conversion self encoding lossy)))

(define (nsstring-data-using-encoding self encoding)
  (wrap (%msg-u64->p (NSObject-ptr self) %sel-nsstring-data-using-encoding encoding)))
(defmethod {data-using-encoding NSString} (lambda (self encoding) (nsstring-data-using-encoding self encoding)))

(define (nsstring-can-be-converted-to-encoding self encoding)
  (%msg-u64->b (NSObject-ptr self) %sel-nsstring-can-be-converted-to-encoding encoding))
(defmethod {can-be-converted-to-encoding NSString} (lambda (self encoding) (nsstring-can-be-converted-to-encoding self encoding)))

(define (nsstring-c-string-using-encoding self encoding)
  (%msg-u64->str (NSObject-ptr self) %sel-nsstring-c-string-using-encoding encoding))
(defmethod {c-string-using-encoding NSString} (lambda (self encoding) (nsstring-c-string-using-encoding self encoding)))

(define (nsstring-maximum-length-of-bytes-using-encoding self enc)
  (%msg-u64->u64 (NSObject-ptr self) %sel-nsstring-maximum-length-of-bytes-using-encoding enc))
(defmethod {maximum-length-of-bytes-using-encoding NSString} (lambda (self enc) (nsstring-maximum-length-of-bytes-using-encoding self enc)))

(define (nsstring-length-of-bytes-using-encoding self enc)
  (%msg-u64->u64 (NSObject-ptr self) %sel-nsstring-length-of-bytes-using-encoding enc))
(defmethod {length-of-bytes-using-encoding NSString} (lambda (self enc) (nsstring-length-of-bytes-using-encoding self enc)))

(define (nsstring-components-separated-by-string self separator)
  (wrap (%msg-p->p (NSObject-ptr self) %sel-nsstring-components-separated-by-string (->ptr separator))))
(defmethod {components-separated-by-string NSString} (lambda (self separator) (nsstring-components-separated-by-string self separator)))

(define (nsstring-components-separated-by-characters-in-set self separator)
  (wrap (%msg-p->p (NSObject-ptr self) %sel-nsstring-components-separated-by-characters-in-set (->ptr separator))))
(defmethod {components-separated-by-characters-in-set NSString} (lambda (self separator) (nsstring-components-separated-by-characters-in-set self separator)))

(define (nsstring-string-by-trimming-characters-in-set self set)
  (wrap (%msg-p->p (NSObject-ptr self) %sel-nsstring-string-by-trimming-characters-in-set (->ptr set))))
(defmethod {string-by-trimming-characters-in-set NSString} (lambda (self set) (nsstring-string-by-trimming-characters-in-set self set)))

(define (nsstring-string-by-padding-to-length-with-string-starting-at-index self new-length pad-string pad-index)
  (wrap (%msg-u64-p-u64->p (NSObject-ptr self) %sel-nsstring-string-by-padding-to-length-with-string-starting-at-index new-length (->ptr pad-string) pad-index)))
(defmethod {string-by-padding-to-length-with-string-starting-at-index NSString} (lambda (self new-length pad-string pad-index) (nsstring-string-by-padding-to-length-with-string-starting-at-index self new-length pad-string pad-index)))

(define (nsstring-string-by-folding-with-options-locale self options locale)
  (wrap (%msg-u64-p->p (NSObject-ptr self) %sel-nsstring-string-by-folding-with-options-locale options (->ptr locale))))
(defmethod {string-by-folding-with-options-locale NSString} (lambda (self options locale) (nsstring-string-by-folding-with-options-locale self options locale)))

(define (nsstring-string-by-replacing-occurrences-of-string-with-string-options-range self target replacement options search-range)
  (wrap (%msg-p-p-u64-nsrange->p (NSObject-ptr self) %sel-nsstring-string-by-replacing-occurrences-of-string-with-string-options-range (->ptr target) (->ptr replacement) options search-range)))
(defmethod {string-by-replacing-occurrences-of-string-with-string-options-range NSString} (lambda (self target replacement options search-range) (nsstring-string-by-replacing-occurrences-of-string-with-string-options-range self target replacement options search-range)))

(define (nsstring-string-by-replacing-occurrences-of-string-with-string self target replacement)
  (wrap (%msg-p-p->p (NSObject-ptr self) %sel-nsstring-string-by-replacing-occurrences-of-string-with-string (->ptr target) (->ptr replacement))))
(defmethod {string-by-replacing-occurrences-of-string-with-string NSString} (lambda (self target replacement) (nsstring-string-by-replacing-occurrences-of-string-with-string self target replacement)))

(define (nsstring-string-by-replacing-characters-in-range-with-string self range replacement)
  (wrap (%msg-nsrange-p->p (NSObject-ptr self) %sel-nsstring-string-by-replacing-characters-in-range-with-string range (->ptr replacement))))
(defmethod {string-by-replacing-characters-in-range-with-string NSString} (lambda (self range replacement) (nsstring-string-by-replacing-characters-in-range-with-string self range replacement)))

(define (nsstring-string-by-applying-transform-reverse self transform reverse)
  (wrap (%msg-p-b->p (NSObject-ptr self) %sel-nsstring-string-by-applying-transform-reverse (->ptr transform) reverse)))
(defmethod {string-by-applying-transform-reverse NSString} (lambda (self transform reverse) (nsstring-string-by-applying-transform-reverse self transform reverse)))

(define (nsstring-write-to-url-atomically-encoding-error self url use-auxiliary-file enc)
  (call-with-nserror-out
    (lambda (%err-cell)
      (%msg-p-b-u64-pp->b-e (NSObject-ptr self) %sel-nsstring-write-to-url-atomically-encoding-error (->ptr url) use-auxiliary-file enc %err-cell))))
(defmethod {write-to-url-atomically-encoding-error NSString} (lambda (self url use-auxiliary-file enc) (nsstring-write-to-url-atomically-encoding-error self url use-auxiliary-file enc)))

(define (nsstring-write-to-file-atomically-encoding-error self path use-auxiliary-file enc)
  (call-with-nserror-out
    (lambda (%err-cell)
      (%msg-p-b-u64-pp->b-e (NSObject-ptr self) %sel-nsstring-write-to-file-atomically-encoding-error (->ptr path) use-auxiliary-file enc %err-cell))))
(defmethod {write-to-file-atomically-encoding-error NSString} (lambda (self path use-auxiliary-file enc) (nsstring-write-to-file-atomically-encoding-error self path use-auxiliary-file enc)))

(define (nsstring-property-list self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsstring-property-list)))
(defmethod {property-list NSString} (lambda (self) (nsstring-property-list self)))
(g:defmethod (property-list (o NSString)) (nsstring-property-list o))

(define (nsstring-property-list-from-strings-file-format self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsstring-property-list-from-strings-file-format)))
(defmethod {property-list-from-strings-file-format NSString} (lambda (self) (nsstring-property-list-from-strings-file-format self)))
(g:defmethod (property-list-from-strings-file-format (o NSString)) (nsstring-property-list-from-strings-file-format o))

(define (nsstring-variant-fitting-presentation-width self width)
  (wrap (%msg-i64->p (NSObject-ptr self) %sel-nsstring-variant-fitting-presentation-width width)))
(defmethod {variant-fitting-presentation-width NSString} (lambda (self width) (nsstring-variant-fitting-presentation-width self width)))

(define (nsstring-string-by-appending-path-component self str)
  (wrap (%msg-p->p (NSObject-ptr self) %sel-nsstring-string-by-appending-path-component (->ptr str))))
(defmethod {string-by-appending-path-component NSString} (lambda (self str) (nsstring-string-by-appending-path-component self str)))

(define (nsstring-string-by-appending-path-extension self str)
  (wrap (%msg-p->p (NSObject-ptr self) %sel-nsstring-string-by-appending-path-extension (->ptr str))))
(defmethod {string-by-appending-path-extension NSString} (lambda (self str) (nsstring-string-by-appending-path-extension self str)))

(define (nsstring-strings-by-appending-paths self paths)
  (wrap (%msg-p->p (NSObject-ptr self) %sel-nsstring-strings-by-appending-paths (->ptr paths))))
(defmethod {strings-by-appending-paths NSString} (lambda (self paths) (nsstring-strings-by-appending-paths self paths)))

(define (nsstring-is-absolute-path self)
  (%msg-v->b (NSObject-ptr self) %sel-nsstring-is-absolute-path))
(defmethod {is-absolute-path NSString} (lambda (self) (nsstring-is-absolute-path self)))
(g:defmethod (is-absolute-path (o NSString)) (nsstring-is-absolute-path o))

(define (nsstring-string-by-adding-percent-encoding-with-allowed-characters self allowed-characters)
  (wrap (%msg-p->p (NSObject-ptr self) %sel-nsstring-string-by-adding-percent-encoding-with-allowed-characters (->ptr allowed-characters))))
(defmethod {string-by-adding-percent-encoding-with-allowed-characters NSString} (lambda (self allowed-characters) (nsstring-string-by-adding-percent-encoding-with-allowed-characters self allowed-characters)))

(define (nsstring-encode-with-coder self coder)
  (%msg-p->v (NSObject-ptr self) %sel-nsstring-encode-with-coder (->ptr coder)))
(defmethod {encode-with-coder NSString} (lambda (self coder) (nsstring-encode-with-coder self coder)))

(define (nsstring-item-provider-visibility-for-representation-with-type-identifier self type-identifier)
  (%msg-p->i64 (NSObject-ptr self) %sel-nsstring-item-provider-visibility-for-representation-with-type-identifier (->ptr type-identifier)))
(defmethod {item-provider-visibility-for-representation-with-type-identifier NSString} (lambda (self type-identifier) (nsstring-item-provider-visibility-for-representation-with-type-identifier self type-identifier)))

(define (nsstring-load-data-with-type-identifier-for-item-provider-completion-handler self type-identifier completion-handler)
  (wrap (%msg-p-p->p (NSObject-ptr self) %sel-nsstring-load-data-with-type-identifier-for-item-provider-completion-handler (->ptr type-identifier) completion-handler)))
(defmethod {load-data-with-type-identifier-for-item-provider-completion-handler NSString} (lambda (self type-identifier completion-handler) (nsstring-load-data-with-type-identifier-for-item-provider-completion-handler self type-identifier completion-handler)))

(define (nsstring-writable-type-identifiers-for-item-provider self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsstring-writable-type-identifiers-for-item-provider)))
(defmethod {writable-type-identifiers-for-item-provider NSString} (lambda (self) (nsstring-writable-type-identifiers-for-item-provider self)))
(g:defmethod (writable-type-identifiers-for-item-provider (o NSString)) (nsstring-writable-type-identifiers-for-item-provider o))

;; --- Class methods ---
(define (nsstring-localized-name-of-string-encoding encoding)
  (wrap (%msg-u64->p (objc_getClass "NSString") %sel-nsstring-localized-name-of-string-encoding encoding)))

(define (nsstring-string)
  (wrap (%msg-v->p (objc_getClass "NSString") %sel-nsstring-string)))

(define (nsstring-string-with-string string)
  (wrap (%msg-p->p (objc_getClass "NSString") %sel-nsstring-string-with-string (->ptr string))))

(define (nsstring-string-with-utf8-string null-terminated-c-string)
  (wrap (%msg-str->p (objc_getClass "NSString") %sel-nsstring-string-with-utf8-string null-terminated-c-string)))

(define (nsstring-string-with-c-string-encoding c-string enc)
  (wrap (%msg-str-u64->p (objc_getClass "NSString") %sel-nsstring-string-with-c-string-encoding c-string enc)))

(define (nsstring-string-with-contents-of-url-encoding-error url enc)
  (call-with-nserror-out
    (lambda (%err-cell)
      (wrap (%msg-p-u64-pp->p-e (objc_getClass "NSString") %sel-nsstring-string-with-contents-of-url-encoding-error (->ptr url) enc %err-cell)))))

(define (nsstring-string-with-contents-of-file-encoding-error path enc)
  (call-with-nserror-out
    (lambda (%err-cell)
      (wrap (%msg-p-u64-pp->p-e (objc_getClass "NSString") %sel-nsstring-string-with-contents-of-file-encoding-error (->ptr path) enc %err-cell)))))

(define (nsstring-path-with-components components)
  (wrap (%msg-p->p (objc_getClass "NSString") %sel-nsstring-path-with-components (->ptr components))))

(define (nsstring-object-with-item-provider-data-type-identifier-error data type-identifier)
  (call-with-nserror-out
    (lambda (%err-cell)
      (wrap (%msg-p-p-pp->p-e (objc_getClass "NSString") %sel-nsstring-object-with-item-provider-data-type-identifier-error (->ptr data) (->ptr type-identifier) %err-cell)))))

(define (nsstring-readable-type-identifiers-for-item-provider)
  (wrap (%msg-v->p (objc_getClass "NSString") %sel-nsstring-readable-type-identifiers-for-item-provider)))

(define (nsstring-supports-secure-coding)
  (%msg-v->b (objc_getClass "NSString") %sel-nsstring-supports-secure-coding))

;; --- Swift-native methods (receiver-handle trampolines, ADR-0030) ---
;; Trampolined through libAPIAnywareGerbil (aw_gerbil_swift_* entries),
;; not the framework dylib (ADR-0029); receiver coerced via (->ptr self).
(begin-ffi (
            %swift-make-nsstring-string
            )
  (c-declare "extern void * aw_gerbil_swift_init_Foundation_NSString_bd6dd38a(void *);")

  (define-c-lambda %swift-make-nsstring-string ((pointer void)) (pointer void) "aw_gerbil_swift_init_Foundation_NSString_bd6dd38a")
  )

(define make-nsstring-string
  (lambda (string)
    (wrap (%swift-make-nsstring-string (aw-swift-string-arg string)) #t)))

