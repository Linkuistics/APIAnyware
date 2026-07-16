#lang racket/base
;; Generated binding for NSString (Foundation)
;; Do not edit — regenerate from enriched IR

(require "../../runtime/ffi2-dispatch.rkt"
         (except-in ffi/unsafe ->)
         ffi/unsafe/objc
         (rename-in racket/contract [-> c->])
         "../../runtime/objc-base.rkt"
         "../../runtime/coerce.rkt"
         "../../runtime/block.rkt"
         "../../runtime/type-mapping.rkt"
         "../../runtime/swift-trampoline.rkt"
         (only-in ffi/unsafe [-> aw->]))

;; Load framework and ObjC runtime
(define _fw-lib (ffi-lib "/System/Library/Frameworks/Foundation.framework/Foundation"))
(define _objc-lib (ffi-lib "libobjc"))


;; --- Class predicates ---
(define (nsarray? v) (objc-instance-of? v "NSArray"))
(define (nsdata? v) (objc-instance-of? v "NSData"))
(define (nsdictionary? v) (objc-instance-of? v "NSDictionary"))
(define (nsprogress? v) (objc-instance-of? v "NSProgress"))
(define (nsstring? v) (objc-instance-of? v "NSString"))
(define (_playgroundquicklook? v) (objc-instance-of? v "_PlaygroundQuickLook"))
(provide NSString)
(provide/contract
  [make-nsstring-init-with-bytes-length-encoding (c-> (or/c cpointer? #f) exact-nonnegative-integer? exact-nonnegative-integer? any/c)]
  [make-nsstring-init-with-bytes-no-copy-length-encoding-deallocator (c-> (or/c cpointer? #f) exact-nonnegative-integer? exact-nonnegative-integer? (or/c procedure? #f) any/c)]
  [make-nsstring-init-with-bytes-no-copy-length-encoding-free-when-done (c-> (or/c cpointer? #f) exact-nonnegative-integer? exact-nonnegative-integer? boolean? any/c)]
  [make-nsstring-init-with-c-string-encoding (c-> string? exact-nonnegative-integer? any/c)]
  [make-nsstring-init-with-characters-length (c-> (or/c cpointer? #f) exact-nonnegative-integer? any/c)]
  [make-nsstring-init-with-characters-no-copy-length-deallocator (c-> (or/c cpointer? #f) exact-nonnegative-integer? (or/c procedure? #f) any/c)]
  [make-nsstring-init-with-characters-no-copy-length-free-when-done (c-> (or/c cpointer? #f) exact-nonnegative-integer? boolean? any/c)]
  [make-nsstring-init-with-coder (c-> (or/c string? objc-object? #f) any/c)]
  [make-nsstring-init-with-contents-of-file-encoding-error (c-> (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c cpointer? #f) any/c)]
  [make-nsstring-init-with-contents-of-file-used-encoding-error (c-> (or/c string? objc-object? #f) (or/c cpointer? #f) (or/c cpointer? #f) any/c)]
  [make-nsstring-init-with-contents-of-url-encoding-error (c-> (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c cpointer? #f) any/c)]
  [make-nsstring-init-with-contents-of-url-used-encoding-error (c-> (or/c string? objc-object? #f) (or/c cpointer? #f) (or/c cpointer? #f) any/c)]
  [make-nsstring-init-with-data-encoding (c-> (or/c string? objc-object? #f) exact-nonnegative-integer? any/c)]
  [make-nsstring-init-with-format-arguments (c-> (or/c string? objc-object? #f) (or/c cpointer? #f) any/c)]
  [make-nsstring-init-with-format-locale-arguments (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c cpointer? #f) any/c)]
  [make-nsstring-init-with-string (c-> (or/c string? objc-object? #f) any/c)]
  [make-nsstring-init-with-utf8-string (c-> string? any/c)]
  [make-nsstring-init-with-validated-format-valid-format-specifiers-arguments-error (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c cpointer? #f) (or/c cpointer? #f) any/c)]
  [make-nsstring-init-with-validated-format-valid-format-specifiers-locale-arguments-error (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c cpointer? #f) (or/c cpointer? #f) any/c)]
  [nsstring-utf8-string (c-> nsstring? (or/c string? #f))]
  [nsstring-absolute-path (c-> nsstring? boolean?)]
  [nsstring-available-string-encodings (c-> (or/c cpointer? #f))]
  [nsstring-bool-value (c-> nsstring? boolean?)]
  [nsstring-capitalized-string (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-custom-playground-quick-look (c-> nsstring? (or/c _playgroundquicklook? objc-nil?))]
  [nsstring-decomposed-string-with-canonical-mapping (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-decomposed-string-with-compatibility-mapping (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-default-c-string-encoding (c-> exact-nonnegative-integer?)]
  [nsstring-description (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-double-value (c-> nsstring? real?)]
  [nsstring-fastest-encoding (c-> nsstring? exact-nonnegative-integer?)]
  [nsstring-file-system-representation (c-> nsstring? (or/c string? #f))]
  [nsstring-float-value (c-> nsstring? real?)]
  [nsstring-hash (c-> nsstring? exact-nonnegative-integer?)]
  [nsstring-int-value (c-> nsstring? exact-integer?)]
  [nsstring-integer-value (c-> nsstring? exact-integer?)]
  [nsstring-last-path-component (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-length (c-> nsstring? exact-nonnegative-integer?)]
  [nsstring-localized-capitalized-string (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-localized-lowercase-string (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-localized-uppercase-string (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-long-long-value (c-> nsstring? exact-integer?)]
  [nsstring-lowercase-string (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-path-components (c-> nsstring? (or/c nsarray? objc-nil?))]
  [nsstring-path-extension (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-precomposed-string-with-canonical-mapping (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-precomposed-string-with-compatibility-mapping (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-smallest-encoding (c-> nsstring? exact-nonnegative-integer?)]
  [nsstring-string-by-abbreviating-with-tilde-in-path (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-string-by-deleting-last-path-component (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-string-by-deleting-path-extension (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-string-by-expanding-tilde-in-path (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-string-by-removing-percent-encoding (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-string-by-resolving-symlinks-in-path (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-string-by-standardizing-path (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-uppercase-string (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-c-string-using-encoding (c-> nsstring? exact-nonnegative-integer? (or/c string? #f))]
  [nsstring-can-be-converted-to-encoding (c-> nsstring? exact-nonnegative-integer? boolean?)]
  [nsstring-capitalized-string-with-locale (c-> nsstring? (or/c string? objc-object? #f) (or/c nsstring? objc-nil?))]
  [nsstring-case-insensitive-compare (c-> nsstring? (or/c string? objc-object? #f) exact-integer?)]
  [nsstring-character-at-index (c-> nsstring? exact-nonnegative-integer? exact-nonnegative-integer?)]
  [nsstring-common-prefix-with-string-options (c-> nsstring? (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c nsstring? objc-nil?))]
  [nsstring-compare (c-> nsstring? (or/c string? objc-object? #f) exact-integer?)]
  [nsstring-compare-options (c-> nsstring? (or/c string? objc-object? #f) exact-nonnegative-integer? exact-integer?)]
  [nsstring-compare-options-range (c-> nsstring? (or/c string? objc-object? #f) exact-nonnegative-integer? any/c exact-integer?)]
  [nsstring-compare-options-range-locale (c-> nsstring? (or/c string? objc-object? #f) exact-nonnegative-integer? any/c (or/c string? objc-object? #f) exact-integer?)]
  [nsstring-complete-path-into-string-case-sensitive-matches-into-array-filter-types (c-> nsstring? (or/c cpointer? #f) boolean? (or/c cpointer? #f) (or/c string? objc-object? #f) exact-nonnegative-integer?)]
  [nsstring-components-separated-by-characters-in-set (c-> nsstring? (or/c string? objc-object? #f) (or/c nsarray? objc-nil?))]
  [nsstring-components-separated-by-string (c-> nsstring? (or/c string? objc-object? #f) (or/c nsarray? objc-nil?))]
  [nsstring-contains-string (c-> nsstring? (or/c string? objc-object? #f) boolean?)]
  [nsstring-copy-with-zone (c-> nsstring? (or/c cpointer? #f) any/c)]
  [nsstring-data-using-encoding (c-> nsstring? exact-nonnegative-integer? (or/c nsdata? objc-nil?))]
  [nsstring-data-using-encoding-allow-lossy-conversion (c-> nsstring? exact-nonnegative-integer? boolean? (or/c nsdata? objc-nil?))]
  [nsstring-encode-with-coder (c-> nsstring? (or/c string? objc-object? #f) void?)]
  [nsstring-enumerate-lines-using-block (c-> nsstring? (or/c procedure? #f) void?)]
  [nsstring-enumerate-linguistic-tags-in-range-scheme-options-orthography-using-block (c-> nsstring? any/c (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c string? objc-object? #f) (or/c procedure? #f) void?)]
  [nsstring-enumerate-substrings-in-range-options-using-block (c-> nsstring? any/c exact-nonnegative-integer? (or/c procedure? #f) void?)]
  [nsstring-get-bytes-max-length-used-length-encoding-options-range-remaining-range (c-> nsstring? (or/c cpointer? #f) exact-nonnegative-integer? (or/c cpointer? #f) exact-nonnegative-integer? exact-nonnegative-integer? any/c (or/c cpointer? #f) boolean?)]
  [nsstring-get-c-string-max-length-encoding (c-> nsstring? (or/c cpointer? #f) exact-nonnegative-integer? exact-nonnegative-integer? boolean?)]
  [nsstring-get-characters (c-> nsstring? (or/c cpointer? #f) void?)]
  [nsstring-get-characters-range (c-> nsstring? (or/c cpointer? #f) any/c void?)]
  [nsstring-get-file-system-representation-max-length (c-> nsstring? (or/c cpointer? #f) exact-nonnegative-integer? boolean?)]
  [nsstring-get-line-start-end-contents-end-for-range (c-> nsstring? (or/c cpointer? #f) (or/c cpointer? #f) (or/c cpointer? #f) any/c void?)]
  [nsstring-get-paragraph-start-end-contents-end-for-range (c-> nsstring? (or/c cpointer? #f) (or/c cpointer? #f) (or/c cpointer? #f) any/c void?)]
  [nsstring-has-prefix (c-> nsstring? (or/c string? objc-object? #f) boolean?)]
  [nsstring-has-suffix (c-> nsstring? (or/c string? objc-object? #f) boolean?)]
  [nsstring-is-absolute-path (c-> nsstring? boolean?)]
  [nsstring-is-equal-to-string (c-> nsstring? (or/c string? objc-object? #f) boolean?)]
  [nsstring-item-provider-visibility-for-representation-with-type-identifier (c-> nsstring? (or/c string? objc-object? #f) exact-integer?)]
  [nsstring-length-of-bytes-using-encoding (c-> nsstring? exact-nonnegative-integer? exact-nonnegative-integer?)]
  [nsstring-line-range-for-range (c-> nsstring? any/c any/c)]
  [nsstring-linguistic-tags-in-range-scheme-options-orthography-token-ranges (c-> nsstring? any/c (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c string? objc-object? #f) (or/c cpointer? #f) (or/c nsarray? objc-nil?))]
  [nsstring-load-data-with-type-identifier-for-item-provider-completion-handler (c-> nsstring? (or/c string? objc-object? #f) (or/c procedure? #f) (or/c nsprogress? objc-nil?))]
  [nsstring-localized-case-insensitive-compare (c-> nsstring? (or/c string? objc-object? #f) exact-integer?)]
  [nsstring-localized-case-insensitive-contains-string (c-> nsstring? (or/c string? objc-object? #f) boolean?)]
  [nsstring-localized-compare (c-> nsstring? (or/c string? objc-object? #f) exact-integer?)]
  [nsstring-localized-standard-compare (c-> nsstring? (or/c string? objc-object? #f) exact-integer?)]
  [nsstring-localized-standard-contains-string (c-> nsstring? (or/c string? objc-object? #f) boolean?)]
  [nsstring-localized-standard-range-of-string (c-> nsstring? (or/c string? objc-object? #f) any/c)]
  [nsstring-lowercase-string-with-locale (c-> nsstring? (or/c string? objc-object? #f) (or/c nsstring? objc-nil?))]
  [nsstring-maximum-length-of-bytes-using-encoding (c-> nsstring? exact-nonnegative-integer? exact-nonnegative-integer?)]
  [nsstring-mutable-copy-with-zone (c-> nsstring? (or/c cpointer? #f) any/c)]
  [nsstring-paragraph-range-for-range (c-> nsstring? any/c any/c)]
  [nsstring-property-list (c-> nsstring? any/c)]
  [nsstring-property-list-from-strings-file-format (c-> nsstring? (or/c nsdictionary? objc-nil?))]
  [nsstring-range-of-character-from-set (c-> nsstring? (or/c string? objc-object? #f) any/c)]
  [nsstring-range-of-character-from-set-options (c-> nsstring? (or/c string? objc-object? #f) exact-nonnegative-integer? any/c)]
  [nsstring-range-of-character-from-set-options-range (c-> nsstring? (or/c string? objc-object? #f) exact-nonnegative-integer? any/c any/c)]
  [nsstring-range-of-composed-character-sequence-at-index (c-> nsstring? exact-nonnegative-integer? any/c)]
  [nsstring-range-of-composed-character-sequences-for-range (c-> nsstring? any/c any/c)]
  [nsstring-range-of-string (c-> nsstring? (or/c string? objc-object? #f) any/c)]
  [nsstring-range-of-string-options (c-> nsstring? (or/c string? objc-object? #f) exact-nonnegative-integer? any/c)]
  [nsstring-range-of-string-options-range (c-> nsstring? (or/c string? objc-object? #f) exact-nonnegative-integer? any/c any/c)]
  [nsstring-range-of-string-options-range-locale (c-> nsstring? (or/c string? objc-object? #f) exact-nonnegative-integer? any/c (or/c string? objc-object? #f) any/c)]
  [nsstring-string-by-adding-percent-encoding-with-allowed-characters (c-> nsstring? (or/c string? objc-object? #f) (or/c nsstring? objc-nil?))]
  [nsstring-string-by-appending-path-component (c-> nsstring? (or/c string? objc-object? #f) (or/c nsstring? objc-nil?))]
  [nsstring-string-by-appending-path-extension (c-> nsstring? (or/c string? objc-object? #f) (or/c nsstring? objc-nil?))]
  [nsstring-string-by-appending-string (c-> nsstring? (or/c string? objc-object? #f) (or/c nsstring? objc-nil?))]
  [nsstring-string-by-applying-transform-reverse (c-> nsstring? (or/c string? objc-object? #f) boolean? (or/c nsstring? objc-nil?))]
  [nsstring-string-by-folding-with-options-locale (c-> nsstring? exact-nonnegative-integer? (or/c string? objc-object? #f) (or/c nsstring? objc-nil?))]
  [nsstring-string-by-padding-to-length-with-string-starting-at-index (c-> nsstring? exact-nonnegative-integer? (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c nsstring? objc-nil?))]
  [nsstring-string-by-replacing-characters-in-range-with-string (c-> nsstring? any/c (or/c string? objc-object? #f) (or/c nsstring? objc-nil?))]
  [nsstring-string-by-replacing-occurrences-of-string-with-string (c-> nsstring? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c nsstring? objc-nil?))]
  [nsstring-string-by-replacing-occurrences-of-string-with-string-options-range (c-> nsstring? (or/c string? objc-object? #f) (or/c string? objc-object? #f) exact-nonnegative-integer? any/c (or/c nsstring? objc-nil?))]
  [nsstring-string-by-trimming-characters-in-set (c-> nsstring? (or/c string? objc-object? #f) (or/c nsstring? objc-nil?))]
  [nsstring-strings-by-appending-paths (c-> nsstring? (or/c string? objc-object? #f) (or/c nsarray? objc-nil?))]
  [nsstring-substring-from-index (c-> nsstring? exact-nonnegative-integer? (or/c nsstring? objc-nil?))]
  [nsstring-substring-to-index (c-> nsstring? exact-nonnegative-integer? (or/c nsstring? objc-nil?))]
  [nsstring-substring-with-range (c-> nsstring? any/c (or/c nsstring? objc-nil?))]
  [nsstring-uppercase-string-with-locale (c-> nsstring? (or/c string? objc-object? #f) (or/c nsstring? objc-nil?))]
  [nsstring-variant-fitting-presentation-width (c-> nsstring? exact-integer? (or/c nsstring? objc-nil?))]
  [nsstring-writable-type-identifiers-for-item-provider (c-> nsstring? (or/c nsarray? objc-nil?))]
  [nsstring-write-to-file-atomically-encoding-error (c-> nsstring? (or/c string? objc-object? #f) boolean? exact-nonnegative-integer? (values boolean? (or/c objc-object? #f)))]
  [nsstring-write-to-url-atomically-encoding-error (c-> nsstring? (or/c string? objc-object? #f) boolean? exact-nonnegative-integer? (values boolean? (or/c objc-object? #f)))]
  [nsstring-localized-name-of-string-encoding (c-> exact-nonnegative-integer? (or/c nsstring? objc-nil?))]
  [nsstring-object-with-item-provider-data-type-identifier-error (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) (values any/c (or/c objc-object? #f)))]
  [nsstring-path-with-components (c-> (or/c string? objc-object? #f) (or/c nsstring? objc-nil?))]
  [nsstring-readable-type-identifiers-for-item-provider (c-> (or/c nsarray? objc-nil?))]
  [nsstring-string (c-> any/c)]
  [nsstring-string-encoding-for-data-encoding-options-converted-string-used-lossy-conversion (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c cpointer? #f) (or/c cpointer? #f) exact-nonnegative-integer?)]
  [nsstring-string-with-c-string-encoding (c-> string? exact-nonnegative-integer? any/c)]
  [nsstring-string-with-characters-length (c-> (or/c cpointer? #f) exact-nonnegative-integer? any/c)]
  [nsstring-string-with-contents-of-file-encoding-error (c-> (or/c string? objc-object? #f) exact-nonnegative-integer? (values any/c (or/c objc-object? #f)))]
  [nsstring-string-with-contents-of-file-used-encoding-error (c-> (or/c string? objc-object? #f) (or/c cpointer? #f) (values any/c (or/c objc-object? #f)))]
  [nsstring-string-with-contents-of-url-encoding-error (c-> (or/c string? objc-object? #f) exact-nonnegative-integer? (values any/c (or/c objc-object? #f)))]
  [nsstring-string-with-contents-of-url-used-encoding-error (c-> (or/c string? objc-object? #f) (or/c cpointer? #f) (values any/c (or/c objc-object? #f)))]
  [nsstring-string-with-string (c-> (or/c string? objc-object? #f) any/c)]
  [nsstring-string-with-utf8-string (c-> string? any/c)]
  [nsstring-supports-secure-coding (c-> boolean?)]
  )

(provide
  make-nsstring-string
  )

;; --- Class reference ---
(import-class NSString)

;; --- Native dispatch bindings (generated objc_msgSend, ADR-0013) ---
(define-aw-msg aw_racket_msg_0_P (-> ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_0_N (-> ptr_t ptr_t string_t))
(define-aw-msg aw_racket_msg_0_b (-> ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_0_i (-> ptr_t ptr_t int32_t))
(define-aw-msg aw_racket_msg_0_q (-> ptr_t ptr_t int64_t))
(define-aw-msg aw_racket_msg_0_Q (-> ptr_t ptr_t uint64_t))
(define-aw-msg aw_racket_msg_0_f (-> ptr_t ptr_t float_t))
(define-aw-msg aw_racket_msg_0_d (-> ptr_t ptr_t double_t))
(define-aw-msg aw_racket_msg_P_P (-> ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_P_b (-> ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_P_q (-> ptr_t ptr_t ptr_t int64_t))
(define-aw-msg aw_racket_msg_P_G (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_P_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PP_P_e (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PPP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PPPP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PPPP_Q (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t uint64_t))
(define-aw-msg aw_racket_msg_PPPPP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PPPG_v (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PPQG_P (-> ptr_t ptr_t ptr_t ptr_t uint64_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_Pb_P (-> ptr_t ptr_t ptr_t bool_t ptr_t))
(define-aw-msg aw_racket_msg_PbPP_Q (-> ptr_t ptr_t ptr_t bool_t ptr_t ptr_t uint64_t))
(define-aw-msg aw_racket_msg_PbQ_b_e (-> ptr_t ptr_t ptr_t bool_t uint64_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_PQ_P (-> ptr_t ptr_t ptr_t uint64_t ptr_t))
(define-aw-msg aw_racket_msg_PQ_P_e (-> ptr_t ptr_t ptr_t uint64_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PQ_b (-> ptr_t ptr_t ptr_t uint64_t bool_t))
(define-aw-msg aw_racket_msg_PQ_q (-> ptr_t ptr_t ptr_t uint64_t int64_t))
(define-aw-msg aw_racket_msg_PQ_G (-> ptr_t ptr_t ptr_t uint64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PQP_P (-> ptr_t ptr_t ptr_t uint64_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PQPQQGP_b (-> ptr_t ptr_t ptr_t uint64_t ptr_t uint64_t uint64_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_PQb_P (-> ptr_t ptr_t ptr_t uint64_t bool_t ptr_t))
(define-aw-msg aw_racket_msg_PQQ_P (-> ptr_t ptr_t ptr_t uint64_t uint64_t ptr_t))
(define-aw-msg aw_racket_msg_PQQ_b (-> ptr_t ptr_t ptr_t uint64_t uint64_t bool_t))
(define-aw-msg aw_racket_msg_PQQP_P (-> ptr_t ptr_t ptr_t uint64_t uint64_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PQQb_P (-> ptr_t ptr_t ptr_t uint64_t uint64_t bool_t ptr_t))
(define-aw-msg aw_racket_msg_PQG_q (-> ptr_t ptr_t ptr_t uint64_t ptr_t int64_t))
(define-aw-msg aw_racket_msg_PQG_G (-> ptr_t ptr_t ptr_t uint64_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PQGP_q (-> ptr_t ptr_t ptr_t uint64_t ptr_t ptr_t int64_t))
(define-aw-msg aw_racket_msg_PQGP_G (-> ptr_t ptr_t ptr_t uint64_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PG_v (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_N_P (-> ptr_t ptr_t string_t ptr_t))
(define-aw-msg aw_racket_msg_NQ_P (-> ptr_t ptr_t string_t uint64_t ptr_t))
(define-aw-msg aw_racket_msg_q_P (-> ptr_t ptr_t int64_t ptr_t))
(define-aw-msg aw_racket_msg_Q_P (-> ptr_t ptr_t uint64_t ptr_t))
(define-aw-msg aw_racket_msg_Q_N (-> ptr_t ptr_t uint64_t string_t))
(define-aw-msg aw_racket_msg_Q_b (-> ptr_t ptr_t uint64_t bool_t))
(define-aw-msg aw_racket_msg_Q_S (-> ptr_t ptr_t uint64_t uint16_t))
(define-aw-msg aw_racket_msg_Q_Q (-> ptr_t ptr_t uint64_t uint64_t))
(define-aw-msg aw_racket_msg_Q_G (-> ptr_t ptr_t uint64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_QP_P (-> ptr_t ptr_t uint64_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_QPQ_P (-> ptr_t ptr_t uint64_t ptr_t uint64_t ptr_t))
(define-aw-msg aw_racket_msg_Qb_P (-> ptr_t ptr_t uint64_t bool_t ptr_t))
(define-aw-msg aw_racket_msg_G_P (-> ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_G_G (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_GP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_GPQPP_P (-> ptr_t ptr_t ptr_t ptr_t uint64_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_GPQPP_v (-> ptr_t ptr_t ptr_t ptr_t uint64_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_GQP_v (-> ptr_t ptr_t ptr_t uint64_t ptr_t void_t))

;; --- Constructors ---
(define (make-nsstring-init-with-bytes-length-encoding bytes len encoding)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PQQ_P (id->ffi2-ptr (tell NSString alloc)) (id->ffi2-ptr (sel_registerName "initWithBytes:length:encoding:")) (id->ffi2-ptr bytes) len encoding))
   #:retained #t))

;; block param 3: stored (retained across calls)
(define (make-nsstring-init-with-bytes-no-copy-length-encoding-deallocator bytes len encoding deallocator)
  (define-values (_blk3 _blk3-id)
    (make-objc-block deallocator (list _pointer _uint64) _void))
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PQQP_P (id->ffi2-ptr (tell NSString alloc)) (id->ffi2-ptr (sel_registerName "initWithBytesNoCopy:length:encoding:deallocator:")) (id->ffi2-ptr bytes) len encoding (id->ffi2-ptr _blk3)))
   #:retained #t))

(define (make-nsstring-init-with-bytes-no-copy-length-encoding-free-when-done bytes len encoding free-buffer)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PQQb_P (id->ffi2-ptr (tell NSString alloc)) (id->ffi2-ptr (sel_registerName "initWithBytesNoCopy:length:encoding:freeWhenDone:")) (id->ffi2-ptr bytes) len encoding free-buffer))
   #:retained #t))

(define (make-nsstring-init-with-c-string-encoding null-terminated-c-string encoding)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_NQ_P (id->ffi2-ptr (tell NSString alloc)) (id->ffi2-ptr (sel_registerName "initWithCString:encoding:")) null-terminated-c-string encoding))
   #:retained #t))

(define (make-nsstring-init-with-characters-length characters length)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PQ_P (id->ffi2-ptr (tell NSString alloc)) (id->ffi2-ptr (sel_registerName "initWithCharacters:length:")) (id->ffi2-ptr characters) length))
   #:retained #t))

;; block param 2: stored (retained across calls)
(define (make-nsstring-init-with-characters-no-copy-length-deallocator chars len deallocator)
  (define-values (_blk2 _blk2-id)
    (make-objc-block deallocator (list _pointer _uint64) _void))
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PQP_P (id->ffi2-ptr (tell NSString alloc)) (id->ffi2-ptr (sel_registerName "initWithCharactersNoCopy:length:deallocator:")) (id->ffi2-ptr chars) len (id->ffi2-ptr _blk2)))
   #:retained #t))

(define (make-nsstring-init-with-characters-no-copy-length-free-when-done characters length free-buffer)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PQb_P (id->ffi2-ptr (tell NSString alloc)) (id->ffi2-ptr (sel_registerName "initWithCharactersNoCopy:length:freeWhenDone:")) (id->ffi2-ptr characters) length free-buffer))
   #:retained #t))

(define (make-nsstring-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSString alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))

;; NSError out-param: result-or-error wrapper candidate
(define (make-nsstring-init-with-contents-of-file-encoding-error path enc error)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PQP_P (id->ffi2-ptr (tell NSString alloc)) (id->ffi2-ptr (sel_registerName "initWithContentsOfFile:encoding:error:")) (id->ffi2-ptr (coerce-arg path)) enc (id->ffi2-ptr error)))
   #:retained #t))

;; NSError out-param: result-or-error wrapper candidate
(define (make-nsstring-init-with-contents-of-file-used-encoding-error path enc error)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PPP_P (id->ffi2-ptr (tell NSString alloc)) (id->ffi2-ptr (sel_registerName "initWithContentsOfFile:usedEncoding:error:")) (id->ffi2-ptr (coerce-arg path)) (id->ffi2-ptr enc) (id->ffi2-ptr error)))
   #:retained #t))

;; NSError out-param: result-or-error wrapper candidate
(define (make-nsstring-init-with-contents-of-url-encoding-error url enc error)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PQP_P (id->ffi2-ptr (tell NSString alloc)) (id->ffi2-ptr (sel_registerName "initWithContentsOfURL:encoding:error:")) (id->ffi2-ptr (coerce-arg url)) enc (id->ffi2-ptr error)))
   #:retained #t))

;; NSError out-param: result-or-error wrapper candidate
(define (make-nsstring-init-with-contents-of-url-used-encoding-error url enc error)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PPP_P (id->ffi2-ptr (tell NSString alloc)) (id->ffi2-ptr (sel_registerName "initWithContentsOfURL:usedEncoding:error:")) (id->ffi2-ptr (coerce-arg url)) (id->ffi2-ptr enc) (id->ffi2-ptr error)))
   #:retained #t))

(define (make-nsstring-init-with-data-encoding data encoding)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PQ_P (id->ffi2-ptr (tell NSString alloc)) (id->ffi2-ptr (sel_registerName "initWithData:encoding:")) (id->ffi2-ptr (coerce-arg data)) encoding))
   #:retained #t))

(define (make-nsstring-init-with-format-arguments format arg-list)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (tell NSString alloc)) (id->ffi2-ptr (sel_registerName "initWithFormat:arguments:")) (id->ffi2-ptr (coerce-arg format)) (id->ffi2-ptr arg-list)))
   #:retained #t))

(define (make-nsstring-init-with-format-locale-arguments format locale arg-list)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PPP_P (id->ffi2-ptr (tell NSString alloc)) (id->ffi2-ptr (sel_registerName "initWithFormat:locale:arguments:")) (id->ffi2-ptr (coerce-arg format)) (id->ffi2-ptr (coerce-arg locale)) (id->ffi2-ptr arg-list)))
   #:retained #t))

(define (make-nsstring-init-with-string a-string)
  (wrap-objc-object
   (tell (tell NSString alloc)
         initWithString: (coerce-arg a-string))
   #:retained #t))

(define (make-nsstring-init-with-utf8-string null-terminated-c-string)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_N_P (id->ffi2-ptr (tell NSString alloc)) (id->ffi2-ptr (sel_registerName "initWithUTF8String:")) null-terminated-c-string))
   #:retained #t))

;; NSError out-param: result-or-error wrapper candidate
(define (make-nsstring-init-with-validated-format-valid-format-specifiers-arguments-error format valid-format-specifiers arg-list error)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PPPP_P (id->ffi2-ptr (tell NSString alloc)) (id->ffi2-ptr (sel_registerName "initWithValidatedFormat:validFormatSpecifiers:arguments:error:")) (id->ffi2-ptr (coerce-arg format)) (id->ffi2-ptr (coerce-arg valid-format-specifiers)) (id->ffi2-ptr arg-list) (id->ffi2-ptr error)))
   #:retained #t))

;; NSError out-param: result-or-error wrapper candidate
(define (make-nsstring-init-with-validated-format-valid-format-specifiers-locale-arguments-error format valid-format-specifiers locale arg-list error)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PPPPP_P (id->ffi2-ptr (tell NSString alloc)) (id->ffi2-ptr (sel_registerName "initWithValidatedFormat:validFormatSpecifiers:locale:arguments:error:")) (id->ffi2-ptr (coerce-arg format)) (id->ffi2-ptr (coerce-arg valid-format-specifiers)) (id->ffi2-ptr (coerce-arg locale)) (id->ffi2-ptr arg-list) (id->ffi2-ptr error)))
   #:retained #t))


;; --- Properties ---
(define (nsstring-utf8-string self)
  (aw_racket_msg_0_N (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "UTF8String"))))
(define (nsstring-absolute-path self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "absolutePath"))))
(define (nsstring-available-string-encodings)
  (ptr_t->cpointer (aw_racket_msg_0_P (id->ffi2-ptr NSString) (id->ffi2-ptr (sel_registerName "availableStringEncodings")))))
(define (nsstring-bool-value self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "boolValue"))))
(define (nsstring-capitalized-string self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "capitalizedString"))))))
(define (nsstring-custom-playground-quick-look self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "customPlaygroundQuickLook"))))))
(define (nsstring-decomposed-string-with-canonical-mapping self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "decomposedStringWithCanonicalMapping"))))))
(define (nsstring-decomposed-string-with-compatibility-mapping self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "decomposedStringWithCompatibilityMapping"))))))
(define (nsstring-default-c-string-encoding)
  (aw_racket_msg_0_Q (id->ffi2-ptr NSString) (id->ffi2-ptr (sel_registerName "defaultCStringEncoding"))))
(define (nsstring-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "description"))))))
(define (nsstring-double-value self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "doubleValue"))))
(define (nsstring-fastest-encoding self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "fastestEncoding"))))
(define (nsstring-file-system-representation self)
  (aw_racket_msg_0_N (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "fileSystemRepresentation"))))
(define (nsstring-float-value self)
  (aw_racket_msg_0_f (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "floatValue"))))
(define (nsstring-hash self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hash"))))
(define (nsstring-int-value self)
  (aw_racket_msg_0_i (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "intValue"))))
(define (nsstring-integer-value self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "integerValue"))))
(define (nsstring-last-path-component self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lastPathComponent"))))))
(define (nsstring-length self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "length"))))
(define (nsstring-localized-capitalized-string self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "localizedCapitalizedString"))))))
(define (nsstring-localized-lowercase-string self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "localizedLowercaseString"))))))
(define (nsstring-localized-uppercase-string self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "localizedUppercaseString"))))))
(define (nsstring-long-long-value self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "longLongValue"))))
(define (nsstring-lowercase-string self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lowercaseString"))))))
(define (nsstring-path-components self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pathComponents"))))))
(define (nsstring-path-extension self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pathExtension"))))))
(define (nsstring-precomposed-string-with-canonical-mapping self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "precomposedStringWithCanonicalMapping"))))))
(define (nsstring-precomposed-string-with-compatibility-mapping self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "precomposedStringWithCompatibilityMapping"))))))
(define (nsstring-smallest-encoding self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "smallestEncoding"))))
(define (nsstring-string-by-abbreviating-with-tilde-in-path self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringByAbbreviatingWithTildeInPath"))))))
(define (nsstring-string-by-deleting-last-path-component self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringByDeletingLastPathComponent"))))))
(define (nsstring-string-by-deleting-path-extension self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringByDeletingPathExtension"))))))
(define (nsstring-string-by-expanding-tilde-in-path self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringByExpandingTildeInPath"))))))
(define (nsstring-string-by-removing-percent-encoding self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringByRemovingPercentEncoding"))))))
(define (nsstring-string-by-resolving-symlinks-in-path self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringByResolvingSymlinksInPath"))))))
(define (nsstring-string-by-standardizing-path self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringByStandardizingPath"))))))
(define (nsstring-uppercase-string self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "uppercaseString"))))))

;; --- Instance methods ---
(define (nsstring-c-string-using-encoding self encoding)
  (aw_racket_msg_Q_N (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cStringUsingEncoding:")) encoding))
(define (nsstring-can-be-converted-to-encoding self encoding)
  (aw_racket_msg_Q_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canBeConvertedToEncoding:")) encoding))
(define (nsstring-capitalized-string-with-locale self locale)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "capitalizedStringWithLocale:")) (id->ffi2-ptr (coerce-arg locale))))
   ))
(define (nsstring-case-insensitive-compare self string)
  (aw_racket_msg_P_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "caseInsensitiveCompare:")) (id->ffi2-ptr (coerce-arg string))))
(define (nsstring-character-at-index self index)
  (aw_racket_msg_Q_S (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "characterAtIndex:")) index))
(define (nsstring-common-prefix-with-string-options self str mask)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PQ_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "commonPrefixWithString:options:")) (id->ffi2-ptr (coerce-arg str)) mask))
   ))
(define (nsstring-compare self string)
  (aw_racket_msg_P_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "compare:")) (id->ffi2-ptr (coerce-arg string))))
(define (nsstring-compare-options self string mask)
  (aw_racket_msg_PQ_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "compare:options:")) (id->ffi2-ptr (coerce-arg string)) mask))
(define (nsstring-compare-options-range self string mask range-of-receiver-to-compare)
  (aw_racket_msg_PQG_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "compare:options:range:")) (id->ffi2-ptr (coerce-arg string)) mask (id->ffi2-ptr range-of-receiver-to-compare)))
(define (nsstring-compare-options-range-locale self string mask range-of-receiver-to-compare locale)
  (aw_racket_msg_PQGP_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "compare:options:range:locale:")) (id->ffi2-ptr (coerce-arg string)) mask (id->ffi2-ptr range-of-receiver-to-compare) (id->ffi2-ptr (coerce-arg locale))))
(define (nsstring-complete-path-into-string-case-sensitive-matches-into-array-filter-types self output-name flag output-array filter-types)
  (aw_racket_msg_PbPP_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "completePathIntoString:caseSensitive:matchesIntoArray:filterTypes:")) (id->ffi2-ptr output-name) flag (id->ffi2-ptr output-array) (id->ffi2-ptr (coerce-arg filter-types))))
(define (nsstring-components-separated-by-characters-in-set self separator)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "componentsSeparatedByCharactersInSet:")) (id->ffi2-ptr (coerce-arg separator))))
   ))
(define (nsstring-components-separated-by-string self separator)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "componentsSeparatedByString:")) (id->ffi2-ptr (coerce-arg separator))))
   ))
(define (nsstring-contains-string self str)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "containsString:")) (id->ffi2-ptr (coerce-arg str))))
(define (nsstring-copy-with-zone self zone)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "copyWithZone:")) (id->ffi2-ptr zone)))
   #:retained #t))
(define (nsstring-data-using-encoding self encoding)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_Q_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "dataUsingEncoding:")) encoding))
   ))
(define (nsstring-data-using-encoding-allow-lossy-conversion self encoding lossy)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_Qb_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "dataUsingEncoding:allowLossyConversion:")) encoding lossy))
   ))
(define (nsstring-encode-with-coder self coder)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "encodeWithCoder:")) (id->ffi2-ptr (coerce-arg coder))))
;; block param 0: synchronous (caller frees)
(define (nsstring-enumerate-lines-using-block self block)
  (define-values (_blk0 _blk0-id)
    (make-objc-block block (list _id _pointer) _void))
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enumerateLinesUsingBlock:")) (id->ffi2-ptr _blk0)))
;; block param 4: synchronous (caller frees)
(define (nsstring-enumerate-linguistic-tags-in-range-scheme-options-orthography-using-block self range scheme options orthography block)
  (define-values (_blk4 _blk4-id)
    (make-objc-block block (list _id _NSRange _NSRange _pointer) _void))
  (aw_racket_msg_GPQPP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enumerateLinguisticTagsInRange:scheme:options:orthography:usingBlock:")) (id->ffi2-ptr range) (id->ffi2-ptr (coerce-arg scheme)) options (id->ffi2-ptr (coerce-arg orthography)) (id->ffi2-ptr _blk4)))
;; block param 2: synchronous (caller frees)
(define (nsstring-enumerate-substrings-in-range-options-using-block self range opts block)
  (define-values (_blk2 _blk2-id)
    (make-objc-block block (list _id _NSRange _NSRange _pointer) _void))
  (aw_racket_msg_GQP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enumerateSubstringsInRange:options:usingBlock:")) (id->ffi2-ptr range) opts (id->ffi2-ptr _blk2)))
(define (nsstring-get-bytes-max-length-used-length-encoding-options-range-remaining-range self buffer max-buffer-count used-buffer-count encoding options range leftover)
  (aw_racket_msg_PQPQQGP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getBytes:maxLength:usedLength:encoding:options:range:remainingRange:")) (id->ffi2-ptr buffer) max-buffer-count (id->ffi2-ptr used-buffer-count) encoding options (id->ffi2-ptr range) (id->ffi2-ptr leftover)))
(define (nsstring-get-c-string-max-length-encoding self buffer max-buffer-count encoding)
  (aw_racket_msg_PQQ_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getCString:maxLength:encoding:")) (id->ffi2-ptr buffer) max-buffer-count encoding))
(define (nsstring-get-characters self buffer)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getCharacters:")) (id->ffi2-ptr buffer)))
(define (nsstring-get-characters-range self buffer range)
  (aw_racket_msg_PG_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getCharacters:range:")) (id->ffi2-ptr buffer) (id->ffi2-ptr range)))
(define (nsstring-get-file-system-representation-max-length self cname max)
  (aw_racket_msg_PQ_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getFileSystemRepresentation:maxLength:")) (id->ffi2-ptr cname) max))
(define (nsstring-get-line-start-end-contents-end-for-range self start-ptr line-end-ptr contents-end-ptr range)
  (aw_racket_msg_PPPG_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getLineStart:end:contentsEnd:forRange:")) (id->ffi2-ptr start-ptr) (id->ffi2-ptr line-end-ptr) (id->ffi2-ptr contents-end-ptr) (id->ffi2-ptr range)))
(define (nsstring-get-paragraph-start-end-contents-end-for-range self start-ptr par-end-ptr contents-end-ptr range)
  (aw_racket_msg_PPPG_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getParagraphStart:end:contentsEnd:forRange:")) (id->ffi2-ptr start-ptr) (id->ffi2-ptr par-end-ptr) (id->ffi2-ptr contents-end-ptr) (id->ffi2-ptr range)))
(define (nsstring-has-prefix self str)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hasPrefix:")) (id->ffi2-ptr (coerce-arg str))))
(define (nsstring-has-suffix self str)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hasSuffix:")) (id->ffi2-ptr (coerce-arg str))))
(define (nsstring-is-absolute-path self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAbsolutePath"))))
(define (nsstring-is-equal-to-string self a-string)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isEqualToString:")) (id->ffi2-ptr (coerce-arg a-string))))
(define (nsstring-item-provider-visibility-for-representation-with-type-identifier self type-identifier)
  (aw_racket_msg_P_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "itemProviderVisibilityForRepresentationWithTypeIdentifier:")) (id->ffi2-ptr (coerce-arg type-identifier))))
(define (nsstring-length-of-bytes-using-encoding self enc)
  (aw_racket_msg_Q_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lengthOfBytesUsingEncoding:")) enc))
(define (nsstring-line-range-for-range self range)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_G_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lineRangeForRange:")) (id->ffi2-ptr range) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsstring-linguistic-tags-in-range-scheme-options-orthography-token-ranges self range scheme options orthography token-ranges)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_GPQPP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "linguisticTagsInRange:scheme:options:orthography:tokenRanges:")) (id->ffi2-ptr range) (id->ffi2-ptr (coerce-arg scheme)) options (id->ffi2-ptr (coerce-arg orthography)) (id->ffi2-ptr token-ranges)))
   ))
;; block param 1: async-copied (runtime-managed)
(define (nsstring-load-data-with-type-identifier-for-item-provider-completion-handler self type-identifier completion-handler)
  (define-values (_blk1 _blk1-id)
    (make-objc-block completion-handler (list _id _id) _void))
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "loadDataWithTypeIdentifier:forItemProviderCompletionHandler:")) (id->ffi2-ptr (coerce-arg type-identifier)) (id->ffi2-ptr _blk1)))
   ))
(define (nsstring-localized-case-insensitive-compare self string)
  (aw_racket_msg_P_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "localizedCaseInsensitiveCompare:")) (id->ffi2-ptr (coerce-arg string))))
(define (nsstring-localized-case-insensitive-contains-string self str)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "localizedCaseInsensitiveContainsString:")) (id->ffi2-ptr (coerce-arg str))))
(define (nsstring-localized-compare self string)
  (aw_racket_msg_P_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "localizedCompare:")) (id->ffi2-ptr (coerce-arg string))))
(define (nsstring-localized-standard-compare self string)
  (aw_racket_msg_P_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "localizedStandardCompare:")) (id->ffi2-ptr (coerce-arg string))))
(define (nsstring-localized-standard-contains-string self str)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "localizedStandardContainsString:")) (id->ffi2-ptr (coerce-arg str))))
(define (nsstring-localized-standard-range-of-string self str)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_P_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "localizedStandardRangeOfString:")) (id->ffi2-ptr (coerce-arg str)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsstring-lowercase-string-with-locale self locale)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lowercaseStringWithLocale:")) (id->ffi2-ptr (coerce-arg locale))))
   ))
(define (nsstring-maximum-length-of-bytes-using-encoding self enc)
  (aw_racket_msg_Q_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "maximumLengthOfBytesUsingEncoding:")) enc))
(define (nsstring-mutable-copy-with-zone self zone)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mutableCopyWithZone:")) (id->ffi2-ptr zone)))
   #:retained #t))
(define (nsstring-paragraph-range-for-range self range)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_G_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "paragraphRangeForRange:")) (id->ffi2-ptr range) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsstring-property-list self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "propertyList"))))
   ))
(define (nsstring-property-list-from-strings-file-format self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "propertyListFromStringsFileFormat"))))
   ))
(define (nsstring-range-of-character-from-set self search-set)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_P_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rangeOfCharacterFromSet:")) (id->ffi2-ptr (coerce-arg search-set)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsstring-range-of-character-from-set-options self search-set mask)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_PQ_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rangeOfCharacterFromSet:options:")) (id->ffi2-ptr (coerce-arg search-set)) mask (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsstring-range-of-character-from-set-options-range self search-set mask range-of-receiver-to-search)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_PQG_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rangeOfCharacterFromSet:options:range:")) (id->ffi2-ptr (coerce-arg search-set)) mask (id->ffi2-ptr range-of-receiver-to-search) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsstring-range-of-composed-character-sequence-at-index self index)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_Q_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rangeOfComposedCharacterSequenceAtIndex:")) index (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsstring-range-of-composed-character-sequences-for-range self range)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_G_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rangeOfComposedCharacterSequencesForRange:")) (id->ffi2-ptr range) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsstring-range-of-string self search-string)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_P_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rangeOfString:")) (id->ffi2-ptr (coerce-arg search-string)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsstring-range-of-string-options self search-string mask)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_PQ_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rangeOfString:options:")) (id->ffi2-ptr (coerce-arg search-string)) mask (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsstring-range-of-string-options-range self search-string mask range-of-receiver-to-search)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_PQG_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rangeOfString:options:range:")) (id->ffi2-ptr (coerce-arg search-string)) mask (id->ffi2-ptr range-of-receiver-to-search) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsstring-range-of-string-options-range-locale self search-string mask range-of-receiver-to-search locale)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_PQGP_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rangeOfString:options:range:locale:")) (id->ffi2-ptr (coerce-arg search-string)) mask (id->ffi2-ptr range-of-receiver-to-search) (id->ffi2-ptr (coerce-arg locale)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsstring-string-by-adding-percent-encoding-with-allowed-characters self allowed-characters)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringByAddingPercentEncodingWithAllowedCharacters:")) (id->ffi2-ptr (coerce-arg allowed-characters))))
   ))
(define (nsstring-string-by-appending-path-component self str)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringByAppendingPathComponent:")) (id->ffi2-ptr (coerce-arg str))))
   ))
(define (nsstring-string-by-appending-path-extension self str)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringByAppendingPathExtension:")) (id->ffi2-ptr (coerce-arg str))))
   ))
(define (nsstring-string-by-appending-string self a-string)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringByAppendingString:")) (id->ffi2-ptr (coerce-arg a-string))))
   ))
(define (nsstring-string-by-applying-transform-reverse self transform reverse)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_Pb_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringByApplyingTransform:reverse:")) (id->ffi2-ptr (coerce-arg transform)) reverse))
   ))
(define (nsstring-string-by-folding-with-options-locale self options locale)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_QP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringByFoldingWithOptions:locale:")) options (id->ffi2-ptr (coerce-arg locale))))
   ))
(define (nsstring-string-by-padding-to-length-with-string-starting-at-index self new-length pad-string pad-index)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_QPQ_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringByPaddingToLength:withString:startingAtIndex:")) new-length (id->ffi2-ptr (coerce-arg pad-string)) pad-index))
   ))
(define (nsstring-string-by-replacing-characters-in-range-with-string self range replacement)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_GP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringByReplacingCharactersInRange:withString:")) (id->ffi2-ptr range) (id->ffi2-ptr (coerce-arg replacement))))
   ))
(define (nsstring-string-by-replacing-occurrences-of-string-with-string self target replacement)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringByReplacingOccurrencesOfString:withString:")) (id->ffi2-ptr (coerce-arg target)) (id->ffi2-ptr (coerce-arg replacement))))
   ))
(define (nsstring-string-by-replacing-occurrences-of-string-with-string-options-range self target replacement options search-range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PPQG_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringByReplacingOccurrencesOfString:withString:options:range:")) (id->ffi2-ptr (coerce-arg target)) (id->ffi2-ptr (coerce-arg replacement)) options (id->ffi2-ptr search-range)))
   ))
(define (nsstring-string-by-trimming-characters-in-set self set)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringByTrimmingCharactersInSet:")) (id->ffi2-ptr (coerce-arg set))))
   ))
(define (nsstring-strings-by-appending-paths self paths)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringsByAppendingPaths:")) (id->ffi2-ptr (coerce-arg paths))))
   ))
(define (nsstring-substring-from-index self from)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_Q_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "substringFromIndex:")) from))
   ))
(define (nsstring-substring-to-index self to)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_Q_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "substringToIndex:")) to))
   ))
(define (nsstring-substring-with-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "substringWithRange:")) (id->ffi2-ptr range)))
   ))
(define (nsstring-uppercase-string-with-locale self locale)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "uppercaseStringWithLocale:")) (id->ffi2-ptr (coerce-arg locale))))
   ))
(define (nsstring-variant-fitting-presentation-width self width)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_q_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "variantFittingPresentationWidth:")) width))
   ))
(define (nsstring-writable-type-identifiers-for-item-provider self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "writableTypeIdentifiersForItemProvider"))))
   ))
;; NSError out-param: result-or-error wrapper candidate
(define (nsstring-write-to-file-atomically-encoding-error self path use-auxiliary-file enc)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PbQ_b_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "writeToFile:atomically:encoding:error:")) (id->ffi2-ptr (coerce-arg path)) use-auxiliary-file enc (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsstring-write-to-url-atomically-encoding-error self url use-auxiliary-file enc)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PbQ_b_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "writeToURL:atomically:encoding:error:")) (id->ffi2-ptr (coerce-arg url)) use-auxiliary-file enc (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))

;; --- Class methods ---
(define (nsstring-localized-name-of-string-encoding encoding)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_Q_P (id->ffi2-ptr NSString) (id->ffi2-ptr (sel_registerName "localizedNameOfStringEncoding:")) encoding))
   ))
;; NSError out-param: result-or-error wrapper candidate
(define (nsstring-object-with-item-provider-data-type-identifier-error data type-identifier)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PP_P_e (id->ffi2-ptr NSString) (id->ffi2-ptr (sel_registerName "objectWithItemProviderData:typeIdentifier:error:")) (id->ffi2-ptr (coerce-arg data)) (id->ffi2-ptr (coerce-arg type-identifier)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values (wrap-objc-object (ffi2-ptr->id result)) (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
(define (nsstring-path-with-components components)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr NSString) (id->ffi2-ptr (sel_registerName "pathWithComponents:")) (id->ffi2-ptr (coerce-arg components))))
   ))
(define (nsstring-readable-type-identifiers-for-item-provider)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSString) (id->ffi2-ptr (sel_registerName "readableTypeIdentifiersForItemProvider"))))
   ))
(define (nsstring-string)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSString) (id->ffi2-ptr (sel_registerName "string"))))
   ))
(define (nsstring-string-encoding-for-data-encoding-options-converted-string-used-lossy-conversion data opts string used-lossy-conversion)
  (aw_racket_msg_PPPP_Q (id->ffi2-ptr NSString) (id->ffi2-ptr (sel_registerName "stringEncodingForData:encodingOptions:convertedString:usedLossyConversion:")) (id->ffi2-ptr (coerce-arg data)) (id->ffi2-ptr (coerce-arg opts)) (id->ffi2-ptr string) (id->ffi2-ptr used-lossy-conversion)))
(define (nsstring-string-with-c-string-encoding c-string enc)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_NQ_P (id->ffi2-ptr NSString) (id->ffi2-ptr (sel_registerName "stringWithCString:encoding:")) c-string enc))
   ))
(define (nsstring-string-with-characters-length characters length)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PQ_P (id->ffi2-ptr NSString) (id->ffi2-ptr (sel_registerName "stringWithCharacters:length:")) (id->ffi2-ptr characters) length))
   ))
;; NSError out-param: result-or-error wrapper candidate
(define (nsstring-string-with-contents-of-file-encoding-error path enc)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PQ_P_e (id->ffi2-ptr NSString) (id->ffi2-ptr (sel_registerName "stringWithContentsOfFile:encoding:error:")) (id->ffi2-ptr (coerce-arg path)) enc (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values (wrap-objc-object (ffi2-ptr->id result)) (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsstring-string-with-contents-of-file-used-encoding-error path enc)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PP_P_e (id->ffi2-ptr NSString) (id->ffi2-ptr (sel_registerName "stringWithContentsOfFile:usedEncoding:error:")) (id->ffi2-ptr (coerce-arg path)) (id->ffi2-ptr enc) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values (wrap-objc-object (ffi2-ptr->id result)) (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsstring-string-with-contents-of-url-encoding-error url enc)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PQ_P_e (id->ffi2-ptr NSString) (id->ffi2-ptr (sel_registerName "stringWithContentsOfURL:encoding:error:")) (id->ffi2-ptr (coerce-arg url)) enc (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values (wrap-objc-object (ffi2-ptr->id result)) (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsstring-string-with-contents-of-url-used-encoding-error url enc)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PP_P_e (id->ffi2-ptr NSString) (id->ffi2-ptr (sel_registerName "stringWithContentsOfURL:usedEncoding:error:")) (id->ffi2-ptr (coerce-arg url)) (id->ffi2-ptr enc) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values (wrap-objc-object (ffi2-ptr->id result)) (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
(define (nsstring-string-with-string string)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr NSString) (id->ffi2-ptr (sel_registerName "stringWithString:")) (id->ffi2-ptr (coerce-arg string))))
   ))
(define (nsstring-string-with-utf8-string null-terminated-c-string)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_N_P (id->ffi2-ptr NSString) (id->ffi2-ptr (sel_registerName "stringWithUTF8String:")) null-terminated-c-string))
   ))
(define (nsstring-supports-secure-coding)
  (aw_racket_msg_0_b (id->ffi2-ptr NSString) (id->ffi2-ptr (sel_registerName "supportsSecureCoding"))))

;; --- Swift-native methods (receiver-handle trampolines, ADR-0030) ---
(define make-nsstring-string
  (let ([raw (get-ffi-obj 'aw_racket_swift_init_Foundation_NSString_bd6dd38a _aw-lib (_fun _pointer aw-> _pointer))])
    (lambda (string)
      (raw (aw-string-arg string)))))
