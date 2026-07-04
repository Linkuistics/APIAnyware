# The chez method trampoline structure, and the first chez async path

Decides the **chez** target's mechanism for binding the **Swift-native method
frontier** — the `objc_exposed == false` methods/initializers on classes and
structs — the chez counterpart to **ADR-0030** (racket). Generalises the chez
free-function trampoline of **ADR-0028** from *free functions* to *methods* by
adding an **opaque receiver handle** as the first C parameter, exactly as ADR-0030
did for racket over ADR-0027. Governed by **ADR-0011** (the trampoline layer is
per-target — nothing native is shared with racket), **ADR-0010** (the native
library *is* the binding), **ADR-0015** (Scheme-side marshalling), and **ADR-0026**
(the `objc_exposed` boundary fact).

This is the design decision of `040-chez/010-build`. It is a **horizontal port,
not a rediscovery**: the hard design work — the receiver-handle call-by-name shape,
init producers (D2), mutating write-back (D3), the async completion-callback form
(D5/R4), and the 955-error swift-residual close (B1–B5) — is already decided in
ADR-0030. chez inherits all of it through the **shared IR**; this ADR records only
where chez *deviates*, which is the same axis ADR-0028 already recorded for free
functions, plus one genuinely new surface (async). The implementation contract is
`targets/racket/docs/design/2026-06-15-racket-trampoline.md` (§method), read as the cross-target
design of record.

## Context

ADR-0028 made chez the second Swift-trampoline target for free functions:
generated `@_cdecl` call-by-name re-exports in `libAPIAnywareChez`, bound from the
chez emitter with `foreign-procedure` and **Scheme-side** value marshalling
(ADR-0015) rather than racket's native coercers. Methods differ from free functions
in exactly one structural way — a **receiver** — so the receiver-handle
generalisation (ADR-0030 §1–§4) ports with the receiver riding the existing
trampoline-call path as one more pointer/scalar arg (D6: no new FFI seam).

The residual is a deterministic function of the shared IR, so the chez pass
reproduces racket's classification **exactly** (the §6c invariant): **51 function +
7 constant + 576 init + 554 method** trampolines, with a **byte-identical
per-reason deferred breakdown** (27 actor_isolated, 3169 nonbridged_struct_param,
1106 static_method, 5567 unbindable_generic_method, 68 closure_param, … through to
the 1-count tail). That equality is the strongest evidence the port is faithful.

## Decision

### 1. Receiver-handle method + init trampolines — the ADR-0030 structure, chez-spelled

`emit-chez/src/trampoline.rs` mirrors `emit-racket`'s codegen under the chez
`aw_chez_swift_*` content-addressed entry prefix: receiver reconstruction by owner
kind (class → `Unmanaged<Module.Owner>.fromOpaque(recv).takeUnretainedValue()`;
value struct → `awChezUnbox(recv, as: Module.Owner.self)`), init producers boxing
the **owner** not the lossy IR return type (`awChezBox` value / `Unmanaged.passRetained`
class, D2), mutating value-receiver write-back into the single box (D3, `AwChezValueBox.value`
is now `var`), object-ref params via the curated `objc_object_param_bridge` (R1),
and the full ADR-0030 §5 deferral taxonomy. The Swift `@_cdecl` bodies are the
ADR-0011 hermetic duplicate of racket's — same shape, `awChez*` namespace.

### 2. Scheme-side binding rendering (ADR-0015, the ADR-0028 deviation)

The generated chez method/init bindings are `foreign-procedure`s against the
`aw_chez_swift_*` entries, with marshalling kept **Scheme-side**: `aw-string-arg` /
`aw-string-result` (NSString ↔ Scheme string), `aw-call/error` (the throwing
`NSError **` out-param), and `coerce-arg` for the receiver — the same coercers
ADR-0028's free-function path uses, in `runtime/swift-trampoline.sls`. The
**lazy-instantiation forcing reference** (ADR-0028 §3) is emitted in every method
section (`(define %aw-lib-ready aw-trampoline-lib-ready)` before the
`foreign-procedure`s) so a pure-scalar method file still forces `libAPIAnywareChez`
to load before its entries resolve.

### 3. Charter-#4 routing in `emit_class.rs` — gated by the explicit export list (D4)

chez `build_class_plan` excludes `objc_exposed == false` methods from the three
`objc_msgSend` categories (init/instance/class) **before** the supported-method
gate, and renders them in a dedicated Swift-native section (bindable) or suppresses
them (deferred, counted by the global pass). A chez-specific load-bearing twist
that racket's `provide` model does not have: a Chez `library` needs an **explicit
export list** and rejects a doubly-defined or doubly-exported name, so a Swift
binding whose Scheme name collides with an already-bound ObjC name is dropped (ObjC
wins) — `SwiftNativeBindings::exclude` — keeping the export list and the `(define …)`s
in lockstep.

### 4. Population-B value structs get their own `(library …)`, name-resolved to a file

chez did not emit struct files before. A Swift-native value struct (population B)
now emits a `(library (apianyware <fw> <struct>) …)` with no ObjC substrate and no
framework-dylib load — just `coerce-arg`, the trampoline coercers, and the
bindings. Because Chez **resolves a library name to a filename by path**
(`(apianyware fw indexset)` → `fw/indexset.sls`), a struct whose lowercased name
collides with a class file takes a `-struct` suffix on **both** the filename and
the final library-name segment, in lockstep (the racket path-require model needs no
such coupling).

### 5. The first chez async path — `async-bridge.sls` over `foreign-callable __collect_safe` (D5/R4)

chez's free-function async bucket was **empty** (ADR-0028 §4: no Swift-native async
*free functions* exist), so the method frontier is the **first chez async path**.
The generated async `@_cdecl` takes a trailing completion context (`Int`) + C
callback and drives `awChezAsyncDispatch` (the ADR-0011 hermetic duplicate of
racket's `AsyncBridge.swift`: kick a `Task`, marshal the result to the Sendable
`AwChezAsyncOutcome` on the cooperative pool, deliver via the callback on the
**main thread** through the `MainActor.run` hop). The chez end is a new
`runtime/async-bridge.sls` exporting `aw-async-call`, the structural analogue of
racket's `async-bridge.rkt` (an id-keyed registry of delivery thunks + one
GC-stable module-level callback), but spelled with a **`foreign-callable
__collect_safe`** (ADR-0016 — safe re-entry from the main thread) locked for the
process lifetime, where racket uses a `_cprocedure` through an `_fpointer` param.
The surface is the **non-blocking callback form** (R4): the binding takes a
`complete` continuation and returns immediately; errors ride a chez condition the
continuation receives, not a raise into the run loop. The two async sub-deferrals
(mutating receiver, scalar return) carry from ADR-0030.

### 6. The swift-residual close (B1–B5) inherited through the shared IR

The 955-error close ADR-0030 records is a property of the IR + the Swift compiler,
not the scripting target, so chez inherits it:

- **B1** (`.macOS(.v26)` floor) is package-wide in `swift/Package.swift`, so chez
  got it for free.
- **B2** (implementation-detail module re-attribution, `swift_import_module`) and
  **B3** (owner-availability fold, `max_macos_version`) are ported verbatim into
  `emit-chez/trampoline.rs`.
- **B4** (`KNOWN_UNBINDABLE` curated suppression) is the **same decl set** as racket
  — the residual is IR-deterministic — keyed by the **chez** content-addressed entry
  name (`aw_chez_swift_*` prefix); each entry counted under its `DeferReason`, the
  full-residual `swift build` its regression guard.
- **B5** (the `@MainActor @preconcurrency` warning posture) carries: those
  trampolines are kept (they run when called on the main thread), the warning count
  the honest record.

### 7. `(chezscheme)`-builtin name collisions on init producers (the 020 close)

Surfaced by the `020-rerun-verify` cold rerun + method-probe VM-verify (not visible
to the in-process smoke, which imports leaf libraries directly; the bundler loads the
**framework umbrella**, which imports every sub-library). A value-struct **init
producer** spells `make-<struct>`, and Chez exports `make-date`, `make-list`, … from
`(chezscheme)`. Under strict R6RS a local `(define make-date …)` that shadows an
import is a hard *"multiple definitions"* load error — unlike Gerbil/Gambit, where
shadowing a procedure binding is harmless (cf. emit-gerbil's `is_reserved_surface_name`,
which deliberately omits procedures). The same hazard hits free functions that mirror
libm names (`coregraphics/functions.sls`: `acos`, `cos`, …), latent until that umbrella
is imported.

Fix (`emit-chez/chez_builtins.rs`): every generated library's `(import (chezscheme) …)`
is emitted via `chezscheme_import_spec(exports)`, which `except`s any **export** name
that is a `(chezscheme)` builtin, letting the local `define` win. Excepting only
*export* names is provably safe — a file that both exported `X` and used Chez's builtin
`X` in a body would already fail to load (so the fix never breaks a currently-loading
file), and the async identity marshaller `values` is used-not-exported, so it is never
excepted. The builtin set is `(environment-symbols (environment '(chezscheme)))`
captured in `chez_builtins.txt` (regeneration recipe in the module docs). Applied at all
three `(chezscheme)`-importing emit sites (value-struct, class, functions). Residual
counts are unchanged (import-line only).

## Consequences

- **`Generated/Trampolines.swift` (chez) gains 576 init + 554 method `@_cdecl`s**
  (same global pass); the summary line now reports function/constant/init/method
  counts + per-reason deferrals, at parity with racket.
- **`AwChezValueBox.value` is now `var`** (D3) and **`AsyncBridge.swift` is new** —
  the only chez runtime Swift changes; everything else reuses the shipped
  `OpaqueHandle`/throws layer.
- **`runtime/async-bridge.sls` is new** (`aw-async-call`) and **`emit-chez`
  emits struct files for the first time** (population B).
- **chez-only** (ADR-0011). gerbil inherits this structure in `050-gerbil` (a thin
  ADR over ADR-0029's dylib path); the IndexSet pop-B and URLSession async exemplars
  are the shared known-good cases.
- **Proof** (this leaf, the ADR-0030 §6/§B6 pattern, chez-local): codegen unit tests
  in `emit-chez/trampoline.rs`, a charter-#4 routing assertion test + a population-B
  struct-file test in `emit_class.rs`, the **whole 117-framework method/init residual
  compiling clean** against the real SDK in Swift 6 mode (0 errors; the B5 warnings
  carry), and the §6c residual-count reproduction reported above. The full cold
  rerun + `cargo test --workspace` + CLI-smoke registration + VM-verify of both
  exemplars is the sibling leaf `040-chez/020-rerun-verify`.

See `CONTEXT.md` (*Receiver handle*, *Population A/B*, *Init producer*), ADR-0030
(the racket method structure this ports), ADR-0028 (the chez free-function
structure this generalises), and the design spec §method for the how.
