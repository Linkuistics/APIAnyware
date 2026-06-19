# 030-racket — brief

Pioneer node. Decomposed (2026-06-18) per D6 / the leaf's own Notes; the
measure-first step (in `010-build`) then split async out into its own leaf
(user-confirmed) — async carries a real undesigned piece (R4, blocking racket
await) that would muddy the structural ADR. Three leaves:

- **`010-build`** — sync structural core: `MethodTrampoline` codegen + runtime
  (receiver unbox A/B, init producers D2, mutating write-back D3, object params R1)
  + charter-#4 routing fix in `emit_class.rs` + IndexSet pop-B in-process smoke.
  Lands the structural ADR generalising ADR-0027 and extends the design spec.
  Async classified `deferred_async`.
- **`020-async-method`** — async-via-`await` (D5) + the blocking racket await
  surface (R4) + the `URLSession.data(from:)` pop-A headline smoke.
- **`030-rerun-verify`** — full cold pipeline rerun (`collect`→`analyze`→
  `generate --target racket`→`swift build`), `cargo test --workspace` green, CLI
  smoke, residual-count reproduction, and the §6b-style VM-verify in a bundled app
  (extend/mirror `swift-native-probe`) of both sync and async paths.

The original leaf's full design (Goal / Context / Done-when / Notes) is retained
below as the node's contract; the two leaves partition it.

## Goal

Pioneer the **receiver-handle method trampoline** for the racket target, end-to-end:
codegen + runtime + emitter routing + smoke + full cold rerun + VM-verify. Produces
the structural **ADR** (the "0027-for-methods", generalising ADR-0027) that chez
(040) and gerbil (050) then inherit with thin ADRs.

## Context

Blocks on `020-method-recovery` (the IR carries `swift_fn` on methods, recovered
inits, receiver-type exposure). Planning decisions D1–D7 in `010-plan`. The
free-function trampoline this generalises: `emit-racket/src/trampoline.rs`
(`classify_function`/`FnTrampoline`/`collect_trampolines`, content-addressed entry
names, `Deferred`/`defer_counts`); runtime `swift/Sources/APIAnywareRacket/`
(`OpaqueHandle.swift` box/unbox, `AsyncBridge.swift`, `ThrowsBridge.swift`).
Latent-broken routing to fix: `emit_class.rs:1196+` (every method → `objc_msgSend`,
no `objc_exposed` branch).

## Done when (the design this leaf must realise)

- **Recovery → codegen:** a `MethodTrampoline` (sibling to `FnTrampoline`) with a
  **receiver** first param; `@_cdecl` unboxes the receiver (D2 unified rep —
  `awRacketUnbox(recv, as: T.self)` value / `Unmanaged<T>.fromOpaque` class) and calls
  `receiver.method(labels:)`. Both populations (D1): A = objc-exposed receiver (`id`),
  B = Swift-native receiver (handle).
- **Initializer producers (D2):** `init` trampolines that call `Type(labels:)` and
  return a boxed handle — the population-B root producer.
- **Mutating write-back (D3):** `AwValueBox.value` → `var`; mutating-value-receiver
  trampolines write the mutated value back. `consuming self` deferred-with-count.
- **Async via `await` (D5):** the `operation` closure captures the **opaque pointer**
  (Sendable), unboxes inside, `await receiver.method(args)` (auto-hops), marshals the
  result to its Sendable C rep inside the closure. Verify Swift 6 Sendable-checking
  compiles clean over the real frameworks. `@MainActor` sync methods = measure-first edge.
- **Charter-#4 fix (D4):** `emit_class.rs` branches on `objc_exposed` —
  `true`→msgSend (unchanged), `false`+trampolinable→trampoline entry,
  `false`+deferred→**suppress + count** (no broken msgSend). Per-blocker deferred
  reasons surfaced (method analog of `defer_counts`).
- **Smoke (D7):** `URLSession.data(from:)` async headline over a deterministic local
  source (confirm symbol + that URLSession accepts it; else fall back to another
  recovered async method) **plus** a measure-first population-B exemplar (init →
  receiver-in → method, + mutating if available), picked from the actual recovered
  residual.
- **Full cold rerun + VM-verify** (the §6b done-bar): `collect`→`analyze`→`generate
  --target racket`→`swift build`; `cargo test --workspace` green; CLI smoke; the
  Swift-native-method path VM-verified in a bundled app (extend/mirror
  `swift-native-probe`). Residual counts reproduce from a cold collect.
- **ADR** written + the design spec extended (the method sections of
  `docs/specs/2026-06-15-racket-trampoline.md`, or a new method spec).

## Notes

Racket-only (ADR-0011). Measure-first before wiring (the §5a/b/c discipline). Likely
`leaf-decompose` into `010-build` + `020-rerun-verify` when picked.
