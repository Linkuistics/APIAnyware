# gerbil — FFI model (§18)

How the gerbil binding crosses into native code. The choices here are authored in
[`../target.apiw`](../target.apiw) (the `ffi-backend`/`runtime-model`/`projection-policy`/
`adapter-strategy` facets), [`../policies/macos/projection.apiw`](../policies/macos/projection.apiw)
(REFACTOR §23, the per-construct routing), and [`../adapters/macos/spec.apiw`](../adapters/macos/spec.apiw)
(REFACTOR §24–26, the native adapter). This page is their prose; the mechanism detail is
[`reference.md`](reference.md).

## One FFI, compiled per call site

Gerbil binds through **one** layer: `:std/foreign` `define-c-lambda`, Gerbil's typed C-FFI. ObjC
message dispatch is reached through it — a per-signature `define-c-lambda` cast over `objc_msgSend`
(`%msg-…`, emitted inline per class module's `begin-ffi` block) — not a separate ObjC-message
library. There is no two-library seam to cross (gerbil's contrast with racket's ffi2 +
`ffi/unsafe/objc` split, and a convergence with chez's single `foreign-procedure` layer).

`runtime-model = compiled-ffi` (ADR-0015/0017): gerbil open-codes **one typed native call per method
ABI signature at compile time** — the gxc → Gambit → C → native pipeline turns each `%msg-…`
crossing into a compiled `objc_msgSend` cast (~11 ns). This is the chez analogue of compiled
dispatch — a coercion-free typed crossing per distinct signature — reached by the Gambit compiler
rather than dynamically like racket's `interpreted-ffi`.

The hand-written runtime is **five Gerbil modules + one C companion** (`bindings/macos/generated/
runtime/`, README there), imported by every generated binding:

| module | holds |
|---|---|
| `runtime/ffi.ss` | C-safe libobjc seam: class/sel lookup, retain/release, autorelease pool, `string->nsstring`/`nsstring->string`, null + NSError-out-cell helpers — all `define-c-lambda` crossings |
| `runtime/objc.ss` | the class-graph root `(defclass NSObject (ptr) …)`, the ObjC-name→constructor registry + class-aware `wrap`, `->ptr`, the lifetime will, `with-autorelease-pool` / `define-entry-point`, the `nserror` record, and the `make-delegate` / `make-objc-block` bridges. Re-exports `ffi.ss` |
| `runtime/native-core.ss` | the ObjC native core: the generic `c-define` trampolines (one per return shape) that let an ObjC IMP or block call **back** into a Gerbil closure, plus the `objc_allocateClassPair`/`class_addMethod`/`objc_registerClassPair` plumbing |
| `runtime/subclass.ss` | the shadowing `defclass`/`defmethod`/`new` for transparent subclassing — imported **only** by app code that subclasses |
| `runtime/cocoa.ss` | geometry constructors (`make-rect`/`make-point`/…) + the standard app menu helper |
| `runtime/native_block.c` | the **one** clang `-fblocks` companion — the ObjC block literals (`^`) `make-objc-block` builds (the single TU the default gcc-15 cannot parse) |

The Swift-native trampolines add `runtime/swift-trampoline.ss` + `runtime/async-bridge.ss`.

## The native core is gsc-compiled — no ObjC dylib

The defining gerbil choice (ADR-0017): the ObjC native core (`native-core.ss` + `native_block.c`)
is **gsc-compiled directly into every executable**, not shipped as a dylib. The callback / block /
delegate bridges and the main-thread bounce all live in this gsc-compiled Gerbil — the **second
ObjC home** is in Gerbil, not in a native unit. The *only* Swift compilation unit in the whole
build is the trampoline-only `libAPIAnywareGerbil.dylib` (ADR-0029), admitted solely because a
Swift-native API can be reached only from Swift; it does not absorb the native core.

## The projection posture — thin-direct (trampoline elision)

`projection-policy = thin-direct`: the **vast directly-reachable ObjC surface is reached directly**
via a `define-c-lambda` cast over `objc_msgSend` (trampoline-*elided*) — the native dylib is **not
in that path**. Only the **Swift-native residual** (USR `s:` — unreachable across the Swift ABI from
Gerbil) plus pointer-valued constants cross the `APIAnywareGerbil` adapter. The gerbil binding is,
like racket and chez, a fully-elided limit of the complete-API model (CONTEXT.md *Trampoline
elision*).

The per-construct routing in [`../policies/macos/projection.apiw`](../policies/macos/projection.apiw)
(five choices):

| construct | spectrum | route |
|---|---|---|
| directly-reachable ObjC | `direct-call` | per-signature `define-c-lambda` over `objc_msgSend` in gsc — dylib not in path |
| Swift-native `async` | `adapter-call-plus-wrapper` | `AsyncBridge` completion-callback trampoline (ADR-0029/0030) + main-thread hop, wrapped by `runtime/swift-trampoline.ss` |
| Swift-native `throws` | `adapter-call-plus-wrapper` | `ThrowsBridge` trailing `NSError**` out-param, wrapped by `swift-trampoline.ss`'s `aw-swift-call/error` |
| Swift-native value return | `adapter-call` | `OpaqueHandle` boxes (ADR-0029); a **bound ObjC object** is instead handed back raw and wrapped Scheme-side via the ADR-0020 registry, never boxed |
| escaping callback | `adapter-call` | `make-delegate` / `make-objc-block` built by `native_block.c` in gerbil's **gsc ObjC home** (ADR-0022 main-thread bounce) — **not** this trampoline-only dylib |

## The native adapter — `APIAnywareGerbil` (trampoline-only)

The adapter dylib (`output { library "APIAnywareGerbil"; symbol-prefix "aw_gerbil_" }`, hermetic
per ADR-0011) is **strictly trampoline-only** (`adapter-strategy = trampoline-only`, ADR-0029): it
holds **only** the Swift-native residual. Its §26 roles in
[`../adapters/macos/spec.apiw`](../adapters/macos/spec.apiw) are just three —
`thread-adapter` (`AsyncBridge`'s async→completion hop via `MainActor.run`, the first gerbil async
path), `error-adapter` (`ThrowsBridge`'s thrown-`Error` → retained `NSError*` out-buffer), and
`generic-erasure-adapter` (`OpaqueHandle`) — with one `required` service, `main-thread-dispatch`
(`AsyncBridge` hops via `MainActor.run` under the ADR-0022 bounce). The `direct-call-policy`
**allows** directly-reachable ObjC and **denies** the three Swift-native constructs (they need the
trampolines).

This is the headline contrast with chez's `trampoline-and-bridges`: chez's dylib also hosts the
`foreign-callable` callback bridges, but **gerbil's callback/ObjC adaptation lives in gsc-compiled
Gerbil** (`native_block.c`), so the dylib carries no callback-registry / buffer / reflection roles —
those are in the gsc native core. The dylib is **necessary** (only Swift calls the Swift ABI) and
**per-target hermetic** (ADR-0010/0011). The Swift sources are under
[`../adapters/macos/sources/`](../adapters/macos/sources/) (`AsyncBridge.swift`,
`ThrowsBridge.swift`, `OpaqueHandle.swift`).

## See also

- [`representability.md`](representability.md) — how the thin-direct posture makes most APIs
  `exact-static` and only the residual drop down the ladder.
- [`reference.md`](reference.md) — the dual-surface dispatch, the native-core trampolines, and the
  toolchain bottle in full.
- [`../bindings/macos/docs/user-guide.md`](../bindings/macos/docs/user-guide.md) — the user-facing
  consequences (the `:gerbil-bindings/…` import model, the three dispatch surfaces, threading).
