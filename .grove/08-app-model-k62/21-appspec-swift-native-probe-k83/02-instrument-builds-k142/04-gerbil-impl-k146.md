# gerbil-impl-k146

**Kind:** work

## Goal

Instrument the **gerbil** swift-native-probe impl (`targets/gerbil/app-implementations/
macos/swift-native-probe/swift-native-probe.ss`) to the k141 logging contract, author its
descriptor + a **new** `build.sh` (none exists), do the gerbil CreateML **per-target
generate + relink** (corpus present), rebuild, and CLI-smoke the full contract vocabulary.
**Last impl** of `instrument-builds-k142` — its retirement empties the node (a menu-quit
cascade check to `instrument-builds-k142`, then up to `appspec-swift-native-probe-k83`
which still has the live `forward-gen-live-run` child to grow next).

## Context — racket-impl-k144 (DONE) + chez-impl-k145 (sibling) are the references

gerbil is the **same 2-shape probe** (`CreateML.timestampSeed` free fn + `MLCreateError
Domain` constant), same contract, same ok-checks as racket/chez. Deltas from racket:

1. **No CreateML bring-in — corpus present** (racket's k144 collect+analyze produced the
   shared `platforms/macos/api/CreateML/{extracted,resolved}.json`). gerbil needs only its
   **per-target** steps: `apianyware-generate --target gerbil` (emits `targets/gerbil/
   bindings/macos/generated/createml/…` + the gerbil `@_cdecl` trampolines) then `swift
   build --product APIAnywareGerbil` (relink `targets/gerbil/adapters/macos`; **--product
   not --target**, [[swift_build_product_vs_target]]). Additive → no golden move.
2. **Events emit INLINE** — the drawing-canvas **gerbil** pattern
   (`targets/gerbil/app-implementations/macos/drawing-canvas/drawing-canvas.ss` + its
   `build.sh` + descriptor). Mirror that emitter shape (lifecycle triad + `[probe] result`
   with double-quoted `name`/string value + `[probe] complete count=2 …`).
3. **Gerbil build gotchas — flag before building:**
   - **gcc-15 shim** ([[gerbil_gcc15_drift]]): the bottle toolchain hardcodes gcc-15 but
     Homebrew ships gcc-16 only → `gxc` breaks with "gcc-15: command not found". Fix via
     the `/tmp/aw-gcc15-shim` symlink to gcc-16 (the drawing-canvas gerbil build did this).
   - **generics-shadow** ([[gerbil_values_coerce_shadow]]): never rely on a bare builtin
     name where gerbil generics are imported — e.g. an app-side `string-length` collides
     with the WKWebView `stringLength` re-export (`(except-in …)` it); bare `values` coerce
     needs `(lambda (v) v)`. Watch for these in the probe's emitter/UI code.

## The two shapes + known-good ok-checks (identical to racket; from the contract)

| shape | name | check | value render |
|---|---|---|---|
| `function` | `CreateML.timestampSeed` | **structural** — an integer returned (never value-equality) | bare number |
| `constant` | `CreateML.MLCreateErrorDomain` | `string=? "com.apple.CreateML"` | double-quoted |

`[probe] complete count=2 ok=2 all-ok=#t` is scenario 01's assertion. The parent BRIEF's
**Shared contract context** has the full porting checklist.

## Descriptor + build.sh

- **Descriptor** `swift-native-probe-impl.rkt`: copy racket's, swap `#:name "Swift-Native
  Probe (Gerbil)"`, `#:binary "/Applications/SwiftNativeProbe-gerbil.app"`, `#:bundle-id
  "com.linkuistics.swift-native-probe-gerbil"` ([[bundle_domain]]).
- **New `build.sh`:** mirror the drawing-canvas **gerbil** `build.sh` (bundler
  `apianyware-bundle-gerbil`; the gcc-15 shim setup). Prereq keyed on gerbil `generated/
  createml/` absent → `apianyware-generate --target gerbil` + `swift build --product
  APIAnywareGerbil`. App name `SwiftNativeProbe-gerbil`; PlistBuddy id override + re-sign;
  the headless revive smoke asserting the 5 contract lines.

## Done when

- CLI-smoke shows in `events.log`: `[lifecycle] startup` → 2× `[probe] result … ok=#t` →
  `[probe] complete count=2 ok=2 all-ok=#t` → `Swift-Native Probe opened.`.
- Descriptor + new `build.sh` authored; a `SwiftNativeProbe-gerbil.app` built with the
  suffixed id; gerbil `generated/createml/` + `APIAnywareGerbil` dylib carry the trampolines.
- Commit names `gerbil-impl-k146`. Retirement handoff: record for `forward-gen-live-run`
  whether the shared-layout three (racket/chez/gerbil) are byte-identical in emission
  (modulo the non-deterministic `timestampSeed` value line) + the four bundle sizes, so
  the ~3-scenario forward-gen suite can bind one target-agnostic assertion set.

## Notes

- Data homes here (ADR-0052); goldens-as-truth unmoved (CreateML additive).
- Never run the GUI from the CLI ([[use_testanyware]]) — the live GUI verify is
  `forward-gen-live-run`'s ([[vm_verify_every_app]]).
