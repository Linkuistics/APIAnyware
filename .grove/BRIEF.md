# update-racket-to-9.2-and-use-ffi2 — brief

## Goal
Move the `racket` target onto **Racket 9.2** and migrate its FFI from
`ffi/unsafe` (+ `ffi/unsafe/objc`) to **ffi2** — across both the Rust **emitter**
and the hand-written **runtime** — while renaming `racket-oo` → `racket`
everywhere, including the generic `Language*` → `Target*` trait/CLI reconciliation
that `CONTEXT.md` had parked as follow-up.

## Done when
- The full pipeline (collect → analyse → generate) regenerates clean on Racket
  9.2 + ffi2, and the build is green.
- No occurrence of the token `racket-oo` remains; the registered target value is
  `racket`; `Language*`/`--lang` machinery is renamed to `Target*`/`--target`.
- The runtime and emitted bindings no longer depend on `ffi/unsafe` *except*
  where the ffi2-vs-ffi/unsafe boundary (see leaf 020) deliberately retains it
  (e.g. ObjC dispatch).
- **Every sample app VM-verifies visually via TestAnyware.** CLI smoke does not
  satisfy this bar (standing project rule).

## Decomposition
Numeric order encodes the dependency chain, with one orthogonal exception:

- `010` rename — done first by explicit decision; orthogonal to 9.2/ffi2, so all
  later edits land on final paths/names.
- `020` research — ffi2 is upstream and absent from our codebase; characterising
  its API and the ObjC-dispatch boundary de-risks 030–050.
- `030` toolchain — must have 9.2 + `ffi2-lib` provisioned before any ffi2 code
  can be built or verified.
- `040` migrate — the heavy thread; left as a single planning leaf to decompose
  *lazily* once 020's findings are in (incremental discovery, not upfront plan).
- `050` regenerate + VM-verify — the done-bar.

## Pointers
- Target tree: `generation/targets/racket-oo/` (→ `racket` after 010)
- Emitter crate: `generation/crates/emit-racket-oo/` — emits FFI directly
  (`emit_class.rs`, `emit_constants.rs`, `emit_functions.rs` write
  `(require ffi/unsafe ffi/unsafe/objc)` and `(_fun … -> …)`)
- Bundler crate: `generation/crates/bundle-racket-oo/`
- Swift bridge: `swift/Sources/APIAnywareRacket/RacketFFI.swift` →
  `libAPIAnywareRacket.dylib`
- Knowledge: `knowledge/targets/racket-oo.md`, `knowledge/matrix/*/racket-oo.md`
- Glossary terms in play: Target, Binding style, **Racket 9.2**, **ffi2** (see CONTEXT.md)
- ffi2 docs: https://docs.racket-lang.org/ffi2/index.html
- Standing rules: VM-verify every sample app; regenerate the pipeline
  aggressively (don't trust stale generated `.rkt`); `SDKROOT=macosx` workaround.

## Notes
Migration is **straight to 9.2+ffi2** — no staged "9.2 on old ffi" baseline (by
decision).

**Boundary settled by 020** (`docs/research/2026-05-31-racket-9.2-ffi2-migration.md`):
the hybrid is *forced* — ffi2 has no ObjC layer, so message dispatch
(`tell`/`objc_msgSend`/`import-class`) stays on `ffi/unsafe/objc`; ffi2 covers
the C-function layer; values cross the seam via `ptr_t<->cpointer`.

**Guiding directive (2026-05-31).** Two priorities, both ranked above minimizing
changes/work (per the APIAnyware-wide policy in auto-memory):
1. *Maximum ffi2 advantage.* On the C-function side of the seam, prefer the
   richest ffi2 idiom: tagged pointer subtypes over hand-rolled `(cast _pointer
   _id)`, custom `#:racket->c`/`#:c->racket` over manual coercion, `struct_t`
   with generated accessors, `define-ffi2-definer` + arrow types, and
   allocator/deallocator (incl. `#:gcable-immobile`) for memory safety. Adopt
   ffi2 everywhere it *can* go, not only where it is least effort.
2. *Maximum performance.* Push as much work as possible into the **native** layer
   (`libAPIAnywareRacket.dylib` Swift/C helpers) and keep the Racket bridge thin
   — ffi2 is the *seam*, not where heavy lifting lives. Favour a thin, static
   ffi2 entry point over interpreted-Racket logic that fans out many per-call FFI
   crossings (e.g. batch type-mapping conversions natively). The two priorities
   compose: a fat native core behind a thin, idiomatic, static ffi2 seam.

**This grove is the first concrete application of ADR-0010** (the per-target
native library *is* the binding). So 040 is reframed: prefer moving binding
logic (memory/callbacks/lifetimes/coercions) into the `libAPIAnywareRacket`
Swift library — exposed to Racket through Racket CS's C embedding API, with ffi2
as the thin static seam — over re-implementing it in Racket. 040 has now been
re-grilled and decomposed under ADR-0010 **and ADR-0011 (hermetic isolation)**:
the node makes `APIAnywareRacket` **self-contained** (extracts racket's needs
from the shared `APIAnywareCommon` and drops the dependency). Chez de-shares in
its own grove (`chez-adopt-native-binding`); Gerbil is an inert stub;
`APIAnywareCommon` is deleted by whichever grove de-shares last. See
`040-migrate-emitter-and-runtime-to-ffi2/BRIEF.md`.
