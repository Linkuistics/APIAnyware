# 010-plan

**Kind:** planning

## Goal

Stand up the design for an **SBCL / CLOS** language target — the fourth target
after `racket`, `chez`, and `gerbil`. This first planning session grills the
foundational design decisions and **grows the tree**: it decomposes the build
into ordered child leaves (design specs, emitter crate, runtime, native core,
sample-app ladder, distribution, docs) rather than resolving every deep design
decision in one sitting.

## Context

- Fourth target. Precedent: `racket` (interpreted-FFI, finalizers, stub-launcher),
  `chez` (compiled-FFI, guardian, self-contained binary, ADR-0009),
  `gerbil` (compiled-FFI, manifest `defclass` graph + dual dispatch ADR-0020,
  ObjC-in-gsc native core ADR-0017, static-exe).
- The new-target playbook is `docs/guides/adding-a-language-target.md` (10 steps).
- North star: ADR-0010 (native library *is* the binding) + ADR-0011 (hermetic
  isolation). Idiom posture: ADR-0005 (maximally idiomatic, not portable subset).
- SBCL distinctives in play: `sb-alien` (native FFI) vs CFFI (portable);
  **CLOS** object model (multiple dispatch, MOP, method combination);
  `save-lisp-and-die :executable t` (self-contained image); the CL **condition
  system** (a different answer to `NSError**`); `sb-ext:finalize` / weak pointers
  (lifetime); `sb-thread` + foreign-thread callback activation.

## Done when

- Foundational decisions grilled and recorded in the running log below.
- `CONTEXT.md` seeded with the SBCL target's glossary entries (idiom, object
  model, dispatch, lifetime, distribution) as they resolve.
- The tree is grown: this leaf is decomposed into ordered child leaves covering
  the design + build workstreams.

## Decisions (running log)

**D1 — Target id is plain `sbcl`; CLOS is the binding style.** Following the
racket/chez/gerbil precedent and the guide's "plain language id, no
`{lang}-{paradigm}` slug" rule. The grove name `add-sbcl-clos-target` emphasizes
the headline idiom but does not reify a paradigm axis. CLOS is simply this
target's *one* binding style (the gerbil analogue: its defclass+generics object
model is gerbil's single style). No `sbcl-functional` sibling is planned; if one
is ever wanted, register it then (per the retired-Paradigm glossary guidance).
On-disk unit `generation/targets/sbcl/`, CLI `--target sbcl`, crate `emit-sbcl`,
dylib (if any) `libAPIAnywareSbcl`.

**D2 — FFI layer is `sb-alien`, not CFFI.** SBCL's compiler-integrated native
FFI (`define-alien-routine`, `with-alien`, `alien-funcall`,
`define-alien-callable`, `alien-sap`). CFFI is the portable-across-Lisps subset
ADR-0005 rejects (the chez-vs-R6RS analogue). `sb-alien` compiles to direct
native calls and lets the emitter open-code one typed alien signature per method
ABI — solving the arm64 variadic-`objc_msgSend` cast problem the same way chez's
`foreign-procedure` and gerbil's `define-c-lambda` do (a **compiled-FFI** target,
ADR-0015). Callbacks use `define-alien-callable`.

**D3 — Object model: MOP projection of ObjC into CLOS (all-in).** The headline.
ObjC's class system is projected into CLOS via the **Metaobject Protocol**: an
`objc-class` metaclass (subclass of `standard-class`); each ObjC class is a CLOS
class of that metaclass carrying the ObjC `Class` pointer; ObjC methods are
`defgeneric`/`defmethod` (native CLOS multiple dispatch + method combination);
instance slots / ivars route through MOP hooks (`slot-value-using-class`,
`allocate-instance`); `make-instance` trampolines to `alloc`/`init`; subclassing
`(defclass my-view (ns:ns-view) … (:metaclass objc-class))` synthesizes a real
ObjC subclass via `objc_allocateClassPair`. Supersedes considering the
single-wrapper-class shape (gerbil pre-rejected it as "vacuous", ADR-0018→0020)
and the manifest-`defclass`-without-MOP baseline.

**Key reconciliation (for the object-model leaf):** APIAnyware emits *statically*
from the shared IR (ADR-0010 fat-native-core/thin-static-seam), whereas Clozure
CL's bridge synthesizes CLOS classes *dynamically* from the live ObjC runtime at
load. Resolution to validate: the **emitter statically generates the CLOS class
graph** (`defclass … :metaclass objc-class` + per-selector generics); the **MOP
machinery lives in the runtime** (the metaclass, slot/dispatch/allocation hooks,
`objc_allocateClassPair` subclass synthesis). The MOP is the mechanism; the class
graph stays statically emitted.

**D3a — CCL/objective-cl research is now load-bearing input, not a gate.** Going
all-in on MOP makes Clozure CL's ~20-year Cocoa bridge (foreign classes as CLOS
classes via the MOP) the definitive evidence base for *how* to build the
projection. Insert a **research leaf** ahead of the object-model planning leaf:
how CCL maps ObjC→CLOS via the MOP, what its `ns:ns-object` root / metaclass /
`define-objc-method` machinery does, the static-emit-vs-dynamic-synthesis
trade-off, and the pitfalls it hit (per driving.md: demand primary-source
citations + a walk-away check).

**D4 — Distribution: self-contained `save-lisp-and-die :executable t`.** Dump the
live SBCL image (runtime + heap + loaded bindings + app) into one standalone
executable, wrapped in a `.app` by a `bundle-sbcl` crate (reusing the shared
`stub-launcher` `.app` skeleton + codesigning). No SBCL needed on the target
machine. The SBCL realization of chez's ADR-0009 / gerbil's static-exe
self-contained posture. Note: distribution is inherently **per-impl** (CCL/ECL
dump images their own way), consistent with the "different under the hood"
family framing in D5.

**D5 — A shared CL-family CLOS interface contract (spec-level, not code-level).**
User steer: CL implementations should expose a **common CLOS-based interface**
even though each uses a different FFI under the hood, so application source is
portable across CL impls. Confirmed **spec-level sharing**, not shared binding
code. Three layers:
- **Interface contract** (shared, documented): the `ns:` package, class names,
  generic-function names, the `objc-class` metaclass / MOP protocol, the
  **condition hierarchy** (CL idiom for `NSError**` → signalled conditions, *part
  of the contract*). CLOS + AMOP are themselves standardized, so a portable MOP
  surface is feasible.
- **Application source** (portable): sample/user apps program against the
  contract, run unchanged on any CL target.
- **Binding implementation** (per-impl, idiomatic): emitter FFI output
  (SBCL: `sb-alien`, D2), callback/block bridges, threading, distribution
  (`save-lisp-and-die`, D4). D2 / ADR-0005 / ADR-0011-substrate-isolation all
  intact.

ADR-0011 isolation was justified for *paradigmatically-alien* targets; two CL
impls are the **same language**, so a shared *interface* (not substrate) falls in
a gap ADR-0011 never considered. → **New ADR** establishing the CL-family
interface-contract axis (does not overturn ADR-0011; scopes an exception to it).

**D5a — Scope: portability-ready, not portability-abstracted.** Only SBCL is
built in this grove. The contract is **authored as a spec deliverable** now (it
disciplines the SBCL design and is cheap), and SBCL is built to conform — but **no
second CL impl is built** (YAGNI / lazy, constraint 4). Strongest version per
research: **align the contract with Clozure CL's existing Cocoa-bridge API**
(`ns:` package, metaclass conventions) so there is de-facto portability with the
large existing CL-Cocoa codebase — the 020 research leaf decides adopt-CCL's-
conventions vs define-our-own. Open: contract spec is *cross-target* within the CL
family, so its doc placement is likely **main-tier** (`docs/specs/`-ish), not the
per-target unit (ADR-0024) — resolve in the contract leaf.

## Notes
