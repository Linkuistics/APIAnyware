(in-package #:apianyware-sbcl-impl)

;;; Generated enum definitions for Foundation — do not edit

;; NSActivityOptions
(defconstant ns:ns-activity-idle-display-sleep-disabled 1099511627776)
(defconstant ns:ns-activity-idle-system-sleep-disabled 1048576)
(defconstant ns:ns-activity-sudden-termination-disabled 16384)
(defconstant ns:ns-activity-automatic-termination-disabled 32768)
(defconstant ns:ns-activity-animation-tracking-enabled 35184372088832)
(defconstant ns:ns-activity-tracking-enabled 70368744177664)
(defconstant ns:ns-activity-user-initiated 16777215)
(defconstant ns:ns-activity-user-initiated-allowing-idle-system-sleep 15728639)
(defconstant ns:ns-activity-background 255)
(defconstant ns:ns-activity-latency-critical 1095216660480)
(defconstant ns:ns-activity-user-interactive 1095233437695)

;; NSAlignmentOptions
(defconstant ns:ns-align-min-x-inward 1)
(defconstant ns:ns-align-min-y-inward 2)
(defconstant ns:ns-align-max-x-inward 4)
(defconstant ns:ns-align-max-y-inward 8)
(defconstant ns:ns-align-width-inward 16)
(defconstant ns:ns-align-height-inward 32)
(defconstant ns:ns-align-min-x-outward 256)
(defconstant ns:ns-align-min-y-outward 512)
(defconstant ns:ns-align-max-x-outward 1024)
(defconstant ns:ns-align-max-y-outward 2048)
(defconstant ns:ns-align-width-outward 4096)
(defconstant ns:ns-align-height-outward 8192)
(defconstant ns:ns-align-min-x-nearest 65536)
(defconstant ns:ns-align-min-y-nearest 131072)
(defconstant ns:ns-align-max-x-nearest 262144)
(defconstant ns:ns-align-max-y-nearest 524288)
(defconstant ns:ns-align-width-nearest 1048576)
(defconstant ns:ns-align-height-nearest 2097152)
(defconstant ns:ns-align-all-edges-inward 15)
(defconstant ns:ns-align-all-edges-outward 3840)
(defconstant ns:ns-align-all-edges-nearest 983040)

;; NSAppleEventSendOptions
(defconstant ns:ns-apple-event-send-no-reply 1)
(defconstant ns:ns-apple-event-send-queue-reply 2)
(defconstant ns:ns-apple-event-send-wait-for-reply 3)
(defconstant ns:ns-apple-event-send-never-interact 16)
(defconstant ns:ns-apple-event-send-can-interact 32)
(defconstant ns:ns-apple-event-send-always-interact 48)
(defconstant ns:ns-apple-event-send-can-switch-layer 64)
(defconstant ns:ns-apple-event-send-dont-record 4096)
(defconstant ns:ns-apple-event-send-dont-execute 8192)
(defconstant ns:ns-apple-event-send-dont-annotate 65536)
(defconstant ns:ns-apple-event-send-default-options 35)

;; NSAttributedStringEnumerationOptions
(defconstant ns:ns-attributed-string-enumeration-reverse 2)
(defconstant ns:ns-attributed-string-enumeration-longest-effective-range-not-required 1048576)

;; NSAttributedStringFormattingOptions
(defconstant ns:ns-attributed-string-formatting-insert-argument-attributes-without-merging 1)
(defconstant ns:ns-attributed-string-formatting-apply-replacement-index-attribute 2)

;; NSAttributedStringMarkdownInterpretedSyntax
(defconstant ns:ns-attributed-string-markdown-interpreted-syntax-full 0)
(defconstant ns:ns-attributed-string-markdown-interpreted-syntax-inline-only 1)
(defconstant ns:ns-attributed-string-markdown-interpreted-syntax-inline-only-preserving-whitespace 2)

;; NSAttributedStringMarkdownParsingFailurePolicy
(defconstant ns:ns-attributed-string-markdown-parsing-failure-return-error 0)
(defconstant ns:ns-attributed-string-markdown-parsing-failure-return-partially-parsed-if-possible 1)

;; NSBackgroundActivityResult
(defconstant ns:ns-background-activity-result-finished 1)
(defconstant ns:ns-background-activity-result-deferred 2)

;; NSBinarySearchingOptions
(defconstant ns:ns-binary-searching-first-equal 256)
(defconstant ns:ns-binary-searching-last-equal 512)
(defconstant ns:ns-binary-searching-insertion-index 1024)

;; NSByteCountFormatterCountStyle
(defconstant ns:ns-byte-count-formatter-count-style-file 0)
(defconstant ns:ns-byte-count-formatter-count-style-memory 1)
(defconstant ns:ns-byte-count-formatter-count-style-decimal 2)
(defconstant ns:ns-byte-count-formatter-count-style-binary 3)

;; NSByteCountFormatterUnits
(defconstant ns:ns-byte-count-formatter-use-default 0)
(defconstant ns:ns-byte-count-formatter-use-bytes 1)
(defconstant ns:ns-byte-count-formatter-use-kb 2)
(defconstant ns:ns-byte-count-formatter-use-mb 4)
(defconstant ns:ns-byte-count-formatter-use-gb 8)
(defconstant ns:ns-byte-count-formatter-use-tb 16)
(defconstant ns:ns-byte-count-formatter-use-pb 32)
(defconstant ns:ns-byte-count-formatter-use-eb 64)
(defconstant ns:ns-byte-count-formatter-use-zb 128)
(defconstant ns:ns-byte-count-formatter-use-yb-or-higher 65280)
(defconstant ns:ns-byte-count-formatter-use-all 65535)

;; NSCalculationError
(defconstant ns:ns-calculation-no-error 0)
(defconstant ns:ns-calculation-loss-of-precision 1)
(defconstant ns:ns-calculation-underflow 2)
(defconstant ns:ns-calculation-overflow 3)
(defconstant ns:ns-calculation-divide-by-zero 4)

;; NSCalendarOptions
(defconstant ns:ns-calendar-wrap-components 1)
(defconstant ns:ns-calendar-match-strictly 2)
(defconstant ns:ns-calendar-search-backwards 4)
(defconstant ns:ns-calendar-match-previous-time-preserving-smaller-units 256)
(defconstant ns:ns-calendar-match-next-time-preserving-smaller-units 512)
(defconstant ns:ns-calendar-match-next-time 1024)
(defconstant ns:ns-calendar-match-first 4096)
(defconstant ns:ns-calendar-match-last 8192)

;; NSCalendarUnit
(defconstant ns:ns-calendar-unit-era 2)
(defconstant ns:ns-calendar-unit-year 4)
(defconstant ns:ns-calendar-unit-month 8)
(defconstant ns:ns-calendar-unit-day 16)
(defconstant ns:ns-calendar-unit-hour 32)
(defconstant ns:ns-calendar-unit-minute 64)
(defconstant ns:ns-calendar-unit-second 128)
(defconstant ns:ns-calendar-unit-weekday 512)
(defconstant ns:ns-calendar-unit-weekday-ordinal 1024)
(defconstant ns:ns-calendar-unit-quarter 2048)
(defconstant ns:ns-calendar-unit-week-of-month 4096)
(defconstant ns:ns-calendar-unit-week-of-year 8192)
(defconstant ns:ns-calendar-unit-year-for-week-of-year 16384)
(defconstant ns:ns-calendar-unit-nanosecond 32768)
(defconstant ns:ns-calendar-unit-day-of-year 65536)
(defconstant ns:ns-calendar-unit-calendar 1048576)
(defconstant ns:ns-calendar-unit-time-zone 2097152)
(defconstant ns:ns-calendar-unit-is-leap-month 1073741824)
(defconstant ns:ns-calendar-unit-is-repeated-day 2147483648)
(defconstant ns:ns-era-calendar-unit 2)
(defconstant ns:ns-year-calendar-unit 4)
(defconstant ns:ns-month-calendar-unit 8)
(defconstant ns:ns-day-calendar-unit 16)
(defconstant ns:ns-hour-calendar-unit 32)
(defconstant ns:ns-minute-calendar-unit 64)
(defconstant ns:ns-second-calendar-unit 128)
(defconstant ns:ns-week-calendar-unit 256)
(defconstant ns:ns-weekday-calendar-unit 512)
(defconstant ns:ns-weekday-ordinal-calendar-unit 1024)
(defconstant ns:ns-quarter-calendar-unit 2048)
(defconstant ns:ns-week-of-month-calendar-unit 4096)
(defconstant ns:ns-week-of-year-calendar-unit 8192)
(defconstant ns:ns-year-for-week-of-year-calendar-unit 16384)
(defconstant ns:ns-calendar-calendar-unit 1048576)
(defconstant ns:ns-time-zone-calendar-unit 2097152)

;; NSCollectionChangeType
(defconstant ns:ns-collection-change-insert 0)
(defconstant ns:ns-collection-change-remove 1)

;; NSComparisonPredicateModifier
(defconstant ns:ns-direct-predicate-modifier 0)
(defconstant ns:ns-all-predicate-modifier 1)
(defconstant ns:ns-any-predicate-modifier 2)

;; NSComparisonPredicateOptions
(defconstant ns:ns-case-insensitive-predicate-option 1)
(defconstant ns:ns-diacritic-insensitive-predicate-option 2)
(defconstant ns:ns-normalized-predicate-option 4)

;; NSComparisonResult
(defconstant ns:ns-ordered-ascending -1)
(defconstant ns:ns-ordered-same 0)
(defconstant ns:ns-ordered-descending 1)

;; NSCompoundPredicateType
(defconstant ns:ns-not-predicate-type 0)
(defconstant ns:ns-and-predicate-type 1)
(defconstant ns:ns-or-predicate-type 2)

;; NSDataBase64DecodingOptions
(defconstant ns:ns-data-base64-decoding-ignore-unknown-characters 1)

;; NSDataBase64EncodingOptions
(defconstant ns:ns-data-base64-encoding64-character-line-length 1)
(defconstant ns:ns-data-base64-encoding76-character-line-length 2)
(defconstant ns:ns-data-base64-encoding-end-line-with-carriage-return 16)
(defconstant ns:ns-data-base64-encoding-end-line-with-line-feed 32)

;; NSDataCompressionAlgorithm
(defconstant ns:ns-data-compression-algorithm-lzfse 0)
(defconstant ns:ns-data-compression-algorithm-lz4 1)
(defconstant ns:ns-data-compression-algorithm-lzma 2)
(defconstant ns:ns-data-compression-algorithm-zlib 3)

;; NSDataReadingOptions
(defconstant ns:ns-data-reading-mapped-if-safe 1)
(defconstant ns:ns-data-reading-uncached 2)
(defconstant ns:ns-data-reading-mapped-always 8)
(defconstant ns:ns-data-reading-mapped 1)
(defconstant ns:ns-mapped-read 1)
(defconstant ns:ns-uncached-read 2)

;; NSDataSearchOptions
(defconstant ns:ns-data-search-backwards 1)
(defconstant ns:ns-data-search-anchored 2)

;; NSDataWritingOptions
(defconstant ns:ns-data-writing-atomic 1)
(defconstant ns:ns-data-writing-without-overwriting 2)
(defconstant ns:ns-data-writing-file-protection-none 268435456)
(defconstant ns:ns-data-writing-file-protection-complete 536870912)
(defconstant ns:ns-data-writing-file-protection-complete-unless-open 805306368)
(defconstant ns:ns-data-writing-file-protection-complete-until-first-user-authentication 1073741824)
(defconstant ns:ns-data-writing-file-protection-complete-when-user-inactive 1342177280)
(defconstant ns:ns-data-writing-file-protection-mask 4026531840)
(defconstant ns:ns-atomic-write 1)

;; NSDateComponentsFormatterUnitsStyle
(defconstant ns:ns-date-components-formatter-units-style-positional 0)
(defconstant ns:ns-date-components-formatter-units-style-abbreviated 1)
(defconstant ns:ns-date-components-formatter-units-style-short 2)
(defconstant ns:ns-date-components-formatter-units-style-full 3)
(defconstant ns:ns-date-components-formatter-units-style-spell-out 4)
(defconstant ns:ns-date-components-formatter-units-style-brief 5)

;; NSDateComponentsFormatterZeroFormattingBehavior
(defconstant ns:ns-date-components-formatter-zero-formatting-behavior-none 0)
(defconstant ns:ns-date-components-formatter-zero-formatting-behavior-default 1)
(defconstant ns:ns-date-components-formatter-zero-formatting-behavior-drop-leading 2)
(defconstant ns:ns-date-components-formatter-zero-formatting-behavior-drop-middle 4)
(defconstant ns:ns-date-components-formatter-zero-formatting-behavior-drop-trailing 8)
(defconstant ns:ns-date-components-formatter-zero-formatting-behavior-drop-all 14)
(defconstant ns:ns-date-components-formatter-zero-formatting-behavior-pad 65536)

;; NSDateFormatterBehavior
(defconstant ns:ns-date-formatter-behavior-default 0)
(defconstant ns:ns-date-formatter-behavior10-0 1000)
(defconstant ns:ns-date-formatter-behavior10-4 1040)

;; NSDateFormatterStyle
(defconstant ns:ns-date-formatter-no-style 0)
(defconstant ns:ns-date-formatter-short-style 1)
(defconstant ns:ns-date-formatter-medium-style 2)
(defconstant ns:ns-date-formatter-long-style 3)
(defconstant ns:ns-date-formatter-full-style 4)

;; NSDateIntervalFormatterStyle
(defconstant ns:ns-date-interval-formatter-no-style 0)
(defconstant ns:ns-date-interval-formatter-short-style 1)
(defconstant ns:ns-date-interval-formatter-medium-style 2)
(defconstant ns:ns-date-interval-formatter-long-style 3)
(defconstant ns:ns-date-interval-formatter-full-style 4)

;; NSDecodingFailurePolicy
(defconstant ns:ns-decoding-failure-policy-raise-exception 0)
(defconstant ns:ns-decoding-failure-policy-set-error-and-return 1)

;; NSDirectoryEnumerationOptions
(defconstant ns:ns-directory-enumeration-skips-subdirectory-descendants 1)
(defconstant ns:ns-directory-enumeration-skips-package-descendants 2)
(defconstant ns:ns-directory-enumeration-skips-hidden-files 4)
(defconstant ns:ns-directory-enumeration-includes-directories-post-order 8)
(defconstant ns:ns-directory-enumeration-produces-relative-path-ur-ls 16)

;; NSDistributedNotificationOptions
(defconstant ns:ns-distributed-notification-deliver-immediately 1)
(defconstant ns:ns-distributed-notification-post-to-all-sessions 2)

;; NSEnergyFormatterUnit
(defconstant ns:ns-energy-formatter-unit-joule 11)
(defconstant ns:ns-energy-formatter-unit-kilojoule 14)
(defconstant ns:ns-energy-formatter-unit-calorie 1793)
(defconstant ns:ns-energy-formatter-unit-kilocalorie 1794)

;; NSEnumerationOptions
(defconstant ns:ns-enumeration-concurrent 1)
(defconstant ns:ns-enumeration-reverse 2)

;; NSExpressionType
(defconstant ns:ns-constant-value-expression-type 0)
(defconstant ns:ns-evaluated-object-expression-type 1)
(defconstant ns:ns-variable-expression-type 2)
(defconstant ns:ns-key-path-expression-type 3)
(defconstant ns:ns-function-expression-type 4)
(defconstant ns:ns-union-set-expression-type 5)
(defconstant ns:ns-intersect-set-expression-type 6)
(defconstant ns:ns-minus-set-expression-type 7)
(defconstant ns:ns-subquery-expression-type 13)
(defconstant ns:ns-aggregate-expression-type 14)
(defconstant ns:ns-any-key-expression-type 15)
(defconstant ns:ns-block-expression-type 19)
(defconstant ns:ns-conditional-expression-type 20)

;; NSFileCoordinatorReadingOptions
(defconstant ns:ns-file-coordinator-reading-without-changes 1)
(defconstant ns:ns-file-coordinator-reading-resolves-symbolic-link 2)
(defconstant ns:ns-file-coordinator-reading-immediately-available-metadata-only 4)
(defconstant ns:ns-file-coordinator-reading-for-uploading 8)

;; NSFileCoordinatorWritingOptions
(defconstant ns:ns-file-coordinator-writing-for-deleting 1)
(defconstant ns:ns-file-coordinator-writing-for-moving 2)
(defconstant ns:ns-file-coordinator-writing-for-merging 4)
(defconstant ns:ns-file-coordinator-writing-for-replacing 8)
(defconstant ns:ns-file-coordinator-writing-content-independent-metadata-only 16)

;; NSFileManagerItemReplacementOptions
(defconstant ns:ns-file-manager-item-replacement-using-new-metadata-only 1)
(defconstant ns:ns-file-manager-item-replacement-without-deleting-backup-item 2)

;; NSFileManagerResumeSyncBehavior
(defconstant ns:ns-file-manager-resume-sync-behavior-preserve-local-changes 0)
(defconstant ns:ns-file-manager-resume-sync-behavior-after-upload-with-fail-on-conflict 1)
(defconstant ns:ns-file-manager-resume-sync-behavior-drop-local-changes 2)

;; NSFileManagerSupportedSyncControls
(defconstant ns:ns-file-manager-supported-sync-controls-pause-sync 1)
(defconstant ns:ns-file-manager-supported-sync-controls-fail-upload-on-conflict 2)

;; NSFileManagerUnmountOptions
(defconstant ns:ns-file-manager-unmount-all-partitions-and-eject-disk 1)
(defconstant ns:ns-file-manager-unmount-without-ui 2)

;; NSFileManagerUploadLocalVersionConflictPolicy
(defconstant ns:ns-file-manager-upload-conflict-policy-default 0)
(defconstant ns:ns-file-manager-upload-conflict-policy-fail-on-conflict 1)

;; NSFileVersionAddingOptions
(defconstant ns:ns-file-version-adding-by-moving 1)

;; NSFileVersionReplacingOptions
(defconstant ns:ns-file-version-replacing-by-moving 1)

;; NSFileWrapperReadingOptions
(defconstant ns:ns-file-wrapper-reading-immediate 1)
(defconstant ns:ns-file-wrapper-reading-without-mapping 2)

;; NSFileWrapperWritingOptions
(defconstant ns:ns-file-wrapper-writing-atomic 1)
(defconstant ns:ns-file-wrapper-writing-with-name-updating 2)

;; NSFormattingContext
(defconstant ns:ns-formatting-context-unknown 0)
(defconstant ns:ns-formatting-context-dynamic 1)
(defconstant ns:ns-formatting-context-standalone 2)
(defconstant ns:ns-formatting-context-list-item 3)
(defconstant ns:ns-formatting-context-beginning-of-sentence 4)
(defconstant ns:ns-formatting-context-middle-of-sentence 5)

;; NSFormattingUnitStyle
(defconstant ns:ns-formatting-unit-style-short 1)
(defconstant ns:ns-formatting-unit-style-medium 2)
(defconstant ns:ns-formatting-unit-style-long 3)

;; NSGrammaticalCase
(defconstant ns:ns-grammatical-case-not-set 0)
(defconstant ns:ns-grammatical-case-nominative 1)
(defconstant ns:ns-grammatical-case-accusative 2)
(defconstant ns:ns-grammatical-case-dative 3)
(defconstant ns:ns-grammatical-case-genitive 4)
(defconstant ns:ns-grammatical-case-prepositional 5)
(defconstant ns:ns-grammatical-case-ablative 6)
(defconstant ns:ns-grammatical-case-adessive 7)
(defconstant ns:ns-grammatical-case-allative 8)
(defconstant ns:ns-grammatical-case-elative 9)
(defconstant ns:ns-grammatical-case-illative 10)
(defconstant ns:ns-grammatical-case-essive 11)
(defconstant ns:ns-grammatical-case-inessive 12)
(defconstant ns:ns-grammatical-case-locative 13)
(defconstant ns:ns-grammatical-case-translative 14)

;; NSGrammaticalDefiniteness
(defconstant ns:ns-grammatical-definiteness-not-set 0)
(defconstant ns:ns-grammatical-definiteness-indefinite 1)
(defconstant ns:ns-grammatical-definiteness-definite 2)

;; NSGrammaticalDetermination
(defconstant ns:ns-grammatical-determination-not-set 0)
(defconstant ns:ns-grammatical-determination-independent 1)
(defconstant ns:ns-grammatical-determination-dependent 2)

;; NSGrammaticalGender
(defconstant ns:ns-grammatical-gender-not-set 0)
(defconstant ns:ns-grammatical-gender-feminine 1)
(defconstant ns:ns-grammatical-gender-masculine 2)
(defconstant ns:ns-grammatical-gender-neuter 3)

;; NSGrammaticalNumber
(defconstant ns:ns-grammatical-number-not-set 0)
(defconstant ns:ns-grammatical-number-singular 1)
(defconstant ns:ns-grammatical-number-zero 2)
(defconstant ns:ns-grammatical-number-plural 3)
(defconstant ns:ns-grammatical-number-plural-two 4)
(defconstant ns:ns-grammatical-number-plural-few 5)
(defconstant ns:ns-grammatical-number-plural-many 6)

;; NSGrammaticalPartOfSpeech
(defconstant ns:ns-grammatical-part-of-speech-not-set 0)
(defconstant ns:ns-grammatical-part-of-speech-determiner 1)
(defconstant ns:ns-grammatical-part-of-speech-pronoun 2)
(defconstant ns:ns-grammatical-part-of-speech-letter 3)
(defconstant ns:ns-grammatical-part-of-speech-adverb 4)
(defconstant ns:ns-grammatical-part-of-speech-particle 5)
(defconstant ns:ns-grammatical-part-of-speech-adjective 6)
(defconstant ns:ns-grammatical-part-of-speech-adposition 7)
(defconstant ns:ns-grammatical-part-of-speech-verb 8)
(defconstant ns:ns-grammatical-part-of-speech-noun 9)
(defconstant ns:ns-grammatical-part-of-speech-conjunction 10)
(defconstant ns:ns-grammatical-part-of-speech-numeral 11)
(defconstant ns:ns-grammatical-part-of-speech-interjection 12)
(defconstant ns:ns-grammatical-part-of-speech-preposition 13)
(defconstant ns:ns-grammatical-part-of-speech-abbreviation 14)

;; NSGrammaticalPerson
(defconstant ns:ns-grammatical-person-not-set 0)
(defconstant ns:ns-grammatical-person-first 1)
(defconstant ns:ns-grammatical-person-second 2)
(defconstant ns:ns-grammatical-person-third 3)

;; NSGrammaticalPronounType
(defconstant ns:ns-grammatical-pronoun-type-not-set 0)
(defconstant ns:ns-grammatical-pronoun-type-personal 1)
(defconstant ns:ns-grammatical-pronoun-type-reflexive 2)
(defconstant ns:ns-grammatical-pronoun-type-possessive 3)

;; NSHTTPCookieAcceptPolicy
(defconstant ns:ns-http-cookie-accept-policy-always 0)
(defconstant ns:ns-http-cookie-accept-policy-never 1)
(defconstant ns:ns-http-cookie-accept-policy-only-from-main-document-domain 2)

;; NSISO8601DateFormatOptions
(defconstant ns:ns-iso8601-date-format-with-year 1)
(defconstant ns:ns-iso8601-date-format-with-month 2)
(defconstant ns:ns-iso8601-date-format-with-week-of-year 4)
(defconstant ns:ns-iso8601-date-format-with-day 16)
(defconstant ns:ns-iso8601-date-format-with-time 32)
(defconstant ns:ns-iso8601-date-format-with-time-zone 64)
(defconstant ns:ns-iso8601-date-format-with-space-between-date-and-time 128)
(defconstant ns:ns-iso8601-date-format-with-dash-separator-in-date 256)
(defconstant ns:ns-iso8601-date-format-with-colon-separator-in-time 512)
(defconstant ns:ns-iso8601-date-format-with-colon-separator-in-time-zone 1024)
(defconstant ns:ns-iso8601-date-format-with-fractional-seconds 2048)
(defconstant ns:ns-iso8601-date-format-with-full-date 275)
(defconstant ns:ns-iso8601-date-format-with-full-time 1632)
(defconstant ns:ns-iso8601-date-format-with-internet-date-time 1907)

;; NSInlinePresentationIntent
(defconstant ns:ns-inline-presentation-intent-emphasized 1)
(defconstant ns:ns-inline-presentation-intent-strongly-emphasized 2)
(defconstant ns:ns-inline-presentation-intent-code 4)
(defconstant ns:ns-inline-presentation-intent-strikethrough 32)
(defconstant ns:ns-inline-presentation-intent-soft-break 64)
(defconstant ns:ns-inline-presentation-intent-line-break 128)
(defconstant ns:ns-inline-presentation-intent-inline-html 256)
(defconstant ns:ns-inline-presentation-intent-block-html 512)

;; NSInsertionPosition
(defconstant ns:ns-position-after 0)
(defconstant ns:ns-position-before 1)
(defconstant ns:ns-position-beginning 2)
(defconstant ns:ns-position-end 3)
(defconstant ns:ns-position-replace 4)

;; NSItemProviderErrorCode
(defconstant ns:ns-item-provider-unknown-error -1)
(defconstant ns:ns-item-provider-item-unavailable-error -1000)
(defconstant ns:ns-item-provider-unexpected-value-class-error -1100)
(defconstant ns:ns-item-provider-unavailable-coercion-error -1200)

;; NSItemProviderFileOptions
(defconstant ns:ns-item-provider-file-option-open-in-place 1)

;; NSItemProviderRepresentationVisibility
(defconstant ns:ns-item-provider-representation-visibility-all 0)
(defconstant ns:ns-item-provider-representation-visibility-team 1)
(defconstant ns:ns-item-provider-representation-visibility-group 2)
(defconstant ns:ns-item-provider-representation-visibility-own-process 3)

;; NSJSONReadingOptions
(defconstant ns:ns-json-reading-mutable-containers 1)
(defconstant ns:ns-json-reading-mutable-leaves 2)
(defconstant ns:ns-json-reading-fragments-allowed 4)
(defconstant ns:ns-json-reading-json5-allowed 8)
(defconstant ns:ns-json-reading-top-level-dictionary-assumed 16)
(defconstant ns:ns-json-reading-allow-fragments 4)

;; NSJSONWritingOptions
(defconstant ns:ns-json-writing-pretty-printed 1)
(defconstant ns:ns-json-writing-sorted-keys 2)
(defconstant ns:ns-json-writing-fragments-allowed 4)
(defconstant ns:ns-json-writing-without-escaping-slashes 8)

;; NSKeyValueChange
(defconstant ns:ns-key-value-change-setting 1)
(defconstant ns:ns-key-value-change-insertion 2)
(defconstant ns:ns-key-value-change-removal 3)
(defconstant ns:ns-key-value-change-replacement 4)

;; NSKeyValueObservingOptions
(defconstant ns:ns-key-value-observing-option-new 1)
(defconstant ns:ns-key-value-observing-option-old 2)
(defconstant ns:ns-key-value-observing-option-initial 4)
(defconstant ns:ns-key-value-observing-option-prior 8)

;; NSKeyValueSetMutationKind
(defconstant ns:ns-key-value-union-set-mutation 1)
(defconstant ns:ns-key-value-minus-set-mutation 2)
(defconstant ns:ns-key-value-intersect-set-mutation 3)
(defconstant ns:ns-key-value-set-set-mutation 4)

;; NSLengthFormatterUnit
(defconstant ns:ns-length-formatter-unit-millimeter 8)
(defconstant ns:ns-length-formatter-unit-centimeter 9)
(defconstant ns:ns-length-formatter-unit-meter 11)
(defconstant ns:ns-length-formatter-unit-kilometer 14)
(defconstant ns:ns-length-formatter-unit-inch 1281)
(defconstant ns:ns-length-formatter-unit-foot 1282)
(defconstant ns:ns-length-formatter-unit-yard 1283)
(defconstant ns:ns-length-formatter-unit-mile 1284)

;; NSLinguisticTaggerOptions
(defconstant ns:ns-linguistic-tagger-omit-words 1)
(defconstant ns:ns-linguistic-tagger-omit-punctuation 2)
(defconstant ns:ns-linguistic-tagger-omit-whitespace 4)
(defconstant ns:ns-linguistic-tagger-omit-other 8)
(defconstant ns:ns-linguistic-tagger-join-names 16)

;; NSLinguisticTaggerUnit
(defconstant ns:ns-linguistic-tagger-unit-word 0)
(defconstant ns:ns-linguistic-tagger-unit-sentence 1)
(defconstant ns:ns-linguistic-tagger-unit-paragraph 2)
(defconstant ns:ns-linguistic-tagger-unit-document 3)

;; NSLocaleLanguageDirection
(defconstant ns:ns-locale-language-direction-unknown 0)
(defconstant ns:ns-locale-language-direction-left-to-right 1)
(defconstant ns:ns-locale-language-direction-right-to-left 2)
(defconstant ns:ns-locale-language-direction-top-to-bottom 3)
(defconstant ns:ns-locale-language-direction-bottom-to-top 4)

;; NSMachPortOptions
(defconstant ns:ns-mach-port-deallocate-none 0)
(defconstant ns:ns-mach-port-deallocate-send-right 1)
(defconstant ns:ns-mach-port-deallocate-receive-right 2)

;; NSMassFormatterUnit
(defconstant ns:ns-mass-formatter-unit-gram 11)
(defconstant ns:ns-mass-formatter-unit-kilogram 14)
(defconstant ns:ns-mass-formatter-unit-ounce 1537)
(defconstant ns:ns-mass-formatter-unit-pound 1538)
(defconstant ns:ns-mass-formatter-unit-stone 1539)

;; NSMatchingFlags
(defconstant ns:ns-matching-progress 1)
(defconstant ns:ns-matching-completed 2)
(defconstant ns:ns-matching-hit-end 4)
(defconstant ns:ns-matching-required-end 8)
(defconstant ns:ns-matching-internal-error 16)

;; NSMatchingOptions
(defconstant ns:ns-matching-report-progress 1)
(defconstant ns:ns-matching-report-completion 2)
(defconstant ns:ns-matching-anchored 4)
(defconstant ns:ns-matching-with-transparent-bounds 8)
(defconstant ns:ns-matching-without-anchoring-bounds 16)

;; NSMeasurementFormatterUnitOptions
(defconstant ns:ns-measurement-formatter-unit-options-provided-unit 1)
(defconstant ns:ns-measurement-formatter-unit-options-natural-scale 2)
(defconstant ns:ns-measurement-formatter-unit-options-temperature-without-unit 4)

;; NSNetServiceOptions
(defconstant ns:ns-net-service-no-auto-rename 1)
(defconstant ns:ns-net-service-listen-for-connections 2)

;; NSNetServicesError
(defconstant ns:ns-net-services-unknown-error -72000)
(defconstant ns:ns-net-services-collision-error -72001)
(defconstant ns:ns-net-services-not-found-error -72002)
(defconstant ns:ns-net-services-activity-in-progress -72003)
(defconstant ns:ns-net-services-bad-argument-error -72004)
(defconstant ns:ns-net-services-cancelled-error -72005)
(defconstant ns:ns-net-services-invalid-error -72006)
(defconstant ns:ns-net-services-timeout-error -72007)
(defconstant ns:ns-net-services-missing-required-configuration-error -72008)

;; NSNotificationCoalescing
(defconstant ns:ns-notification-no-coalescing 0)
(defconstant ns:ns-notification-coalescing-on-name 1)
(defconstant ns:ns-notification-coalescing-on-sender 2)

;; NSNotificationSuspensionBehavior
(defconstant ns:ns-notification-suspension-behavior-drop 1)
(defconstant ns:ns-notification-suspension-behavior-coalesce 2)
(defconstant ns:ns-notification-suspension-behavior-hold 3)
(defconstant ns:ns-notification-suspension-behavior-deliver-immediately 4)

;; NSNumberFormatterBehavior
(defconstant ns:ns-number-formatter-behavior-default 0)
(defconstant ns:ns-number-formatter-behavior10-0 1000)
(defconstant ns:ns-number-formatter-behavior10-4 1040)

;; NSNumberFormatterPadPosition
(defconstant ns:ns-number-formatter-pad-before-prefix 0)
(defconstant ns:ns-number-formatter-pad-after-prefix 1)
(defconstant ns:ns-number-formatter-pad-before-suffix 2)
(defconstant ns:ns-number-formatter-pad-after-suffix 3)

;; NSNumberFormatterRoundingMode
(defconstant ns:ns-number-formatter-round-ceiling 0)
(defconstant ns:ns-number-formatter-round-floor 1)
(defconstant ns:ns-number-formatter-round-down 2)
(defconstant ns:ns-number-formatter-round-up 3)
(defconstant ns:ns-number-formatter-round-half-even 4)
(defconstant ns:ns-number-formatter-round-half-down 5)
(defconstant ns:ns-number-formatter-round-half-up 6)

;; NSNumberFormatterStyle
(defconstant ns:ns-number-formatter-no-style 0)
(defconstant ns:ns-number-formatter-decimal-style 1)
(defconstant ns:ns-number-formatter-currency-style 2)
(defconstant ns:ns-number-formatter-percent-style 3)
(defconstant ns:ns-number-formatter-scientific-style 4)
(defconstant ns:ns-number-formatter-spell-out-style 5)
(defconstant ns:ns-number-formatter-ordinal-style 6)
(defconstant ns:ns-number-formatter-currency-iso-code-style 8)
(defconstant ns:ns-number-formatter-currency-plural-style 9)
(defconstant ns:ns-number-formatter-currency-accounting-style 10)

;; NSOperationQueuePriority
(defconstant ns:ns-operation-queue-priority-very-low -8)
(defconstant ns:ns-operation-queue-priority-low -4)
(defconstant ns:ns-operation-queue-priority-normal 0)
(defconstant ns:ns-operation-queue-priority-high 4)
(defconstant ns:ns-operation-queue-priority-very-high 8)

;; NSOrderedCollectionDifferenceCalculationOptions
(defconstant ns:ns-ordered-collection-difference-calculation-omit-inserted-objects 1)
(defconstant ns:ns-ordered-collection-difference-calculation-omit-removed-objects 2)
(defconstant ns:ns-ordered-collection-difference-calculation-infer-moves 4)

;; NSPersonNameComponentsFormatterOptions
(defconstant ns:ns-person-name-components-formatter-phonetic 2)

;; NSPersonNameComponentsFormatterStyle
(defconstant ns:ns-person-name-components-formatter-style-default 0)
(defconstant ns:ns-person-name-components-formatter-style-short 1)
(defconstant ns:ns-person-name-components-formatter-style-medium 2)
(defconstant ns:ns-person-name-components-formatter-style-long 3)
(defconstant ns:ns-person-name-components-formatter-style-abbreviated 4)

;; NSPointerFunctionsOptions
(defconstant ns:ns-pointer-functions-strong-memory 0)
(defconstant ns:ns-pointer-functions-zeroing-weak-memory 1)
(defconstant ns:ns-pointer-functions-opaque-memory 2)
(defconstant ns:ns-pointer-functions-malloc-memory 3)
(defconstant ns:ns-pointer-functions-mach-virtual-memory 4)
(defconstant ns:ns-pointer-functions-weak-memory 5)
(defconstant ns:ns-pointer-functions-object-personality 0)
(defconstant ns:ns-pointer-functions-opaque-personality 256)
(defconstant ns:ns-pointer-functions-object-pointer-personality 512)
(defconstant ns:ns-pointer-functions-c-string-personality 768)
(defconstant ns:ns-pointer-functions-struct-personality 1024)
(defconstant ns:ns-pointer-functions-integer-personality 1280)
(defconstant ns:ns-pointer-functions-copy-in 65536)

;; NSPostingStyle
(defconstant ns:ns-post-when-idle 1)
(defconstant ns:ns-post-asap 2)
(defconstant ns:ns-post-now 3)

;; NSPredicateOperatorType
(defconstant ns:ns-less-than-predicate-operator-type 0)
(defconstant ns:ns-less-than-or-equal-to-predicate-operator-type 1)
(defconstant ns:ns-greater-than-predicate-operator-type 2)
(defconstant ns:ns-greater-than-or-equal-to-predicate-operator-type 3)
(defconstant ns:ns-equal-to-predicate-operator-type 4)
(defconstant ns:ns-not-equal-to-predicate-operator-type 5)
(defconstant ns:ns-matches-predicate-operator-type 6)
(defconstant ns:ns-like-predicate-operator-type 7)
(defconstant ns:ns-begins-with-predicate-operator-type 8)
(defconstant ns:ns-ends-with-predicate-operator-type 9)
(defconstant ns:ns-in-predicate-operator-type 10)
(defconstant ns:ns-custom-selector-predicate-operator-type 11)
(defconstant ns:ns-contains-predicate-operator-type 99)
(defconstant ns:ns-between-predicate-operator-type 100)

;; NSPresentationIntentKind
(defconstant ns:ns-presentation-intent-kind-paragraph 0)
(defconstant ns:ns-presentation-intent-kind-header 1)
(defconstant ns:ns-presentation-intent-kind-ordered-list 2)
(defconstant ns:ns-presentation-intent-kind-unordered-list 3)
(defconstant ns:ns-presentation-intent-kind-list-item 4)
(defconstant ns:ns-presentation-intent-kind-code-block 5)
(defconstant ns:ns-presentation-intent-kind-block-quote 6)
(defconstant ns:ns-presentation-intent-kind-thematic-break 7)
(defconstant ns:ns-presentation-intent-kind-table 8)
(defconstant ns:ns-presentation-intent-kind-table-header-row 9)
(defconstant ns:ns-presentation-intent-kind-table-row 10)
(defconstant ns:ns-presentation-intent-kind-table-cell 11)

;; NSPresentationIntentTableColumnAlignment
(defconstant ns:ns-presentation-intent-table-column-alignment-left 0)
(defconstant ns:ns-presentation-intent-table-column-alignment-center 1)
(defconstant ns:ns-presentation-intent-table-column-alignment-right 2)

;; NSProcessInfoThermalState
(defconstant ns:ns-process-info-thermal-state-nominal 0)
(defconstant ns:ns-process-info-thermal-state-fair 1)
(defconstant ns:ns-process-info-thermal-state-serious 2)
(defconstant ns:ns-process-info-thermal-state-critical 3)

;; NSPropertyListFormat
(defconstant ns:ns-property-list-open-step-format 1)
(defconstant ns:ns-property-list-xml-format-v1-0 100)
(defconstant ns:ns-property-list-binary-format-v1-0 200)

;; NSPropertyListMutabilityOptions
(defconstant ns:ns-property-list-immutable 0)
(defconstant ns:ns-property-list-mutable-containers 1)
(defconstant ns:ns-property-list-mutable-containers-and-leaves 2)

;; NSQualityOfService
(defconstant ns:ns-quality-of-service-user-interactive 33)
(defconstant ns:ns-quality-of-service-user-initiated 25)
(defconstant ns:ns-quality-of-service-utility 17)
(defconstant ns:ns-quality-of-service-background 9)
(defconstant ns:ns-quality-of-service-default -1)

;; NSRectEdge
(defconstant ns:ns-rect-edge-min-x 0)
(defconstant ns:ns-rect-edge-min-y 1)
(defconstant ns:ns-rect-edge-max-x 2)
(defconstant ns:ns-rect-edge-max-y 3)
(defconstant ns:ns-min-x-edge 0)
(defconstant ns:ns-min-y-edge 1)
(defconstant ns:ns-max-x-edge 2)
(defconstant ns:ns-max-y-edge 3)

;; NSRegularExpressionOptions
(defconstant ns:ns-regular-expression-case-insensitive 1)
(defconstant ns:ns-regular-expression-allow-comments-and-whitespace 2)
(defconstant ns:ns-regular-expression-ignore-metacharacters 4)
(defconstant ns:ns-regular-expression-dot-matches-line-separators 8)
(defconstant ns:ns-regular-expression-anchors-match-lines 16)
(defconstant ns:ns-regular-expression-use-unix-line-separators 32)
(defconstant ns:ns-regular-expression-use-unicode-word-boundaries 64)

;; NSRelativeDateTimeFormatterStyle
(defconstant ns:ns-relative-date-time-formatter-style-numeric 0)
(defconstant ns:ns-relative-date-time-formatter-style-named 1)

;; NSRelativeDateTimeFormatterUnitsStyle
(defconstant ns:ns-relative-date-time-formatter-units-style-full 0)
(defconstant ns:ns-relative-date-time-formatter-units-style-spell-out 1)
(defconstant ns:ns-relative-date-time-formatter-units-style-short 2)
(defconstant ns:ns-relative-date-time-formatter-units-style-abbreviated 3)

;; NSRelativePosition
(defconstant ns:ns-relative-after 0)
(defconstant ns:ns-relative-before 1)

;; NSRoundingMode
(defconstant ns:ns-round-plain 0)
(defconstant ns:ns-round-down 1)
(defconstant ns:ns-round-up 2)
(defconstant ns:ns-round-bankers 3)

;; NSSaveOptions
(defconstant ns:ns-save-options-yes 0)
(defconstant ns:ns-save-options-no 1)
(defconstant ns:ns-save-options-ask 2)

;; NSSearchPathDirectory
(defconstant ns:ns-application-directory 1)
(defconstant ns:ns-demo-application-directory 2)
(defconstant ns:ns-developer-application-directory 3)
(defconstant ns:ns-admin-application-directory 4)
(defconstant ns:ns-library-directory 5)
(defconstant ns:ns-developer-directory 6)
(defconstant ns:ns-user-directory 7)
(defconstant ns:ns-documentation-directory 8)
(defconstant ns:ns-document-directory 9)
(defconstant ns:ns-core-service-directory 10)
(defconstant ns:ns-autosaved-information-directory 11)
(defconstant ns:ns-desktop-directory 12)
(defconstant ns:ns-caches-directory 13)
(defconstant ns:ns-application-support-directory 14)
(defconstant ns:ns-downloads-directory 15)
(defconstant ns:ns-input-methods-directory 16)
(defconstant ns:ns-movies-directory 17)
(defconstant ns:ns-music-directory 18)
(defconstant ns:ns-pictures-directory 19)
(defconstant ns:ns-printer-description-directory 20)
(defconstant ns:ns-shared-public-directory 21)
(defconstant ns:ns-preference-panes-directory 22)
(defconstant ns:ns-application-scripts-directory 23)
(defconstant ns:ns-item-replacement-directory 99)
(defconstant ns:ns-all-applications-directory 100)
(defconstant ns:ns-all-libraries-directory 101)
(defconstant ns:ns-trash-directory 102)

;; NSSearchPathDomainMask
(defconstant ns:ns-user-domain-mask 1)
(defconstant ns:ns-local-domain-mask 2)
(defconstant ns:ns-network-domain-mask 4)
(defconstant ns:ns-system-domain-mask 8)
(defconstant ns:ns-all-domains-mask 65535)

;; NSSortOptions
(defconstant ns:ns-sort-concurrent 1)
(defconstant ns:ns-sort-stable 16)

;; NSStreamEvent
(defconstant ns:ns-stream-event-none 0)
(defconstant ns:ns-stream-event-open-completed 1)
(defconstant ns:ns-stream-event-has-bytes-available 2)
(defconstant ns:ns-stream-event-has-space-available 4)
(defconstant ns:ns-stream-event-error-occurred 8)
(defconstant ns:ns-stream-event-end-encountered 16)

;; NSStreamStatus
(defconstant ns:ns-stream-status-not-open 0)
(defconstant ns:ns-stream-status-opening 1)
(defconstant ns:ns-stream-status-open 2)
(defconstant ns:ns-stream-status-reading 3)
(defconstant ns:ns-stream-status-writing 4)
(defconstant ns:ns-stream-status-at-end 5)
(defconstant ns:ns-stream-status-closed 6)
(defconstant ns:ns-stream-status-error 7)

;; NSStringCompareOptions
(defconstant ns:ns-case-insensitive-search 1)
(defconstant ns:ns-literal-search 2)
(defconstant ns:ns-backwards-search 4)
(defconstant ns:ns-anchored-search 8)
(defconstant ns:ns-numeric-search 64)
(defconstant ns:ns-diacritic-insensitive-search 128)
(defconstant ns:ns-width-insensitive-search 256)
(defconstant ns:ns-forced-ordering-search 512)
(defconstant ns:ns-regular-expression-search 1024)

;; NSStringEncodingConversionOptions
(defconstant ns:ns-string-encoding-conversion-allow-lossy 1)
(defconstant ns:ns-string-encoding-conversion-external-representation 2)

;; NSStringEnumerationOptions
(defconstant ns:ns-string-enumeration-by-lines 0)
(defconstant ns:ns-string-enumeration-by-paragraphs 1)
(defconstant ns:ns-string-enumeration-by-composed-character-sequences 2)
(defconstant ns:ns-string-enumeration-by-words 3)
(defconstant ns:ns-string-enumeration-by-sentences 4)
(defconstant ns:ns-string-enumeration-by-caret-positions 5)
(defconstant ns:ns-string-enumeration-by-deletion-clusters 6)
(defconstant ns:ns-string-enumeration-reverse 256)
(defconstant ns:ns-string-enumeration-substring-not-required 512)
(defconstant ns:ns-string-enumeration-localized 1024)

;; NSTaskTerminationReason
(defconstant ns:ns-task-termination-reason-exit 1)
(defconstant ns:ns-task-termination-reason-uncaught-signal 2)

;; NSTestComparisonOperation
(defconstant ns:ns-equal-to-comparison 0)
(defconstant ns:ns-less-than-or-equal-to-comparison 1)
(defconstant ns:ns-less-than-comparison 2)
(defconstant ns:ns-greater-than-or-equal-to-comparison 3)
(defconstant ns:ns-greater-than-comparison 4)
(defconstant ns:ns-begins-with-comparison 5)
(defconstant ns:ns-ends-with-comparison 6)
(defconstant ns:ns-contains-comparison 7)

;; NSTextCheckingType
(defconstant ns:ns-text-checking-type-orthography 1)
(defconstant ns:ns-text-checking-type-spelling 2)
(defconstant ns:ns-text-checking-type-grammar 4)
(defconstant ns:ns-text-checking-type-date 8)
(defconstant ns:ns-text-checking-type-address 16)
(defconstant ns:ns-text-checking-type-link 32)
(defconstant ns:ns-text-checking-type-quote 64)
(defconstant ns:ns-text-checking-type-dash 128)
(defconstant ns:ns-text-checking-type-replacement 256)
(defconstant ns:ns-text-checking-type-correction 512)
(defconstant ns:ns-text-checking-type-regular-expression 1024)
(defconstant ns:ns-text-checking-type-phone-number 2048)
(defconstant ns:ns-text-checking-type-transit-information 4096)

;; NSTimeZoneNameStyle
(defconstant ns:ns-time-zone-name-style-standard 0)
(defconstant ns:ns-time-zone-name-style-short-standard 1)
(defconstant ns:ns-time-zone-name-style-daylight-saving 2)
(defconstant ns:ns-time-zone-name-style-short-daylight-saving 3)
(defconstant ns:ns-time-zone-name-style-generic 4)
(defconstant ns:ns-time-zone-name-style-short-generic 5)

;; NSURLBookmarkCreationOptions
(defconstant ns:ns-url-bookmark-creation-prefer-file-id-resolution 256)
(defconstant ns:ns-url-bookmark-creation-minimal-bookmark 512)
(defconstant ns:ns-url-bookmark-creation-suitable-for-bookmark-file 1024)
(defconstant ns:ns-url-bookmark-creation-with-security-scope 2048)
(defconstant ns:ns-url-bookmark-creation-security-scope-allow-only-read-access 4096)
(defconstant ns:ns-url-bookmark-creation-without-implicit-security-scope 536870912)

;; NSURLBookmarkResolutionOptions
(defconstant ns:ns-url-bookmark-resolution-without-ui 256)
(defconstant ns:ns-url-bookmark-resolution-without-mounting 512)
(defconstant ns:ns-url-bookmark-resolution-with-security-scope 1024)
(defconstant ns:ns-url-bookmark-resolution-without-implicit-start-accessing 32768)

;; NSURLCacheStoragePolicy
(defconstant ns:ns-url-cache-storage-allowed 0)
(defconstant ns:ns-url-cache-storage-allowed-in-memory-only 1)
(defconstant ns:ns-url-cache-storage-not-allowed 2)

;; NSURLCredentialPersistence
(defconstant ns:ns-url-credential-persistence-none 0)
(defconstant ns:ns-url-credential-persistence-for-session 1)
(defconstant ns:ns-url-credential-persistence-permanent 2)
(defconstant ns:ns-url-credential-persistence-synchronizable 3)

;; NSURLErrorNetworkUnavailableReason
(defconstant ns:ns-url-error-network-unavailable-reason-cellular 0)
(defconstant ns:ns-url-error-network-unavailable-reason-expensive 1)
(defconstant ns:ns-url-error-network-unavailable-reason-constrained 2)
(defconstant ns:ns-url-error-network-unavailable-reason-ultra-constrained 3)

;; NSURLHandleStatus
(defconstant ns:ns-url-handle-not-loaded 0)
(defconstant ns:ns-url-handle-load-succeeded 1)
(defconstant ns:ns-url-handle-load-in-progress 2)
(defconstant ns:ns-url-handle-load-failed 3)

;; NSURLRelationship
(defconstant ns:ns-url-relationship-contains 0)
(defconstant ns:ns-url-relationship-same 1)
(defconstant ns:ns-url-relationship-other 2)

;; NSURLRequestAttribution
(defconstant ns:ns-url-request-attribution-developer 0)
(defconstant ns:ns-url-request-attribution-user 1)

;; NSURLRequestCachePolicy
(defconstant ns:ns-url-request-use-protocol-cache-policy 0)
(defconstant ns:ns-url-request-reload-ignoring-local-cache-data 1)
(defconstant ns:ns-url-request-reload-ignoring-local-and-remote-cache-data 4)
(defconstant ns:ns-url-request-reload-ignoring-cache-data 1)
(defconstant ns:ns-url-request-return-cache-data-else-load 2)
(defconstant ns:ns-url-request-return-cache-data-dont-load 3)
(defconstant ns:ns-url-request-reload-revalidating-cache-data 5)

;; NSURLRequestNetworkServiceType
(defconstant ns:ns-url-network-service-type-default 0)
(defconstant ns:ns-url-network-service-type-vo-ip 1)
(defconstant ns:ns-url-network-service-type-video 2)
(defconstant ns:ns-url-network-service-type-background 3)
(defconstant ns:ns-url-network-service-type-voice 4)
(defconstant ns:ns-url-network-service-type-responsive-data 6)
(defconstant ns:ns-url-network-service-type-av-streaming 8)
(defconstant ns:ns-url-network-service-type-responsive-av 9)
(defconstant ns:ns-url-network-service-type-call-signaling 11)

;; NSURLSessionAuthChallengeDisposition
(defconstant ns:ns-url-session-auth-challenge-use-credential 0)
(defconstant ns:ns-url-session-auth-challenge-perform-default-handling 1)
(defconstant ns:ns-url-session-auth-challenge-cancel-authentication-challenge 2)
(defconstant ns:ns-url-session-auth-challenge-reject-protection-space 3)

;; NSURLSessionDelayedRequestDisposition
(defconstant ns:ns-url-session-delayed-request-continue-loading 0)
(defconstant ns:ns-url-session-delayed-request-use-new-request 1)
(defconstant ns:ns-url-session-delayed-request-cancel 2)

;; NSURLSessionMultipathServiceType
(defconstant ns:ns-url-session-multipath-service-type-none 0)
(defconstant ns:ns-url-session-multipath-service-type-handover 1)
(defconstant ns:ns-url-session-multipath-service-type-interactive 2)
(defconstant ns:ns-url-session-multipath-service-type-aggregate 3)

;; NSURLSessionResponseDisposition
(defconstant ns:ns-url-session-response-cancel 0)
(defconstant ns:ns-url-session-response-allow 1)
(defconstant ns:ns-url-session-response-become-download 2)
(defconstant ns:ns-url-session-response-become-stream 3)

;; NSURLSessionTaskMetricsDomainResolutionProtocol
(defconstant ns:ns-url-session-task-metrics-domain-resolution-protocol-unknown 0)
(defconstant ns:ns-url-session-task-metrics-domain-resolution-protocol-udp 1)
(defconstant ns:ns-url-session-task-metrics-domain-resolution-protocol-tcp 2)
(defconstant ns:ns-url-session-task-metrics-domain-resolution-protocol-tls 3)
(defconstant ns:ns-url-session-task-metrics-domain-resolution-protocol-https 4)

;; NSURLSessionTaskMetricsResourceFetchType
(defconstant ns:ns-url-session-task-metrics-resource-fetch-type-unknown 0)
(defconstant ns:ns-url-session-task-metrics-resource-fetch-type-network-load 1)
(defconstant ns:ns-url-session-task-metrics-resource-fetch-type-server-push 2)
(defconstant ns:ns-url-session-task-metrics-resource-fetch-type-local-cache 3)

;; NSURLSessionTaskState
(defconstant ns:ns-url-session-task-state-running 0)
(defconstant ns:ns-url-session-task-state-suspended 1)
(defconstant ns:ns-url-session-task-state-canceling 2)
(defconstant ns:ns-url-session-task-state-completed 3)

;; NSURLSessionWebSocketCloseCode
(defconstant ns:ns-url-session-web-socket-close-code-invalid 0)
(defconstant ns:ns-url-session-web-socket-close-code-normal-closure 1000)
(defconstant ns:ns-url-session-web-socket-close-code-going-away 1001)
(defconstant ns:ns-url-session-web-socket-close-code-protocol-error 1002)
(defconstant ns:ns-url-session-web-socket-close-code-unsupported-data 1003)
(defconstant ns:ns-url-session-web-socket-close-code-no-status-received 1005)
(defconstant ns:ns-url-session-web-socket-close-code-abnormal-closure 1006)
(defconstant ns:ns-url-session-web-socket-close-code-invalid-frame-payload-data 1007)
(defconstant ns:ns-url-session-web-socket-close-code-policy-violation 1008)
(defconstant ns:ns-url-session-web-socket-close-code-message-too-big 1009)
(defconstant ns:ns-url-session-web-socket-close-code-mandatory-extension-missing 1010)
(defconstant ns:ns-url-session-web-socket-close-code-internal-server-error 1011)
(defconstant ns:ns-url-session-web-socket-close-code-tls-handshake-failure 1015)

;; NSURLSessionWebSocketMessageType
(defconstant ns:ns-url-session-web-socket-message-type-data 0)
(defconstant ns:ns-url-session-web-socket-message-type-string 1)

;; NSUserNotificationActivationType
(defconstant ns:ns-user-notification-activation-type-none 0)
(defconstant ns:ns-user-notification-activation-type-contents-clicked 1)
(defconstant ns:ns-user-notification-activation-type-action-button-clicked 2)
(defconstant ns:ns-user-notification-activation-type-replied 3)
(defconstant ns:ns-user-notification-activation-type-additional-action-clicked 4)

;; NSVolumeEnumerationOptions
(defconstant ns:ns-volume-enumeration-skip-hidden-volumes 2)
(defconstant ns:ns-volume-enumeration-produce-file-reference-ur-ls 4)

;; NSWhoseSubelementIdentifier
(defconstant ns:ns-index-subelement 0)
(defconstant ns:ns-every-subelement 1)
(defconstant ns:ns-middle-subelement 2)
(defconstant ns:ns-random-subelement 3)
(defconstant ns:ns-no-subelement 4)

;; NSXMLDTDNodeKind
(defconstant ns:ns-xml-entity-general-kind 1)
(defconstant ns:ns-xml-entity-parsed-kind 2)
(defconstant ns:ns-xml-entity-unparsed-kind 3)
(defconstant ns:ns-xml-entity-parameter-kind 4)
(defconstant ns:ns-xml-entity-predefined 5)
(defconstant ns:ns-xml-attribute-cdata-kind 6)
(defconstant ns:ns-xml-attribute-id-kind 7)
(defconstant ns:ns-xml-attribute-id-ref-kind 8)
(defconstant ns:ns-xml-attribute-id-refs-kind 9)
(defconstant ns:ns-xml-attribute-entity-kind 10)
(defconstant ns:ns-xml-attribute-entities-kind 11)
(defconstant ns:ns-xml-attribute-nm-token-kind 12)
(defconstant ns:ns-xml-attribute-nm-tokens-kind 13)
(defconstant ns:ns-xml-attribute-enumeration-kind 14)
(defconstant ns:ns-xml-attribute-notation-kind 15)
(defconstant ns:ns-xml-element-declaration-undefined-kind 16)
(defconstant ns:ns-xml-element-declaration-empty-kind 17)
(defconstant ns:ns-xml-element-declaration-any-kind 18)
(defconstant ns:ns-xml-element-declaration-mixed-kind 19)
(defconstant ns:ns-xml-element-declaration-element-kind 20)

;; NSXMLDocumentContentKind
(defconstant ns:ns-xml-document-xml-kind 0)
(defconstant ns:ns-xml-document-x-html-kind 1)
(defconstant ns:ns-xml-document-html-kind 2)
(defconstant ns:ns-xml-document-text-kind 3)

;; NSXMLNodeKind
(defconstant ns:ns-xml-invalid-kind 0)
(defconstant ns:ns-xml-document-kind 1)
(defconstant ns:ns-xml-element-kind 2)
(defconstant ns:ns-xml-attribute-kind 3)
(defconstant ns:ns-xml-namespace-kind 4)
(defconstant ns:ns-xml-processing-instruction-kind 5)
(defconstant ns:ns-xml-comment-kind 6)
(defconstant ns:ns-xml-text-kind 7)
(defconstant ns:ns-xml-dtd-kind 8)
(defconstant ns:ns-xml-entity-declaration-kind 9)
(defconstant ns:ns-xml-attribute-declaration-kind 10)
(defconstant ns:ns-xml-element-declaration-kind 11)
(defconstant ns:ns-xml-notation-declaration-kind 12)

;; NSXMLNodeOptions
(defconstant ns:ns-xml-node-options-none 0)
(defconstant ns:ns-xml-node-is-cdata 1)
(defconstant ns:ns-xml-node-expand-empty-element 2)
(defconstant ns:ns-xml-node-compact-empty-element 4)
(defconstant ns:ns-xml-node-use-single-quotes 8)
(defconstant ns:ns-xml-node-use-double-quotes 16)
(defconstant ns:ns-xml-node-never-escape-contents 32)
(defconstant ns:ns-xml-document-tidy-html 512)
(defconstant ns:ns-xml-document-tidy-xml 1024)
(defconstant ns:ns-xml-document-validate 8192)
(defconstant ns:ns-xml-node-load-external-entities-always 16384)
(defconstant ns:ns-xml-node-load-external-entities-same-origin-only 32768)
(defconstant ns:ns-xml-node-load-external-entities-never 524288)
(defconstant ns:ns-xml-document-x-include 65536)
(defconstant ns:ns-xml-node-pretty-print 131072)
(defconstant ns:ns-xml-document-include-content-type-declaration 262144)
(defconstant ns:ns-xml-node-preserve-namespace-order 1048576)
(defconstant ns:ns-xml-node-preserve-attribute-order 2097152)
(defconstant ns:ns-xml-node-preserve-entities 4194304)
(defconstant ns:ns-xml-node-preserve-prefixes 8388608)
(defconstant ns:ns-xml-node-preserve-cdata 16777216)
(defconstant ns:ns-xml-node-preserve-whitespace 33554432)
(defconstant ns:ns-xml-node-preserve-dtd 67108864)
(defconstant ns:ns-xml-node-preserve-character-references 134217728)
(defconstant ns:ns-xml-node-promote-significant-whitespace 268435456)
(defconstant ns:ns-xml-node-preserve-empty-elements 6)
(defconstant ns:ns-xml-node-preserve-quotes 24)
(defconstant ns:ns-xml-node-preserve-all 4293918750)

;; NSXMLParserError
(defconstant ns:ns-xml-parser-internal-error 1)
(defconstant ns:ns-xml-parser-out-of-memory-error 2)
(defconstant ns:ns-xml-parser-document-start-error 3)
(defconstant ns:ns-xml-parser-empty-document-error 4)
(defconstant ns:ns-xml-parser-premature-document-end-error 5)
(defconstant ns:ns-xml-parser-invalid-hex-character-ref-error 6)
(defconstant ns:ns-xml-parser-invalid-decimal-character-ref-error 7)
(defconstant ns:ns-xml-parser-invalid-character-ref-error 8)
(defconstant ns:ns-xml-parser-invalid-character-error 9)
(defconstant ns:ns-xml-parser-character-ref-at-eof-error 10)
(defconstant ns:ns-xml-parser-character-ref-in-prolog-error 11)
(defconstant ns:ns-xml-parser-character-ref-in-epilog-error 12)
(defconstant ns:ns-xml-parser-character-ref-in-dtd-error 13)
(defconstant ns:ns-xml-parser-entity-ref-at-eof-error 14)
(defconstant ns:ns-xml-parser-entity-ref-in-prolog-error 15)
(defconstant ns:ns-xml-parser-entity-ref-in-epilog-error 16)
(defconstant ns:ns-xml-parser-entity-ref-in-dtd-error 17)
(defconstant ns:ns-xml-parser-parsed-entity-ref-at-eof-error 18)
(defconstant ns:ns-xml-parser-parsed-entity-ref-in-prolog-error 19)
(defconstant ns:ns-xml-parser-parsed-entity-ref-in-epilog-error 20)
(defconstant ns:ns-xml-parser-parsed-entity-ref-in-internal-subset-error 21)
(defconstant ns:ns-xml-parser-entity-reference-without-name-error 22)
(defconstant ns:ns-xml-parser-entity-reference-missing-semi-error 23)
(defconstant ns:ns-xml-parser-parsed-entity-ref-no-name-error 24)
(defconstant ns:ns-xml-parser-parsed-entity-ref-missing-semi-error 25)
(defconstant ns:ns-xml-parser-undeclared-entity-error 26)
(defconstant ns:ns-xml-parser-unparsed-entity-error 28)
(defconstant ns:ns-xml-parser-entity-is-external-error 29)
(defconstant ns:ns-xml-parser-entity-is-parameter-error 30)
(defconstant ns:ns-xml-parser-unknown-encoding-error 31)
(defconstant ns:ns-xml-parser-encoding-not-supported-error 32)
(defconstant ns:ns-xml-parser-string-not-started-error 33)
(defconstant ns:ns-xml-parser-string-not-closed-error 34)
(defconstant ns:ns-xml-parser-namespace-declaration-error 35)
(defconstant ns:ns-xml-parser-entity-not-started-error 36)
(defconstant ns:ns-xml-parser-entity-not-finished-error 37)
(defconstant ns:ns-xml-parser-less-than-symbol-in-attribute-error 38)
(defconstant ns:ns-xml-parser-attribute-not-started-error 39)
(defconstant ns:ns-xml-parser-attribute-not-finished-error 40)
(defconstant ns:ns-xml-parser-attribute-has-no-value-error 41)
(defconstant ns:ns-xml-parser-attribute-redefined-error 42)
(defconstant ns:ns-xml-parser-literal-not-started-error 43)
(defconstant ns:ns-xml-parser-literal-not-finished-error 44)
(defconstant ns:ns-xml-parser-comment-not-finished-error 45)
(defconstant ns:ns-xml-parser-processing-instruction-not-started-error 46)
(defconstant ns:ns-xml-parser-processing-instruction-not-finished-error 47)
(defconstant ns:ns-xml-parser-notation-not-started-error 48)
(defconstant ns:ns-xml-parser-notation-not-finished-error 49)
(defconstant ns:ns-xml-parser-attribute-list-not-started-error 50)
(defconstant ns:ns-xml-parser-attribute-list-not-finished-error 51)
(defconstant ns:ns-xml-parser-mixed-content-decl-not-started-error 52)
(defconstant ns:ns-xml-parser-mixed-content-decl-not-finished-error 53)
(defconstant ns:ns-xml-parser-element-content-decl-not-started-error 54)
(defconstant ns:ns-xml-parser-element-content-decl-not-finished-error 55)
(defconstant ns:ns-xml-parser-xml-decl-not-started-error 56)
(defconstant ns:ns-xml-parser-xml-decl-not-finished-error 57)
(defconstant ns:ns-xml-parser-conditional-section-not-started-error 58)
(defconstant ns:ns-xml-parser-conditional-section-not-finished-error 59)
(defconstant ns:ns-xml-parser-external-subset-not-finished-error 60)
(defconstant ns:ns-xml-parser-doctype-decl-not-finished-error 61)
(defconstant ns:ns-xml-parser-misplaced-cdata-end-string-error 62)
(defconstant ns:ns-xml-parser-cdata-not-finished-error 63)
(defconstant ns:ns-xml-parser-misplaced-xml-declaration-error 64)
(defconstant ns:ns-xml-parser-space-required-error 65)
(defconstant ns:ns-xml-parser-separator-required-error 66)
(defconstant ns:ns-xml-parser-nmtoken-required-error 67)
(defconstant ns:ns-xml-parser-name-required-error 68)
(defconstant ns:ns-xml-parser-pcdata-required-error 69)
(defconstant ns:ns-xml-parser-uri-required-error 70)
(defconstant ns:ns-xml-parser-public-identifier-required-error 71)
(defconstant ns:ns-xml-parser-lt-required-error 72)
(defconstant ns:ns-xml-parser-gt-required-error 73)
(defconstant ns:ns-xml-parser-lt-slash-required-error 74)
(defconstant ns:ns-xml-parser-equal-expected-error 75)
(defconstant ns:ns-xml-parser-tag-name-mismatch-error 76)
(defconstant ns:ns-xml-parser-unfinished-tag-error 77)
(defconstant ns:ns-xml-parser-standalone-value-error 78)
(defconstant ns:ns-xml-parser-invalid-encoding-name-error 79)
(defconstant ns:ns-xml-parser-comment-contains-double-hyphen-error 80)
(defconstant ns:ns-xml-parser-invalid-encoding-error 81)
(defconstant ns:ns-xml-parser-external-standalone-entity-error 82)
(defconstant ns:ns-xml-parser-invalid-conditional-section-error 83)
(defconstant ns:ns-xml-parser-entity-value-required-error 84)
(defconstant ns:ns-xml-parser-not-well-balanced-error 85)
(defconstant ns:ns-xml-parser-extra-content-error 86)
(defconstant ns:ns-xml-parser-invalid-character-in-entity-error 87)
(defconstant ns:ns-xml-parser-parsed-entity-ref-in-internal-error 88)
(defconstant ns:ns-xml-parser-entity-ref-loop-error 89)
(defconstant ns:ns-xml-parser-entity-boundary-error 90)
(defconstant ns:ns-xml-parser-invalid-uri-error 91)
(defconstant ns:ns-xml-parser-uri-fragment-error 92)
(defconstant ns:ns-xml-parser-no-dtd-error 94)
(defconstant ns:ns-xml-parser-delegate-aborted-parse-error 512)

;; NSXMLParserExternalEntityResolvingPolicy
(defconstant ns:ns-xml-parser-resolve-external-entities-never 0)
(defconstant ns:ns-xml-parser-resolve-external-entities-no-network 1)
(defconstant ns:ns-xml-parser-resolve-external-entities-same-origin-only 2)
(defconstant ns:ns-xml-parser-resolve-external-entities-always 3)

;; NSXPCConnectionOptions
(defconstant ns:ns-xpc-connection-privileged 4096)

;; enum (unnamed at System/Library/Frameworks/Foundation.framework/Headers/FoundationErrors.h:11:1)
(defconstant ns:ns-file-no-such-file-error 4)
(defconstant ns:ns-file-locking-error 255)
(defconstant ns:ns-file-read-unknown-error 256)
(defconstant ns:ns-file-read-no-permission-error 257)
(defconstant ns:ns-file-read-invalid-file-name-error 258)
(defconstant ns:ns-file-read-corrupt-file-error 259)
(defconstant ns:ns-file-read-no-such-file-error 260)
(defconstant ns:ns-file-read-inapplicable-string-encoding-error 261)
(defconstant ns:ns-file-read-unsupported-scheme-error 262)
(defconstant ns:ns-file-read-too-large-error 263)
(defconstant ns:ns-file-read-unknown-string-encoding-error 264)
(defconstant ns:ns-file-write-unknown-error 512)
(defconstant ns:ns-file-write-no-permission-error 513)
(defconstant ns:ns-file-write-invalid-file-name-error 514)
(defconstant ns:ns-file-write-file-exists-error 516)
(defconstant ns:ns-file-write-inapplicable-string-encoding-error 517)
(defconstant ns:ns-file-write-unsupported-scheme-error 518)
(defconstant ns:ns-file-write-out-of-space-error 640)
(defconstant ns:ns-file-write-volume-read-only-error 642)
(defconstant ns:ns-file-manager-unmount-unknown-error 768)
(defconstant ns:ns-file-manager-unmount-busy-error 769)
(defconstant ns:ns-key-value-validation-error 1024)
(defconstant ns:ns-formatting-error 2048)
(defconstant ns:ns-user-cancelled-error 3072)
(defconstant ns:ns-feature-unsupported-error 3328)
(defconstant ns:ns-executable-not-loadable-error 3584)
(defconstant ns:ns-executable-architecture-mismatch-error 3585)
(defconstant ns:ns-executable-runtime-mismatch-error 3586)
(defconstant ns:ns-executable-load-error 3587)
(defconstant ns:ns-executable-link-error 3588)
(defconstant ns:ns-file-error-minimum 0)
(defconstant ns:ns-file-error-maximum 1023)
(defconstant ns:ns-validation-error-minimum 1024)
(defconstant ns:ns-validation-error-maximum 2047)
(defconstant ns:ns-executable-error-minimum 3584)
(defconstant ns:ns-executable-error-maximum 3839)
(defconstant ns:ns-formatting-error-minimum 2048)
(defconstant ns:ns-formatting-error-maximum 2559)
(defconstant ns:ns-property-list-read-corrupt-error 3840)
(defconstant ns:ns-property-list-read-unknown-version-error 3841)
(defconstant ns:ns-property-list-read-stream-error 3842)
(defconstant ns:ns-property-list-write-stream-error 3851)
(defconstant ns:ns-property-list-write-invalid-error 3852)
(defconstant ns:ns-property-list-error-minimum 3840)
(defconstant ns:ns-property-list-error-maximum 4095)
(defconstant ns:ns-xpc-connection-interrupted 4097)
(defconstant ns:ns-xpc-connection-invalid 4099)
(defconstant ns:ns-xpc-connection-reply-invalid 4101)
(defconstant ns:ns-xpc-connection-code-signing-requirement-failure 4102)
(defconstant ns:ns-xpc-connection-error-minimum 4096)
(defconstant ns:ns-xpc-connection-error-maximum 4224)
(defconstant ns:ns-ubiquitous-file-unavailable-error 4353)
(defconstant ns:ns-ubiquitous-file-not-uploaded-due-to-quota-error 4354)
(defconstant ns:ns-ubiquitous-file-ubiquity-server-not-available 4355)
(defconstant ns:ns-ubiquitous-file-error-minimum 4352)
(defconstant ns:ns-ubiquitous-file-error-maximum 4607)
(defconstant ns:ns-user-activity-handoff-failed-error 4608)
(defconstant ns:ns-user-activity-connection-unavailable-error 4609)
(defconstant ns:ns-user-activity-remote-application-timed-out-error 4610)
(defconstant ns:ns-user-activity-handoff-user-info-too-large-error 4611)
(defconstant ns:ns-user-activity-error-minimum 4608)
(defconstant ns:ns-user-activity-error-maximum 4863)
(defconstant ns:ns-coder-read-corrupt-error 4864)
(defconstant ns:ns-coder-value-not-found-error 4865)
(defconstant ns:ns-coder-invalid-value-error 4866)
(defconstant ns:ns-coder-error-minimum 4864)
(defconstant ns:ns-coder-error-maximum 4991)
(defconstant ns:ns-bundle-error-minimum 4992)
(defconstant ns:ns-bundle-error-maximum 5119)
(defconstant ns:ns-bundle-on-demand-resource-out-of-space-error 4992)
(defconstant ns:ns-bundle-on-demand-resource-exceeded-maximum-size-error 4993)
(defconstant ns:ns-bundle-on-demand-resource-invalid-tag-error 4994)
(defconstant ns:ns-cloud-sharing-network-failure-error 5120)
(defconstant ns:ns-cloud-sharing-quota-exceeded-error 5121)
(defconstant ns:ns-cloud-sharing-too-many-participants-error 5122)
(defconstant ns:ns-cloud-sharing-conflict-error 5123)
(defconstant ns:ns-cloud-sharing-no-permission-error 5124)
(defconstant ns:ns-cloud-sharing-other-error 5375)
(defconstant ns:ns-cloud-sharing-error-minimum 5120)
(defconstant ns:ns-cloud-sharing-error-maximum 5375)
(defconstant ns:ns-compression-failed-error 5376)
(defconstant ns:ns-decompression-failed-error 5377)
(defconstant ns:ns-compression-error-minimum 5376)
(defconstant ns:ns-compression-error-maximum 5503)

;; enum (unnamed at System/Library/Frameworks/Foundation.framework/Headers/NSBundle.h:127:1)
(defconstant ns:ns-bundle-executable-architecture-i386 7)
(defconstant ns:ns-bundle-executable-architecture-ppc 18)
(defconstant ns:ns-bundle-executable-architecture-x86-64 16777223)
(defconstant ns:ns-bundle-executable-architecture-ppc64 16777234)
(defconstant ns:ns-bundle-executable-architecture-arm64 16777228)

;; enum (unnamed at System/Library/Frameworks/Foundation.framework/Headers/NSByteOrder.h:10:1)
(defconstant ns:ns-unknown-byte-order 0)
(defconstant ns:ns-little-endian 1)
(defconstant ns:ns-big-endian 2)

;; enum (unnamed at System/Library/Frameworks/Foundation.framework/Headers/NSCalendar.h:113:1)
(defconstant ns:ns-wrap-calendar-components 1)

;; enum (unnamed at System/Library/Frameworks/Foundation.framework/Headers/NSCalendar.h:423:1)
(defconstant ns:ns-date-component-undefined 9223372036854775807)
(defconstant ns:ns-undefined-date-component 9223372036854775807)

;; enum (unnamed at System/Library/Frameworks/Foundation.framework/Headers/NSCharacterSet.h:14:1)
(defconstant ns:ns-open-step-unicode-reserved-base 62464)

;; enum (unnamed at System/Library/Frameworks/Foundation.framework/Headers/NSProcessInfo.h:11:1)
(defconstant ns:ns-windows-nt-operating-system 1)
(defconstant ns:ns-windows95-operating-system 2)
(defconstant ns:ns-solaris-operating-system 3)
(defconstant ns:ns-hpux-operating-system 4)
(defconstant ns:ns-mach-operating-system 5)
(defconstant ns:ns-sun-os-operating-system 6)
(defconstant ns:ns-osf1-operating-system 7)

;; enum (unnamed at System/Library/Frameworks/Foundation.framework/Headers/NSScriptCommand.h:13:1)
(defconstant ns:ns-no-script-error 0)
(defconstant ns:ns-receiver-evaluation-script-error 1)
(defconstant ns:ns-key-specifier-evaluation-script-error 2)
(defconstant ns:ns-argument-evaluation-script-error 3)
(defconstant ns:ns-receivers-cant-handle-command-script-error 4)
(defconstant ns:ns-required-arguments-missing-script-error 5)
(defconstant ns:ns-arguments-wrong-script-error 6)
(defconstant ns:ns-unknown-key-script-error 7)
(defconstant ns:ns-internal-script-error 8)
(defconstant ns:ns-operation-not-supported-for-key-script-error 9)
(defconstant ns:ns-cannot-create-script-command-error 10)

;; enum (unnamed at System/Library/Frameworks/Foundation.framework/Headers/NSScriptObjectSpecifiers.h:13:1)
(defconstant ns:ns-no-specifier-error 0)
(defconstant ns:ns-no-top-level-containers-specifier-error 1)
(defconstant ns:ns-container-specifier-error 2)
(defconstant ns:ns-unknown-key-specifier-error 3)
(defconstant ns:ns-invalid-index-specifier-error 4)
(defconstant ns:ns-internal-specifier-error 5)
(defconstant ns:ns-operation-not-supported-for-key-specifier-error 6)

;; enum (unnamed at System/Library/Frameworks/Foundation.framework/Headers/NSString.h:548:1)
(defconstant ns:ns-proprietary-string-encoding 65536)

;; enum (unnamed at System/Library/Frameworks/Foundation.framework/Headers/NSString.h:68:1)
(defconstant ns:ns-ascii-string-encoding 1)
(defconstant ns:ns-nextstep-string-encoding 2)
(defconstant ns:ns-japanese-euc-string-encoding 3)
(defconstant ns:ns-utf8-string-encoding 4)
(defconstant ns:ns-iso-latin1-string-encoding 5)
(defconstant ns:ns-symbol-string-encoding 6)
(defconstant ns:ns-non-lossy-ascii-string-encoding 7)
(defconstant ns:ns-shift-jis-string-encoding 8)
(defconstant ns:ns-iso-latin2-string-encoding 9)
(defconstant ns:ns-unicode-string-encoding 10)
(defconstant ns:ns-windows-cp1251-string-encoding 11)
(defconstant ns:ns-windows-cp1252-string-encoding 12)
(defconstant ns:ns-windows-cp1253-string-encoding 13)
(defconstant ns:ns-windows-cp1254-string-encoding 14)
(defconstant ns:ns-windows-cp1250-string-encoding 15)
(defconstant ns:ns-iso2022jp-string-encoding 21)
(defconstant ns:ns-mac-os-roman-string-encoding 30)
(defconstant ns:ns-utf16-string-encoding 10)
(defconstant ns:ns-utf16-big-endian-string-encoding 2415919360)
(defconstant ns:ns-utf16-little-endian-string-encoding 2483028224)
(defconstant ns:ns-utf32-string-encoding 2348810496)
(defconstant ns:ns-utf32-big-endian-string-encoding 2550137088)
(defconstant ns:ns-utf32-little-endian-string-encoding 2617245952)

;; enum (unnamed at System/Library/Frameworks/Foundation.framework/Headers/NSTextCheckingResult.h:32:1)
(defconstant ns:ns-text-checking-all-system-types 4294967295)

;; enum (unnamed at System/Library/Frameworks/Foundation.framework/Headers/NSURLError.h:101:1)
(defconstant ns:ns-url-error-unknown -1)
(defconstant ns:ns-url-error-cancelled -999)
(defconstant ns:ns-url-error-bad-url -1000)
(defconstant ns:ns-url-error-timed-out -1001)
(defconstant ns:ns-url-error-unsupported-url -1002)
(defconstant ns:ns-url-error-cannot-find-host -1003)
(defconstant ns:ns-url-error-cannot-connect-to-host -1004)
(defconstant ns:ns-url-error-network-connection-lost -1005)
(defconstant ns:ns-url-error-dns-lookup-failed -1006)
(defconstant ns:ns-url-error-http-too-many-redirects -1007)
(defconstant ns:ns-url-error-resource-unavailable -1008)
(defconstant ns:ns-url-error-not-connected-to-internet -1009)
(defconstant ns:ns-url-error-redirect-to-non-existent-location -1010)
(defconstant ns:ns-url-error-bad-server-response -1011)
(defconstant ns:ns-url-error-user-cancelled-authentication -1012)
(defconstant ns:ns-url-error-user-authentication-required -1013)
(defconstant ns:ns-url-error-zero-byte-resource -1014)
(defconstant ns:ns-url-error-cannot-decode-raw-data -1015)
(defconstant ns:ns-url-error-cannot-decode-content-data -1016)
(defconstant ns:ns-url-error-cannot-parse-response -1017)
(defconstant ns:ns-url-error-app-transport-security-requires-secure-connection -1022)
(defconstant ns:ns-url-error-file-does-not-exist -1100)
(defconstant ns:ns-url-error-file-is-directory -1101)
(defconstant ns:ns-url-error-no-permissions-to-read-file -1102)
(defconstant ns:ns-url-error-data-length-exceeds-maximum -1103)
(defconstant ns:ns-url-error-file-outside-safe-area -1104)
(defconstant ns:ns-url-error-secure-connection-failed -1200)
(defconstant ns:ns-url-error-server-certificate-has-bad-date -1201)
(defconstant ns:ns-url-error-server-certificate-untrusted -1202)
(defconstant ns:ns-url-error-server-certificate-has-unknown-root -1203)
(defconstant ns:ns-url-error-server-certificate-not-yet-valid -1204)
(defconstant ns:ns-url-error-client-certificate-rejected -1205)
(defconstant ns:ns-url-error-client-certificate-required -1206)
(defconstant ns:ns-url-error-cannot-load-from-network -2000)
(defconstant ns:ns-url-error-cannot-create-file -3000)
(defconstant ns:ns-url-error-cannot-open-file -3001)
(defconstant ns:ns-url-error-cannot-close-file -3002)
(defconstant ns:ns-url-error-cannot-write-to-file -3003)
(defconstant ns:ns-url-error-cannot-remove-file -3004)
(defconstant ns:ns-url-error-cannot-move-file -3005)
(defconstant ns:ns-url-error-download-decoding-failed-mid-stream -3006)
(defconstant ns:ns-url-error-download-decoding-failed-to-complete -3007)
(defconstant ns:ns-url-error-international-roaming-off -1018)
(defconstant ns:ns-url-error-call-is-active -1019)
(defconstant ns:ns-url-error-data-not-allowed -1020)
(defconstant ns:ns-url-error-request-body-stream-exhausted -1021)
(defconstant ns:ns-url-error-background-session-requires-shared-container -995)
(defconstant ns:ns-url-error-background-session-in-use-by-another-process -996)
(defconstant ns:ns-url-error-background-session-was-disconnected -997)

;; enum (unnamed at System/Library/Frameworks/Foundation.framework/Headers/NSURLError.h:69:1)
(defconstant ns:ns-url-error-cancelled-reason-user-force-quit-application 0)
(defconstant ns:ns-url-error-cancelled-reason-background-updates-disabled 1)
(defconstant ns:ns-url-error-cancelled-reason-insufficient-system-resources 2)

;; enum (unnamed at System/Library/Frameworks/Foundation.framework/Headers/NSUbiquitousKeyValueStore.h:47:1)
(defconstant ns:ns-ubiquitous-key-value-store-server-change 0)
(defconstant ns:ns-ubiquitous-key-value-store-initial-sync-change 1)
(defconstant ns:ns-ubiquitous-key-value-store-quota-violation-change 2)
(defconstant ns:ns-ubiquitous-key-value-store-account-change 3)

;; enum (unnamed at System/Library/Frameworks/Foundation.framework/Headers/NSZone.h:32:1)
(defconstant ns:ns-scanned-option 1)
(defconstant ns:ns-collector-disabled-option 2)

;; InflectionRule
(defconstant ns:automatic 0)
(defconstant ns:explicit 1)

;; SortOrder
(defconstant ns:forward 0)
(defconstant ns:reverse 1)

;; InflectionConcept
(defconstant ns:terms-of-address 0)
(defconstant ns:localized-phrase 1)

