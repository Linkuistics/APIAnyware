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
the current free-function/constant machinery) and was first grown as a
planning-gated node, `040-racket-trampoline/050-async-methods`.

**Scope finalised (040/050 grilling, 2026-06-16, user-confirmed "own grove").**
That planning node measured the frontier and deferred it to a **dedicated grove**,
`add-swift-native-method-coverage` (seeded, gates `add-sbcl-clos-target`). The
measurement: async (445 methods) is one slice of **~3,181 Swift-native methods**
(`objc_exposed == false` on classes/structs/protocols) that are unbound today —
they route through `native_dispatch` (ObjC `msgSend`), which has no entry for a
Swift-native method, so per the founding charter's point #4 they are *latently
broken*, not merely missing. Reaching them needs **receiver-handle method
trampolines** (a `@_cdecl` taking an opaque receiver handle, calling
`receiver.method(labels:)` by name — generalising ADR-0027's free-function
call-by-name) plus Swift-native *method recovery* in collection/IR, then
propagation to chez/gerbil. async is the runtime-ready slice of that frontier, not
a separable task — so this trampoline spec (free functions + constants) is
complete as-is, and the method frontier is the new grove's charter.

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

### 6b. Full rerun + VM-verify landed (050)

The racket slice closed in leaf 050 (2026-06-16). The whole pipeline was re-run
cold from the real SDK and the Swift-native path verified end-to-end in a GUI app,
not just the in-process smoke:

- **Cold full rerun, clean.** `collect` (284 frameworks, 0 errors) → `analyze`
  (0 verification failures across 284) → `generate --target racket` → `swift
  build`. The residual classification **reproduced exactly** from a cold collect:
  **51 function trampolines, 7 constants**, deferred `6 closure_param /
  10 nonbridged_struct_param / 4 unnameable_param / 34 unbindable_generic` —
  i.e. the §5a–c counts are a deterministic function of the SDK, not an artifact
  of stale local IR. The CLI smoke passed 4/4 against the freshly built dylib.
- **No ObjC regression.** `cargo test --workspace` 944/0; the runtime-load harness
  (`RUNTIME_LOAD_TEST=1`) 7/7 — it now carries `CreateML` in `REQUIRED_FRAMEWORKS`,
  `swift-native-probe` in `APPS`, `swift-trampoline.rkt` in `RUNTIME_FILES`, and
  `createml/{functions,constants}.rkt` + `runtime/swift-trampoline.rkt` in
  `LIBRARY_LOAD_CHECKS`, so the trampoline require-shape and the constant-trampoline
  round-trip (a `dynamic-require` of `constants.rkt` *calls* the constant trampoline
  at module-init) are now permanent regression guards, not a one-time check.
- **VM-verified (project done-bar).** The `swift-native-probe` sample app
  (`apps/swift-native-probe/`, spec `docs/apps/swift-native-probe/`) is a bundled
  AppKit window showing the §6a exemplars live: `CreateML.timestampSeed()` returned
  a time-derived `Int` and `MLCreateErrorDomain` rendered `com.apple.CreateML`, both
  through `libAPIAnywareRacket`'s `@_cdecl` trampolines. Visually confirmed in the
  TestAnyware macOS VM (golden `macos-tahoe`); screenshot at
  `generation/targets/racket/test-results/swift-native-probe/screenshot.png`. The
  bundle's require-tree BFS pulled exactly `createml/{functions,constants}.rkt` +
  `runtime/swift-trampoline.rkt` + the dylib — the residual reaches a real app with
  no special bundling beyond what already ships the native-dispatch dylib.

This is the evidence behind ADR-0025's "Consequences": the model ADR stayed stable;
the mechanism earned its keep on real macOS. The chez (060) / gerbil (070) slices
reuse these same known-good exemplars.

### 6c. chez slice closed — full rerun + VM-verify landed (060/020)

The chez slice closed in leaf 060/020 (2026-06-18), mirroring the racket §6b close.
The build leaf 060/010 had already ported the mechanism (ADR-0028); 020 re-ran the
whole pipeline cold and proved the path in a GUI app:

- **Cold full rerun, clean.** `collect` (284 frameworks, 0 errors) → `analyze`
  (0 verification failures across 284, LLM annotations replayed from the
  git-tracked `analysis/ir/llm-annotations/`) → `generate --target chez` →
  `swift build`. The chez residual classification **reproduced exactly** and is
  **identical to racket's** (§6b) — **51 function trampolines, 7 constants**,
  deferred `6 closure_param / 10 nonbridged_struct_param / 4 unnameable_param /
  34 unbindable_generic`. Same shared IR ⇒ same residual; the counts are a
  deterministic function of the SDK, not stale local IR.
- **No ObjC regression.** `cargo test --workspace` 961/0. The chez CLI smoke
  (`runtime/tests/smoke-swift-trampoline.sls`) passed 3/3 against the freshly built
  `libAPIAnywareChez.dylib`, and is now registered as the permanent trampoline
  regression guard in the chez runtime README's "Verifying the runtime" harness —
  the chez analog of racket's `RUNTIME_LOAD_TEST` registration (chez verifies via
  `.sls` smoke scripts, not a Rust load test; the *content* of the guard — the
  trampoline require-shape + the constant-trampoline round-trip at module-init — is
  the same).
- **VM-verified (project done-bar).** The chez `swift-native-probe` sample app
  (`generation/targets/chez/apps/swift-native-probe/`) is a standalone open-world
  `.app` (ADR-0009) showing the §6a exemplars live: `CreateML.timestampSeed()`
  returned a time-derived `Int` (`1781740880061`) and `MLCreateErrorDomain` rendered
  `com.apple.CreateML`, both through `libAPIAnywareChez`'s `@_cdecl` trampolines —
  the constant Scheme-side coerced (ADR-0015) from the `id` the trampoline returns,
  not a native string bridge. Visually confirmed in the TestAnyware macOS VM (golden
  `macos-tahoe`); screenshot at
  `generation/targets/chez/test-results/swift-native-probe/screenshot.png`. The
  whole-program standalone compile (closure → `.boot`) is itself the chez
  load-verification; it caught a real internal-`define` ordering bug during the port,
  fixed before VM-verify.

### 6d. gerbil slice closed — full rerun + VM-verify landed (070/030)

The gerbil slice closed in leaf 070/030 (2026-06-18), the **last target**, mirroring
the racket §6b / chez §6c closes. The design landed in **ADR-0029** (the deliberate
ADR-0017 deviation — gerbil grows a trampoline-only Swift dylib because only Swift can
call the Swift ABI); 070/010 de-risked the build path, 070/020 ported codegen+emitter,
030 re-ran the whole pipeline cold and proved the path in a GUI app:

- **Cold full rerun, clean.** `collect` (284 frameworks, 0 errors) → `analyze`
  (0 verification failures, LLM annotations replayed) → `generate --target gerbil` →
  `swift build` → `gxc`. The gerbil residual classification **reproduced exactly** and
  is **identical to racket's and chez's** — **51 function trampolines, 7 constants**,
  deferred `6 closure_param / 10 nonbridged_struct_param / 4 unnameable_param /
  34 unbindable_generic`. Same shared IR ⇒ same residual.
- **No ObjC regression.** `cargo test --workspace` 985/0 (incl. the new `bundle-gerbil`
  swift-dylib relocation tests). The gerbil `run-smokes.sh` harness now **chains**
  `smoke-swift-trampoline.ss` as the permanent Swift-native regression guard (the
  require-shape + constant-trampoline round-trip at module init) — the gerbil analog of
  racket's `RUNTIME_LOAD_TEST` / chez's smoke registration.
- **VM-verified (project done-bar).** The gerbil `swift-native-probe` sample app is a
  standalone self-contained `.app` (ADR-0009) showing the §6a exemplars live:
  `CreateML.timestampSeed()` returned a time-derived `Int` (`1781763860100`) and
  `MLCreateErrorDomain` rendered `com.apple.CreateML`, both through
  `libAPIAnywareGerbil`'s `@_cdecl` trampolines (bound via `define-c-lambda`, the
  constant Scheme-side coerced per ADR-0015). Gerbil **links** the dylib at `gxc -exe`
  time (ADR-0029 §4, unlike chez's dlopen); `bundle-gerbil` vendored + relocated it into
  `Contents/Frameworks/` by the same path that relocates openssl@3 (ADR-0029 §3) — the
  bundled exe's `otool -L` shows only `/usr/lib/*`, system frameworks, and
  `@executable_path/..`. Visually confirmed in the TestAnyware VM (golden `macos-tahoe`);
  screenshot at `generation/targets/gerbil/test-results/swift-native-probe/screenshot.png`.
- **N1 measured (ADR-0029).** The added `swift build` step is **3.96s cold** (84 KB
  dylib), orthogonal to and ~74× smaller than the ~292s generics compile (ADR-0023,
  unchanged) — the build-time *win* hypothesis does not hold; the dylib is necessity,
  not a gain.

All three targets (racket, chez, gerbil) are now re-run and VM-verified — the charter's
"rerun every target" done-bar is met and the grove is ready to finish.

## 7. Out of scope (this leaf)

- chez/gerbil trampolines (060/070, their own ADRs).
- Walking/recovering `Macro`/`TypeAlias`/`AssociatedType` ABI kinds (030 records
  them as `deferred_abi_kind`; recovery is a later frontier leaf).
- Monomorphizing generic free functions (recorded as unbindable; reopen on need).

## 8. The method frontier — receiver-handle method trampolines (ADR-0030)

Implements **ADR-0030** (generalises this spec's free-function trampoline to
Swift-native methods + initializers). Added by grove
`add-swift-native-method-coverage`, leaf `030-racket/010-build` (the sync
structural core; `async` methods are leaf `020-async-method`). Same `emit-racket`
module (`trampoline.rs`), same global pass, same `Generated/Trampolines.swift`.

### 8.0 Inputs (from `020-method-recovery`)

`ir::Method.swift_fn: Option<SwiftFnInfo>` (now also carrying `self_kind`:
`"Mutating"`/`"NonMutating"`/`"Consuming"`/…), `ir::Struct.methods` (Swift value
types now carry their methods), and recovered `init_method`. A method is
Swift-native iff `swift_fn.is_some()` (⇔ `objc_exposed == false`); the owning type
is population B iff its `objc_exposed == false`.

### 8.1 New plan types

- `MethodTrampoline { module, owner, swift_name (selector base), entry, recv:
  SelfMarshal, labels, params, ret, ret_nullable, throwing, availability }`.
- `InitTrampoline { module, owner, entry, owner_is_class, labels, params, throwing,
  availability }`.
- `SelfMarshal::{ ClassRef, ValueBox { mutating } }` — receiver reconstruction by
  owner kind (class iterated from `Framework.classes` ⇒ `ClassRef`; struct from
  `Framework.structs` ⇒ `ValueBox`). `TrampolineSet` gains `methods` + `inits`.

### 8.2 `@_cdecl` shape

The receiver is the first C param (`_ awRecv: UnsafeMutableRawPointer?`), then the
marshalled args (§3 taxonomy unchanged), then the trailing `NSError**` when
throwing. Receiver prelude:

```swift
// class owner (objc-exposed or Swift-native class):
let awSelf = Unmanaged<Module.Owner>.fromOpaque(awRecv!).takeUnretainedValue()
// value-struct owner, non-mutating:
let awSelf = awRacketUnbox(awRecv!, as: Module.Owner.self)
// value-struct owner, mutating (D3 write-back):
let awBox = Unmanaged<AwValueBox>.fromOpaque(awRecv!).takeUnretainedValue()
var awSelf = awBox.value as! Module.Owner
// … let awR = awSelf.method(...) ; awBox.value = awSelf ; return marshal(awR)
```

The call is `awSelf.<base>(<labels: args>)`. An init is `Module.Owner(<labels:
args>)` boxed as the owner (`awRacketBox` value / `Unmanaged.passRetained` class) —
**not** the lossy IR return type (R2).

### 8.3 Method return marshalling (differs from §3 free-function returns)

- A method's non-scalar return always boxes **unnamed** (`Handle(None)`; no `as
  <Type>` pin — the call is unambiguous and the IR name is often unspellable:
  `Tuple`, `ProtocolComposition`, `Iterator`, nested types).
- An **integer** scalar param/return uses `numericCast` (the IR collapses
  `Int`/`Int64` etc.); `Bool`/`Float`/`Double` pass through. **Init params do not**
  `numericCast` — the declared width selects the overloaded initializer.
- **Nullable** String/handle returns map `nil` → NULL/`#f`; a nullable scalar
  return is deferred (a C scalar can't carry `nil`).

### 8.4 Entry naming

`aw_racket_swift_m_<Fw>_<Owner>_<base>[_<hash>]` (methods),
`aw_racket_swift_init_<Fw>_<Owner>[_<hash>]` (inits). The content hash (FNV over
selector + ABI shape) is appended only when `(module, owner, base)` (resp. the
owner's inits) is overloaded. Duplicate decls collapsing to the same entry are
deduped (keep first) before emission.

### 8.5 Charter-#4 routing (D4)

`emit_class`'s method emitter branches on `objc_exposed` **before**
`is_supported_method` (which would otherwise drop the parenthesised Swift
selector): `false` & trampolinable → `MethodTrampoline::render_racket_method`
against `_aw-lib` (receiver passed first as `(coerce-arg self)`); `false` &
deferred → suppress (global pass counts it); `true` → unchanged msgSend. The
owning framework's `value_struct_names` are threaded into `generate_class_file`
(forward-compat; value-struct method params are deferred this leaf).

### 8.6 Deferral taxonomy (method-specific, counted)

`unbindable_generic_method`, `deferred_async` (→ leaf 020),
`deferred_consuming_receiver`, `deferred_static_method`,
`deferred_non_nameable_method` (operators), `deferred_variadic_method`,
`deferred_nullable_scalar_return`, plus the inherited param reasons (value-struct
and object/reference params defer this leaf — object params are the async leaf's
R1).

### 8.7 Done-bar evidence (the §6 deviation pattern, racket-local)

Codegen unit tests in `trampoline.rs` (receiver A/B, init producer, mutating
write-back, deferral categorisation, overload disambiguation); a routing assertion
test in `emit_class.rs` (`swift_native_method_routes_to_trampoline_not_msgsend`);
the **whole Foundation residual** (68 inits + 92 methods + 2 constants) compiling
clean against real Foundation in Swift 6 mode (via the `#[ignore]`d
`generate_foundation_trampolines_to_disk` generator + `swiftc -typecheck`); and an
**in-process smoke** binding the real `IndexSet` `init(integer:)` / `contains(_:)`
/ `insert(_:)` `@_cdecl`s raw against the built dylib — proving init producer →
value-receiver unbox → mutating write-back on one stable handle. Full cold rerun +
VM-verify is leaf `030-rerun-verify`; `async` methods + the blocking-await surface
are leaf `020-async-method`.

### 8.8 Full-residual `swift build` close (leaf `030-racket/040-swift-residual-verify`)

Leaves 010/020 only *typechecked Foundation*. Compiling the **full 117-framework
residual** (593 init + 588 method `@_cdecl`s) surfaced **955 errors** across ~14
categories — availability gates the IR can't synthesise, impl-detail-module imports,
and per-decl semantic failures — that single-framework typechecks never reach. The
close, all racket-emitter-side (chez/gerbil inherit through the shared IR), is
**ADR-0030 §B**:

- **Deployment-target bump** `swift/Package.swift` → `swift-tools-version 6.2`,
  `platforms: [.macOS(.v26)]` (the host SDK floor). A `@_cdecl` is a plain global
  function, so raising the package minimum clears every API introduced at ≤ 26.0
  without per-decl `@available` — **826 of 955** in one move (§B1). Package-wide ⇒
  chez/gerbil inherit; acceptable as all three are **host tools** (VM golden
  `macos-tahoe`/26), never back-deployed apps.
- **Umbrella re-attribution** (`swift_import_module`): impl-detail modules
  (`RealityFoundation`→`RealityKit`, `SwiftUICore`→`SwiftUI`) are re-attributed for
  the **Swift `import` + type qualifier only** — the entry symbol + Racket binding
  keep the original module — rescuing **~250** trampolines that can't import their own
  module (§B2).
- **Owner-availability fold** (`max_macos_version`): a `@_cdecl` is gated to the max of
  the method's and its owning value-struct's `introduced:`, binding the type-gated
  inits (§B3).
- **Curated `KNOWN_UNBINDABLE`** (51 decls): the genuinely-un-trampolinable residual —
  dominated by `@MainActor`/actor isolation, which `swift-api-digester` **does not
  surface** — keyed by content-addressed entry name, each counted under its
  `DeferReason` (the libobjc Option-B precedent; the full `swift build` is its
  regression guard) (§B4). A further **~60** `@MainActor @preconcurrency` decls compile
  with a *warning* and are **kept** (they run on the main thread, the GUI use case);
  a sound off-main variant is a future async-hopping frontier (§B5).

Result: `swift build` **green** over the full residual (576 init + 554 method emitted;
the 51 + the modules' non-re-exported tail deferred-with-count), the classification
**reproducing exactly** from a cold `collect`→`analyze`→`generate`. Done-bar evidence
(cold rerun, `cargo test`, the two-exemplar CLI smoke, the `RUNTIME_LOAD_TEST` method
round-trip, the `swift-native-method-probe` VM-verify) is ADR-0030 §B6.

## 9. Async methods + object-ref params (ADR-0030 addendum, leaf `030-racket/020`)

Decided in ADR-0030's *Addendum*; this section is the implementation contract.
Same `trampoline.rs`, same global pass.

### 9.1 Async `@_cdecl` shape (D5) — `emit_async_method_tramp`

The signature is `(receiver, <args>, awCtx: Int, awCb: @convention(c) (Int,
value, error) -> Void)`, returns void (no `NSError**`: errors ride
`AwAsyncOutcome.error`). Body:

```swift
let o0 = Unmanaged<NSURL>.fromOpaque(a0!).takeUnretainedValue() as URL  // args at entry
nonisolated(unsafe) let awRecvUnsafe = awRecv                            // pointer is not Sendable
awRacketAsyncDispatch({ () async -> AwAsyncOutcome in
  let awSelf = Unmanaged<Foundation.URLSession>.fromOpaque(awRecvUnsafe!).takeUnretainedValue()
  do { let awR = try await awSelf.data(from: o0)
       return AwAsyncOutcome(value: awRacketBox(awR)) }       // marshal off-main
  catch { return AwAsyncOutcome.failure(error) }
}, { awOutcome in awCb(awCtx, awOutcome.value, awOutcome.error) })       // deliver on main
```

Args marshal to Sendable values **at entry** (no dangling across the `Task`); the
receiver pointer rides `nonisolated(unsafe)` and is unboxed **inside** the closure;
the result marshals to `AwAsyncOutcome` (pointer payload) **on the cooperative
thread**. Non-throwing drops the do/catch and the `try`; `Void` returns
`AwAsyncOutcome()` (the racket completion gets `#f`).

### 9.2 R4 racket surface — the callback form (`async-bridge.rkt`)

`render_async_racket_method` emits a binding whose ffi arrow ends `… _intptr
_fpointer -> _void` and whose body is:

```racket
(lambda (self url complete)
  (aw-async-call (lambda (id cb) (raw (coerce-arg self) url id cb)) values complete))
```

`aw-async-call` registers `complete` under a fresh id, then kicks the trampoline
with that id + the **one GC-stable callback fptr** (passed as `_fpointer`, never a
`_cprocedure` *param*). The completion fires on the main thread and runs `(complete
result err)` — non-blocking, no run-loop pump (the app's loop already runs; a CLI
smoke pumps `CFRunLoopRunInMode` itself). `coerce` is `values` for a boxed handle /
void, `aw-string-result` for a String.

### 9.3 R1 object-ref params — `ArgMarshal::ObjectRef`, `objc_object_param_bridge`

A `Class` param in the curated bridge table reconstructs the objc reference and
casts to the value twin (`Unmanaged<NSURL>…takeUnretainedValue() as URL`); racket
passes the `id` cpointer straight through (`_pointer` ffi, `cpointer?` contract).
The table is **proven against the whole-Foundation typecheck** (start `NSURL`,
`NSURLRequest`; `inout` twins like `NSDate` are invisible in the IR and stay out).
**Init object params defer** (`Data(referencing:)` wants the reference). New
deferral reasons: `deferred_async_mutating_receiver`, `deferred_async_scalar_return`.

### 9.4 Done-bar evidence

`trampoline.rs` codegen tests (async throws/void/non-throwing, both async deferrals,
object-ref bridging); whole-Foundation residual compiles clean in Swift 6 (async +
R1 included; the lone residual error is the *pre-existing* `provenance: null`
availability gap on `AttributeContainer.filter`, → `030-rerun-verify`); and the
**in-process smoke** (`generation/targets/racket/runtime/smoke/`) running real
`URLSession.data(from: file://…)` through the real `async-bridge.rkt` and asserting a
real `(Data, URLResponse)` returned. Generated-file require wiring + the
`needs_native` `_fun` interaction are carried to `030-rerun-verify`.
