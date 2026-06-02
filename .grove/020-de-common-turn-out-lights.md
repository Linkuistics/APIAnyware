# 020-de-common-turn-out-lights

**Kind:** work

## Goal
Make `APIAnywareChez` self-contained (ADR-0011) and delete the now-orphaned
`APIAnywareCommon`. Chez is the last *real* Common consumer (racket de-shared on
`main`), so this leaf also turns out the lights.

## Context
- Design: `docs/specs/2026-06-02-chez-native-binding-design.md` §5; running-log
  D4 in `010-design-and-spike` (now in `done/`). ADR-0011.
- Chez uses exactly **8** `aw_common_*` symbols, backed by **4** Common files:
  `ClassLookup`, `MemoryManagement`, `AutoreleasePool`, `StringConversion`
  (~82 lines). It does NOT use `MessageSend` / `StructMarshal` / `ObservationBridge`.
- Only **2** chez files reference `aw_common_*`: `generation/targets/chez/apianyware/runtime/ffi.sls`
  and `.../runtime/README.md`.

## Done when
1. **Merge `main` first** — this worktree predates racket's de-share; edit
   `swift/Package.swift` against reality (racket already has no Common dep).
2. The 4 used Common files are rehomed into `APIAnywareChez` (folded into one
   `swift/Sources/APIAnywareChez/ChezRuntime.swift`).
3. The 8 symbols are renamed `aw_common_*` → `aw_chez_*`; `ffi.sls` + the runtime
   `README.md` updated to match.
4. `APIAnywareChez` drops its `APIAnywareCommon` dependency in `Package.swift`;
   `swift build` + `APIAnywareChez` Swift tests pass.
5. **Confirm the Gerbil stub is truly inert** (no real consumer), then delete
   `swift/Sources/APIAnywareCommon/`, the Gerbil stub, and both their
   `Package.swift` targets/products.
6. Full chez pipeline regenerates clean; build green.

## Notes
- Rename rationale: honest hermetic naming — the chez dylib should export only
  `aw_chez_*` (matches the existing `aw_chez_create_block` family). (010 D4)
- If deleting Gerbil turns out to be non-trivial (real consumer found), capture a
  follow-up via `grove-llm inbox-add` rather than expanding this leaf.
