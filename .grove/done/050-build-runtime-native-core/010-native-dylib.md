# 010-native-dylib

**Kind:** work

## Goal

Stand up **`libAPIAnywareSbcl`** — the SBCL target's **sole native compilation
unit** (ADR-0038): one SwiftPM dynamic-library target the runtime `load-shared-object`s
and the residual trampolines live in. Broader than gerbil's trampoline-only dylib
because SBCL has no ObjC-in-`gsc` home — so `CallbackBounce` + `SubclassSynth`
converge here too (but the MOP object model stays in Lisp; "trampoline-only" holds
in that sense).

- **SwiftPM target** `APIAnywareSbcl` in `swift/Package.swift`: add the `.library(…
  type: .dynamic, targets: ["APIAnywareSbcl"])` product + `.target` + test target,
  peer the existing `APIAnywareGerbil` block. Sources at
  `swift/Sources/APIAnywareSbcl/`. Inherits the package-wide `.macOS(.v26)` floor
  (ADR-0030, the `.v26` residual floor — design §4 / project memory).
- **The six files** (design §4 table):
  - `OpaqueHandle.swift` — `AwSbclValueBox` + the uniform `aw_sbcl_box_free` (peer
    `APIAnywareGerbil/OpaqueHandle.swift`).
  - `ThrowsBridge.swift` — the `NSError**` / Swift-`throws` out-param bridge that
    feeds `ns:cocoa-error` (ADR-0037); peer `APIAnywareGerbil/ThrowsBridge.swift`.
  - `AsyncBridge.swift` — async-method dispatch, completion delivered **on main**
    (ADR-0035); peer `APIAnywareGerbil/AsyncBridge.swift`.
  - `CallbackBounce.swift` — **new**: the foreign-thread → main-thread bounce
    (`dispatch_sync` value-returning / `dispatch_async` void) that re-enters the Lisp
    IMP. The ADR-0035 spine; a foreign thread must never run Lisp.
  - `SubclassSynth.swift` — **new**: build the per-signature **native bounce-shim
    IMP** and `class_addMethod` it (ADR-0034 §5). Lift the working mechanism from
    spike `2026-06-20-sbcl-mop-spike/4-subclass-synthesis.lisp` (the Lisp side drove
    `objc_allocateClassPair`; this is the Swift IMP-builder half it installs).
  - `Generated/Trampolines.swift` — the emitter-written `@_cdecl` residual
    (gitignored; produced by 040's `run_sbcl_trampolines`). 010 only ensures the
    `Generated/` dir + `.gitignore` + an empty/committed placeholder so `swift build`
    is green before `generate` has run.
- **Open item — the per-signature bounce-shim IMP mechanism (design §8, decide here):**
  a `@convention(c)` IMP is signature-specific. Choose **generated-per-selector**
  (one shim per overridable selector signature, emitted) **vs** a single
  **`NSInvocation`-forwarding** shim (one reflective trampoline). Record the decision
  + rationale inline (ADR-worthy only if it surprises; otherwise a design-spec §8
  resolution note). This choice gates 040 (subclass IMP install).

## Context

Node BRIEF (§4 dylib row + disk layout). Design spec §4 (`libAPIAnywareSbcl`, the
six-file table, entry naming, the `save-lisp-and-die` relive-split §5) + ADR-0038.
ADR-0035 (why the bounce, not activation — the 5/5 crash). ADR-0034 §5 (subclass
synthesis). Reference: the whole `swift/Sources/APIAnywareGerbil/` dylib (3 files —
this adds `CallbackBounce` + `SubclassSynth` + `Generated/`), `swift/Package.swift`
(the `APIAnywareGerbil` product/target block to peer). Spike:
`2026-06-20-sbcl-mop-spike/4-subclass-synthesis.lisp`, `…/5-startup-re-resolution.sh`.

## Done when

- `swift build` (the whole package) is green with the new `APIAnywareSbcl` target;
  `swift test --filter APIAnywareSbcl` (a smoke test target) passes.
- `libAPIAnywareSbcl.dylib` is produced; `nm -gU` shows `aw_sbcl_box_free` +
  the bounce/subclass entry points the runtime will `sb-alien`-bind.
- The bounce-shim IMP mechanism is **chosen** + recorded inline (gates 040).
- `Generated/Trampolines.swift` placeholder + `.gitignore` in place so the build is
  green pre-`generate`.

## Notes

- This is the only `swift build`-verifiable leaf — no SBCL needed. Do it first so
  the later Lisp leaves have a real dylib to `sb-alien`-bind against.
- Do **not** absorb the MOP object model (§2 stays Lisp). The dylib is the native
  *seam + residual*, not the object model.
