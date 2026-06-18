# 010-build

**Kind:** work

## Goal

Build the **sync receiver-handle method trampoline** for racket end-to-end
in-process: codegen + runtime + emitter routing fix + an in-process smoke over the
real `IndexSet` residual. Land the structural **ADR** (generalising ADR-0027 to
methods) and extend the design spec. This is the pioneer structural core that chez
(040) and gerbil (050) inherit.

**Scoped (measure-first, user-confirmed 2026-06-18):** `async` methods are split to
the sibling `020-async-method` leaf — the async path carries a real undesigned
piece (blocking racket await while the main loop services the callback) that would
muddy the structural ADR. This leaf classifies async methods as `deferred_async`
(recorded + counted, per the §5 discipline) and the async leaf wires them.

## Context

Read first: node `BRIEF.md` (the full D1–D7 design), root `BRIEF.md` (residual
measurement), and `docs/specs/2026-06-15-racket-trampoline.md` (the free-function
design this generalises — §2 entry naming, §3 marshalling taxonomy, §3a runtime,
§5 deferral discipline, §6 done-bar/deviation pattern).

**Exemplar picked (measure-first, this leaf):** pop-B = Foundation **`IndexSet`**
(value struct, `objc_exposed=false`) — `init(integer:)` (scalar param) → `contains(_:)`
(non-mutating, `Bool` return) → `update(with:)`/`insert(_:)` (**mutating**, scalar
param). Exercises every novel pop-B mechanism (init producer D2, value-receiver
unbox D2, non-mutating method, mutating write-back D3) with only `Int` params. The
write-back proof: `contains(h,9)`=#f → `update(h,9)` → `contains(h,9)`=#t on the
*same* handle.

Code map (cite-checked, 2026-06-18):
- Generalise: `generation/crates/emit-racket/src/trampoline.rs` (`FnTrampoline`,
  `classify_function`, `classify_param`/`classify_return`, `Scalar`/`ArgMarshal`/
  `RetMarshal`, content-addressed entry/`binding_name`, `Deferred`/`defer_counts`).
  Reuse the marshalling taxonomy — keep it in one place.
- Routing fix (D4): `emit-racket/src/emit_class.rs` `emit_method` (`:1196`) — branch
  at the top on `!method.objc_exposed` *before* the `objc_msgSend` paths.
- Global pass: `generation/crates/cli/src/generate.rs` `run_racket_trampolines`
  (`:219`) collects fn/const trampolines; extend to collect method/init trampolines
  too (iterate types-then-methods across `classes`+`structs`).
- Runtime: `swift/Sources/APIAnywareRacket/OpaqueHandle.swift` (`AwValueBox.value`
  is `let` → make `var` for D3; `awRacketBox`/`awRacketUnbox`); reuse
  `ThrowsBridge.swift`, `MemoryManagement.swift`.
- Racket seam: `generation/targets/racket/runtime/swift-trampoline.rkt` (`_aw-lib`,
  `aw-string-arg/result`, `aw-call/error`); smoke at `tests/test-swift-trampoline-smoke.rkt`.
- IR inputs (`020-method-recovery`): `ir::Method.swift_fn` (`{throwing,is_async,
  is_generic,self_kind}`), `ir::Struct.methods`, `init_method`. Owner type's `name`
  + `objc_exposed` reachable by iterating types-then-methods.

## Done when

- **`MethodTrampoline`** (sibling to `FnTrampoline`) with a **receiver** first param:
  `@_cdecl` unboxes the receiver — pop A (objc-exposed owner) = `id` via
  `Unmanaged.fromOpaque`; pop B value owner = `awRacketUnbox(recv, as: Owner.self)`;
  pop B class owner = `Unmanaged<Owner>.fromOpaque(recv).takeUnretainedValue()` —
  then calls `receiver.method(labels:)`.
- **Object/ObjC-class params (R1, measure-first kick-back):** an `objc_exposed`-class
  param (e.g. `NSIndexSet`) passes as an `id` cpointer, body `Unmanaged.fromOpaque`
  + bridges to the Swift param type. Non-objc reference params stay deferred.
- **Initializer producers (D2):** `init` trampolines call `Owner(labels:)` and box a
  handle of the **owning type** — *not* the lossy IR return type (R2 kick-back:
  `init(integer:)` reports `NSIndexSet`, must box `IndexSet`).
- **Mutating write-back (D3):** `AwValueBox.value` → `var`; a `self_kind=="Mutating"`
  value-receiver trampoline does `var v = unbox(recv); v.method(...); box.value = v`.
  `self_kind=="Consuming"` deferred-with-count.
- **Charter-#4 fix (D4):** `emit_method` branches on `objc_exposed` — `true`→msgSend
  (unchanged); `false`+trampolinable→trampoline entry via `_aw-lib`; `false`+deferred
  →**suppress + count** (no broken msgSend). Per-blocker deferred reasons surfaced.
- **In-process smoke:** the `IndexSet` exemplar resolves through `libAPIAnywareRacket`
  and runs (rackunit, mirroring `test-swift-trampoline-smoke.rkt`), proving the
  write-back round-trip.
- `swift build` green; `cargo test --workspace` green (incl. new codegen unit tests +
  updated snapshots; ObjC goldens unchanged). Racket-local routing assertion tests
  (the §6 deviation pattern — no shared-fixture churn into chez/gerbil goldens).
- **ADR** written (the "0027-for-methods" structural ADR) + the method sections added
  to the design spec, recording the R1/R2 kick-backs.

## Notes

Racket-only (ADR-0011). Async methods → `020-async-method`. Full cold rerun +
residual reproduction + VM-verify is `030-rerun-verify`.
