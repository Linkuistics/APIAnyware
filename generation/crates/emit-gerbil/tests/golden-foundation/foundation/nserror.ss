;;; Generated binding for NSError (Foundation) — do not edit
(import :std/foreign
        (rename-in :std/generic (defgeneric g:defgeneric) (defmethod g:defmethod))
        :gerbil-bindings/generics
        :gerbil-bindings/runtime/objc)
(export
  NSError
  NSError?
  code
  domain
  encode-with-coder
  help-anchor
  localized-description
  localized-failure-reason
  localized-recovery-options
  localized-recovery-suggestion
  make-nserror-init-with-coder
  make-nserror-init-with-domain-code-user-info
  nserror-code
  nserror-domain
  nserror-encode-with-coder
  nserror-error-with-domain-code-user-info
  nserror-help-anchor
  nserror-localized-description
  nserror-localized-failure-reason
  nserror-localized-recovery-options
  nserror-localized-recovery-suggestion
  nserror-recovery-attempter
  nserror-set-user-info-value-provider-for-domain-provider!
  nserror-supports-secure-coding
  nserror-underlying-errors
  nserror-user-info
  recovery-attempter
  underlying-errors
  user-info
  )

;; --- Class graph (ADR-0020) ---
(defclass (NSError NSObject) () transparent: #t)
(register-objc-class! (lambda (p) (make-NSError ptr: p)) NSError::t "NSError" "NSObject")

(begin-ffi (objc_getClass sel_registerName
            %msg-p->p
            %msg-p->v
            %msg-p-i64-p->p
            %msg-p-p->v
            %msg-v->b
            %msg-v->i64
            %msg-v->p
            )
  (c-declare "#include <objc/runtime.h>")
  (c-declare "#include <objc/message.h>")
  (c-declare "#include <stdint.h>")

  (define-c-lambda objc_getClass (char-string) (pointer void) "objc_getClass")
  (define-c-lambda sel_registerName (char-string) (pointer void) "sel_registerName")
  (define-c-lambda %msg-p->p ((pointer void) (pointer void) (pointer void)) (pointer void)
    "___return( ((id (*)(id, SEL, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3) );")
  (define-c-lambda %msg-p->v ((pointer void) (pointer void) (pointer void)) void
    "((void (*)(id, SEL, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3);")
  (define-c-lambda %msg-p-i64-p->p ((pointer void) (pointer void) (pointer void) int64 (pointer void)) (pointer void)
    "___return( ((id (*)(id, SEL, id, int64_t, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4, ___arg5) );")
  (define-c-lambda %msg-p-p->v ((pointer void) (pointer void) (pointer void) (pointer void)) void
    "((void (*)(id, SEL, id, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4);")
  (define-c-lambda %msg-v->b ((pointer void) (pointer void)) bool
    "___return( ((BOOL (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  (define-c-lambda %msg-v->i64 ((pointer void) (pointer void)) int64
    "___return( ((int64_t (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  (define-c-lambda %msg-v->p ((pointer void) (pointer void)) (pointer void)
    "___return( ((id (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  )

(define %sel-nserror-init-with-domain-code-user-info (sel_registerName "initWithDomain:code:userInfo:"))
(define %sel-nserror-init-with-coder (sel_registerName "initWithCoder:"))
(define %sel-nserror-encode-with-coder (sel_registerName "encodeWithCoder:"))
(define %sel-nserror-error-with-domain-code-user-info (sel_registerName "errorWithDomain:code:userInfo:"))
(define %sel-nserror-set-user-info-value-provider-for-domain-provider (sel_registerName "setUserInfoValueProviderForDomain:provider:"))
(define %sel-nserror-supports-secure-coding (sel_registerName "supportsSecureCoding"))
(define %sel-nserror-domain (sel_registerName "domain"))
(define %sel-nserror-code (sel_registerName "code"))
(define %sel-nserror-user-info (sel_registerName "userInfo"))
(define %sel-nserror-localized-description (sel_registerName "localizedDescription"))
(define %sel-nserror-localized-failure-reason (sel_registerName "localizedFailureReason"))
(define %sel-nserror-localized-recovery-suggestion (sel_registerName "localizedRecoverySuggestion"))
(define %sel-nserror-localized-recovery-options (sel_registerName "localizedRecoveryOptions"))
(define %sel-nserror-recovery-attempter (sel_registerName "recoveryAttempter"))
(define %sel-nserror-help-anchor (sel_registerName "helpAnchor"))
(define %sel-nserror-underlying-errors (sel_registerName "underlyingErrors"))

;; --- Dispatch surfaces (ADR-0020): inlinable proc core; generics are
;;     declared once in :gerbil-bindings/generics and extended below ---
(declare (inline))

;; --- Constructors ---
(define (make-nserror-init-with-domain-code-user-info domain code dict)
  (wrap (%msg-p-i64-p->p (%msg-v->p (objc_getClass "NSError") (sel_registerName "alloc")) %sel-nserror-init-with-domain-code-user-info (->ptr domain) code (->ptr dict)) #t))

(define (make-nserror-init-with-coder coder)
  (wrap (%msg-p->p (%msg-v->p (objc_getClass "NSError") (sel_registerName "alloc")) %sel-nserror-init-with-coder (->ptr coder)) #t))

;; --- Properties ---
(define (nserror-domain self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nserror-domain)))
(defmethod {domain NSError} (lambda (self) (nserror-domain self)))
(g:defmethod (domain (o NSError)) (nserror-domain o))

(define (nserror-code self)
  (%msg-v->i64 (NSObject-ptr self) %sel-nserror-code))
(defmethod {code NSError} (lambda (self) (nserror-code self)))
(g:defmethod (code (o NSError)) (nserror-code o))

(define (nserror-user-info self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nserror-user-info)))
(defmethod {user-info NSError} (lambda (self) (nserror-user-info self)))
(g:defmethod (user-info (o NSError)) (nserror-user-info o))

(define (nserror-localized-description self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nserror-localized-description)))
(defmethod {localized-description NSError} (lambda (self) (nserror-localized-description self)))
(g:defmethod (localized-description (o NSError)) (nserror-localized-description o))

(define (nserror-localized-failure-reason self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nserror-localized-failure-reason)))
(defmethod {localized-failure-reason NSError} (lambda (self) (nserror-localized-failure-reason self)))
(g:defmethod (localized-failure-reason (o NSError)) (nserror-localized-failure-reason o))

(define (nserror-localized-recovery-suggestion self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nserror-localized-recovery-suggestion)))
(defmethod {localized-recovery-suggestion NSError} (lambda (self) (nserror-localized-recovery-suggestion self)))
(g:defmethod (localized-recovery-suggestion (o NSError)) (nserror-localized-recovery-suggestion o))

(define (nserror-localized-recovery-options self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nserror-localized-recovery-options)))
(defmethod {localized-recovery-options NSError} (lambda (self) (nserror-localized-recovery-options self)))
(g:defmethod (localized-recovery-options (o NSError)) (nserror-localized-recovery-options o))

(define (nserror-recovery-attempter self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nserror-recovery-attempter)))
(defmethod {recovery-attempter NSError} (lambda (self) (nserror-recovery-attempter self)))
(g:defmethod (recovery-attempter (o NSError)) (nserror-recovery-attempter o))

(define (nserror-help-anchor self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nserror-help-anchor)))
(defmethod {help-anchor NSError} (lambda (self) (nserror-help-anchor self)))
(g:defmethod (help-anchor (o NSError)) (nserror-help-anchor o))

(define (nserror-underlying-errors self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nserror-underlying-errors)))
(defmethod {underlying-errors NSError} (lambda (self) (nserror-underlying-errors self)))
(g:defmethod (underlying-errors (o NSError)) (nserror-underlying-errors o))

;; --- Instance methods ---
(define (nserror-encode-with-coder self coder)
  (%msg-p->v (NSObject-ptr self) %sel-nserror-encode-with-coder (->ptr coder)))
(defmethod {encode-with-coder NSError} (lambda (self coder) (nserror-encode-with-coder self coder)))

;; --- Class methods ---
(define (nserror-error-with-domain-code-user-info domain code dict)
  (wrap (%msg-p-i64-p->p (objc_getClass "NSError") %sel-nserror-error-with-domain-code-user-info (->ptr domain) code (->ptr dict))))

(define (nserror-set-user-info-value-provider-for-domain-provider! error-domain provider)
  (%msg-p-p->v (objc_getClass "NSError") %sel-nserror-set-user-info-value-provider-for-domain-provider (->ptr error-domain) provider))

(define (nserror-supports-secure-coding)
  (%msg-v->b (objc_getClass "NSError") %sel-nserror-supports-secure-coding))

