#lang racket/base
;; test-runtime-load.rkt — Verify all runtime modules load successfully
;;
;; Tests that:
;;   1. All 8 runtime modules can be required without errors
;;   2. swift-available? is #t (dylib loaded successfully)
;;   3. Key exports are present and non-#f

(require rackunit
         rackunit/text-ui
         "../runtime/swift-helpers.rkt"
         "../runtime/objc-base.rkt"
         "../runtime/coerce.rkt"
         "../runtime/block.rkt"
         "../runtime/delegate.rkt"
         "../runtime/type-mapping.rkt"
         "../runtime/variadic-helpers.rkt"
         "../runtime/main-thread.rkt")

(define runtime-load-tests
  (test-suite
   "Runtime module loading"

   (test-case "swift-helpers.rkt loads and dylib is available"
     (check-true swift-available?
                 "libAPIAnywareRacket.dylib should be loadable"))

   (test-case "Swift FFI functions are bound (not #f)"
     (check-not-false swift:autorelease-push "autorelease-push should be bound")
     (check-not-false swift:autorelease-pop "autorelease-pop should be bound")
     (check-not-false swift:retain "retain should be bound")
     (check-not-false swift:release "release should be bound")
     (check-not-false swift:get-class "get-class should be bound")
     (check-not-false swift:sel-register "sel-register should be bound")
     (check-not-false swift:string-to-nsstring "string-to-nsstring should be bound")
     (check-not-false swift:nsstring-to-string "nsstring-to-string should be bound")
     (check-not-false swift:nsstring-length "nsstring-length should be bound")
     (check-not-false swift:create-block "create-block should be bound")
     (check-not-false swift:release-block "release-block should be bound")
     (check-not-false swift:register-delegate "register-delegate should be bound")
     (check-not-false swift:set-method "set-method should be bound")
     (check-not-false swift:free-delegate "free-delegate should be bound")
     (check-not-false swift:prevent-gc "prevent-gc should be bound")
     (check-not-false swift:allow-gc "allow-gc should be bound")
     (check-not-false swift:gc-count "gc-count should be bound"))

   (test-case "objc-base.rkt exports are functional"
     (check-true (procedure? wrap-objc-object))
     (check-true (procedure? unwrap-objc-object))
     (check-true (procedure? objc-retain))
     (check-true (procedure? objc-release))
     (check-true (objc-null? objc-null) "objc-null should be null"))

   (test-case "coerce.rkt loads (re-exports objc-base + type-mapping)"
     ;; coerce.rkt re-exports from objc-base and type-mapping
     ;; If require succeeded, the module loaded correctly
     (check-true #t "coerce.rkt loaded successfully"))

   (test-case "block.rkt exports are functional"
     (check-true (procedure? make-objc-block))
     (check-true (procedure? free-objc-block))
     (check-true (procedure? call-with-objc-block)))

   (test-case "delegate.rkt exports are functional"
     (check-true (procedure? make-delegate))
     (check-true (procedure? delegate-set!))
     (check-true (procedure? delegate-remove!))
     (check-true (procedure? free-delegate)))

   (test-case "type-mapping.rkt exports are functional"
     (check-true (procedure? string->nsstring))
     (check-true (procedure? nsstring->string))
     (check-true (procedure? list->nsarray))
     (check-true (procedure? nsarray->list))
     (check-true (procedure? make-nspoint))
     (check-true (procedure? make-nssize))
     (check-true (procedure? make-nsrect)))

   (test-case "main-thread.rkt exports are functional"
     (check-true (procedure? on-main-thread?))
     (check-true (procedure? call-on-main-thread))
     (check-true (procedure? call-on-main-thread-after)))))

(run-tests runtime-load-tests)
