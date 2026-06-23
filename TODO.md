# TODO

Cross-target findings parked here (the grove inbox is being retired by a grove update).
Per-target work that belongs to an active grove is tracked as a grove leaf instead.

## ✅ RESOLVED — Swift-overlay class names vs ObjC runtime names break auto-wrap / construct

**Surfaced by:** `add-sbcl-clos-target` leaf 060/030 (swift-native-probe), 2026-06-21.
**Resolved:** `add-sbcl-clos-target` leaf `fix-objc-runtime-class-naming-k38`, 2026-06-23 —
fixed at the **shared collection** layer, so **all targets** (racket/chez/gerbil/sbcl) are
covered at once; the per-target rollout this TODO tracked is **discharged**.

### The defect (was)

Classes whose **Swift overlay** drops or renames the `NS` prefix (`Scanner`→`NSScanner`,
`FileHandle`→`NSFileHandle`, the `Unit*` family, the private `_NSKeyValueObservation`, …)
reached the IR under their Swift import name. Worse than a naming bake: the Swift overlay
(`Scanner`, USR `c:objc(cs)NSScanner`) and the clang ObjC class (`NSScanner`) were **two IR
classes for one runtime class**, because `merge_swift_into_objc` matches by `name` — so the
Swift-native methods and the ObjC methods landed on *different* CLOS classes, and the
overlay-named one (`ns:scanner`, registered `"Scanner"`) matched no live object.

### The fix

`collection/crates/extract-swift` `map_class` now keys an ObjC-bridged class on its **ObjC
runtime name recovered from the clang USR** (`objc_runtime_class_name`: `c:objc(cs)NSScanner`
and the `@M@…@objc(cs)` form → `NSScanner`). The existing by-name merge then **unifies** each
overlay with its clang twin into a single class registered under the live runtime name,
carrying both the ObjC init/methods and the Swift-native residual. ~31 Foundation duplicate
classes collapsed. Regression test: `objc_bridged_class_uses_runtime_name_from_usr` (+ infixed
/ idempotent / swift-native guards). Worked analysis:
`generation/targets/sbcl/apps/swift-native-probe/learnings.md`.

## racket / chez snapshot goldens are stale vs the current SDK (MacOSX26.5)

**Surfaced by:** verifying k38 (2026-06-23). The `emit-racket` real-IR snapshot subset tests
(`snapshot_racket_foundation_subset`, `snapshot_racket_appkit_subset`) fail **locally** against
SDK-26.5 enriched IR with drift unrelated to any code change — e.g. AppKit gained
`NSTextView.characterIndex(for:)`. Their goldens were bootstrapped on an older SDK (the racket
grove era). These tests **skip-as-pass without local IR**, so CI is green; the failure only
shows locally once the pipeline has been run. **Fix:** a deliberate goldens-as-truth refresh
(`UPDATE_GOLDEN=1`) on a controlled full pipeline run for the current SDK — a maintenance pass,
not part of any feature change (so SDK drift is not folded into an unrelated commit). sbcl and
gerbil goldens are already current (they were the only Foundation file that k38's dedup
changed, and that change was accepted).
