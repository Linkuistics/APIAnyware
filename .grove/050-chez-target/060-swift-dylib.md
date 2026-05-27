# 060-swift-dylib

**Kind:** work

## Goal
Build `libAPIAnywareChez.dylib` end-to-end. Three Swift source files in
`swift/Sources/APIAnywareChez/` (the directory and the SwiftPM target
already exist):

- `BlockBridge.swift` — exports `aw_chez_create_block(invoke:) ->
  UnsafeMutableRawPointer` and `aw_chez_release_block(block:)`. Mirrors
  `APIAnywareRacket/BlockBridge.swift`'s ABI handling
  (`_NSConcreteGlobalBlock`, `BLOCK_HAS_COPY_DISPOSE` flag, arm64e
  PAC-signed invoke pointer) but is parameter-compatible with the
  `foreign-callable` pointers chez provides.
- `DelegateBridge.swift` — exports
  `aw_chez_register_delegate(selectors:, return_types:, count:)`,
  `aw_chez_set_method(delegate:, selector:, callable:)`,
  `aw_chez_free_delegate(delegate:)`. Delegate class is a Swift class
  with per-selector callable trampolines, mirroring the racket flavour.
- `GCPrevention.swift` — implementation decided during this leaf. If the
  guardian + `lock-object` model handles all GC-prevention concerns,
  this file is empty (or absent and the SwiftPM target compiles without
  it). If Swift-side pinning is needed, mirror
  `APIAnywareRacket/GCPrevention.swift`.

Also: replace the existing `swift/Sources/APIAnywareChez/ChezFFI.swift`
stub with an actual entry-point file (or delete it — three discrete
files may be cleaner than one umbrella).

## Context
- `swift/Sources/APIAnywareRacket/{BlockBridge,DelegateBridge,GCPrevention}.swift`
  for the ABI patterns.
- `swift/Sources/APIAnywareCommon/` for the symbols this dylib does
  *not* re-implement (autorelease, retain/release, class lookup, etc.)
  — `APIAnywareCommon` is statically embedded by the SwiftPM build.
- The chez-side consumer surface — `runtime/dispatch.sls` (leaf 040) is
  the caller; the symbol names and signatures must align with what 040
  expects.

## Done when
- `cd swift && swift build` produces
  `.build/<arch>-apple-macosx/debug/libAPIAnywareChez.dylib`.
- `generation/targets/chez/lib/libAPIAnywareChez.dylib` symlink points
  at the built dylib (mirror the racket target's symlink convention).
- The smoke tests from leaves 030 and 040 still pass after switching
  their `(load-shared-object …)` calls from
  `libAPIAnywareRacket.dylib` (the temporary borrowing arrangement)
  to `libAPIAnywareChez.dylib`.
- The Swift test target (`APIAnywareCommonTests`) still passes.

## Notes
- The Swift-side delegate trampolines need to invoke the Scheme-side
  `foreign-callable` pointers. Document the calling-convention contract
  in `DelegateBridge.swift`'s file header so future Swift changes don't
  silently break the chez side.
- The 030 leaf's note mentions a temporary "use racket's dylib"
  arrangement. This leaf is the deadline for that arrangement —
  remove the cross-borrow before retiring.
