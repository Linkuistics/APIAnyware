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
- **`ffi2-lib` is already provisioned** (retired leaf 030-adopt-racket-9.2-toolchain;
  `(require ffi2)` loads). This leaf only makes that durable in the toolchain/CI
  provisioning script — do not re-run `raco pkg install` ad hoc (supply-chain-gated).
- Shape settled by **010** (DONE): design spec
  `docs/specs/2026-05-31-racket-native-binding-design.md` §5 (ffi2 role + hybrid
  boundary). This leaf is the **C-function layer + seam plumbing**; outbound ObjC
  *dispatch* relocates into generated native entries in leaf **040** (ADR-0013).
- **Spike findings to apply (010):** `ffi2-sizeof` exists (closes the 020
  `ctype-sizeof` gap); `ptr_t->cpointer`/`cpointer->ptr_t` confirmed working;
  `->` **collides** between ffi2 and ffi/unsafe — any module mixing them must use
  `(except-in ffi/unsafe ->)` (NOT `rename-in ffi2`, which breaks nested arrow
  parsing), or keep the two libraries in separate modules.
