# 040-emitter-thin-ffi2-shims

**Kind:** work

## Goal
Rework the emitter (`emit_functions.rs`, `emit_constants.rs`, `emit_class.rs`)
so generated bindings are **thin idiomatic ffi2 shims that call into the racket
native lib** (ADR-0010) rather than open-coded `ffi/unsafe` + `tell`. C-function
bindings use `define-ffi2-definer` + arrow types; class/method dispatch routes
through the native dispatcher chosen in 010. Then **regenerate the full
pipeline** and never trust stale `.rkt`.

## Done when
- Generated `.rkt` uses the ffi2 seam + native dispatch per the 010 design.
- Emitter unit/golden tests updated; full pipeline regenerates clean.
- Build green. (VM-verify deferred to root leaf 050.)

## Notes
- Depends on 010 (dispatch mechanism), 020 (native lib shape), 030 (seam + mapper).
- Regenerate aggressively (standing rule).
