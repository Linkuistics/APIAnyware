#lang racket/base
;; Generated binding for NSArray (Foundation)
;; Do not edit — regenerate from enriched IR

(require "../../runtime/ffi2-dispatch.rkt"
         (except-in ffi/unsafe ->)
         ffi/unsafe/objc
         (rename-in racket/contract [-> c->])
         "../../runtime/objc-base.rkt"
         "../../runtime/coerce.rkt"
         "../../runtime/block.rkt"
         "../../runtime/type-mapping.rkt"
         "../../runtime/swift-trampoline.rkt"
         (only-in ffi/unsafe [-> aw->]))

;; Load framework and ObjC runtime
(define _fw-lib (ffi-lib "/System/Library/Frameworks/Foundation.framework/Foundation"))
(define _objc-lib (ffi-lib "libobjc"))


;; --- Class predicates ---
(define (mirror? v) (objc-instance-of? v "Mirror"))
(define (nsarray? v) (objc-instance-of? v "NSArray"))
(define (nsdata? v) (objc-instance-of? v "NSData"))
(define (nsenumerator? v) (objc-instance-of? v "NSEnumerator"))
(define (nsindexset? v) (objc-instance-of? v "NSIndexSet"))
(define (nsorderedcollectiondifference? v) (objc-instance-of? v "NSOrderedCollectionDifference"))
(define (nsstring? v) (objc-instance-of? v "NSString"))
(provide NSArray)
(provide/contract
  [make-nsarray-init-with-array (c-> (or/c string? objc-object? #f) any/c)]
  [make-nsarray-init-with-array-copy-items (c-> (or/c string? objc-object? #f) boolean? any/c)]
  [make-nsarray-init-with-coder (c-> (or/c string? objc-object? #f) any/c)]
  [make-nsarray-init-with-contents-of-file (c-> (or/c string? objc-object? #f) any/c)]
  [make-nsarray-init-with-contents-of-url (c-> (or/c string? objc-object? #f) any/c)]
  [make-nsarray-init-with-contents-of-url-error (c-> (or/c string? objc-object? #f) (or/c cpointer? #f) any/c)]
  [make-nsarray-init-with-objects-count (c-> (or/c cpointer? #f) exact-nonnegative-integer? any/c)]
  [nsarray-count (c-> nsarray? exact-nonnegative-integer?)]
  [nsarray-custom-mirror (c-> nsarray? (or/c mirror? objc-nil?))]
  [nsarray-description (c-> nsarray? (or/c nsstring? objc-nil?))]
  [nsarray-first-object (c-> nsarray? any/c)]
  [nsarray-last-object (c-> nsarray? any/c)]
  [nsarray-sorted-array-hint (c-> nsarray? (or/c nsdata? objc-nil?))]
  [nsarray-underestimated-count (c-> nsarray? exact-integer?)]
  [nsarray-add-observer-for-key-path-options-context! (c-> nsarray? (or/c string? objc-object? #f) (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c cpointer? #f) void?)]
  [nsarray-add-observer-to-objects-at-indexes-for-key-path-options-context! (c-> nsarray? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c cpointer? #f) void?)]
  [nsarray-array-by-adding-object (c-> nsarray? (or/c string? objc-object? #f) (or/c nsarray? objc-nil?))]
  [nsarray-array-by-adding-objects-from-array (c-> nsarray? (or/c string? objc-object? #f) (or/c nsarray? objc-nil?))]
  [nsarray-array-by-applying-difference (c-> nsarray? (or/c string? objc-object? #f) (or/c nsarray? objc-nil?))]
  [nsarray-components-joined-by-string (c-> nsarray? (or/c string? objc-object? #f) (or/c nsstring? objc-nil?))]
  [nsarray-contains-object (c-> nsarray? (or/c string? objc-object? #f) boolean?)]
  [nsarray-copy-with-zone (c-> nsarray? (or/c cpointer? #f) any/c)]
  [nsarray-count-by-enumerating-with-state-objects-count (c-> nsarray? (or/c cpointer? #f) (or/c cpointer? #f) exact-nonnegative-integer? exact-nonnegative-integer?)]
  [nsarray-description-with-locale (c-> nsarray? (or/c string? objc-object? #f) (or/c nsstring? objc-nil?))]
  [nsarray-description-with-locale-indent (c-> nsarray? (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c nsstring? objc-nil?))]
  [nsarray-difference-from-array (c-> nsarray? (or/c string? objc-object? #f) (or/c nsorderedcollectiondifference? objc-nil?))]
  [nsarray-difference-from-array-with-options (c-> nsarray? (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c nsorderedcollectiondifference? objc-nil?))]
  [nsarray-difference-from-array-with-options-using-equivalence-test (c-> nsarray? (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c procedure? #f) (or/c nsorderedcollectiondifference? objc-nil?))]
  [nsarray-encode-with-coder (c-> nsarray? (or/c string? objc-object? #f) void?)]
  [nsarray-enumerate-objects-at-indexes-options-using-block (c-> nsarray? (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c procedure? #f) void?)]
  [nsarray-enumerate-objects-using-block (c-> nsarray? (or/c procedure? #f) void?)]
  [nsarray-enumerate-objects-with-options-using-block (c-> nsarray? exact-nonnegative-integer? (or/c procedure? #f) void?)]
  [nsarray-filtered-array-using-predicate (c-> nsarray? (or/c string? objc-object? #f) (or/c nsarray? objc-nil?))]
  [nsarray-first-object-common-with-array (c-> nsarray? (or/c string? objc-object? #f) any/c)]
  [nsarray-get-objects-range (c-> nsarray? (or/c cpointer? #f) any/c void?)]
  [nsarray-index-of-object (c-> nsarray? (or/c string? objc-object? #f) exact-nonnegative-integer?)]
  [nsarray-index-of-object-in-range (c-> nsarray? (or/c string? objc-object? #f) any/c exact-nonnegative-integer?)]
  [nsarray-index-of-object-in-sorted-range-options-using-comparator (c-> nsarray? (or/c string? objc-object? #f) any/c exact-nonnegative-integer? (or/c procedure? #f) exact-nonnegative-integer?)]
  [nsarray-index-of-object-at-indexes-options-passing-test (c-> nsarray? (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c procedure? #f) exact-nonnegative-integer?)]
  [nsarray-index-of-object-identical-to (c-> nsarray? (or/c string? objc-object? #f) exact-nonnegative-integer?)]
  [nsarray-index-of-object-identical-to-in-range (c-> nsarray? (or/c string? objc-object? #f) any/c exact-nonnegative-integer?)]
  [nsarray-index-of-object-passing-test (c-> nsarray? (or/c procedure? #f) exact-nonnegative-integer?)]
  [nsarray-index-of-object-with-options-passing-test (c-> nsarray? exact-nonnegative-integer? (or/c procedure? #f) exact-nonnegative-integer?)]
  [nsarray-indexes-of-objects-at-indexes-options-passing-test (c-> nsarray? (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c procedure? #f) (or/c nsindexset? objc-nil?))]
  [nsarray-indexes-of-objects-passing-test (c-> nsarray? (or/c procedure? #f) (or/c nsindexset? objc-nil?))]
  [nsarray-indexes-of-objects-with-options-passing-test (c-> nsarray? exact-nonnegative-integer? (or/c procedure? #f) (or/c nsindexset? objc-nil?))]
  [nsarray-is-equal-to-array (c-> nsarray? (or/c string? objc-object? #f) boolean?)]
  [nsarray-make-objects-perform-selector (c-> nsarray? string? void?)]
  [nsarray-make-objects-perform-selector-with-object (c-> nsarray? string? (or/c string? objc-object? #f) void?)]
  [nsarray-mutable-copy-with-zone (c-> nsarray? (or/c cpointer? #f) any/c)]
  [nsarray-object-at-index (c-> nsarray? exact-nonnegative-integer? any/c)]
  [nsarray-object-at-indexed-subscript (c-> nsarray? exact-nonnegative-integer? any/c)]
  [nsarray-object-enumerator (c-> nsarray? (or/c nsenumerator? objc-nil?))]
  [nsarray-objects-at-indexes (c-> nsarray? (or/c string? objc-object? #f) (or/c nsarray? objc-nil?))]
  [nsarray-paths-matching-extensions (c-> nsarray? (or/c string? objc-object? #f) (or/c nsarray? objc-nil?))]
  [nsarray-remove-observer-for-key-path! (c-> nsarray? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsarray-remove-observer-for-key-path-context! (c-> nsarray? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c cpointer? #f) void?)]
  [nsarray-remove-observer-from-objects-at-indexes-for-key-path! (c-> nsarray? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsarray-remove-observer-from-objects-at-indexes-for-key-path-context! (c-> nsarray? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c cpointer? #f) void?)]
  [nsarray-reverse-object-enumerator (c-> nsarray? (or/c nsenumerator? objc-nil?))]
  [nsarray-set-value-for-key! (c-> nsarray? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsarray-sorted-array-using-comparator (c-> nsarray? (or/c procedure? #f) (or/c nsarray? objc-nil?))]
  [nsarray-sorted-array-using-descriptors (c-> nsarray? (or/c string? objc-object? #f) (or/c nsarray? objc-nil?))]
  [nsarray-sorted-array-using-function-context (c-> nsarray? (or/c cpointer? #f) (or/c cpointer? #f) (or/c nsarray? objc-nil?))]
  [nsarray-sorted-array-using-function-context-hint (c-> nsarray? (or/c cpointer? #f) (or/c cpointer? #f) (or/c string? objc-object? #f) (or/c nsarray? objc-nil?))]
  [nsarray-sorted-array-using-selector (c-> nsarray? string? (or/c nsarray? objc-nil?))]
  [nsarray-sorted-array-with-options-using-comparator (c-> nsarray? exact-nonnegative-integer? (or/c procedure? #f) (or/c nsarray? objc-nil?))]
  [nsarray-subarray-with-range (c-> nsarray? any/c (or/c nsarray? objc-nil?))]
  [nsarray-value-for-key (c-> nsarray? (or/c string? objc-object? #f) any/c)]
  [nsarray-write-to-file-atomically (c-> nsarray? (or/c string? objc-object? #f) boolean? boolean?)]
  [nsarray-write-to-url-atomically (c-> nsarray? (or/c string? objc-object? #f) boolean? boolean?)]
  [nsarray-write-to-url-error (c-> nsarray? (or/c string? objc-object? #f) (values boolean? (or/c objc-object? #f)))]
  [nsarray-array (c-> any/c)]
  [nsarray-array-with-array (c-> (or/c string? objc-object? #f) any/c)]
  [nsarray-array-with-contents-of-file (c-> (or/c string? objc-object? #f) (or/c nsarray? objc-nil?))]
  [nsarray-array-with-contents-of-url (c-> (or/c string? objc-object? #f) (or/c nsarray? objc-nil?))]
  [nsarray-array-with-contents-of-url-error (c-> (or/c string? objc-object? #f) (values (or/c nsarray? objc-nil?) (or/c objc-object? #f)))]
  [nsarray-array-with-object (c-> (or/c string? objc-object? #f) any/c)]
  [nsarray-array-with-objects-count (c-> (or/c cpointer? #f) exact-nonnegative-integer? any/c)]
  [nsarray-supports-secure-coding (c-> boolean?)]
  )

(provide
  nsarray-make-iterator
  )

;; --- Class reference ---
(import-class NSArray)

;; --- Native dispatch bindings (generated objc_msgSend, ADR-0013) ---
(define-aw-msg aw_racket_msg_0_P (-> ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_0_b (-> ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_0_q (-> ptr_t ptr_t int64_t))
(define-aw-msg aw_racket_msg_0_Q (-> ptr_t ptr_t uint64_t))
(define-aw-msg aw_racket_msg_P_P (-> ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_P_P_e (-> ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_P_b (-> ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_P_b_e (-> ptr_t ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_P_Q (-> ptr_t ptr_t ptr_t uint64_t))
(define-aw-msg aw_racket_msg_P_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PP_v (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PPP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PPP_v (-> ptr_t ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PPPP_v (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PPPQP_v (-> ptr_t ptr_t ptr_t ptr_t ptr_t uint64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PPQ_Q (-> ptr_t ptr_t ptr_t ptr_t uint64_t uint64_t))
(define-aw-msg aw_racket_msg_PPQP_v (-> ptr_t ptr_t ptr_t ptr_t uint64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_Pb_P (-> ptr_t ptr_t ptr_t bool_t ptr_t))
(define-aw-msg aw_racket_msg_Pb_b (-> ptr_t ptr_t ptr_t bool_t bool_t))
(define-aw-msg aw_racket_msg_PQ_P (-> ptr_t ptr_t ptr_t uint64_t ptr_t))
(define-aw-msg aw_racket_msg_PQP_P (-> ptr_t ptr_t ptr_t uint64_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PQP_Q (-> ptr_t ptr_t ptr_t uint64_t ptr_t uint64_t))
(define-aw-msg aw_racket_msg_PQP_v (-> ptr_t ptr_t ptr_t uint64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PG_Q (-> ptr_t ptr_t ptr_t ptr_t uint64_t))
(define-aw-msg aw_racket_msg_PG_v (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PGQP_Q (-> ptr_t ptr_t ptr_t ptr_t uint64_t ptr_t uint64_t))
(define-aw-msg aw_racket_msg_Q_P (-> ptr_t ptr_t uint64_t ptr_t))
(define-aw-msg aw_racket_msg_QP_P (-> ptr_t ptr_t uint64_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_QP_Q (-> ptr_t ptr_t uint64_t ptr_t uint64_t))
(define-aw-msg aw_racket_msg_QP_v (-> ptr_t ptr_t uint64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_G_P (-> ptr_t ptr_t ptr_t ptr_t))

;; --- Constructors ---
(define (make-nsarray-init-with-array array)
  (wrap-objc-object
   (tell (tell NSArray alloc)
         initWithArray: (coerce-arg array))
   #:retained #t))

(define (make-nsarray-init-with-array-copy-items array flag)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_Pb_P (id->ffi2-ptr (tell NSArray alloc)) (id->ffi2-ptr (sel_registerName "initWithArray:copyItems:")) (id->ffi2-ptr (coerce-arg array)) flag))
   #:retained #t))

(define (make-nsarray-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSArray alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))

(define (make-nsarray-init-with-contents-of-file path)
  (wrap-objc-object
   (tell (tell NSArray alloc)
         initWithContentsOfFile: (coerce-arg path))
   #:retained #t))

(define (make-nsarray-init-with-contents-of-url url)
  (wrap-objc-object
   (tell (tell NSArray alloc)
         initWithContentsOfURL: (coerce-arg url))
   #:retained #t))

;; NSError out-param: result-or-error wrapper candidate
(define (make-nsarray-init-with-contents-of-url-error url error)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (tell NSArray alloc)) (id->ffi2-ptr (sel_registerName "initWithContentsOfURL:error:")) (id->ffi2-ptr (coerce-arg url)) (id->ffi2-ptr error)))
   #:retained #t))

(define (make-nsarray-init-with-objects-count objects cnt)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PQ_P (id->ffi2-ptr (tell NSArray alloc)) (id->ffi2-ptr (sel_registerName "initWithObjects:count:")) (id->ffi2-ptr objects) cnt))
   #:retained #t))


;; --- Properties ---
(define (nsarray-count self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "count"))))
(define (nsarray-custom-mirror self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "customMirror"))))))
(define (nsarray-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "description"))))))
(define (nsarray-first-object self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "firstObject"))))))
(define (nsarray-last-object self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lastObject"))))))
(define (nsarray-sorted-array-hint self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sortedArrayHint"))))))
(define (nsarray-underestimated-count self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "underestimatedCount"))))

;; --- Instance methods ---
;; param 0: weak reference
(define (nsarray-add-observer-for-key-path-options-context! self observer key-path options context)
  (aw_racket_msg_PPQP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addObserver:forKeyPath:options:context:")) (id->ffi2-ptr (coerce-arg observer)) (id->ffi2-ptr (coerce-arg key-path)) options (id->ffi2-ptr context)))
;; param 0: weak reference
(define (nsarray-add-observer-to-objects-at-indexes-for-key-path-options-context! self observer indexes key-path options context)
  (aw_racket_msg_PPPQP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addObserver:toObjectsAtIndexes:forKeyPath:options:context:")) (id->ffi2-ptr (coerce-arg observer)) (id->ffi2-ptr (coerce-arg indexes)) (id->ffi2-ptr (coerce-arg key-path)) options (id->ffi2-ptr context)))
(define (nsarray-array-by-adding-object self an-object)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "arrayByAddingObject:")) (id->ffi2-ptr (coerce-arg an-object))))
   ))
(define (nsarray-array-by-adding-objects-from-array self other-array)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "arrayByAddingObjectsFromArray:")) (id->ffi2-ptr (coerce-arg other-array))))
   ))
(define (nsarray-array-by-applying-difference self difference)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "arrayByApplyingDifference:")) (id->ffi2-ptr (coerce-arg difference))))
   ))
(define (nsarray-components-joined-by-string self separator)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "componentsJoinedByString:")) (id->ffi2-ptr (coerce-arg separator))))
   ))
(define (nsarray-contains-object self an-object)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "containsObject:")) (id->ffi2-ptr (coerce-arg an-object))))
(define (nsarray-copy-with-zone self zone)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "copyWithZone:")) (id->ffi2-ptr zone)))
   #:retained #t))
(define (nsarray-count-by-enumerating-with-state-objects-count self state buffer len)
  (aw_racket_msg_PPQ_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "countByEnumeratingWithState:objects:count:")) (id->ffi2-ptr state) (id->ffi2-ptr buffer) len))
(define (nsarray-description-with-locale self locale)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "descriptionWithLocale:")) (id->ffi2-ptr (coerce-arg locale))))
   ))
(define (nsarray-description-with-locale-indent self locale level)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PQ_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "descriptionWithLocale:indent:")) (id->ffi2-ptr (coerce-arg locale)) level))
   ))
(define (nsarray-difference-from-array self other)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "differenceFromArray:")) (id->ffi2-ptr (coerce-arg other))))
   ))
(define (nsarray-difference-from-array-with-options self other options)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PQ_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "differenceFromArray:withOptions:")) (id->ffi2-ptr (coerce-arg other)) options))
   ))
;; block param 2: synchronous (caller frees)
(define (nsarray-difference-from-array-with-options-using-equivalence-test self other options block)
  (define-values (_blk2 _blk2-id)
    (make-objc-block block (list _id _id) _bool))
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PQP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "differenceFromArray:withOptions:usingEquivalenceTest:")) (id->ffi2-ptr (coerce-arg other)) options (id->ffi2-ptr _blk2)))
   ))
(define (nsarray-encode-with-coder self coder)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "encodeWithCoder:")) (id->ffi2-ptr (coerce-arg coder))))
;; block param 2: synchronous (caller frees)
(define (nsarray-enumerate-objects-at-indexes-options-using-block self s opts block)
  (define-values (_blk2 _blk2-id)
    (make-objc-block block (list _id _uint64 _pointer) _void))
  (aw_racket_msg_PQP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enumerateObjectsAtIndexes:options:usingBlock:")) (id->ffi2-ptr (coerce-arg s)) opts (id->ffi2-ptr _blk2)))
;; block param 0: synchronous (caller frees)
(define (nsarray-enumerate-objects-using-block self block)
  (define-values (_blk0 _blk0-id)
    (make-objc-block block (list _id _uint64 _pointer) _void))
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enumerateObjectsUsingBlock:")) (id->ffi2-ptr _blk0)))
;; block param 1: synchronous (caller frees)
(define (nsarray-enumerate-objects-with-options-using-block self opts block)
  (define-values (_blk1 _blk1-id)
    (make-objc-block block (list _id _uint64 _pointer) _void))
  (aw_racket_msg_QP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enumerateObjectsWithOptions:usingBlock:")) opts (id->ffi2-ptr _blk1)))
(define (nsarray-filtered-array-using-predicate self predicate)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "filteredArrayUsingPredicate:")) (id->ffi2-ptr (coerce-arg predicate))))
   ))
(define (nsarray-first-object-common-with-array self other-array)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "firstObjectCommonWithArray:")) (id->ffi2-ptr (coerce-arg other-array))))
   ))
(define (nsarray-get-objects-range self objects range)
  (aw_racket_msg_PG_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getObjects:range:")) (id->ffi2-ptr objects) (id->ffi2-ptr range)))
(define (nsarray-index-of-object self an-object)
  (aw_racket_msg_P_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "indexOfObject:")) (id->ffi2-ptr (coerce-arg an-object))))
(define (nsarray-index-of-object-in-range self an-object range)
  (aw_racket_msg_PG_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "indexOfObject:inRange:")) (id->ffi2-ptr (coerce-arg an-object)) (id->ffi2-ptr range)))
;; block param 3: synchronous (caller frees)
(define (nsarray-index-of-object-in-sorted-range-options-using-comparator self obj r opts cmp)
  (define-values (_blk3 _blk3-id)
    (make-objc-block cmp (list _id _id) _int64))
  (aw_racket_msg_PGQP_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "indexOfObject:inSortedRange:options:usingComparator:")) (id->ffi2-ptr (coerce-arg obj)) (id->ffi2-ptr r) opts (id->ffi2-ptr _blk3)))
;; block param 2: synchronous (caller frees)
(define (nsarray-index-of-object-at-indexes-options-passing-test self s opts predicate)
  (define-values (_blk2 _blk2-id)
    (make-objc-block predicate (list _id _uint64 _pointer) _bool))
  (aw_racket_msg_PQP_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "indexOfObjectAtIndexes:options:passingTest:")) (id->ffi2-ptr (coerce-arg s)) opts (id->ffi2-ptr _blk2)))
(define (nsarray-index-of-object-identical-to self an-object)
  (aw_racket_msg_P_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "indexOfObjectIdenticalTo:")) (id->ffi2-ptr (coerce-arg an-object))))
(define (nsarray-index-of-object-identical-to-in-range self an-object range)
  (aw_racket_msg_PG_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "indexOfObjectIdenticalTo:inRange:")) (id->ffi2-ptr (coerce-arg an-object)) (id->ffi2-ptr range)))
;; block param 0: synchronous (caller frees)
(define (nsarray-index-of-object-passing-test self predicate)
  (define-values (_blk0 _blk0-id)
    (make-objc-block predicate (list _id _uint64 _pointer) _bool))
  (aw_racket_msg_P_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "indexOfObjectPassingTest:")) (id->ffi2-ptr _blk0)))
;; block param 1: synchronous (caller frees)
(define (nsarray-index-of-object-with-options-passing-test self opts predicate)
  (define-values (_blk1 _blk1-id)
    (make-objc-block predicate (list _id _uint64 _pointer) _bool))
  (aw_racket_msg_QP_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "indexOfObjectWithOptions:passingTest:")) opts (id->ffi2-ptr _blk1)))
;; block param 2: synchronous (caller frees)
(define (nsarray-indexes-of-objects-at-indexes-options-passing-test self s opts predicate)
  (define-values (_blk2 _blk2-id)
    (make-objc-block predicate (list _id _uint64 _pointer) _bool))
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PQP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "indexesOfObjectsAtIndexes:options:passingTest:")) (id->ffi2-ptr (coerce-arg s)) opts (id->ffi2-ptr _blk2)))
   ))
;; block param 0: synchronous (caller frees)
(define (nsarray-indexes-of-objects-passing-test self predicate)
  (define-values (_blk0 _blk0-id)
    (make-objc-block predicate (list _id _uint64 _pointer) _bool))
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "indexesOfObjectsPassingTest:")) (id->ffi2-ptr _blk0)))
   ))
;; block param 1: synchronous (caller frees)
(define (nsarray-indexes-of-objects-with-options-passing-test self opts predicate)
  (define-values (_blk1 _blk1-id)
    (make-objc-block predicate (list _id _uint64 _pointer) _bool))
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_QP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "indexesOfObjectsWithOptions:passingTest:")) opts (id->ffi2-ptr _blk1)))
   ))
(define (nsarray-is-equal-to-array self other-array)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isEqualToArray:")) (id->ffi2-ptr (coerce-arg other-array))))
(define (nsarray-make-objects-perform-selector self a-selector)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeObjectsPerformSelector:")) (id->ffi2-ptr (sel_registerName a-selector))))
(define (nsarray-make-objects-perform-selector-with-object self a-selector argument)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeObjectsPerformSelector:withObject:")) (id->ffi2-ptr (sel_registerName a-selector)) (id->ffi2-ptr (coerce-arg argument))))
(define (nsarray-mutable-copy-with-zone self zone)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mutableCopyWithZone:")) (id->ffi2-ptr zone)))
   #:retained #t))
(define (nsarray-object-at-index self index)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_Q_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "objectAtIndex:")) index))
   ))
(define (nsarray-object-at-indexed-subscript self idx)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_Q_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "objectAtIndexedSubscript:")) idx))
   ))
(define (nsarray-object-enumerator self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "objectEnumerator"))))
   ))
(define (nsarray-objects-at-indexes self indexes)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "objectsAtIndexes:")) (id->ffi2-ptr (coerce-arg indexes))))
   ))
(define (nsarray-paths-matching-extensions self filter-types)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pathsMatchingExtensions:")) (id->ffi2-ptr (coerce-arg filter-types))))
   ))
(define (nsarray-remove-observer-for-key-path! self observer key-path)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeObserver:forKeyPath:")) (id->ffi2-ptr (coerce-arg observer)) (id->ffi2-ptr (coerce-arg key-path))))
(define (nsarray-remove-observer-for-key-path-context! self observer key-path context)
  (aw_racket_msg_PPP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeObserver:forKeyPath:context:")) (id->ffi2-ptr (coerce-arg observer)) (id->ffi2-ptr (coerce-arg key-path)) (id->ffi2-ptr context)))
(define (nsarray-remove-observer-from-objects-at-indexes-for-key-path! self observer indexes key-path)
  (aw_racket_msg_PPP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeObserver:fromObjectsAtIndexes:forKeyPath:")) (id->ffi2-ptr (coerce-arg observer)) (id->ffi2-ptr (coerce-arg indexes)) (id->ffi2-ptr (coerce-arg key-path))))
(define (nsarray-remove-observer-from-objects-at-indexes-for-key-path-context! self observer indexes key-path context)
  (aw_racket_msg_PPPP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeObserver:fromObjectsAtIndexes:forKeyPath:context:")) (id->ffi2-ptr (coerce-arg observer)) (id->ffi2-ptr (coerce-arg indexes)) (id->ffi2-ptr (coerce-arg key-path)) (id->ffi2-ptr context)))
(define (nsarray-reverse-object-enumerator self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "reverseObjectEnumerator"))))
   ))
(define (nsarray-set-value-for-key! self value key)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setValue:forKey:")) (id->ffi2-ptr (coerce-arg value)) (id->ffi2-ptr (coerce-arg key))))
;; block param 0: synchronous (caller frees)
(define (nsarray-sorted-array-using-comparator self cmptr)
  (define-values (_blk0 _blk0-id)
    (make-objc-block cmptr (list _id _id) _int64))
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sortedArrayUsingComparator:")) (id->ffi2-ptr _blk0)))
   ))
(define (nsarray-sorted-array-using-descriptors self sort-descriptors)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sortedArrayUsingDescriptors:")) (id->ffi2-ptr (coerce-arg sort-descriptors))))
   ))
(define (nsarray-sorted-array-using-function-context self comparator context)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sortedArrayUsingFunction:context:")) (id->ffi2-ptr comparator) (id->ffi2-ptr context)))
   ))
(define (nsarray-sorted-array-using-function-context-hint self comparator context hint)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PPP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sortedArrayUsingFunction:context:hint:")) (id->ffi2-ptr comparator) (id->ffi2-ptr context) (id->ffi2-ptr (coerce-arg hint))))
   ))
(define (nsarray-sorted-array-using-selector self comparator)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sortedArrayUsingSelector:")) (id->ffi2-ptr (sel_registerName comparator))))
   ))
;; block param 1: synchronous (caller frees)
(define (nsarray-sorted-array-with-options-using-comparator self opts cmptr)
  (define-values (_blk1 _blk1-id)
    (make-objc-block cmptr (list _id _id) _int64))
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_QP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sortedArrayWithOptions:usingComparator:")) opts (id->ffi2-ptr _blk1)))
   ))
(define (nsarray-subarray-with-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "subarrayWithRange:")) (id->ffi2-ptr range)))
   ))
(define (nsarray-value-for-key self key)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "valueForKey:")) (id->ffi2-ptr (coerce-arg key))))
   ))
(define (nsarray-write-to-file-atomically self path use-auxiliary-file)
  (aw_racket_msg_Pb_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "writeToFile:atomically:")) (id->ffi2-ptr (coerce-arg path)) use-auxiliary-file))
(define (nsarray-write-to-url-atomically self url atomically)
  (aw_racket_msg_Pb_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "writeToURL:atomically:")) (id->ffi2-ptr (coerce-arg url)) atomically))
;; NSError out-param: result-or-error wrapper candidate
(define (nsarray-write-to-url-error self url)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_P_b_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "writeToURL:error:")) (id->ffi2-ptr (coerce-arg url)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))

;; --- Class methods ---
(define (nsarray-array)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSArray) (id->ffi2-ptr (sel_registerName "array"))))
   ))
(define (nsarray-array-with-array array)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr NSArray) (id->ffi2-ptr (sel_registerName "arrayWithArray:")) (id->ffi2-ptr (coerce-arg array))))
   ))
(define (nsarray-array-with-contents-of-file path)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr NSArray) (id->ffi2-ptr (sel_registerName "arrayWithContentsOfFile:")) (id->ffi2-ptr (coerce-arg path))))
   ))
(define (nsarray-array-with-contents-of-url url)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr NSArray) (id->ffi2-ptr (sel_registerName "arrayWithContentsOfURL:")) (id->ffi2-ptr (coerce-arg url))))
   ))
;; NSError out-param: result-or-error wrapper candidate
(define (nsarray-array-with-contents-of-url-error url)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_P_P_e (id->ffi2-ptr NSArray) (id->ffi2-ptr (sel_registerName "arrayWithContentsOfURL:error:")) (id->ffi2-ptr (coerce-arg url)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values (wrap-objc-object (ffi2-ptr->id result)) (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
(define (nsarray-array-with-object an-object)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr NSArray) (id->ffi2-ptr (sel_registerName "arrayWithObject:")) (id->ffi2-ptr (coerce-arg an-object))))
   ))
(define (nsarray-array-with-objects-count objects cnt)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PQ_P (id->ffi2-ptr NSArray) (id->ffi2-ptr (sel_registerName "arrayWithObjects:count:")) (id->ffi2-ptr objects) cnt))
   ))
(define (nsarray-supports-secure-coding)
  (aw_racket_msg_0_b (id->ffi2-ptr NSArray) (id->ffi2-ptr (sel_registerName "supportsSecureCoding"))))

;; --- Swift-native methods (receiver-handle trampolines, ADR-0030) ---
(define nsarray-make-iterator
  (let ([raw (get-ffi-obj 'aw_racket_swift_m_Foundation_NSArray_makeIterator _aw-lib (_fun _pointer aw-> _pointer))])
    (lambda (self)
      (raw (coerce-arg self)))))
