#lang racket/base
;; Generated binding for NSData (Foundation)
;; Do not edit — regenerate from enriched IR

(require "../../runtime/ffi2-dispatch.rkt"
         (except-in ffi/unsafe ->)
         ffi/unsafe/objc
         (rename-in racket/contract [-> c->])
         "../../runtime/objc-base.rkt"
         "../../runtime/coerce.rkt"
         "../../runtime/block.rkt"
         "../../runtime/type-mapping.rkt")

;; Load framework and ObjC runtime
(define _fw-lib (ffi-lib "/System/Library/Frameworks/Foundation.framework/Foundation"))
(define _objc-lib (ffi-lib "libobjc"))


;; --- Class predicates ---
(define (nsarray? v) (objc-instance-of? v "NSArray"))
(define (nsdata? v) (objc-instance-of? v "NSData"))
(define (nsstring? v) (objc-instance-of? v "NSString"))
(provide NSData)
(provide/contract
  [make-nsdata-init-with-base64-encoded-data-options (c-> (or/c string? objc-object? #f) exact-nonnegative-integer? any/c)]
  [make-nsdata-init-with-base64-encoded-string-options (c-> (or/c string? objc-object? #f) exact-nonnegative-integer? any/c)]
  [make-nsdata-init-with-bytes-length (c-> (or/c cpointer? #f) exact-nonnegative-integer? any/c)]
  [make-nsdata-init-with-bytes-no-copy-length (c-> (or/c cpointer? #f) exact-nonnegative-integer? any/c)]
  [make-nsdata-init-with-bytes-no-copy-length-deallocator (c-> (or/c cpointer? #f) exact-nonnegative-integer? (or/c procedure? #f) any/c)]
  [make-nsdata-init-with-bytes-no-copy-length-free-when-done (c-> (or/c cpointer? #f) exact-nonnegative-integer? boolean? any/c)]
  [make-nsdata-init-with-coder (c-> (or/c string? objc-object? #f) any/c)]
  [make-nsdata-init-with-contents-of-file (c-> (or/c string? objc-object? #f) any/c)]
  [make-nsdata-init-with-contents-of-file-options-error (c-> (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c cpointer? #f) any/c)]
  [make-nsdata-init-with-contents-of-url (c-> (or/c string? objc-object? #f) any/c)]
  [make-nsdata-init-with-contents-of-url-options-error (c-> (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c cpointer? #f) any/c)]
  [make-nsdata-init-with-data (c-> (or/c string? objc-object? #f) any/c)]
  [nsdata-bytes (c-> nsdata? (or/c cpointer? #f))]
  [nsdata-description (c-> nsdata? (or/c nsstring? objc-nil?))]
  [nsdata-end-index (c-> nsdata? exact-integer?)]
  [nsdata-length (c-> nsdata? exact-nonnegative-integer?)]
  [nsdata-regions (c-> nsdata? (or/c nsarray? objc-nil?))]
  [nsdata-start-index (c-> nsdata? exact-integer?)]
  [nsdata-base64-encoded-data-with-options (c-> nsdata? exact-nonnegative-integer? (or/c nsdata? objc-nil?))]
  [nsdata-base64-encoded-string-with-options (c-> nsdata? exact-nonnegative-integer? (or/c nsstring? objc-nil?))]
  [nsdata-compressed-data-using-algorithm-error (c-> nsdata? exact-integer? (values any/c (or/c objc-object? #f)))]
  [nsdata-copy-with-zone (c-> nsdata? (or/c cpointer? #f) any/c)]
  [nsdata-decompressed-data-using-algorithm-error (c-> nsdata? exact-integer? (values any/c (or/c objc-object? #f)))]
  [nsdata-encode-with-coder (c-> nsdata? (or/c string? objc-object? #f) void?)]
  [nsdata-enumerate-byte-ranges-using-block (c-> nsdata? (or/c procedure? #f) void?)]
  [nsdata-get-bytes-length (c-> nsdata? (or/c cpointer? #f) exact-nonnegative-integer? void?)]
  [nsdata-get-bytes-range (c-> nsdata? (or/c cpointer? #f) any/c void?)]
  [nsdata-is-equal-to-data (c-> nsdata? (or/c string? objc-object? #f) boolean?)]
  [nsdata-mutable-copy-with-zone (c-> nsdata? (or/c cpointer? #f) any/c)]
  [nsdata-range-of-data-options-range (c-> nsdata? (or/c string? objc-object? #f) exact-nonnegative-integer? any/c any/c)]
  [nsdata-subdata-with-range (c-> nsdata? any/c (or/c nsdata? objc-nil?))]
  [nsdata-write-to-file-atomically (c-> nsdata? (or/c string? objc-object? #f) boolean? boolean?)]
  [nsdata-write-to-file-options-error (c-> nsdata? (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c cpointer? #f) boolean?)]
  [nsdata-write-to-url-atomically (c-> nsdata? (or/c string? objc-object? #f) boolean? boolean?)]
  [nsdata-write-to-url-options-error (c-> nsdata? (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c cpointer? #f) boolean?)]
  [nsdata-data (c-> any/c)]
  [nsdata-data-with-bytes-length (c-> (or/c cpointer? #f) exact-nonnegative-integer? any/c)]
  [nsdata-data-with-bytes-no-copy-length (c-> (or/c cpointer? #f) exact-nonnegative-integer? any/c)]
  [nsdata-data-with-bytes-no-copy-length-free-when-done (c-> (or/c cpointer? #f) exact-nonnegative-integer? boolean? any/c)]
  [nsdata-data-with-contents-of-file (c-> (or/c string? objc-object? #f) any/c)]
  [nsdata-data-with-contents-of-file-options-error (c-> (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c cpointer? #f) any/c)]
  [nsdata-data-with-contents-of-url (c-> (or/c string? objc-object? #f) any/c)]
  [nsdata-data-with-contents-of-url-options-error (c-> (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c cpointer? #f) any/c)]
  [nsdata-data-with-data (c-> (or/c string? objc-object? #f) any/c)]
  [nsdata-supports-secure-coding (c-> boolean?)]
  )

;; --- Class reference ---
(import-class NSData)

;; --- Native dispatch bindings (generated objc_msgSend, ADR-0013) ---
(define-aw-msg aw_racket_msg_0_P (-> ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_0_b (-> ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_0_q (-> ptr_t ptr_t int64_t))
(define-aw-msg aw_racket_msg_0_Q (-> ptr_t ptr_t uint64_t))
(define-aw-msg aw_racket_msg_P_P (-> ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_P_b (-> ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_P_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_Pb_b (-> ptr_t ptr_t ptr_t bool_t bool_t))
(define-aw-msg aw_racket_msg_PQ_P (-> ptr_t ptr_t ptr_t uint64_t ptr_t))
(define-aw-msg aw_racket_msg_PQ_v (-> ptr_t ptr_t ptr_t uint64_t void_t))
(define-aw-msg aw_racket_msg_PQP_P (-> ptr_t ptr_t ptr_t uint64_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PQP_b (-> ptr_t ptr_t ptr_t uint64_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_PQb_P (-> ptr_t ptr_t ptr_t uint64_t bool_t ptr_t))
(define-aw-msg aw_racket_msg_PQG_G (-> ptr_t ptr_t ptr_t uint64_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PG_v (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_q_P_e (-> ptr_t ptr_t int64_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_Q_P (-> ptr_t ptr_t uint64_t ptr_t))
(define-aw-msg aw_racket_msg_G_P (-> ptr_t ptr_t ptr_t ptr_t))

;; --- Constructors ---
(define (make-nsdata-init-with-base64-encoded-data-options base64-data options)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PQ_P (id->ffi2-ptr (tell NSData alloc)) (id->ffi2-ptr (sel_registerName "initWithBase64EncodedData:options:")) (id->ffi2-ptr (coerce-arg base64-data)) options))
   #:retained #t))

(define (make-nsdata-init-with-base64-encoded-string-options base64-string options)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PQ_P (id->ffi2-ptr (tell NSData alloc)) (id->ffi2-ptr (sel_registerName "initWithBase64EncodedString:options:")) (id->ffi2-ptr (coerce-arg base64-string)) options))
   #:retained #t))

(define (make-nsdata-init-with-bytes-length bytes length)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PQ_P (id->ffi2-ptr (tell NSData alloc)) (id->ffi2-ptr (sel_registerName "initWithBytes:length:")) (id->ffi2-ptr bytes) length))
   #:retained #t))

(define (make-nsdata-init-with-bytes-no-copy-length bytes length)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PQ_P (id->ffi2-ptr (tell NSData alloc)) (id->ffi2-ptr (sel_registerName "initWithBytesNoCopy:length:")) (id->ffi2-ptr bytes) length))
   #:retained #t))

;; block param 2: stored (retained across calls)
(define (make-nsdata-init-with-bytes-no-copy-length-deallocator bytes length deallocator)
  (define-values (_blk2 _blk2-id)
    (make-objc-block deallocator (list _pointer _uint64) _void))
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PQP_P (id->ffi2-ptr (tell NSData alloc)) (id->ffi2-ptr (sel_registerName "initWithBytesNoCopy:length:deallocator:")) (id->ffi2-ptr bytes) length (id->ffi2-ptr _blk2)))
   #:retained #t))

(define (make-nsdata-init-with-bytes-no-copy-length-free-when-done bytes length b)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PQb_P (id->ffi2-ptr (tell NSData alloc)) (id->ffi2-ptr (sel_registerName "initWithBytesNoCopy:length:freeWhenDone:")) (id->ffi2-ptr bytes) length b))
   #:retained #t))

(define (make-nsdata-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSData alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))

(define (make-nsdata-init-with-contents-of-file path)
  (wrap-objc-object
   (tell (tell NSData alloc)
         initWithContentsOfFile: (coerce-arg path))
   #:retained #t))

(define (make-nsdata-init-with-contents-of-file-options-error path read-options-mask error-ptr)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PQP_P (id->ffi2-ptr (tell NSData alloc)) (id->ffi2-ptr (sel_registerName "initWithContentsOfFile:options:error:")) (id->ffi2-ptr (coerce-arg path)) read-options-mask (id->ffi2-ptr error-ptr)))
   #:retained #t))

(define (make-nsdata-init-with-contents-of-url url)
  (wrap-objc-object
   (tell (tell NSData alloc)
         initWithContentsOfURL: (coerce-arg url))
   #:retained #t))

(define (make-nsdata-init-with-contents-of-url-options-error url read-options-mask error-ptr)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PQP_P (id->ffi2-ptr (tell NSData alloc)) (id->ffi2-ptr (sel_registerName "initWithContentsOfURL:options:error:")) (id->ffi2-ptr (coerce-arg url)) read-options-mask (id->ffi2-ptr error-ptr)))
   #:retained #t))

(define (make-nsdata-init-with-data data)
  (wrap-objc-object
   (tell (tell NSData alloc)
         initWithData: (coerce-arg data))
   #:retained #t))


;; --- Properties ---
(define (nsdata-bytes self)
  (ptr_t->cpointer (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "bytes")))))
(define (nsdata-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "description"))))))
(define (nsdata-end-index self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "endIndex"))))
(define (nsdata-length self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "length"))))
(define (nsdata-regions self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "regions"))))))
(define (nsdata-start-index self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "startIndex"))))

;; --- Instance methods ---
(define (nsdata-base64-encoded-data-with-options self options)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_Q_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "base64EncodedDataWithOptions:")) options))
   ))
(define (nsdata-base64-encoded-string-with-options self options)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_Q_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "base64EncodedStringWithOptions:")) options))
   ))
;; NSError out-param: result-or-error wrapper candidate
(define (nsdata-compressed-data-using-algorithm-error self algorithm)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_q_P_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "compressedDataUsingAlgorithm:error:")) algorithm (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values (wrap-objc-object (ffi2-ptr->id result)) (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
(define (nsdata-copy-with-zone self zone)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "copyWithZone:")) (id->ffi2-ptr zone)))
   #:retained #t))
;; NSError out-param: result-or-error wrapper candidate
(define (nsdata-decompressed-data-using-algorithm-error self algorithm)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_q_P_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "decompressedDataUsingAlgorithm:error:")) algorithm (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values (wrap-objc-object (ffi2-ptr->id result)) (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
(define (nsdata-encode-with-coder self coder)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "encodeWithCoder:")) (id->ffi2-ptr (coerce-arg coder))))
;; block param 0: synchronous (caller frees)
(define (nsdata-enumerate-byte-ranges-using-block self block)
  (define-values (_blk0 _blk0-id)
    (make-objc-block block (list _pointer _NSRange _pointer) _void))
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enumerateByteRangesUsingBlock:")) (id->ffi2-ptr _blk0)))
(define (nsdata-get-bytes-length self buffer length)
  (aw_racket_msg_PQ_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getBytes:length:")) (id->ffi2-ptr buffer) length))
(define (nsdata-get-bytes-range self buffer range)
  (aw_racket_msg_PG_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getBytes:range:")) (id->ffi2-ptr buffer) (id->ffi2-ptr range)))
(define (nsdata-is-equal-to-data self other)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isEqualToData:")) (id->ffi2-ptr (coerce-arg other))))
(define (nsdata-mutable-copy-with-zone self zone)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mutableCopyWithZone:")) (id->ffi2-ptr zone)))
   #:retained #t))
(define (nsdata-range-of-data-options-range self data-to-find mask search-range)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_PQG_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rangeOfData:options:range:")) (id->ffi2-ptr (coerce-arg data-to-find)) mask (id->ffi2-ptr search-range) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsdata-subdata-with-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "subdataWithRange:")) (id->ffi2-ptr range)))
   ))
(define (nsdata-write-to-file-atomically self path use-auxiliary-file)
  (aw_racket_msg_Pb_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "writeToFile:atomically:")) (id->ffi2-ptr (coerce-arg path)) use-auxiliary-file))
(define (nsdata-write-to-file-options-error self path write-options-mask error-ptr)
  (aw_racket_msg_PQP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "writeToFile:options:error:")) (id->ffi2-ptr (coerce-arg path)) write-options-mask (id->ffi2-ptr error-ptr)))
(define (nsdata-write-to-url-atomically self url atomically)
  (aw_racket_msg_Pb_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "writeToURL:atomically:")) (id->ffi2-ptr (coerce-arg url)) atomically))
(define (nsdata-write-to-url-options-error self url write-options-mask error-ptr)
  (aw_racket_msg_PQP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "writeToURL:options:error:")) (id->ffi2-ptr (coerce-arg url)) write-options-mask (id->ffi2-ptr error-ptr)))

;; --- Class methods ---
(define (nsdata-data)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSData) (id->ffi2-ptr (sel_registerName "data"))))
   ))
(define (nsdata-data-with-bytes-length bytes length)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PQ_P (id->ffi2-ptr NSData) (id->ffi2-ptr (sel_registerName "dataWithBytes:length:")) (id->ffi2-ptr bytes) length))
   ))
(define (nsdata-data-with-bytes-no-copy-length bytes length)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PQ_P (id->ffi2-ptr NSData) (id->ffi2-ptr (sel_registerName "dataWithBytesNoCopy:length:")) (id->ffi2-ptr bytes) length))
   ))
(define (nsdata-data-with-bytes-no-copy-length-free-when-done bytes length b)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PQb_P (id->ffi2-ptr NSData) (id->ffi2-ptr (sel_registerName "dataWithBytesNoCopy:length:freeWhenDone:")) (id->ffi2-ptr bytes) length b))
   ))
(define (nsdata-data-with-contents-of-file path)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr NSData) (id->ffi2-ptr (sel_registerName "dataWithContentsOfFile:")) (id->ffi2-ptr (coerce-arg path))))
   ))
(define (nsdata-data-with-contents-of-file-options-error path read-options-mask error-ptr)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PQP_P (id->ffi2-ptr NSData) (id->ffi2-ptr (sel_registerName "dataWithContentsOfFile:options:error:")) (id->ffi2-ptr (coerce-arg path)) read-options-mask (id->ffi2-ptr error-ptr)))
   ))
(define (nsdata-data-with-contents-of-url url)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr NSData) (id->ffi2-ptr (sel_registerName "dataWithContentsOfURL:")) (id->ffi2-ptr (coerce-arg url))))
   ))
(define (nsdata-data-with-contents-of-url-options-error url read-options-mask error-ptr)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PQP_P (id->ffi2-ptr NSData) (id->ffi2-ptr (sel_registerName "dataWithContentsOfURL:options:error:")) (id->ffi2-ptr (coerce-arg url)) read-options-mask (id->ffi2-ptr error-ptr)))
   ))
(define (nsdata-data-with-data data)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr NSData) (id->ffi2-ptr (sel_registerName "dataWithData:")) (id->ffi2-ptr (coerce-arg data))))
   ))
(define (nsdata-supports-secure-coding)
  (aw_racket_msg_0_b (id->ffi2-ptr NSData) (id->ffi2-ptr (sel_registerName "supportsSecureCoding"))))
