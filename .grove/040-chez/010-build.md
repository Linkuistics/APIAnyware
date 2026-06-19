# 010-build

**Kind:** work

## Goal

Port the receiver-handle method trampoline machinery from `030-racket` into the
**chez** emitter + runtime, end-to-end through codegen + the swift-residual close +
in-process/CLI smoke. Land the thin structural ADR (the "0030-for-chez", mirroring
how ADR-0028 mirrored ADR-0027) and extend the design spec / co-located chez docs.

## What to port (the racket design, ADR-0030 + spec §method)

1. **`MethodTrampoline` + `InitProducer` codegen** in `emit-chez/src/trampoline.rs`,
   mirroring `emit-racket/src/trampoline.rs`. Receiver reconstruction by owner kind
   (ADR-0030 §1): class → `Unmanaged<Module.Owner>.fromOpaque(recv).takeUnretainedValue()`;
   value struct → `awChezUnbox(recv, as: Module.Owner.self)`. Calls
   `receiver.name(labels:)` by name; swiftc owns ABI.
2. **Init producers (D2)** — `init` trampolines call `Module.Owner(labels:)` and box
   the **owner** (not the lossy IR return type): `awChezBox` value / `Unmanaged.passRetained`
   class. The only new decl kind.
3. **Mutating write-back (D3)** — `AwChezValueBox.value` → `var`; mutating
   value-receiver writes the mutated value back to the single handle. `consuming self`
   deferred-with-count.
4. **Object-ref params (R1)** — the small verified `objc_object_param_bridge` table
   (`NSURL`→`URL` etc.), proven against the whole-Foundation typecheck, not assumed.
5. **Async via callback (D5/R4)** — async `@_cdecl` takes a trailing completion
   context + C callback, marshals args Sendably at entry, reconstructs receiver inside
   the `@Sendable` closure (`nonisolated(unsafe) let` pointer), awaits, marshals result
   to the Sendable C rep, delivers on main thread. Map onto the chez async surface
   (chez had an **empty** async bucket for free functions per ADR-0028 §4, so this is
   the first chez async path — confirm the chez main-thread/`_cprocedure`-equivalent
   delivery model). The two async sub-deferrals (mutating receiver, scalar return) carry.
6. **Charter-#4 routing fix (D4)** in chez `emit_class.rs`: branch on `objc_exposed`
   **before** the supported-method gate — `true`→msgSend (unchanged), `false`+
   trampolinable→bind a `foreign-procedure` against the entry, `false`+deferred→
   **suppress + count** (no broken msgSend). Per-reason deferred counts surfaced.
7. **Swift-residual close (ADR-0030 addendum B1–B5)** — chez emits its own
   `Trampolines.swift`, so it needs the equivalents: the `.macOS(.v26)` floor is
   **package-wide** (already bumped in `swift/Package.swift`) so chez inherits B1 for
   free; port B2 (implementation-detail module re-attribution, `swift_import_module`),
   B3 (owner-availability fold, `max_macos_version`), and B4 (`KNOWN_UNBINDABLE` table
   keyed by the **chez** content-addressed entry name — same decl *set* as racket since
   IR-deterministic, chez entry-name prefix). B5 warning posture carries over.

## Runtime / Swift

- `swift/Sources/APIAnywareChez/OpaqueHandle.swift`: `AwChezValueBox.value` → `var`
  (D3) + any `awChezBox`/`awChezUnbox` generic helpers the method/init path needs.
- `generation/targets/chez/apianyware/runtime/swift-trampoline.sls`: method/init
  binding shapes + async callback delivery (mirror the chez free-function coercers
  `aw-string-arg`/`aw-string-result`/`aw-call/error`; add receiver/handle + async).
- Keep the lazy-instantiation forcing reference (ADR-0028 §3) working for the new
  method sections.

## Done when

- Codegen unit tests in `emit-chez` (sync receiver A/B, init producer, mutating
  write-back, async throws/void, the deferrals, object-ref bridge) green.
- A routing assertion test in chez `emit_class.rs` (objc_exposed branch).
- The **whole-Foundation** chez method/init residual compiles clean against real
  Foundation in Swift 6 mode (the strongest available proof — these defects are
  invisible to synthetic tests).
- **In-process / CLI smoke** of both 030 known-good exemplars through libAPIAnywareChez:
  pop-B IndexSet init→contains→mutating insert! write-back (D2+D3) and pop-A async
  `URLSession.data(from: file://…)` delivering a real `(Data, URLResponse)`.
- Residual classification **reproduces racket's counts** (§6c invariant) — report them.
- Thin ADR (`0031-chez-method-trampoline-structure.md` or next free number) + spec /
  chez docs extended.

## Notes

chez-only (ADR-0011). Reuse the 030 exemplars (D7). The full cold pipeline rerun +
`cargo test --workspace` + VM-verify is the sibling leaf `020-rerun-verify`.
