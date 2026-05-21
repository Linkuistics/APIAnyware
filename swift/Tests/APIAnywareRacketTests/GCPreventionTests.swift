import Testing
import Foundation
@testable import APIAnywareRacket

// Nested under RacketBridgeSuites so the whole Racket-bridge group runs
// serially — see RacketBridgeSuites.swift. `activeCount` asserts on the
// process-global GC-prevention count, which other suites also mutate.
extension RacketBridgeSuites {

@Suite("GCPrevention")
struct GCPreventionTests {

    @Test("Prevent and allow GC returns valid handles")
    func preventAndAllow() {
        let str = ("prevent-gc-test" as NSString)
        let ptr = Unmanaged.passUnretained(str).toOpaque()

        let handle = preventGC(ptr)
        #expect(handle >= 0, "Handle should be non-negative")

        // Allowing should not crash
        allowGC(handle)
    }

    @Test("Multiple references get distinct handles")
    func distinctHandles() {
        let str1 = ("gc-test-1" as NSString)
        let str2 = ("gc-test-2" as NSString)
        let ptr1 = Unmanaged.passUnretained(str1).toOpaque()
        let ptr2 = Unmanaged.passUnretained(str2).toOpaque()

        let handle1 = preventGC(ptr1)
        let handle2 = preventGC(ptr2)

        #expect(handle1 != handle2, "Each reference should get a unique handle")

        allowGC(handle1)
        allowGC(handle2)
    }

    @Test("Same pointer can be registered multiple times")
    func samePointerMultipleHandles() {
        let str = ("gc-multi-test" as NSString)
        let ptr = Unmanaged.passUnretained(str).toOpaque()

        let handle1 = preventGC(ptr)
        let handle2 = preventGC(ptr)

        #expect(handle1 != handle2, "Same pointer registered twice gets different handles")

        // Releasing one handle should not affect the other
        allowGC(handle1)
        // handle2 still holds a reference — this is the expected behavior
        allowGC(handle2)
    }

    @Test("Active GC prevention count")
    func activeCount() {
        let str = ("gc-count-test" as NSString)
        let ptr = Unmanaged.passUnretained(str).toOpaque()

        // The RacketBridgeSuites parent runs all three Racket-bridge suites
        // serially, so no other test mutates the registry concurrently. The
        // snapshots below are still taken immediately before/after each
        // operation to keep the assertions self-contained and robust.

        let beforeAdd1 = gcPreventionCount()
        let h1 = preventGC(ptr)
        let afterAdd1 = gcPreventionCount()
        #expect(afterAdd1 > beforeAdd1, "preventGC should increase count")

        let beforeAdd2 = gcPreventionCount()
        let h2 = preventGC(ptr)
        let afterAdd2 = gcPreventionCount()
        #expect(afterAdd2 > beforeAdd2, "preventGC should increase count again")

        let beforeRemove1 = gcPreventionCount()
        allowGC(h1)
        let afterRemove1 = gcPreventionCount()
        #expect(afterRemove1 < beforeRemove1, "allowGC should decrease count")

        let beforeRemove2 = gcPreventionCount()
        allowGC(h2)
        let afterRemove2 = gcPreventionCount()
        #expect(afterRemove2 < beforeRemove2, "allowGC should decrease count again")
    }

    @Test("Allow non-existent handle is safe")
    func allowNonExistentHandle() {
        // Should not crash or have side effects
        allowGC(999_999)
    }
}

}
