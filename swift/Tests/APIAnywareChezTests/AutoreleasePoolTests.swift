import Testing
@testable import APIAnywareChez

@Test func autoreleasePoolPushAndPop() {
    let pool = autoreleasePoolPush()
    autoreleasePoolPop(pool)
}

@Test func autoreleasePoolNesting() {
    let outer = autoreleasePoolPush()
    let inner = autoreleasePoolPush()
    autoreleasePoolPop(inner)
    autoreleasePoolPop(outer)
}

@Test func autoreleasePoolWithObjectCreation() {
    let pool = autoreleasePoolPush()
    // Create and use an object within the pool scope
    let str = stringToNSString("test")
    let len = nsstringLength(str)
    #expect(len == 4)
    releaseObject(str)
    autoreleasePoolPop(pool)
}
