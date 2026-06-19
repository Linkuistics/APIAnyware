# The racket method trampoline structure: receiver-handle call-by-name, init producers, mutating write-back

**Status:** accepted

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
`docs/specs/2026-06-15-racket-trampoline.md` (§method).

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
