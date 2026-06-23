# swift-native-probe — learnings (sbcl target, 060 ladder, the §6d exemplar)

The verification probe for the Swift-native **trampoline** lower layer (ADR-0038, the
racket spec §6d). First app to (a) load a generated `functions.lisp`, (b) load
`:load-residual t` + the dylib, and (c) dump+revive **with** the dylib. As the forcing
function it surfaced one blocker (fixed) and one cross-cutting finding (reported).

## Blocker FIXED here: `t`/`nil` as a generated lambda-list formal (emitter)

`coregraphics/functions.lisp` named nine `CGAffineTransform*` formals `t` — the C
parameter name `CGAffineTransformInvert(_ t:)` kebab'd straight through. `t` (and `nil`)
are CL **defined constants**, illegal as lambda-list variables, so the whole file raised
`COMMON-LISP:T names a defined constant, and cannot be used …` at load — `(aw-app-load-
framework "CoreGraphics" :load-residual t)` failed entirely. hello-window never hit this
(it loaded `:load-residual nil`, pure ObjC, so no `functions.lisp`).

**Fix (emit-sbcl):** `naming::is_cl_reserved_formal(kebab) -> matches!("t" | "nil")`,
applied in **both** formal-emitting sites — `emit_functions::arg_name` (C functions) and
`emit_generics::arg_name` (CLOS method params) — falling back to the positional `argN`
exactly like an empty/wildcard label. After collision resolution `t-1` etc. are fine (only
the bare constant is reserved). Regenerated; the goldens are unchanged (no `t` param in the
TestKit/Foundation fixtures). This protects **every** app that loads the residual.

## Cross-cutting finding — FIXED in k38: Swift-overlay class names vs ObjC runtime names

**Original finding (now resolved).** `NSScanner` reached the IR under its **Swift-overlay**
name `"Scanner"` (the `NS`-stripped import name), so the emitter baked
`(register-objc-class 'ns:scanner "Scanner" "NSObject")` from `cls.name` even though the
**ObjC runtime** class is `"NSScanner"`. That stranded the Swift-native methods: a live
`NSScanner` auto-wrapped to `ns:ns-scanner` (the clang twin, registered correctly) while the
receiver-handle method `ns:scan-up-to-string` was specialized on a *separate*, unreachable
`ns:scanner`, and `make-instance 'ns:scanner` → `objc_getClass("Scanner")` → nil. The probe
worked around it with `(make-instance 'ns:scanner :ptr (… over (aw-class "NSScanner") …))`.

**Root cause + fix (k38).** Not just a naming bake — a **duplicate-class** problem. The Swift
overlay (`Scanner`, USR `c:objc(cs)NSScanner`) and the clang ObjC class (`NSScanner`) were
*two IR classes for one runtime class*, with the Swift-native methods on one and the ObjC
methods on the other, because the collection merge (`merge_swift_into_objc`) matches by
`name`. Fixed at the source: `extract-swift`'s `map_class` now keys an ObjC-bridged class on
its **ObjC runtime name recovered from the clang USR** (`objc_runtime_class_name`,
`c:objc(cs)NSScanner` / the `@M@…@objc(cs)` form → `NSScanner`). The by-name merge then
**unifies** the overlay with its clang twin into a single `ns:ns-scanner` carrying *both* the
ObjC `initWithString:` init and the Swift-native `ns:scan-up-to-string` method, registered
under the live `"NSScanner"`. ~31 Foundation duplicate classes collapsed (Scanner, FileHandle,
URLSession, the Unit* family, …; even the underscore-private `_NSKeyValueObservation`, which a
naive NS-prefix heuristic would miss but the USR handles). Being in **shared collection**, the
fix applies to **all targets** (racket/chez/gerbil dedup identically — discharges the repo-root
TODO item). Regression test: `extract-swift` `objc_bridged_class_uses_runtime_name_from_usr`
(+ infixed-USR / idempotent / swift-native guards).

**Probe now uses the natural path:** `(make-instance 'ns:ns-scanner :init-with-string @"…")`
— no `:ptr` workaround (see `probe-make-scanner`). The original finding did **NOT** affect the
AppKit GUI ladder (NSButton/NSWindow/… keep their ObjC names), so 040–090's GUI apps were
unaffected throughout.

## Patterns confirmed for later residual-using apps

- **The dylib must be loaded before any `aw_sbcl_*` call** and survives the dump via
  SBCL's `*shared-objects*` auto-reopen (ADR-0038 §5) **by its load-time path**. The dev
  build records a FIXED `/tmp/libAPIAnywareSbcl.dylib` so the VM needs only that one path
  provisioned; production `bundle-sbcl` (070) will relocate into `Contents/Frameworks/` +
  re-resolve exe-relative (post-dump `install_name_tool` is impossible — hello-window 070
  finding). The `otool -L` of the dumped exe shows only `libSystem` + `libzstd` (the dylib
  is dlopen'd, not linked), so VM deps are: libzstd + the residual dylib.
- **Swift `String` parameters take a Lisp string, not an `ns:ns-string`.** A residual
  binding (`ns:scan-up-to-string`) bridges the arg itself via `aw-swift-string-arg` (which
  calls `aw-make-nsstring` on a Lisp string). Passing `@"…"` (an `ns:ns-string` instance)
  is a type error. Object args take wrapped instances; String args take Lisp strings.
- **value-OPAQUE vs value-STRUCT-owner.** A non-class Swift value (IndexSet/CharacterSet/…)
  can be driven NOW as a raw `AwSbclValueBox` handle through hand-bound trampolines (init →
  method(box) → `aw-box-free`) — the value-opaque shape. Giving it a CLOS class +
  `make-instance` + receiver-specialized `defmethod` is the value-struct-owner shape, the
  parked **090** leaf. The probe uses the former and says so.
- **`NSColor` class methods** dispatch via the `(eql (find-class 'ns:ns-color))` specializer:
  `(ns:system-blue-color (find-class 'ns:ns-color))`, `(ns:secondary-label-color …)` — used
  for the row accent + footer colours.
