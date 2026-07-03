# Swift-Native Probe (racket)

A verification **probe**, not a portfolio sample app. It proves the complete-API
**Swift-native trampoline** mechanism (ADR-0025 / ADR-0027) works end-to-end in a
real GUI app — the project done-bar that the in-process CLI smoke does not satisfy.
The racket/chez/gerbil analogue of the sbcl `swift-native-probe` (whose 2-shape
function/constant slice this is; sbcl merges in the method/init slice).

It opens an AppKit window showing two Swift-native CreateML decls, each reached
**only** through `libAPIAnywareRacket`'s `@_cdecl` trampolines (`_aw-lib`), never
the framework dylib:

| Shape | Swift decl | Trampoline entry | ok-check |
|---|---|---|---|
| function | `CreateML.timestampSeed() -> Int` | `aw_racket_swift_CreateML_timestampSeed` | structural — an exact `Int` returned (time-derived, never value-equality) |
| constant | `CreateML.MLCreateErrorDomain: String` | `aw_racket_swift_const_CreateML_MLCreateErrorDomain` | `string=? "com.apple.CreateML"` |

Both carry `objc_exposed: false` and have no C symbol in `CreateML.framework`, so a
window that renders their live values is unambiguous evidence the Swift-native path
is bound (spec `targets/racket/docs/design/2026-06-15-racket-trampoline.md` §6a/§6b).

## AppSpec instrumentation (racket-impl-k144)

Instrumented for the AppSpec scenario runner per the k141 **logging contract**
(`apps/macos/swift-native-probe/docs/logging-contract.md`): `events.rkt` writes the
structured `events.log` the runner tails — `[lifecycle] startup` before probing, one
`[probe] result shape=… name="…" ok=<#t|#f> value=…` per shape (each an explicit
check vs a known-good expected), a `[probe] complete count=2 ok=2 all-ok=#t` coverage
summary (the single target-agnostic assertion scenario 01 consumes), the bare
`Swift-Native Probe opened.` launch line, and `[lifecycle] shutdown reason=menu` from
an `applicationWillTerminate:` delegate (SIGTERM/SIGINT → `reason=signal`, other
uncaught → `reason=error`). Under `launch-via 'open` LaunchServices discards stdout,
so the log file (not stdout) is the runner's read path; the stdout echo is kept for
unbundled runs. The impl descriptor is `swift-native-probe-impl.rkt`
(`com.linkuistics.swift-native-probe-racket`).

Setting `AW_PROBE_SMOKE` runs the whole probe + emits the full contract + builds the
window, then exits **without** the run loop (headless — no GUI is serviced), which is
`build.sh`'s host revive-smoke.

## Build

```sh
targets/racket/app-implementations/macos/swift-native-probe/build.sh
```

Produces a **self-contained** `build/SwiftNativeProbe-racket.app` via the production
bundler (`apianyware-bundle-racket`, `raco exe` + `raco distribute`): the module
graph + `libAPIAnywareRacket.dylib` travel inside the bundle, so the VM needs NOTHING
staged. Because CreateML is **not** in this worktree's base corpus, `build.sh`
self-heals it in — a **targeted, additive, golden-neutral** bring-in
(`apianyware-collect/analyze --only CreateML` → `apianyware-generate --target racket`
→ `swift build --product APIAnywareRacket`) when `generated/createml/functions.rkt`
is absent (NOT a 153-framework regen). `build.sh` then runs the `AW_PROBE_SMOKE`
revive smoke, which emits + asserts the full k141 contract on the host before any VM
round-trip.

## VM-verify (never run GUI apps from the CLI — use TestAnyware)

The live-VM run + `docs/run-results.md` is `forward-gen-live-run`'s. Because the
bundle is self-contained, VM-verify is: upload the `.app`, `xattr -dr
com.apple.quarantine`, `open -n` (or drive the AppSpec runner with `--impl
swift-native-probe-impl.rkt`).
