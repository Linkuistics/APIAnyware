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

## Child leaves (reshaped 2026-05-31 after 010 design-and-spike settled)

010's design is settled: **design spec** `docs/specs/2026-05-31-racket-native-binding-design.md`,
**ADR-0013** (generated typed native dispatch), **ADR-0014** (callbacks outbound +
native trampoline), spike `docs/research/2026-05-31-racket-ffi2-spike/`. The
dispatch-into-native leaf (040) was inserted; 040→050, 050→060 shifted.

- **010 design-and-spike** (planning) — **DONE.** Decisions: D0 spike-decide; D1
  generated typed native dispatch (per-signature, from the IR; ~3.5× faster than
  status-quo typed msgSend, 5.4× on structs; libffi merely ties it → rejected
  except as escape hatch); D2 outbound + native trampoline (ffi2 callbacks
  rejected: foreign-thread SIGILL + void-return bug).
- **020 racket-extract-from-common** (work): rehome racket's Common pieces into
  `APIAnywareRacket`, drop the dependency. **Delete `MessageSend.swift`** (dead
  code per spike), don't rehome it. Don't touch Chez/Gerbil; Common deleted by
  the last grove to de-share.
- **030 racket-ffi2-seam-and-type-mapper** (work): ffi2 base types + arrow
  procedures + `define-ffi2-definer` for the **C-function layer**;
  `ptr_t<->cpointer` bridge; ffi2 type mapper in `shared_signatures.rs`. ffi2-lib
  already provisioned (retired leaf 030); `->` collision discipline
  (`except-in ffi/unsafe ->`).
- **040 generated-native-dispatch** (work) — **NEW, the ADR-0013 core**: generate
  one typed native `objc_msgSend` entry per IR signature into `APIAnywareRacket`;
  route the emitter's class/method dispatch through them via thin ffi2 bindings.
  Retain one libffi generic dispatcher as the escape hatch.
- **050 emitter-thin-ffi2-shims** (work): cut the emitter over to thin shims along
  the marshalling-depth spectrum (spec §3); Depth-1 across the surface, Depth-2
  (batched string/array/dict, `NSError**`) for hot cases; regenerate the pipeline.
- **060 delete-racket-fallbacks** (work): make the dylib mandatory; delete the
  pure-Racket `swift-available?` fallbacks; keep the native trampoline path
  (ADR-0014); confirm the retained `ffi/unsafe/objc` boundary is the spec set.

## Notes
- Regenerate the pipeline after emitter changes — never trust stale generated
  `.rkt` (standing rule).
- 020 research doc: `docs/research/2026-05-31-racket-9.2-ffi2-migration.md`
  (ffi2 API map + ObjC boundary; still valid as the *seam* characterisation).
