# add-sbcl-clos-target — brief

## Goal

Build the **`sbcl`** language target — **Steel Bank Common Lisp** with a **CLOS**
binding style — the fourth APIAnyware target after `racket`, `chez`, and
`gerbil`. Take it through the full new-target playbook
(`docs/guides/adding-a-language-target.md`): emitter crate, runtime + native
core, the 7-app sample ladder (VM-verified), bundler, and co-located docs.

Distinctive to this target: the object model is a **MOP projection of ObjC into
CLOS**, and the target is designed as the first member of a **CL family** that
shares a spec-level CLOS **interface contract** (so application source is portable
across future CL impls), while keeping each impl's binding implementation isolated
and idiomatic.

## Done when

- `emit-sbcl` crate compiles, registered in the CLI; `--target sbcl` works.
- Runtime + native core load in SBCL; the MOP object model works.
- All 7 sample apps built and **TestAnyware VM-verified** (CLI smoke never
  satisfies the bar).
- `bundle-sbcl` packages apps as self-contained `.app`s via
  `save-lisp-and-die :executable t`.
- The CL-family interface contract is authored as a spec; SBCL conforms to it.
- Per-language docs exist in the canonical ADR-0024 structure; target ADRs raised
  centrally; repo-root README Current Status updated.

## Decomposition

Foundational decisions (D1–D5) settled in `010-plan` (see its running log).
Coarse, lazy skeleton — design/build leaves decompose further when picked:

- **010-plan** — foundational grilling (this; D1–D5). *(retires after session)*
- **020-research-ccl-cocoa-bridge** — research leaf: Clozure CL's Cocoa bridge +
  objective-cl as prior art for the MOP object model *and* the CL-family contract
  (adopt CCL's `ns:`/metaclass conventions vs define our own). Load-bearing for
  030 + 040.
- **030-design** — planning: author the **CL-family interface contract** spec +
  the **new ADR** for the family interface-sharing axis; then the **SBCL MOP
  realization** (metaclass impl, static-emit-vs-runtime split, dispatch,
  lifetime, callbacks/threading, conditions). Decomposes into sub-leaves.
- **040-build-emitter** — `emit-sbcl` crate (TargetInfo/TargetEmitter,
  `SbclFfiTypeMapper`, naming, emit_class/protocol/enums/constants/functions).
- **050-build-runtime-native-core** — `sb-alien` runtime, MOP metaclass +
  hooks, block/delegate bridges, dynamic-class synthesis, lifetime, threading,
  native dylib (`libAPIAnywareSbcl`) if needed.
- **060-build-sample-apps** — the 7-app ladder, written against the contract,
  VM-verified. Decomposes per app.
- **070-distribution-bundler** — `bundle-sbcl` crate, `save-lisp-and-die`.
- **080-docs** — per-language docs (ADR-0024), contract spec placement, repo
  README.

## Pointers

- Playbook: `docs/guides/adding-a-language-target.md` (10 steps + checklist).
- North star: ADR-0010 (native library *is* the binding), ADR-0011 (hermetic
  isolation — and its CL-family exception, D5).
- Idiom: ADR-0005 (max idiom, not portable subset — why `sb-alien` not CFFI).
- Object-model precedent: gerbil ADR-0020 (manifest graph + dual dispatch) —
  sbcl goes further to a MOP projection.
- Compiled-FFI precedent: ADR-0015 (chez/gerbil vs interpreted racket).
- Distribution precedent: ADR-0009 (chez self-contained), gerbil static-exe.
- Glossary: `CONTEXT.md` → "SBCL target toolchain" (`sbcl` target, `sb-alien`,
  MOP projection / `objc-class` metaclass, CL-family interface contract).

## Notes

- Provisional/open items carried into design leaves: exact condition hierarchy
  for `NSError**`; whether a native dylib is needed (gerbil avoided one via
  ObjC-in-gsc — SBCL can't compile ObjC inline, so likely yes); foreign-thread
  callback activation model (`sb-thread`); contract-spec doc placement (main-tier
  vs per-target).
