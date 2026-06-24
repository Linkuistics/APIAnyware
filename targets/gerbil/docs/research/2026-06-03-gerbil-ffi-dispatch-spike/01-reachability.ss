;;; Spike item 1: FFI reachability.
;;; Can Gerbil's :std/foreign reach libobjc (objc_getClass / sel_registerName /
;;; objc_msgSend) and round-trip an NSString? Compiled with `gxc -exe`.

(import :std/foreign)
(export main)

(begin-ffi (objc-hello)

  (c-declare "#include <objc/runtime.h>")
  (c-declare "#include <objc/message.h>")

  ;; objc_getClass(name) -> Class    (Class/id/SEL all carried as void*)
  (define-c-lambda objc_getClass (char-string) (pointer void)
    "objc_getClass")

  ;; sel_registerName(name) -> SEL
  (define-c-lambda sel_registerName (char-string) (pointer void)
    "sel_registerName")

  ;; id objc_msgSend(id, SEL, const char*)  -- +[NSString stringWithUTF8String:]
  ;; objc_msgSend is untyped/variadic; cast to the concrete signature inline.
  (define-c-lambda msgSend-str ((pointer void) (pointer void) char-string) (pointer void)
    "___return( ((id (*)(id, SEL, const char *))objc_msgSend)
                  (___arg1, (SEL)___arg2, ___arg3) );")

  ;; const char* objc_msgSend(id, SEL)  -- -[NSString UTF8String]
  (define-c-lambda msgSend-utf8 ((pointer void) (pointer void)) char-string
    "___return( (char *) ((const char * (*)(id, SEL))objc_msgSend)
                           (___arg1, (SEL)___arg2) );")

  (define (objc-hello text)
    (let* ((nsstring (objc_getClass "NSString"))
           (sel-with (sel_registerName "stringWithUTF8String:"))
           (sel-utf8 (sel_registerName "UTF8String"))
           (obj      (msgSend-str nsstring sel-with text)))
      (msgSend-utf8 obj sel-utf8))))

(def (main . _)
  (let ((round-trip (objc-hello "hello from gerbil via objc_msgSend")))
    (displayln "round-trip: " round-trip)
    (if (equal? round-trip "hello from gerbil via objc_msgSend")
      (displayln "RESULT: PASS — :std/foreign reaches objc_msgSend and round-trips NSString")
      (displayln "RESULT: FAIL — mismatch"))))
