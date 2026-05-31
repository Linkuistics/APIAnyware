# 040-migrate-emitter-and-runtime-to-ffi2 — brief

**Kind:** node (decomposed 2026-05-31 after re-grilling 020's findings under ADR-0010/0011)

> **Scope expanded beyond the node name.** Re-grilling (2026-05-31) settled three
> decisions that grow this node from "swap the FFI primitives" into "make the
> racket target's native library *the* binding, hermetically isolated." The
> prefix/name are kept for stability; the real scope is below.

## Decisions driving this node

1. **Pursue ADR-0010 fully.** The per-target native Swift library *is* the
   binding. ffi2 is the **thin, static seam** by which Racket calls into a fat
   `APIAnywareRacket` native lib (via Racket CS's C embedding facilities) — not
   the home of the binding logic. Move dispatch / marshalling / lifetimes into
   native; delete the pure-Racket fallbacks Swift covers; make the dylib
   mandatory.
2. **Hermetic isolation (ADR-0011).** Targets share *nothing* downstream of the
   API analysis. No common native substrate.
3. **Racket de-shares from `APIAnywareCommon` (ADR-0011).** Extract the Common
   code racket uses into `APIAnywareRacket` and drop the dependency — racket's
   lib becomes self-contained. Do **not** touch Chez/Gerbil: Chez de-shares in
   its own grove (`chez-adopt-native-binding`); Gerbil is an inert 3-line stub.
   `APIAnywareCommon` itself (+ the Gerbil stub + its `Package.swift` target) is
   physically deleted by whichever grove de-shares **last** — it will observe no
   remaining real consumer. (Revised 2026-05-31: the earlier "dissolve all three
   here" scope moved to per-target groves, per the hermetic-isolation philosophy.)

## The two code surfaces (unchanged from the original leaf)

1. **Emitter** `generation/crates/emit-racket/`: `emit_class.rs`,
   `emit_constants.rs`, `emit_functions.rs` write `(require ffi/unsafe …)` and
   `(_fun … -> …)`; `shared_signatures.rs` holds the FFI type mapper. Under
   ADR-0010 the emitter trends toward **thin idiomatic ffi2 shims that call into
   the native lib**, not open-coded FFI.
2. **Runtime** `generation/targets/racket/runtime/*.rkt` (~18 files). Per 020,
   ffi2 has **no ObjC layer** — message dispatch (`tell`/`objc_msgSend`/
   `import-class`) has no ffi2 equivalent. Under ADR-0010 dispatch is a prime
   candidate to relocate into the native lib rather than stay in Racket; the
   retained-`ffi/unsafe/objc` boundary (020) applies to whatever genuinely stays
   Racket-side. Values cross the ffi2↔ffi/unsafe seam via `ptr_t<->cpointer`.

## Done when
- This node's child leaves are complete; the full pipeline regenerates clean on
  Racket 9.2 + ffi2; the racket build + `APIAnywareRacket` Swift tests are green.
  (Chez/Gerbil must still **build** — racket's de-share drops only racket's own
  dependency edge and does not modify their code.)
- `APIAnywareRacket` is self-contained (no `APIAnywareCommon` dependency).
  `APIAnywareCommon` is deleted by the last grove to de-share (see decision #3),
  not necessarily here.
- Genuinely hard-to-reverse mechanism choices (dispatch relocation, the
  embedding direction) are captured in ADR(s) raised by the 010 design leaf.
- Visual VM-verify of the racket sample apps is **050's** job (root leaf); these
  child leaves leave the build green but defer VM-verify. (Chez/Gerbil are not
  touched by this grove — Chez adopts the architecture in its own grove.)

## Child leaves (seeded backbone — 010 reshapes/inserts as the spike resolves)
- **010 design-and-spike** (planning): the load-bearing design. Resolve, with a
  code spike: (a) per-concern disposition for each runtime file — *stays Racket*
  / *moves into the racket native lib* / *already-in-Swift → delete Racket
  fallback*; (b) the **dispatch-relocation mechanism** (how a Racket class-method
  wrapper invokes a generic native dispatcher — NSInvocation/libffi/typed
  entry points — across the ffi2 seam); (c) the **embedding direction** — Racket
  calls Swift *outbound* via ffi2 C-ABI, vs Swift embeds the *Racket CS C-API*
  inbound (esp. for callbacks/delegates; revisit 020's `_cprocedure` SIGILL /
  atomic-mode thread-safety finding). Write a design spec under `docs/specs/`;
  raise ADR(s) for the hard-to-reverse choices; then **grow/insert** the
  execution leaves below (esp. the dispatch-into-native leaf).
- **020 racket-extract-from-common** (work): extract racket's needs from Common
  into `APIAnywareRacket` per 010's shape; drop the dependency so the racket lib
  is self-contained. Do **not** touch Chez/Gerbil. Common deletion is deferred to
  the last grove to de-share (decision #3).
- **030 racket-ffi2-seam-and-type-mapper** (work): ffi2 base types + arrow
  procedures + `define-ffi2-definer`; `ptr_t<->cpointer` bridge; the ffi2 type
  mapper in `shared_signatures.rs`. Provision (`raco pkg install ffi2-lib`) is
  030's *root-leaf* job — done before this runs.
- **040 emitter-thin-ffi2-shims** (work): emitter emits thin idiomatic ffi2
  shims into the native lib; regenerate the full pipeline (don't trust stale
  `.rkt`).
- **050 delete-racket-fallbacks** (work): make the dylib mandatory; delete the
  pure-Racket fallbacks the native lib now covers; confirm the retained
  `ffi/unsafe/objc` boundary is exactly the 020/010 set and no more.

## Notes
- Regenerate the pipeline after emitter changes — never trust stale generated
  `.rkt` (standing rule).
- 020 research doc: `docs/research/2026-05-31-racket-9.2-ffi2-migration.md`
  (ffi2 API map + ObjC boundary; still valid as the *seam* characterisation).
