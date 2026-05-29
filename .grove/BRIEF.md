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
decision). The likely ffi2 shape is *hybrid*: ffi2 for the C-function/ctype
layer, retain `ffi/unsafe/objc` for ObjC message dispatch — but that is leaf
020's question to settle, not a foregone conclusion.
