# 020-runtime-scaffold

**Kind:** work

## Goal
Lay down the five-cluster chez runtime as empty-ish library skeletons that
load cleanly under Chez ≥10 with `(import (apianyware runtime cocoa))`
(transitively pulling in `ffi`, `objc`, `dispatch`, `types`). No FFI calls,
no real bodies — just `(library …)` shells, the public `export` lists,
and stub `define`s so dependents can compile.

## Context
- Design spec §2 (runtime decomposition) gives the cluster names and the
  files each absorbs.
- Reference shape: any racket runtime file (`generation/targets/racket/runtime/*.rkt`)
  for the procedures each cluster must eventually contain.
- Chez ≥10 docs: library form, `(import (chezscheme))`, ftype basics.

## Done when
- `generation/targets/chez/runtime/{ffi,objc,dispatch,types,cocoa}.sls` exist.
- `chez --script` of a tiny demo that does
  `(import (apianyware runtime cocoa))` loads without error.
- Library import graph matches the spec: `ffi` → `objc` →
  `dispatch | types | cocoa` (and `cocoa` may import from `dispatch`).
- A README at `generation/targets/chez/runtime/README.md` enumerates the
  clusters and points at the racket runtime files each absorbs (so a
  reader navigating from racket can find the analog).

## Notes
- Stub-procedure bodies that should-but-can't-yet do real FFI work
  may `(error 'name "not yet implemented")` — they will be filled in by
  030 / 040 / 050.
- This leaf does **not** touch the Swift dylib. Dylib mandate is recorded
  in the spec; actually loading it lands in 030.
