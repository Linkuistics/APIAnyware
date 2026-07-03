# Swift-Native Probe (chez)

A verification **probe**, not a portfolio sample app. It proves the complete-API
**Swift-native trampoline** mechanism (ADR-0025 / ADR-0027, ported to chez in
ADR-0028) works end-to-end in a real GUI app — the project done-bar that the
in-process CLI smoke (`runtime/tests/smoke-swift-trampoline.sls`) does not satisfy.

It opens an AppKit window showing two Swift-native CreateML decls, each reached
**only** through `libAPIAnywareChez`'s `@_cdecl` trampolines, never the framework
dylib:

| Shape | Swift decl | Trampoline entry | ok-check |
|---|---|---|---|
| function | `CreateML.timestampSeed() -> Int` | `aw_chez_swift_CreateML_timestampSeed` | structural — an exact integer returned (time-derived, never value-equality) |
| constant | `CreateML.MLCreateErrorDomain: String` | `aw_chez_swift_const_CreateML_MLCreateErrorDomain` | `string=? "com.apple.CreateML"` |

Both carry `objc_exposed: false` and have no C symbol in `CreateML.framework`, so a
window that renders their live values is unambiguous evidence the Swift-native path
is bound (spec `targets/racket/docs/design/2026-06-15-racket-trampoline.md` §6a; chez slice §6c).
This is the racket/chez/gerbil analogue of the sbcl `swift-native-probe` (whose
2-shape function/constant slice this is; sbcl merges in the method/init slice).

Per ADR-0015 the chez `String` coercion is **Scheme-side**: the constant trampoline
returns an `id` (NSString) and `(apianyware createml constants)` coerces it with the
existing `aw-string-result` — no native string bridge (the racket↔chez divergence
the 060 brief flags). This is the chez counterpart of the racket probe
(`targets/racket/app-implementations/macos/swift-native-probe/`).

## AppSpec instrumentation (chez-impl-k145)

Instrumented for the AppSpec scenario runner per the k141 **logging contract**
(`apps/macos/swift-native-probe/docs/logging-contract.md`): the impl writes the
structured `events.log` the runner tails — `[lifecycle] startup` before probing, one
`[probe] result shape=… name="…" ok=<#t|#f> value=…` per shape (each an explicit
check vs a known-good expected), a `[probe] complete count=2 ok=2 all-ok=#t` coverage
summary (the single target-agnostic assertion scenario 01 consumes), the bare
`Swift-Native Probe opened.` launch line, and `[lifecycle] shutdown reason=menu` from
an `applicationWillTerminate:` delegate. Events emit **inline** (`snp-` helpers, the
drawing-canvas chez house style, k135) — the racket sibling uses a separate
`events.rkt`; the emitted line grammar is byte-identical across both (modulo the
non-deterministic `timestampSeed` value). Under `launch-via 'open` LaunchServices
discards stdout, so the log file (not stdout) is the runner's read path; the stdout
echo is kept for unbundled runs. The impl descriptor is `swift-native-probe-impl.rkt`
(`com.linkuistics.swift-native-probe-chez`).

Setting `AW_PROBE_SMOKE` runs the whole probe + emits the full contract + builds the
window, then exits **without** the run loop (headless — no GUI is serviced), which is
`build.sh`'s source pre-flight + bundle revive smokes.

## Build

```sh
targets/chez/app-implementations/macos/swift-native-probe/build.sh
```

Produces a **self-contained** `build/SwiftNativeProbe-chez.app` via the production
bundler (`apianyware-bundle-chez`, whole-program compile). Because CreateML is
**not** in this worktree's chez bindings by default, `build.sh` self-heals it in — a
**targeted, additive, golden-neutral** per-target bring-in (`apianyware-generate
--target chez` → `swift build --product APIAnywareChez`, reusing the shared CreateML
corpus the racket sibling brought in; collect/analyze only if the corpus is also
absent) when `apianyware/createml/functions.sls` is missing (NOT a 153-framework
regen). `build.sh` then runs the `AW_PROBE_SMOKE` source pre-flight smoke and, after
the bundle, the bundle revive smoke — each emitting + asserting the full k141
contract on the host before any VM round-trip.

## VM-verify (never run GUI apps from the CLI — use TestAnyware)

The live-VM run + `docs/run-results.md` is `forward-gen-live-run`'s. GUI testing uses
TestAnyware (never run apps from the CLI — see the apps README and
`feedback-use-testanyware`). Because the bundle is self-contained, VM-verify is:
upload the `.app`, `xattr -dr com.apple.quarantine`, `open -n` (or drive the AppSpec
runner with `--impl swift-native-probe-impl.rkt`).
