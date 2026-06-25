# racket — FFI model (§18)

How the racket binding crosses into native code. The choices here are authored in
[`../target.apiw`](../target.apiw) (the `ffi-backend`/`runtime-model`/`projection-policy`/
`adapter-strategy` facets), [`../policies/macos/projection.apiw`](../policies/macos/projection.apiw)
(REFACTOR §23, the per-construct routing), and [`../adapters/macos/spec.apiw`](../adapters/macos/spec.apiw)
(REFACTOR §24–26, the native adapter). This page is their prose; the mechanism detail is
[`reference.md`](reference.md) §0–§7.

## Two FFI layers, one seam

ffi2 (Racket 9.2's more-static C-binding library) is the **C-function layer**; ObjC **message
dispatch** stays on `ffi/unsafe/objc`, because ffi2 has no ObjC layer (resolved 2026-05-31). The
two coexist in one installation and values cross the seam via `id->ffi2-ptr` /`ffi2-ptr->id`
(`runtime/ffi2-seam.rkt`). See CONTEXT.md *ffi2* and
[`research/2026-05-31-racket-9.2-ffi2-migration.md`](research/2026-05-31-racket-9.2-ffi2-migration.md).

`runtime-model = interpreted-ffi` (ADR-0015): racket is the only target whose FFI call sites are
reached **dynamically** rather than open-coded at compile time. The cost of that dynamism is paid
back by **generated typed dispatch** (ADR-0013): the emitter generates one typed native dispatch
entry per distinct method ABI signature, so each call is a coercion-free typed crossing
(~5–6 ns/call, ~8× faster than generic msgSend on struct returns) bought with generated code at
zero hand-maintenance. See CONTEXT.md *Generated typed dispatch* and *Marshalling-depth spectrum*.

## The projection posture — thin-direct (trampoline elision)

`projection-policy = thin-direct`: the **vast directly-reachable ObjC surface is reached directly**
via `objc_msgSend` (trampoline-*elided*) — the native adapter is **not in that path**. Only the
**Swift-native residual** (USR `s:` — unreachable across the Swift ABI from racket) plus
pointer-valued constants cross the `APIAnywareRacket` adapter. The racket binding is the
fully-elided limit of the complete-API model (CONTEXT.md *Trampoline elision*).

The per-construct routing in [`../policies/macos/projection.apiw`](../policies/macos/projection.apiw):

| construct | spectrum | route |
|---|---|---|
| directly-reachable ObjC | `direct-call` | `ffi/unsafe/objc` `objc_msgSend` — adapter not in path |
| Swift-native `async` | `adapter-call-plus-wrapper` | `AsyncBridge` trampoline + main-thread hop (ADR-0027) |
| Swift-native `throws` | `adapter-call-plus-wrapper` | `ThrowsBridge` trailing `NSError**` out-param |
| Swift-native value return | `adapter-call` | `OpaqueHandle` boxes + per-type accessors |
| escaping callback | `adapter-call` | `BlockBridge`/`DelegateBridge` + `GCPrevention` rooting |
| KVO observation | `adapter-call` | `ObservationBridge` (Swift Observation → C) |
| collection marshalling | `adapter-call` | `CollectionMarshal` (Depth-2, one native call per collection) |

## The native adapter — `APIAnywareRacket`

The adapter dylib (`output { library "APIAnywareRacket"; symbol-prefix "aw_racket_" }`, hermetic
per ADR-0011) classifies its functions by §26 role in
[`../adapters/macos/spec.apiw`](../adapters/macos/spec.apiw): `callback-adapter`
(Block/Delegate/Observation bridges), `thread-adapter` (`AsyncBridge` main-thread hop),
`error-adapter` (`ThrowsBridge`), `lifetime-adapter` (retain/release + `GCPrevention` +
`AutoreleasePool`), `generic-erasure-adapter` (`OpaqueHandle`), `collection-adapter`,
`buffer-adapter` (String/Struct marshalling), `reflection-adapter` (class/selector lookup), and a
racket-specific `utility-adapter`. Three runtime services are `required`: `callback-registry`
(GC rooting), `main-thread-dispatch`, and `autorelease-pool-management`.

The dylib is **necessary** (only Swift calls the Swift ABI) and **per-target hermetic** — it
shares no native substrate with the other targets (ADR-0010/0011). The runtime that loads it and
binds the `aw_racket_*` symbols is [`../bindings/macos/runtime/`](../bindings/macos/runtime/);
its design is [`design/2026-05-31-racket-native-binding-design.md`](design/2026-05-31-racket-native-binding-design.md)
+ [`design/2026-06-15-racket-trampoline.md`](design/2026-06-15-racket-trampoline.md).

## See also

- [`representability.md`](representability.md) — how the thin-direct posture makes most APIs
  `exact-static` and only the residual drop down the ladder.
- [`reference.md`](reference.md) §4 — the FFI type-coercion rules in full.
- [`developer-guide.md`](developer-guide.md) — "Type coercion and the FFI boundary" for users.
