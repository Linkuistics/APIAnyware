import Testing
@testable import APIAnywareChez

@Test func getClassFindsNSObject() {
    let cls = getClass("NSObject")
    #expect(cls != nil)
}

@Test func getClassFindsNSString() {
    let cls = getClass("NSString")
    #expect(cls != nil)
}

@Test func getClassReturnsNilForUnknownClass() {
    let cls = getClass("NonExistentClass12345")
    #expect(cls == nil)
}

@Test func registerSelectorReturnsNonNil() {
    let sel = registerSelector("init")
    // Selectors are interned — same name always gives same pointer
    let sel2 = registerSelector("init")
    #expect(sel == sel2)
}

@Test func differentSelectorsReturnDifferentPointers() {
    let sel1 = registerSelector("init")
    let sel2 = registerSelector("alloc")
    #expect(sel1 != sel2)
}
