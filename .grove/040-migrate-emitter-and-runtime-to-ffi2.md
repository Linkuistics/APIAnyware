# 040-migrate-emitter-and-runtime-to-ffi2

**Kind:** planning (decompose lazily once 020's findings are in)

## Goal
Plan and drive the migration of the FFI layer from `ffi/unsafe`(+`ffi/unsafe/objc`)
to **ffi2**, across both the Rust emitter (which writes FFI into generated
bindings) and the hand-written runtime. Decompose into ordered child leaves
informed by 020's research — do not pre-plan the children here.

## Context
- Two code surfaces emit/contain FFI:
  1. **Emitter crate** `generation/crates/emit-racket-oo` (→ `emit-racket`):
     `emit_class.rs`, `emit_constants.rs`, `emit_functions.rs` write
     `(require ffi/unsafe ffi/unsafe/objc)` and `(_fun … -> …)` signatures.
     `shared_signatures.rs` holds the FFI type mapper.
  2. **Runtime** `generation/targets/racket/runtime/*.rkt` — ~15 files:
     `coerce.rkt`, `type-mapping.rkt`, `objc-interop.rkt`, `block.rkt`,
     `main-thread.rkt`, `app-menu.rkt`, `nsevent-helpers.rkt`,
     `nsview-helpers.rkt`, `ax-helpers.rkt`, …
- The ffi2/ObjC boundary from 020 decides how much of `ffi/unsafe/objc` survives.

## Done when
- This leaf has been replaced by a node directory (`040-…/BRIEF.md` + child
  leaves) covering, at minimum: the FFI type mapper (`shared_signatures.rs`), the
  emitter templates, the runtime C-layer, and the runtime ObjC layer — each as
  its own work leaf, sequenced by dependency.
- Any decision that *changes* the migration approach (e.g. the retained-ffi/unsafe
  boundary) is captured in an ADR cited from the new node's brief.

## Notes
- Regenerate the pipeline after emitter changes — never trust stale generated
  `.rkt` as evidence (standing rule).
- Verification of the migrated apps is leaf 050's job; the child leaves here
  should leave the build green but defer visual VM-verify to 050.
