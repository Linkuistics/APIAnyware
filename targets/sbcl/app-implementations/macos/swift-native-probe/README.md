# swift-native-probe (sbcl target)

The 060 ladder's **§6d exemplar**: a verification *probe* (not a portfolio app) that proves
the complete-API Swift-native **trampoline** lower layer (ADR-0038, the racket spec §6d,
ported to sbcl) works end-to-end in a *loaded, dumped* GUI app — the bar the in-process 050
integration smoke (`lib/runtime/tests/smoke-integration.lisp`) does not satisfy. The sbcl
analogue of racket/chez/gerbil's `swift-native-probe`.

It calls **real** `objc_exposed: false` symbols (no C symbol exists in their frameworks —
each is reachable only through `libAPIAnywareSbcl`'s `aw_sbcl_swift_*` `@_cdecl` trampolines,
bound by typed `sb-alien`) and renders their live values. Five shapes (045/050 wired):

| Shape | Symbol | Value |
|---|---|---|
| free function | `CoreGraphics.hypot(3, 4)` | `5.0` |
| constant | `Foundation.NSNotFound` | `9223372036854775807` |
| class-owner init | `NSNumber(integerLiteral: 42)` | a real `ns:ns-number`, `intValue` 42 |
| class-owner method | `Scanner("APIAnyware:SBCL").scanUpToString(":")` | `"APIAnyware"` |
| value-opaque box | `IndexSet(5)` → `insert(7)` round-trip (opaque `AwSbclValueBox` handle) | `contains 7 = YES (was NO), contains 5 = YES` |

(The value-STRUCT-owner CLOS modelling and the async-method shape are deferred — 090 and a
design follow-up respectively.)

## AppSpec instrumentation (sbcl-impl-k143)

Instrumented for the AppSpec scenario runner per the k141 **logging contract**
(`apps/macos/swift-native-probe/docs/logging-contract.md`): `events.lisp` (the `snp-events`
package) writes the structured `events.log` the runner tails — `[lifecycle] startup` before
probing, one `[probe] result shape=… name="…" ok=<#t|#f> value=…` per shape (each an
explicit check vs a known-good expected), a `[probe] complete count=5 ok=5 all-ok=#t`
coverage summary (the single target-agnostic assertion scenario 01 consumes), the bare
`Swift-Native Probe opened.` launch line, and `[lifecycle] shutdown reason=menu` from an
`applicationWillTerminate:` delegate. Under `launch-via 'open` LaunchServices discards
stdout, so the log file (not stdout) is the runner's read path; the stdout echo is kept for
unbundled runs. The impl descriptor is `swift-native-probe-impl.rkt`
(`com.linkuistics.swift-native-probe-sbcl`).

## Build

```sh
targets/sbcl/app-implementations/macos/swift-native-probe/build.sh
```

Produces a **self-contained** `build/SwiftNativeProbe-sbcl.app` via the production bundler
(`apianyware-bundle-sbcl`, ADR-0041): a `save-lisp-and-die :executable t` image driven by
this app's own `dump.lisp`, a DYLD-fallback stub launcher, and **both** non-system dylibs
(`libzstd.1.dylib` + `libAPIAnywareSbcl.dylib`) vendored into `Contents/Frameworks/`. Unlike
hello-window, this app **depends on `libAPIAnywareSbcl`** (the §6d Swift-native residual + the
subclass bounce shim the terminate delegate uses); the dump records the
`@executable_path/../Frameworks/` namestring, so the revived image reopens the vendored copy
exe-relative (ADR-0038 §5). `build.sh` runs a host pre-flight + a bundled-image revive smoke
(`AW_PROBE_SMOKE`) that both emit the full k141 contract before any VM round-trip. The bundle
**travels alone** — no `/tmp` staging, no VM provisioning beyond the `.app`.

## VM-verify (never run GUI apps from the CLI — use TestAnyware)

The live-VM run + `docs/run-results.md` is `forward-gen-live-run-k144`'s. Because the bundle
is self-contained, VM-verify is: upload the `.app`, `xattr -dr com.apple.quarantine`,
`open -n` (or drive the AppSpec runner with `--impl swift-native-probe-impl.rkt`).
