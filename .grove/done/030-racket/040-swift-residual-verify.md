# 040-swift-residual-verify

**Kind:** work

## Goal

Make the **full racket method-trampoline residual `swift build` green**, then close
the §6b-style done-bar for the method slice: CLI smoke + **VM-verify** of both
exemplars in a bundled app, the regression-harness extension, and the spec close.

Split out of `030-rerun-verify` (2026-06-19): that leaf landed the racket-side
emission (all 119 class files + 510 value-struct files load cleanly) and the cold
`collect`→`analyze`→`generate` rerun with the method residual reproduced. But the
**full 117-framework method residual had never been `swift build`-compiled** — leaves
010/020 only *typechecked Foundation*. Building it surfaces **955 errors** across ~12
categories. User-chosen approach (2026-06-19): **bump deployment target +
defer-with-count the rest.**

## Context

Read first: `030-rerun-verify` (the landed racket-side work + the residual numbers),
node `BRIEF.md`, `docs/specs/2026-06-15-racket-trampoline.md` §6b (the free-function
close to mirror) + §8/§9 (the method-trampoline design). The `@_cdecl` emitters are
`emit_method_tramp`/`emit_init_tramp`/`emit_async_method_tramp` in
`emit-racket/src/trampoline.rs`; availability rides `introduced_macos(provenance)` →
`@available(macOS v, *)`. Deferral taxonomy + `defer_counts` already exist (§8.6/§9.3).

Discipline: `feedback-vm-verify-every-app`, `reference-testanyware-cli`,
`feedback-use-testanyware`; `SDKROOT=macosx` for collect/analyze/swift build.

**The 955-error taxonomy (measured 2026-06-19, full residual swift build):**
- **840 availability** — `'X' is only available in macOS N` (N ∈ 14.2 … 26.4); the
  `@_cdecl` isn't gated high enough (`provenance: null` methods + type-availability >
  method-availability). → **deployment-target bump** to the SDK macOS clears these
  (host-targeted dylib; VM golden `macos-tahoe`/26). `.v26` is `unavailable` at
  `swift-tools-version 6.0` — bump the tools-version to expose it, or use the highest
  enum + defer the macOS-26-only residual. **Package platform is package-wide →
  chez/gerbil targets inherit the bump** (acceptable: all host tools).
- **~115 across ~11 categories** to **defer-with-count** (new `DeferReason`s + suppress
  the `@_cdecl` and the racket binding, agreeing across the global pass + emitter):
  `module 'X' is an implementation detail of 'Y'` (RealityFoundation, SwiftUICore — 8),
  `@MainActor`/actor-isolated call in nonisolated `@_cdecl` (34+8+6),
  `module has no member named` (16), `expect a compile-time constant literal` (6),
  `cannot pass immutable value as inout` (8), `not a member type` (6),
  `generic parameter could not be inferred` (4), `inaccessible due to protection level`
  (4), `noncopyable types cannot be conditionally cast` (2), `extra arguments` (2),
  `cannot assign value of type` (2). Surface each as a counted reason (§5 honesty).

## Done when

- **`swift build` green** over the full racket residual: deployment target raised
  (record the macOS version + that chez/gerbil inherit it, a thin ADR/spec note), the
  un-compilable categories **deferred-with-count** so no broken `@_cdecl` is emitted.
  The method residual classification **reproduces exactly** from a cold collect, with
  the new per-category deferred counts recorded.
- **No ObjC regression:** `cargo test --workspace` green (the pre-existing gerbil
  `computes_hello_window_closure` env-skip aside — see `030-rerun-verify` notes), and
  the `RUNTIME_LOAD_TEST` harness extended to carry the method-trampoline require-shape
  + a **receiver-method round-trip** (the §6b registration pattern, permanent guard).
- **CLI smoke** of both exemplars against the freshly built dylib: the pop-A async
  headline `URLSession.data(from: file://…)` (generated `foundation/urlsession.rkt`)
  **and** the pop-B `IndexSet` init→`contains`→`insert!` write-back round-trip
  (generated `foundation/indexset.rkt`).
- **VM-verified (project done-bar):** the `swift-native-probe` app extended (or a
  sibling) shows both exemplars live through `libAPIAnywareRacket`'s `@_cdecl`
  trampolines via the **generated require-tree** (not raw binds). Screenshot committed
  under `generation/targets/racket/test-results/`.
- The spec's **§6b-analog method-slice close** section is written (mirroring §6b), and
  the spec/ADR-0030 note that chez (040) and gerbil (050) inherit these known-good
  method exemplars + the deployment-target policy. Retiring this leaf empties the
  `030-racket` node.

## Notes

The racket-side emission is **done** (`030-rerun-verify`): naming
(`make_swift_method_name`/`make_swift_init_name`, base+labels, wildcard `_`→`argN`),
require-wiring (`swift-trampoline.rkt`/`async-bridge.rkt` + the `aw->` arrow alias that
survives the native header's `(except-in ffi/unsafe ->)`), init racket bindings
(`render_racket_init`), value-struct files (`generate_struct_file`, `owner_is_class =
false`), and ObjC/Swift name-collision exclusion. This leaf is **Swift-side + verify
only** — do not re-open the racket emitter except to wire new deferral reasons.
