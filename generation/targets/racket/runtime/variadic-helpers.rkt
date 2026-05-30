#lang racket/base
;; variadic-helpers.rkt — Alternatives for ObjC variadic methods
;;
;; ObjC variadic methods (e.g., arrayWithObjects:, stringWithFormat:)
;; cannot be auto-generated because C variadic calling conventions
;; require compile-time knowledge of argument count and types.
;;
;; 67 Foundation + 6 AppKit variadic methods are intentionally skipped
;; by the emitter. This module provides Racket-idiomatic alternatives
;; for the most commonly needed patterns.
;;
;; Skipped patterns and their alternatives:
;;
;;   NSArray.arrayWithObjects: / initWithObjects:
;;     → (list->nsarray (list obj1 obj2 obj3))
;;
;;   NSDictionary.dictionaryWithObjectsAndKeys:
;;     → (hash->nsdictionary (hash "key1" val1 "key2" val2))
;;
;;   NSString.stringWithFormat:
;;     → (string->nsstring (format "~a items found" count))
;;     Racket's format is more expressive than NSString format strings.
;;
;;   NSPredicate.predicateWithFormat:
;;     → (tell NSPredicate predicateWithFormat: (string->nsstring fmt-str))
;;     For no-arg predicates. For predicates with arguments, build
;;     with NSComparisonPredicate / NSCompoundPredicate directly.
;;
;;   NSOrderedSet.orderedSetWithObjects:
;;     → Create via initWithArray: + list->nsarray
;;
;;   NSSet.setWithObjects:
;;     → Create via initWithArray: + list->nsarray

(require "type-mapping.rkt"
         "objc-base.rkt")

(provide nsstring-from-format
         nsarray-from-items
         nsdictionary-from-pairs)

;; Create an NSString using Racket's format.
;; Usage: (nsstring-from-format "~a items in ~a" count name)
;; Equivalent to: [NSString stringWithFormat:@"%d items in %@", count, name]
(define (nsstring-from-format fmt . args)
  (string->nsstring (apply format fmt args)))

;; Create an NSArray from individual items (raw ObjC pointers).
;; Usage: (nsarray-from-items obj1 obj2 obj3)
;; Equivalent to: [NSArray arrayWithObjects:obj1, obj2, obj3, nil]
(define (nsarray-from-items . items)
  (list->nsarray items))

;; Create an NSDictionary from alternating key-value pairs.
;; Keys are Racket strings, values are ObjC pointers.
;; Usage: (nsdictionary-from-pairs "name" name-str "age" age-num)
;; Equivalent to: [NSDictionary dictionaryWithObjectsAndKeys:name, @"name", age, @"age", nil]
(define (nsdictionary-from-pairs . args)
  (unless (even? (length args))
    (error 'nsdictionary-from-pairs "expected even number of args (key value pairs)"))
  (define ht (make-hash))
  (let loop ([rest args])
    (unless (null? rest)
      (hash-set! ht (car rest) (cadr rest))
      (loop (cddr rest))))
  (hash->nsdictionary ht))
