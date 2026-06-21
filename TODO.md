# TODO

Cross-target findings parked here (the grove inbox is being retired by a grove update).
Per-target work that belongs to an active grove is tracked as a grove leaf instead.

## Swift-overlay class names vs ObjC runtime names break auto-wrap / construct

**Surfaced by:** `add-sbcl-clos-target` leaf 060/030 (swift-native-probe), 2026-06-21.
**Severity:** correctness bug for a family of Foundation classes; **does NOT block** the
GUI ladders (AppKit `NSButton`/`NSWindow`/`NSTextField`/… keep their ObjC names).

- **sbcl:** tracked by grove leaf `.grove/100-fix-objc-runtime-class-naming.md` (this grove).
- **racket / chez / gerbil:** ← **still open here.** The class name comes from shared
  analysis-level IR, so these targets very likely share the same defect; each needs the same
  investigation (does its registry/dispatch key on the Swift-overlay name or the ObjC runtime
  name?) and, if affected, the same fix or an explicit "not affected" ruling.

### The defect

Classes whose **Swift overlay** drops or renames the `NS` prefix (`Scanner`→`NSScanner`,
`FileHandle`→`NSFileHandle`, `Notification`→`NSNotification`, …) reach the IR under their
Swift import name. A target that bakes its class-identity registry from that name (sbcl wrote
`(register-objc-class 'ns:scanner "Scanner" …)`) cannot match the live ObjC runtime name
(`"NSScanner"`):

- inbound auto-wrap looks up the runtime `class_getName` → misses → wraps to the nearest
  registered ancestor → a method specialized on the bound class gets *no applicable method*;
- construction (`objc_getClass(<swift-name>)`) returns nil → fails.

Only a pointer-based (receiver-handle) call works; the named construct/wrap paths don't.

### Proposed fix (per target)

Register / key the class-identity table on the ObjC **runtime** class name, not the Swift
overlay name. Verify whether the shared IR already carries the runtime name (the digester) or
whether it must be derived. See `generation/targets/sbcl/apps/swift-native-probe/learnings.md`
for the worked sbcl analysis (the sbcl fix itself is the grove leaf above).
