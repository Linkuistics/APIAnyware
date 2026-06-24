# Swift-Native Probe (gerbil)

A verification **probe**, not a portfolio sample app. It proves the complete-API
**Swift-native trampoline** mechanism (ADR-0025 / ADR-0027, ported to gerbil in
ADR-0029) works end-to-end in a real GUI app — the project done-bar that the
in-process CLI smoke (`runtime/tests/smoke-swift-trampoline.ss`) does not satisfy.

It opens an AppKit window showing two Swift-native CreateML decls, each reached
**only** through `libAPIAnywareGerbil`'s `@_cdecl` trampolines (bound via
`define-c-lambda`, the ADR-0017 idiom), never the framework dylib:

| Kind | Swift decl | Trampoline entry |
|---|---|---|
| free function | `CreateML.timestampSeed() -> Int` | `aw_gerbil_swift_CreateML_timestampSeed` |
| constant | `CreateML.MLCreateErrorDomain: String` | `aw_gerbil_swift_const_CreateML_MLCreateErrorDomain` |

Both carry `objc_exposed: false` and have no C symbol in `CreateML.framework`, so a
window that renders their live values is unambiguous evidence the Swift-native path
is bound (spec `docs/specs/2026-06-15-racket-trampoline.md` §6a).

Per ADR-0015 the gerbil `String` coercion is **Scheme-side**: the constant
trampoline returns an `id` (NSString) and `(gerbil-bindings createml constants)`
coerces it with the existing `aw-swift-string-result` — no native string bridge.
This is the gerbil counterpart of the racket / chez probes
(`generation/targets/{racket,chez}/apps/swift-native-probe/`).

Unlike chez (which `dlopen`s `libAPIAnywareChez`), gerbil **links** the dylib at
`gxc -exe` time (`-lAPIAnywareGerbil`, ADR-0029 §4), so the symbols resolve at
image load. `bundle-gerbil` vendors + relocates the dylib into
`Contents/Frameworks/` by the *same* path that already relocates openssl@3 (ADR-0029
§3), so `otool -L` on the bundled exe again shows only `/usr/lib/*`, system
frameworks, and `@executable_path/..`.

## Run / verify

GUI testing uses TestAnyware (never run apps from the CLI — see the apps README and
`feedback-use-testanyware`). The captured VM-verify screenshot is at
`../../test-results/swift-native-probe/screenshot.png`.

Build the standalone bundle (compiles the whole closure, links + relocates the
dylib):

```
SDKROOT=macosx cargo run -p apianyware-generate -- --target gerbil
(cd targets/gerbil/adapters/macos && SDKROOT=macosx swift build -c release --product APIAnywareGerbil)
cargo run --example bundle_app -p apianyware-bundle-gerbil -- swift-native-probe
```
