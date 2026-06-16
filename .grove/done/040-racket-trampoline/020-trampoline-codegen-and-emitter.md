# 020-trampoline-codegen-and-emitter

**Kind:** work

## Goal

Generate the trampolines and bind them: the global pass that writes
`Generated/Trampolines.swift`, plus the racket emitter changes that route the
Swift-native residual through `libAPIAnywareRacket` instead of the framework
dylib. Binds to the runtime built in 010.

## Scope (per `docs/specs/2026-06-15-racket-trampoline.md` §1,2,4,5)

- **Codegen (`emit-racket`, new `src/trampoline.rs`):** `collect_trampolines` over
  enriched frameworks (every retained `objc_exposed == false` decl);
  `generate_trampolines_swift` → one **call-by-name** `@_cdecl` per trampolinable
  decl (`import <Framework>`; reconstruct `name(label:…)` from `Function.name` +
  `Param.name`s; marshal per the §3 taxonomy via 010's exports). Naming per §2
  (`aw_racket_swift_<Fw>_<name>`, sig-hash on overload; `…_const_…` for
  constants).
- **Global pass (`cli/src/generate.rs`):** `run_racket_trampolines` modelled on
  `run_racket_native_dispatch` — runs after `run_generation`, before `swift build`,
  writes `swift/Sources/APIAnywareRacket/Generated/Trampolines.swift`, returns +
  logs the entry count.
- **Emitter wiring (`emit_functions.rs`, `emit_constants.rs`):** branch on
  `objc_exposed`. Direct → unchanged (`_fw-lib`). Trampolined → emit `_aw-lib`
  (ffi-lib to `libAPIAnywareRacket`) once per file + `get-ffi-obj
  'aw_racket_swift_… _aw-lib` with the ffi2 rep + racket-side coercion. Pointer
  Swift constants → constant trampoline. Contracts/`provide` describe the
  racket-visible (post-coercion) type.
- **Unbindable generics (§5):** emit nothing; record name+module+reason
  `unbindable_generic_free_function`; surface the count in the pass log.
- **Racket-side coercers:** any new `runtime/*.rkt` helpers the reps need.
- **TestKit fixture + goldens:** add Swift-native exemplars
  (`objc_exposed: false`) to `generation/crates/emit/src/test_fixtures.rs`
  covering the implemented rows (≥ scalar fn, String fn, struct-return, pointer
  const); update emit-racket snapshot goldens so they prove `_aw-lib` routing.

## Done when

- `apianyware-macos-generate` writes `Generated/Trampolines.swift`; `swift build`
  green; `cargo test --workspace` green (snapshots updated).
- Goldens show Swift-native decls bound via `_aw-lib`/`aw_racket_swift_…`, ObjC
  decls unchanged via `_fw-lib`.
- The pass logs "N trampolined, M unbindable (generic)".

## Notes

- Regenerate, don't trust stale checkpoints (`feedback-regenerate-pipeline-aggressively`).
- Underspecified rep → update spec §3, don't guess.
