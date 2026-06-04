;;; Generated binding for TKView (TestKit) — do not edit
(import :std/foreign
        (rename-in :std/generic (defgeneric g:defgeneric) (defmethod g:defmethod))
        :gerbil-bindings/generics
        :gerbil-bindings/testkit/tkobject
        :gerbil-bindings/runtime/objc)
(export
  TKView
  TKView?
  animate-with-duration-animations
  frame
  hidden
  make-tkview-init-with-frame
  set-frame!
  set-hidden!
  set-needs-display!
  set-tag!
  set-title!
  tag
  title
  tkview-animate-with-duration-animations
  tkview-appearance
  tkview-frame
  tkview-hidden
  tkview-set-frame!
  tkview-set-hidden!
  tkview-set-needs-display!
  tkview-set-tag!
  tkview-set-title!
  tkview-tag
  tkview-title
  )

;; --- Class graph (ADR-0020) ---
(defclass (TKView TKObject) () transparent: #t)
(register-objc-class! (lambda (p) (make-TKView ptr: p)) TKView::t "TKView" "TKObject")

(begin-ffi (objc_getClass sel_registerName
            %msg-b->v
            %msg-cgrect->p
            %msg-cgrect->v
            %msg-d-p->v
            %msg-i64->v
            %msg-p->v
            %msg-v->b
            %msg-v->cgrect
            %msg-v->i64
            %msg-v->p
            %msg-v->v
            )
  (c-declare "#include <objc/runtime.h>")
  (c-declare "#include <objc/message.h>")
  (c-declare "#include <stdint.h>")
  (c-declare "#include <CoreGraphics/CGGeometry.h>")
  (c-define-type CGRect (struct "CGRect"))

  (define-c-lambda objc_getClass (char-string) (pointer void) "objc_getClass")
  (define-c-lambda sel_registerName (char-string) (pointer void) "sel_registerName")
  (define-c-lambda %msg-b->v ((pointer void) (pointer void) bool) void
    "((void (*)(id, SEL, BOOL))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3);")
  (define-c-lambda %msg-cgrect->p ((pointer void) (pointer void) CGRect) (pointer void)
    "___return( ((id (*)(id, SEL, CGRect))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3) );")
  (define-c-lambda %msg-cgrect->v ((pointer void) (pointer void) CGRect) void
    "((void (*)(id, SEL, CGRect))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3);")
  (define-c-lambda %msg-d-p->v ((pointer void) (pointer void) double (pointer void)) void
    "((void (*)(id, SEL, double, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4);")
  (define-c-lambda %msg-i64->v ((pointer void) (pointer void) int64) void
    "((void (*)(id, SEL, int64_t))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3);")
  (define-c-lambda %msg-p->v ((pointer void) (pointer void) (pointer void)) void
    "((void (*)(id, SEL, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3);")
  (define-c-lambda %msg-v->b ((pointer void) (pointer void)) bool
    "___return( ((BOOL (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  (define-c-lambda %msg-v->cgrect ((pointer void) (pointer void)) CGRect
    "___return( ((CGRect (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  (define-c-lambda %msg-v->i64 ((pointer void) (pointer void)) int64
    "___return( ((int64_t (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  (define-c-lambda %msg-v->p ((pointer void) (pointer void)) (pointer void)
    "___return( ((id (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  (define-c-lambda %msg-v->v ((pointer void) (pointer void)) void
    "((void (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2);")
  )

(define %sel-tkview-init-with-frame (sel_registerName "initWithFrame:"))
(define %sel-tkview-set-needs-display (sel_registerName "setNeedsDisplay"))
(define %sel-tkview-animate-with-duration-animations (sel_registerName "animateWithDuration:animations:"))
(define %sel-tkview-appearance (sel_registerName "appearance"))
(define %sel-tkview-title (sel_registerName "title"))
(define %sel-tkview-set-title (sel_registerName "setTitle:"))
(define %sel-tkview-hidden (sel_registerName "hidden"))
(define %sel-tkview-set-hidden (sel_registerName "setHidden:"))
(define %sel-tkview-tag (sel_registerName "tag"))
(define %sel-tkview-set-tag (sel_registerName "setTag:"))
(define %sel-tkview-frame (sel_registerName "frame"))
(define %sel-tkview-set-frame (sel_registerName "setFrame:"))

;; --- Dispatch surfaces (ADR-0020): inlinable proc core; generics are
;;     declared once in :gerbil-bindings/generics and extended below ---
(declare (inline))

;; --- Constructors ---
(define (make-tkview-init-with-frame frame)
  (wrap (%msg-cgrect->p (%msg-v->p (objc_getClass "TKView") (sel_registerName "alloc")) %sel-tkview-init-with-frame frame) #t))

;; --- Properties ---
(define (tkview-title self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-tkview-title)))
(defmethod {title TKView} (lambda (self) (tkview-title self)))
(g:defmethod (title (o TKView)) (tkview-title o))

(define (tkview-set-title! self value)
  (%msg-p->v (NSObject-ptr self) %sel-tkview-set-title (->ptr value)))
(defmethod {set-title! TKView} (lambda (self value) (tkview-set-title! self value)))
(g:defmethod (set-title! (o TKView) value) (tkview-set-title! o value))

(define (tkview-hidden self)
  (%msg-v->b (NSObject-ptr self) %sel-tkview-hidden))
(defmethod {hidden TKView} (lambda (self) (tkview-hidden self)))
(g:defmethod (hidden (o TKView)) (tkview-hidden o))

(define (tkview-set-hidden! self value)
  (%msg-b->v (NSObject-ptr self) %sel-tkview-set-hidden value))
(defmethod {set-hidden! TKView} (lambda (self value) (tkview-set-hidden! self value)))
(g:defmethod (set-hidden! (o TKView) value) (tkview-set-hidden! o value))

(define (tkview-tag self)
  (%msg-v->i64 (NSObject-ptr self) %sel-tkview-tag))
(defmethod {tag TKView} (lambda (self) (tkview-tag self)))
(g:defmethod (tag (o TKView)) (tkview-tag o))

(define (tkview-set-tag! self value)
  (%msg-i64->v (NSObject-ptr self) %sel-tkview-set-tag value))
(defmethod {set-tag! TKView} (lambda (self value) (tkview-set-tag! self value)))
(g:defmethod (set-tag! (o TKView) value) (tkview-set-tag! o value))

(define (tkview-frame self)
  (%msg-v->cgrect (NSObject-ptr self) %sel-tkview-frame))
(defmethod {frame TKView} (lambda (self) (tkview-frame self)))
(g:defmethod (frame (o TKView)) (tkview-frame o))

(define (tkview-set-frame! self value)
  (%msg-cgrect->v (NSObject-ptr self) %sel-tkview-set-frame value))
(defmethod {set-frame! TKView} (lambda (self value) (tkview-set-frame! self value)))
(g:defmethod (set-frame! (o TKView) value) (tkview-set-frame! o value))

;; --- Instance methods ---
(define (tkview-set-needs-display! self)
  (%msg-v->v (NSObject-ptr self) %sel-tkview-set-needs-display))
(defmethod {set-needs-display! TKView} (lambda (self) (tkview-set-needs-display! self)))
(g:defmethod (set-needs-display! (o TKView)) (tkview-set-needs-display! o))

(define (tkview-animate-with-duration-animations self duration animations)
  (%msg-d-p->v (NSObject-ptr self) %sel-tkview-animate-with-duration-animations duration animations))
(defmethod {animate-with-duration-animations TKView} (lambda (self duration animations) (tkview-animate-with-duration-animations self duration animations)))
(g:defmethod (animate-with-duration-animations (o TKView) duration animations) (tkview-animate-with-duration-animations o duration animations))

;; --- Class methods ---
(define (tkview-appearance)
  (wrap (%msg-v->p (objc_getClass "TKView") %sel-tkview-appearance)))

