import Testing
import Foundation
@testable import APIAnywareChez

@Test func retainReturnsSamePointer() {
    let obj = NSObject()
    let ptr = Unmanaged.passRetained(obj).toOpaque()
    let retained = retainObject(ptr)
    #expect(retained == ptr)
    releaseObject(ptr) // balance retain
    releaseObject(ptr) // balance passRetained
}

@Test func retainAndRelease() {
    let pool = autoreleasePoolPush()
    // Create NSString via our API
    let str = stringToNSString("Hello")
    // Retain gives us +2
    _ = retainObject(str)
    // Release back to +1
    releaseObject(str)
    // Release back to +0 (dealloc)
    releaseObject(str)
    autoreleasePoolPop(pool)
}
