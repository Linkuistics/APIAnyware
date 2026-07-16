;;; Generated binding for NSArray (Foundation) — do not edit
(import :std/foreign
        (rename-in :std/generic (defgeneric g:defgeneric) (defmethod g:defmethod))
        :gerbil-bindings/generics
        :gerbil-bindings/runtime/objc)
(export
  NSArray
  NSArray?
  array-by-adding-object
  array-by-adding-objects-from-array
  array-by-applying-difference
  components-joined-by-string
  contains-object
  count
  custom-mirror
  description
  description-with-locale
  description-with-locale-indent
  difference-from-array
  difference-from-array-with-options
  difference-from-array-with-options-using-equivalence-test
  encode-with-coder
  enumerate-objects-at-indexes-options-using-block
  enumerate-objects-using-block
  enumerate-objects-with-options-using-block
  filtered-array-using-predicate
  first-object
  first-object-common-with-array
  index-of-object
  index-of-object-at-indexes-options-passing-test
  index-of-object-identical-to
  index-of-object-identical-to-in-range
  index-of-object-in-range
  index-of-object-in-sorted-range-options-using-comparator
  index-of-object-passing-test
  index-of-object-with-options-passing-test
  indexes-of-objects-at-indexes-options-passing-test
  indexes-of-objects-passing-test
  indexes-of-objects-with-options-passing-test
  is-equal-to-array
  last-object
  make-nsarray-init-with-array
  make-nsarray-init-with-array-copy-items
  make-nsarray-init-with-coder
  make-nsarray-init-with-contents-of-file
  make-nsarray-init-with-contents-of-url
  make-objects-perform-selector
  make-objects-perform-selector-with-object
  nsarray-array
  nsarray-array-by-adding-object
  nsarray-array-by-adding-objects-from-array
  nsarray-array-by-applying-difference
  nsarray-array-with-array
  nsarray-array-with-contents-of-file
  nsarray-array-with-contents-of-url
  nsarray-array-with-contents-of-url-error
  nsarray-array-with-object
  nsarray-components-joined-by-string
  nsarray-contains-object
  nsarray-count
  nsarray-custom-mirror
  nsarray-description
  nsarray-description-with-locale
  nsarray-description-with-locale-indent
  nsarray-difference-from-array
  nsarray-difference-from-array-with-options
  nsarray-difference-from-array-with-options-using-equivalence-test
  nsarray-encode-with-coder
  nsarray-enumerate-objects-at-indexes-options-using-block
  nsarray-enumerate-objects-using-block
  nsarray-enumerate-objects-with-options-using-block
  nsarray-filtered-array-using-predicate
  nsarray-first-object
  nsarray-first-object-common-with-array
  nsarray-index-of-object
  nsarray-index-of-object-at-indexes-options-passing-test
  nsarray-index-of-object-identical-to
  nsarray-index-of-object-identical-to-in-range
  nsarray-index-of-object-in-range
  nsarray-index-of-object-in-sorted-range-options-using-comparator
  nsarray-index-of-object-passing-test
  nsarray-index-of-object-with-options-passing-test
  nsarray-indexes-of-objects-at-indexes-options-passing-test
  nsarray-indexes-of-objects-passing-test
  nsarray-indexes-of-objects-with-options-passing-test
  nsarray-is-equal-to-array
  nsarray-last-object
  nsarray-make-iterator
  nsarray-make-objects-perform-selector
  nsarray-make-objects-perform-selector-with-object
  nsarray-object-at-index
  nsarray-object-at-indexed-subscript
  nsarray-object-enumerator
  nsarray-objects-at-indexes
  nsarray-paths-matching-extensions
  nsarray-remove-observer-for-key-path!
  nsarray-remove-observer-from-objects-at-indexes-for-key-path!
  nsarray-reverse-object-enumerator
  nsarray-set-value-for-key!
  nsarray-sorted-array-hint
  nsarray-sorted-array-using-comparator
  nsarray-sorted-array-using-descriptors
  nsarray-sorted-array-using-selector
  nsarray-sorted-array-with-options-using-comparator
  nsarray-subarray-with-range
  nsarray-supports-secure-coding
  nsarray-underestimated-count
  nsarray-value-for-key
  nsarray-write-to-file-atomically
  nsarray-write-to-url-atomically
  nsarray-write-to-url-error
  object-at-index
  object-at-indexed-subscript
  object-enumerator
  objects-at-indexes
  paths-matching-extensions
  remove-observer-for-key-path!
  remove-observer-from-objects-at-indexes-for-key-path!
  reverse-object-enumerator
  set-value-for-key!
  sorted-array-hint
  sorted-array-using-comparator
  sorted-array-using-descriptors
  sorted-array-using-selector
  sorted-array-with-options-using-comparator
  subarray-with-range
  underestimated-count
  value-for-key
  write-to-file-atomically
  write-to-url-atomically
  write-to-url-error
  )

;; --- Class graph (ADR-0020) ---
(defclass (NSArray NSObject) () transparent: #t)
(register-objc-class! (lambda (p) (make-NSArray ptr: p)) NSArray::t "NSArray" "NSObject")

(begin-ffi (objc_getClass sel_registerName
            %msg-nsrange->p
            %msg-p->b
            %msg-p->p
            %msg-p->u64
            %msg-p->v
            %msg-p-b->b
            %msg-p-b->p
            %msg-p-nsrange->u64
            %msg-p-nsrange-u64-p->u64
            %msg-p-p->v
            %msg-p-p-p->v
            %msg-p-pp->b-e
            %msg-p-pp->p-e
            %msg-p-u64->p
            %msg-p-u64-p->p
            %msg-p-u64-p->u64
            %msg-p-u64-p->v
            %msg-u64->p
            %msg-u64-p->p
            %msg-u64-p->u64
            %msg-u64-p->v
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
  (define-c-lambda %msg-nsrange->p ((pointer void) (pointer void) NSRange) (pointer void)
    "___return( ((id (*)(id, SEL, NSRange))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3) );")
  (define-c-lambda %msg-p->b ((pointer void) (pointer void) (pointer void)) bool
    "___return( ((BOOL (*)(id, SEL, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3) );")
  (define-c-lambda %msg-p->p ((pointer void) (pointer void) (pointer void)) (pointer void)
    "___return( ((id (*)(id, SEL, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3) );")
  (define-c-lambda %msg-p->u64 ((pointer void) (pointer void) (pointer void)) unsigned-int64
    "___return( ((uint64_t (*)(id, SEL, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3) );")
  (define-c-lambda %msg-p->v ((pointer void) (pointer void) (pointer void)) void
    "((void (*)(id, SEL, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3);")
  (define-c-lambda %msg-p-b->b ((pointer void) (pointer void) (pointer void) bool) bool
    "___return( ((BOOL (*)(id, SEL, id, BOOL))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4) );")
  (define-c-lambda %msg-p-b->p ((pointer void) (pointer void) (pointer void) bool) (pointer void)
    "___return( ((id (*)(id, SEL, id, BOOL))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4) );")
  (define-c-lambda %msg-p-nsrange->u64 ((pointer void) (pointer void) (pointer void) NSRange) unsigned-int64
    "___return( ((uint64_t (*)(id, SEL, id, NSRange))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4) );")
  (define-c-lambda %msg-p-nsrange-u64-p->u64 ((pointer void) (pointer void) (pointer void) NSRange unsigned-int64 (pointer void)) unsigned-int64
    "___return( ((uint64_t (*)(id, SEL, id, NSRange, uint64_t, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4, ___arg5, ___arg6) );")
  (define-c-lambda %msg-p-p->v ((pointer void) (pointer void) (pointer void) (pointer void)) void
    "((void (*)(id, SEL, id, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4);")
  (define-c-lambda %msg-p-p-p->v ((pointer void) (pointer void) (pointer void) (pointer void) (pointer void)) void
    "((void (*)(id, SEL, id, id, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4, ___arg5);")
  (define-c-lambda %msg-p-pp->b-e ((pointer void) (pointer void) (pointer void) (pointer (pointer void))) bool
    "___return( ((BOOL (*)(id, SEL, id, id*))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, (id*)___arg4) );")
  (define-c-lambda %msg-p-pp->p-e ((pointer void) (pointer void) (pointer void) (pointer (pointer void))) (pointer void)
    "___return( ((id (*)(id, SEL, id, id*))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, (id*)___arg4) );")
  (define-c-lambda %msg-p-u64->p ((pointer void) (pointer void) (pointer void) unsigned-int64) (pointer void)
    "___return( ((id (*)(id, SEL, id, uint64_t))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4) );")
  (define-c-lambda %msg-p-u64-p->p ((pointer void) (pointer void) (pointer void) unsigned-int64 (pointer void)) (pointer void)
    "___return( ((id (*)(id, SEL, id, uint64_t, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4, ___arg5) );")
  (define-c-lambda %msg-p-u64-p->u64 ((pointer void) (pointer void) (pointer void) unsigned-int64 (pointer void)) unsigned-int64
    "___return( ((uint64_t (*)(id, SEL, id, uint64_t, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4, ___arg5) );")
  (define-c-lambda %msg-p-u64-p->v ((pointer void) (pointer void) (pointer void) unsigned-int64 (pointer void)) void
    "((void (*)(id, SEL, id, uint64_t, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4, ___arg5);")
  (define-c-lambda %msg-u64->p ((pointer void) (pointer void) unsigned-int64) (pointer void)
    "___return( ((id (*)(id, SEL, uint64_t))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3) );")
  (define-c-lambda %msg-u64-p->p ((pointer void) (pointer void) unsigned-int64 (pointer void)) (pointer void)
    "___return( ((id (*)(id, SEL, uint64_t, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4) );")
  (define-c-lambda %msg-u64-p->u64 ((pointer void) (pointer void) unsigned-int64 (pointer void)) unsigned-int64
    "___return( ((uint64_t (*)(id, SEL, uint64_t, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4) );")
  (define-c-lambda %msg-u64-p->v ((pointer void) (pointer void) unsigned-int64 (pointer void)) void
    "((void (*)(id, SEL, uint64_t, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4);")
  (define-c-lambda %msg-v->b ((pointer void) (pointer void)) bool
    "___return( ((BOOL (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  (define-c-lambda %msg-v->i64 ((pointer void) (pointer void)) int64
    "___return( ((int64_t (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  (define-c-lambda %msg-v->p ((pointer void) (pointer void)) (pointer void)
    "___return( ((id (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  (define-c-lambda %msg-v->u64 ((pointer void) (pointer void)) unsigned-int64
    "___return( ((uint64_t (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  )

(define %sel-nsarray-init-with-coder (sel_registerName "initWithCoder:"))
(define %sel-nsarray-init-with-array (sel_registerName "initWithArray:"))
(define %sel-nsarray-init-with-array-copy-items (sel_registerName "initWithArray:copyItems:"))
(define %sel-nsarray-init-with-contents-of-file (sel_registerName "initWithContentsOfFile:"))
(define %sel-nsarray-init-with-contents-of-url (sel_registerName "initWithContentsOfURL:"))
(define %sel-nsarray-object-at-index (sel_registerName "objectAtIndex:"))
(define %sel-nsarray-array-by-adding-object (sel_registerName "arrayByAddingObject:"))
(define %sel-nsarray-array-by-adding-objects-from-array (sel_registerName "arrayByAddingObjectsFromArray:"))
(define %sel-nsarray-components-joined-by-string (sel_registerName "componentsJoinedByString:"))
(define %sel-nsarray-contains-object (sel_registerName "containsObject:"))
(define %sel-nsarray-description-with-locale (sel_registerName "descriptionWithLocale:"))
(define %sel-nsarray-description-with-locale-indent (sel_registerName "descriptionWithLocale:indent:"))
(define %sel-nsarray-first-object-common-with-array (sel_registerName "firstObjectCommonWithArray:"))
(define %sel-nsarray-index-of-object (sel_registerName "indexOfObject:"))
(define %sel-nsarray-index-of-object-in-range (sel_registerName "indexOfObject:inRange:"))
(define %sel-nsarray-index-of-object-identical-to (sel_registerName "indexOfObjectIdenticalTo:"))
(define %sel-nsarray-index-of-object-identical-to-in-range (sel_registerName "indexOfObjectIdenticalTo:inRange:"))
(define %sel-nsarray-is-equal-to-array (sel_registerName "isEqualToArray:"))
(define %sel-nsarray-object-enumerator (sel_registerName "objectEnumerator"))
(define %sel-nsarray-reverse-object-enumerator (sel_registerName "reverseObjectEnumerator"))
(define %sel-nsarray-sorted-array-using-selector (sel_registerName "sortedArrayUsingSelector:"))
(define %sel-nsarray-subarray-with-range (sel_registerName "subarrayWithRange:"))
(define %sel-nsarray-write-to-url-error (sel_registerName "writeToURL:error:"))
(define %sel-nsarray-make-objects-perform-selector (sel_registerName "makeObjectsPerformSelector:"))
(define %sel-nsarray-make-objects-perform-selector-with-object (sel_registerName "makeObjectsPerformSelector:withObject:"))
(define %sel-nsarray-objects-at-indexes (sel_registerName "objectsAtIndexes:"))
(define %sel-nsarray-object-at-indexed-subscript (sel_registerName "objectAtIndexedSubscript:"))
(define %sel-nsarray-enumerate-objects-using-block (sel_registerName "enumerateObjectsUsingBlock:"))
(define %sel-nsarray-enumerate-objects-with-options-using-block (sel_registerName "enumerateObjectsWithOptions:usingBlock:"))
(define %sel-nsarray-enumerate-objects-at-indexes-options-using-block (sel_registerName "enumerateObjectsAtIndexes:options:usingBlock:"))
(define %sel-nsarray-index-of-object-passing-test (sel_registerName "indexOfObjectPassingTest:"))
(define %sel-nsarray-index-of-object-with-options-passing-test (sel_registerName "indexOfObjectWithOptions:passingTest:"))
(define %sel-nsarray-index-of-object-at-indexes-options-passing-test (sel_registerName "indexOfObjectAtIndexes:options:passingTest:"))
(define %sel-nsarray-indexes-of-objects-passing-test (sel_registerName "indexesOfObjectsPassingTest:"))
(define %sel-nsarray-indexes-of-objects-with-options-passing-test (sel_registerName "indexesOfObjectsWithOptions:passingTest:"))
(define %sel-nsarray-indexes-of-objects-at-indexes-options-passing-test (sel_registerName "indexesOfObjectsAtIndexes:options:passingTest:"))
(define %sel-nsarray-sorted-array-using-comparator (sel_registerName "sortedArrayUsingComparator:"))
(define %sel-nsarray-sorted-array-with-options-using-comparator (sel_registerName "sortedArrayWithOptions:usingComparator:"))
(define %sel-nsarray-index-of-object-in-sorted-range-options-using-comparator (sel_registerName "indexOfObject:inSortedRange:options:usingComparator:"))
(define %sel-nsarray-difference-from-array-with-options-using-equivalence-test (sel_registerName "differenceFromArray:withOptions:usingEquivalenceTest:"))
(define %sel-nsarray-difference-from-array-with-options (sel_registerName "differenceFromArray:withOptions:"))
(define %sel-nsarray-difference-from-array (sel_registerName "differenceFromArray:"))
(define %sel-nsarray-array-by-applying-difference (sel_registerName "arrayByApplyingDifference:"))
(define %sel-nsarray-write-to-file-atomically (sel_registerName "writeToFile:atomically:"))
(define %sel-nsarray-write-to-url-atomically (sel_registerName "writeToURL:atomically:"))
(define %sel-nsarray-paths-matching-extensions (sel_registerName "pathsMatchingExtensions:"))
(define %sel-nsarray-value-for-key (sel_registerName "valueForKey:"))
(define %sel-nsarray-set-value-for-key (sel_registerName "setValue:forKey:"))
(define %sel-nsarray-remove-observer-from-objects-at-indexes-for-key-path (sel_registerName "removeObserver:fromObjectsAtIndexes:forKeyPath:"))
(define %sel-nsarray-remove-observer-for-key-path (sel_registerName "removeObserver:forKeyPath:"))
(define %sel-nsarray-sorted-array-using-descriptors (sel_registerName "sortedArrayUsingDescriptors:"))
(define %sel-nsarray-filtered-array-using-predicate (sel_registerName "filteredArrayUsingPredicate:"))
(define %sel-nsarray-encode-with-coder (sel_registerName "encodeWithCoder:"))
(define %sel-nsarray-array (sel_registerName "array"))
(define %sel-nsarray-array-with-object (sel_registerName "arrayWithObject:"))
(define %sel-nsarray-array-with-array (sel_registerName "arrayWithArray:"))
(define %sel-nsarray-array-with-contents-of-url-error (sel_registerName "arrayWithContentsOfURL:error:"))
(define %sel-nsarray-array-with-contents-of-file (sel_registerName "arrayWithContentsOfFile:"))
(define %sel-nsarray-array-with-contents-of-url (sel_registerName "arrayWithContentsOfURL:"))
(define %sel-nsarray-supports-secure-coding (sel_registerName "supportsSecureCoding"))
(define %sel-nsarray-count (sel_registerName "count"))
(define %sel-nsarray-description (sel_registerName "description"))
(define %sel-nsarray-first-object (sel_registerName "firstObject"))
(define %sel-nsarray-last-object (sel_registerName "lastObject"))
(define %sel-nsarray-sorted-array-hint (sel_registerName "sortedArrayHint"))
(define %sel-nsarray-underestimated-count (sel_registerName "underestimatedCount"))
(define %sel-nsarray-custom-mirror (sel_registerName "customMirror"))

;; --- Dispatch surfaces (ADR-0020): inlinable proc core; generics are
;;     declared once in :gerbil-bindings/generics and extended below ---
(declare (inline))

;; --- Constructors ---
(define (make-nsarray-init-with-coder coder)
  (wrap (%msg-p->p (%msg-v->p (objc_getClass "NSArray") (sel_registerName "alloc")) %sel-nsarray-init-with-coder (->ptr coder)) #t))

(define (make-nsarray-init-with-array array)
  (wrap (%msg-p->p (%msg-v->p (objc_getClass "NSArray") (sel_registerName "alloc")) %sel-nsarray-init-with-array (->ptr array)) #t))

(define (make-nsarray-init-with-array-copy-items array flag)
  (wrap (%msg-p-b->p (%msg-v->p (objc_getClass "NSArray") (sel_registerName "alloc")) %sel-nsarray-init-with-array-copy-items (->ptr array) flag) #t))

(define (make-nsarray-init-with-contents-of-file path)
  (wrap (%msg-p->p (%msg-v->p (objc_getClass "NSArray") (sel_registerName "alloc")) %sel-nsarray-init-with-contents-of-file (->ptr path)) #t))

(define (make-nsarray-init-with-contents-of-url url)
  (wrap (%msg-p->p (%msg-v->p (objc_getClass "NSArray") (sel_registerName "alloc")) %sel-nsarray-init-with-contents-of-url (->ptr url)) #t))

;; --- Properties ---
(define (nsarray-count self)
  (%msg-v->u64 (NSObject-ptr self) %sel-nsarray-count))
(defmethod {count NSArray} (lambda (self) (nsarray-count self)))
(g:defmethod (count (o NSArray)) (nsarray-count o))

(define (nsarray-description self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsarray-description)))
(defmethod {description NSArray} (lambda (self) (nsarray-description self)))
(g:defmethod (description (o NSArray)) (nsarray-description o))

(define (nsarray-first-object self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsarray-first-object)))
(defmethod {first-object NSArray} (lambda (self) (nsarray-first-object self)))
(g:defmethod (first-object (o NSArray)) (nsarray-first-object o))

(define (nsarray-last-object self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsarray-last-object)))
(defmethod {last-object NSArray} (lambda (self) (nsarray-last-object self)))
(g:defmethod (last-object (o NSArray)) (nsarray-last-object o))

(define (nsarray-sorted-array-hint self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsarray-sorted-array-hint)))
(defmethod {sorted-array-hint NSArray} (lambda (self) (nsarray-sorted-array-hint self)))
(g:defmethod (sorted-array-hint (o NSArray)) (nsarray-sorted-array-hint o))

(define (nsarray-underestimated-count self)
  (%msg-v->i64 (NSObject-ptr self) %sel-nsarray-underestimated-count))
(defmethod {underestimated-count NSArray} (lambda (self) (nsarray-underestimated-count self)))
(g:defmethod (underestimated-count (o NSArray)) (nsarray-underestimated-count o))

(define (nsarray-custom-mirror self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsarray-custom-mirror)))
(defmethod {custom-mirror NSArray} (lambda (self) (nsarray-custom-mirror self)))
(g:defmethod (custom-mirror (o NSArray)) (nsarray-custom-mirror o))

;; --- Instance methods ---
(define (nsarray-object-at-index self index)
  (wrap (%msg-u64->p (NSObject-ptr self) %sel-nsarray-object-at-index index)))
(defmethod {object-at-index NSArray} (lambda (self index) (nsarray-object-at-index self index)))

(define (nsarray-array-by-adding-object self an-object)
  (wrap (%msg-p->p (NSObject-ptr self) %sel-nsarray-array-by-adding-object (->ptr an-object))))
(defmethod {array-by-adding-object NSArray} (lambda (self an-object) (nsarray-array-by-adding-object self an-object)))

(define (nsarray-array-by-adding-objects-from-array self other-array)
  (wrap (%msg-p->p (NSObject-ptr self) %sel-nsarray-array-by-adding-objects-from-array (->ptr other-array))))
(defmethod {array-by-adding-objects-from-array NSArray} (lambda (self other-array) (nsarray-array-by-adding-objects-from-array self other-array)))

(define (nsarray-components-joined-by-string self separator)
  (wrap (%msg-p->p (NSObject-ptr self) %sel-nsarray-components-joined-by-string (->ptr separator))))
(defmethod {components-joined-by-string NSArray} (lambda (self separator) (nsarray-components-joined-by-string self separator)))

(define (nsarray-contains-object self an-object)
  (%msg-p->b (NSObject-ptr self) %sel-nsarray-contains-object (->ptr an-object)))
(defmethod {contains-object NSArray} (lambda (self an-object) (nsarray-contains-object self an-object)))

(define (nsarray-description-with-locale self locale)
  (wrap (%msg-p->p (NSObject-ptr self) %sel-nsarray-description-with-locale (->ptr locale))))
(defmethod {description-with-locale NSArray} (lambda (self locale) (nsarray-description-with-locale self locale)))

(define (nsarray-description-with-locale-indent self locale level)
  (wrap (%msg-p-u64->p (NSObject-ptr self) %sel-nsarray-description-with-locale-indent (->ptr locale) level)))
(defmethod {description-with-locale-indent NSArray} (lambda (self locale level) (nsarray-description-with-locale-indent self locale level)))

(define (nsarray-first-object-common-with-array self other-array)
  (wrap (%msg-p->p (NSObject-ptr self) %sel-nsarray-first-object-common-with-array (->ptr other-array))))
(defmethod {first-object-common-with-array NSArray} (lambda (self other-array) (nsarray-first-object-common-with-array self other-array)))

(define (nsarray-index-of-object self an-object)
  (%msg-p->u64 (NSObject-ptr self) %sel-nsarray-index-of-object (->ptr an-object)))
(defmethod {index-of-object NSArray} (lambda (self an-object) (nsarray-index-of-object self an-object)))

(define (nsarray-index-of-object-in-range self an-object range)
  (%msg-p-nsrange->u64 (NSObject-ptr self) %sel-nsarray-index-of-object-in-range (->ptr an-object) range))
(defmethod {index-of-object-in-range NSArray} (lambda (self an-object range) (nsarray-index-of-object-in-range self an-object range)))

(define (nsarray-index-of-object-identical-to self an-object)
  (%msg-p->u64 (NSObject-ptr self) %sel-nsarray-index-of-object-identical-to (->ptr an-object)))
(defmethod {index-of-object-identical-to NSArray} (lambda (self an-object) (nsarray-index-of-object-identical-to self an-object)))

(define (nsarray-index-of-object-identical-to-in-range self an-object range)
  (%msg-p-nsrange->u64 (NSObject-ptr self) %sel-nsarray-index-of-object-identical-to-in-range (->ptr an-object) range))
(defmethod {index-of-object-identical-to-in-range NSArray} (lambda (self an-object range) (nsarray-index-of-object-identical-to-in-range self an-object range)))

(define (nsarray-is-equal-to-array self other-array)
  (%msg-p->b (NSObject-ptr self) %sel-nsarray-is-equal-to-array (->ptr other-array)))
(defmethod {is-equal-to-array NSArray} (lambda (self other-array) (nsarray-is-equal-to-array self other-array)))

(define (nsarray-object-enumerator self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsarray-object-enumerator)))
(defmethod {object-enumerator NSArray} (lambda (self) (nsarray-object-enumerator self)))
(g:defmethod (object-enumerator (o NSArray)) (nsarray-object-enumerator o))

(define (nsarray-reverse-object-enumerator self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsarray-reverse-object-enumerator)))
(defmethod {reverse-object-enumerator NSArray} (lambda (self) (nsarray-reverse-object-enumerator self)))
(g:defmethod (reverse-object-enumerator (o NSArray)) (nsarray-reverse-object-enumerator o))

(define (nsarray-sorted-array-using-selector self comparator)
  (wrap (%msg-p->p (NSObject-ptr self) %sel-nsarray-sorted-array-using-selector (sel_registerName comparator))))
(defmethod {sorted-array-using-selector NSArray} (lambda (self comparator) (nsarray-sorted-array-using-selector self comparator)))

(define (nsarray-subarray-with-range self range)
  (wrap (%msg-nsrange->p (NSObject-ptr self) %sel-nsarray-subarray-with-range range)))
(defmethod {subarray-with-range NSArray} (lambda (self range) (nsarray-subarray-with-range self range)))

(define (nsarray-write-to-url-error self url)
  (call-with-nserror-out
    (lambda (%err-cell)
      (%msg-p-pp->b-e (NSObject-ptr self) %sel-nsarray-write-to-url-error (->ptr url) %err-cell))))
(defmethod {write-to-url-error NSArray} (lambda (self url) (nsarray-write-to-url-error self url)))

(define (nsarray-make-objects-perform-selector self a-selector)
  (%msg-p->v (NSObject-ptr self) %sel-nsarray-make-objects-perform-selector (sel_registerName a-selector)))
(defmethod {make-objects-perform-selector NSArray} (lambda (self a-selector) (nsarray-make-objects-perform-selector self a-selector)))

(define (nsarray-make-objects-perform-selector-with-object self a-selector argument)
  (%msg-p-p->v (NSObject-ptr self) %sel-nsarray-make-objects-perform-selector-with-object (sel_registerName a-selector) (->ptr argument)))
(defmethod {make-objects-perform-selector-with-object NSArray} (lambda (self a-selector argument) (nsarray-make-objects-perform-selector-with-object self a-selector argument)))

(define (nsarray-objects-at-indexes self indexes)
  (wrap (%msg-p->p (NSObject-ptr self) %sel-nsarray-objects-at-indexes (->ptr indexes))))
(defmethod {objects-at-indexes NSArray} (lambda (self indexes) (nsarray-objects-at-indexes self indexes)))

(define (nsarray-object-at-indexed-subscript self idx)
  (wrap (%msg-u64->p (NSObject-ptr self) %sel-nsarray-object-at-indexed-subscript idx)))
(defmethod {object-at-indexed-subscript NSArray} (lambda (self idx) (nsarray-object-at-indexed-subscript self idx)))

(define (nsarray-enumerate-objects-using-block self block)
  (%msg-p->v (NSObject-ptr self) %sel-nsarray-enumerate-objects-using-block block))
(defmethod {enumerate-objects-using-block NSArray} (lambda (self block) (nsarray-enumerate-objects-using-block self block)))

(define (nsarray-enumerate-objects-with-options-using-block self opts block)
  (%msg-u64-p->v (NSObject-ptr self) %sel-nsarray-enumerate-objects-with-options-using-block opts block))
(defmethod {enumerate-objects-with-options-using-block NSArray} (lambda (self opts block) (nsarray-enumerate-objects-with-options-using-block self opts block)))

(define (nsarray-enumerate-objects-at-indexes-options-using-block self s opts block)
  (%msg-p-u64-p->v (NSObject-ptr self) %sel-nsarray-enumerate-objects-at-indexes-options-using-block (->ptr s) opts block))
(defmethod {enumerate-objects-at-indexes-options-using-block NSArray} (lambda (self s opts block) (nsarray-enumerate-objects-at-indexes-options-using-block self s opts block)))

(define (nsarray-index-of-object-passing-test self predicate)
  (%msg-p->u64 (NSObject-ptr self) %sel-nsarray-index-of-object-passing-test predicate))
(defmethod {index-of-object-passing-test NSArray} (lambda (self predicate) (nsarray-index-of-object-passing-test self predicate)))

(define (nsarray-index-of-object-with-options-passing-test self opts predicate)
  (%msg-u64-p->u64 (NSObject-ptr self) %sel-nsarray-index-of-object-with-options-passing-test opts predicate))
(defmethod {index-of-object-with-options-passing-test NSArray} (lambda (self opts predicate) (nsarray-index-of-object-with-options-passing-test self opts predicate)))

(define (nsarray-index-of-object-at-indexes-options-passing-test self s opts predicate)
  (%msg-p-u64-p->u64 (NSObject-ptr self) %sel-nsarray-index-of-object-at-indexes-options-passing-test (->ptr s) opts predicate))
(defmethod {index-of-object-at-indexes-options-passing-test NSArray} (lambda (self s opts predicate) (nsarray-index-of-object-at-indexes-options-passing-test self s opts predicate)))

(define (nsarray-indexes-of-objects-passing-test self predicate)
  (wrap (%msg-p->p (NSObject-ptr self) %sel-nsarray-indexes-of-objects-passing-test predicate)))
(defmethod {indexes-of-objects-passing-test NSArray} (lambda (self predicate) (nsarray-indexes-of-objects-passing-test self predicate)))

(define (nsarray-indexes-of-objects-with-options-passing-test self opts predicate)
  (wrap (%msg-u64-p->p (NSObject-ptr self) %sel-nsarray-indexes-of-objects-with-options-passing-test opts predicate)))
(defmethod {indexes-of-objects-with-options-passing-test NSArray} (lambda (self opts predicate) (nsarray-indexes-of-objects-with-options-passing-test self opts predicate)))

(define (nsarray-indexes-of-objects-at-indexes-options-passing-test self s opts predicate)
  (wrap (%msg-p-u64-p->p (NSObject-ptr self) %sel-nsarray-indexes-of-objects-at-indexes-options-passing-test (->ptr s) opts predicate)))
(defmethod {indexes-of-objects-at-indexes-options-passing-test NSArray} (lambda (self s opts predicate) (nsarray-indexes-of-objects-at-indexes-options-passing-test self s opts predicate)))

(define (nsarray-sorted-array-using-comparator self cmptr)
  (wrap (%msg-p->p (NSObject-ptr self) %sel-nsarray-sorted-array-using-comparator cmptr)))
(defmethod {sorted-array-using-comparator NSArray} (lambda (self cmptr) (nsarray-sorted-array-using-comparator self cmptr)))

(define (nsarray-sorted-array-with-options-using-comparator self opts cmptr)
  (wrap (%msg-u64-p->p (NSObject-ptr self) %sel-nsarray-sorted-array-with-options-using-comparator opts cmptr)))
(defmethod {sorted-array-with-options-using-comparator NSArray} (lambda (self opts cmptr) (nsarray-sorted-array-with-options-using-comparator self opts cmptr)))

(define (nsarray-index-of-object-in-sorted-range-options-using-comparator self obj r opts cmp)
  (%msg-p-nsrange-u64-p->u64 (NSObject-ptr self) %sel-nsarray-index-of-object-in-sorted-range-options-using-comparator (->ptr obj) r opts cmp))
(defmethod {index-of-object-in-sorted-range-options-using-comparator NSArray} (lambda (self obj r opts cmp) (nsarray-index-of-object-in-sorted-range-options-using-comparator self obj r opts cmp)))

(define (nsarray-difference-from-array-with-options-using-equivalence-test self other options block)
  (wrap (%msg-p-u64-p->p (NSObject-ptr self) %sel-nsarray-difference-from-array-with-options-using-equivalence-test (->ptr other) options block)))
(defmethod {difference-from-array-with-options-using-equivalence-test NSArray} (lambda (self other options block) (nsarray-difference-from-array-with-options-using-equivalence-test self other options block)))

(define (nsarray-difference-from-array-with-options self other options)
  (wrap (%msg-p-u64->p (NSObject-ptr self) %sel-nsarray-difference-from-array-with-options (->ptr other) options)))
(defmethod {difference-from-array-with-options NSArray} (lambda (self other options) (nsarray-difference-from-array-with-options self other options)))

(define (nsarray-difference-from-array self other)
  (wrap (%msg-p->p (NSObject-ptr self) %sel-nsarray-difference-from-array (->ptr other))))
(defmethod {difference-from-array NSArray} (lambda (self other) (nsarray-difference-from-array self other)))

(define (nsarray-array-by-applying-difference self difference)
  (wrap (%msg-p->p (NSObject-ptr self) %sel-nsarray-array-by-applying-difference (->ptr difference))))
(defmethod {array-by-applying-difference NSArray} (lambda (self difference) (nsarray-array-by-applying-difference self difference)))

(define (nsarray-write-to-file-atomically self path use-auxiliary-file)
  (%msg-p-b->b (NSObject-ptr self) %sel-nsarray-write-to-file-atomically (->ptr path) use-auxiliary-file))
(defmethod {write-to-file-atomically NSArray} (lambda (self path use-auxiliary-file) (nsarray-write-to-file-atomically self path use-auxiliary-file)))

(define (nsarray-write-to-url-atomically self url atomically)
  (%msg-p-b->b (NSObject-ptr self) %sel-nsarray-write-to-url-atomically (->ptr url) atomically))
(defmethod {write-to-url-atomically NSArray} (lambda (self url atomically) (nsarray-write-to-url-atomically self url atomically)))

(define (nsarray-paths-matching-extensions self filter-types)
  (wrap (%msg-p->p (NSObject-ptr self) %sel-nsarray-paths-matching-extensions (->ptr filter-types))))
(defmethod {paths-matching-extensions NSArray} (lambda (self filter-types) (nsarray-paths-matching-extensions self filter-types)))

(define (nsarray-value-for-key self key)
  (wrap (%msg-p->p (NSObject-ptr self) %sel-nsarray-value-for-key (->ptr key))))
(defmethod {value-for-key NSArray} (lambda (self key) (nsarray-value-for-key self key)))

(define (nsarray-set-value-for-key! self value key)
  (%msg-p-p->v (NSObject-ptr self) %sel-nsarray-set-value-for-key (->ptr value) (->ptr key)))
(defmethod {set-value-for-key! NSArray} (lambda (self value key) (nsarray-set-value-for-key! self value key)))

(define (nsarray-remove-observer-from-objects-at-indexes-for-key-path! self observer indexes key-path)
  (%msg-p-p-p->v (NSObject-ptr self) %sel-nsarray-remove-observer-from-objects-at-indexes-for-key-path (->ptr observer) (->ptr indexes) (->ptr key-path)))
(defmethod {remove-observer-from-objects-at-indexes-for-key-path! NSArray} (lambda (self observer indexes key-path) (nsarray-remove-observer-from-objects-at-indexes-for-key-path! self observer indexes key-path)))

(define (nsarray-remove-observer-for-key-path! self observer key-path)
  (%msg-p-p->v (NSObject-ptr self) %sel-nsarray-remove-observer-for-key-path (->ptr observer) (->ptr key-path)))
(defmethod {remove-observer-for-key-path! NSArray} (lambda (self observer key-path) (nsarray-remove-observer-for-key-path! self observer key-path)))

(define (nsarray-sorted-array-using-descriptors self sort-descriptors)
  (wrap (%msg-p->p (NSObject-ptr self) %sel-nsarray-sorted-array-using-descriptors (->ptr sort-descriptors))))
(defmethod {sorted-array-using-descriptors NSArray} (lambda (self sort-descriptors) (nsarray-sorted-array-using-descriptors self sort-descriptors)))

(define (nsarray-filtered-array-using-predicate self predicate)
  (wrap (%msg-p->p (NSObject-ptr self) %sel-nsarray-filtered-array-using-predicate (->ptr predicate))))
(defmethod {filtered-array-using-predicate NSArray} (lambda (self predicate) (nsarray-filtered-array-using-predicate self predicate)))

(define (nsarray-encode-with-coder self coder)
  (%msg-p->v (NSObject-ptr self) %sel-nsarray-encode-with-coder (->ptr coder)))
(defmethod {encode-with-coder NSArray} (lambda (self coder) (nsarray-encode-with-coder self coder)))

;; --- Class methods ---
(define (nsarray-array)
  (wrap (%msg-v->p (objc_getClass "NSArray") %sel-nsarray-array)))

(define (nsarray-array-with-object an-object)
  (wrap (%msg-p->p (objc_getClass "NSArray") %sel-nsarray-array-with-object (->ptr an-object))))

(define (nsarray-array-with-array array)
  (wrap (%msg-p->p (objc_getClass "NSArray") %sel-nsarray-array-with-array (->ptr array))))

(define (nsarray-array-with-contents-of-url-error url)
  (call-with-nserror-out
    (lambda (%err-cell)
      (wrap (%msg-p-pp->p-e (objc_getClass "NSArray") %sel-nsarray-array-with-contents-of-url-error (->ptr url) %err-cell)))))

(define (nsarray-array-with-contents-of-file path)
  (wrap (%msg-p->p (objc_getClass "NSArray") %sel-nsarray-array-with-contents-of-file (->ptr path))))

(define (nsarray-array-with-contents-of-url url)
  (wrap (%msg-p->p (objc_getClass "NSArray") %sel-nsarray-array-with-contents-of-url (->ptr url))))

(define (nsarray-supports-secure-coding)
  (%msg-v->b (objc_getClass "NSArray") %sel-nsarray-supports-secure-coding))

;; --- Swift-native methods (receiver-handle trampolines, ADR-0030) ---
;; Trampolined through libAPIAnywareGerbil (aw_gerbil_swift_* entries),
;; not the framework dylib (ADR-0029); receiver coerced via (->ptr self).
(begin-ffi (
            %swift-nsarray-make-iterator
            )
  (c-declare "extern void * aw_gerbil_swift_m_Foundation_NSArray_makeIterator(void *);")

  (define-c-lambda %swift-nsarray-make-iterator ((pointer void)) (pointer void) "aw_gerbil_swift_m_Foundation_NSArray_makeIterator")
  )

(define nsarray-make-iterator
  (lambda (self)
    (wrap (%swift-nsarray-make-iterator (->ptr self)) #t)))

