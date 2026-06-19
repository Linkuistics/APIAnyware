# 010-build

**Kind:** work

## Goal

Port the receiver-handle method trampoline machinery from `030-racket` (as
re-spelled for chez in `040-chez`, ADR-0031) into the **gerbil** emitter + dylib +
runtime, end-to-end through codegen + the swift-residual close + in-process/CLI
smoke. Land the thin structural ADR (the "0029-for-methods", mirroring how ADR-0031
mirrored ADR-0030) and extend the design spec / co-located gerbil docs.

## What to port (the racket/chez design, ADR-0030/0031 + spec §method)

1. **`MethodTrampoline` + `InitProducer` codegen** in `emit-gerbil/src/trampoline.rs`,
   mirroring `emit-chez/src/trampoline.rs`, under the gerbil `aw_gerbil_swift_*`
   content-addressed entry prefix. Receiver reconstruction by owner kind (ADR-0030 §1):
   class → `Unmanaged<Module.Owner>.fromOpaque(recv).takeUnretainedValue()`; value
   struct → `awGerbilUnbox(recv, as: Module.Owner.self)`. Calls `receiver.name(labels:)`
   by name; swiftc owns ABI. The `@_cdecl` bodies are the ADR-0011 hermetic duplicate
   of chez's, `awGerbil*` namespace.
2. **Init producers (D2)** — `init` trampolines call `Module.Owner(labels:)` and box
   the **owner** (not the lossy IR return type): `awGerbilBox` value /
   `Unmanaged.passRetained` class. On the gerbil binding side the returned object `id`
   is **wrapped to its exact bound type via the ADR-0020 `register-objc-class!`
   registry** (gerbil's substantive divergence from chez, ADR-0029 §2) — not a raw
   pointer. The only new decl kind.
3. **Mutating write-back (D3)** — `OpaqueHandle.swift` value box `.value` → `var`;
   mutating value-receiver writes the mutated value back to the single handle.
   `consuming self` deferred-with-count.
4. **Object-ref params (R1)** — the small verified `objc_object_param_bridge` table
   (`NSURL`→`URL` etc.), proven against the whole-Foundation typecheck, not assumed
   (already curated in the shared IR / racket+chez; reuse).
5. **Async via callback (D5/R4)** — async `@_cdecl` takes a trailing completion
   context + C callback, marshals args Sendably at entry, reconstructs receiver inside
   the `@Sendable` closure (`nonisolated(unsafe) let` pointer), awaits, marshals result
   to the Sendable C rep, delivers on the **main thread**. gerbil's free-function async
   bucket was **empty** (ADR-0029 §5, no Swift-native async free functions), so this is
   the **first gerbil async path** — add a new `AsyncBridge.swift` (`awGerbilAsyncDispatch`,
   the ADR-0011 hermetic duplicate of chez's `AsyncBridge.swift`) and a gerbil end
   `runtime/async-bridge.ss`. Confirm the gerbil main-thread delivery model — reuse the
   ADR-0022 main-thread-bounce idiom rather than inventing one. The two async
   sub-deferrals (mutating receiver, scalar return) carry from ADR-0030.
6. **Charter-#4 routing fix (D4)** in gerbil `emit_class.rs`: branch on `objc_exposed`
   **before** the supported-method gate — `true`→msgSend (unchanged), `false`+
   trampolinable→bind a `define-c-lambda` against the entry (wrapping objects via the
   ADR-0020 registry), `false`+deferred→**suppress + count** (no broken msgSend).
   Per-reason deferred counts surfaced. Watch the gerbil reserved-surface-name guard
   (`is_reserved_surface_name`, which omits procedures — the dual of chez's
   `(chezscheme)`-builtin collision in ADR-0031 §7; gerbil shadowing is harmless, so the
   chez `except` fix is **not** needed here — confirm).
7. **Swift-residual close (ADR-0031 §6 / ADR-0030 addendum B1–B5)** — gerbil emits its
   own `Trampolines.swift`, so it needs the equivalents: B1 (`.macOS(.v26)` floor) is
   **package-wide** in `swift/Package.swift` ⇒ inherited free; port B2 (implementation-
   detail module re-attribution, `swift_import_module`) and B3 (owner-availability fold,
   `max_macos_version`) into `emit-gerbil/trampoline.rs`; B4 (`KNOWN_UNBINDABLE` table
   keyed by the **gerbil** `aw_gerbil_swift_*` entry name — **same decl set** as
   racket/chez since IR-deterministic, gerbil entry-name prefix). B5 warning posture
   carries over.

## Runtime / Swift

- `swift/Sources/APIAnywareGerbil/OpaqueHandle.swift`: value box `.value` → `var` (D3)
  + any `awGerbilBox`/`awGerbilUnbox` generic helpers the method/init path needs.
- `swift/Sources/APIAnywareGerbil/AsyncBridge.swift`: **new** (mirror chez's), the
  first gerbil async surface.
- `generation/targets/gerbil/lib/runtime/swift-trampoline.ss`: method/init
  `define-c-lambda` binding shapes (receiver/handle args) + object wrapping via the
  ADR-0020 registry (mirror the gerbil free-function bindings already there).
- `generation/targets/gerbil/lib/runtime/async-bridge.ss`: **new**, the gerbil async
  delivery surface (structural analogue of chez's `async-bridge.sls`, gerbil-spelled
  with the ADR-0022 main-thread bounce).
- No lazy-instantiation forcing reference (ADR-0029 §4) — dylib linked at `gxc -exe`,
  symbols resolve at image load. Do **not** port chez's ADR-0031 §2 forcing idiom.

## Done when

- Codegen unit tests in `emit-gerbil` (sync receiver A/B, init producer, mutating
  write-back, async throws/void, the deferrals, object-ref bridge) green.
- A routing assertion test in gerbil `emit_class.rs` (objc_exposed branch).
- The **whole-Foundation** gerbil method/init residual compiles clean against real
  Foundation in Swift 6 mode (the strongest available proof — these defects are
  invisible to synthetic tests).
- **In-process / CLI smoke** of both 030 known-good exemplars through
  libAPIAnywareGerbil: pop-B IndexSet init→contains→mutating insert! write-back
  (D2+D3) and pop-A async `URLSession.data(from: file://…)` delivering a real
  `(Data, URLResponse)`.
- Residual classification **reproduces racket's/chez's counts** (§6d invariant) —
  report them.
- Thin ADR (`0032-gerbil-method-trampoline-structure.md` or next free number) + spec /
  gerbil docs extended.

## Notes

gerbil-only (ADR-0011). Reuse the 030 exemplars (D7). The full cold pipeline rerun +
`cargo test --workspace` + VM-verify is the sibling leaf `020-rerun-verify`.
