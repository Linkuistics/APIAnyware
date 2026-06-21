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
across CL impls), while keeping each impl's binding implementation isolated and
idiomatic.

**CL family roster (D5, refined):** the contract is designed against four
confirmed members — **SBCL, CCL, AllegroCL, LispWorks** (two open-source, two
commercial) — with a usage/landscape survey (020) to confirm membership and catch
any others (ECL, ABCL, Clasp). Only **SBCL is built in this grove** (D5a posture:
portability-ready, not portability-abstracted); the other three inform what the
contract must abstract over. Risk to resolve in design: AMOP conformance and ObjC-
bridge maturity vary across the four (esp. the commercial impls' own MOPs/FFIs),
so the MOP-based contract's viability across all four — and whether a fallback is
needed — is a 020-research / 030-design question, not yet settled.

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
- **020-research-cl-cocoa-bridges** — research leaf: CL-Cocoa bridge prior art
  **across the family** (CCL deepest; LispWorks + AllegroCL where bridges exist) +
  a usage/landscape survey confirming the roster, + AMOP-conformance-per-impl.
  Prior art for the MOP object model *and* the CL-family contract (adopt CCL's
  `ns:`/metaclass conventions vs define our own). Load-bearing for 030 + 040.
- **030-design** — planning: author the **CL-family interface contract** spec +
  the **new ADR** for the family interface-sharing axis; then the **SBCL MOP
  realization** (metaclass impl, static-emit-vs-runtime split, dispatch,
  lifetime, callbacks/threading, conditions). Decomposes into sub-leaves.
- **040-build-emitter** — `emit-sbcl` crate (TargetInfo/TargetEmitter,
  `SbclFfiTypeMapper`, naming, emit_class/protocol/enums/constants/functions).
  *(retired 2026-06-20 — orchestrator + facade + goldens; direct contract surface
  complete, §6d count reproduced; layout/seam promoted to CONTEXT.md.)*
- **045-method-init-residual-wiring** — follow-up split from 040/060: wire the
  Swift-native method/init residual as Lisp forms. *(done — **class owners**: each
  bindable method a receiver-specialized `(defmethod ns:<base-labels> ((self ns:<owner>)
  …))` with its generic folded into `collect_generics` for the lockstep; each init a
  `(defun ns:make-<owner>… )` constructor — not `make-instance`, since a Swift-native
  init trampolines `Owner(labels:)` not ObjC alloc/init. **Value-struct (population-B)
  owners deferred to 090** — no CLOS class to specialize on. §6d count unchanged.)*
- **050-build-runtime-native-core** — `sb-alien` runtime, MOP metaclass +
  hooks, block/delegate bridges, dynamic-class synthesis, lifetime, threading,
  native dylib (`libAPIAnywareSbcl`). *(✅ COMPLETE + retired 2026-06-21 — all 8
  bottom-up leaves done: 010 native-dylib → 020 ffi-seam → 030 mop-object-model →
  040 subclass-and-conformance → 050 lifetime-and-conditions → 060
  threading-and-callbacks → 070 startup-re-resolution → 080 integration-smoke (the
  node done-bar). Runtime loads in SBCL; the MOP object model + lifetime + the §6d
  Swift-native residual all verified end-to-end. Per-leaf + integration smokes +
  the runner under `generation/targets/sbcl/lib/runtime/tests/`; runtime README
  documents the suite. Design was fully settled in ADRs 0034–0038 + the design
  spec; the leaves implemented, none re-decided.)*
- **060-build-sample-apps** — the 7-app ladder, written against the contract,
  VM-verified. Decomposes per app.
- **070-distribution-bundler** — `bundle-sbcl` crate, `save-lisp-and-die`.
- **080-docs** — per-language docs (ADR-0024), contract spec placement, repo
  README.
- **090-value-struct-residual-wiring** — follow-up split from 045: wire the
  **population-B (value-struct)** method/init residual. Needs an object-model decision
  (does a value struct get a CLOS class?) — ADR-worthy, hence split out. Logically
  sequences **after 050** (needs the value-box runtime) and **before 080-docs**; parked
  at 090, a planning session should `leaf-insert` it into place. Not a blocker for 060.

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

- Design phase **complete** (030-design retired 2026-06-20). The provisional/open
  items are all **resolved**: condition hierarchy for `NSError**` → flat
  `ns:objc-error` (ADR-0037); native dylib needed → **yes**, `libAPIAnywareSbcl`
  the **sole native unit** (ADR-0038 — SBCL compiles neither ObjC nor Swift inline);
  foreign-thread callback model → **main-thread bounce, not activation** (ADR-0035,
  spiked — chez's `Sactivate_thread` rejected); contract-spec placement → **main-tier**
  (`docs/specs/2026-06-20-cl-family-interface-contract.md`, ADR-0033). Full design
  recorded in ADRs **0033–0038** + the SBCL target design spec
  (`generation/targets/sbcl/docs/design/2026-06-20-sbcl-target-design.md`). Build
  leaves 040–080 refined to cite it. **040-build-emitter complete + retired
  (2026-06-20)** — `emit-sbcl` emits a complete contract-conforming tree end-to-end
  (`--target sbcl`), §6d count reproduced; the method/init residual defmethod wiring
  was split to **045**. **045 complete + retired (2026-06-20)** — the class-owner
  method/init residual is wired (receiver-specialized `defmethod` + `make-<owner>`
  constructor + defgeneric lockstep); the **value-struct (population-B)** half split to
  **090** (needs a value-struct-CLOS-class object-model decision).
- **050-build-runtime-native-core COMPLETE + retired (2026-06-21).** The 080
  integration smoke (the node done-bar) is the first thing in the grove to LOAD
  emitted bindings on the runtime, and surfaced + fixed four cross-layer gaps that
  hand-authored per-leaf smokes could not see: (1) the geometry struct typedefs
  (`ns-rect`/`ns-point`/… in `ffi.lisp`) the FFI mapper delegates to "leaf 050" —
  without them any `frame`/`bounds`/`rangeOfString:` fails to *load*; (2)
  `define-objc-constant` (emitted into every `constants.lisp`, defined nowhere);
  (3) `register-objc-init` + `register-objc-protocol` are now MACROS (the runtime
  contract emits their literal data UNQUOTED, so the functions tried to *call* it);
  (4) emitter `trampoline.rs` — a `throws` TRAMPOLINE now emits `aw-swift-call/error`,
  not the `+0`-borrow `aw-with-error-cell`, since the `ThrowsBridge` writes a `+1`
  `NSError` (golden-neutral). The §6d Swift-native residual is verified BY SHAPE
  (fn / const / class-owner method+init / value-opaque box / `throws`); two shapes
  RECORDED PENDING — **value-struct-owner** residual (the live **090** leaf) and the
  **async-method trampoline** (deferred by design in `threading.lisp` until async
  trampolines are emitted; the `CallbackBounce` family is proven). Next:
  **060-build-sample-apps** (090 sequences after 050, not a blocker for 060).
