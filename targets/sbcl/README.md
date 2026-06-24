# Target: sbcl

Steel Bank Common Lisp bindings for macOS system APIs — a **MOP projection of
ObjC into CLOS** (`objc-class` metaclass over `sb-mop`), `sb-alien` FFI reaching
`objc_msgSend` directly, errors signalled as CL conditions, and self-contained
`.app` distribution via `save-lisp-and-die :executable t`. The fourth APIAnyware
target after racket, chez, and gerbil, and the **first member of the CL family**
that shares a spec-level CLOS interface contract.

## For developers and maintainers

- [`docs/reference.md`](docs/reference.md) — target-wide, written-after-the-fact
  learnings; covers only what is *sbcl-specific* and was surprising in practice
  (FP-trap masking, the `sb-alien` seam, the MOP dispatch model, the
  finalize+release-queue lifetime, dump-based distribution). The single read for
  someone maintaining this target.
- [`docs/design/`](docs/design) — the per-target design spec
  (`2026-06-20-sbcl-target-design.md`): the buildable design synthesizing the
  030-design leaves, pointing at the central ADRs.
- [`docs/research/`](docs/research) — the MOP spike and the threading spike
  (first-hand evidence on SBCL 2.6.5 / arm64), the load-bearing inputs to
  ADR-0034 and ADR-0035.
- [`lib/runtime/README.md`](lib/runtime/README.md) — the runtime module map, the
  dev load order, and the smoke suite. Read it before touching the runtime.

For cross-cutting context shared by all targets, read the main `docs/` tier
(pipeline, app-portfolio specs, emitter-contract, ADRs 0010/0011/0025). Two
documents are **CL-family-wide** and live main-tier (not here), because they
cross target boundaries:

- `docs/specs/2026-06-20-cl-family-interface-contract.md` (ADR-0033) — the
  portable `ns:`/CLOS contract every CL target conforms to; this target is its
  SBCL realization.
- `docs/research/cl-cocoa-bridges-across-the-family.md` — the 020 prior-art +
  landscape survey across SBCL/CCL/AllegroCL/LispWorks.

All target ADRs are central in `docs/adr/` (the decision graph crosses targets):
**0033** (family contract), **0034** (object model + dispatch), **0035**
(callbacks / main-thread bounce), **0036** (lifetime), **0037** (conditions),
**0038** (`libAPIAnywareSbcl`, the sole native unit), **0039** (selector-structure
naming), **0040** (typed init appliers + FP-trap masking), **0041** (bundle
relocation), **0042** (value-struct CLOS projection).

## Target structure

- `lib/` — the SBCL runtime (`lib/runtime/`, the **upper layer** — `sb-alien`
  seam, `objc-class` metaclass + MOP hooks, lifetime/threading/conditions,
  startup re-resolution) and the symlink to the Swift dylib
- `generated/` — emitted CLOS bindings, written by `generate --target sbcl`
  (gitignored — the enriched IR is not committed)
- `apps/` — sample app implementations; each `apps/<app>/` carries a
  `learnings.md` (per-target-per-app realization notes)
- `docs/` — co-located target documentation (see above)
- `test-results/` — TestAnyware VM-verify evidence (screenshots, reports)

The **lower layer** — the `libAPIAnywareSbcl` Swift dylib (the Swift-native
trampoline residual + the main-thread callback bounce + subclass-IMP synthesis,
ADR-0038) — is the target's sole native compilation unit and lives with the other
targets' bridges under the repo-root `swift/Sources/APIAnywareSbcl/`.
