#lang racket/base
;; Generated binding for NSDateFormatter (Foundation)
;; Do not edit — regenerate from enriched IR

(require "../../runtime/ffi2-dispatch.rkt"
         (except-in ffi/unsafe ->)
         ffi/unsafe/objc
         (rename-in racket/contract [-> c->])
         "../../runtime/objc-base.rkt"
         "../../runtime/coerce.rkt"
         "../../runtime/type-mapping.rkt")

;; Load framework and ObjC runtime
(define _fw-lib (ffi-lib "/System/Library/Frameworks/Foundation.framework/Foundation"))
(define _objc-lib (ffi-lib "libobjc"))


;; --- Class predicates ---
(define (nsarray? v) (objc-instance-of? v "NSArray"))
(define (nsattributedstring? v) (objc-instance-of? v "NSAttributedString"))
(define (nscalendar? v) (objc-instance-of? v "NSCalendar"))
(define (nsdate? v) (objc-instance-of? v "NSDate"))
(define (nsdateformatter? v) (objc-instance-of? v "NSDateFormatter"))
(define (nslocale? v) (objc-instance-of? v "NSLocale"))
(define (nsstring? v) (objc-instance-of? v "NSString"))
(define (nstimezone? v) (objc-instance-of? v "NSTimeZone"))
(provide NSDateFormatter)
(provide/contract
  [make-nsdateformatter-init-with-coder (c-> (or/c string? objc-object? #f) any/c)]
  [nsdateformatter-am-symbol (c-> nsdateformatter? (or/c nsstring? objc-nil?))]
  [nsdateformatter-set-am-symbol! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-pm-symbol (c-> nsdateformatter? (or/c nsstring? objc-nil?))]
  [nsdateformatter-set-pm-symbol! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-calendar (c-> nsdateformatter? (or/c nscalendar? objc-nil?))]
  [nsdateformatter-set-calendar! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-date-format (c-> nsdateformatter? (or/c nsstring? objc-nil?))]
  [nsdateformatter-set-date-format! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-date-style (c-> nsdateformatter? exact-nonnegative-integer?)]
  [nsdateformatter-set-date-style! (c-> nsdateformatter? exact-nonnegative-integer? void?)]
  [nsdateformatter-default-date (c-> nsdateformatter? (or/c nsdate? objc-nil?))]
  [nsdateformatter-set-default-date! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-default-formatter-behavior (c-> exact-nonnegative-integer?)]
  [nsdateformatter-set-default-formatter-behavior! (c-> exact-nonnegative-integer? void?)]
  [nsdateformatter-does-relative-date-formatting (c-> nsdateformatter? boolean?)]
  [nsdateformatter-set-does-relative-date-formatting! (c-> nsdateformatter? boolean? void?)]
  [nsdateformatter-era-symbols (c-> nsdateformatter? (or/c nsarray? objc-nil?))]
  [nsdateformatter-set-era-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-formatter-behavior (c-> nsdateformatter? exact-nonnegative-integer?)]
  [nsdateformatter-set-formatter-behavior! (c-> nsdateformatter? exact-nonnegative-integer? void?)]
  [nsdateformatter-formatting-context (c-> nsdateformatter? exact-integer?)]
  [nsdateformatter-set-formatting-context! (c-> nsdateformatter? exact-integer? void?)]
  [nsdateformatter-generates-calendar-dates (c-> nsdateformatter? boolean?)]
  [nsdateformatter-set-generates-calendar-dates! (c-> nsdateformatter? boolean? void?)]
  [nsdateformatter-gregorian-start-date (c-> nsdateformatter? (or/c nsdate? objc-nil?))]
  [nsdateformatter-set-gregorian-start-date! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-lenient (c-> nsdateformatter? boolean?)]
  [nsdateformatter-set-lenient! (c-> nsdateformatter? boolean? void?)]
  [nsdateformatter-locale (c-> nsdateformatter? (or/c nslocale? objc-nil?))]
  [nsdateformatter-set-locale! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-long-era-symbols (c-> nsdateformatter? (or/c nsarray? objc-nil?))]
  [nsdateformatter-set-long-era-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-month-symbols (c-> nsdateformatter? (or/c nsarray? objc-nil?))]
  [nsdateformatter-set-month-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-quarter-symbols (c-> nsdateformatter? (or/c nsarray? objc-nil?))]
  [nsdateformatter-set-quarter-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-short-month-symbols (c-> nsdateformatter? (or/c nsarray? objc-nil?))]
  [nsdateformatter-set-short-month-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-short-quarter-symbols (c-> nsdateformatter? (or/c nsarray? objc-nil?))]
  [nsdateformatter-set-short-quarter-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-short-standalone-month-symbols (c-> nsdateformatter? (or/c nsarray? objc-nil?))]
  [nsdateformatter-set-short-standalone-month-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-short-standalone-quarter-symbols (c-> nsdateformatter? (or/c nsarray? objc-nil?))]
  [nsdateformatter-set-short-standalone-quarter-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-short-standalone-weekday-symbols (c-> nsdateformatter? (or/c nsarray? objc-nil?))]
  [nsdateformatter-set-short-standalone-weekday-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-short-weekday-symbols (c-> nsdateformatter? (or/c nsarray? objc-nil?))]
  [nsdateformatter-set-short-weekday-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-standalone-month-symbols (c-> nsdateformatter? (or/c nsarray? objc-nil?))]
  [nsdateformatter-set-standalone-month-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-standalone-quarter-symbols (c-> nsdateformatter? (or/c nsarray? objc-nil?))]
  [nsdateformatter-set-standalone-quarter-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-standalone-weekday-symbols (c-> nsdateformatter? (or/c nsarray? objc-nil?))]
  [nsdateformatter-set-standalone-weekday-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-time-style (c-> nsdateformatter? exact-nonnegative-integer?)]
  [nsdateformatter-set-time-style! (c-> nsdateformatter? exact-nonnegative-integer? void?)]
  [nsdateformatter-time-zone (c-> nsdateformatter? (or/c nstimezone? objc-nil?))]
  [nsdateformatter-set-time-zone! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-two-digit-start-date (c-> nsdateformatter? (or/c nsdate? objc-nil?))]
  [nsdateformatter-set-two-digit-start-date! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-very-short-month-symbols (c-> nsdateformatter? (or/c nsarray? objc-nil?))]
  [nsdateformatter-set-very-short-month-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-very-short-standalone-month-symbols (c-> nsdateformatter? (or/c nsarray? objc-nil?))]
  [nsdateformatter-set-very-short-standalone-month-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-very-short-standalone-weekday-symbols (c-> nsdateformatter? (or/c nsarray? objc-nil?))]
  [nsdateformatter-set-very-short-standalone-weekday-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-very-short-weekday-symbols (c-> nsdateformatter? (or/c nsarray? objc-nil?))]
  [nsdateformatter-set-very-short-weekday-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-weekday-symbols (c-> nsdateformatter? (or/c nsarray? objc-nil?))]
  [nsdateformatter-set-weekday-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-attributed-string-for-object-value-with-default-attributes (c-> nsdateformatter? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c nsattributedstring? objc-nil?))]
  [nsdateformatter-copy-with-zone (c-> nsdateformatter? (or/c cpointer? #f) any/c)]
  [nsdateformatter-date-from-string (c-> nsdateformatter? (or/c string? objc-object? #f) (or/c nsdate? objc-nil?))]
  [nsdateformatter-editing-string-for-object-value (c-> nsdateformatter? (or/c string? objc-object? #f) (or/c nsstring? objc-nil?))]
  [nsdateformatter-encode-with-coder (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-get-object-value-for-string-error-description (c-> nsdateformatter? (or/c cpointer? #f) (or/c string? objc-object? #f) (values boolean? (or/c objc-object? #f)))]
  [nsdateformatter-get-object-value-for-string-range-error (c-> nsdateformatter? (or/c cpointer? #f) (or/c string? objc-object? #f) (or/c cpointer? #f) (values boolean? (or/c objc-object? #f)))]
  [nsdateformatter-is-lenient (c-> nsdateformatter? boolean?)]
  [nsdateformatter-is-partial-string-valid-new-editing-string-error-description (c-> nsdateformatter? (or/c string? objc-object? #f) (or/c cpointer? #f) (values boolean? (or/c objc-object? #f)))]
  [nsdateformatter-is-partial-string-valid-proposed-selected-range-original-string-original-selected-range-error-description (c-> nsdateformatter? (or/c cpointer? #f) (or/c cpointer? #f) (or/c string? objc-object? #f) any/c (values boolean? (or/c objc-object? #f)))]
  [nsdateformatter-set-localized-date-format-from-template! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-string-for-object-value (c-> nsdateformatter? (or/c string? objc-object? #f) (or/c nsstring? objc-nil?))]
  [nsdateformatter-string-from-date (c-> nsdateformatter? (or/c string? objc-object? #f) (or/c nsstring? objc-nil?))]
  [nsdateformatter-date-format-from-template-options-locale (c-> (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c string? objc-object? #f) (or/c nsstring? objc-nil?))]
  [nsdateformatter-localized-string-from-date-date-style-time-style (c-> (or/c string? objc-object? #f) exact-nonnegative-integer? exact-nonnegative-integer? (or/c nsstring? objc-nil?))]
  )

;; --- Class reference ---
(import-class NSDateFormatter)

;; --- Native dispatch bindings (generated objc_msgSend, ADR-0013) ---
(define-aw-msg aw_racket_msg_0_P (-> ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_0_b (-> ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_0_q (-> ptr_t ptr_t int64_t))
(define-aw-msg aw_racket_msg_0_Q (-> ptr_t ptr_t uint64_t))
(define-aw-msg aw_racket_msg_P_P (-> ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_P_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PP_b_e (-> ptr_t ptr_t ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_PPP_b_e (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_PPPG_b_e (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_PQP_P (-> ptr_t ptr_t ptr_t uint64_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PQQ_P (-> ptr_t ptr_t ptr_t uint64_t uint64_t ptr_t))
(define-aw-msg aw_racket_msg_b_v (-> ptr_t ptr_t bool_t void_t))
(define-aw-msg aw_racket_msg_q_v (-> ptr_t ptr_t int64_t void_t))
(define-aw-msg aw_racket_msg_Q_v (-> ptr_t ptr_t uint64_t void_t))

;; --- Constructors ---
(define (make-nsdateformatter-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSDateFormatter alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))


;; --- Properties ---
(define (nsdateformatter-am-symbol self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "AMSymbol"))))))
(define (nsdateformatter-set-am-symbol! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAMSymbol:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsdateformatter-pm-symbol self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "PMSymbol"))))))
(define (nsdateformatter-set-pm-symbol! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPMSymbol:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsdateformatter-calendar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "calendar"))))))
(define (nsdateformatter-set-calendar! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setCalendar:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsdateformatter-date-format self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "dateFormat"))))))
(define (nsdateformatter-set-date-format! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDateFormat:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsdateformatter-date-style self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "dateStyle"))))
(define (nsdateformatter-set-date-style! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDateStyle:")) value))
(define (nsdateformatter-default-date self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "defaultDate"))))))
(define (nsdateformatter-set-default-date! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDefaultDate:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsdateformatter-default-formatter-behavior)
  (aw_racket_msg_0_Q (id->ffi2-ptr NSDateFormatter) (id->ffi2-ptr (sel_registerName "defaultFormatterBehavior"))))
(define (nsdateformatter-set-default-formatter-behavior! value)
  (aw_racket_msg_Q_v (id->ffi2-ptr NSDateFormatter) (id->ffi2-ptr (sel_registerName "setDefaultFormatterBehavior:")) value))
(define (nsdateformatter-does-relative-date-formatting self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "doesRelativeDateFormatting"))))
(define (nsdateformatter-set-does-relative-date-formatting! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDoesRelativeDateFormatting:")) value))
(define (nsdateformatter-era-symbols self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "eraSymbols"))))))
(define (nsdateformatter-set-era-symbols! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setEraSymbols:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsdateformatter-formatter-behavior self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "formatterBehavior"))))
(define (nsdateformatter-set-formatter-behavior! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFormatterBehavior:")) value))
(define (nsdateformatter-formatting-context self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "formattingContext"))))
(define (nsdateformatter-set-formatting-context! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFormattingContext:")) value))
(define (nsdateformatter-generates-calendar-dates self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "generatesCalendarDates"))))
(define (nsdateformatter-set-generates-calendar-dates! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setGeneratesCalendarDates:")) value))
(define (nsdateformatter-gregorian-start-date self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "gregorianStartDate"))))))
(define (nsdateformatter-set-gregorian-start-date! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setGregorianStartDate:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsdateformatter-lenient self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lenient"))))
(define (nsdateformatter-set-lenient! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLenient:")) value))
(define (nsdateformatter-locale self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "locale"))))))
(define (nsdateformatter-set-locale! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLocale:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsdateformatter-long-era-symbols self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "longEraSymbols"))))))
(define (nsdateformatter-set-long-era-symbols! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLongEraSymbols:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsdateformatter-month-symbols self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "monthSymbols"))))))
(define (nsdateformatter-set-month-symbols! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMonthSymbols:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsdateformatter-quarter-symbols self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "quarterSymbols"))))))
(define (nsdateformatter-set-quarter-symbols! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setQuarterSymbols:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsdateformatter-short-month-symbols self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shortMonthSymbols"))))))
(define (nsdateformatter-set-short-month-symbols! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setShortMonthSymbols:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsdateformatter-short-quarter-symbols self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shortQuarterSymbols"))))))
(define (nsdateformatter-set-short-quarter-symbols! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setShortQuarterSymbols:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsdateformatter-short-standalone-month-symbols self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shortStandaloneMonthSymbols"))))))
(define (nsdateformatter-set-short-standalone-month-symbols! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setShortStandaloneMonthSymbols:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsdateformatter-short-standalone-quarter-symbols self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shortStandaloneQuarterSymbols"))))))
(define (nsdateformatter-set-short-standalone-quarter-symbols! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setShortStandaloneQuarterSymbols:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsdateformatter-short-standalone-weekday-symbols self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shortStandaloneWeekdaySymbols"))))))
(define (nsdateformatter-set-short-standalone-weekday-symbols! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setShortStandaloneWeekdaySymbols:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsdateformatter-short-weekday-symbols self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shortWeekdaySymbols"))))))
(define (nsdateformatter-set-short-weekday-symbols! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setShortWeekdaySymbols:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsdateformatter-standalone-month-symbols self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "standaloneMonthSymbols"))))))
(define (nsdateformatter-set-standalone-month-symbols! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setStandaloneMonthSymbols:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsdateformatter-standalone-quarter-symbols self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "standaloneQuarterSymbols"))))))
(define (nsdateformatter-set-standalone-quarter-symbols! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setStandaloneQuarterSymbols:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsdateformatter-standalone-weekday-symbols self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "standaloneWeekdaySymbols"))))))
(define (nsdateformatter-set-standalone-weekday-symbols! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setStandaloneWeekdaySymbols:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsdateformatter-time-style self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "timeStyle"))))
(define (nsdateformatter-set-time-style! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTimeStyle:")) value))
(define (nsdateformatter-time-zone self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "timeZone"))))))
(define (nsdateformatter-set-time-zone! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTimeZone:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsdateformatter-two-digit-start-date self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "twoDigitStartDate"))))))
(define (nsdateformatter-set-two-digit-start-date! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTwoDigitStartDate:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsdateformatter-very-short-month-symbols self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "veryShortMonthSymbols"))))))
(define (nsdateformatter-set-very-short-month-symbols! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setVeryShortMonthSymbols:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsdateformatter-very-short-standalone-month-symbols self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "veryShortStandaloneMonthSymbols"))))))
(define (nsdateformatter-set-very-short-standalone-month-symbols! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setVeryShortStandaloneMonthSymbols:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsdateformatter-very-short-standalone-weekday-symbols self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "veryShortStandaloneWeekdaySymbols"))))))
(define (nsdateformatter-set-very-short-standalone-weekday-symbols! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setVeryShortStandaloneWeekdaySymbols:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsdateformatter-very-short-weekday-symbols self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "veryShortWeekdaySymbols"))))))
(define (nsdateformatter-set-very-short-weekday-symbols! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setVeryShortWeekdaySymbols:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsdateformatter-weekday-symbols self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "weekdaySymbols"))))))
(define (nsdateformatter-set-weekday-symbols! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWeekdaySymbols:")) (id->ffi2-ptr (coerce-arg value))))

;; --- Instance methods ---
(define (nsdateformatter-attributed-string-for-object-value-with-default-attributes self obj attrs)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "attributedStringForObjectValue:withDefaultAttributes:")) (id->ffi2-ptr (coerce-arg obj)) (id->ffi2-ptr (coerce-arg attrs))))
   ))
(define (nsdateformatter-copy-with-zone self zone)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "copyWithZone:")) (id->ffi2-ptr zone)))
   #:retained #t))
(define (nsdateformatter-date-from-string self string)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "dateFromString:")) (id->ffi2-ptr (coerce-arg string))))
   ))
(define (nsdateformatter-editing-string-for-object-value self obj)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "editingStringForObjectValue:")) (id->ffi2-ptr (coerce-arg obj))))
   ))
(define (nsdateformatter-encode-with-coder self coder)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "encodeWithCoder:")) (id->ffi2-ptr (coerce-arg coder))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsdateformatter-get-object-value-for-string-error-description self obj string)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PP_b_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getObjectValue:forString:errorDescription:")) (id->ffi2-ptr obj) (id->ffi2-ptr (coerce-arg string)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsdateformatter-get-object-value-for-string-range-error self obj string rangep)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PPP_b_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getObjectValue:forString:range:error:")) (id->ffi2-ptr obj) (id->ffi2-ptr (coerce-arg string)) (id->ffi2-ptr rangep) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
(define (nsdateformatter-is-lenient self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isLenient"))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsdateformatter-is-partial-string-valid-new-editing-string-error-description self partial-string new-string)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PP_b_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isPartialStringValid:newEditingString:errorDescription:")) (id->ffi2-ptr (coerce-arg partial-string)) (id->ffi2-ptr new-string) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsdateformatter-is-partial-string-valid-proposed-selected-range-original-string-original-selected-range-error-description self partial-string-ptr proposed-sel-range-ptr orig-string orig-sel-range)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PPPG_b_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isPartialStringValid:proposedSelectedRange:originalString:originalSelectedRange:errorDescription:")) (id->ffi2-ptr partial-string-ptr) (id->ffi2-ptr proposed-sel-range-ptr) (id->ffi2-ptr (coerce-arg orig-string)) (id->ffi2-ptr orig-sel-range) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
(define (nsdateformatter-set-localized-date-format-from-template! self date-format-template)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLocalizedDateFormatFromTemplate:")) (id->ffi2-ptr (coerce-arg date-format-template))))
(define (nsdateformatter-string-for-object-value self obj)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringForObjectValue:")) (id->ffi2-ptr (coerce-arg obj))))
   ))
(define (nsdateformatter-string-from-date self date)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringFromDate:")) (id->ffi2-ptr (coerce-arg date))))
   ))

;; --- Class methods ---
(define (nsdateformatter-date-format-from-template-options-locale tmplate opts locale)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PQP_P (id->ffi2-ptr NSDateFormatter) (id->ffi2-ptr (sel_registerName "dateFormatFromTemplate:options:locale:")) (id->ffi2-ptr (coerce-arg tmplate)) opts (id->ffi2-ptr (coerce-arg locale))))
   ))
(define (nsdateformatter-localized-string-from-date-date-style-time-style date dstyle tstyle)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PQQ_P (id->ffi2-ptr NSDateFormatter) (id->ffi2-ptr (sel_registerName "localizedStringFromDate:dateStyle:timeStyle:")) (id->ffi2-ptr (coerce-arg date)) dstyle tstyle))
   ))
