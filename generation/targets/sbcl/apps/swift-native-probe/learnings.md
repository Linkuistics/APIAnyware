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

## Cross-cutting FINDING (reported, not fixed): Swift-overlay class names vs ObjC runtime names

`NSScanner` reaches the IR under its **Swift-overlay** name `"Scanner"` (the `NS`-stripped
import name). The emitter bakes `(register-objc-class 'ns:scanner "Scanner" "NSObject")`
from `cls.name`, but the **ObjC runtime** class is `"NSScanner"`. Consequences:

- `aw-resolve-bound-class` (the auto-wrap path) walks the live `object_getClass` →
  `class_getName` chain → sees `"NSScanner"` → not in `*objc-class-registry*` → wraps to the
  nearest registered ancestor (`ns:ns-object`), so a Swift-native **method** specialized on
  `ns:scanner` gets *no applicable method*.
- `make-instance 'ns:scanner` (construct) does `aw-class "Scanner"` → `objc_getClass("Scanner")`
  → **nil** → fails.

So `ns:scanner` is unreachable through the natural construct/wrap paths; only the method
trampoline itself works (it takes the receiver pointer, name-agnostic). **Workaround used
here:** build over the real ObjC class and force the CLOS type —
`(make-instance 'ns:scanner :ptr (… alloc/initWithString: over (aw-class "NSScanner") …))`
— after which `ns:scan-up-to-string` dispatches.

This is an **IR/analysis-level** naming issue (the class's recorded `name`), almost
certainly shared with racket/chez/gerbil, and affects the family of Foundation utility
classes whose Swift overlay drops/renames `NS` (Scanner→NSScanner, the FileHandle/Notification
family, …). It does **NOT** affect the AppKit GUI ladder — NSButton/NSWindow/NSTextField/…
keep their ObjC names, so 040–090's GUI apps construct/dispatch normally. Recommend a
dedicated fix (register the ObjC runtime name, not the Swift overlay name, for
`register-objc-class`'s 2nd arg) as its own leaf; captured to the grove inbox.

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
