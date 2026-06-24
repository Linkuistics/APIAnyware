#lang racket/base
;; test-block-creation.rkt — Verify ObjC block creation through Swift dylib
;;
;; Tests:
;;   1. Create a block from a Racket lambda
;;   2. Pass block to NSArray's enumerateObjectsUsingBlock: (sync)
;;   3. Verify callback fires with correct args
;;   4. Block cleanup via free-objc-block
;;   5. NSArray's sortedArrayUsingComparator: with a comparison block

(require rackunit
         rackunit/text-ui
         ffi/unsafe
         ffi/unsafe/objc
         "../runtime/swift-helpers.rkt"
         "../runtime/objc-base.rkt"
         "../runtime/block.rkt"
         "../runtime/type-mapping.rkt")

;; ObjC runtime bindings for calling methods with block parameters
(define objc-lib (ffi-lib "libobjc"))

;; objc_msgSend for enumerateObjectsUsingBlock: (one block arg)
(define msg-send-block
  (get-ffi-obj "objc_msgSend" objc-lib
    (_fun _pointer _pointer _pointer -> _void)))

;; objc_msgSend for sortedArrayUsingComparator: (one block arg, returns id)
(define msg-send-block->id
  (get-ffi-obj "objc_msgSend" objc-lib
    (_fun _pointer _pointer _pointer -> _pointer)))

(define sel-enumerate (sel_registerName "enumerateObjectsUsingBlock:"))
(define sel-sorted (sel_registerName "sortedArrayUsingComparator:"))

(import-class NSNumber)

(define block-tests
  (test-suite
   "Block creation and invocation"

   (test-case "Create and free a simple block"
     (define called? (box #f))
     (define-values (blk blk-id)
       (make-objc-block
        (lambda () (set-box! called? #t))
        '()
        _void))
     (check-pred cpointer? blk "Block should be a pointer")
     (check-pred integer? blk-id "Block ID should be an integer")
     ;; Free without invoking — just test lifecycle
     (free-objc-block blk-id))

   (test-case "Block invoked by enumerateObjectsUsingBlock:"
     (with-autorelease-pool
       ;; Build an NSArray of 3 NSStrings
       (let* ([s1 (string->nsstring "alpha")]
              [s2 (string->nsstring "beta")]
              [s3 (string->nsstring "gamma")]
              [arr (list->nsarray (list s1 s2 s3))]
              ;; Collect objects seen by the block
              [seen (box '())])

         ;; Block signature: (id obj, NSUInteger idx, BOOL *stop) -> void
         (define-values (blk blk-id)
           (make-objc-block
            (lambda (obj idx stop-ptr)
              (set-box! seen (cons (nsstring->string (cast obj _pointer _id))
                                   (unbox seen))))
            (list _pointer _uint64 _pointer)
            _void))

         ;; Call enumerateObjectsUsingBlock:
         (msg-send-block (unwrap-objc-object arr) sel-enumerate blk)

         ;; Verify all 3 elements were visited
         (let ([result (reverse (unbox seen))])
           (check-equal? result '("alpha" "beta" "gamma")
                         "Block should see all 3 array elements"))

         ;; Cleanup
         (free-objc-block blk-id))))

   (test-case "Block with early stop via BOOL* parameter"
     (with-autorelease-pool
       (let* ([s1 (string->nsstring "first")]
              [s2 (string->nsstring "second")]
              [s3 (string->nsstring "third")]
              [arr (list->nsarray (list s1 s2 s3))]
              [seen (box '())])

         ;; Block that stops after seeing "second"
         (define-values (blk blk-id)
           (make-objc-block
            (lambda (obj idx stop-ptr)
              (let ([str (nsstring->string (cast obj _pointer _id))])
                (set-box! seen (cons str (unbox seen)))
                (when (equal? str "second")
                  ;; Set *stop = YES (1 byte, value 1)
                  (ptr-set! stop-ptr _byte 1))))
            (list _pointer _uint64 _pointer)
            _void))

         (msg-send-block (unwrap-objc-object arr) sel-enumerate blk)

         (let ([result (reverse (unbox seen))])
           (check-equal? result '("first" "second")
                         "Block should stop after 'second'"))

         (free-objc-block blk-id))))

   (test-case "Comparator block with sortedArrayUsingComparator:"
     (with-autorelease-pool
       ;; Create NSNumbers for sorting: 30, 10, 20
       (let* ([n1 (tell NSNumber numberWithInt: #:type _int 30)]
              [n2 (tell NSNumber numberWithInt: #:type _int 10)]
              [n3 (tell NSNumber numberWithInt: #:type _int 20)]
              [arr (list->nsarray (list n1 n2 n3))])

         ;; Comparator block: (id, id) -> NSComparisonResult (NSInteger)
         ;; NSOrderedAscending = -1, NSOrderedSame = 0, NSOrderedDescending = 1
         (define-values (blk blk-id)
           (make-objc-block
            (lambda (a b)
              (let ([va (tell #:type _int (cast a _pointer _id) intValue)]
                    [vb (tell #:type _int (cast b _pointer _id) intValue)])
                (cond [(< va vb) -1]
                      [(> va vb) 1]
                      [else 0])))
            (list _pointer _pointer)
            _int64))

         (let* ([sorted-ptr (msg-send-block->id (unwrap-objc-object arr) sel-sorted blk)]
                [sorted (cast sorted-ptr _pointer _id)]
                [sorted-list (nsarray->list sorted)]
                [values (map (lambda (n) (tell #:type _int n intValue)) sorted-list)])
           (check-equal? values '(10 20 30)
                         "NSNumbers should be sorted ascending"))

         (free-objc-block blk-id))))

   (test-case "call-with-objc-block convenience"
     (with-autorelease-pool
       (let* ([s1 (string->nsstring "x")]
              [arr (list->nsarray (list s1))]
              [count (box 0)])

         (define-values (result blk-id)
           (call-with-objc-block
            (lambda (obj idx stop) (set-box! count (add1 (unbox count))))
            (list _pointer _uint64 _pointer)
            _void
            (lambda (blk)
              (msg-send-block (unwrap-objc-object arr) sel-enumerate blk)
              (unbox count))))

         (check-equal? result 1 "Block should have been called once")
         (free-objc-block blk-id))))

   (test-case "make-objc-block with #f returns NULL pointer"
     ;; Passing #f as proc should return a NULL block pointer,
     ;; not a wrapped lambda that crashes on invocation.
     ;; This is how callers express "no callback" (ObjC nil block).
     (define-values (blk blk-id)
       (make-objc-block #f '() _void))
     (check-false blk "Block pointer should be #f (NULL) for nil proc")
     (check-false blk-id "Block ID should be #f for nil proc"))

   (test-case "free-objc-block with #f block-id is a no-op"
     ;; Freeing a nil block should not error
     (check-not-exn
       (lambda () (free-objc-block #f))
       "free-objc-block should accept #f gracefully"))

   (test-case "call-with-objc-block with #f proc passes NULL"
     ;; When proc is #f, the body should receive #f as the block pointer.
     (define-values (result blk-id)
       (call-with-objc-block
        #f '() _void
        (lambda (blk)
          (check-false blk "Body should receive #f for nil block")
          'ok)))
     (check-equal? result 'ok "Body should execute normally")
     (check-false blk-id "Block ID should be #f for nil proc"))))

(run-tests block-tests)
