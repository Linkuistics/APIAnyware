# The racket method trampoline structure: receiver-handle call-by-name, init producers, mutating write-back

Decides the **per-target** mechanism for binding the **Swift-native method
frontier** — the `objc_exposed == false` methods/initializers on classes and
structs that ADR-0027's free-function trampoline does not reach. Generalises
**ADR-0027** (the racket free-function trampoline: call-by-name `@_cdecl`
re-export) from *free functions* to *methods* by adding an **opaque receiver
handle** as the first C parameter. Governed by **ADR-0011** (the trampoline layer
is per-target — this ADR is racket-only; chez/gerbil inherit it in this grove's
040/050 with thin ADRs), **ADR-0010** (the native library *is* the binding), and
**ADR-0026** (the `objc_exposed` boundary fact). Consumes the method-recovery IR
landed in `020-method-recovery` (`ir::Method.swift_fn` with `self_kind`,
`ir::Struct.methods`, recovered `init_method`).

This is the design decision of `030-racket/010-build` (the sync structural core).
`async` methods are split to `030-racket/020-async-method` (ADR addendum there).
The implementation-level contract is in
`targets/racket/docs/design/2026-06-15-racket-trampoline.md` (§method).

## Context

ADR-0027 retained and trampolined top-level `s:` funcs/constants. But the bulk of
the Swift-native residual is **methods**: measured over 284 frameworks,
**~11,200** Swift-native methods (3,181 class + 8,011 struct) plus **~5,600
initializers** — none bound today. They route through the ObjC `native_dispatch`
(`objc_msgSend`), which has no entry for a Swift-native selector, so per the
founding charter's point #4 they are **latently broken** (`emit_class.rs`'s
`is_supported_method` actually *drops* the Swift-style `name(label:)` selectors, so
the break manifests as missing rather than crashing — but the floor is the same:
the broken msgSend must go).

A method differs from a free function in exactly one structural way: it has a
**receiver**. Everything else — argument marshalling, throwing, the deferral
discipline — is the ADR-0027 taxonomy unchanged.

## Decision

### 1. Receiver-handle method trampolines, called by name

A method trampoline is a `@_cdecl` whose **first C parameter is an opaque receiver
handle**; the body reconstructs the receiver, then calls `receiver.name(labels:)`
by name (swiftc owns ABI correctness, exactly as ADR-0027). Receiver
reconstruction is by the **owner's kind**, not the population A/B split:

- A **class** owner — objc-exposed (the target already holds it as an `id`) *or*
  Swift-native (boxed via `Unmanaged.passRetained`) — is a reference type:
  `Unmanaged<Module.Owner>.fromOpaque(recv).takeUnretainedValue()`.
- A **value struct** owner (population B) is an `AwValueBox` handle:
  `awRacketUnbox(recv, as: Module.Owner.self)`.

The A/B split (owner `objc_exposed`) governs only whether an init *producer* is
needed — orthogonal to how the receiver is unboxed.

### 2. Initializer producers — the population-B root producer (D2)

An `init` trampoline calls `Module.Owner(labels:)` and returns a boxed handle of
the **owning type** — `awRacketBox` for a value struct, `Unmanaged.passRetained`
for a class. It boxes the *owner*, **not** the IR's return type, which the lossy
Swift→ObjC normalization often reports as the bridged class (`init(integer:)` on
`IndexSet` reports `NSIndexSet`; the produced handle must be an `IndexSet`). This
is the only new decl kind methods require; factory/static producers fall out of
the existing return-boxing path.

### 3. Mutating value-receiver write-back (D3)

`AwValueBox.value` becomes a `var`. A `self_kind == "Mutating"` value-receiver
trampoline does `var v = box.value as! T; let r = v.method(...); box.value = v;
return r`, so the single handle the racket side holds reflects the mutation (one
stable identity). Class receivers need no write-back (reference identity). A
`consuming self` method is deferred-with-count (the handle would dangle).

### 4. Charter-#4 routing fix (D4)

`emit_class`'s method emitter branches on `objc_exposed` **before**
`is_supported_method`: `true` → `objc_msgSend` (unchanged); `false` &
trampolinable → a receiver-handle trampoline bound against `libAPIAnywareRacket`
(`_aw-lib`); `false` & deferred → **suppress + count** (emit nothing, the global
pass records the reason). The broken msgSend for Swift-native selectors is gone.

### 5. Complete marshalling to the C-ABI limit — defer nothing, but be honest

Method args reuse ADR-0027's scalar/string taxonomy verbatim. The deferral set
grows with method-specific, per-reason counts (the §5 discipline): generic method,
async method (→ leaf 020), `consuming` receiver, static/class method,
operator/non-identifier name, variadic, nullable-scalar return, and — in this
structural leaf — value-struct **params** and object/reference params (the async
leaf's R1). Nothing is silently dropped.

### 6. Codegen robustness against the lossy IR (kick-backs, resolved in leaf)

Compile-checking the **entire generated Foundation residual** (68 inits + 92
methods + 2 constants) against the real framework — the strongest available proof,
since these defects are invisible to synthetic unit tests — surfaced and fixed
seven classes of bug rooted in the IR's lossy normalization:

- **Duplicate decls** (a category re-listing, a digester dupe) → dedup trampolines
  by content-addressed entry (a duplicate entry *is* the same trampoline).
- **Sentinel / inaccessible return type names** (`Tuple`, `ProtocolComposition`,
  `Iterator`, nested types) → a method's non-scalar return always boxes **unnamed**
  (no `as <Type>` pin; the call is unambiguous, unlike the cross-module free-fn
  `nan` case).
- **Optional returns** → nullable String/handle returns map `nil` → NULL/`#f`; a
  nullable *scalar* return is deferred (a C scalar cannot carry `nil`).
- **`Int`/`Int64` width collapse** (the IR normalizes both to `int64`) →
  **`numericCast`** for *method* integer params/returns bridges whatever width the
  by-name call infers. **Not** for *init* params: an overloaded initializer
  (`Decimal(Int)` vs `Decimal(UInt)`) is selected *by* the param type, so a
  width-agnostic cast would make the constructor ambiguous.
- **Nested value-struct param names** (`Data.Base64EncodingOptions`, not
  bare-spellable) → value-struct method params are deferred in this structural leaf
  (a qualified-name follow-up).

## Consequences

- **`Generated/Trampolines.swift` gains method + init `@_cdecl`s** (same global
  pass, same file as the free-function trampolines). The summary line now reports
  function/constant/init/method counts + per-reason deferrals.
- **`AwValueBox.value` is now `var`** (D3). The only runtime change — everything
  else reuses the shipped `OpaqueHandle`/`ThrowsBridge`/`MemoryManagement` layer.
- **The racket emitter routes Swift-native methods for the first time** —
  `emit_class` branches on `objc_exposed` and renders the trampoline binding (or
  suppresses), closing charter #4 for methods.
- **Receiver marshalling reuses the box/`Unmanaged` lifetime model** — no new
  handle type, no new lifetime (constraint honoured from ADR-0027).
- **Racket-only.** chez/gerbil inherit this structure in 040/050 (thin ADRs over
  ADR-0028/0029); the IndexSet pop-B and URLSession async exemplars are the shared
  known-good cases.
- **Proof** (the §6 deviation pattern — racket-local, no cross-target golden
  churn): codegen unit tests in `trampoline.rs`, a routing assertion test in
  `emit_class.rs`, the whole-Foundation residual compiling clean against real
  Foundation in Swift 6 mode, and an **in-process smoke** binding the real
  `IndexSet` init/contains/insert `@_cdecl`s raw — proving init producer (D2) →
  value-receiver unbox (D2) → mutating write-back (D3) on one stable handle. The
  full cold-pipeline rerun + VM-verify is `030-rerun-verify`.

See `CONTEXT.md` (*Receiver handle*, *Population A/B*, *Init producer*), ADR-0027
(the free-function structure this generalises), ADR-0026 (the `objc_exposed`
fact), and the design spec §method for the how.

## Addendum: async methods + object-ref params (`030-racket/020-async-method`)

The sync structural core above classified `async` methods `deferred_async` and
deferred object/reference params. This addendum decides both — the headline being a
real recovered `async throws` method (`URLSession.data(from:)`) that resolves and
runs end-to-end.

### A1. Async method codegen — the completion-callback shape (D5)

An `async` method cannot return across the C ABI, so its `@_cdecl` takes a trailing
**completion context (`Int`) + C callback** (`@convention(c) (Int, value, error)
-> Void`) instead of a synchronous return, returns void, and drives the shipped
`awRacketAsyncDispatch` (AsyncBridge.swift). The body:

- **marshals every argument to a Sendable value *synchronously at entry*** (before
  the `Task`), so the captured args (`URL`, `String`, scalars — all `Sendable` and
  copied) cannot dangle while the async op runs;
- in the `@Sendable` operation closure, reconstructs the **receiver inside** the
  closure from the captured opaque pointer. `UnsafeMutableRawPointer` is *not*
  `Sendable` in Swift 6 (pointers are unsafe to share by design), so the pointer
  rides a **`nonisolated(unsafe) let`** — an honest assertion: the caller's lifetime
  contract (keep the receiver alive until completion) makes the capture sound;
- `await`s the by-name call and **marshals the result to `AwAsyncOutcome` on the
  cooperative thread** (`awRacketBox` / +1 NSString / `nil`; `.failure(error)` on
  the throwing path), so only a Sendable C rep crosses the hop;
- the completion closure delivers it via the C callback **on the main thread** (the
  `MainActor.run` hop — a Racket CS `_cprocedure` SIGILLs on a foreign thread).

Two sub-cases defer-with-count (cannot ride the carrier): a `mutating` value
receiver (`deferred_async_mutating_receiver` — write-back is ill-defined across the
async hop) and a scalar return (`deferred_async_scalar_return` — `AwAsyncOutcome`
carries a pointer).

### A2. R4 — the racket surface is the non-blocking **callback form**, not a blocking await

The spec §5b named "a blocking `aw-async-await` wrapper" as a candidate. **Rejected**
(grilled, user-confirmed): a synchronous block would freeze the very Cocoa run loop
the completion needs to drain — under `nsapplication-run` the Racket CS green-thread
scheduler is frozen, so a semaphore never wakes; pumping a nested run loop to fake a
synchronous return is the wrong model for an event-driven app. Instead the generated
async binding takes a **`complete` continuation and returns immediately**; the result
is delivered on a later main-run-loop pass (`generation/targets/racket/runtime/
async-bridge.rkt`, `aw-async-call`). A richer mailbox/await layer can be built on top
later. The runtime mirrors `main-thread.rkt`: an id-keyed registry of delivery
thunks + one **GC-stable module-level `_cprocedure`** passed through an `_fpointer`
param (a `_cprocedure` *param* would per-call wrap a soon-GC'd callback — the bug the
smoke caught).

### A3. R1 — objc-bridged reference params, via a verified table

A param the lossy Swift→ObjC normalization reports as a Foundation objc twin
(`URL` → `NSURL`) reconstructs the reference and **bridges to the value the by-name
call wants** (`… as URL`). The bridge set (`objc_object_param_bridge`) is
deliberately small and **proven against the whole-Foundation typecheck, not
assumed**: an objc twin like `NSDate` also appears as a hidden `inout Date` param
(`Calendar.dateIntervalOfWeekend`), and `inout` is invisible in the IR, so a
speculative entry can surface an uncompilable method. **Init object params stay
deferred** — a bridging constructor (`Data(referencing: NSData)`) genuinely wants the
reference, the opposite of the method-call case, and the IR cannot tell them apart.
The set widens in `030-rerun-verify` over enriched IR (which may expose `inout`).

### A4. Proof

Codegen unit tests in `trampoline.rs` (async throws/void/non-throwing, the two async
deferrals, object-ref bridging); the whole-Foundation residual compiling clean
against real Foundation in Swift 6 (the async `URLSession.data` overloads + the R1
params included — the only residual error is a *pre-existing* `provenance: null`
availability gap on `AttributeContainer.filter`, resolved by the full pipeline in
`030-rerun-verify`); and an **in-process smoke**
(`generation/targets/racket/runtime/smoke/`) driving the real `async-bridge.rkt` to
run `URLSession.data(from: file://…)` end-to-end and assert a real
`(Data, URLResponse)` came back. The generated-class-file **require wiring** (sync +
async) and the `needs_native`-branch `_fun` interaction are carried to
`030-rerun-verify` (they surface only at full-pipeline generate + load).

## Addendum: the full-residual `swift build` close (`030-racket/040-swift-residual-verify`)

Leaves 010/020 only *typechecked Foundation* in isolation. Compiling the **full
117-framework method/init residual** (593 init + 588 method `@_cdecl`s) surfaced 955
errors across ~14 categories that single-framework typechecks never reached. The
slice closed by **raising the deployment floor + re-attributing implementation-detail
modules + folding owner availability + curating the genuinely-un-trampolinable
residual** — every drop counted by reason (spec §8.8). All four are racket-emitter
changes (`trampoline.rs`/`emit_class.rs`); the IR and the collection pipeline are
untouched, so chez (040) and gerbil (050) inherit the policy through the shared IR.

### B1. Deployment-target bump → `.macOS(.v26)` (cleared 826 of 955)

A `@_cdecl` is a plain global function: swiftc requires every API it calls to be
available at the package's **minimum** deployment target. At `.macOS(.v14)`, 840 of
the 955 errors were `'X' is only available in macOS N or newer` (N ∈ 14.2 … 26.4) —
the `@_cdecl` was not gated high enough because the method's IR provenance was `null`
or *lower* than its owning type's. Rather than synthesise a per-decl gate for each
(impossible where provenance is `null`), `swift/Package.swift` raises the floor to
`.macOS(.v26)` (the host SDK; VM golden `macos-tahoe`), which clears every API
introduced at ≤ 26.0 without any `@available` at all — 826 errors in one move.
`.v26` needs `swift-tools-version ≥ 6.1`, so the manifest is bumped to **6.2**.

**Policy (chez/gerbil inherit):** `platforms:` is package-wide, so the chez and gerbil
dylibs adopt the `.v26` floor too. This is acceptable precisely because all three are
**host tools** (the generated dylibs run on the build/VM host, golden macOS 26), never
shippable apps with a back-deployment contract. Recorded here so a future
shippable-artifact target revisits it.

### B2. Implementation-detail module re-attribution (rescued ~250)

266 trampolines owned types in `RealityFoundation` / `SwiftUICore` — modules Swift
**forbids importing** ("it is an implementation detail of RealityKit/SwiftUI; import
the umbrella instead"). The same types are reachable through the umbrella's namespace
(`RealityKit.MeshResource` ≡ the illegal `RealityFoundation.MeshResource`), so
`swift_import_module()` re-attributes the **Swift spelling only** — the `import` line
and the `Module.Owner` type qualifier — while the trampoline's `module` field (and
thus the content-addressed entry symbol + the Racket binding identity, which both
sides must agree on) keeps the original module. This *rescues* ~250 trampolines that
would otherwise be dropped, at the cost of a 2-line module map; only the residual that
the umbrella does not re-export, or that fails for an orthogonal reason (B4), is then
suppressed. (Chosen over plain defer after the re-attribution was shown to typecheck.)

### B3. Owner-availability fold (binds the type-gated value-struct inits)

A method/init whose own provenance is absent or *lower* than its owning type's must be
gated to the **max** of the two, else swiftc rejects the call to the unavailable type.
`max_macos_version(method, owner)` folds the owning **struct's** `introduced:` into the
`@available` gate (`Class` carries no provenance field; the type-gated residual is
entirely value-struct owners — ImagePlaygroundOptions @26.4, SignificantAppUpdateTopic
@26.2, WebKit.URLScheme @26.0). This *binds* those inits rather than deferring them.

### B4. Curated suppression of the un-trampolinable residual (51 decls, counted)

The remaining 51 decls fail for causes the **lossy IR cannot mechanically predict** —
dominated by `@MainActor`/actor isolation (swiftc errors `#ActorIsolatedCall`), which
`swift-api-digester` does **not surface at all** (the digester emits no isolation
attribute; `swift_attributes` carries an opaque `Custom`, never `MainActor`). The rest
are per-decl semantic failures: unspellable nested owners (`CloudKit.ID` is really
`CKRecord.ID`), `@const` params, un-inferrable generics, noncopyable receivers,
immutable-`inout` receivers, `internal`/`private` overloads, null-provenance version
gates, arg-shape divergence. These are suppressed via a **curated `KNOWN_UNBINDABLE`
table keyed by the content-addressed entry name** (exact per overload; reproduces from
a cold collect since the entry name is a pure function of the IR), each entry counted
under its own `DeferReason`. This is the method analogue of the **libobjc curated
bridge (Option B)**: a hand-verified list earns its place where mechanical detection
has no signal to act on, and the **full-residual `swift build` is its regression
guard** — a stale entry re-surfaces as a compile error.

### B5. `@MainActor @preconcurrency` warning posture (kept, not deferred)

Beyond the 51 hard errors, ~60 trampolines for `@MainActor @preconcurrency` decls
compile with a **warning** (swiftc *permits* the nonisolated call under
`@preconcurrency`). These are **kept**: unlike the charter-#4 broken path (no entry,
always crashes), they have a real `@_cdecl` that **runs when called on the main
thread** — the actual GUI use case for these SwiftUI/RealityKit-shaped APIs.
`MainActor.assumeIsolated`-wrapping does *not* cleanly recover them (the non-Sendable
`@MainActor` return value still cannot cross back to the nonisolated context), so a
sound off-main variant is a future async-hopping frontier (captured for a later leaf),
not a defer. The warning count is the honest record of the constraint.

### B6. Proof (the §6b-analog method-slice close)

The whole pipeline re-ran cold from the real SDK and the method path was proven
end-to-end in a GUI app, mirroring the free-function §6b close:

- **Cold full rerun, clean.** `collect` (284 frameworks, 0 errors) → `analyze`
  (0 verification failures, LLM annotations replayed) → `generate --target racket` →
  `swift build`. The method residual **reproduces exactly** from the cold collect:
  **576 init + 554 method** trampolines (51 + the re-attribution-survivors emitted),
  with the new per-category deferred counts — `27 actor_isolated, 6
  module_member_missing, 4 unresolved_member_type, 4 immutable_inout_argument, 2
  compile_time_constant_param, 2 generic_inference_failure, 2 inaccessible_decl, 2
  unknown_availability, 1 argument_shape_mismatch, 1 noncopyable_receiver` — a
  deterministic function of the SDK. `swift build` green (0 errors).
- **No ObjC regression.** `cargo test --workspace` green (the pre-existing gerbil
  `computes_hello_window_closure` env-flake aside). The `RUNTIME_LOAD_TEST` harness now
  carries `foundation/indexset.rkt` in its library load checks (the method-trampoline
  require-shape) **and** a new `runtime_swift_method_roundtrip` permanent guard — the
  IndexSet init → `contains` → mutating `insert!` write-back round-trip through the
  generated bindings, the §6b registration pattern for the method frontier.
- **CLI smoke (both exemplars).** `tests/test-swift-method-smoke.rkt` drives both
  through the **generated require-tree** against the freshly built dylib: pop-B
  IndexSet init→contains→insert!→contains (D2 producer + D3 write-back) and pop-A
  async `URLSession.data(from: file://…)` (the generated `urlsession-data-from`
  delivering a real `(Data, URLResponse)`).
- **VM-verified (project done-bar).** The `swift-native-method-probe` sample app shows
  both exemplars live through `libAPIAnywareRacket`'s `@_cdecl` trampolines via the
  generated require-tree; screenshot at
  `generation/targets/racket/test-results/swift-native-method-probe/screenshot.png`.
