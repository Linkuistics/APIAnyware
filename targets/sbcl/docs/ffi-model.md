# sbcl — FFI model (§18)

How the sbcl binding crosses into native code. The choices here are authored in
[`../target.apiw`](../target.apiw) (the `ffi-backend`/`runtime-model`/`projection-policy`/
`adapter-strategy` facets), [`../policies/macos/projection.apiw`](../policies/macos/projection.apiw)
(REFACTOR §23, the per-construct routing), and [`../adapters/macos/spec.apiw`](../adapters/macos/spec.apiw)
(REFACTOR §24–26, the native adapter). This page is their prose; the mechanism detail is
[`reference.md`](reference.md).

## One FFI, compiled per call site

SBCL binds through **one** layer: `sb-alien`, SBCL's compiler-integrated C FFI. There is no external
FFI library to provision (a convergence with chez's single `foreign-procedure` layer, and a contrast
with racket's ffi2 + `ffi/unsafe/objc` split). ObjC message dispatch is reached through it directly:
`objc_msgSend` is selector-polymorphic, so it cannot be a single `define-alien-routine` — its address
is taken **once as a raw SAP** (`+objc-msgsend+`) and `sap-alien`-recast to the exact
`(function <ret> sap sap <args>…)` type **per call site**. (arm64 needs no `objc_msgSend_stret` /
`_fpret` variant — the plain entry returns structs/floats correctly via x8.)

`runtime-model = compiled-ffi` (ADR-0015): SBCL open-codes **one typed alien signature per method ABI
at compile time** — the compiled-FFI analogue of chez's per-signature `foreign-procedure`, a
coercion-free typed crossing per distinct signature, reached by the SBCL compiler rather than
dynamically like racket's `interpreted-ffi`.

The hand-written runtime is **eleven Lisp modules** under
[`../bindings/macos/runtime/`](../bindings/macos/runtime/) (module table + dev load order in the
README there), read in the `apianyware-sbcl-impl` package and imported by every generated binding:

| module | holds |
|---|---|
| `packages.lisp` | the two packages: `ns` (the pure contract-surface holder) + `apianyware-sbcl-impl` (the runtime + the package every generated file is read in) |
| `ffi.lisp` | the `sb-alien` seam: libobjc primitives, the `+objc-msgsend+` SAP + the typed-cast dispatch shape, lazy/cached/re-resolvable `aw-sel`/`aw-class`, `aw-ptr`/`aw-wrap`, the UTF-8 String bridge, the geometry struct typedefs |
| `objc.lisp` | the MOP headline: the `objc-class` metaclass + `validate-superclass`, the foreign ivar slot mechanism, the `ns:ns-object` root, the baked-table consumers (`register-objc-class`/`-init`/`define-objc-constant`), and `make-instance` → alloc/init |
| `swift-trampoline.lisp` | the Swift-native residual binding shape: the dylib loader, `aw-box-free`, the residual String coercers |
| `subclass.lisp` | ObjC subclass synthesis + protocol conformance: `define-objc-subclass`/`define-objc-method`, the **one** reflective forwarding dispatcher (post-bounce), super-dispatch (`call-super`) |
| `lifetime.lisp` | `sb-ext:finalize` + the main-thread release queue + `with-autorelease-pool`/`define-entry-point` |
| `conditions.lisp` | the `ns:objc-error`/`ns:cocoa-error`/`ns:objc-exception` hierarchy + the single `signal-cocoa-error` + the two call-site macros |
| `threading.lisp` | the foreign-thread model: `aw-block` (Lisp closure → bounced ObjC block), `aw-on-main`, the `sb-thread` native-worker boundary (`with-background-work`) |
| `startup.lisp` | the mandatory startup re-resolution pass (the dumped image revives `Class`/`SEL`/`objc_msgSend` from baked strings) |
| `value-struct.lisp` | the ADR-0042 `ns:value-struct` root for the CLOS value-struct surface |
| `reader-syntax.lisp` | the `@"…"` NSString reader macro |

## The native unit is one dylib — `libAPIAnywareSbcl`, sole native home

The defining sbcl choice (ADR-0038): unlike gerbil — which keeps its callback / block / subclass
bridges in **gsc-compiled Gerbil**, a second ObjC home — a Lisp compiles neither ObjC nor Swift
inline, so SBCL has **no second native home**. `libAPIAnywareSbcl` is therefore the target's **sole
native compilation unit**: it hosts the Swift-native trampolines **and** the foreign→main-thread
bounce, the subclass-IMP synthesis, and the OpaqueHandle/Throws/Async marshalling. This is the
`adapter-strategy = sole-native-unit` facet — a **fourth** strategy value, **broader** than gerbil's
`trampoline-only` (bridges in Gerbil) and chez's `trampoline-and-bridges` (bridges in the dylib
*alongside* native-compiled Chez). The MOP object model itself stays in Lisp.

## The projection posture — thin-direct (trampoline elision)

`projection-policy = thin-direct`: the **vast directly-reachable ObjC surface is reached directly**
via a typed `sb-alien` cast over `objc_msgSend` (trampoline-*elided*) — the native dylib is **not in
that path**. Only the **Swift-native residual** (`s:` USR — unreachable across the Swift ABI from
Lisp), pointer-valued constants, and the **callback / subclass-override** constructs (which need the
bounce) cross the `aw_sbcl_*` C-ABI seam. The sbcl binding is, like racket/chez/gerbil, a fully-elided
limit of the complete-API model (CONTEXT.md *Trampoline elision*).

The per-construct routing in [`../policies/macos/projection.apiw`](../policies/macos/projection.apiw)
(**six** choices — one more than gerbil, because subclass overrides are an explicit routed construct
here):

| construct | spectrum | route |
|---|---|---|
| directly-reachable ObjC | `direct-call` | one typed `sb-alien` signature per method ABI over `objc_msgSend` (ADR-0015) — dylib not in path |
| Swift-native `async` | `adapter-call-plus-wrapper` | `AsyncBridge`'s completion-callback trampoline (ADR-0038), wrapped so the callback **bounces to main** (ADR-0035) |
| Swift-native `throws` | `adapter-call-plus-wrapper` | `ThrowsBridge`'s trailing `NSError**` out-param, wrapped by `aw-with-error-cell` / `signal-cocoa-error` (ADR-0037) |
| Swift-native value return | `adapter-call` | `OpaqueHandle` boxes (ADR-0038); a **bound ObjC object** is instead handed back raw and wrapped to its CLOS class via the ADR-0034 MOP registry, never boxed |
| escaping callback | `adapter-call` | a Lisp closure projected as **one universal ObjC block** by `BlockBridge`; the block body bounces foreign→main via `CallbackBounce` before any Lisp runs (ADR-0035) |
| ObjC subclass override | `adapter-call` | a `define-objc-subclass` override installs a reflective `NSInvocation`-forwarding IMP (`SubclassSynth`, ADR-0034 §5) that bounces foreign→main before dispatching to the Lisp handler |

## The native adapter — `libAPIAnywareSbcl` (sole native unit)

The adapter dylib (`output { library "APIAnywareSbcl"; symbol-prefix "aw_sbcl_" }`, hermetic per
ADR-0011) carries **five** §26 roles and one required service — broader than gerbil's three roles,
exactly because it is the sole native home (the bounce/IMP/marshalling concerns gerbil kept in ObjC
live here too). From [`../adapters/macos/spec.apiw`](../adapters/macos/spec.apiw):

| role | what it does |
|---|---|
| `thread-adapter` | `AsyncBridge` (async→completion trampoline via `MainActor.run`) + **`CallbackBounce`** (the ADR-0035 spine: foreign OS threads must never run Lisp, so every off-main callback bounces to main via `dispatch_sync`) |
| `callback-adapter` | `BlockBridge`: a Lisp closure projected as **one** universal, token-less ObjC block, bouncing foreign→main in the block body before any Lisp runs |
| `error-adapter` | `ThrowsBridge`: marshal a thrown Swift `Error` to a retained `NSError*` through a trailing out-buffer; `signal-cocoa-error` serves both this and the direct `NSError**` path (ADR-0037) |
| `generic-erasure-adapter` | `OpaqueHandle`: non-bridged Swift values boxed as opaque pointers; a bound ObjC object is wrapped to its CLOS class via the MOP registry, never boxed |
| `reflection-adapter` | `SubclassSynth`: install a **reflective** `NSInvocation`-forwarding IMP on a synthesized ObjC subclass — **one** trampoline, not a per-signature shim, ABI-correct for every selector shape (structs, floats) — bouncing foreign→main before the Lisp handler (a divergence from gerbil's fixed-family `void*`-tail shims) |

The single `required` service is `main-thread-dispatch` (`CallbackBounce`'s uniform `dispatch_sync` +
`AsyncBridge`'s `MainActor.run`) — the ADR-0035 spine: foreign threads running Lisp under GC pressure
crashed 5/5 in the threading spike. The `direct-call-policy` **allows** directly-reachable ObjC and
**denies** all five residual / bounced constructs (they need the trampolines). The dylib is
**necessary** (only Swift calls the Swift ABI; only native code can bounce before Lisp runs) and
**per-target hermetic** (ADR-0010/0011). The Swift sources are under
[`../adapters/macos/sources/`](../adapters/macos/sources/).

## See also

- [`representability.md`](representability.md) — how the thin-direct posture makes most APIs
  `exact-static` and only the residual / bounced surface drop down the ladder.
- [`reference.md`](reference.md) — the `objc-class` metaclass dispatch, the FP-trap masking, the
  reflective forwarding IMP, and the dumped-image startup re-resolution in full.
- [`../bindings/macos/docs/user-guide.md`](../bindings/macos/docs/user-guide.md) — the user-facing
  consequences (the dev load model, the per-selector generics, subclassing, threading).
