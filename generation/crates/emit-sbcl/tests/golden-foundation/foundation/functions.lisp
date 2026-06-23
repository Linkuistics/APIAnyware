(in-package #:apianyware-sbcl-impl)

;;; Generated C function bindings for Foundation — do not edit

(sb-alien:define-alien-routine ("NSAllHashTableObjects" ns:ns-all-hash-table-objects) sb-alien:system-area-pointer
  (table sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSAllMapTableKeys" ns:ns-all-map-table-keys) sb-alien:system-area-pointer
  (table sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSAllMapTableValues" ns:ns-all-map-table-values) sb-alien:system-area-pointer
  (table sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSAllocateCollectable" ns:ns-allocate-collectable) sb-alien:system-area-pointer
  (size (sb-alien:unsigned 64))
  (options (sb-alien:unsigned 64)))
(sb-alien:define-alien-routine ("NSAllocateMemoryPages" ns:ns-allocate-memory-pages) sb-alien:system-area-pointer
  (bytes (sb-alien:unsigned 64)))
(sb-alien:define-alien-routine ("NSAllocateObject" ns:ns-allocate-object) sb-alien:system-area-pointer
  (a-class sb-alien:system-area-pointer)
  (extra-bytes (sb-alien:unsigned 64))
  (zone sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSClassFromString" ns:ns-class-from-string) sb-alien:system-area-pointer
  (a-class-name sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSCompareHashTables" ns:ns-compare-hash-tables) (sb-alien:boolean 8)
  (table1 sb-alien:system-area-pointer)
  (table2 sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSCompareMapTables" ns:ns-compare-map-tables) (sb-alien:boolean 8)
  (table1 sb-alien:system-area-pointer)
  (table2 sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSContainsRect" ns:ns-contains-rect) (sb-alien:boolean 8)
  (a-rect (sb-alien:struct ns-rect))
  (b-rect (sb-alien:struct ns-rect)))
(sb-alien:define-alien-routine ("NSCopyHashTableWithZone" ns:ns-copy-hash-table-with-zone) sb-alien:system-area-pointer
  (table sb-alien:system-area-pointer)
  (zone sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSCopyMapTableWithZone" ns:ns-copy-map-table-with-zone) sb-alien:system-area-pointer
  (table sb-alien:system-area-pointer)
  (zone sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSCopyMemoryPages" ns:ns-copy-memory-pages) sb-alien:void
  (source sb-alien:system-area-pointer)
  (dest sb-alien:system-area-pointer)
  (bytes (sb-alien:unsigned 64)))
(sb-alien:define-alien-routine ("NSCopyObject" ns:ns-copy-object) sb-alien:system-area-pointer
  (object sb-alien:system-area-pointer)
  (extra-bytes (sb-alien:unsigned 64))
  (zone sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSCountHashTable" ns:ns-count-hash-table) (sb-alien:unsigned 64)
  (table sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSCountMapTable" ns:ns-count-map-table) (sb-alien:unsigned 64)
  (table sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSCreateHashTable" ns:ns-create-hash-table) sb-alien:system-area-pointer
  (call-backs sb-alien:system-area-pointer)
  (capacity (sb-alien:unsigned 64)))
(sb-alien:define-alien-routine ("NSCreateHashTableWithZone" ns:ns-create-hash-table-with-zone) sb-alien:system-area-pointer
  (call-backs sb-alien:system-area-pointer)
  (capacity (sb-alien:unsigned 64))
  (zone sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSCreateMapTable" ns:ns-create-map-table) sb-alien:system-area-pointer
  (key-call-backs sb-alien:system-area-pointer)
  (value-call-backs sb-alien:system-area-pointer)
  (capacity (sb-alien:unsigned 64)))
(sb-alien:define-alien-routine ("NSCreateMapTableWithZone" ns:ns-create-map-table-with-zone) sb-alien:system-area-pointer
  (key-call-backs sb-alien:system-area-pointer)
  (value-call-backs sb-alien:system-area-pointer)
  (capacity (sb-alien:unsigned 64))
  (zone sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSCreateZone" ns:ns-create-zone) sb-alien:system-area-pointer
  (start-size (sb-alien:unsigned 64))
  (granularity (sb-alien:unsigned 64))
  (can-free (sb-alien:boolean 8)))
(sb-alien:define-alien-routine ("NSDeallocateMemoryPages" ns:ns-deallocate-memory-pages) sb-alien:void
  (ptr sb-alien:system-area-pointer)
  (bytes (sb-alien:unsigned 64)))
(sb-alien:define-alien-routine ("NSDeallocateObject" ns:ns-deallocate-object) sb-alien:void
  (object sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSDecimalAdd" ns:ns-decimal-add) (sb-alien:unsigned 64)
  (result sb-alien:system-area-pointer)
  (left-operand sb-alien:system-area-pointer)
  (right-operand sb-alien:system-area-pointer)
  (rounding-mode (sb-alien:unsigned 64)))
(sb-alien:define-alien-routine ("NSDecimalCompact" ns:ns-decimal-compact) sb-alien:void
  (number sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSDecimalCompare" ns:ns-decimal-compare) (sb-alien:signed 64)
  (left-operand sb-alien:system-area-pointer)
  (right-operand sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSDecimalCopy" ns:ns-decimal-copy) sb-alien:void
  (destination sb-alien:system-area-pointer)
  (source sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSDecimalDivide" ns:ns-decimal-divide) (sb-alien:unsigned 64)
  (result sb-alien:system-area-pointer)
  (left-operand sb-alien:system-area-pointer)
  (right-operand sb-alien:system-area-pointer)
  (rounding-mode (sb-alien:unsigned 64)))
(sb-alien:define-alien-routine ("NSDecimalMultiply" ns:ns-decimal-multiply) (sb-alien:unsigned 64)
  (result sb-alien:system-area-pointer)
  (left-operand sb-alien:system-area-pointer)
  (right-operand sb-alien:system-area-pointer)
  (rounding-mode (sb-alien:unsigned 64)))
(sb-alien:define-alien-routine ("NSDecimalMultiplyByPowerOf10" ns:ns-decimal-multiply-by-power-of10) (sb-alien:unsigned 64)
  (result sb-alien:system-area-pointer)
  (number sb-alien:system-area-pointer)
  (power (sb-alien:signed 16))
  (rounding-mode (sb-alien:unsigned 64)))
(sb-alien:define-alien-routine ("NSDecimalNormalize" ns:ns-decimal-normalize) (sb-alien:unsigned 64)
  (number1 sb-alien:system-area-pointer)
  (number2 sb-alien:system-area-pointer)
  (rounding-mode (sb-alien:unsigned 64)))
(sb-alien:define-alien-routine ("NSDecimalPower" ns:ns-decimal-power) (sb-alien:unsigned 64)
  (result sb-alien:system-area-pointer)
  (number sb-alien:system-area-pointer)
  (power (sb-alien:unsigned 64))
  (rounding-mode (sb-alien:unsigned 64)))
(sb-alien:define-alien-routine ("NSDecimalRound" ns:ns-decimal-round) sb-alien:void
  (result sb-alien:system-area-pointer)
  (number sb-alien:system-area-pointer)
  (scale (sb-alien:signed 64))
  (rounding-mode (sb-alien:unsigned 64)))
(sb-alien:define-alien-routine ("NSDecimalString" ns:ns-decimal-string) sb-alien:system-area-pointer
  (dcm sb-alien:system-area-pointer)
  (locale sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSDecimalSubtract" ns:ns-decimal-subtract) (sb-alien:unsigned 64)
  (result sb-alien:system-area-pointer)
  (left-operand sb-alien:system-area-pointer)
  (right-operand sb-alien:system-area-pointer)
  (rounding-mode (sb-alien:unsigned 64)))
(sb-alien:define-alien-routine ("NSDecrementExtraRefCountWasZero" ns:ns-decrement-extra-ref-count-was-zero) (sb-alien:boolean 8)
  (object sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSDefaultMallocZone" ns:ns-default-malloc-zone) sb-alien:system-area-pointer)
(sb-alien:define-alien-routine ("NSDivideRect" ns:ns-divide-rect) sb-alien:void
  (in-rect (sb-alien:struct ns-rect))
  (slice sb-alien:system-area-pointer)
  (rem sb-alien:system-area-pointer)
  (amount sb-alien:double)
  (edge (sb-alien:unsigned 64)))
(sb-alien:define-alien-routine ("NSEdgeInsetsEqual" ns:ns-edge-insets-equal) (sb-alien:boolean 8)
  (a-insets (sb-alien:struct ns-edge-insets))
  (b-insets (sb-alien:struct ns-edge-insets)))
(sb-alien:define-alien-routine ("NSEndHashTableEnumeration" ns:ns-end-hash-table-enumeration) sb-alien:void
  (enumerator sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSEndMapTableEnumeration" ns:ns-end-map-table-enumeration) sb-alien:void
  (enumerator sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSEnumerateHashTable" ns:ns-enumerate-hash-table) sb-alien:system-area-pointer
  (table sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSEnumerateMapTable" ns:ns-enumerate-map-table) sb-alien:system-area-pointer
  (table sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSEqualPoints" ns:ns-equal-points) (sb-alien:boolean 8)
  (a-point (sb-alien:struct ns-point))
  (b-point (sb-alien:struct ns-point)))
(sb-alien:define-alien-routine ("NSEqualRects" ns:ns-equal-rects) (sb-alien:boolean 8)
  (a-rect (sb-alien:struct ns-rect))
  (b-rect (sb-alien:struct ns-rect)))
(sb-alien:define-alien-routine ("NSEqualSizes" ns:ns-equal-sizes) (sb-alien:boolean 8)
  (a-size (sb-alien:struct ns-size))
  (b-size (sb-alien:struct ns-size)))
(sb-alien:define-alien-routine ("NSExtraRefCount" ns:ns-extra-ref-count) (sb-alien:unsigned 64)
  (object sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSFileTypeForHFSTypeCode" ns:ns-file-type-for-hfs-type-code) sb-alien:system-area-pointer
  (hfs-file-type-code (sb-alien:unsigned 32)))
(sb-alien:define-alien-routine ("NSFreeHashTable" ns:ns-free-hash-table) sb-alien:void
  (table sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSFreeMapTable" ns:ns-free-map-table) sb-alien:void
  (table sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSFullUserName" ns:ns-full-user-name) sb-alien:system-area-pointer)
(sb-alien:define-alien-routine ("NSGetSizeAndAlignment" ns:ns-get-size-and-alignment) sb-alien:c-string
  (type-ptr sb-alien:c-string)
  (sizep sb-alien:system-area-pointer)
  (alignp sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSGetUncaughtExceptionHandler" ns:ns-get-uncaught-exception-handler) sb-alien:system-area-pointer)
(sb-alien:define-alien-routine ("NSHFSTypeCodeFromFileType" ns:ns-hfs-type-code-from-file-type) (sb-alien:unsigned 32)
  (file-type-string sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSHFSTypeOfFile" ns:ns-hfs-type-of-file) sb-alien:system-area-pointer
  (full-file-path sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSHashGet" ns:ns-hash-get) sb-alien:system-area-pointer
  (table sb-alien:system-area-pointer)
  (pointer sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSHashInsert" ns:ns-hash-insert) sb-alien:void
  (table sb-alien:system-area-pointer)
  (pointer sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSHashInsertIfAbsent" ns:ns-hash-insert-if-absent) sb-alien:system-area-pointer
  (table sb-alien:system-area-pointer)
  (pointer sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSHashInsertKnownAbsent" ns:ns-hash-insert-known-absent) sb-alien:void
  (table sb-alien:system-area-pointer)
  (pointer sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSHashRemove" ns:ns-hash-remove) sb-alien:void
  (table sb-alien:system-area-pointer)
  (pointer sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSHomeDirectory" ns:ns-home-directory) sb-alien:system-area-pointer)
(sb-alien:define-alien-routine ("NSHomeDirectoryForUser" ns:ns-home-directory-for-user) sb-alien:system-area-pointer
  (user-name sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSIncrementExtraRefCount" ns:ns-increment-extra-ref-count) sb-alien:void
  (object sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSInsetRect" ns:ns-inset-rect) (sb-alien:struct ns-rect)
  (a-rect (sb-alien:struct ns-rect))
  (d-x sb-alien:double)
  (d-y sb-alien:double))
(sb-alien:define-alien-routine ("NSIntegralRect" ns:ns-integral-rect) (sb-alien:struct ns-rect)
  (a-rect (sb-alien:struct ns-rect)))
(sb-alien:define-alien-routine ("NSIntegralRectWithOptions" ns:ns-integral-rect-with-options) (sb-alien:struct ns-rect)
  (a-rect (sb-alien:struct ns-rect))
  (opts (sb-alien:unsigned 64)))
(sb-alien:define-alien-routine ("NSIntersectionRange" ns:ns-intersection-range) (sb-alien:struct ns-range)
  (range1 (sb-alien:struct ns-range))
  (range2 (sb-alien:struct ns-range)))
(sb-alien:define-alien-routine ("NSIntersectionRect" ns:ns-intersection-rect) (sb-alien:struct ns-rect)
  (a-rect (sb-alien:struct ns-rect))
  (b-rect (sb-alien:struct ns-rect)))
(sb-alien:define-alien-routine ("NSIntersectsRect" ns:ns-intersects-rect) (sb-alien:boolean 8)
  (a-rect (sb-alien:struct ns-rect))
  (b-rect (sb-alien:struct ns-rect)))
(sb-alien:define-alien-routine ("NSIsEmptyRect" ns:ns-is-empty-rect) (sb-alien:boolean 8)
  (a-rect (sb-alien:struct ns-rect)))
(sb-alien:define-alien-routine ("NSLogPageSize" ns:ns-log-page-size) (sb-alien:unsigned 64))
(sb-alien:define-alien-routine ("NSLogv" ns:ns-logv) sb-alien:void
  (format sb-alien:system-area-pointer)
  (args sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSMapGet" ns:ns-map-get) sb-alien:system-area-pointer
  (table sb-alien:system-area-pointer)
  (key sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSMapInsert" ns:ns-map-insert) sb-alien:void
  (table sb-alien:system-area-pointer)
  (key sb-alien:system-area-pointer)
  (value sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSMapInsertIfAbsent" ns:ns-map-insert-if-absent) sb-alien:system-area-pointer
  (table sb-alien:system-area-pointer)
  (key sb-alien:system-area-pointer)
  (value sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSMapInsertKnownAbsent" ns:ns-map-insert-known-absent) sb-alien:void
  (table sb-alien:system-area-pointer)
  (key sb-alien:system-area-pointer)
  (value sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSMapMember" ns:ns-map-member) (sb-alien:boolean 8)
  (table sb-alien:system-area-pointer)
  (key sb-alien:system-area-pointer)
  (original-key sb-alien:system-area-pointer)
  (value sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSMapRemove" ns:ns-map-remove) sb-alien:void
  (table sb-alien:system-area-pointer)
  (key sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSMouseInRect" ns:ns-mouse-in-rect) (sb-alien:boolean 8)
  (a-point (sb-alien:struct ns-point))
  (a-rect (sb-alien:struct ns-rect))
  (flipped (sb-alien:boolean 8)))
(sb-alien:define-alien-routine ("NSNextHashEnumeratorItem" ns:ns-next-hash-enumerator-item) sb-alien:system-area-pointer
  (enumerator sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSNextMapEnumeratorPair" ns:ns-next-map-enumerator-pair) (sb-alien:boolean 8)
  (enumerator sb-alien:system-area-pointer)
  (key sb-alien:system-area-pointer)
  (value sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSOffsetRect" ns:ns-offset-rect) (sb-alien:struct ns-rect)
  (a-rect (sb-alien:struct ns-rect))
  (d-x sb-alien:double)
  (d-y sb-alien:double))
(sb-alien:define-alien-routine ("NSOpenStepRootDirectory" ns:ns-open-step-root-directory) sb-alien:system-area-pointer)
(sb-alien:define-alien-routine ("NSPageSize" ns:ns-page-size) (sb-alien:unsigned 64))
(sb-alien:define-alien-routine ("NSPointFromString" ns:ns-point-from-string) (sb-alien:struct ns-point)
  (a-string sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSPointInRect" ns:ns-point-in-rect) (sb-alien:boolean 8)
  (a-point (sb-alien:struct ns-point))
  (a-rect (sb-alien:struct ns-rect)))
(sb-alien:define-alien-routine ("NSProtocolFromString" ns:ns-protocol-from-string) sb-alien:system-area-pointer
  (namestr sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSRangeFromString" ns:ns-range-from-string) (sb-alien:struct ns-range)
  (a-string sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSRealMemoryAvailable" ns:ns-real-memory-available) (sb-alien:unsigned 64))
(sb-alien:define-alien-routine ("NSReallocateCollectable" ns:ns-reallocate-collectable) sb-alien:system-area-pointer
  (ptr sb-alien:system-area-pointer)
  (size (sb-alien:unsigned 64))
  (options (sb-alien:unsigned 64)))
(sb-alien:define-alien-routine ("NSRectFromString" ns:ns-rect-from-string) (sb-alien:struct ns-rect)
  (a-string sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSRecycleZone" ns:ns-recycle-zone) sb-alien:void
  (zone sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSResetHashTable" ns:ns-reset-hash-table) sb-alien:void
  (table sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSResetMapTable" ns:ns-reset-map-table) sb-alien:void
  (table sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSRoundDownToMultipleOfPageSize" ns:ns-round-down-to-multiple-of-page-size) (sb-alien:unsigned 64)
  (bytes (sb-alien:unsigned 64)))
(sb-alien:define-alien-routine ("NSRoundUpToMultipleOfPageSize" ns:ns-round-up-to-multiple-of-page-size) (sb-alien:unsigned 64)
  (bytes (sb-alien:unsigned 64)))
(sb-alien:define-alien-routine ("NSSearchPathForDirectoriesInDomains" ns:ns-search-path-for-directories-in-domains) sb-alien:system-area-pointer
  (directory (sb-alien:unsigned 64))
  (domain-mask (sb-alien:unsigned 64))
  (expand-tilde (sb-alien:boolean 8)))
(sb-alien:define-alien-routine ("NSSelectorFromString" ns:ns-selector-from-string) sb-alien:system-area-pointer
  (a-selector-name sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSSetUncaughtExceptionHandler" ns:ns-set-uncaught-exception-handler) sb-alien:void
  (arg0 sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSSetZoneName" ns:ns-set-zone-name) sb-alien:void
  (zone sb-alien:system-area-pointer)
  (name sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSShouldRetainWithZone" ns:ns-should-retain-with-zone) (sb-alien:boolean 8)
  (an-object sb-alien:system-area-pointer)
  (requested-zone sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSSizeFromString" ns:ns-size-from-string) (sb-alien:struct ns-size)
  (a-string sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSStringFromClass" ns:ns-string-from-class) sb-alien:system-area-pointer
  (a-class sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSStringFromHashTable" ns:ns-string-from-hash-table) sb-alien:system-area-pointer
  (table sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSStringFromMapTable" ns:ns-string-from-map-table) sb-alien:system-area-pointer
  (table sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSStringFromPoint" ns:ns-string-from-point) sb-alien:system-area-pointer
  (a-point (sb-alien:struct ns-point)))
(sb-alien:define-alien-routine ("NSStringFromProtocol" ns:ns-string-from-protocol) sb-alien:system-area-pointer
  (proto sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSStringFromRange" ns:ns-string-from-range) sb-alien:system-area-pointer
  (range (sb-alien:struct ns-range)))
(sb-alien:define-alien-routine ("NSStringFromRect" ns:ns-string-from-rect) sb-alien:system-area-pointer
  (a-rect (sb-alien:struct ns-rect)))
(sb-alien:define-alien-routine ("NSStringFromSelector" ns:ns-string-from-selector) sb-alien:system-area-pointer
  (a-selector sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSStringFromSize" ns:ns-string-from-size) sb-alien:system-area-pointer
  (a-size (sb-alien:struct ns-size)))
(sb-alien:define-alien-routine ("NSTemporaryDirectory" ns:ns-temporary-directory) sb-alien:system-area-pointer)
(sb-alien:define-alien-routine ("NSUnionRange" ns:ns-union-range) (sb-alien:struct ns-range)
  (range1 (sb-alien:struct ns-range))
  (range2 (sb-alien:struct ns-range)))
(sb-alien:define-alien-routine ("NSUnionRect" ns:ns-union-rect) (sb-alien:struct ns-rect)
  (a-rect (sb-alien:struct ns-rect))
  (b-rect (sb-alien:struct ns-rect)))
(sb-alien:define-alien-routine ("NSUserName" ns:ns-user-name) sb-alien:system-area-pointer)
(sb-alien:define-alien-routine ("NSZoneCalloc" ns:ns-zone-calloc) sb-alien:system-area-pointer
  (zone sb-alien:system-area-pointer)
  (num-elems (sb-alien:unsigned 64))
  (byte-size (sb-alien:unsigned 64)))
(sb-alien:define-alien-routine ("NSZoneFree" ns:ns-zone-free) sb-alien:void
  (zone sb-alien:system-area-pointer)
  (ptr sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSZoneFromPointer" ns:ns-zone-from-pointer) sb-alien:system-area-pointer
  (ptr sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSZoneMalloc" ns:ns-zone-malloc) sb-alien:system-area-pointer
  (zone sb-alien:system-area-pointer)
  (size (sb-alien:unsigned 64)))
(sb-alien:define-alien-routine ("NSZoneName" ns:ns-zone-name) sb-alien:system-area-pointer
  (zone sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("NSZoneRealloc" ns:ns-zone-realloc) sb-alien:system-area-pointer
  (zone sb-alien:system-area-pointer)
  (ptr sb-alien:system-area-pointer)
  (size (sb-alien:unsigned 64)))
(sb-alien:define-alien-routine ("NXReadNSObjectFromCoder" ns:nx-read-ns-object-from-coder) sb-alien:system-area-pointer
  (decoder sb-alien:system-area-pointer))
