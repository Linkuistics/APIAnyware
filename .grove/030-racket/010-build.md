# 010-build

**Kind:** work

## Goal

Build the **receiver-handle method trampoline** for racket end-to-end in-process:
codegen + runtime + emitter routing fix + a measure-first exemplar pick + an
in-process smoke. Land the structural **ADR** (generalising ADR-0027 to methods)
and extend the design spec. The heavy cold rerun + VM-verify is the sibling leaf
`020-rerun-verify` — this leaf proves the mechanism compiles and runs in-process.

## Context

Read first: node `BRIEF.md` (the full D1–D7 design), root `BRIEF.md` (residual
measurement: 5,620 bindable methods, A 672 : B 4,948, 1,963 inits, 282 async, 259
mutating value-receivers), and `docs/specs/2026-06-15-racket-trampoline.md` (the
free-function design this generalises — §2 entry naming, §3 marshalling taxonomy,
§3a runtime, §5 deferral discipline, §6 done-bar/deviation pattern).

Code map (cite-checked at decompose time, 2026-06-18):
- Free-function trampoline to generalise: `generation/crates/emit-racket/src/
  trampoline.rs` (1679 lines — `FnTrampoline`, `classify_function`,
  `collect_trampolines`, `generate_trampolines_swift`, content-addressed entry +
  `binding_name`, `Deferred`/`defer_counts`).
- Latent-broken routing to fix (charter #4 / D4): `generation/crates/emit-racket/
  src/emit_class.rs:1196+` — every method → `objc_msgSend`, no `objc_exposed`
  branch.
- Runtime (reuse, do not redo): `swift/Sources/APIAnywareRacket/` —
  `OpaqueHandle.swift` (`AwValueBox`, `awRacketBox`/`awRacketUnbox`,
  `aw_racket_box_free`), `AsyncBridge.swift` (`awRacketAsyncDispatch`,
  `AwAsyncOutcome`, main-thread delivery), `ThrowsBridge.swift`,
  `MemoryManagement.swift` (`aw_racket_retain`/`_release`).
- IR inputs from `020-method-recovery`: `ir::Method.swift_fn`
  (`{throwing,is_async,is_generic}`), `ir::Struct.methods`, `init_method`,
  receiver-type exposure reachable by iterating types-then-methods.

## Done when

- **`MethodTrampoline`** (sibling to `FnTrampoline`) with a **receiver** first
  param; `@_cdecl` unboxes the receiver per D2 (`awRacketUnbox(recv, as: T.self)`
  for value / `Unmanaged<T>.fromOpaque(recv).takeUnretainedValue()` for class) and
  calls `receiver.method(labels:)`. Both populations (D1): A = objc-exposed
  receiver (`id`), B = Swift-native receiver (handle).
- **Initializer producers (D2):** `init` trampolines calling `Type(labels:)`,
  returning a boxed handle — the population-B root producer.
- **Mutating write-back (D3):** `AwValueBox.value` → `var`; mutating-value-receiver
  trampolines write the mutated value back. `consuming self` deferred-with-count.
- **Async via `await` (D5):** the `@Sendable operation` closure captures the
  **opaque pointer**, unboxes inside, `await receiver.method(args)` (auto-hops),
  marshals the result to its Sendable C rep inside the closure. Verify Swift 6
  Sendable-checking compiles clean over the real frameworks.
- **Charter-#4 fix (D4):** `emit_class.rs` branches on `objc_exposed` — `true`→
  msgSend (unchanged); `false`+trampolinable→trampoline entry; `false`+deferred→
  **suppress + count** (no broken msgSend). Per-blocker deferred reasons surfaced
  (method analog of `defer_counts`).
- **Measure-first + exemplar pick (D7):** confirm the headline async symbol
  (`URLSession.data(from:)`, pop A) resolves + URLSession accepts a deterministic
  local source (else fall back to another recovered bindable-async method); pick a
  pop-B exemplar (init → receiver-in → method, + mutating if available) from the
  actual recovered residual.
- **In-process smoke:** the picked exemplars resolve through `libAPIAnywareRacket`
  and run from racket (rackunit, mirroring `test-swift-trampoline-smoke.rkt`).
- `swift build` green; `cargo test --workspace` green (incl. updated snapshots;
  ObjC goldens unchanged). Racket-local assertion tests for routing (the §6
  deviation pattern — no shared-fixture churn into chez/gerbil goldens).
- **ADR** written (the "0027-for-methods" structural ADR) + the method sections
  added to the design spec.

## Notes

Racket-only (ADR-0011). Measure-first before wiring (§5a/b/c discipline). If
measurement reveals new structure, grow a leaf rather than guess. The full cold
rerun + residual-count reproduction + VM-verify is `020-rerun-verify`.
