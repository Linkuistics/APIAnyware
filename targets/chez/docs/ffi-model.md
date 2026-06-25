# chez — FFI model (§18)

How the chez binding crosses into native code. The choices here are authored in
[`../target.apiw`](../target.apiw) (the `ffi-backend`/`runtime-model`/`projection-policy`/
`adapter-strategy` facets), [`../policies/macos/projection.apiw`](../policies/macos/projection.apiw)
(REFACTOR §23, the per-construct routing), and [`../adapters/macos/spec.apiw`](../adapters/macos/spec.apiw)
(REFACTOR §24–26, the native adapter). This page is their prose; the mechanism detail is
[`reference.md`](reference.md) §1–§4.

## One FFI, compiled per call site

Chez binds through **one** layer: `foreign-procedure`, Chez's native typed C-FFI. ObjC message
dispatch is reached through it — a typed `foreign-procedure` over `objc_msgSend` (and its
struct-return / fpret variants) — not a separate ObjC-message library. There is no two-library
seam to cross (chez's contrast with racket's ffi2 + `ffi/unsafe/objc` split).

`runtime-model = compiled-ffi` (ADR-0015): chez open-codes **one typed native call per method ABI
signature at compile time**. This is the chez analogue of racket's generated typed dispatch
(ADR-0013) — a coercion-free typed crossing per distinct signature — but reached by Chez's compiler
rather than by generating and dynamically loading dispatch entries. The cost racket pays in
dynamism (`interpreted-ffi`) chez never incurs: the call site *is* the compiled `foreign-procedure`.

The hand-written runtime is **five clusters** (reference §1), imported in strict order
`ffi → objc → {dispatch, types, cocoa}`:

| cluster | holds |
|---|---|
| `runtime/ffi.sls` | mandatory dylib load, libobjc raw surface, `objc_msgSend` / `sel-register`, autoreleasepool primitives |
| `runtime/objc.sls` | the `objc-object` record, the guardian, `wrap`/`borrow`/`unwrap`, `define-entry-point`, the `nserror` record |
| `runtime/dispatch.sls` | block bridge, delegate bridge, dynamic-class bridge — all over one `foreign-callable` substrate |
| `runtime/types.sls` | geometry ftypes + ctors/accessors, NSString/NSArray/NSDictionary marshalling, `coerce-arg`, CoreFoundation bridging |
| `runtime/cocoa.sls` | non-FFI-primitive helpers (app menu, main-thread dispatch, autoresizing) |

The Swift-native trampolines add `runtime/swift-trampoline.sls` + `runtime/async-bridge.sls`.

## The projection posture — thin-direct (trampoline elision)

`projection-policy = thin-direct`: the **vast directly-reachable ObjC surface is reached directly**
via a typed `foreign-procedure` over `objc_msgSend` (trampoline-*elided*) — the native adapter is
**not in that path**. Only the **Swift-native residual** (USR `s:` — unreachable across the Swift
ABI from chez) plus pointer-valued constants cross the `APIAnywareChez` adapter. The chez binding
is, like racket, a fully-elided limit of the complete-API model (CONTEXT.md *Trampoline elision*).

The per-construct routing in [`../policies/macos/projection.apiw`](../policies/macos/projection.apiw)
(five choices):

| construct | spectrum | route |
|---|---|---|
| directly-reachable ObjC | `direct-call` | typed `foreign-procedure` per call site — adapter not in path |
| Swift-native `async` | `adapter-call-plus-wrapper` | `AsyncBridge` completion-callback trampoline (ADR-0030 addendum) + main-thread hop |
| Swift-native `throws` | `adapter-call-plus-wrapper` | `ThrowsBridge` trailing `NSError**` out-param, wrapped by `swift-trampoline.sls`'s `aw-call/error` |
| Swift-native value return | `adapter-call` | `OpaqueHandle` boxes (ADR-0027 ported to chez) |
| escaping callback | `adapter-call` | `BlockBridge` / `DelegateBridge` built from `foreign-callable` pointers; Scheme side roots the code object via `lock-object` |

## The native adapter — `APIAnywareChez`

The adapter dylib (`output { library "APIAnywareChez"; symbol-prefix "aw_chez_" }`, hermetic per
ADR-0011) classifies its functions by §26 role in
[`../adapters/macos/spec.apiw`](../adapters/macos/spec.apiw): `callback-adapter`
(`BlockBridge` + `DelegateBridge`), `thread-adapter` (`AsyncBridge`'s async→completion hop via
`MainActor.run`), `error-adapter` (`ThrowsBridge`), `lifetime-adapter` (`ChezRuntime` retain/release
+ autorelease pool, plus `GCPrevention` dispose accounting), `generic-erasure-adapter`
(`OpaqueHandle`), `buffer-adapter` (`ChezRuntime` NSString⇄UTF-8), `reflection-adapter`
(`ChezRuntime` class/selector lookup), and a chez-specific `utility-adapter` (`ChezFFI`).

The runtime services tell chez apart from racket: `main-thread-dispatch` and
`autorelease-pool-management` are `required`, but `callback-registry` is rated **`parity`** — the
native registry's `@_cdecl` exports exist only for cross-target parity; the chez runtime roots
callbacks **Scheme-side via `lock-object`** instead, and `BlockBridge` drives the registry
internally only for async dispose accounting.

The dylib is **necessary** (only Swift calls the Swift ABI) and **per-target hermetic** — it shares
no native substrate with the other targets (ADR-0010/0011; the autorelease-pool primitives were
*absorbed* from the former `APIAnywareCommon`). The Swift sources are under
[`../adapters/macos/sources/`](../adapters/macos/sources/); their design is
[`design/2026-06-02-chez-native-binding-design.md`](design/2026-06-02-chez-native-binding-design.md).

## See also

- [`representability.md`](representability.md) — how the thin-direct posture makes most APIs
  `exact-static` and only the residual drop down the ladder.
- [`reference.md`](reference.md) §3–§4 — the dispatch substrate + FFI type-coercion rules in full.
- [`../bindings/macos/docs/user-guide.md`](../bindings/macos/docs/user-guide.md) — the user-facing
  consequences (the `(apianyware …)` require model, threading, errors).
