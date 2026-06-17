# 010-chez-trampoline-build

**Kind:** work

## Goal

Build the chez Swift-native trampoline: vend `aw_chez_swift_*` `@_cdecl` re-export
trampolines for the `objc_exposed == false` residual, and route the chez emitter to
bind them against `libAPIAnywareChez.dylib` with Scheme-side marshalling. Port the
proven racket mechanism (ADR-0027 + spec `docs/specs/2026-06-15-racket-trampoline.md`)
to chez idiom. CLI-smoke green. Full pipeline rerun + VM-verify is 020.

## What to build

1. **Trampoline codegen** — `generation/crates/emit-chez/src/trampoline.rs`, sibling
   to the racket `emit-racket/src/trampoline.rs`. Same call-by-name `@_cdecl`
   structure: `import` the owning framework, call the API by reconstructed name +
   arg labels, swiftc owns ABI correctness. Entry naming `aw_chez_swift_<Fw>_<name>`
   / `aw_chez_swift_const_<Fw>_<name>` (matches the `aw_chez_` convention), with the
   content-addressed overload hash (ADR-0013 / spec §2) so the emitter reconstructs
   names with no shared counter. Reuse racket's `SwiftFnInfo` (`throwing`/`is_async`/
   `is_generic`) and the same deferred-bucket reasons (§5a–c) — the residual is the
   *same shared IR*, so the same functions trampoline/defer.
2. **Global pass** — `run_chez_trampolines` in `generation/crates/cli/src/generate.rs`
   modelled on `run_racket_trampolines` (load enriched frameworks, collect residual,
   write `swift/Sources/APIAnywareChez/Generated/Trampolines.swift`, return count,
   run before `swift build`). Add `Generated/` to chez's gitignore as racket has.
3. **Hermetic chez Swift runtime** (ADR-0011 — no sharing with racket) in
   `swift/Sources/APIAnywareChez/`:
   - opaque value-box: `AwChezValueBox`/`awChezBox`/`awChezUnbox` + one uniform
     `@_cdecl aw_chez_box_free` (spec §3 box-rep resolution — one rep, `Unmanaged`
     for class instances only).
   - throws bridge: `awChezTry`/`awChezWriteError` (trailing `NSError**` out-param,
     mirroring the dispatch `error_out` write).
   - **No new String/collection bridge** — the trampoline returns `id` for `String`
     and the chez side reuses `nsstring->string` (`runtime/types.sls`). That is the
     ADR-0015 Scheme-side-marshalling divergence; honour it.
4. **Emitter routing** — `emit_functions.rs` / `emit_constants.rs`: for
   `!objc_exposed`, replace the current skip (which points here) with a trampoline
   bind: `(foreign-procedure "aw_chez_swift_…" (cabi-args) cabi-ret)` against the
   already-loaded `libAPIAnywareChez.dylib`, wrapped in the Scheme-side coercion
   (e.g. `nsstring->string` for a String return, raise-on-error for throws). Pointer
   constants route through a constant trampoline. Direct (`objc_exposed`) decls
   unchanged. Mirror the racket emitter assertions (`…route_to_different_libs`,
   `swift_string_function_uses_coercers`, deferred-recorded-not-dropped, etc.).

## Scope (port the racket §5 scope decision verbatim)

Land scalars, Foundation-bridged value returns (Scheme-side), objects→pointer,
`Optional`, Swift-struct **return**→opaque box, pointer constants, **plus throws**.
`async` (bucket measured empty, spec §5b), generic free functions, and non-bridged
struct/closure/unnameable **params** are recorded-with-reason + counted, not wired.
"Defer nothing" = nothing silently dropped.

## Done when

- `apianyware-macos-generate --target chez` writes `Generated/Trampolines.swift`;
  `(cd swift && SDKROOT=macosx swift build)` green; `cargo test --workspace` green
  (incl. new `trampoline.rs` unit tests + emitter assertions).
- The chez emitter routes residual decls to `aw_chez_swift_*` against
  `libAPIAnywareChez.dylib`, not the framework dylib; ObjC decls unchanged.
- A chez CLI smoke proves the §6a exemplars resolve and run through the chez
  trampolines: `CreateML.timestampSeed()` → time-derived `Int`,
  `MLCreateErrorDomain` → `"com.apple.CreateML"` (chez analog of
  `test-swift-trampoline-smoke.rkt`).
- **The chez trampoline structure is recorded** (new ADR mirroring ADR-0027, or a
  scoped extension), **and the ADR-0011 shared-source call is recorded** — the
  hermetic-duplication default holds unless the racket↔chez duplication proved
  painful; say which and why. Surface to the user only if it genuinely forked.

## Notes / risks

- Watch the chez↔racket marshalling asymmetry (ADR-0015): keep the Scheme-side
  coercion in chez, don't replicate racket's native string bridge.
- Per `feedback-regenerate-pipeline-aggressively`: regenerate, don't trust stale IR.
- If the codegen turns out to share enough with racket's that duplication bites,
  that is exactly the ADR-0011 trigger — record it and raise with the user before
  building a shared source (don't pre-emptively share).
