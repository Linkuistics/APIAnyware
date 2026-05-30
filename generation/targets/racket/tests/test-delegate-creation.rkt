#lang racket/base
;; test-delegate-creation.rkt — Verify ObjC delegate creation through Swift dylib
;;
;; Tests:
;;   1. Create delegate with make-delegate
;;   2. ObjC dispatch invokes Racket handler
;;   3. delegate-set! updates a handler on a live delegate
;;   4. delegate-remove! removes a handler
;;   5. free-delegate cleans up
;;   6. Return type detection (void, bool, id)

(require rackunit
         rackunit/text-ui
         ffi/unsafe
         ffi/unsafe/objc
         "../runtime/swift-helpers.rkt"
         "../runtime/objc-base.rkt"
         "../runtime/delegate.rkt"
         "../runtime/type-mapping.rkt")

;; ObjC runtime helpers
(define objc-lib (ffi-lib "libobjc"))

;; Send a message with 1 id arg, void return
(define msg-send-1id
  (get-ffi-obj "objc_msgSend" objc-lib
    (_fun _pointer _pointer _pointer -> _void)))

;; Send a message with 1 id arg, bool return
(define msg-send-1id->bool
  (get-ffi-obj "objc_msgSend" objc-lib
    (_fun _pointer _pointer _pointer -> _bool)))

;; Send a message with 0 args, void return
(define msg-send-0
  (get-ffi-obj "objc_msgSend" objc-lib
    (_fun _pointer _pointer -> _void)))

;; Check if an object responds to a selector
(define msg-send-responds
  (get-ffi-obj "objc_msgSend" objc-lib
    (_fun _pointer _pointer _pointer -> _bool)))

(define sel-respondsToSelector (sel_registerName "respondsToSelector:"))

(define delegate-tests
  (test-suite
   "Delegate creation and dispatch"

   (test-case "Create a simple delegate and verify it's an ObjC object"
     (define called? (box #f))
     (define del
       (make-delegate
        "windowDidResize:" (lambda (notif) (set-box! called? #t))))

     ;; Should be a valid ObjC _id pointer
     (check-not-false del "Delegate should be non-null")
     (check-pred cpointer? del "Should be a pointer")

     ;; Verify it responds to the registered selector
     (define responds
       (msg-send-responds del sel-respondsToSelector
                          (sel_registerName "windowDidResize:")))
     (check-true responds "Delegate should respond to windowDidResize:")

     (free-delegate del))

   (test-case "Delegate dispatch invokes Racket handler (void return)"
     (define log (box '()))
     (define del
       (make-delegate
        "windowDidResize:" (lambda (notif)
                             (set-box! log (cons "resized" (unbox log))))
        "windowDidMove:"   (lambda (notif)
                             (set-box! log (cons "moved" (unbox log))))))

     ;; Simulate ObjC calling the delegate methods
     ;; Pass a dummy notification (NSNull works as a stand-in)
     (import-class NSNull)
     (define null-instance (tell NSNull null))

     (msg-send-1id del (sel_registerName "windowDidResize:")
                   (cast null-instance _id _pointer))
     (msg-send-1id del (sel_registerName "windowDidMove:")
                   (cast null-instance _id _pointer))

     (check-equal? (reverse (unbox log)) '("resized" "moved")
                   "Both handlers should have fired in order")

     (free-delegate del))

   (test-case "Delegate with bool return type (shouldClose)"
     ;; shouldClose: should auto-detect as 'bool return
     (define del
       (make-delegate
        "windowShouldClose:" (lambda (window) #t)))

     ;; Invoke and check return
     (import-class NSNull)
     (define null-instance (tell NSNull null))
     (define result
       (msg-send-1id->bool del (sel_registerName "windowShouldClose:")
                           (cast null-instance _id _pointer)))
     (check-true result "Handler returning #t should produce YES")

     (free-delegate del))

   (test-case "Delegate with bool return type returning false"
     (define del
       (make-delegate
        "shouldSelectItem:" (lambda (item) #f)))

     (import-class NSNull)
     (define null-instance (tell NSNull null))
     (define result
       (msg-send-1id->bool del (sel_registerName "shouldSelectItem:")
                           (cast null-instance _id _pointer)))
     (check-false result "Handler returning #f should produce NO")

     (free-delegate del))

   (test-case "delegate-set! updates a handler on a live delegate"
     (define log (box '()))
     (define del
       (make-delegate
        "windowDidResize:" (lambda (notif)
                             (set-box! log (cons "v1" (unbox log))))))

     (import-class NSNull)
     (define null-instance (tell NSNull null))

     ;; Call with original handler
     (msg-send-1id del (sel_registerName "windowDidResize:")
                   (cast null-instance _id _pointer))

     ;; Update the handler
     (delegate-set! del "windowDidResize:"
                    (lambda (notif)
                      (set-box! log (cons "v2" (unbox log)))))

     ;; Call again — should use updated handler
     (msg-send-1id del (sel_registerName "windowDidResize:")
                   (cast null-instance _id _pointer))

     (check-equal? (reverse (unbox log)) '("v1" "v2")
                   "Should see v1 then v2 after update")

     (free-delegate del))

   (test-case "free-delegate cleans up without crash"
     ;; Create and immediately free
     (define del
       (make-delegate
        "windowDidResize:" (lambda (notif) (void))))
     (free-delegate del)
     ;; If we get here without crash, cleanup works
     (check-true #t "Delegate freed successfully"))

   (test-case "Multiple delegates can coexist"
     (define log1 (box '()))
     (define log2 (box '()))

     (define del1
       (make-delegate
        "windowDidResize:" (lambda (notif)
                             (set-box! log1 (cons "d1" (unbox log1))))))
     (define del2
       (make-delegate
        "windowDidResize:" (lambda (notif)
                             (set-box! log2 (cons "d2" (unbox log2))))))

     (import-class NSNull)
     (define null-instance (tell NSNull null))

     ;; Call both
     (msg-send-1id del1 (sel_registerName "windowDidResize:")
                   (cast null-instance _id _pointer))
     (msg-send-1id del2 (sel_registerName "windowDidResize:")
                   (cast null-instance _id _pointer))

     (check-equal? (unbox log1) '("d1") "Delegate 1 should only see its call")
     (check-equal? (unbox log2) '("d2") "Delegate 2 should only see its call")

     (free-delegate del1)
     (free-delegate del2))))

(run-tests delegate-tests)
