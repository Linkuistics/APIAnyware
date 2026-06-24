# The gerbil method trampoline structure, and the first gerbil async path

**Status:** accepted

Decides the **gerbil** target's mechanism for binding the **Swift-native method
frontier** — the `objc_exposed == false` methods/initializers on classes and
structs — the gerbil counterpart to **ADR-0030** (racket) and **ADR-0031** (chez).
Generalises the gerbil free-function trampoline of **ADR-0029** from *free
functions* to *methods* by adding an **opaque receiver handle** as the first C
parameter, exactly as ADR-0030 did for racket over ADR-0027 and ADR-0031 did for
chez over ADR-0028. Governed by **ADR-0011** (the trampoline layer is per-target —
nothing native is shared), **ADR-0010** (the native library *is* the binding),
**ADR-0017/0029** (gerbil's compiled-FFI `define-c-lambda` idiom + the
trampoline-only Swift dylib), **ADR-0020** (the manifest class graph + the
`register-objc-class!` wrap registry), and **ADR-0026** (the `objc_exposed`
boundary fact).

This is the design decision of `050-gerbil/010-build`. It is a **horizontal port,
not a rediscovery**: the hard design work — the receiver-handle call-by-name shape,
init producers (D2), mutating write-back (D3), the async completion-callback form
(D5/R4), the curated swift-residual close (B1–B5) — is already decided in ADR-0030
and confirmed reproducible by chez (ADR-0031) through the shared IR. gerbil inherits
all of it; this ADR records only where gerbil *deviates*, which is the same axis
ADR-0029 already recorded for free functions, plus one genuinely new surface
(async). The implementation contract is `targets/racket/docs/design/2026-06-15-racket-trampoline.md`
(§method), read as the cross-target design of record.

## Context

ADR-0029 made gerbil the third Swift-trampoline target for free functions: a
**trampoline-only `libAPIAnywareGerbil.dylib`** (only Swift can call the Swift ABI;
`gsc`/`gxc` structurally cannot), bound from the gerbil emitter with a per-signature
**`define-c-lambda`** (not chez's `foreign-procedure`) against the dylib **linked at
`gxc -exe` time**, with **Scheme-side** value marshalling (ADR-0015). Methods differ
from free functions in exactly one structural way — a **receiver** — so the
receiver-handle generalisation (ADR-0030 §1–§4) ports with the receiver riding the
existing dylib-call path as one more pointer/scalar arg (D6: no new FFI seam).

The residual is a deterministic function of the shared IR, so the gerbil pass
reproduces racket's and chez's classification **exactly** (the §6d invariant): **51
function + 7 constant + 576 init + 554 method** trampolines, with a **byte-identical
per-reason deferred breakdown** (27 actor_isolated, 3169 nonbridged_struct_param,
1106 static_method, 5567 unbindable_generic_method, 68 closure_param, … through to
the 1-count tail). That equality is the strongest evidence the port is faithful.

## Decision

### 1. Receiver-handle method + init trampolines — the ADR-0030 structure, gerbil-spelled

`emit-gerbil/src/trampoline.rs` mirrors `emit-chez`/`emit-racket`'s codegen under the
gerbil `aw_gerbil_swift_m_*` / `aw_gerbil_swift_init_*` content-addressed entry
prefixes: receiver reconstruction by owner kind (class →
`Unmanaged<Module.Owner>.fromOpaque(recv).takeUnretainedValue()`; value struct →
`awGerbilUnbox(recv, as: Module.Owner.self)`), init producers boxing the **owner**
not the lossy IR return type (`awGerbilBox` value / `Unmanaged.passRetained` class,
D2, R2), mutating value-receiver write-back into the single box (D3,
`AwGerbilValueBox.value` is now `var`), object-ref params via the curated
`objc_object_param_bridge` (R1, `NSURL`→`URL`, `NSURLRequest`→`URLRequest`), and the
full ADR-0030 §5 deferral taxonomy. The Swift `@_cdecl` bodies are the ADR-0011
hermetic duplicate of chez's/racket's — same shape, `awGerbil*` namespace.

### 2. `define-c-lambda` crossing + Scheme-side rendering, **object returns wrap** (the ADR-0029 deviation)

The generated gerbil method/init bindings are split into a `%swift-<name>`
**`define-c-lambda` crossing** (with a synthesized `extern` prototype, ADR-0021)
emitted into a dedicated `begin-ffi` block, plus an outer `(define <name> (lambda
(self …) …))` — not chez's inline `foreign-procedure`. The receiver coerces to its
raw handle pointer via **`(->ptr self)`** (a wrapped class instance → its `ptr`; a
raw value-struct handle → straight through — the universal receiver coercion,
replacing chez's `(coerce-arg self)`). Marshalling stays Scheme-side (ADR-0015):
`aw-swift-string-arg` / `aw-swift-string-result` (NSString ↔ Scheme string),
`aw-swift-call/error` (the throwing `NSError**` cell), all from
`runtime/swift-trampoline.ss`.

gerbil's **substantive divergence from chez** (ADR-0029 §2) carries into methods: a
chez method always boxes its non-scalar return into one opaque `Handle`; gerbil
splits it into **`Object`** (an ObjC/bridged object → handed back as a raw +1 `id`
and `wrap`ped to its **exact bound type** via the ADR-0020 `register-objc-class!`
registry) vs **`OpaqueBox`** (a genuine non-object value → `awGerbilBox`). An init
producer for a **class** owner likewise `wrap`s its returned id; a **value-struct**
owner hands back the raw opaque handle (no ObjC class to wrap to).

### 3. Charter-#4 routing in `emit_class.rs` — gated on `objc_exposed` before the supported gate (D4)

gerbil `build_class_plan` excludes `objc_exposed == false` methods/inits from the
three `objc_msgSend` categories (init/instance/class) **before** the supported-method
gate, and `generate_class_file_with_parent` routes them to a dedicated Swift-native
section (bindable) or suppresses them (deferred, counted by the global pass). The
ObjC bindings win any Scheme-name collision (`SwiftNativeBindings::exclude`); a
duplicate `(define …)` is at best last-wins shadowing. The gerbil reserved-surface
guard (`is_reserved_surface_name`, which omits procedures — the dual of chez's
`(chezscheme)`-builtin collision in ADR-0031 §7) **does not apply**: the Swift-native
bindings are standalone named procedures, not `{}`/generic surfaces, and gerbil
shadowing is harmless — so chez's `except` fix is **not** ported.

### 4. Population-B value structs get their own `<struct>.ss` module, no msgSend substrate

gerbil did not emit struct files before. A Swift-native value struct (population B,
e.g. `IndexSet`) now emits a `<fw>/<struct>.ss` module with **no `defclass` graph and
no `objc_msgSend` substrate** — just the init producers + methods over the opaque
`awGerbilBox` handle the init hands back (a raw pointer; methods take it as `self`,
coerced through `(->ptr self)`, which passes a raw pointer through). A struct whose
lowercased name collides with a class module's stem takes a `-struct` suffix on the
file + import path (the binding names are unchanged; the global pass keys entries on
the struct's real name).

### 5. The first gerbil async path — `async-bridge.ss` over a `c-define` callback (D5/R4)

gerbil's free-function async bucket was **empty** (ADR-0029 §5: no Swift-native async
*free functions* exist), so the method frontier is the **first gerbil async path**.
The generated async `@_cdecl` takes a trailing completion context (`Int`) + C
callback and drives `awGerbilAsyncDispatch` (the ADR-0011 hermetic duplicate of
chez's/racket's `AsyncBridge.swift`: kick a `Task`, marshal the result to the
Sendable `AwGerbilAsyncOutcome` on the cooperative pool, deliver via the callback on
the **main thread** through the `MainActor.run` hop). The gerbil end is a new
`runtime/async-bridge.ss` exporting `aw-async-call`, the structural analogue of
chez's `async-bridge.sls` (an id-keyed registry of delivery thunks + one C callback),
but spelled with a **Gambit `c-define`** (the same C-callback mechanism the native
core's IMP/block bridges use — it re-enters Scheme by fully-qualified name). Because
Swift delivers on the main thread, the callback is entered on the main thread
directly — like the native-core IMP *inner* dispatchers, no extra outer-trampoline
bounce needed (cf. ADR-0022). The surface is the **non-blocking callback form** (R4):
the binding takes a `complete` continuation and returns immediately. The two async
sub-deferrals (mutating receiver, scalar return) carry from ADR-0030.

### 6. The swift-residual close (B1–B5) inherited through the shared IR

The curated close ADR-0030 records is a property of the IR + the Swift compiler, not
the scripting target, so gerbil inherits it:

- **B1** (`.macOS(.v26)` floor) is package-wide in `swift/Package.swift`, so gerbil
  got it for free.
- **B2** (implementation-detail module re-attribution, `swift_import_module`:
  `RealityFoundation`→`RealityKit`, `SwiftUICore`→`SwiftUI`) and **B3** (owner-
  availability fold, `max_macos_version`) are ported verbatim into
  `emit-gerbil/trampoline.rs`.
- **B4** (`KNOWN_UNBINDABLE` curated suppression) is the **same decl set** as
  racket/chez — the residual is IR-deterministic, the suffix after the prefix and the
  overload hash are target-independent — keyed by the **gerbil** content-addressed
  entry name (`aw_gerbil_swift_*` prefix); each entry counted under its `DeferReason`,
  the full-residual `swift build` its regression guard.
- **B5** (the `@MainActor @preconcurrency` warning posture) carries: those
  trampolines are kept (they run when called on the main thread), the warnings the
  honest record.

### 7. No lazy-load forcing reference (ADR-0029 §4 carries)

gerbil has no lazy-instantiation hazard: the dylib is linked at `gxc -exe` time via
`-l`, so every `aw_gerbil_swift_*` symbol resolves at image load regardless of which
trampolines a program references. chez's ADR-0031 §2 forcing idiom (`%aw-lib-ready`)
is **deliberately not ported** — the same call ADR-0029 §4 made for free functions.

## Consequences

- **`Generated/Trampolines.swift` (gerbil) gains 576 init + 554 method `@_cdecl`s**
  (the same global pass); the summary line reports function/constant/init/method
  counts + per-reason deferrals, at parity with racket/chez.
- **`AwGerbilValueBox.value` is now `var`** (D3) and **`AsyncBridge.swift` is new** —
  the only gerbil runtime Swift changes; everything else reuses the shipped
  `OpaqueHandle`/`ThrowsBridge` layer.
- **`runtime/async-bridge.ss` is new** (`aw-async-call`) and **`emit-gerbil` emits
  value-struct modules for the first time** (population B).
- **gerbil-only** (ADR-0011). gerbil is the **third and last** target; on close the
  grove's "propagate to all targets, each VM-verified" done-bar is met. The IndexSet
  pop-B and URLSession async exemplars are the shared known-good cases.
- **Proof** (this leaf, the ADR-0030 §6/§B6 pattern, gerbil-local): codegen unit
  tests in `emit-gerbil/trampoline.rs`, a charter-#4 routing assertion + a
  population-B struct-file test in `emit_class.rs` (139 emit-gerbil tests green), the
  **whole 117-framework method/init residual compiling clean** against the real SDK
  in Swift 6 mode (0 errors; the B5 warnings carry), the §6d residual-count
  reproduction reported above, and a **CLI smoke** of both exemplars through
  libAPIAnywareGerbil (pop-B IndexSet init→contains→mutating insert! D3 write-back;
  pop-A async `URLSession.data(from: file://…)` delivering a real `(Data,
  URLResponse)` via the CFRunLoop pump). The full cold rerun + `cargo test
  --workspace` + `run-smokes.sh` registration + VM-verify of both exemplars in a
  bundled self-contained `.app` is the sibling leaf `050-gerbil/020-rerun-verify`.

See `CONTEXT.md` (*Receiver handle*, *Population A/B*, *Init producer*), ADR-0030
(the racket method structure this ports), ADR-0031 (the chez method structure this
parallels), ADR-0029 (the gerbil free-function structure this generalises), and the
design spec §method for the how.
