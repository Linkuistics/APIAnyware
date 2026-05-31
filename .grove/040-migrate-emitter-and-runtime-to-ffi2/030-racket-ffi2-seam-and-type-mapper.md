# 030-racket-ffi2-seam-and-type-mapper

**Kind:** work

## Goal
Build the thin, static **ffi2 seam** on the Racket side: ffi2 base types
(`int_t`/`double_t`/`ptr_t`/…), arrow-type procedures, `define-ffi2-definer`,
and the `ptr_t<->cpointer` bridge to the retained `ffi/unsafe/objc` layer. Add
the **ffi2 type mapper** to `shared_signatures.rs` (parallel to the current
`ffi/unsafe` mapper), covering the base-type table and the arm64 aliases
(`NSUInteger`→`uint64_t`, etc.) from the 020 research doc §3.3.

## Done when
- A working ffi2 seam exists in the runtime; `ptr_t<->cpointer` round-trips
  across the ObjC boundary.
- `shared_signatures.rs` can emit ffi2 type spellings; unit tests cover the map.
- Build green. (Visual VM-verify deferred to root leaf 050.)

## Notes
- Requires `ffi2-lib` provisioned — that's **root leaf 030**'s job, done first.
- Shape gated on **010** (what stays Racket vs. moves native).
