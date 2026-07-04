# The chez trampoline structure, and the ADR-0011 shared-source call

Decides the **chez** target's mechanism for vending C-ABI **trampolines** for the
Swift-native residual (`objc_exposed == false`), the chez counterpart to
**ADR-0027** (racket). Refines **ADR-0025** (the complete-API binding model and
trampoline elision), consumes **ADR-0026** (the `objc_exposed` IR fact), and is
governed by **ADR-0011** (the trampoline layer is per-target) and **ADR-0010** (the
native library *is* the binding). It also records
the **ADR-0011 shared-source call** now that a second Swift-trampoline target
exists.

This is the chez trampoline design decision. It
reuses the racket design spec `targets/racket/docs/design/2026-06-15-racket-trampoline.md` (the
marshalling taxonomy, deferred buckets §5a–c, and known-good exemplars §6a all
carry over unchanged — same shared IR) rather than re-deriving it.

## Context

030 made the direct-vs-trampoline boundary an explicit IR fact (ADR-0026) and
retained top-level `s:` funcs/constants so they reach the emitter. Racket then
built the first trampoline layer (ADR-0027): generated `@_cdecl` call-by-name
re-exports in `libAPIAnywareRacket`, bound from the racket emitter. Chez is the
second Swift-trampoline target — it already ships `libAPIAnywareChez` (loaded by
`runtime/ffi.sls`) and has the `aw_chez_*` `@_cdecl` convention — so this is a
**horizontal port, not a rediscovery**.

The residual is a deterministic function of the shared IR, so the chez pass
reproduces racket's classification **exactly**: **51 function trampolines, 7
constants**, deferred `6 closure_param / 10 nonbridged_struct_param /
4 unnameable_param / 34 unbindable_generic` (spec §6b). That equality is the
strongest evidence the port is faithful.

## Decision

### 1. Generated `@_cdecl` trampolines, called by name — same as racket

`apianyware-generate` emits a gitignored
`swift/Sources/APIAnywareChez/Generated/Trampolines.swift` in a global pass
(`run_chez_trampolines`, modelled on `run_racket_trampolines`), then `swift build`
compiles it into `libAPIAnywareChez`. Each residual decl becomes one `@_cdecl`
that `import`s the owning module and calls the API by reconstructed name + labels;
swiftc owns ABI correctness. Entry naming is content-addressed
`aw_chez_swift_<Fw>_<name>` / `aw_chez_swift_const_<Fw>_<name>`, with a short
overload hash, so the chez emitter reconstructs the symbol with no shared counter
(ADR-0013 precedent). The classification taxonomy (`ArgMarshal`/`RetMarshal`,
the value-struct unbox gate, the deferred reasons) is identical to racket's.

### 2. Scheme-side marshalling, not native (the ADR-0015 divergence)

Racket built a **native** marshalling layer (`OpaqueHandle.swift`, plus native
`aw_racket_nsstring_to_string` coercers it binds from racket). Chez keeps value
marshalling **Scheme-side** (ADR-0015: chez's compiled `foreign-procedure` crossing
is already at the dispatch floor, so a native shim only adds a hop):

- A `String`-returning trampoline returns the bridged `NSString` `id`; the chez
  binding coerces it with the **existing** `nsstring->string` / `objc_release`
  (`runtime/types.sls` + `runtime/ffi.sls`) — no new native string bridge.
- The chez emitter binds each entry with a plain `(foreign-procedure
  "aw_chez_swift_…" (…) …)` (not racket's `get-ffi-obj … _aw-lib`), wrapping only
  the `String`/`throws` shapes with Scheme-side coercers in a new
  `runtime/swift-trampoline.sls` (`aw-string-arg` / `aw-string-result` /
  `aw-call/error`).

Only the genuinely-native concerns get new **hermetic** Swift in `APIAnywareChez`:
`OpaqueHandle.swift` (`AwChezValueBox` + one uniform `aw_chez_box_free`) and
`ThrowsBridge.swift` (`awChezTry` / `awChezWriteError`, the trailing `NSError**`
out-param). These mirror racket's shape, renamed `awChez*`.

### 3. The lazy-instantiation forcing reference (a chez-specific hazard)

Chez instantiates an R6RS library **lazily** — its body runs only when one of its
exports is first referenced. `runtime/ffi.sls` loads `libAPIAnywareChez.dylib` *in
its body*, so a generated `functions.sls` whose only residual is a **pure-scalar**
trampoline (using none of the `swift-trampoline` coercers) would never trigger
that load, and its `aw_chez_swift_*` entries would fail to resolve at call. Racket
never hit this — it binds against an explicitly-loaded `_aw-lib` handle. The fix:
`swift-trampoline.sls` exports `aw-trampoline-lib-ready` (a binding whose RHS
references an `ffi` export, forcing the dylib load), and the emitter emits
`(define %aw-lib-ready aw-trampoline-lib-ready)` as the first line of every
trampoline section — the same forcing idiom as ffi.sls's own `%dylib-loaded`.

### 4. Scope — identical to racket (spec §5)

Land scalars, Foundation-bridged value returns (Scheme-side), objects→pointer,
`Optional`, Swift-`struct`-**return**→opaque box, pointer constants, **plus
`throws`**. `async` (bucket measured empty, spec §5b), generic free functions, and
non-bridged-struct/closure/unnameable **params** are recorded-with-reason and
counted, never silently dropped.

## The ADR-0011 shared-source call: keep hermetic duplication

This ADR records an explicit resolution of the
per-target-vs-shared-source question now that two Swift-trampoline targets exist.

**Call: keep hermetic per-target duplication (the ADR-0011 default). Do not extract
a shared trampoline source.**

What is duplicated: the classification taxonomy and the Swift codegen shape
(`emit-chez/src/trampoline.rs` mirrors `emit-racket/src/trampoline.rs`, ~600 lines).
What genuinely diverges, and would have to be parameterised away in any shared
crate: the entry prefix (`aw_chez_swift_` vs `aw_racket_swift_`), the Swift runtime
helper names (`awChez*` vs `awRacket*`), and — most substantively — the *binding
rendering*: chez emits `foreign-procedure` + **Scheme-side** marshalling (ADR-0015)
plus the lazy-instantiation forcing reference (§3), where racket emits
`get-ffi-obj` + **native** coercers against `_aw-lib`. The generated
`Trampolines.swift` files are also *not* literally shareable — they compile into
different dylibs under different entry-name prefixes.

So the shared half is a *taxonomy* (a property of the shared IR + the flat C ABI),
which the IR already centralises via `objc_exposed`; the per-target half is the
half that would actually need maintaining together. Per ADR-0011 ("duplication
across similar targets is accepted by design … cheap because LLM-assisted coding
makes a bespoke per-target native library affordable") the duplication is the
sanctioned choice, and it was not painful: the port reproduced the residual exactly
and the only new design work was the chez-specific lazy-instantiation fix — which a
shared source could not have abstracted anyway.

**Revisit trigger:** gerbil (070) becoming a *third* near-identical copy *and* the
per-target divergences shrinking. The opposite is expected — gerbil has no Swift
dylib (ADR-0017) and is the hard case, so it will likely diverge *more*, reinforcing
this call rather than overturning it.

## Consequences

- A new gitignored generated artifact, `APIAnywareChez/Generated/Trampolines.swift`,
  written by `generate` before `swift build` (global pass; `--chez-trampolines-out`
  / `--no-chez-trampolines` flags mirror the racket ones).
- The chez native lib gains a hermetic marshalling layer (`OpaqueHandle.swift`,
  `ThrowsBridge.swift`) and the chez runtime gains `swift-trampoline.sls`; the
  emitter (`emit_functions` / `emit_constants`) routes `objc_exposed == false`
  decls to trampolines, replacing the prior skip.
- `cargo test --workspace` green; the CLI smoke
  (`runtime/tests/smoke-swift-trampoline.sls`) proves the spec §6a exemplars
  (`CreateML.timestampSeed()` → time-derived `Int`, `MLCreateErrorDomain` →
  `"com.apple.CreateML"`) resolve and run through libAPIAnywareChez. The full cold
  rerun + VM-verify is a separate follow-up.
- **Chez-only.** Gerbil decides its own trampoline structure (ADR-0029); the
  shared-source call above stands.

See `CONTEXT.md` (*Trampoline*, *Opaque handle*, *Unbindable residual*) for the
glossary, ADR-0027 for the racket sibling, ADR-0015 for the Scheme-side-marshalling
divergence, and the racket design spec for the taxonomy this reuses.
