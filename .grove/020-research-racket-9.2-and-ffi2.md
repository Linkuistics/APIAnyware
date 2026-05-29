# 020-research-racket-9.2-and-ffi2

**Kind:** research (output: a doc under `docs/research/`)

## Goal
Characterise Racket 9.2's **ffi2** library well enough that the migration leaf
(040) can be planned without re-discovering the API from scratch. Surface the
ffi2-vs-`ffi/unsafe` boundary — especially whether ffi2 covers Objective-C
message dispatch or whether `ffi/unsafe/objc` must be retained.

## Context
- Starting point: https://docs.racket-lang.org/ffi2/index.html — ffi2 is "a more
  static alternative to ffi/unsafe", require path `ffi2`, package `ffi2-lib`
  (`raco pkg install ffi2-lib`), part of Racket 9.2, with an
  "Interoperability with ffi/unsafe" section (so coexistence is supported).
- Our current FFI surface (the migration target): grep `ffi/unsafe` /
  `ffi/unsafe/objc` across `generation/targets/racket/runtime/` and the emitter
  crate. Key forms in use: `_fun`, `_id`, primitive ctypes (`_int` etc.),
  `define-objc-class`/`tell` (ObjC), C-callback construction, pointer ops,
  blocks (`runtime/block.rkt`), `runtime/coerce.rkt`, `runtime/type-mapping.rkt`,
  `runtime/objc-interop.rkt`.

## Done when
A `docs/research/` doc exists that answers, with citations to the ffi2 docs:
- **API surface:** what ffi2 forms replace `_fun`, ctypes (`_id`, `_int`, …),
  struct/typedef mapping, C-callback construction, pointer ops.
- **ObjC dispatch:** does ffi2 provide an `objc` layer / message-send, or is the
  intended pattern "ffi2 for C, keep `ffi/unsafe/objc` for ObjC"? State the
  recommended hybrid boundary explicitly. **This is the load-bearing question.**
- **Interop:** how ffi2 and `ffi/unsafe` values pass across the boundary (so the
  hybrid actually composes).
- **Toolchain/install:** how Racket 9.2 + `ffi2-lib` get provisioned (feeds 030).
- **Per-concern takeaways** pointing at the migration sub-areas 040 will spawn
  (emitter templates, coerce/type-mapping, objc-interop, block, callbacks).

## Notes
- Bias the search toward *migration mechanics*, not marketing. For each of our
  in-use forms, find its ffi2 equivalent or confirm none exists.
- Where a form has no ffi2 equivalent, that's a finding — record it; it likely
  defines the retained-`ffi/unsafe` boundary.
- A finding that *changes* the migration approach belongs in an ADR raised by
  040; a finding that merely confirms an approach stays in this doc with a pointer.
