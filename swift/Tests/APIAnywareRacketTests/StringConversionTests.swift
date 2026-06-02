import Testing
@testable import APIAnywareRacket

@Test func stringToNSStringCreatesValidObject() {
    let nsstr = stringToNSString("Hello")
    let len = nsstringLength(nsstr)
    #expect(len == 5)
    releaseObject(nsstr)
}

@Test func nsstringToStringRoundTrip() {
    let pool = autoreleasePoolPush()
    let original = "Hello, World!"
    let nsstr = stringToNSString(original)
    let cstr = nsstringToString(nsstr)!
    let result = String(cString: cstr)
    #expect(result == original)
    releaseObject(nsstr)
    autoreleasePoolPop(pool)
}

@Test func emptyStringRoundTrip() {
    let pool = autoreleasePoolPush()
    let nsstr = stringToNSString("")
    let len = nsstringLength(nsstr)
    #expect(len == 0)
    let cstr = nsstringToString(nsstr)!
    let result = String(cString: cstr)
    #expect(result == "")
    releaseObject(nsstr)
    autoreleasePoolPop(pool)
}

@Test func unicodeStringRoundTrip() {
    let pool = autoreleasePoolPush()
    // U+1F600 (grinning face) takes 2 UTF-16 code units (surrogate pair)
    let original = "Hi\u{1F600}!"
    let nsstr = stringToNSString(original)
    // NSString length counts UTF-16 code units: H=1, i=1, emoji=2, !=1
    let len = nsstringLength(nsstr)
    #expect(len == 5)
    let cstr = nsstringToString(nsstr)!
    let result = String(cString: cstr)
    #expect(result == original)
    releaseObject(nsstr)
    autoreleasePoolPop(pool)
}
