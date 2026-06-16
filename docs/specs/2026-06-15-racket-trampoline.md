# Design spec — the racket trampoline (Swift-native residual)

**Date:** 2026-06-15
**Status:** specifies the implementation of ADR-0027 (refines ADR-0025, consumes
ADR-0026, extends ADR-0013).
**Implemented by:** the build leaves of `040-racket-trampoline`; re-verified
end-to-end in `050-racket-rerun-verify`.

This is the implementation-level contract for vending C-ABI trampolines from
`libAPIAnywareRacket` for the Swift-native residual, and binding them from the
racket emitter. ADR-0027 records *what* and *why*; this records *how*, in enough
detail to implement without re-deriving the design. Where a detail is genuinely
under-determined, the build leaf resolves it and kicks back to update this spec
(the 030 pattern), rather than guessing.

## 0. Inputs (what 030 already landed)

- `objc_exposed: bool` on every decl node with a USR; `false` ⟺ Swift-native
  (`s:` USR). Top-level `s:` `Func`/`Var` are **retained** as `ir::Function` /
  `ir::Constant` with `objc_exposed: false` (no longer `skipped_symbols`).
- The owning **module** for a residual decl = the enclosing `Framework.name`.
- The mangled **`s:` USR** is in the decl's `doc_refs.usr`; the **bare name** is
  `Function.name` / `Constant.name`; **arg labels** are the `Param.name`s.

### 0a. The IR gap closed by 040/020 (kick-back, resolved in leaf)

The build revealed a real hole in §0's input list. `map_swift_type`
(extract-swift) **lossily normalizes** Swift types into the ObjC-bridged
vocabulary — `String`→`Class{NSString}`, `Array`→`Class{NSArray}`, `Int`→
`Primitive{int64}`, etc. — and `map_top_level_function` discarded the
`throwing`/`is_async`/generic facts that `AbiNode` carries. The call-by-name
mechanism (§1) emits `return foo(x)`, which **does not compile** for a `throws`
or `async` function; and a generic free function (`@_cdecl` cannot be generic)
cannot even be *recognised* to record it. So the codegen cannot produce a
compilable `Trampolines.swift` over the real residual without these facts.

**Resolved here (additive, ObjC golden JSON unchanged):** `ir::Function` gains
`swift_fn: Option<SwiftFnInfo>` (`{ throwing, is_async, is_generic }`),
`skip_serializing_if = "Option::is_none"`. Populated only by
`map_top_level_function` from `node.throwing` / `node.is_async` /
`node.generic_sig.is_some()`; `None` for every ObjC/C function. This is the
shared-pipeline touch 030 would have made had the need been visible then; it is
recorded here rather than reopening the retired 030 node.

## 1. Generated artifact & build wiring

- **Path:** `swift/Sources/APIAnywareRacket/Generated/Trampolines.swift`
  (gitignored, like `Generated/Dispatch.swift`).
- **Pass:** a **global** pass in `generation/crates/cli/src/generate.rs`,
  modelled on `run_racket_native_dispatch` — load all enriched frameworks,
  collect every residual decl, emit one file, write it, return the entry count.
  Runs after `run_generation`, before `swift build`.
- **Codegen home:** a new module in `emit-racket` (sibling to `native_dispatch`),
  e.g. `src/trampoline.rs`, exposing `collect_trampolines(&[Framework])` and
  `generate_trampolines_swift(&[Trampoline]) -> String`. Keep the USR/marshalling
  knowledge in this one place.
- A residual decl whose module fails to `import`, or which is an unbindable
  generic, is **not** emitted; both are counted and logged (see §5).

## 2. Entry naming

- Functions: `aw_racket_swift_<Framework>_<name>`; on overload collision append a
  short signature hash so the name is a pure function of (module, name, ABI
  shape) — reconstructible per-emitter without a global counter (ADR-0013
  content-addressing precedent).
- Constant trampolines: `aw_racket_swift_const_<Framework>_<name>`.
- Handle accessors: `aw_racket_box_<Type>_<field>`, `aw_racket_box_<Type>_tag`
  (payload-enum discriminant). **Free is a single uniform entry**
  `aw_racket_box_free(handle)`, **not** per-type — see §3 (resolved in leaf
  040/010: every boxed value rides one `AwValueBox` rep, so one free suffices and
  opaque `some P` returns that cannot be *named* at a free site are still
  freeable). Per-type field/tag accessors stay per-type — they need the concrete
  nameable type to read a field.

## 3. The marshalling taxonomy (Swift type → C-ABI rep → racket coercion)

The `@_cdecl` boundary may use only C-representable types; the trampoline body
does the bridging. Each row: what the trampoline param/return type is at the C
boundary, and what the racket binding coerces.

| Swift type | C-ABI rep at `@_cdecl` | racket-side coercion |
|---|---|---|
| `Int*/UInt*/Float/Double/Bool` | same scalar | direct ffi2 scalar |
| scalar-backed typedef (`CGFloat`) | underlying scalar (`Double`); body re-wraps `CGFloat(a0)` / converts `Double((call) as CGFloat)` | direct ffi2 scalar (added 040/040/010) |
| `String` | `id` (`x as NSString`) | `aw_racket_nsstring_to_string` (existing) |
| `Array<T>` | `id` (`x as NSArray`) | `aw_racket_nsarray_get_all` (existing) + per-elem coercion |
| `Dictionary<K,V>` | `id` (`as NSDictionary`) | `aw_racket_nsdictionary_get_all` (existing) |
| `Set<T>` | `id` (`as NSSet`) | `aw_racket_nsset_get_all` (added 040/010) + per-elem coercion |
| `Optional<T>` | `T`'s rep, nil = NULL/`#f` | nullable coercion |
| tuple | opaque boxed handle (`AwValueBox`) | `awRacketBox` + field accessors + `aw_racket_box_free` |
| Swift `struct` (non-bridged) | opaque boxed handle (`AwValueBox`) | `awRacketBox` + `aw_racket_box_<T>_*` accessors + `aw_racket_box_free` |
| `enum` with payload | opaque boxed handle + tag (`AwValueBox`) | `awRacketBox` + `aw_racket_box_<T>_tag` + per-case field accessors |
| value-backed existential / opaque `some P` | opaque boxed handle (`AwValueBox`) | `awRacketBox` + `aw_racket_box_free` (no field accessors when the type is unnameable — handle is pass-through only) |
| **class** instance (identity) | opaque retained handle (`Unmanaged.passRetained`) | cpointer, freed by existing `aw_racket_release` |
| pointer-valued constant | constant trampoline → opaque ptr | cpointer |
| `throws` | trailing `NSError**` out-param | `awRacketWriteError` / `awRacketTry`; racket checks + raises |
| `async` | completion-callback trampoline | `awRacketAsyncDispatch` (+ `AwAsyncOutcome` for `async throws`); main-thread aware |

**Box rep — resolved in leaf 040/010 (refines the rows above).** The spec's
first draft listed `struct` / payload-`enum` / tuple / existential / `some P` as
separate handle rows each with a per-type `_free`, and lumped class +
existential + `some P` under `Unmanaged`. Two corrections, now reflected above:

1. *One value-box rep, not many.* Every non-class value (struct, payload-enum,
   tuple, value-backed existential, opaque `some P`) is wrapped in
   `final class AwValueBox { let value: Any }` and `Unmanaged.passRetained`-ed.
   This gives **one** uniform free (`aw_racket_box_free`), works for types that
   cannot be named at a free site (`some P`), and rides the existing
   `Unmanaged`/finalizer lifetime — no new lifetime model. `awRacketBox<T>` /
   `awRacketUnbox<T>` are the generic engine; per-type accessors call
   `awRacketUnbox(h, as: T.self).<field>` where `T` is nameable.
2. *`Unmanaged` is for classes only.* A value-backed existential cannot be
   `Unmanaged`-boxed (not `AnyObject`); only genuine **class instances** (where
   reference identity must survive) take `Unmanaged.passRetained` + the existing
   `aw_racket_release`. 020 picks the path from the static type; swiftc enforces
   it (a wrong pick won't compile).

Foundation-bridged value types deliberately reuse the **existing** runtime
exports (`StringConversion.swift`, `CollectionMarshal.swift`); only the
non-bridged box/handle/async/throws infra is new. Geometry structs already have
`StructMarshal.swift` pack/unpack and stay on that path.

Lifetime: value handles are `AwValueBox`-wrapped (`Unmanaged`-retained) by the
trampoline and freed by the uniform `aw_racket_box_free`; class handles are
`Unmanaged`-retained and freed by `aw_racket_release`. Either way the racket side
wraps them so finalization calls the right free — reuse the existing GC/will
machinery, not a new one.

### 3a. Runtime exports landed by 040/010 (what 020 binds against)

The native marshalling-runtime layer is built (leaf 040/010); 020 binds these
mechanically. New `swift/Sources/APIAnywareRacket/` files + exports:

- **`OpaqueHandle.swift`** — `AwValueBox`; generic `awRacketBox<T>(_:)` /
  `awRacketUnbox<T>(_:as:)` (same-module, called by generated trampolines +
  accessors); `@_cdecl aw_racket_box_free(handle)` (the one uniform value-handle
  free).
- **`ThrowsBridge.swift`** — `awRacketWriteError(errOut:_:)` (the primitive,
  mirrors the dispatch `error_out` write byte-for-byte) and
  `awRacketTry(errOut:fallback:body:)` (ergonomic do/catch wrapper; the generated
  body supplies its concrete `fallback` — `nil` for a pointer rep, `0` for a
  scalar).
- **`AsyncBridge.swift`** — `awRacketAsyncDispatch<P: Sendable>(operation:completion:)`
  (runs the async op on the cooperative pool, delivers a Sendable payload to
  `completion` **on the main thread** via `MainActor.run` so the racket
  `_cprocedure` doesn't SIGILL), plus `AwAsyncOutcome` (`@unchecked Sendable`
  value/error pointer carrier; `.failure(_:)` marshals a thrown error like the
  sync bridge). **Consequence to honour in 020:** the generated `operation`
  closure must be `@Sendable` and must **marshal the result to its C rep inside
  the closure** (on the cooperative thread) — only Sendable C reps (a scalar, or
  `AwAsyncOutcome` for pointer/throwing results) may cross the hop. Async results
  are therefore marshalled off-main; safe for value/Foundation reps, revisit only
  for a main-thread-only return object.
- **`CollectionMarshal.swift`** (extended) — Set bridge:
  `aw_racket_list_to_nsset` / `aw_racket_nsset_count` / `aw_racket_nsset_get_all`,
  same +1-retained-constructor / unretained-`get_all` ownership as the NSArray
  path.

Already present and reused as-is: `StringConversion.swift`,
`CollectionMarshal.swift` (list/dict), `StructMarshal.swift` geometry pack/unpack,
`MemoryManagement.swift` (`aw_racket_retain`/`_release`), and the GC/will
finalization machinery.

## 4. Emitter wiring (`emit_functions.rs`, `emit_constants.rs`)

- A residual is detected by `!func.objc_exposed` / `!constant.objc_exposed`.
- Direct decls: unchanged (`get-ffi-obj '<sym> _fw-lib`).
- Trampolined decls: emit a load of `_aw-lib` (ffi-lib to `libAPIAnywareRacket`)
  once per file when any residual binding is present, then
  `get-ffi-obj 'aw_racket_swift_… _aw-lib` with the ffi2 type for the C-ABI rep,
  wrapped in the racket-side coercion from §3.
- Unbindable generic free function: emit nothing; record (§5).
- Contracts/`provide` continue to describe the *racket-visible* type (post-coercion).

## 5. The unbindable / deferred residual (defer nothing, but be honest)

Some residual decls cannot be trampolined this leaf. They are **not** silently
skipped — each is recorded with a reason and the per-reason counts are logged,
so a clean generate reports e.g. "N trampolined, M unbindable". The reasons:

- `unbindable_generic_free_function` — a generic free function. `@_cdecl` cannot
  be generic and no concrete symbol exists without monomorphization (the rejected
  ADR-0027 option). A **hard** limit; reopen only with a concrete need.
- `deferred_async` — an `async` function. The runtime (`AsyncBridge.swift`)
  supports it, but the callback `@_cdecl` shape + racket `_cprocedure`
  main-thread binding is a follow-up leaf (scope decision below). Recorded, not
  a hard limit. **Measured empty + spun out — see §5b** (040/040/020): there are
  **zero** async *free functions* in the residual; async is a method-level effect,
  outside this leaf's top-level-`s:`-`Func` perimeter.
- `deferred_nonbridged_struct_param` — a function with a non-Foundation-bridged
  Swift `struct`/tuple/existential **parameter**. Calling it by name needs the
  `@_cdecl` body to *unbox a named Swift type*, which requires spelling that type
  (and per-field accessors) — the handle-accessor surface deferred below. A
  non-bridged struct **return** is fine (boxed opaque handle, no naming needed).
- `deferred_closure_param` — a closure / function-pointer **parameter** (a Swift
  closure synthesised over a C callback; distinct from an unboxable value).
- `deferred_unnameable_param` — a parameter that is not a nameable type at all
  (`id`/`Any`, raw pointer, selector); cannot ride the handle-unbox path even in
  principle. (Both added 040/040/010, splitting the umbrella below.)

### 5a. Kick-back — the bucket measured (040/040/010)

The `deferred_nonbridged_struct_param` bucket was wired with the **whole IR
measured first**, and the reality refined the leaf's framing (the spec's first
draft, written before measuring, assumed all 69 were genuine struct params
needing handle-unbox + per-field accessors). Across 284 enriched frameworks the
69 broke down as:

| sub-case | count | disposition |
|---|---|---|
| **`CGFloat`-only params** (a `Double` scalar lossily lowered to `Class{CGFloat}`) | **44** | **recovered** — scalar-typedef row above (`Double` boundary, body re-wraps `CGFloat(a0)`) |
| genuine nameable value-struct / CF / ObjC-reference / bridged-collection params | 17 | still `deferred_nonbridged_struct_param` |
| closure / function-pointer params | 6 | `deferred_closure_param` |
| `id`/`Any` params | 2 | `deferred_unnameable_param` |

Net: function trampolines **2 → 46** across the whole API; the headline bucket
**69 → 17**; nothing dropped (44 recovered + 17 + 6 + 2 = 69). Two return-side
bugs this newly *exposed* (a function only reaches codegen once its params bind)
were fixed in the same leaf: an anonymous **tuple** return is lowered to the
sentinel `Class{name:"Tuple"}` and must box **unnamed** (`as Tuple` does not
compile — `remquo`/`lgamma`); and a scalar-typedef return must keep the
disambiguating `as CGFloat` cast *inside* the conversion (`Double((call) as
CGFloat)`) because `nan` is declared in both CoreGraphics and `_DarwinFoundation1`
and a bare `Double(...)` accepts either.

**Per-field `aw_racket_box_<T>_<field>` accessors / "construct a handle from
scalar fields" — deferred, no real consumers yet.** The leaf brief imagined a
"small concrete struct with scalar/bridged fields"; the measured residual has
none. The genuine struct params are **opaque framework objects** (`MLTensor`,
`MLUntypedColumn`, `SecCode`, …) with no public stored scalar properties — racket
neither constructs them from scalars nor reads their fields; it would only ever
**pass through** a handle obtained from a prior boxed return. So the handle path
is `awRacketUnbox(a!, as: T.self)` pass-through, not field accessors. That path is
its own focused **follow-up leaf** (`…/040-deferred-residual/030-value-struct-handle-params`) because it
needs design the scalar-typedef recovery did not: (1) a **global struct-name set**
threaded to *both* the global pass and the per-framework emitter to keep the
content-addressed entry-name agreement sound while distinguishing a Swift
**value** struct (`AwValueBox`-safe to unbox) from a CF/ObjC **reference** type
(would trap) — the emitter only sees one framework at a time; (2) a **handle
producer** — the residual exposes no free function returning these types, so an
end-to-end smoke needs the class/instance handle path (or a constructor
trampoline) first. Per-field accessors reopen only when a transparent
value-struct consumer actually appears.

**Scope decision (040/020, user-confirmed).** This leaf lands the §6 done-bar
taxonomy (scalars, Foundation-bridged value types via the existing runtime,
objects→cpointer, `Optional`, Swift-`struct`-**return**→opaque handle, pointer
constants) **plus `throws`→trailing `NSError` out-param** (cheap; the
`ThrowsBridge.swift` runtime is ready). `async`, generic free functions, and
non-bridged-struct **params** / per-field handle accessors are **recorded with a
reason and counted** (above), wired in follow-up leaves. "Defer nothing" is
honoured as *nothing silently dropped*, not *everything wired at once*.

### 5b. Kick-back — the `deferred_async` bucket measured empty (040/040/020)

Like §5a, the async leaf measured the **whole IR first**, and the reality
overturned the leaf's framing (the spec assumed an async bucket to wire). Three
independent measurements over the 284 enriched frameworks agree:

| measurement | async free functions |
|---|---|
| enriched IR `swift_fn.is_async` (105 Swift-native free funcs: 34 generic, 11 throwing) | **0** |
| resolved IR (pre-enrichment), all 12,046 free functions | **0** |
| mangled-name `Ya` async-marker scan over every residual `s:` USR | **0** |

This is structural, not incidental: **`async` is a method/actor effect**, and the
trampoline residual is *top-level free functions + constants* (`s:` `Func`/`Var`)
only. Apple SDKs essentially have no top-level async free functions (the canonical
async surface — `URLSession.data(for:)`, etc. — is methods). The 040/030 count
list already silently carried no `deferred_async` line; it was 0 then too.

**Latent bug found + fixed (the real work this leaf landed).**
`swift-api-digester` (json_format_version 8, Xcode 16) emits **no structured
`async` field** — it emits `throwing`, but async is recoverable only from the
Swift **mangled name** (`Ya` effect marker, e.g. `URLSession.data(from:)` →
`…tYaKF`). The extractor read `AbiNode.is_async` from a renamed `"async"` JSON key
that never appears, so `is_async` was *permanently false*. Had an async free
function ever appeared it would have classified as **bindable**, and the codegen
would have emitted a synchronous `return Module.foo(…)` that does not compile.
Never triggered (empty bucket), but a real trap. Fixed in
`extract-swift/src/declaration_mapping.rs`: `is_async = node.is_async ||
node_is_async(node)`, where `node_is_async` matches the mangled-name suffix
`YaF`/`YaKF` (`mangled_is_async`). The OR keeps forward-compatibility if a future
digester (or an upstream PR) ever populates the field; the mangling is the
permanent, toolchain-independent floor. We do **not** patch the digester itself —
it is the Xcode-shipped toolchain binary, and the mangling is the more
authoritative source regardless (same rationale as §3a preferring ground truth
over the digester's lossy projection).

**Async codegen NOT built this leaf; spun to a frontier node (user-confirmed).**
Building the completion-callback `@_cdecl` + racket `_cprocedure` binding now would
be untestable — the node's done-bar requires "a real recovered async decl
resolves and runs", and there is none. The `AsyncBridge.swift` runtime (the
continuation core + a blocking `aw-async-await` wrapper were the chosen racket
surface) stays valid and **ready for its first real consumer: an async *method*
trampoline**. That is a larger frontier (it needs async-method *recovery*, beyond
the current free-function/constant machinery) and is grown as a new
planning-gated node, `040-racket-trampoline/050-async-methods`.

### 5c. Kick-back — value-struct **params** wired; the bucket measured again (040/040/030)

The `deferred_nonbridged_struct_param` follow-up leaf wired the genuine
**nameable value-struct parameter** path the §5a kick-back named. Measuring the
whole IR first (as §5a/§5b established) refined the 17 residual functions:

| sub-case | count | disposition |
|---|---|---|
| all params bindable once value structs unbox | **5** | **recovered** — `CreateML.show` (×3, `MLUntypedColumn`/`MLDataTable`), `CoreML.pointwiseMin`/`pointwiseMax` (`MLTensor`,`MLTensor`) |
| a value-struct param **mixed** with an `id`/`Any` param | 2 | reclassified `deferred_unnameable_param` (`pointwise{Min,Max}(MLTensor, id)`) |
| blocked by a genuine **CF/ObjC reference** param (`SecCode`, `SecTask`, `NSDecimalNumber`, `NSBundle`, `BlendTreeNode`, `SecStaticCode`) or an `OS_os_log`/`StaticString`/`UnsafeRawPointer`/`NSArray` param | 10 | stays `deferred_nonbridged_struct_param` |

Net: function trampolines **46 → 51**; the headline bucket **17 → 10**; nothing
dropped (5 + 2 + 10 = 17, with the 2 moving to a *more specific* reason).

**The gate (fork 1 + 2, resolved in leaf).** A param whose named type the owning
framework defines in `Framework.structs` is a Swift **value struct** the
`AwValueBox` round-trips — sound to `awRacketUnbox(aN!, as: Name.self)`. A CF/ObjC
**reference** type is in `classes` or absent, so "name ∈ the framework's struct
set" is exactly the soundness oracle. The set is built **per-framework, from the
function's own `Framework.structs`** (`value_struct_names`), threaded into both
`collect_trampolines` (global pass) and `generate_functions_file` (per-framework
emitter) so they classify identically. Per-framework is the *smallest sound
option*: the `@_cdecl` `import`s only its owning module, so a cross-module struct
type is not in scope to spell; all 5 real recoveries are same-module, and any
future cross-module struct param stays soundly deferred. Mixed-param functions
(fork 3) trampoline only when **every** param binds — `classify_function` defers
on the first non-bindable param, so the recorded reason is now the *actual*
blocker, not the value-struct that precedes it.

**Latent bug found + fixed (the real downstream work).** Recovering these params
exposed a dormant racket-side hole: `CreateML.show` has **three** overloads, all
now bindable. The C **entry** symbol was already content-addressed (§2 overload
hash), but the **racket-visible** binding name used the bare `swift_name` — so the
emitter wrote three `(define show …)` + three `[show …]` provides, which `raco
make` rejects (racket has no overloading). Dormant only because every overloaded
Swift-native free function happened to be deferred before this leaf. Fixed by
giving `FnTrampoline` a `binding_name` that carries the **same** overload hash the
entry does when `(module, name)` is overloaded (`show_06c0f52a`); one rule —
racket-name disambiguation mirrors entry disambiguation. Tree-wide check after the
fix: zero duplicate defines across all 284 frameworks.

**Smoke story (fork 4) — no in-residual producer; swiftc + assertion-test
evidence.** The residual exposes **no free function returning these value structs
non-circularly**: `pointwiseMin/Max` return `MLTensor` but *require* `MLTensor`
inputs, and the only non-`MLTensor` overloads take `id` (deferred); the root
producers are struct initializers/methods, outside the free-function residual. So
racket cannot obtain a first handle to feed back, and an end-to-end run is
unreachable in-residual (as the leaf brief's fork 4 anticipated). The done-bar
evidence is therefore: **`swift build` green** (the `awRacketUnbox(_, as: T.self)`
+ by-name call type-checks against the real CoreML/CreateML frameworks and links
into the dylib), the `trampoline.rs` codegen unit tests
(`value_struct_param_unboxes_through_the_handle`,
`mixed_value_struct_and_reference_param_defers_on_the_reference`,
`overloads_get_distinct_content_addressed_entries`), and a racket-local emitter
assertion (`value_struct_param_routes_through_aw_lib_with_framework_structs`) —
the §6 deviation pattern, zero cross-target pollution. The handle path waits for
its first real consumer (a class/instance handle or a constructor trampoline),
exactly as §5a deferred the per-field accessors.

## 6. Done-bar (the leaf's "resolves and runs")

- `apianyware-macos-generate` writes `Generated/Trampolines.swift`; `swift build`
  is green; `cargo test --workspace` green (incl. updated snapshots).
- The emitter routes Swift-native decls (`objc_exposed: false`) to trampolines,
  not `_fw-lib` — covering at minimum a scalar function, a `String` function, a
  Swift-struct return, and a pointer-valued constant. **Deviation (040/020):** the
  spec's first draft put these exemplars in the *shared* TestKit fixture
  (`generation/crates/emit/src/test_fixtures.rs`), but that fixture is consumed by
  the chez and gerbil snapshot tests too — whose trampoline support is leaves
  060/070 — so adding `s:` decls there would make them emit *broken direct
  bindings* and churn their goldens. The routing is therefore proven by
  **racket-local assertion tests** (`emit_functions.rs` / `emit_constants.rs`:
  `direct_and_trampoline_functions_route_to_different_libs`,
  `swift_string_function_uses_coercers`,
  `deferred_residual_is_recorded_as_comment_not_dropped`,
  `swift_native_constant_reads_through_aw_lib`, …) plus the codegen unit tests in
  `trampoline.rs` — same done-bar evidence, zero cross-target pollution. The shared
  fixture stays all-direct until chez/gerbil grow their own trampolines.
- **A real end-to-end smoke**: at least one real macOS Swift-native function and
  one real pointer-valued constant resolve through `libAPIAnywareRacket` and run
  from racket (the candidate real symbols are picked in the build leaf from the
  actual recovered residual; full rerun + VM-verify is 050's job).
- Per `feedback-regenerate-pipeline-aggressively`: regenerate rather than trust
  stale checkpoints.

### 6a. Known-good real exemplars (landed by 040/030)

The smoke leaf picked both exemplars from the **CreateML** residual (one module
keeps the proof focused) and proved them end-to-end. These are the canonical
known-good symbols for 050 and for future targets (chez 060 / gerbil 070):

| Kind | Swift decl | `s:` USR | Trampoline entry | C-ABI rep | Observed |
|---|---|---|---|---|---|
| scalar function | `CreateML.timestampSeed() -> Int` | `s:8CreateML13timestampSeedSiyF` | `aw_racket_swift_CreateML_timestampSeed` | `Int` | positive, time-derived (`1781577508722`) |
| pointer constant | `CreateML.MLCreateErrorDomain: String` | `s:8CreateML19MLCreateErrorDomainSSvp` | `aw_racket_swift_const_CreateML_MLCreateErrorDomain` | `id` (NSString) | `"com.apple.CreateML"` |

Both carry `objc_exposed: false` and have **no** C symbol in `CreateML.framework`
(they are reachable only via the trampolines). The repeatable smoke recipe:

```
SDKROOT=macosx cargo run --release -q -p apianyware-macos-generate -- --target racket
(cd swift && SDKROOT=macosx swift build)          # compiles Trampolines.swift into the dylib
racket generation/targets/racket/tests/test-swift-trampoline-smoke.rkt   # 3/3
```

The smoke is `generation/targets/racket/tests/test-swift-trampoline-smoke.rkt`
(rackunit; requires the generated `createml/functions.rkt` + `constants.rkt`,
asserts the raw `_aw-lib` symbols resolve and both decls run).

## 7. Out of scope (this leaf)

- chez/gerbil trampolines (060/070, their own ADRs).
- Walking/recovering `Macro`/`TypeAlias`/`AssociatedType` ABI kinds (030 records
  them as `deferred_abi_kind`; recovery is a later frontier leaf).
- Monomorphizing generic free functions (recorded as unbindable; reopen on need).
