# 020-trampoline-codegen-and-emitter

**Kind:** work

## Goal

Fill the dylib stood up in 010 with **generated** Swift-native trampolines and
route the gerbil emitter to bind them — the horizontal port of chez's
codegen+emitter (ADR-0028 → ADR-0029), with gerbil's `define-c-lambda` +
ADR-0020-wrap divergences.

## Context

ADR-0029 §1/§2/§5. Same shared IR as racket/chez, so the residual classification
(`ArgMarshal`/`RetMarshal`, value-struct unbox gate, deferred reasons) carries
over unchanged. Reference: `generation/crates/emit-chez/src/trampoline.rs` (codegen),
`generation/crates/cli/src/generate.rs` `run_chez_trampolines` (global pass),
the racket spec `docs/specs/2026-06-15-racket-trampoline.md` (taxonomy §3,
deferred §5a–c, exemplars §6a). The skips to replace:
`emit-gerbil/src/emit_functions.rs:49`, `emit_constants.rs:133`.

## Done when

- **Generate pass.** `run_gerbil_trampolines` (modelled on `run_chez_trampolines`)
  writes gitignored `swift/Sources/APIAnywareGerbil/Generated/Trampolines.swift`:
  one `@_cdecl aw_gerbil_swift_<Fw>_<name>` / `…_const_<Fw>_<name>` per residual,
  `import`ing the owning module, calling by reconstructed name+labels (swiftc owns
  ABI). Content-addressed naming with overload hash (no shared counter).
  `--gerbil-trampolines-out` / `--no-gerbil-trampolines` flags mirror chez/racket.
- **Hermetic Swift.** `OpaqueHandle.swift` (`AwGerbilValueBox` + uniform
  `aw_gerbil_box_free`) and `ThrowsBridge.swift` (`awGerbilTry`/`awGerbilWriteError`,
  trailing `NSError**`), mirroring chez renamed `awGerbil*`.
- **Emitter routing.** `emit_functions`/`emit_constants` route `objc_exposed ==
  false` decls to trampoline bindings instead of skipping. Each entry bound by a
  per-signature `define-c-lambda` in a new `runtime/swift-trampoline.ss`; `String`
  returns coerced via gerbil's existing `cocoa.ss` bridge; **object returns
  `wrap`ped to exact bound type via the ADR-0020 `register-objc-class!` registry**;
  `throws` shapes routed through the Swift error bridge. Deferred buckets
  (closure/nonbridged-struct/unnameable/generic) recorded-with-reason + counted,
  never silently dropped.
- **CLI smoke** proves the §6a exemplars resolve and run through
  `libAPIAnywareGerbil`: `CreateML.timestampSeed()` → time-derived `Int`,
  `MLCreateErrorDomain` → `"com.apple.CreateML"`. (Full cold rerun + VM-verify is
  030.)
- `cargo test --workspace` green; emitter snapshot goldens updated; the residual
  count printed matches racket/chez (51 funcs, 7 constants).

## Notes

- If codegen reveals ADR-0029 underspecified, kick back and update the ADR rather
  than guessing (racket-030 pattern).
- The object-return-wrap is gerbil's substantive divergence from chez — verify a
  trampoline returning an `id` lands as the correctly-typed bound wrapper, not a
  raw pointer.
