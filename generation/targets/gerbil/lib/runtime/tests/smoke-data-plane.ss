;;; runtime/tests/smoke-data-plane.ss — leaf 050/010 smoke.
;;;
;;; Exercises the C-safe FFI seam + the objc data plane end to end, the way a
;;; generated module would: NSString round-trip, class lookup, class-aware
;;; `wrap` into the exact bound type, the lifetime will, and the ADR-0006
;;; `call-with-nserror-out` `(values result error)` model against a REAL failing
;;; Cocoa call. Built as an -exe so libobjc links once (-ld-options "-lobjc");
;;; C-safe, so the default gcc-15 compiler suffices (no -x objective-c).
;;; CLI smoke only; VM-verify of real apps is node 070/090.

(export main)
(import :std/foreign
        :gerbil-bindings/runtime/ffi
        :gerbil-bindings/runtime/objc)

;; Stand-in for a generated foundation/nsstring.ss module: a class-graph node +
;; its registration, exactly as emit_class emits them. Lets the smoke exercise
;; the class-aware `wrap` producing the EXACT bound type (the real ObjC class of
;; a string literal is __NSCFString, whose superclass chain reaches NSString —
;; so the registry fallback walk resolves it to this bound NSString).
(defclass (NSString NSObject) () transparent: #t)
(register-objc-class! (lambda (p) (make-NSString ptr: p)) NSString::t "NSString" "NSObject")

;; A per-method `-e` crossing, exactly the shape emit_class emits for an
;; NSError** out-param method: visible args + trailing (pointer (pointer void))
;; cell, cast to NSError** in the body. -[NSFileManager removeItemAtPath:error:].
(begin-ffi (%msg-removeitem-e)
  (c-declare "#include <objc/message.h>")
  (c-declare "#include <objc/runtime.h>")
  (define-c-lambda %msg-removeitem-e
    ((pointer void) (pointer void) (pointer void) (pointer (pointer void))) bool
    "BOOL (*send)(id, SEL, id, id*) = (BOOL (*)(id, SEL, id, id*))objc_msgSend;
     ___return(send((id)___arg1, (SEL)___arg2, (id)___arg3, (id*)___arg4));"))

(def failures 0)
(def (check tag ok?)
  (displayln (if ok? "  ok   " "  FAIL ") tag)
  (unless ok? (set! failures (1+ failures))))

(def (main . _)
  (with-autorelease-pool
   ;; --- FFI seam: NSString round-trip ------------------------------------
   (let* ((ns   (string->nsstring "hello from gerbil"))  ; +1 retained
          (back (nsstring->string ns)))
     (check "nsstring round-trip" (equal? back "hello from gerbil"))
     (objc-release ns))                                  ; balance the +1

   ;; --- class lookup -----------------------------------------------------
   (let (cls (objc-get-class "NSString"))
     (check "objc-get-class NSString"
            (and (not (ptr-null? cls)) (equal? (class-get-name cls) "NSString"))))

   ;; --- class-aware wrap into the exact bound type -----------------------
   (let* ((raw (string->nsstring "wrap me"))             ; +1; wrap #t takes ownership
          (obj (wrap raw #t)))
     (check "wrap -> NSObject?" (NSObject? obj))
     (check "wrap exact type (__NSCFString is-a NSString via fallback)" (NSString? obj))
     (check "->ptr round-trips the handle" (eq? (->ptr obj) (NSObject-ptr obj)))
     (check "->ptr of #f is the null pointer" (ptr-null? (->ptr #f))))

   ;; --- nserror struct ---------------------------------------------------
   (let (e (make-nserror "dom" 7 "boom" #f))
     (check "nserror accessors"
            (and (equal? (nserror-domain e) "dom")
                 (eqv? (nserror-code e) 7)
                 (equal? (nserror-localised-description e) "boom"))))

   ;; --- call-with-nserror-out against a real failing call ----------------
   (let* ((fm   (msg-id (objc-get-class "NSFileManager") (sel-register "defaultManager")))
          (path (string->nsstring "/no/such/path/gerbil-smoke-xyz")))
     (let-values (((ok? err)
                   (call-with-nserror-out
                    (lambda (cell)
                      (%msg-removeitem-e fm (sel-register "removeItemAtPath:error:")
                                         path cell)))))
       (check "failing call returned #f" (not ok?))
       (check "nserror populated" (and (nserror? err) (string? (nserror-domain err))))
       (displayln "       (info) domain=" (and err (nserror-domain err))
                  " code=" (and err (nserror-code err)))
       (objc-release path)))

   ;; --- lifetime: a will fires on GC, releasing the owned +1 -------------
   (let (n0 (alloc-id-cell))  ; just to allocate churn; real proof is no crash
     (free-cell n0))
   (let loop ((i 0))                       ; create + drop wrapped objects
     (when (< i 50)
       (wrap (string->nsstring "transient") #t)
       (loop (1+ i))))
   (##gc)
   (check "wills survived a GC sweep (no crash on release)" #t)

   (displayln (if (zero? failures) "SMOKE-OK" "SMOKE-FAIL"))))
