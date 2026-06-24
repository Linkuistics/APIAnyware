# swift-native-probe (sbcl target)

The 060 ladder's **§6d exemplar**: a verification *probe* (not a portfolio app) that proves
the complete-API Swift-native **trampoline** lower layer (ADR-0038, the racket spec §6d,
ported to sbcl) works end-to-end in a *loaded, dumped* GUI app — the bar the in-process 050
integration smoke (`lib/runtime/tests/smoke-integration.lisp`) does not satisfy. The sbcl
analogue of racket/chez/gerbil's `swift-native-probe`.

It calls **real** `objc_exposed: false` symbols (no C symbol exists in their frameworks —
each is reachable only through `libAPIAnywareSbcl`'s `aw_sbcl_swift_*` `@_cdecl` trampolines,
bound by typed `sb-alien`) and renders their live values. Four shapes (045/050 wired):

| Shape | Symbol | Value |
|---|---|---|
| free function | `CoreGraphics.hypot(3, 4)` | `5.0` |
| constant | `Foundation.NSNotFound` | `9223372036854775807` |
| class-owner init | `NSNumber(integerLiteral: 42)` | a real `ns:ns-number`, `intValue` 42 |
| class-owner method | `Scanner("APIAnyware:SBCL").scanUpToString(":")` | `"APIAnyware"` |
| value-opaque box | `IndexSet(5)` → `insert(7)` round-trip (opaque `AwSbclValueBox` handle) | `contains 7 = YES (was NO), contains 5 = YES` |

(The value-STRUCT-owner CLOS modelling and the async-method shape are deferred — 090 and a
design follow-up respectively.)

## Build

```sh
# prerequisites: generated bindings fresh + the dylib built
SDKROOT=macosx cargo run -p apianyware-generate -- --target sbcl
SDKROOT=macosx swift build --package-path swift --product APIAnywareSbcl
# then:
targets/sbcl/app-implementations/macos/swift-native-probe/build.sh
```

Produces `build/SwiftNativeProbe.app` (a standalone `save-lisp-and-die :executable t` dump).
Unlike hello-window, this app **depends on `libAPIAnywareSbcl`**: the dump records the dylib
at `/tmp/libAPIAnywareSbcl.dylib` and the revived image auto-reopens it (ADR-0038 §5).

## VM-verify (never run GUI apps from the CLI — use TestAnyware)

Provision **two** dylibs in the VM (no SBCL install needed — the image is embedded):
`/opt/homebrew/opt/zstd/lib/libzstd.1.dylib` (SBCL core-compression dep) and
`/tmp/libAPIAnywareSbcl.dylib` (the §6d residual). Then upload the bundle, `xattr -dr
com.apple.quarantine`, `open -n`. See `test-results/swift-native-probe/report.md`.
