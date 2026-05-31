# chez-adopt-native-binding — brief

## Goal
Move the **chez** target onto the architecture now adopted project-wide:
- **ADR-0010** — the per-target native (Swift) library *is* the binding. Push
  chez's binding logic (memory, callbacks/blocks, delegates, lifetimes, dispatch,
  marshalling) into `APIAnywareChez`, using Chez Scheme's own FFI/C facilities
  (`foreign-procedure`, ftype, guardians) as the thin static seam. The chez
  runtime becomes thin; in the limit the binding is almost entirely native.
- **ADR-0011** — hermetic isolation. Make `APIAnywareChez` **self-contained**:
  absorb the `APIAnywareCommon` code chez uses and drop the dependency. Share
  nothing with other targets downstream of the API analysis.

## Done when
- `APIAnywareChez` is self-contained (no `APIAnywareCommon` dependency); builds
  and its Swift tests pass.
- chez's binding logic lives in `APIAnywareChez` per the ADR-0010 design; the
  chez runtime is a thin seam.
- The full pipeline regenerates clean for chez; the build is green.
- **Every chez sample app VM-verifies visually via TestAnyware** (standing
  project rule — CLI smoke does not satisfy this bar).
- **Common deletion (coordinated with the racket grove):** if chez de-shares
  *after* racket (so no real consumer remains — only the inert Gerbil stub), this
  grove deletes `APIAnywareCommon` + the Gerbil stub + its `swift/Package.swift`
  target. If racket finishes last, racket does it. Whichever observes "no real
  consumer left" turns out the lights.

## Decomposition
Seeded with a single planning leaf (`010`) that grills the chez-specific design
and grows the execution leaves lazily — mirroring the racket grove's
`040/010-design-and-spike`. Do not pre-plan children here.

## Pointers
- Target tree: `generation/targets/chez/`; emitter `generation/crates/emit-chez/`;
  bundler `generation/crates/bundle-chez/`; knowledge `knowledge/targets/chez.md`.
- Native lib: `swift/Sources/APIAnywareChez/` (BlockBridge, DelegateBridge,
  GCPrevention, ChezFFI) + the shared `APIAnywareCommon/` to be absorbed.
- Architecture: **ADR-0010** (`docs/adr/0010-native-library-is-the-binding.md`),
  **ADR-0011** (`docs/adr/0011-targets-hermetically-isolated.md`); idiom posture
  **ADR-0005**; chez lifetime model **ADR-0007**. Glossary: `CONTEXT.md`.
- **Sibling grove** `update-racket-to-9.2-and-use-ffi2` does the same for racket;
  its `040/010-design-and-spike` design spec (dispatch mechanism, embedding
  direction) is worth reading once it lands — chez can reuse the *reasoning*
  (not the code; targets are isolated).

## Notes
- This is the chez analogue of the racket grove's 040 node — but chez has **no
  ffi2/9.2 toolchain bump** (that's racket-specific). Chez uses `foreign-procedure`.
- Standing rules: VM-verify every sample app; regenerate the pipeline
  aggressively; `SDKROOT=macosx` workaround.
