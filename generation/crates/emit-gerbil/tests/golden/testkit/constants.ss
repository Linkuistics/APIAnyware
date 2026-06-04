;;; Generated constant definitions for TestKit — do not edit
(import
  :std/foreign
  :gerbil-bindings/runtime/objc
  )
(export
  TKVersionString
  TKDefaultTimeout
  TKStatusAttribute
  )

(begin-ffi (
            %const-TKVersionString
            %const-TKDefaultTimeout
            )
  (c-declare "extern void * const TKVersionString;")
  (c-declare "extern double TKDefaultTimeout;")

  (define-c-lambda %const-TKVersionString () (pointer void) "___return((void*)TKVersionString);")
  (define-c-lambda %const-TKDefaultTimeout () double "___return(TKDefaultTimeout);")
  )

(define TKVersionString (wrap (%const-TKVersionString)))
(define TKDefaultTimeout (%const-TKDefaultTimeout))
(define TKStatusAttribute (wrap (string->nsstring "TKStatus") #t))
