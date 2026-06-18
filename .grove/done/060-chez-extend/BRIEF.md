# 060-chez-extend — brief

## Goal

Extend the proven Swift-native trampoline mechanism (racket, ADR-0027 + spec
`docs/specs/2026-06-15-racket-trampoline.md`) to the **chez** target. Chez ships a
Swift dylib (`APIAnywareChez`) already loaded by `runtime/ffi.sls`, so this is the
second-easiest target — and the first point where the **per-target-vs-shared-source**
question for the trampoline becomes real (two Swift-trampoline targets now exist).

## Decomposition (decomposed from the original work leaf, 2026-06-17)

The original `060-chez-extend.md` work leaf was decomposed for **size**, not because
the ADR-0011 design question reopened: the build (trampoline codegen + a hermetic
chez Swift box/throws runtime + emitter routing) and the project-mandated VM-verify
(memory `feedback-vm-verify-every-app`) are two focused commits. Discovery is
*done* — same shared IR as racket, so the residual, the deferred buckets, and the
known-good exemplars (`CreateML.timestampSeed`, `MLCreateErrorDomain`) all carry over
(spec §6a). This is a horizontal port, not rediscovery.

- **010-chez-trampoline-build** — vend `aw_chez_swift_*` `@_cdecl` trampolines into
  `swift/Sources/APIAnywareChez/Generated/Trampolines.swift`; add the hermetic chez
  Swift box/throws runtime; route the chez emitter (`emit_functions`/`emit_constants`)
  to bind them against `libAPIAnywareChez.dylib` with **Scheme-side** marshalling
  (ADR-0015); CLI smoke. Records the chez trampoline structure (a new ADR mirroring
  ADR-0027, or an extension note) **and the ADR-0011 call**.
- **020-chez-rerun-verify** — full cold pipeline rerun for chez + VM-verify (the
  project done-bar).

## Done when (node)

- chez trampolines + emitter bindings landed; full pipeline rerun; **VM-verified**.
- **ADR-0011 shared-source question explicitly resolved and recorded:** the ADR-0011
  default (hermetic per-target duplication, "duplication across similar targets is
  accepted by design") holds unless racket+chez duplication proves painful enough to
  justify a shared Swift trampoline source. Record the call either way — promoted to
  the chez trampoline ADR at node retirement.

## Key divergence from racket (watch in 010)

- **Scheme-side marshalling (ADR-0015), not native.** Racket built a native
  marshalling layer (`OpaqueHandle.swift`, native `aw_racket_nsstring_to_string`).
  Chez keeps marshalling Scheme-side: a `String`-returning trampoline returns an
  `id` (NSString); the chez binding coerces with the *existing* `nsstring->string`
  (`runtime/types.sls`) — no new native string bridge. Only the genuinely-native
  concerns (opaque value-box + `free`, the `throws` NSError out-param) get new
  hermetic Swift in `APIAnywareChez`.
- The chez emitter already skips the residual with a comment pointing at "leaf 060"
  (`emit_functions.rs:31`, `emit_constants.rs:106`); this node replaces that skip.

## Pointers

- ADR-0027 + `docs/specs/2026-06-15-racket-trampoline.md` — the racket reference
  (taxonomy §3, deferred buckets §5a–c, exemplars §6a).
- `generation/crates/emit-racket/src/trampoline.rs` — racket codegen reference.
- `generation/crates/cli/src/generate.rs:219 run_racket_trampolines` — global-pass
  reference.
- chez: `generation/crates/emit-chez/src/{emit_functions,emit_constants}.rs`,
  `generation/targets/chez/apianyware/runtime/{ffi,types}.sls`,
  `swift/Sources/APIAnywareChez/ChezRuntime.swift` (`@_cdecl` `aw_chez_*` style).
- ADR-0011 (hermetic isolation), ADR-0015 (chez direct dispatch + Scheme marshalling),
  ADR-0009 (chez self-contained bundle).
