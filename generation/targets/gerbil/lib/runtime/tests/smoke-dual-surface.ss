;;; runtime/tests/smoke-dual-surface.ss — leaf 050/010 dual-surface check.
;;;
;;; Mimics, byte-for-byte, the shape emit_class emits for an instance method
;;; (ADR-0020, spike 07-dual-surface): the renamed :std/generic import, an
;;; inlinable per-class proc core over the runtime NSObject root, and BOTH the
;;; built-in {} MOP surface and the :std/generic surface sharing one identifier.
;;; Proves the runtime supports the dual surface the emitter targets, over a
;;; REAL FFI crossing (-[NSString length]). Built as an -exe; -framework
;;; Foundation -lobjc.

(export main)
(import :std/foreign
        (rename-in :std/generic (defgeneric g:defgeneric) (defmethod g:defmethod))
        :gerbil-bindings/runtime/ffi
        :gerbil-bindings/runtime/objc)

;; Stand-in generated class-graph node + registration (as emit_class emits).
(defclass (NSString NSObject) () transparent: #t)
(register-objc-class! (lambda (p) (make-NSString ptr: p)) NSString::t "NSString" "NSObject")

;; Per-signature crossing + cached selector (as the begin-ffi block emits).
(begin-ffi (%msg-u64)
  (c-declare "#include <objc/message.h>")
  (define-c-lambda %msg-u64 ((pointer void) (pointer void)) unsigned-int64
    "unsigned long (*send)(id, SEL) = (unsigned long (*)(id, SEL))objc_msgSend;
     ___return(send((id)___arg1, (SEL)___arg2));"))
(def %sel-length (sel-register "length"))

;; The dual surface for `length` (renamed bare-sel to dodge the builtin `length`
;; — the real emitter keeps the selector name; here we use `str-length` so the
;; smoke does not fight Gerbil's list `length`).
(declare (inline))
(g:defgeneric str-length)
(def (nsstring-length self) (%msg-u64 (NSObject-ptr self) %sel-length))     ; proc core
(defmethod {str-length NSString} (lambda (self) (nsstring-length self)))    ; {} MOP
(g:defmethod (str-length (o NSString)) (nsstring-length o))                 ; :std/generic

(def failures 0)
(def (check tag ok?)
  (displayln (if ok? "  ok   " "  FAIL ") tag)
  (unless ok? (set! failures (1+ failures))))

(def (main . _)
  (with-autorelease-pool
   (let (s (wrap (string->nsstring "hello!") #t))     ; 6 chars
     (check "proc core"        (= (nsstring-length s) 6))
     (check "{} MOP surface"   (= {str-length s} 6))
     (check ":std/generic surface" (= (str-length s) 6))
     (check "all three agree"
            (= (nsstring-length s) {str-length s} (str-length s))))
   (displayln (if (zero? failures) "DUAL-OK" "DUAL-FAIL"))))
