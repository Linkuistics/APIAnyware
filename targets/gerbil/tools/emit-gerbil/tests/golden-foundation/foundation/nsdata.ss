;;; Generated binding for NSData (Foundation) — do not edit
(import :std/foreign
        (rename-in :std/generic (defgeneric g:defgeneric) (defmethod g:defmethod))
        :gerbil-bindings/generics
        :gerbil-bindings/runtime/objc)
(export
  NSData
  NSData?
  base64-encoded-data-with-options
  base64-encoded-string-with-options
  bytes
  compressed-data-using-algorithm-error
  decompressed-data-using-algorithm-error
  description
  encode-with-coder
  end-index
  is-equal-to-data
  length
  make-nsdata-init-with-base64-encoded-data-options
  make-nsdata-init-with-base64-encoded-string-options
  make-nsdata-init-with-coder
  make-nsdata-init-with-contents-of-file
  make-nsdata-init-with-contents-of-url
  make-nsdata-init-with-data
  nsdata-base64-encoded-data-with-options
  nsdata-base64-encoded-string-with-options
  nsdata-bytes
  nsdata-compressed-data-using-algorithm-error
  nsdata-data
  nsdata-data-with-contents-of-file
  nsdata-data-with-contents-of-url
  nsdata-data-with-data
  nsdata-decompressed-data-using-algorithm-error
  nsdata-description
  nsdata-encode-with-coder
  nsdata-end-index
  nsdata-is-equal-to-data
  nsdata-length
  nsdata-range-of-data-options-range
  nsdata-regions
  nsdata-start-index
  nsdata-subdata-with-range
  nsdata-supports-secure-coding
  nsdata-write-to-file-atomically
  nsdata-write-to-url-atomically
  range-of-data-options-range
  regions
  start-index
  subdata-with-range
  write-to-file-atomically
  write-to-url-atomically
  )

;; --- Class graph (ADR-0020) ---
(defclass (NSData NSObject) () transparent: #t)
(register-objc-class! (lambda (p) (make-NSData ptr: p)) NSData::t "NSData" "NSObject")

(begin-ffi (objc_getClass sel_registerName
            %msg-i64-pp->p-e
            %msg-nsrange->p
            %msg-p->b
            %msg-p->p
            %msg-p->v
            %msg-p-b->b
            %msg-p-u64->p
            %msg-p-u64-nsrange->nsrange
            %msg-u64->p
            %msg-v->b
            %msg-v->i64
            %msg-v->p
            %msg-v->u64
            )
  (c-declare "#include <objc/runtime.h>")
  (c-declare "#include <objc/message.h>")
  (c-declare "#include <stdint.h>")
  (c-declare "typedef struct _NSRange { unsigned long location; unsigned long length; } NSRange;")
  (c-define-type NSRange (struct "_NSRange"))

  (define-c-lambda objc_getClass (char-string) (pointer void) "objc_getClass")
  (define-c-lambda sel_registerName (char-string) (pointer void) "sel_registerName")
  (define-c-lambda %msg-i64-pp->p-e ((pointer void) (pointer void) int64 (pointer (pointer void))) (pointer void)
    "___return( ((id (*)(id, SEL, int64_t, id*))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, (id*)___arg4) );")
  (define-c-lambda %msg-nsrange->p ((pointer void) (pointer void) NSRange) (pointer void)
    "___return( ((id (*)(id, SEL, NSRange))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3) );")
  (define-c-lambda %msg-p->b ((pointer void) (pointer void) (pointer void)) bool
    "___return( ((BOOL (*)(id, SEL, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3) );")
  (define-c-lambda %msg-p->p ((pointer void) (pointer void) (pointer void)) (pointer void)
    "___return( ((id (*)(id, SEL, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3) );")
  (define-c-lambda %msg-p->v ((pointer void) (pointer void) (pointer void)) void
    "((void (*)(id, SEL, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3);")
  (define-c-lambda %msg-p-b->b ((pointer void) (pointer void) (pointer void) bool) bool
    "___return( ((BOOL (*)(id, SEL, id, BOOL))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4) );")
  (define-c-lambda %msg-p-u64->p ((pointer void) (pointer void) (pointer void) unsigned-int64) (pointer void)
    "___return( ((id (*)(id, SEL, id, uint64_t))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4) );")
  (define-c-lambda %msg-p-u64-nsrange->nsrange ((pointer void) (pointer void) (pointer void) unsigned-int64 NSRange) NSRange
    "___return( ((NSRange (*)(id, SEL, id, uint64_t, NSRange))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4, ___arg5) );")
  (define-c-lambda %msg-u64->p ((pointer void) (pointer void) unsigned-int64) (pointer void)
    "___return( ((id (*)(id, SEL, uint64_t))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3) );")
  (define-c-lambda %msg-v->b ((pointer void) (pointer void)) bool
    "___return( ((BOOL (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  (define-c-lambda %msg-v->i64 ((pointer void) (pointer void)) int64
    "___return( ((int64_t (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  (define-c-lambda %msg-v->p ((pointer void) (pointer void)) (pointer void)
    "___return( ((id (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  (define-c-lambda %msg-v->u64 ((pointer void) (pointer void)) unsigned-int64
    "___return( ((uint64_t (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  )

(define %sel-nsdata-init-with-contents-of-file (sel_registerName "initWithContentsOfFile:"))
(define %sel-nsdata-init-with-contents-of-url (sel_registerName "initWithContentsOfURL:"))
(define %sel-nsdata-init-with-data (sel_registerName "initWithData:"))
(define %sel-nsdata-init-with-base64-encoded-string-options (sel_registerName "initWithBase64EncodedString:options:"))
(define %sel-nsdata-init-with-base64-encoded-data-options (sel_registerName "initWithBase64EncodedData:options:"))
(define %sel-nsdata-init-with-coder (sel_registerName "initWithCoder:"))
(define %sel-nsdata-is-equal-to-data (sel_registerName "isEqualToData:"))
(define %sel-nsdata-subdata-with-range (sel_registerName "subdataWithRange:"))
(define %sel-nsdata-write-to-file-atomically (sel_registerName "writeToFile:atomically:"))
(define %sel-nsdata-write-to-url-atomically (sel_registerName "writeToURL:atomically:"))
(define %sel-nsdata-range-of-data-options-range (sel_registerName "rangeOfData:options:range:"))
(define %sel-nsdata-base64-encoded-string-with-options (sel_registerName "base64EncodedStringWithOptions:"))
(define %sel-nsdata-base64-encoded-data-with-options (sel_registerName "base64EncodedDataWithOptions:"))
(define %sel-nsdata-decompressed-data-using-algorithm-error (sel_registerName "decompressedDataUsingAlgorithm:error:"))
(define %sel-nsdata-compressed-data-using-algorithm-error (sel_registerName "compressedDataUsingAlgorithm:error:"))
(define %sel-nsdata-encode-with-coder (sel_registerName "encodeWithCoder:"))
(define %sel-nsdata-data (sel_registerName "data"))
(define %sel-nsdata-data-with-contents-of-file (sel_registerName "dataWithContentsOfFile:"))
(define %sel-nsdata-data-with-contents-of-url (sel_registerName "dataWithContentsOfURL:"))
(define %sel-nsdata-data-with-data (sel_registerName "dataWithData:"))
(define %sel-nsdata-supports-secure-coding (sel_registerName "supportsSecureCoding"))
(define %sel-nsdata-length (sel_registerName "length"))
(define %sel-nsdata-bytes (sel_registerName "bytes"))
(define %sel-nsdata-description (sel_registerName "description"))
(define %sel-nsdata-start-index (sel_registerName "startIndex"))
(define %sel-nsdata-end-index (sel_registerName "endIndex"))
(define %sel-nsdata-regions (sel_registerName "regions"))

;; --- Dispatch surfaces (ADR-0020): inlinable proc core; generics are
;;     declared once in :gerbil-bindings/generics and extended below ---
(declare (inline))

;; --- Constructors ---
(define (make-nsdata-init-with-contents-of-file path)
  (wrap (%msg-p->p (%msg-v->p (objc_getClass "NSData") (sel_registerName "alloc")) %sel-nsdata-init-with-contents-of-file (->ptr path)) #t))

(define (make-nsdata-init-with-contents-of-url url)
  (wrap (%msg-p->p (%msg-v->p (objc_getClass "NSData") (sel_registerName "alloc")) %sel-nsdata-init-with-contents-of-url (->ptr url)) #t))

(define (make-nsdata-init-with-data data)
  (wrap (%msg-p->p (%msg-v->p (objc_getClass "NSData") (sel_registerName "alloc")) %sel-nsdata-init-with-data (->ptr data)) #t))

(define (make-nsdata-init-with-base64-encoded-string-options base64-string options)
  (wrap (%msg-p-u64->p (%msg-v->p (objc_getClass "NSData") (sel_registerName "alloc")) %sel-nsdata-init-with-base64-encoded-string-options (->ptr base64-string) options) #t))

(define (make-nsdata-init-with-base64-encoded-data-options base64-data options)
  (wrap (%msg-p-u64->p (%msg-v->p (objc_getClass "NSData") (sel_registerName "alloc")) %sel-nsdata-init-with-base64-encoded-data-options (->ptr base64-data) options) #t))

(define (make-nsdata-init-with-coder coder)
  (wrap (%msg-p->p (%msg-v->p (objc_getClass "NSData") (sel_registerName "alloc")) %sel-nsdata-init-with-coder (->ptr coder)) #t))

;; --- Properties ---
(define (nsdata-length self)
  (%msg-v->u64 (NSObject-ptr self) %sel-nsdata-length))
(defmethod {length NSData} (lambda (self) (nsdata-length self)))
(g:defmethod (length (o NSData)) (nsdata-length o))

(define (nsdata-bytes self)
  (%msg-v->p (NSObject-ptr self) %sel-nsdata-bytes))
(defmethod {bytes NSData} (lambda (self) (nsdata-bytes self)))
(g:defmethod (bytes (o NSData)) (nsdata-bytes o))

(define (nsdata-description self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsdata-description)))
(defmethod {description NSData} (lambda (self) (nsdata-description self)))
(g:defmethod (description (o NSData)) (nsdata-description o))

(define (nsdata-start-index self)
  (%msg-v->i64 (NSObject-ptr self) %sel-nsdata-start-index))
(defmethod {start-index NSData} (lambda (self) (nsdata-start-index self)))
(g:defmethod (start-index (o NSData)) (nsdata-start-index o))

(define (nsdata-end-index self)
  (%msg-v->i64 (NSObject-ptr self) %sel-nsdata-end-index))
(defmethod {end-index NSData} (lambda (self) (nsdata-end-index self)))
(g:defmethod (end-index (o NSData)) (nsdata-end-index o))

(define (nsdata-regions self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsdata-regions)))
(defmethod {regions NSData} (lambda (self) (nsdata-regions self)))
(g:defmethod (regions (o NSData)) (nsdata-regions o))

;; --- Instance methods ---
(define (nsdata-is-equal-to-data self other)
  (%msg-p->b (NSObject-ptr self) %sel-nsdata-is-equal-to-data (->ptr other)))
(defmethod {is-equal-to-data NSData} (lambda (self other) (nsdata-is-equal-to-data self other)))

(define (nsdata-subdata-with-range self range)
  (wrap (%msg-nsrange->p (NSObject-ptr self) %sel-nsdata-subdata-with-range range)))
(defmethod {subdata-with-range NSData} (lambda (self range) (nsdata-subdata-with-range self range)))

(define (nsdata-write-to-file-atomically self path use-auxiliary-file)
  (%msg-p-b->b (NSObject-ptr self) %sel-nsdata-write-to-file-atomically (->ptr path) use-auxiliary-file))
(defmethod {write-to-file-atomically NSData} (lambda (self path use-auxiliary-file) (nsdata-write-to-file-atomically self path use-auxiliary-file)))

(define (nsdata-write-to-url-atomically self url atomically)
  (%msg-p-b->b (NSObject-ptr self) %sel-nsdata-write-to-url-atomically (->ptr url) atomically))
(defmethod {write-to-url-atomically NSData} (lambda (self url atomically) (nsdata-write-to-url-atomically self url atomically)))

(define (nsdata-range-of-data-options-range self data-to-find mask search-range)
  (%msg-p-u64-nsrange->nsrange (NSObject-ptr self) %sel-nsdata-range-of-data-options-range (->ptr data-to-find) mask search-range))
(defmethod {range-of-data-options-range NSData} (lambda (self data-to-find mask search-range) (nsdata-range-of-data-options-range self data-to-find mask search-range)))

(define (nsdata-base64-encoded-string-with-options self options)
  (wrap (%msg-u64->p (NSObject-ptr self) %sel-nsdata-base64-encoded-string-with-options options)))
(defmethod {base64-encoded-string-with-options NSData} (lambda (self options) (nsdata-base64-encoded-string-with-options self options)))

(define (nsdata-base64-encoded-data-with-options self options)
  (wrap (%msg-u64->p (NSObject-ptr self) %sel-nsdata-base64-encoded-data-with-options options)))
(defmethod {base64-encoded-data-with-options NSData} (lambda (self options) (nsdata-base64-encoded-data-with-options self options)))

(define (nsdata-decompressed-data-using-algorithm-error self algorithm)
  (call-with-nserror-out
    (lambda (%err-cell)
      (wrap (%msg-i64-pp->p-e (NSObject-ptr self) %sel-nsdata-decompressed-data-using-algorithm-error algorithm %err-cell)))))
(defmethod {decompressed-data-using-algorithm-error NSData} (lambda (self algorithm) (nsdata-decompressed-data-using-algorithm-error self algorithm)))

(define (nsdata-compressed-data-using-algorithm-error self algorithm)
  (call-with-nserror-out
    (lambda (%err-cell)
      (wrap (%msg-i64-pp->p-e (NSObject-ptr self) %sel-nsdata-compressed-data-using-algorithm-error algorithm %err-cell)))))
(defmethod {compressed-data-using-algorithm-error NSData} (lambda (self algorithm) (nsdata-compressed-data-using-algorithm-error self algorithm)))

(define (nsdata-encode-with-coder self coder)
  (%msg-p->v (NSObject-ptr self) %sel-nsdata-encode-with-coder (->ptr coder)))
(defmethod {encode-with-coder NSData} (lambda (self coder) (nsdata-encode-with-coder self coder)))

;; --- Class methods ---
(define (nsdata-data)
  (wrap (%msg-v->p (objc_getClass "NSData") %sel-nsdata-data)))

(define (nsdata-data-with-contents-of-file path)
  (wrap (%msg-p->p (objc_getClass "NSData") %sel-nsdata-data-with-contents-of-file (->ptr path))))

(define (nsdata-data-with-contents-of-url url)
  (wrap (%msg-p->p (objc_getClass "NSData") %sel-nsdata-data-with-contents-of-url (->ptr url))))

(define (nsdata-data-with-data data)
  (wrap (%msg-p->p (objc_getClass "NSData") %sel-nsdata-data-with-data (->ptr data))))

(define (nsdata-supports-secure-coding)
  (%msg-v->b (objc_getClass "NSData") %sel-nsdata-supports-secure-coding))

