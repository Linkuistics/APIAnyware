# TODO

Cross-cutting findings parked here (the grove inbox is being retired by a grove update).

## Swift-overlay class names vs ObjC runtime names break auto-wrap / construct

**Surfaced by:** `add-sbcl-clos-target` leaf 060/030 (swift-native-probe), 2026-06-21.
**Severity:** correctness bug for a family of Foundation classes; **does NOT block** the
sbcl GUI ladder (AppKit `NSButton`/`NSWindow`/`NSTextField`/… keep their ObjC names).
**Scope:** IR/analysis-level — likely shared across racket/chez/gerbil, not sbcl-only.

Classes whose **Swift overlay** drops or renames the `NS` prefix (`Scanner`→`NSScanner`,
`FileHandle`→`NSFileHandle`, `Notification`→`NSNotification`, …) reach the IR under their
Swift import name. The sbcl emitter bakes `(register-objc-class 'ns:<name> "<SwiftName>" …)`
from `cls.name`, but the **ObjC runtime** class name differs. Effect:

- `aw-resolve-bound-class` (the auto-wrap path) looks up the live `class_getName`
  (`"NSScanner"`) in `*objc-class-registry*` (which holds `"Scanner"`) → misses → wraps to
  the nearest registered ancestor (`ns:ns-object`), so a Swift-native method specialized on
  `ns:scanner` gets *no applicable method*.
- `make-instance 'ns:scanner` (construct) does `aw-class "Scanner"` → `objc_getClass("Scanner")`
  → **nil** → fails.

So the CLOS class is unreachable through the natural construct/wrap paths; only the
receiver-handle **method** trampoline works (it is pointer-based, name-agnostic).

**Workaround used in the probe** (`ns:scanner`): construct over the real ObjC class and
force the CLOS type — `(make-instance 'ns:scanner :ptr (… alloc/initWithString: over
(aw-class "NSScanner") …))`.

**Proposed fix:** register the ObjC **runtime** class name (not the Swift overlay name) as
`register-objc-class`'s 2nd arg — verify whether the IR already carries the runtime name
(the digester) or whether it must be derived. Worth a dedicated leaf; consider whether
racket/chez/gerbil need the same fix (probably yes). Then `ns:scanner` etc. construct and
auto-wrap normally and the probe's `:ptr` workaround can be removed.

**References:** `generation/targets/sbcl/apps/swift-native-probe/learnings.md`,
`generation/targets/sbcl/test-results/swift-native-probe/report.md`.
