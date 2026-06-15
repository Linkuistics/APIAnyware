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

## 5. The unbindable residual (defer nothing, but be honest)

Generic free functions cannot be trampolined. They are **not** silently skipped:

- The trampoline pass records each as a diagnostic (name + module + reason
  `unbindable_generic_free_function`) and logs the total count, so a clean
  generate reports "N Swift-native decls trampolined, M unbindable (generic)".
- If the residual surfaces a real, wanted generic API, revisit (monomorphization
  was the rejected option in ADR-0027 — reopen it only with a concrete need).

## 6. Done-bar (the leaf's "resolves and runs")

- `apianyware-macos-generate` writes `Generated/Trampolines.swift`; `swift build`
  is green; `cargo test --workspace` green (incl. updated snapshots).
- The TestKit synthetic fixture (`generation/crates/emit/src/test_fixtures.rs`)
  gains Swift-native exemplars (`objc_exposed: false`) covering the taxonomy rows
  the slice implements — at minimum a scalar function, a `String` function, a
  Swift-struct return, and a pointer-valued constant — so the snapshot goldens
  prove the emitter routes them to trampolines, not `_fw-lib`.
- **A real end-to-end smoke**: at least one real macOS Swift-native function and
  one real pointer-valued constant resolve through `libAPIAnywareRacket` and run
  from racket (the candidate real symbols are picked in the build leaf from the
  actual recovered residual; full rerun + VM-verify is 050's job).
- Per `feedback-regenerate-pipeline-aggressively`: regenerate rather than trust
  stale checkpoints.

## 7. Out of scope (this leaf)

- chez/gerbil trampolines (060/070, their own ADRs).
- Walking/recovering `Macro`/`TypeAlias`/`AssociatedType` ABI kinds (030 records
  them as `deferred_abi_kind`; recovery is a later frontier leaf).
- Monomorphizing generic free functions (recorded as unbindable; reopen on need).
