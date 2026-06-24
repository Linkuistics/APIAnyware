// AutoreleasePool.swift — Autorelease pool push/pop via ObjC runtime.
// Exports: aw_racket_autorelease_push, aw_racket_autorelease_pop

@_silgen_name("objc_autoreleasePoolPush")
private func _autoreleasePoolPush() -> UnsafeMutableRawPointer

@_silgen_name("objc_autoreleasePoolPop")
private func _autoreleasePoolPop(_ pool: UnsafeMutableRawPointer)

/// Push a new autorelease pool. Returns an opaque token to pass to pop.
@_cdecl("aw_racket_autorelease_push")
public func autoreleasePoolPush() -> UnsafeMutableRawPointer {
    _autoreleasePoolPush()
}

/// Pop (drain) an autorelease pool. All objects autoreleased since the
/// matching push are released.
@_cdecl("aw_racket_autorelease_pop")
public func autoreleasePoolPop(_ pool: UnsafeMutableRawPointer) {
    _autoreleasePoolPop(pool)
}
