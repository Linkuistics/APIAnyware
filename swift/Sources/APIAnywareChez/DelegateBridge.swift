// DelegateBridge.swift — Dynamic ObjC class creation with per-instance
// callback dispatch, driven by Chez Scheme `foreign-callable` pointers.
//
// Calling-convention contract (kept stable across racket/chez/gerbil so
// the runtime side's selection of "void"/"bool"/"id"/"int"/"long" return
// shapes carries no language affinity):
//
//   IMP trampoline signature, as ObjC dispatches it:
//       return_type imp(self, _cmd, arg0?, arg1?, arg2?)
//
//   The trampoline strips self and _cmd and forwards arg0..argN-1 as
//   void* values to the Scheme-side callback obtained from Chez's
//   `foreign-callable-entry-point`. The Scheme procedure therefore
//   receives ONLY the method arguments — never self or _cmd.
//
// Future Swift changes here MUST preserve that contract; the chez
// runtime's `dispatch.sls` documents the mirror-image expectation and
// will break silently on signature drift. (For dynamic-class IMPs —
// where the Scheme proc DOES want self and _cmd — the chez runtime
// bypasses this file and uses libobjc's `class_addMethod` directly,
// with foreign-callable signatures that include the (self _cmd …)
// prefix.)
//
// Exports:
//   aw_chez_register_delegate   — create class + alloc/init instance
//   aw_chez_set_method          — register callback for (instance, selector)
//   aw_chez_free_delegate       — remove instance from dispatch table

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

private nonisolated(unsafe) var delegateLock = os_unfair_lock()

private nonisolated(unsafe) var dispatchTable: [Int: [String: UnsafeMutableRawPointer]] = [:]

private nonisolated(unsafe) var delegateGCHandles: [Int: [Int64]] = [:]

private nonisolated(unsafe) var classCounter: Int = 0

// MARK: - IMP trampolines
//
// Each trampoline is a @convention(c) function with the ObjC method
// signature (self, _cmd, arg0?, arg1?, arg2?) -> return_type. It looks
// up the callback in dispatchTable and forwards just the args.

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
// NSInteger on 64-bit Apple platforms is typedef'd to `long` (clang
// encodes as "q") — this is the right return shape for any
// NSInteger-returning delegate method.

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
// Called when the delegate's retain count hits 0. Defense-in-depth
// cleanup: releases all GC prevention handles and removes from dispatch
// table, then calls [super dealloc] via objc_msgSendSuper.

private let impDealloc: @convention(c) (
    UnsafeMutableRawPointer, UnsafeMutableRawPointer
) -> Void = { selfPtr, _ in
    let key = Int(bitPattern: selfPtr)

    os_unfair_lock_lock(&delegateLock)
    let callbacks = dispatchTable.removeValue(forKey: key)
    let gcHandles = delegateGCHandles.removeValue(forKey: key)
    os_unfair_lock_unlock(&delegateLock)

    if let handles = gcHandles {
        for handle in handles {
            chezAllowGC(handle)
        }
    }

    _ = callbacks

    guard let msgSendSuperPtr = dlsym(
        UnsafeMutableRawPointer(bitPattern: -2)!, "objc_msgSendSuper"
    ) else { return }

    typealias MsgSendSuperF = @convention(c) (
        UnsafeMutableRawPointer, UnsafeMutableRawPointer
    ) -> Void

    guard let objectGetClassPtr = dlsym(
        UnsafeMutableRawPointer(bitPattern: -2)!, "object_getClass"
    ) else { return }
    let objectGetClass = unsafeBitCast(
        objectGetClassPtr,
        to: (@convention(c) (UnsafeMutableRawPointer) -> UnsafeMutableRawPointer?).self
    )
    guard let selfClass = objectGetClass(selfPtr) else { return }
    guard let superclass = _getSuperclass(selfClass) else { return }

    let objcSuper = UnsafeMutableRawPointer.allocate(byteCount: 16, alignment: 8)
    objcSuper.storeBytes(of: selfPtr, as: UnsafeMutableRawPointer.self)
    objcSuper.advanced(by: 8).storeBytes(of: superclass, as: UnsafeMutableRawPointer.self)

    let deallocSel = unsafeBitCast(sel_registerName("dealloc"), to: UnsafeMutableRawPointer.self)
    let msgSendSuper = unsafeBitCast(msgSendSuperPtr, to: MsgSendSuperF.self)
    msgSendSuper(objcSuper, deallocSel)

    objcSuper.deallocate()
}

// MARK: - Trampoline selection

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

private func selectorParamCount(_ selector: String) -> Int {
    selector.filter { $0 == ":" }.count
}

/// Build ObjC type encoding for a method.
/// v = void, B = bool, @ = id, i = int32, q = int64 (NSInteger).
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
///   - returnTypes: Array of C strings ("void", "bool", "id", "int", "long")
///   - count: Number of selectors
/// - Returns: alloc+init'd NSObject-subclass instance pointer, or nil on failure
@_cdecl("aw_chez_register_delegate")
public func chezRegisterDelegate(
    _ selectors: UnsafePointer<UnsafePointer<CChar>?>,
    _ returnTypes: UnsafePointer<UnsafePointer<CChar>?>,
    _ count: Int32
) -> UnsafeMutableRawPointer? {
    guard let nsObjectClass = NSClassFromString("NSObject") else { return nil }
    let superclassPtr = Unmanaged.passUnretained(nsObjectClass as AnyObject).toOpaque()

    os_unfair_lock_lock(&delegateLock)
    let className = "AWChezDelegate\(classCounter)"
    classCounter += 1
    os_unfair_lock_unlock(&delegateLock)

    guard let cls = className.withCString({ name in
        _allocateClassPair(superclassPtr, name, 0)
    }) else { return nil }

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

    let deallocSel = sel_registerName("dealloc")
    "v@:".withCString { encCStr in
        _ = _addMethod(
            cls, deallocSel,
            unsafeBitCast(impDealloc, to: UnsafeMutableRawPointer.self),
            encCStr
        )
    }

    _registerClassPair(cls)

    let msgSendPtr = dlsym(UnsafeMutableRawPointer(bitPattern: -2)!, "objc_msgSend")!
    typealias AllocF = @convention(c) (UnsafeMutableRawPointer, UnsafeMutableRawPointer) -> UnsafeMutableRawPointer?
    let allocSel = unsafeBitCast(sel_registerName("alloc"), to: UnsafeMutableRawPointer.self)
    let initSel = unsafeBitCast(sel_registerName("init"), to: UnsafeMutableRawPointer.self)

    let msgSend = unsafeBitCast(msgSendPtr, to: AllocF.self)
    guard let allocated = msgSend(cls, allocSel) else { return nil }
    guard let instance = msgSend(allocated, initSel) else { return nil }

    let key = Int(bitPattern: instance)
    os_unfair_lock_lock(&delegateLock)
    dispatchTable[key] = [:]
    delegateGCHandles[key] = []
    os_unfair_lock_unlock(&delegateLock)

    return instance
}

/// Register a callback for a selector on a delegate instance.
///
/// Passing nil for `handler` removes the entry; the dispatch table will
/// then fall back to the default return for the selector's return type.
@_cdecl("aw_chez_set_method")
public func chezSetDelegateHandler(
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
        os_unfair_lock_unlock(&delegateLock)
        let gcHandle = chezPreventGC(handler)
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
/// After this, method calls on the instance use defaults (void/false/nil/0).
@_cdecl("aw_chez_free_delegate")
public func chezFreeDelegateDispatch(_ instance: UnsafeMutableRawPointer) {
    let key = Int(bitPattern: instance)
    os_unfair_lock_lock(&delegateLock)
    dispatchTable.removeValue(forKey: key)
    let gcHandles = delegateGCHandles.removeValue(forKey: key)
    os_unfair_lock_unlock(&delegateLock)

    if let handles = gcHandles {
        for handle in handles {
            chezAllowGC(handle)
        }
    }
}
