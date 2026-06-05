;;; Generated C function bindings for Foundation — do not edit
(import :std/foreign)
(export
  NSAllHashTableObjects
  NSAllMapTableKeys
  NSAllMapTableValues
  NSAllocateCollectable
  NSAllocateMemoryPages
  NSAllocateObject
  NSClassFromString
  NSCompareHashTables
  NSCompareMapTables
  NSContainsRect
  NSCopyHashTableWithZone
  NSCopyMapTableWithZone
  NSCopyMemoryPages
  NSCopyObject
  NSCountHashTable
  NSCountMapTable
  NSCreateHashTable
  NSCreateHashTableWithZone
  NSCreateMapTable
  NSCreateMapTableWithZone
  NSCreateZone
  NSDeallocateMemoryPages
  NSDeallocateObject
  NSDecimalAdd
  NSDecimalCompact
  NSDecimalCompare
  NSDecimalCopy
  NSDecimalDivide
  NSDecimalMultiply
  NSDecimalMultiplyByPowerOf10
  NSDecimalNormalize
  NSDecimalPower
  NSDecimalRound
  NSDecimalString
  NSDecimalSubtract
  NSDecrementExtraRefCountWasZero
  NSDefaultMallocZone
  NSDivideRect
  NSEdgeInsetsEqual
  NSEndHashTableEnumeration
  NSEndMapTableEnumeration
  NSEnumerateHashTable
  NSEnumerateMapTable
  NSEqualPoints
  NSEqualRects
  NSEqualSizes
  NSExtraRefCount
  NSFileTypeForHFSTypeCode
  NSFreeHashTable
  NSFreeMapTable
  NSFullUserName
  NSGetSizeAndAlignment
  NSGetUncaughtExceptionHandler
  NSHFSTypeCodeFromFileType
  NSHFSTypeOfFile
  NSHashGet
  NSHashInsert
  NSHashInsertIfAbsent
  NSHashInsertKnownAbsent
  NSHashRemove
  NSHomeDirectory
  NSHomeDirectoryForUser
  NSIncrementExtraRefCount
  NSInsetRect
  NSIntegralRect
  NSIntegralRectWithOptions
  NSIntersectionRange
  NSIntersectionRect
  NSIntersectsRect
  NSIsEmptyRect
  NSLogPageSize
  NSLogv
  NSMapGet
  NSMapInsert
  NSMapInsertIfAbsent
  NSMapInsertKnownAbsent
  NSMapMember
  NSMapRemove
  NSMouseInRect
  NSNextHashEnumeratorItem
  NSNextMapEnumeratorPair
  NSOffsetRect
  NSOpenStepRootDirectory
  NSPageSize
  NSPointFromString
  NSPointInRect
  NSProtocolFromString
  NSRangeFromString
  NSRealMemoryAvailable
  NSReallocateCollectable
  NSRectFromString
  NSRecycleZone
  NSResetHashTable
  NSResetMapTable
  NSRoundDownToMultipleOfPageSize
  NSRoundUpToMultipleOfPageSize
  NSSearchPathForDirectoriesInDomains
  NSSelectorFromString
  NSSetUncaughtExceptionHandler
  NSSetZoneName
  NSShouldRetainWithZone
  NSSizeFromString
  NSStringFromClass
  NSStringFromHashTable
  NSStringFromMapTable
  NSStringFromPoint
  NSStringFromProtocol
  NSStringFromRange
  NSStringFromRect
  NSStringFromSelector
  NSStringFromSize
  NSTemporaryDirectory
  NSUnionRange
  NSUnionRect
  NSUserName
  NSZoneCalloc
  NSZoneFree
  NSZoneFromPointer
  NSZoneMalloc
  NSZoneName
  NSZoneRealloc
  NXReadNSObjectFromCoder
  )

(begin-ffi (
            NSAllHashTableObjects
            NSAllMapTableKeys
            NSAllMapTableValues
            NSAllocateCollectable
            NSAllocateMemoryPages
            NSAllocateObject
            NSClassFromString
            NSCompareHashTables
            NSCompareMapTables
            NSContainsRect
            NSCopyHashTableWithZone
            NSCopyMapTableWithZone
            NSCopyMemoryPages
            NSCopyObject
            NSCountHashTable
            NSCountMapTable
            NSCreateHashTable
            NSCreateHashTableWithZone
            NSCreateMapTable
            NSCreateMapTableWithZone
            NSCreateZone
            NSDeallocateMemoryPages
            NSDeallocateObject
            NSDecimalAdd
            NSDecimalCompact
            NSDecimalCompare
            NSDecimalCopy
            NSDecimalDivide
            NSDecimalMultiply
            NSDecimalMultiplyByPowerOf10
            NSDecimalNormalize
            NSDecimalPower
            NSDecimalRound
            NSDecimalString
            NSDecimalSubtract
            NSDecrementExtraRefCountWasZero
            NSDefaultMallocZone
            NSDivideRect
            NSEdgeInsetsEqual
            NSEndHashTableEnumeration
            NSEndMapTableEnumeration
            NSEnumerateHashTable
            NSEnumerateMapTable
            NSEqualPoints
            NSEqualRects
            NSEqualSizes
            NSExtraRefCount
            NSFileTypeForHFSTypeCode
            NSFreeHashTable
            NSFreeMapTable
            NSFullUserName
            NSGetSizeAndAlignment
            NSGetUncaughtExceptionHandler
            NSHFSTypeCodeFromFileType
            NSHFSTypeOfFile
            NSHashGet
            NSHashInsert
            NSHashInsertIfAbsent
            NSHashInsertKnownAbsent
            NSHashRemove
            NSHomeDirectory
            NSHomeDirectoryForUser
            NSIncrementExtraRefCount
            NSInsetRect
            NSIntegralRect
            NSIntegralRectWithOptions
            NSIntersectionRange
            NSIntersectionRect
            NSIntersectsRect
            NSIsEmptyRect
            NSLogPageSize
            NSLogv
            NSMapGet
            NSMapInsert
            NSMapInsertIfAbsent
            NSMapInsertKnownAbsent
            NSMapMember
            NSMapRemove
            NSMouseInRect
            NSNextHashEnumeratorItem
            NSNextMapEnumeratorPair
            NSOffsetRect
            NSOpenStepRootDirectory
            NSPageSize
            NSPointFromString
            NSPointInRect
            NSProtocolFromString
            NSRangeFromString
            NSRealMemoryAvailable
            NSReallocateCollectable
            NSRectFromString
            NSRecycleZone
            NSResetHashTable
            NSResetMapTable
            NSRoundDownToMultipleOfPageSize
            NSRoundUpToMultipleOfPageSize
            NSSearchPathForDirectoriesInDomains
            NSSelectorFromString
            NSSetUncaughtExceptionHandler
            NSSetZoneName
            NSShouldRetainWithZone
            NSSizeFromString
            NSStringFromClass
            NSStringFromHashTable
            NSStringFromMapTable
            NSStringFromPoint
            NSStringFromProtocol
            NSStringFromRange
            NSStringFromRect
            NSStringFromSelector
            NSStringFromSize
            NSTemporaryDirectory
            NSUnionRange
            NSUnionRect
            NSUserName
            NSZoneCalloc
            NSZoneFree
            NSZoneFromPointer
            NSZoneMalloc
            NSZoneName
            NSZoneRealloc
            NXReadNSObjectFromCoder
            )
  (c-declare "#include <stdbool.h>")
  (c-declare "#include <CoreGraphics/CGGeometry.h>")
  (c-declare "typedef struct NSEdgeInsets { double top; double left; double bottom; double right; } NSEdgeInsets;")
  (c-declare "#include <CoreGraphics/CGGeometry.h>")
  (c-declare "#include <CoreGraphics/CGGeometry.h>")
  (c-declare "typedef struct _NSRange { unsigned long location; unsigned long length; } NSRange;")
  (c-define-type CGRect (struct "CGRect"))
  (c-define-type NSEdgeInsets (struct "NSEdgeInsets"))
  (c-define-type CGPoint (struct "CGPoint"))
  (c-define-type CGSize (struct "CGSize"))
  (c-define-type NSRange (struct "_NSRange"))
  (c-declare "extern void * NSAllHashTableObjects(void *);")
  (c-declare "extern void * NSAllMapTableKeys(void *);")
  (c-declare "extern void * NSAllMapTableValues(void *);")
  (c-declare "extern void * NSAllocateCollectable(unsigned long long, unsigned long long);")
  (c-declare "extern void * NSAllocateMemoryPages(unsigned long long);")
  (c-declare "extern void * NSAllocateObject(void *, unsigned long long, void *);")
  (c-declare "extern void * NSClassFromString(void *);")
  (c-declare "extern bool NSCompareHashTables(void *, void *);")
  (c-declare "extern bool NSCompareMapTables(void *, void *);")
  (c-declare "extern bool NSContainsRect(struct CGRect, struct CGRect);")
  (c-declare "extern void * NSCopyHashTableWithZone(void *, void *);")
  (c-declare "extern void * NSCopyMapTableWithZone(void *, void *);")
  (c-declare "extern void NSCopyMemoryPages(void *, void *, unsigned long long);")
  (c-declare "extern void * NSCopyObject(void *, unsigned long long, void *);")
  (c-declare "extern unsigned long long NSCountHashTable(void *);")
  (c-declare "extern unsigned long long NSCountMapTable(void *);")
  (c-declare "extern void * NSCreateHashTable(void *, unsigned long long);")
  (c-declare "extern void * NSCreateHashTableWithZone(void *, unsigned long long, void *);")
  (c-declare "extern void * NSCreateMapTable(void *, void *, unsigned long long);")
  (c-declare "extern void * NSCreateMapTableWithZone(void *, void *, unsigned long long, void *);")
  (c-declare "extern void * NSCreateZone(unsigned long long, unsigned long long, bool);")
  (c-declare "extern void NSDeallocateMemoryPages(void *, unsigned long long);")
  (c-declare "extern void NSDeallocateObject(void *);")
  (c-declare "extern unsigned long long NSDecimalAdd(void *, void *, void *, unsigned long long);")
  (c-declare "extern void NSDecimalCompact(void *);")
  (c-declare "extern long long NSDecimalCompare(void *, void *);")
  (c-declare "extern void NSDecimalCopy(void *, void *);")
  (c-declare "extern unsigned long long NSDecimalDivide(void *, void *, void *, unsigned long long);")
  (c-declare "extern unsigned long long NSDecimalMultiply(void *, void *, void *, unsigned long long);")
  (c-declare "extern unsigned long long NSDecimalMultiplyByPowerOf10(void *, void *, short, unsigned long long);")
  (c-declare "extern unsigned long long NSDecimalNormalize(void *, void *, unsigned long long);")
  (c-declare "extern unsigned long long NSDecimalPower(void *, void *, unsigned long long, unsigned long long);")
  (c-declare "extern void NSDecimalRound(void *, void *, long long, unsigned long long);")
  (c-declare "extern void * NSDecimalString(void *, void *);")
  (c-declare "extern unsigned long long NSDecimalSubtract(void *, void *, void *, unsigned long long);")
  (c-declare "extern bool NSDecrementExtraRefCountWasZero(void *);")
  (c-declare "extern void * NSDefaultMallocZone(void);")
  (c-declare "extern void NSDivideRect(struct CGRect, void *, void *, double, unsigned long long);")
  (c-declare "extern bool NSEdgeInsetsEqual(struct NSEdgeInsets, struct NSEdgeInsets);")
  (c-declare "extern void NSEndHashTableEnumeration(void *);")
  (c-declare "extern void NSEndMapTableEnumeration(void *);")
  (c-declare "extern void * NSEnumerateHashTable(void *);")
  (c-declare "extern void * NSEnumerateMapTable(void *);")
  (c-declare "extern bool NSEqualPoints(struct CGPoint, struct CGPoint);")
  (c-declare "extern bool NSEqualRects(struct CGRect, struct CGRect);")
  (c-declare "extern bool NSEqualSizes(struct CGSize, struct CGSize);")
  (c-declare "extern unsigned long long NSExtraRefCount(void *);")
  (c-declare "extern void * NSFileTypeForHFSTypeCode(unsigned int);")
  (c-declare "extern void NSFreeHashTable(void *);")
  (c-declare "extern void NSFreeMapTable(void *);")
  (c-declare "extern void * NSFullUserName(void);")
  (c-declare "extern const char * NSGetSizeAndAlignment(const char *, void *, void *);")
  (c-declare "extern void * NSGetUncaughtExceptionHandler(void);")
  (c-declare "extern unsigned int NSHFSTypeCodeFromFileType(void *);")
  (c-declare "extern void * NSHFSTypeOfFile(void *);")
  (c-declare "extern void * NSHashGet(void *, void *);")
  (c-declare "extern void NSHashInsert(void *, void *);")
  (c-declare "extern void * NSHashInsertIfAbsent(void *, void *);")
  (c-declare "extern void NSHashInsertKnownAbsent(void *, void *);")
  (c-declare "extern void NSHashRemove(void *, void *);")
  (c-declare "extern void * NSHomeDirectory(void);")
  (c-declare "extern void * NSHomeDirectoryForUser(void *);")
  (c-declare "extern void NSIncrementExtraRefCount(void *);")
  (c-declare "extern struct CGRect NSInsetRect(struct CGRect, double, double);")
  (c-declare "extern struct CGRect NSIntegralRect(struct CGRect);")
  (c-declare "extern struct CGRect NSIntegralRectWithOptions(struct CGRect, unsigned long long);")
  (c-declare "extern struct _NSRange NSIntersectionRange(struct _NSRange, struct _NSRange);")
  (c-declare "extern struct CGRect NSIntersectionRect(struct CGRect, struct CGRect);")
  (c-declare "extern bool NSIntersectsRect(struct CGRect, struct CGRect);")
  (c-declare "extern bool NSIsEmptyRect(struct CGRect);")
  (c-declare "extern unsigned long long NSLogPageSize(void);")
  (c-declare "extern void NSLogv(void *, void *);")
  (c-declare "extern void * NSMapGet(void *, void *);")
  (c-declare "extern void NSMapInsert(void *, void *, void *);")
  (c-declare "extern void * NSMapInsertIfAbsent(void *, void *, void *);")
  (c-declare "extern void NSMapInsertKnownAbsent(void *, void *, void *);")
  (c-declare "extern bool NSMapMember(void *, void *, void *, void *);")
  (c-declare "extern void NSMapRemove(void *, void *);")
  (c-declare "extern bool NSMouseInRect(struct CGPoint, struct CGRect, bool);")
  (c-declare "extern void * NSNextHashEnumeratorItem(void *);")
  (c-declare "extern bool NSNextMapEnumeratorPair(void *, void *, void *);")
  (c-declare "extern struct CGRect NSOffsetRect(struct CGRect, double, double);")
  (c-declare "extern void * NSOpenStepRootDirectory(void);")
  (c-declare "extern unsigned long long NSPageSize(void);")
  (c-declare "extern struct CGPoint NSPointFromString(void *);")
  (c-declare "extern bool NSPointInRect(struct CGPoint, struct CGRect);")
  (c-declare "extern void * NSProtocolFromString(void *);")
  (c-declare "extern struct _NSRange NSRangeFromString(void *);")
  (c-declare "extern unsigned long long NSRealMemoryAvailable(void);")
  (c-declare "extern void * NSReallocateCollectable(void *, unsigned long long, unsigned long long);")
  (c-declare "extern struct CGRect NSRectFromString(void *);")
  (c-declare "extern void NSRecycleZone(void *);")
  (c-declare "extern void NSResetHashTable(void *);")
  (c-declare "extern void NSResetMapTable(void *);")
  (c-declare "extern unsigned long long NSRoundDownToMultipleOfPageSize(unsigned long long);")
  (c-declare "extern unsigned long long NSRoundUpToMultipleOfPageSize(unsigned long long);")
  (c-declare "extern void * NSSearchPathForDirectoriesInDomains(unsigned long long, unsigned long long, bool);")
  (c-declare "extern void * NSSelectorFromString(void *);")
  (c-declare "extern void NSSetUncaughtExceptionHandler(void *);")
  (c-declare "extern void NSSetZoneName(void *, void *);")
  (c-declare "extern bool NSShouldRetainWithZone(void *, void *);")
  (c-declare "extern struct CGSize NSSizeFromString(void *);")
  (c-declare "extern void * NSStringFromClass(void *);")
  (c-declare "extern void * NSStringFromHashTable(void *);")
  (c-declare "extern void * NSStringFromMapTable(void *);")
  (c-declare "extern void * NSStringFromPoint(struct CGPoint);")
  (c-declare "extern void * NSStringFromProtocol(void *);")
  (c-declare "extern void * NSStringFromRange(struct _NSRange);")
  (c-declare "extern void * NSStringFromRect(struct CGRect);")
  (c-declare "extern void * NSStringFromSelector(void *);")
  (c-declare "extern void * NSStringFromSize(struct CGSize);")
  (c-declare "extern void * NSTemporaryDirectory(void);")
  (c-declare "extern struct _NSRange NSUnionRange(struct _NSRange, struct _NSRange);")
  (c-declare "extern struct CGRect NSUnionRect(struct CGRect, struct CGRect);")
  (c-declare "extern void * NSUserName(void);")
  (c-declare "extern void * NSZoneCalloc(void *, unsigned long long, unsigned long long);")
  (c-declare "extern void NSZoneFree(void *, void *);")
  (c-declare "extern void * NSZoneFromPointer(void *);")
  (c-declare "extern void * NSZoneMalloc(void *, unsigned long long);")
  (c-declare "extern void * NSZoneName(void *);")
  (c-declare "extern void * NSZoneRealloc(void *, void *, unsigned long long);")
  (c-declare "extern void * NXReadNSObjectFromCoder(void *);")

  (define-c-lambda NSAllHashTableObjects ((pointer void)) (pointer void) "NSAllHashTableObjects")
  (define-c-lambda NSAllMapTableKeys ((pointer void)) (pointer void) "NSAllMapTableKeys")
  (define-c-lambda NSAllMapTableValues ((pointer void)) (pointer void) "NSAllMapTableValues")
  (define-c-lambda NSAllocateCollectable (unsigned-int64 unsigned-int64) (pointer void) "NSAllocateCollectable")
  (define-c-lambda NSAllocateMemoryPages (unsigned-int64) (pointer void) "NSAllocateMemoryPages")
  (define-c-lambda NSAllocateObject ((pointer void) unsigned-int64 (pointer void)) (pointer void) "NSAllocateObject")
  (define-c-lambda NSClassFromString ((pointer void)) (pointer void) "NSClassFromString")
  (define-c-lambda NSCompareHashTables ((pointer void) (pointer void)) bool "NSCompareHashTables")
  (define-c-lambda NSCompareMapTables ((pointer void) (pointer void)) bool "NSCompareMapTables")
  (define-c-lambda NSContainsRect (CGRect CGRect) bool "NSContainsRect")
  (define-c-lambda NSCopyHashTableWithZone ((pointer void) (pointer void)) (pointer void) "NSCopyHashTableWithZone")
  (define-c-lambda NSCopyMapTableWithZone ((pointer void) (pointer void)) (pointer void) "NSCopyMapTableWithZone")
  (define-c-lambda NSCopyMemoryPages ((pointer void) (pointer void) unsigned-int64) void "NSCopyMemoryPages")
  (define-c-lambda NSCopyObject ((pointer void) unsigned-int64 (pointer void)) (pointer void) "NSCopyObject")
  (define-c-lambda NSCountHashTable ((pointer void)) unsigned-int64 "NSCountHashTable")
  (define-c-lambda NSCountMapTable ((pointer void)) unsigned-int64 "NSCountMapTable")
  (define-c-lambda NSCreateHashTable ((pointer void) unsigned-int64) (pointer void) "NSCreateHashTable")
  (define-c-lambda NSCreateHashTableWithZone ((pointer void) unsigned-int64 (pointer void)) (pointer void) "NSCreateHashTableWithZone")
  (define-c-lambda NSCreateMapTable ((pointer void) (pointer void) unsigned-int64) (pointer void) "NSCreateMapTable")
  (define-c-lambda NSCreateMapTableWithZone ((pointer void) (pointer void) unsigned-int64 (pointer void)) (pointer void) "NSCreateMapTableWithZone")
  (define-c-lambda NSCreateZone (unsigned-int64 unsigned-int64 bool) (pointer void) "NSCreateZone")
  (define-c-lambda NSDeallocateMemoryPages ((pointer void) unsigned-int64) void "NSDeallocateMemoryPages")
  (define-c-lambda NSDeallocateObject ((pointer void)) void "NSDeallocateObject")
  (define-c-lambda NSDecimalAdd ((pointer void) (pointer void) (pointer void) unsigned-int64) unsigned-int64 "NSDecimalAdd")
  (define-c-lambda NSDecimalCompact ((pointer void)) void "NSDecimalCompact")
  (define-c-lambda NSDecimalCompare ((pointer void) (pointer void)) int64 "NSDecimalCompare")
  (define-c-lambda NSDecimalCopy ((pointer void) (pointer void)) void "NSDecimalCopy")
  (define-c-lambda NSDecimalDivide ((pointer void) (pointer void) (pointer void) unsigned-int64) unsigned-int64 "NSDecimalDivide")
  (define-c-lambda NSDecimalMultiply ((pointer void) (pointer void) (pointer void) unsigned-int64) unsigned-int64 "NSDecimalMultiply")
  (define-c-lambda NSDecimalMultiplyByPowerOf10 ((pointer void) (pointer void) int16 unsigned-int64) unsigned-int64 "NSDecimalMultiplyByPowerOf10")
  (define-c-lambda NSDecimalNormalize ((pointer void) (pointer void) unsigned-int64) unsigned-int64 "NSDecimalNormalize")
  (define-c-lambda NSDecimalPower ((pointer void) (pointer void) unsigned-int64 unsigned-int64) unsigned-int64 "NSDecimalPower")
  (define-c-lambda NSDecimalRound ((pointer void) (pointer void) int64 unsigned-int64) void "NSDecimalRound")
  (define-c-lambda NSDecimalString ((pointer void) (pointer void)) (pointer void) "NSDecimalString")
  (define-c-lambda NSDecimalSubtract ((pointer void) (pointer void) (pointer void) unsigned-int64) unsigned-int64 "NSDecimalSubtract")
  (define-c-lambda NSDecrementExtraRefCountWasZero ((pointer void)) bool "NSDecrementExtraRefCountWasZero")
  (define-c-lambda NSDefaultMallocZone () (pointer void) "NSDefaultMallocZone")
  (define-c-lambda NSDivideRect (CGRect (pointer void) (pointer void) double unsigned-int64) void "NSDivideRect")
  (define-c-lambda NSEdgeInsetsEqual (NSEdgeInsets NSEdgeInsets) bool "NSEdgeInsetsEqual")
  (define-c-lambda NSEndHashTableEnumeration ((pointer void)) void "NSEndHashTableEnumeration")
  (define-c-lambda NSEndMapTableEnumeration ((pointer void)) void "NSEndMapTableEnumeration")
  (define-c-lambda NSEnumerateHashTable ((pointer void)) (pointer void) "NSEnumerateHashTable")
  (define-c-lambda NSEnumerateMapTable ((pointer void)) (pointer void) "NSEnumerateMapTable")
  (define-c-lambda NSEqualPoints (CGPoint CGPoint) bool "NSEqualPoints")
  (define-c-lambda NSEqualRects (CGRect CGRect) bool "NSEqualRects")
  (define-c-lambda NSEqualSizes (CGSize CGSize) bool "NSEqualSizes")
  (define-c-lambda NSExtraRefCount ((pointer void)) unsigned-int64 "NSExtraRefCount")
  (define-c-lambda NSFileTypeForHFSTypeCode (unsigned-int32) (pointer void) "NSFileTypeForHFSTypeCode")
  (define-c-lambda NSFreeHashTable ((pointer void)) void "NSFreeHashTable")
  (define-c-lambda NSFreeMapTable ((pointer void)) void "NSFreeMapTable")
  (define-c-lambda NSFullUserName () (pointer void) "NSFullUserName")
  (define-c-lambda NSGetSizeAndAlignment (char-string (pointer void) (pointer void)) char-string "NSGetSizeAndAlignment")
  (define-c-lambda NSGetUncaughtExceptionHandler () (pointer void) "NSGetUncaughtExceptionHandler")
  (define-c-lambda NSHFSTypeCodeFromFileType ((pointer void)) unsigned-int32 "NSHFSTypeCodeFromFileType")
  (define-c-lambda NSHFSTypeOfFile ((pointer void)) (pointer void) "NSHFSTypeOfFile")
  (define-c-lambda NSHashGet ((pointer void) (pointer void)) (pointer void) "NSHashGet")
  (define-c-lambda NSHashInsert ((pointer void) (pointer void)) void "NSHashInsert")
  (define-c-lambda NSHashInsertIfAbsent ((pointer void) (pointer void)) (pointer void) "NSHashInsertIfAbsent")
  (define-c-lambda NSHashInsertKnownAbsent ((pointer void) (pointer void)) void "NSHashInsertKnownAbsent")
  (define-c-lambda NSHashRemove ((pointer void) (pointer void)) void "NSHashRemove")
  (define-c-lambda NSHomeDirectory () (pointer void) "NSHomeDirectory")
  (define-c-lambda NSHomeDirectoryForUser ((pointer void)) (pointer void) "NSHomeDirectoryForUser")
  (define-c-lambda NSIncrementExtraRefCount ((pointer void)) void "NSIncrementExtraRefCount")
  (define-c-lambda NSInsetRect (CGRect double double) CGRect "NSInsetRect")
  (define-c-lambda NSIntegralRect (CGRect) CGRect "NSIntegralRect")
  (define-c-lambda NSIntegralRectWithOptions (CGRect unsigned-int64) CGRect "NSIntegralRectWithOptions")
  (define-c-lambda NSIntersectionRange (NSRange NSRange) NSRange "NSIntersectionRange")
  (define-c-lambda NSIntersectionRect (CGRect CGRect) CGRect "NSIntersectionRect")
  (define-c-lambda NSIntersectsRect (CGRect CGRect) bool "NSIntersectsRect")
  (define-c-lambda NSIsEmptyRect (CGRect) bool "NSIsEmptyRect")
  (define-c-lambda NSLogPageSize () unsigned-int64 "NSLogPageSize")
  (define-c-lambda NSLogv ((pointer void) (pointer void)) void "NSLogv")
  (define-c-lambda NSMapGet ((pointer void) (pointer void)) (pointer void) "NSMapGet")
  (define-c-lambda NSMapInsert ((pointer void) (pointer void) (pointer void)) void "NSMapInsert")
  (define-c-lambda NSMapInsertIfAbsent ((pointer void) (pointer void) (pointer void)) (pointer void) "NSMapInsertIfAbsent")
  (define-c-lambda NSMapInsertKnownAbsent ((pointer void) (pointer void) (pointer void)) void "NSMapInsertKnownAbsent")
  (define-c-lambda NSMapMember ((pointer void) (pointer void) (pointer void) (pointer void)) bool "NSMapMember")
  (define-c-lambda NSMapRemove ((pointer void) (pointer void)) void "NSMapRemove")
  (define-c-lambda NSMouseInRect (CGPoint CGRect bool) bool "NSMouseInRect")
  (define-c-lambda NSNextHashEnumeratorItem ((pointer void)) (pointer void) "NSNextHashEnumeratorItem")
  (define-c-lambda NSNextMapEnumeratorPair ((pointer void) (pointer void) (pointer void)) bool "NSNextMapEnumeratorPair")
  (define-c-lambda NSOffsetRect (CGRect double double) CGRect "NSOffsetRect")
  (define-c-lambda NSOpenStepRootDirectory () (pointer void) "NSOpenStepRootDirectory")
  (define-c-lambda NSPageSize () unsigned-int64 "NSPageSize")
  (define-c-lambda NSPointFromString ((pointer void)) CGPoint "NSPointFromString")
  (define-c-lambda NSPointInRect (CGPoint CGRect) bool "NSPointInRect")
  (define-c-lambda NSProtocolFromString ((pointer void)) (pointer void) "NSProtocolFromString")
  (define-c-lambda NSRangeFromString ((pointer void)) NSRange "NSRangeFromString")
  (define-c-lambda NSRealMemoryAvailable () unsigned-int64 "NSRealMemoryAvailable")
  (define-c-lambda NSReallocateCollectable ((pointer void) unsigned-int64 unsigned-int64) (pointer void) "NSReallocateCollectable")
  (define-c-lambda NSRectFromString ((pointer void)) CGRect "NSRectFromString")
  (define-c-lambda NSRecycleZone ((pointer void)) void "NSRecycleZone")
  (define-c-lambda NSResetHashTable ((pointer void)) void "NSResetHashTable")
  (define-c-lambda NSResetMapTable ((pointer void)) void "NSResetMapTable")
  (define-c-lambda NSRoundDownToMultipleOfPageSize (unsigned-int64) unsigned-int64 "NSRoundDownToMultipleOfPageSize")
  (define-c-lambda NSRoundUpToMultipleOfPageSize (unsigned-int64) unsigned-int64 "NSRoundUpToMultipleOfPageSize")
  (define-c-lambda NSSearchPathForDirectoriesInDomains (unsigned-int64 unsigned-int64 bool) (pointer void) "NSSearchPathForDirectoriesInDomains")
  (define-c-lambda NSSelectorFromString ((pointer void)) (pointer void) "NSSelectorFromString")
  (define-c-lambda NSSetUncaughtExceptionHandler ((pointer void)) void "NSSetUncaughtExceptionHandler")
  (define-c-lambda NSSetZoneName ((pointer void) (pointer void)) void "NSSetZoneName")
  (define-c-lambda NSShouldRetainWithZone ((pointer void) (pointer void)) bool "NSShouldRetainWithZone")
  (define-c-lambda NSSizeFromString ((pointer void)) CGSize "NSSizeFromString")
  (define-c-lambda NSStringFromClass ((pointer void)) (pointer void) "NSStringFromClass")
  (define-c-lambda NSStringFromHashTable ((pointer void)) (pointer void) "NSStringFromHashTable")
  (define-c-lambda NSStringFromMapTable ((pointer void)) (pointer void) "NSStringFromMapTable")
  (define-c-lambda NSStringFromPoint (CGPoint) (pointer void) "NSStringFromPoint")
  (define-c-lambda NSStringFromProtocol ((pointer void)) (pointer void) "NSStringFromProtocol")
  (define-c-lambda NSStringFromRange (NSRange) (pointer void) "NSStringFromRange")
  (define-c-lambda NSStringFromRect (CGRect) (pointer void) "NSStringFromRect")
  (define-c-lambda NSStringFromSelector ((pointer void)) (pointer void) "NSStringFromSelector")
  (define-c-lambda NSStringFromSize (CGSize) (pointer void) "NSStringFromSize")
  (define-c-lambda NSTemporaryDirectory () (pointer void) "NSTemporaryDirectory")
  (define-c-lambda NSUnionRange (NSRange NSRange) NSRange "NSUnionRange")
  (define-c-lambda NSUnionRect (CGRect CGRect) CGRect "NSUnionRect")
  (define-c-lambda NSUserName () (pointer void) "NSUserName")
  (define-c-lambda NSZoneCalloc ((pointer void) unsigned-int64 unsigned-int64) (pointer void) "NSZoneCalloc")
  (define-c-lambda NSZoneFree ((pointer void) (pointer void)) void "NSZoneFree")
  (define-c-lambda NSZoneFromPointer ((pointer void)) (pointer void) "NSZoneFromPointer")
  (define-c-lambda NSZoneMalloc ((pointer void) unsigned-int64) (pointer void) "NSZoneMalloc")
  (define-c-lambda NSZoneName ((pointer void)) (pointer void) "NSZoneName")
  (define-c-lambda NSZoneRealloc ((pointer void) (pointer void) unsigned-int64) (pointer void) "NSZoneRealloc")
  (define-c-lambda NXReadNSObjectFromCoder ((pointer void)) (pointer void) "NXReadNSObjectFromCoder")
  )
