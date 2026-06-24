// DelegateBridge.swift — Dynamic ObjC class creation with per-instance callback dispatch.
//
// Creates ObjC classes at runtime and dispatches method calls to registered
// C function pointers (provided by Racket, Chez, or Gerbil via their FFI).
//
// The dispatch model:
//   1. registerDelegate() creates a dynamic ObjC class with IMP trampolines
//   2. setDelegateHandler() registers a C callback for (instance, selector)
//   3. When ObjC calls the method, the trampoline looks up and calls the callback
//
// IMP trampolines are provided for common delegate signatures:
//   - void return: 0-3 pointer args
//   - bool return: 0-3 pointer args
//   - id return:   0-3 pointer args
//
// Exports:
//   aw_racket_register_delegate    — create class + alloc/init instance
//   aw_racket_set_method           — register callback for (instance, selector)
//   aw_racket_free_delegate        — remove instance from dispatch table

import Foundation

// MARK: - ObjC runtime imports

@_silgen_name("objc_allocateClassPair")
private func _allocateClassPair(
    _ superclass: UnsafeMutableRawPointer?,
    _ name: UnsafePointer<CChar>,
    _ extraBytes: Int
) -> UnsafeMutableRawPointer?

@_silgen_name("objc_registerClassPair")
private func _registerClassPair(_ cls: UnsafeMutableRawPointer)

@_silgen_name("class_addMethod")
private func _addMethod(
    _ cls: UnsafeMutableRawPointer,
    _ sel: Selector,
    _ imp: UnsafeMutableRawPointer,
    _ types: UnsafePointer<CChar>
) -> Bool

@_silgen_name("sel_getName")
private func _selGetName(_ sel: UnsafeMutableRawPointer) -> UnsafePointer<CChar>

@_silgen_name("class_getSuperclass")
private func _getSuperclass(_ cls: UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer?

// MARK: - Dispatch table

/// Lock protecting dispatchTable and classCounter from concurrent access.
/// ObjC can invoke delegate trampolines from any thread (timers, notifications, GCD).
private nonisolated(unsafe) var delegateLock = os_unfair_lock()

/// Per-instance dispatch: maps instance pointer (as Int) -> (selector string -> callback pointer).
private nonisolated(unsafe) var dispatchTable: [Int: [String: UnsafeMutableRawPointer]] = [:]

/// Per-instance GC handles: maps instance pointer (as Int) -> list of GC prevention handles.
/// Stored separately to ensure cleanup on dealloc.
private nonisolated(unsafe) var delegateGCHandles: [Int: [Int64]] = [:]

/// Class name counter for unique naming.
private nonisolated(unsafe) var classCounter: Int = 0

// MARK: - IMP trampolines
//
// Each trampoline is a @convention(c) function with the ObjC method signature:
//   (self, _cmd, arg0?, arg1?, arg2?) -> return_type
//
// It looks up the callback in dispatchTable and calls it with just the args
// (skipping self and _cmd, which are ObjC implementation details).

private func lookupCallback(
    _ selfPtr: UnsafeMutableRawPointer,
    _ cmdPtr: UnsafeMutableRawPointer
) -> UnsafeMutableRawPointer? {
    let key = Int(bitPattern: selfPtr)
    let selName = String(cString: _selGetName(cmdPtr))
    os_unfair_lock_lock(&delegateLock)
    let result = dispatchTable[key]?[selName]
    os_unfair_lock_unlock(&delegateLock)
    return result
}

// -- Void return trampolines --

private let impVoid0: @convention(c) (
    UnsafeMutableRawPointer, UnsafeMutableRawPointer
) -> Void = { selfPtr, cmdPtr in
    guard let cb = lookupCallback(selfPtr, cmdPtr) else { return }
    unsafeBitCast(cb, to: (@convention(c) () -> Void).self)()
}

private let impVoid1: @convention(c) (
    UnsafeMutableRawPointer, UnsafeMutableRawPointer, UnsafeMutableRawPointer?
) -> Void = { selfPtr, cmdPtr, arg0 in
    guard let cb = lookupCallback(selfPtr, cmdPtr) else { return }
    unsafeBitCast(cb, to: (@convention(c) (UnsafeMutableRawPointer?) -> Void).self)(arg0)
}

private let impVoid2: @convention(c) (
    UnsafeMutableRawPointer, UnsafeMutableRawPointer,
    UnsafeMutableRawPointer?, UnsafeMutableRawPointer?
) -> Void = { selfPtr, cmdPtr, arg0, arg1 in
    guard let cb = lookupCallback(selfPtr, cmdPtr) else { return }
    unsafeBitCast(cb, to: (@convention(c) (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> Void).self)(arg0, arg1)
}

private let impVoid3: @convention(c) (
    UnsafeMutableRawPointer, UnsafeMutableRawPointer,
    UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?
) -> Void = { selfPtr, cmdPtr, arg0, arg1, arg2 in
    guard let cb = lookupCallback(selfPtr, cmdPtr) else { return }
    unsafeBitCast(cb, to: (@convention(c) (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> Void).self)(arg0, arg1, arg2)
}

// -- Bool return trampolines --

private let impBool0: @convention(c) (
    UnsafeMutableRawPointer, UnsafeMutableRawPointer
) -> Bool = { selfPtr, cmdPtr in
    guard let cb = lookupCallback(selfPtr, cmdPtr) else { return false }
    return unsafeBitCast(cb, to: (@convention(c) () -> Bool).self)()
}

private let impBool1: @convention(c) (
    UnsafeMutableRawPointer, UnsafeMutableRawPointer, UnsafeMutableRawPointer?
) -> Bool = { selfPtr, cmdPtr, arg0 in
    guard let cb = lookupCallback(selfPtr, cmdPtr) else { return false }
    return unsafeBitCast(cb, to: (@convention(c) (UnsafeMutableRawPointer?) -> Bool).self)(arg0)
}

private let impBool2: @convention(c) (
    UnsafeMutableRawPointer, UnsafeMutableRawPointer,
    UnsafeMutableRawPointer?, UnsafeMutableRawPointer?
) -> Bool = { selfPtr, cmdPtr, arg0, arg1 in
    guard let cb = lookupCallback(selfPtr, cmdPtr) else { return false }
    return unsafeBitCast(cb, to: (@convention(c) (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> Bool).self)(arg0, arg1)
}

private let impBool3: @convention(c) (
    UnsafeMutableRawPointer, UnsafeMutableRawPointer,
    UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?
) -> Bool = { selfPtr, cmdPtr, arg0, arg1, arg2 in
    guard let cb = lookupCallback(selfPtr, cmdPtr) else { return false }
    return unsafeBitCast(cb, to: (@convention(c) (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> Bool).self)(arg0, arg1, arg2)
}

// -- Id (pointer) return trampolines --

private let impId0: @convention(c) (
    UnsafeMutableRawPointer, UnsafeMutableRawPointer
) -> UnsafeMutableRawPointer? = { selfPtr, cmdPtr in
    guard let cb = lookupCallback(selfPtr, cmdPtr) else { return nil }
    return unsafeBitCast(cb, to: (@convention(c) () -> UnsafeMutableRawPointer?).self)()
}

private let impId1: @convention(c) (
    UnsafeMutableRawPointer, UnsafeMutableRawPointer, UnsafeMutableRawPointer?
) -> UnsafeMutableRawPointer? = { selfPtr, cmdPtr, arg0 in
    guard let cb = lookupCallback(selfPtr, cmdPtr) else { return nil }
    return unsafeBitCast(cb, to: (@convention(c) (UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer?).self)(arg0)
}

private let impId2: @convention(c) (
    UnsafeMutableRawPointer, UnsafeMutableRawPointer,
    UnsafeMutableRawPointer?, UnsafeMutableRawPointer?
) -> UnsafeMutableRawPointer? = { selfPtr, cmdPtr, arg0, arg1 in
    guard let cb = lookupCallback(selfPtr, cmdPtr) else { return nil }
    return unsafeBitCast(cb, to: (@convention(c) (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer?).self)(arg0, arg1)
}

private let impId3: @convention(c) (
    UnsafeMutableRawPointer, UnsafeMutableRawPointer,
    UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?
) -> UnsafeMutableRawPointer? = { selfPtr, cmdPtr, arg0, arg1, arg2 in
    guard let cb = lookupCallback(selfPtr, cmdPtr) else { return nil }
    return unsafeBitCast(cb, to: (@convention(c) (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer?).self)(arg0, arg1, arg2)
}

// -- Int32 (C int) return trampolines --
// Matches ObjC type encoding "i" (32-bit signed int). Use for delegate
// methods declared as `int` in headers — distinct from NSInteger (64-bit).

private let impInt0: @convention(c) (
    UnsafeMutableRawPointer, UnsafeMutableRawPointer
) -> Int32 = { selfPtr, cmdPtr in
    guard let cb = lookupCallback(selfPtr, cmdPtr) else { return 0 }
    return unsafeBitCast(cb, to: (@convention(c) () -> Int32).self)()
}

private let impInt1: @convention(c) (
    UnsafeMutableRawPointer, UnsafeMutableRawPointer, UnsafeMutableRawPointer?
) -> Int32 = { selfPtr, cmdPtr, arg0 in
    guard let cb = lookupCallback(selfPtr, cmdPtr) else { return 0 }
    return unsafeBitCast(cb, to: (@convention(c) (UnsafeMutableRawPointer?) -> Int32).self)(arg0)
}

private let impInt2: @convention(c) (
    UnsafeMutableRawPointer, UnsafeMutableRawPointer,
    UnsafeMutableRawPointer?, UnsafeMutableRawPointer?
) -> Int32 = { selfPtr, cmdPtr, arg0, arg1 in
    guard let cb = lookupCallback(selfPtr, cmdPtr) else { return 0 }
    return unsafeBitCast(cb, to: (@convention(c) (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> Int32).self)(arg0, arg1)
}

private let impInt3: @convention(c) (
    UnsafeMutableRawPointer, UnsafeMutableRawPointer,
    UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?
) -> Int32 = { selfPtr, cmdPtr, arg0, arg1, arg2 in
    guard let cb = lookupCallback(selfPtr, cmdPtr) else { return 0 }
    return unsafeBitCast(cb, to: (@convention(c) (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> Int32).self)(arg0, arg1, arg2)
}

// -- Int64 (C long / NSInteger) return trampolines --
// Matches ObjC type encoding "q" (64-bit signed). NSInteger on 64-bit Apple
// platforms is typedef'd to `long`, which clang encodes as "q" — so this is
// the right return shape for any NSInteger-returning delegate method
// (e.g. -numberOfRowsInTableView:, -outlineView:numberOfChildrenOfItem:).

private let impLong0: @convention(c) (
    UnsafeMutableRawPointer, UnsafeMutableRawPointer
) -> Int64 = { selfPtr, cmdPtr in
    guard let cb = lookupCallback(selfPtr, cmdPtr) else { return 0 }
    return unsafeBitCast(cb, to: (@convention(c) () -> Int64).self)()
}

private let impLong1: @convention(c) (
    UnsafeMutableRawPointer, UnsafeMutableRawPointer, UnsafeMutableRawPointer?
) -> Int64 = { selfPtr, cmdPtr, arg0 in
    guard let cb = lookupCallback(selfPtr, cmdPtr) else { return 0 }
    return unsafeBitCast(cb, to: (@convention(c) (UnsafeMutableRawPointer?) -> Int64).self)(arg0)
}

private let impLong2: @convention(c) (
    UnsafeMutableRawPointer, UnsafeMutableRawPointer,
    UnsafeMutableRawPointer?, UnsafeMutableRawPointer?
) -> Int64 = { selfPtr, cmdPtr, arg0, arg1 in
    guard let cb = lookupCallback(selfPtr, cmdPtr) else { return 0 }
    return unsafeBitCast(cb, to: (@convention(c) (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> Int64).self)(arg0, arg1)
}

private let impLong3: @convention(c) (
    UnsafeMutableRawPointer, UnsafeMutableRawPointer,
    UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?
) -> Int64 = { selfPtr, cmdPtr, arg0, arg1, arg2 in
    guard let cb = lookupCallback(selfPtr, cmdPtr) else { return 0 }
    return unsafeBitCast(cb, to: (@convention(c) (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> Int64).self)(arg0, arg1, arg2)
}

// -- Dealloc trampoline --
// Called when the delegate's retain count hits 0. Defense-in-depth cleanup:
// releases all GC prevention handles and removes from dispatch table,
// then calls [super dealloc] via objc_msgSendSuper.

/// objc_msgSendSuper struct: { receiver, super_class }
private let impDealloc: @convention(c) (
    UnsafeMutableRawPointer, UnsafeMutableRawPointer
) -> Void = { selfPtr, _ in
    let key = Int(bitPattern: selfPtr)

    // Step 1: Clean up dispatch table and GC handles
    os_unfair_lock_lock(&delegateLock)
    let callbacks = dispatchTable.removeValue(forKey: key)
    let gcHandles = delegateGCHandles.removeValue(forKey: key)
    os_unfair_lock_unlock(&delegateLock)

    // Release all GC prevention handles
    if let handles = gcHandles {
        for handle in handles {
            allowGC(handle)
        }
    }

    // Silence unused variable warning — callbacks are freed by removing from table
    _ = callbacks

    // Step 2: Call [super dealloc] via objc_msgSendSuper
    // objc_msgSendSuper takes a pointer to { receiver, super_class }
    guard let msgSendSuperPtr = dlsym(
        UnsafeMutableRawPointer(bitPattern: -2)!, "objc_msgSendSuper"
    ) else { return }

    typealias MsgSendSuperF = @convention(c) (
        UnsafeMutableRawPointer, UnsafeMutableRawPointer
    ) -> Void

    // Get the class of self, then its superclass
    guard let objectGetClassPtr = dlsym(
        UnsafeMutableRawPointer(bitPattern: -2)!, "object_getClass"
    ) else { return }
    let objectGetClass = unsafeBitCast(
        objectGetClassPtr,
        to: (@convention(c) (UnsafeMutableRawPointer) -> UnsafeMutableRawPointer?).self
    )
    guard let selfClass = objectGetClass(selfPtr) else { return }
    guard let superclass = _getSuperclass(selfClass) else { return }

    // Build the objc_super struct on the stack: { receiver, super_class }
    let objcSuper = UnsafeMutableRawPointer.allocate(byteCount: 16, alignment: 8)
    objcSuper.storeBytes(of: selfPtr, as: UnsafeMutableRawPointer.self)
    objcSuper.advanced(by: 8).storeBytes(of: superclass, as: UnsafeMutableRawPointer.self)

    let deallocSel = unsafeBitCast(sel_registerName("dealloc"), to: UnsafeMutableRawPointer.self)
    let msgSendSuper = unsafeBitCast(msgSendSuperPtr, to: MsgSendSuperF.self)
    msgSendSuper(objcSuper, deallocSel)

    objcSuper.deallocate()
}

// MARK: - Trampoline selection

/// Select the appropriate IMP trampoline for the given return type and parameter count.
private func selectIMP(returnType: String, paramCount: Int) -> UnsafeMutableRawPointer {
    switch (returnType, paramCount) {
    case ("void", 0): return unsafeBitCast(impVoid0, to: UnsafeMutableRawPointer.self)
    case ("void", 1): return unsafeBitCast(impVoid1, to: UnsafeMutableRawPointer.self)
    case ("void", 2): return unsafeBitCast(impVoid2, to: UnsafeMutableRawPointer.self)
    case ("void", _): return unsafeBitCast(impVoid3, to: UnsafeMutableRawPointer.self)
    case ("bool", 0): return unsafeBitCast(impBool0, to: UnsafeMutableRawPointer.self)
    case ("bool", 1): return unsafeBitCast(impBool1, to: UnsafeMutableRawPointer.self)
    case ("bool", 2): return unsafeBitCast(impBool2, to: UnsafeMutableRawPointer.self)
    case ("bool", _): return unsafeBitCast(impBool3, to: UnsafeMutableRawPointer.self)
    case ("id", 0): return unsafeBitCast(impId0, to: UnsafeMutableRawPointer.self)
    case ("id", 1): return unsafeBitCast(impId1, to: UnsafeMutableRawPointer.self)
    case ("id", 2): return unsafeBitCast(impId2, to: UnsafeMutableRawPointer.self)
    case ("id", _): return unsafeBitCast(impId3, to: UnsafeMutableRawPointer.self)
    case ("int", 0): return unsafeBitCast(impInt0, to: UnsafeMutableRawPointer.self)
    case ("int", 1): return unsafeBitCast(impInt1, to: UnsafeMutableRawPointer.self)
    case ("int", 2): return unsafeBitCast(impInt2, to: UnsafeMutableRawPointer.self)
    case ("int", _): return unsafeBitCast(impInt3, to: UnsafeMutableRawPointer.self)
    case ("long", 0): return unsafeBitCast(impLong0, to: UnsafeMutableRawPointer.self)
    case ("long", 1): return unsafeBitCast(impLong1, to: UnsafeMutableRawPointer.self)
    case ("long", 2): return unsafeBitCast(impLong2, to: UnsafeMutableRawPointer.self)
    case ("long", _): return unsafeBitCast(impLong3, to: UnsafeMutableRawPointer.self)
    default:         return unsafeBitCast(impVoid0, to: UnsafeMutableRawPointer.self)
    }
}

/// Count colons in a selector name to determine parameter count.
private func selectorParamCount(_ selector: String) -> Int {
    selector.filter { $0 == ":" }.count
}

/// Build ObjC type encoding for a method.
/// Format: return_type self(@) _cmd(:) param_types(@...)
///
/// Encoding key (from clang ObjC ABI):
///   v = void, B = bool, @ = id (object), i = int32, q = int64.
/// "long" is mapped to "q" because NSInteger on 64-bit Apple platforms
/// is typedef'd to `long`, which clang encodes as "q".
private func typeEncoding(returnType: String, paramCount: Int) -> String {
    let ret: String
    switch returnType {
    case "bool": ret = "B"
    case "id":   ret = "@"
    case "int":  ret = "i"
    case "long": ret = "q"
    default:     ret = "v"
    }
    return ret + "@:" + String(repeating: "@", count: paramCount)
}

// MARK: - Public API

/// Create a delegate instance with the given method signatures.
///
/// - Parameters:
///   - selectors: Array of C strings (selector names)
///   - returnTypes: Array of C strings ("void", "bool", or "id")
///   - count: Number of selectors
/// - Returns: ObjC instance pointer (alloc+init'd NSObject subclass), or nil on failure
@_cdecl("aw_racket_register_delegate")
public func registerDelegate(
    _ selectors: UnsafePointer<UnsafePointer<CChar>?>,
    _ returnTypes: UnsafePointer<UnsafePointer<CChar>?>,
    _ count: Int32
) -> UnsafeMutableRawPointer? {
    // Get NSObject class pointer
    guard let nsObjectClass = NSClassFromString("NSObject") else { return nil }
    let superclassPtr = Unmanaged.passUnretained(nsObjectClass as AnyObject).toOpaque()

    // Generate unique class name
    os_unfair_lock_lock(&delegateLock)
    let className = "AWDelegate\(classCounter)"
    classCounter += 1
    os_unfair_lock_unlock(&delegateLock)

    // Allocate class pair
    guard let cls = className.withCString({ name in
        _allocateClassPair(superclassPtr, name, 0)
    }) else { return nil }

    // Add methods for each selector
    for i in 0..<Int(count) {
        guard let selCStr = selectors[i], let retCStr = returnTypes[i] else { continue }

        let selName = String(cString: selCStr)
        let retType = String(cString: retCStr)
        let paramCount = selectorParamCount(selName)

        let imp = selectIMP(returnType: retType, paramCount: paramCount)
        let encoding = typeEncoding(returnType: retType, paramCount: paramCount)

        let sel = sel_registerName(selCStr)
        encoding.withCString { encCStr in
            _ = _addMethod(cls, sel, imp, encCStr)
        }
    }

    // Add dealloc method for defense-in-depth cleanup
    let deallocSel = sel_registerName("dealloc")
    "v@:".withCString { encCStr in
        _ = _addMethod(
            cls, deallocSel,
            unsafeBitCast(impDealloc, to: UnsafeMutableRawPointer.self),
            encCStr
        )
    }

    // Register class
    _registerClassPair(cls)

    // Alloc + init
    let msgSendPtr = dlsym(UnsafeMutableRawPointer(bitPattern: -2)!, "objc_msgSend")!
    typealias AllocF = @convention(c) (UnsafeMutableRawPointer, UnsafeMutableRawPointer) -> UnsafeMutableRawPointer?
    let allocSel = unsafeBitCast(sel_registerName("alloc"), to: UnsafeMutableRawPointer.self)
    let initSel = unsafeBitCast(sel_registerName("init"), to: UnsafeMutableRawPointer.self)

    let msgSend = unsafeBitCast(msgSendPtr, to: AllocF.self)
    guard let allocated = msgSend(cls, allocSel) else { return nil }
    guard let instance = msgSend(allocated, initSel) else { return nil }

    // Initialize dispatch table entry and GC handle list for this instance
    let key = Int(bitPattern: instance)
    os_unfair_lock_lock(&delegateLock)
    dispatchTable[key] = [:]
    delegateGCHandles[key] = []
    os_unfair_lock_unlock(&delegateLock)

    return instance
}

/// Register a callback for a selector on a delegate instance.
///
/// - Parameters:
///   - instance: The delegate instance (from registerDelegate)
///   - selector: The selector name as a C string
///   - handler: C function pointer for the callback, or nil to remove
///
/// The callback signature must match the return type declared in registerDelegate:
///   - "void": `void callback(arg0?, arg1?, ...)`
///   - "bool": `bool callback(arg0?, arg1?, ...)`
///   - "id":   `id? callback(arg0?, arg1?, ...)`
@_cdecl("aw_racket_set_method")
public func setDelegateHandler(
    _ instance: UnsafeMutableRawPointer,
    _ selector: UnsafePointer<CChar>,
    _ handler: UnsafeMutableRawPointer?
) {
    let key = Int(bitPattern: instance)
    let selName = String(cString: selector)

    os_unfair_lock_lock(&delegateLock)
    if dispatchTable[key] == nil {
        dispatchTable[key] = [:]
    }

    if let handler = handler {
        dispatchTable[key]?[selName] = handler
        // Prevent GC of the callback and track the handle
        os_unfair_lock_unlock(&delegateLock)
        let gcHandle = preventGC(handler)
        os_unfair_lock_lock(&delegateLock)
        if delegateGCHandles[key] == nil {
            delegateGCHandles[key] = []
        }
        delegateGCHandles[key]?.append(gcHandle)
    } else {
        dispatchTable[key]?[selName] = nil
    }
    os_unfair_lock_unlock(&delegateLock)
}

/// Remove a delegate instance from the dispatch table.
/// After this, method calls on the instance will use default returns (void/false/nil).
@_cdecl("aw_racket_free_delegate")
public func freeDelegateDispatch(_ instance: UnsafeMutableRawPointer) {
    let key = Int(bitPattern: instance)
    os_unfair_lock_lock(&delegateLock)
    dispatchTable.removeValue(forKey: key)
    let gcHandles = delegateGCHandles.removeValue(forKey: key)
    os_unfair_lock_unlock(&delegateLock)

    // Release all GC prevention handles
    if let handles = gcHandles {
        for handle in handles {
            allowGC(handle)
        }
    }
}
