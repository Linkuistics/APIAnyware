# chez-impl-k145

**Kind:** work

## Goal

Instrument the **chez** swift-native-probe impl (`targets/chez/app-implementations/macos/
swift-native-probe/swift-native-probe.sls`) to the k141 logging contract, author its
descriptor + a **new** `build.sh` (none exists), do the chez CreateML **per-target
generate + relink** (the corpus is already present — see below), rebuild, and CLI-smoke
that the full contract vocabulary emits.

## Context — racket-impl-k144 (DONE) is the reference template

Read the sibling `02-DONE-racket-impl-k144.md` + the just-committed racket impl
(`targets/racket/app-implementations/macos/swift-native-probe/`): chez is the **same
2-shape probe** (`CreateML.timestampSeed` free fn + `MLCreateErrorDomain` constant), same
contract, same ok-checks. Two deltas from racket:

1. **No CreateML bring-in confirm-gate — the corpus is already present.** racket's k144
   ran `collect --only CreateML` + `analyze --only CreateML`, so the **shared** corpus
   `platforms/macos/api/CreateML/{extracted,resolved}.json` exists in this worktree
   (gitignored, persists). chez needs only its **per-target** steps: `apianyware-generate
   --target chez` (emits `targets/chez/bindings/macos/generated/createml/{functions,
   constants}.sls` + the chez `@_cdecl` trampolines) then `swift build --product
   APIAnywareChez` (relink `targets/chez/adapters/macos`; **--product not --target**,
   [[swift_build_product_vs_target]]). No collect/analyze; no golden move (CreateML is
   additive — verified k144).
2. **Events emit INLINE** (no separate `events.rkt` module) — the drawing-canvas **chez**
   pattern (`targets/chez/app-implementations/macos/drawing-canvas/drawing-canvas.sls` +
   its `build.sh` + `drawing-canvas-impl.rkt`). Mirror that emitter shape: the lifecycle
   triad + `[probe] result` (with re-readable double-quoting for the `name` + the constant
   string value) + `[probe] complete count=2 …`.

## The two shapes + known-good ok-checks (identical to racket; from the contract)

| shape | name | check | value render |
|---|---|---|---|
| `function` | `CreateML.timestampSeed` | **structural** — an integer returned (time-derived, never value-equality) | bare number |
| `constant` | `CreateML.MLCreateErrorDomain` | `string=? "com.apple.CreateML"` | double-quoted |

`[probe] complete count=2 ok=2 all-ok=#t` is scenario 01's assertion. The parent BRIEF's
**Shared contract context** section has the full porting checklist (path/config env
`SWIFT_NATIVE_PROBE_*`, default `/tmp/swift-native-probe/events.log`, don't abort on a
failed probe, keep the stdout echo, `applicationWillTerminate:` → shutdown reason=menu).

## Descriptor + build.sh

- **Descriptor** `swift-native-probe-impl.rkt`: copy racket's, swap `#:name "Swift-Native
  Probe (Chez)"`, `#:binary "/Applications/SwiftNativeProbe-chez.app"`, `#:bundle-id
  "com.linkuistics.swift-native-probe-chez"` ([[bundle_domain]] — never com.apianyware.*).
- **New `build.sh`:** mirror the drawing-canvas **chez** `build.sh` (production bundler,
  `apianyware-bundle-chez`). Prereq keyed on `targets/chez/bindings/macos/generated/
  createml/functions.sls` absent → `apianyware-generate --target chez` + `swift build
  --product APIAnywareChez` (NOT the racket collect/analyze — corpus present). App name
  `SwiftNativeProbe-chez`; PlistBuddy id override + re-sign; add the AW_PROBE_SMOKE-style
  headless revive smoke if chez has an equivalent run-loop gate (else the drawing-canvas
  chez build.sh's own smoke shape), asserting the 5 contract lines.

## Done when

- CLI-smoke shows in `events.log`: `[lifecycle] startup` → 2× `[probe] result … ok=#t` →
  `[probe] complete count=2 ok=2 all-ok=#t` → `Swift-Native Probe opened.` (menu-quit
  shutdown is `forward-gen-live-run`'s live-VM concern).
- Descriptor + new `build.sh` authored; a `SwiftNativeProbe-chez.app` built with the
  suffixed id; chez `generated/createml/` + `APIAnywareChez` dylib carry the trampolines.
- Commit names `chez-impl-k145`. Handoff for gerbil: whether chez's inline emission is
  byte-identical to racket's modulo the non-deterministic `timestampSeed` value line;
  bundle size.

## Notes

- Data homes here (ADR-0052); goldens-as-truth unmoved (CreateML additive).
- Never run the GUI from the CLI ([[use_testanyware]]) — CLI-smoke = the headless
  build-time smoke (the live GUI verify is `forward-gen-live-run`'s, [[vm_verify_every_app]]).
