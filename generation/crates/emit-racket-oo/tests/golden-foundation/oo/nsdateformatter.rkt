#lang racket/base
;; Generated binding for NSDateFormatter (Foundation)
;; Do not edit — regenerate from enriched IR

(require ffi/unsafe
         ffi/unsafe/objc
         (rename-in racket/contract [-> c->])
         "../../../runtime/objc-base.rkt"
         "../../../runtime/coerce.rkt"
         "../../../runtime/type-mapping.rkt")

;; Load framework and ObjC runtime
(define _fw-lib (ffi-lib "/System/Library/Frameworks/Foundation.framework/Foundation"))
(define _objc-lib (ffi-lib "libobjc"))


;; --- Class predicates ---
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
  [nsdateformatter-era-symbols (c-> nsdateformatter? any/c)]
  [nsdateformatter-set-era-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-formatter-behavior (c-> nsdateformatter? exact-nonnegative-integer?)]
  [nsdateformatter-set-formatter-behavior! (c-> nsdateformatter? exact-nonnegative-integer? void?)]
  [nsdateformatter-formatting-context (c-> nsdateformatter? exact-nonnegative-integer?)]
  [nsdateformatter-set-formatting-context! (c-> nsdateformatter? exact-nonnegative-integer? void?)]
  [nsdateformatter-generates-calendar-dates (c-> nsdateformatter? boolean?)]
  [nsdateformatter-set-generates-calendar-dates! (c-> nsdateformatter? boolean? void?)]
  [nsdateformatter-gregorian-start-date (c-> nsdateformatter? (or/c nsdate? objc-nil?))]
  [nsdateformatter-set-gregorian-start-date! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-lenient (c-> nsdateformatter? boolean?)]
  [nsdateformatter-set-lenient! (c-> nsdateformatter? boolean? void?)]
  [nsdateformatter-locale (c-> nsdateformatter? (or/c nslocale? objc-nil?))]
  [nsdateformatter-set-locale! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-long-era-symbols (c-> nsdateformatter? any/c)]
  [nsdateformatter-set-long-era-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-month-symbols (c-> nsdateformatter? any/c)]
  [nsdateformatter-set-month-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-quarter-symbols (c-> nsdateformatter? any/c)]
  [nsdateformatter-set-quarter-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-short-month-symbols (c-> nsdateformatter? any/c)]
  [nsdateformatter-set-short-month-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-short-quarter-symbols (c-> nsdateformatter? any/c)]
  [nsdateformatter-set-short-quarter-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-short-standalone-month-symbols (c-> nsdateformatter? any/c)]
  [nsdateformatter-set-short-standalone-month-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-short-standalone-quarter-symbols (c-> nsdateformatter? any/c)]
  [nsdateformatter-set-short-standalone-quarter-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-short-standalone-weekday-symbols (c-> nsdateformatter? any/c)]
  [nsdateformatter-set-short-standalone-weekday-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-short-weekday-symbols (c-> nsdateformatter? any/c)]
  [nsdateformatter-set-short-weekday-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-standalone-month-symbols (c-> nsdateformatter? any/c)]
  [nsdateformatter-set-standalone-month-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-standalone-quarter-symbols (c-> nsdateformatter? any/c)]
  [nsdateformatter-set-standalone-quarter-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-standalone-weekday-symbols (c-> nsdateformatter? any/c)]
  [nsdateformatter-set-standalone-weekday-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-time-style (c-> nsdateformatter? exact-nonnegative-integer?)]
  [nsdateformatter-set-time-style! (c-> nsdateformatter? exact-nonnegative-integer? void?)]
  [nsdateformatter-time-zone (c-> nsdateformatter? (or/c nstimezone? objc-nil?))]
  [nsdateformatter-set-time-zone! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-two-digit-start-date (c-> nsdateformatter? (or/c nsdate? objc-nil?))]
  [nsdateformatter-set-two-digit-start-date! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-very-short-month-symbols (c-> nsdateformatter? any/c)]
  [nsdateformatter-set-very-short-month-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-very-short-standalone-month-symbols (c-> nsdateformatter? any/c)]
  [nsdateformatter-set-very-short-standalone-month-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-very-short-standalone-weekday-symbols (c-> nsdateformatter? any/c)]
  [nsdateformatter-set-very-short-standalone-weekday-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-very-short-weekday-symbols (c-> nsdateformatter? any/c)]
  [nsdateformatter-set-very-short-weekday-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-weekday-symbols (c-> nsdateformatter? any/c)]
  [nsdateformatter-set-weekday-symbols! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-attributed-string-for-object-value-with-default-attributes (c-> nsdateformatter? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c nsattributedstring? objc-nil?))]
  [nsdateformatter-copy-with-zone (c-> nsdateformatter? (or/c cpointer? #f) any/c)]
  [nsdateformatter-date-from-string (c-> nsdateformatter? (or/c string? objc-object? #f) (or/c nsdate? objc-nil?))]
  [nsdateformatter-editing-string-for-object-value (c-> nsdateformatter? (or/c string? objc-object? #f) (or/c nsstring? objc-nil?))]
  [nsdateformatter-encode-with-coder (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-get-object-value-for-string-error-description (c-> nsdateformatter? (or/c cpointer? #f) (or/c string? objc-object? #f) (or/c cpointer? #f) boolean?)]
  [nsdateformatter-get-object-value-for-string-range-error (c-> nsdateformatter? (or/c cpointer? #f) (or/c string? objc-object? #f) (or/c cpointer? #f) (or/c cpointer? #f) boolean?)]
  [nsdateformatter-is-lenient (c-> nsdateformatter? boolean?)]
  [nsdateformatter-is-partial-string-valid-new-editing-string-error-description (c-> nsdateformatter? (or/c string? objc-object? #f) (or/c cpointer? #f) (or/c cpointer? #f) boolean?)]
  [nsdateformatter-is-partial-string-valid-proposed-selected-range-original-string-original-selected-range-error-description (c-> nsdateformatter? (or/c cpointer? #f) (or/c cpointer? #f) (or/c string? objc-object? #f) any/c (or/c cpointer? #f) boolean?)]
  [nsdateformatter-set-localized-date-format-from-template! (c-> nsdateformatter? (or/c string? objc-object? #f) void?)]
  [nsdateformatter-string-for-object-value (c-> nsdateformatter? (or/c string? objc-object? #f) (or/c nsstring? objc-nil?))]
  [nsdateformatter-string-from-date (c-> nsdateformatter? (or/c string? objc-object? #f) (or/c nsstring? objc-nil?))]
  [nsdateformatter-date-format-from-template-options-locale (c-> (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c string? objc-object? #f) (or/c nsstring? objc-nil?))]
  [nsdateformatter-localized-string-from-date-date-style-time-style (c-> (or/c string? objc-object? #f) exact-nonnegative-integer? exact-nonnegative-integer? (or/c nsstring? objc-nil?))]
  )

;; --- Class reference ---
(import-class NSDateFormatter)

;; --- Shared typed objc_msgSend bindings ---
(define _msg-0  ; (_fun _pointer _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _bool)))
(define _msg-1  ; (_fun _pointer _pointer -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _int64)))
(define _msg-2  ; (_fun _pointer _pointer -> _uint64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _uint64)))
(define _msg-3  ; (_fun _pointer _pointer _bool -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _bool -> _void)))
(define _msg-4  ; (_fun _pointer _pointer _id _pointer _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _pointer _pointer -> _bool)))
(define _msg-5  ; (_fun _pointer _pointer _id _uint64 _id -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _uint64 _id -> _id)))
(define _msg-6  ; (_fun _pointer _pointer _id _uint64 _uint64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _uint64 _uint64 -> _id)))
(define _msg-7  ; (_fun _pointer _pointer _int64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _void)))
(define _msg-8  ; (_fun _pointer _pointer _pointer -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer -> _id)))
(define _msg-9  ; (_fun _pointer _pointer _pointer _id _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _id _pointer -> _bool)))
(define _msg-10  ; (_fun _pointer _pointer _pointer _id _pointer _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _id _pointer _pointer -> _bool)))
(define _msg-11  ; (_fun _pointer _pointer _pointer _pointer _id _NSRange _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _pointer _id _NSRange _pointer -> _bool)))
(define _msg-12  ; (_fun _pointer _pointer _uint64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _uint64 -> _void)))

;; --- Constructors ---
(define (make-nsdateformatter-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSDateFormatter alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))


;; --- Properties ---
(define (nsdateformatter-am-symbol self)
  (wrap-objc-object
   (tell (coerce-arg self) AMSymbol)))
(define (nsdateformatter-set-am-symbol! self value)
  (tell #:type _void (coerce-arg self) setAMSymbol: (coerce-arg value)))
(define (nsdateformatter-pm-symbol self)
  (wrap-objc-object
   (tell (coerce-arg self) PMSymbol)))
(define (nsdateformatter-set-pm-symbol! self value)
  (tell #:type _void (coerce-arg self) setPMSymbol: (coerce-arg value)))
(define (nsdateformatter-calendar self)
  (wrap-objc-object
   (tell (coerce-arg self) calendar)))
(define (nsdateformatter-set-calendar! self value)
  (tell #:type _void (coerce-arg self) setCalendar: (coerce-arg value)))
(define (nsdateformatter-date-format self)
  (wrap-objc-object
   (tell (coerce-arg self) dateFormat)))
(define (nsdateformatter-set-date-format! self value)
  (tell #:type _void (coerce-arg self) setDateFormat: (coerce-arg value)))
(define (nsdateformatter-date-style self)
  (tell #:type _uint64 (coerce-arg self) dateStyle))
(define (nsdateformatter-set-date-style! self value)
  (_msg-12 (coerce-arg self) (sel_registerName "setDateStyle:") value))
(define (nsdateformatter-default-date self)
  (wrap-objc-object
   (tell (coerce-arg self) defaultDate)))
(define (nsdateformatter-set-default-date! self value)
  (tell #:type _void (coerce-arg self) setDefaultDate: (coerce-arg value)))
(define (nsdateformatter-default-formatter-behavior)
  (tell #:type _uint64 NSDateFormatter defaultFormatterBehavior))
(define (nsdateformatter-set-default-formatter-behavior! value)
  (_msg-12 NSDateFormatter (sel_registerName "setDefaultFormatterBehavior:") value))
(define (nsdateformatter-does-relative-date-formatting self)
  (tell #:type _bool (coerce-arg self) doesRelativeDateFormatting))
(define (nsdateformatter-set-does-relative-date-formatting! self value)
  (_msg-3 (coerce-arg self) (sel_registerName "setDoesRelativeDateFormatting:") value))
(define (nsdateformatter-era-symbols self)
  (wrap-objc-object
   (tell (coerce-arg self) eraSymbols)))
(define (nsdateformatter-set-era-symbols! self value)
  (tell #:type _void (coerce-arg self) setEraSymbols: (coerce-arg value)))
(define (nsdateformatter-formatter-behavior self)
  (tell #:type _uint64 (coerce-arg self) formatterBehavior))
(define (nsdateformatter-set-formatter-behavior! self value)
  (_msg-12 (coerce-arg self) (sel_registerName "setFormatterBehavior:") value))
(define (nsdateformatter-formatting-context self)
  (tell #:type _int64 (coerce-arg self) formattingContext))
(define (nsdateformatter-set-formatting-context! self value)
  (_msg-7 (coerce-arg self) (sel_registerName "setFormattingContext:") value))
(define (nsdateformatter-generates-calendar-dates self)
  (tell #:type _bool (coerce-arg self) generatesCalendarDates))
(define (nsdateformatter-set-generates-calendar-dates! self value)
  (_msg-3 (coerce-arg self) (sel_registerName "setGeneratesCalendarDates:") value))
(define (nsdateformatter-gregorian-start-date self)
  (wrap-objc-object
   (tell (coerce-arg self) gregorianStartDate)))
(define (nsdateformatter-set-gregorian-start-date! self value)
  (tell #:type _void (coerce-arg self) setGregorianStartDate: (coerce-arg value)))
(define (nsdateformatter-lenient self)
  (tell #:type _bool (coerce-arg self) lenient))
(define (nsdateformatter-set-lenient! self value)
  (_msg-3 (coerce-arg self) (sel_registerName "setLenient:") value))
(define (nsdateformatter-locale self)
  (wrap-objc-object
   (tell (coerce-arg self) locale)))
(define (nsdateformatter-set-locale! self value)
  (tell #:type _void (coerce-arg self) setLocale: (coerce-arg value)))
(define (nsdateformatter-long-era-symbols self)
  (wrap-objc-object
   (tell (coerce-arg self) longEraSymbols)))
(define (nsdateformatter-set-long-era-symbols! self value)
  (tell #:type _void (coerce-arg self) setLongEraSymbols: (coerce-arg value)))
(define (nsdateformatter-month-symbols self)
  (wrap-objc-object
   (tell (coerce-arg self) monthSymbols)))
(define (nsdateformatter-set-month-symbols! self value)
  (tell #:type _void (coerce-arg self) setMonthSymbols: (coerce-arg value)))
(define (nsdateformatter-quarter-symbols self)
  (wrap-objc-object
   (tell (coerce-arg self) quarterSymbols)))
(define (nsdateformatter-set-quarter-symbols! self value)
  (tell #:type _void (coerce-arg self) setQuarterSymbols: (coerce-arg value)))
(define (nsdateformatter-short-month-symbols self)
  (wrap-objc-object
   (tell (coerce-arg self) shortMonthSymbols)))
(define (nsdateformatter-set-short-month-symbols! self value)
  (tell #:type _void (coerce-arg self) setShortMonthSymbols: (coerce-arg value)))
(define (nsdateformatter-short-quarter-symbols self)
  (wrap-objc-object
   (tell (coerce-arg self) shortQuarterSymbols)))
(define (nsdateformatter-set-short-quarter-symbols! self value)
  (tell #:type _void (coerce-arg self) setShortQuarterSymbols: (coerce-arg value)))
(define (nsdateformatter-short-standalone-month-symbols self)
  (wrap-objc-object
   (tell (coerce-arg self) shortStandaloneMonthSymbols)))
(define (nsdateformatter-set-short-standalone-month-symbols! self value)
  (tell #:type _void (coerce-arg self) setShortStandaloneMonthSymbols: (coerce-arg value)))
(define (nsdateformatter-short-standalone-quarter-symbols self)
  (wrap-objc-object
   (tell (coerce-arg self) shortStandaloneQuarterSymbols)))
(define (nsdateformatter-set-short-standalone-quarter-symbols! self value)
  (tell #:type _void (coerce-arg self) setShortStandaloneQuarterSymbols: (coerce-arg value)))
(define (nsdateformatter-short-standalone-weekday-symbols self)
  (wrap-objc-object
   (tell (coerce-arg self) shortStandaloneWeekdaySymbols)))
(define (nsdateformatter-set-short-standalone-weekday-symbols! self value)
  (tell #:type _void (coerce-arg self) setShortStandaloneWeekdaySymbols: (coerce-arg value)))
(define (nsdateformatter-short-weekday-symbols self)
  (wrap-objc-object
   (tell (coerce-arg self) shortWeekdaySymbols)))
(define (nsdateformatter-set-short-weekday-symbols! self value)
  (tell #:type _void (coerce-arg self) setShortWeekdaySymbols: (coerce-arg value)))
(define (nsdateformatter-standalone-month-symbols self)
  (wrap-objc-object
   (tell (coerce-arg self) standaloneMonthSymbols)))
(define (nsdateformatter-set-standalone-month-symbols! self value)
  (tell #:type _void (coerce-arg self) setStandaloneMonthSymbols: (coerce-arg value)))
(define (nsdateformatter-standalone-quarter-symbols self)
  (wrap-objc-object
   (tell (coerce-arg self) standaloneQuarterSymbols)))
(define (nsdateformatter-set-standalone-quarter-symbols! self value)
  (tell #:type _void (coerce-arg self) setStandaloneQuarterSymbols: (coerce-arg value)))
(define (nsdateformatter-standalone-weekday-symbols self)
  (wrap-objc-object
   (tell (coerce-arg self) standaloneWeekdaySymbols)))
(define (nsdateformatter-set-standalone-weekday-symbols! self value)
  (tell #:type _void (coerce-arg self) setStandaloneWeekdaySymbols: (coerce-arg value)))
(define (nsdateformatter-time-style self)
  (tell #:type _uint64 (coerce-arg self) timeStyle))
(define (nsdateformatter-set-time-style! self value)
  (_msg-12 (coerce-arg self) (sel_registerName "setTimeStyle:") value))
(define (nsdateformatter-time-zone self)
  (wrap-objc-object
   (tell (coerce-arg self) timeZone)))
(define (nsdateformatter-set-time-zone! self value)
  (tell #:type _void (coerce-arg self) setTimeZone: (coerce-arg value)))
(define (nsdateformatter-two-digit-start-date self)
  (wrap-objc-object
   (tell (coerce-arg self) twoDigitStartDate)))
(define (nsdateformatter-set-two-digit-start-date! self value)
  (tell #:type _void (coerce-arg self) setTwoDigitStartDate: (coerce-arg value)))
(define (nsdateformatter-very-short-month-symbols self)
  (wrap-objc-object
   (tell (coerce-arg self) veryShortMonthSymbols)))
(define (nsdateformatter-set-very-short-month-symbols! self value)
  (tell #:type _void (coerce-arg self) setVeryShortMonthSymbols: (coerce-arg value)))
(define (nsdateformatter-very-short-standalone-month-symbols self)
  (wrap-objc-object
   (tell (coerce-arg self) veryShortStandaloneMonthSymbols)))
(define (nsdateformatter-set-very-short-standalone-month-symbols! self value)
  (tell #:type _void (coerce-arg self) setVeryShortStandaloneMonthSymbols: (coerce-arg value)))
(define (nsdateformatter-very-short-standalone-weekday-symbols self)
  (wrap-objc-object
   (tell (coerce-arg self) veryShortStandaloneWeekdaySymbols)))
(define (nsdateformatter-set-very-short-standalone-weekday-symbols! self value)
  (tell #:type _void (coerce-arg self) setVeryShortStandaloneWeekdaySymbols: (coerce-arg value)))
(define (nsdateformatter-very-short-weekday-symbols self)
  (wrap-objc-object
   (tell (coerce-arg self) veryShortWeekdaySymbols)))
(define (nsdateformatter-set-very-short-weekday-symbols! self value)
  (tell #:type _void (coerce-arg self) setVeryShortWeekdaySymbols: (coerce-arg value)))
(define (nsdateformatter-weekday-symbols self)
  (wrap-objc-object
   (tell (coerce-arg self) weekdaySymbols)))
(define (nsdateformatter-set-weekday-symbols! self value)
  (tell #:type _void (coerce-arg self) setWeekdaySymbols: (coerce-arg value)))

;; --- Instance methods ---
(define (nsdateformatter-attributed-string-for-object-value-with-default-attributes self obj attrs)
  (wrap-objc-object
   (tell (coerce-arg self) attributedStringForObjectValue: (coerce-arg obj) withDefaultAttributes: (coerce-arg attrs))))
(define (nsdateformatter-copy-with-zone self zone)
  (wrap-objc-object
   (_msg-8 (coerce-arg self) (sel_registerName "copyWithZone:") zone)
   #:retained #t))
(define (nsdateformatter-date-from-string self string)
  (wrap-objc-object
   (tell (coerce-arg self) dateFromString: (coerce-arg string))))
(define (nsdateformatter-editing-string-for-object-value self obj)
  (wrap-objc-object
   (tell (coerce-arg self) editingStringForObjectValue: (coerce-arg obj))))
(define (nsdateformatter-encode-with-coder self coder)
  (tell #:type _void (coerce-arg self) encodeWithCoder: (coerce-arg coder)))
(define (nsdateformatter-get-object-value-for-string-error-description self obj string error)
  (_msg-9 (coerce-arg self) (sel_registerName "getObjectValue:forString:errorDescription:") obj (coerce-arg string) error))
(define (nsdateformatter-get-object-value-for-string-range-error self obj string rangep error)
  (_msg-10 (coerce-arg self) (sel_registerName "getObjectValue:forString:range:error:") obj (coerce-arg string) rangep error))
(define (nsdateformatter-is-lenient self)
  (_msg-0 (coerce-arg self) (sel_registerName "isLenient")))
(define (nsdateformatter-is-partial-string-valid-new-editing-string-error-description self partial-string new-string error)
  (_msg-4 (coerce-arg self) (sel_registerName "isPartialStringValid:newEditingString:errorDescription:") (coerce-arg partial-string) new-string error))
(define (nsdateformatter-is-partial-string-valid-proposed-selected-range-original-string-original-selected-range-error-description self partial-string-ptr proposed-sel-range-ptr orig-string orig-sel-range error)
  (_msg-11 (coerce-arg self) (sel_registerName "isPartialStringValid:proposedSelectedRange:originalString:originalSelectedRange:errorDescription:") partial-string-ptr proposed-sel-range-ptr (coerce-arg orig-string) orig-sel-range error))
(define (nsdateformatter-set-localized-date-format-from-template! self date-format-template)
  (tell #:type _void (coerce-arg self) setLocalizedDateFormatFromTemplate: (coerce-arg date-format-template)))
(define (nsdateformatter-string-for-object-value self obj)
  (wrap-objc-object
   (tell (coerce-arg self) stringForObjectValue: (coerce-arg obj))))
(define (nsdateformatter-string-from-date self date)
  (wrap-objc-object
   (tell (coerce-arg self) stringFromDate: (coerce-arg date))))

;; --- Class methods ---
(define (nsdateformatter-date-format-from-template-options-locale tmplate opts locale)
  (wrap-objc-object
   (_msg-5 NSDateFormatter (sel_registerName "dateFormatFromTemplate:options:locale:") (coerce-arg tmplate) opts (coerce-arg locale))
   ))
(define (nsdateformatter-localized-string-from-date-date-style-time-style date dstyle tstyle)
  (wrap-objc-object
   (_msg-6 NSDateFormatter (sel_registerName "localizedStringFromDate:dateStyle:timeStyle:") (coerce-arg date) dstyle tstyle)
   ))
