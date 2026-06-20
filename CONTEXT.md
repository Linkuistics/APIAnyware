# APIAnyware macOS bindings

This repo generates language-native bindings to the macOS system frameworks
(collect → analyse → generate pipeline) and ships sample apps that exercise
those bindings on real macOS.

## Fundamental design goal

For each target language, APIAnyware ships a **native (Swift) library
purpose-built and optimised for that one target to bind to** — mapping the macOS
API model idiomatically into the target language and owning the hard runtime
concerns (memory management, callbacks, closures, lifetimes, threading), using
wherever possible the FFI/embedding C-API the *target language itself* provides.
In the limit the binding is provided **almost entirely in the native library**,
with the generated/scripting-side surface kept thin and static — a fat native
core behind a thin crossing. LLM-assisted coding is what makes a bespoke,
fully-optimised native library per target affordable. This is the project's
north star; everything else (emitter, runtime, bundler) serves it.

**Targets are hermetically isolated.** Each target's generator, runtime, and
native library share *nothing* with other targets — there is no shared native
substrate. The only cross-target commonality is the **API analysis**
(`collect → analyse`, the macOS API model / IR); everything downstream of
analysis is per-target. (Future targets — Prolog, Haskell, Idris2, TypeScript —
are paradigmatically alien; a shared substrate would be the wrong abstraction.)
See **ADR-0010** and **ADR-0011**.

## Complete-API binding model

**Complete-API binding model**:
The pure form of the design goal (ADR-0025, refining ADR-0010): each target's
binding is *abstractly* a **complete C-ABI re-export of the entire macOS API** —
every Objective-C **and** Swift declaration — surfaced to the target language. A
per-target native (Swift) library vends the whole API behind a flat C ABI, with a
thin target-language surface over it. The library *is* the API.
_Avoid_: "ObjC-only binding" (the current targets are not ObjC-only by design —
they are the fully-elided limit of this model; see **Trampoline elision**);
"Swift bridge" (too narrow — the model covers the whole API, not just the Swift
delta).

**Trampoline**:
A C-ABI entry in a target's native (Swift) library that **re-exports a macOS API
the target cannot reach directly**, making it `dlsym`-able. The paradigm case is a
**Swift-native API** (USR `s:` — only reachable via the Swift ABI): the library
calls it across the Swift ABI and re-exports it as a C-linkable entry. Also covers
pointer-valued constants (a runtime address can't be a target-language literal).
_Avoid_: "shim" (overloaded); "wrapper" (a trampoline is specifically the
C-ABI-re-export-of-an-otherwise-unreachable-API kind of wrapper).

**Receiver-handle method trampoline**:
A **trampoline for a Swift-native *method*** (`objc_exposed == false` on a
class/struct/protocol) — the method generalisation of the free-function trampoline
(ADR-0027). The `@_cdecl` takes an **opaque receiver handle** as its first parameter,
unboxes it to the concrete receiver type, and calls `receiver.method(labels:)` by
name. The receiver splits by the **exposure of its type**: *population A* — receiver
type is `objc_exposed` (a live `id` the target already holds, e.g. `URLSession` for
its Swift-native `async` `data(from:)`), no producer needed; *population B* —
receiver type is Swift-native (`s:`), obtainable only via a handle some other
trampoline produced. Both are in scope (grove `add-swift-native-method-coverage`,
D1). The receiver rides the **same unified handle rep** as boxed returns
(`AwValueBox`/`Unmanaged`), bidirectionally. A `mutating` method on a value receiver
**writes the mutated value back** into the (mutable) box (D3). An `async` method
relies on Swift `await` to hop onto the method's actor — no isolation machinery (D5).
_Avoid_: "method shim"; conflating the receiver handle with a **direct** ObjC
object cpointer (population A *is* such a cpointer, but population B is a Swift
**Opaque handle**); treating the receiver as a distinct "token" type (it is the
unified handle rep).

**Async callback form** _(R4; `aw-async-call`)_:
The racket surface for an `async` Swift-native method (ADR-0030 addendum). The
generated binding takes a **`complete` continuation and returns immediately**
(non-blocking); the `@_cdecl` drives `awRacketAsyncDispatch`, which marshals the
result on the cooperative pool and invokes a C callback **on the main thread** (the
SIGILL-safe hop), running `(complete result err)`. There is deliberately **no
blocking await** — a synchronous block would freeze the very Cocoa run loop the
completion needs to drain (and the Racket CS green scheduler is frozen under
`nsapplication-run`). A richer mailbox/await layer may sit on top later.
_Avoid_: "blocking await" / "`aw-async-await`" (a rejected candidate, spec §5b);
"future"/"promise" (the surface is a callback, not a value handle).

**Object-ref param** _(R1; `objc_object_param_bridge`)_:
A method parameter the lossy Swift→ObjC normalization reports as a Foundation objc
twin (`URL` → `NSURL`); the trampoline reconstructs the reference and **bridges to
the value the by-name call wants** (`… as URL`). Only a **curated, typecheck-proven**
set bridges — an objc twin can also hide an `inout` param (invisible in the IR), and
a bridging *constructor* (`Data(referencing:)`) wants the reference, so init object
params stay deferred.
_Avoid_: bridging by guesswork (the set is proven against the real-framework
typecheck, not assumed).

**Handle producer / initializer trampoline**:
The mechanism that *produces* a first **Opaque handle** for a Swift-native (`s:`)
receiver so population-B methods are usable. The **sole root producer is the
initializer**: an `init` trampoline `@_cdecl` calls `Type(labels:)` and returns a
boxed handle (`awRacketBox` value / `Unmanaged.passRetained` class). Everything else
**chains** off it — a method/property/factory returning a Swift-native type boxes its
return via the existing return-marshalling taxonomy (spec §3); no separate factory
design (D2). Soundness gate = the §5c oracle: the produced/unboxed type must be
nameable & in-module ("name ∈ owning framework's struct/class set").
_Avoid_: designing standalone factory/`static`-property producers (they fall out of
return-boxing); a constructor rep distinct from the unified handle rep.

**Trampoline elision** _(the direct-binding optimisation)_:
Binding a macOS API **directly** from the target, skipping the trampoline, wherever
the target can reach it without one: ObjC methods via `objc_msgSend`; constants as
native target-language literals (**except** pointer-valued constants). The current
targets (racket, chez, gerbil) are the **fully-elided limit** — all-ObjC, all
directly reachable, trampoline library ~empty — which is why they look "ObjC-only"
though they are really the optimised case of the complete-API model. The residual
that genuinely needs a trampoline is the **Swift-native delta** plus pointer
constants.
_Avoid_: framing elision as a deviation from ADR-0010 (it is the optimisation
*of* it); "skip Swift" (elision is about what's reachable *directly*, not about
dropping Swift).

**`objc_exposed` (ObjC-exposure fact)**:
The single derived IR fact (ADR-0026) that makes the **direct-vs-trampoline
boundary** explicit — a `bool` on every declaration node with a USR (`Class`,
`Method`, `Property`, `Protocol`, `Enum`, `Struct`, `Function`, `Constant`)
recording *is this reachable through the ObjC/C runtime without crossing the
Swift ABI?* Derived once in collection by one shared USR-prefix classifier: `s:`
USR → `false` (Swift-native, trampoline/skip); clang `c:`/`So` cursor (incl.
`@objc` Swift decls) → `true` (bind directly). It is a **fact, not a
classification** — each emitter derives Direct|Trampoline|Skip from it locally
(ADR-0025/D1), combined with pointer-ness (derived from `constant_type`, not
carried). Defaults `true` (the fully-elided ObjC limit) and is omitted from JSON
when true, so the golden diff audits exactly the trampoline residual.
_Avoid_: a shared `reachability: Direct|Trampoline` field (D1 forbids it —
reachability is per-target in the limit); reusing `DeclarationSource`
(`ObjcHeader|SwiftInterface`) as the boundary (an `@objc` Swift class is
`SwiftInterface` yet `objc_exposed`); re-parsing the raw USR prefix in emitters
(the classifier lives once, in collection).

**Opaque handle**:
The trampoline rep (ADR-0027) for a Swift value/reference that has no flat C-ABI
form and is not Foundation-bridgeable — a non-bridged Swift `struct`, a payload
`enum`, a class instance, an existential, an opaque `some P` return. The
trampoline heap-boxes (value) or `Unmanaged`-retains (reference) it and returns
an opaque pointer; generated `_field` / `_tag` accessor + `_free` trampolines
read and release it. Distinct from a **direct** ObjC object cpointer (that one is
a live `id` the runtime knows); a handle is a Swift thing reachable only through
its accessors.
_Avoid_: "box" alone (overloaded with NSNumber boxing); "wrapper".

**Unbindable residual**:
Swift-native declarations that cannot be trampolined *at all* — chiefly **generic
free functions** (no concrete symbol exists without monomorphization; `@_cdecl`
cannot be generic). Under the "defer nothing" directive these are **recorded with
a reason and their count surfaced** by the trampoline pass, never silently
dropped; revisited only when a real API needs one. The honest floor of "complete
marshalling to the limit of the C ABI".
_Avoid_: conflating with **trampoline elision** (that is *directly reachable*, not
unbindable) or with `deferred_abi_kind` (Macro/TypeAlias/AssociatedType — a
deferred *frontier*, not a hard limit).

## Language

**Target**:
A complete pipeline output for one language — its emitter crate, bundler
crate, runtime support, sample apps, and knowledge files. Examples:
`racket` (current), `chez` (planned). The on-disk unit is
`generation/targets/<name>/`.
_Avoid_: language (ambiguous — source-language? target-language?),
platform (means macOS, not the destination of generation).

**Binding style**:
The shape in which a target exposes its generated APIs (e.g. class-and-method
vs. plain-function). After paradigm-retirement, exactly **one** binding style
per target — implicit in the target, never reified as data or selected at
the CLI.
_Avoid_: paradigm, style (alone), flavour.

**Target idiom**:
The *style* of source a target's emitter writes. Each target commits to
**maximum idiom compliance for its specific implementation** — not to a
portable subset shared across implementations of the same language family.
For chez this means `(import (chezscheme))`, `foreign-procedure`, guardians,
and any Chez extension that makes the generated code read like code a Chez
programmer would actually write; it explicitly does **not** mean "portable
R6RS that any Scheme can load". Cross-target symmetry lives at the on-disk
layout level (per-class files, `main` re-export, runtime/ + generated/
layout) and at the IR-decision level (what gets emitted), not at the
source-form level (how it's spelled).
_Avoid_: portable, dialect-neutral.

**`objc-object`**:
The single Scheme record type wrapping an ObjC `id` pointer. Used uniformly by
**both** targets (`racket` and `chez`) — no per-class record subtype exists;
generated class files are namespaces of procedures keyed by class, not record
hierarchies that mirror the ObjC class graph. For chez specifically, the
record's lifetime is managed by a Chez guardian rather than per-instance
finalizers — see `docs/adr/0007-chez-lifetime-model.md`.
_Avoid_: `objc-handle`, `objc-ref`, `nsobject` (the last clashes with the
class).

**Entry-point autoreleasepool**:
The convention that every **outer entry into Scheme-driven ObjC code** — the
app `main`, every event handler dispatched from `NSRunLoop`, every callback
invoked from the ObjC side (delegate methods, blocks, `foreign-callable`
trampolines) — wraps its body in an `@autoreleasepool`. Transient
autoreleased objects produced during the entry's lifetime drain at the pool
boundary and never reach the guardian. Specific to the chez lifetime model;
the racket runtime relies on per-thread autorelease pools instead. See
`docs/adr/0007-chez-lifetime-model.md`.
_Avoid_: "main pool" (ambiguous with NSRunLoop's autorelease pool).

**Foreign-thread activation**:
The chez mechanism for callbacks that fire on a background OS thread. Every
runtime callback is a `__collect_safe` `foreign-callable`, so Chez's generated
C prologue registers ("activates") the calling thread before entering Scheme
and destroys a freshly-created thread context on exit. Unlike racket, chez does
**not bounce to the main thread for safety** — only for AppKit UI mutation. The
dual obligation: a *blocking* outbound `foreign-procedure` on a Scheme thread
must also be `__collect_safe`, or it parks the thread off any GC safe point and
deadlocks a background callback's stop-the-world collection. See
`docs/adr/0016-chez-outbound-callbacks-with-thread-activation.md`.
_Avoid_: "main-thread bounce" as the chez safety mechanism (that is racket's
model — ADR-0014; chez bounces only for UI).

**Paradigm** _(retired)_:
Formerly a dimension reified by the `BindingStyle` enum
(`ObjectOriented | Functional | Procedural`), allowing one target to emit
multiple binding styles from the same enriched IR. Retired: only
`ObjectOriented` was ever produced; the other variants were speculative
scaffolding. **If a future target genuinely needs two flavours, register
two targets** (e.g. `chez-class`, `chez-functional`) rather than
reintroducing this dimension.
_Avoid_: do not reuse this word in the new design.

## Racket target toolchain

**Racket 9.2**:
The upstream Racket release the `racket` target is built and run against.
Introduces **ffi2**. Replaces the previously-unpinned, pre-9 toolchain.
_Avoid_: "latest Racket" (the target is pinned, not floating).

**ffi2**:
Racket 9.2's "more static alternative to `ffi/unsafe`" for binding C APIs
(require path `ffi2`, package `ffi2-lib`). The `racket` target's FFI layer —
both the Rust emitter's generated output and the hand-written runtime — targets
ffi2, with `ffi/unsafe`/`ffi/unsafe/objc` retained only where ffi2 has no
equivalent. **Boundary (resolved 2026-05-31, leaf 020):** ffi2 has *no* ObjC
layer, so all message dispatch (`tell`/`import-class`/`objc_msgSend`) stays on
`ffi/unsafe/objc`; ffi2 covers the C-function layer only; values cross the seam
via `ptr_t->cpointer` / `cpointer->ptr_t`. The seam plumbing — ffi2 re-export
under the `(except-in ffi/unsafe ->)` discipline, arm64 width aliases, and the
bridge (incl. `_id`-tagging via `ffi2-ptr->id`/`id->ffi2-ptr`) — lives in
`runtime/ffi2-seam.rkt` (leaf 030); its ffi2 type-mapper counterpart is
`RacketFfi2TypeMapper`. ffi2 is **not** in the minimal
distribution — provision with `raco pkg install ffi2-lib`. Full map:
`docs/research/2026-05-31-racket-9.2-ffi2-migration.md`.
_Avoid_: "the new FFI" (name it ffi2); conflating it with the retired
class-system work.

## Gerbil target toolchain

**Gerbil 0.18.x**:
The upstream Gerbil Scheme release the `gerbil` target is built and run against.
Since the v0.18 cycle Gerbil vendors **Gambit as a git submodule** — there is no
external Gambit dependency; the Gerbil distribution *is* the Gambit it compiles
through. Gerbil compiles Scheme → Gambit → C → a native executable (a
**compiled-FFI target**, like chez and unlike interpreted-FFI racket — the
distinction ADR-0015 turns on).
_Avoid_: "Gerbil/Gambit" as two pinned things (one pin since v0.18); "latest
Gerbil" (the target is pinned).

**`:std/foreign`**:
Gerbil's FFI library and the `gerbil` target's FFI layer — `begin-ffi` (emits the
extern + namespace declarations), `define-c-lambda` (Scheme wrapper for a C
function), and `c-declare` for inline C. The idiomatic Gerbil way to reach
`objc_msgSend` / libobjc; the analogue of chez's `foreign-procedure` and racket's
ffi2 + `ffi/unsafe/objc`.
_Avoid_: "the FFI" (name it `:std/foreign`); conflating raw Gambit `c-lambda`
with the `:std/foreign` conveniences layered over it.

**`static-exe` (Gerbil standalone)**:
Gerbil's self-contained-binary build — `gxc -static -exe` or the `static-exe:` /
`optimized-static-exe:` build-script specs — producing a fully static native
executable that needs no Gerbil/Gambit installed on the target machine. Requires
a Gerbil configured `--enable-shared=no`; foreign-framework linkage is passed via
`-ld-options -framework AppKit`. The natural realisation of chez's self-contained
distribution model (ADR-0009) for the `gerbil` target.
_Avoid_: "stub-launcher" (that is racket's distribution model, not gerbil's).

## SBCL target toolchain

**`sbcl` target**:
The fourth target — **Steel Bank Common Lisp** with a **CLOS** binding style.
The on-disk unit is `generation/targets/sbcl/`; CLI `--target sbcl`; emitter
crate `emit-sbcl`. The id is a **plain language id** (no `{lang}-{paradigm}`
slug), matching racket/chez/gerbil — CLOS is this target's *one* binding style
(the gerbil analogue: its `defclass`+generics object model is gerbil's single
style), not a reified paradigm axis. No `sbcl-functional` sibling is planned; if
one is ever wanted, register it then (per the retired **Paradigm** guidance).
_Avoid_: `sbcl-clos` as the target id (that is the *grove* name, emphasizing the
headline idiom — the id stays plain `sbcl`); "Common Lisp" as the display name
(the target is pinned to the SBCL *implementation*, not portable CL — ADR-0005).

**`sb-alien`**:
SBCL's compiler-integrated native FFI and the `sbcl` target's FFI layer —
`define-alien-routine` / `alien-funcall` (typed C calls), `with-alien` (stack
aliens), `alien-sap` (pointer↔SAP), `define-alien-callable` (callbacks). The
idiomatic SBCL way to reach `objc_msgSend` / libobjc; the analogue of chez's
`foreign-procedure`, gerbil's `:std/foreign`/`define-c-lambda`, and racket's
ffi2 + `ffi/unsafe/objc`. Chosen over **CFFI** (the portable-across-Lisps FFI
library) per ADR-0005 — CFFI is the "portable subset" the chez-vs-R6RS rule
rejects. Makes `sbcl` a **compiled-FFI** target (ADR-0015), like chez and
gerbil, unlike interpreted-FFI racket: the emitter open-codes one typed alien
signature per method ABI, casting away arm64 variadic `objc_msgSend`.
_Avoid_: "CFFI" / "the FFI" (name it `sb-alien`); "libffi" (sb-alien generates
direct native call sites, not libffi thunks).

**MOP projection / `objc-class` metaclass (sbcl)**:
The `sbcl` object model (provisional, to be settled in the object-model leaf):
ObjC's class system is **projected into CLOS via the Metaobject Protocol**, not
mirrored as plain `defclass`. An `objc-class` metaclass (subclass of
`standard-class`) backs every bound ObjC class; each ObjC class is a CLOS class
of that metaclass carrying the ObjC `Class` pointer; ObjC methods are
**per-selector `defgeneric`/`defmethod` specialized on the receiver** over the
real metaclass-backed class graph (CLOS generic dispatch + method combination +
`call-next-method` for subclass overrides — **not** literal multiple-argument
dispatch, since ObjC is single-receiver; settled **D6**, 2026-06-20, holding D3's
line against the single-dispatch veneer of all prior CL bridges and dodging the
"vacuous" critique the gerbil way: dispatch rides a *real* class graph, not one
wrapper type);
instance ivars/slots route through MOP hooks (`slot-value-using-class`,
`allocate-instance`); `make-instance` trampolines to `alloc`/`init`; deriving
`(defclass my-view (ns:ns-view) … (:metaclass objc-class))` synthesizes a real
ObjC subclass via `objc_allocateClassPair`. The **emitter statically generates
the class graph** (per ADR-0010 / the shared-IR model); the **MOP machinery
lives in the runtime** — diverging from Clozure CL, whose bridge synthesizes
classes dynamically from the live ObjC runtime. The MOP is the *mechanism*; the
class graph stays statically emitted.
_Avoid_: a single `objc-object` wrapper class with generics (gerbil pre-rejected
as "vacuous" — receiver-only dispatch over one type, ADR-0018→0020); "manifest
`defclass` graph" *without* the MOP (that is gerbil's shape, ADR-0020 — sbcl goes
further); "dynamic synthesis from the ObjC runtime" as sbcl's mechanism (that is
CCL's model — sbcl emits the graph statically, runtime owns only the MOP hooks);
"multiple dispatch" (ObjC dispatches on the receiver only — the generics are
receiver-specialized over the real class graph, D6).

**CL-family interface contract** _(settled — ADR-0033 + `docs/specs/2026-06-20-cl-family-interface-contract.md`)_:
The **documented, specification-level interface that all Common Lisp targets share**,
even though each compiles to a different FFI under the hood. The family roster is
four confirmed members — **SBCL, CCL, AllegroCL, LispWorks** (two open-source, two
commercial; ECL/ABCL/Clasp out-for-now — absence, not exclusion) — though **only
`sbcl` is built** in the add-sbcl-clos-target grove; the others shape what the
contract must abstract over (each has its own FFI — `sb-alien` / CCL bridge /
Allegro `ff:` / LispWorks `fli:` — and its own MOP with varying AMOP conformance).
**The normative boundary (decision C1): observable behaviour is normative; the
realization mechanism is implementation-private.** The shared surface is the
`ns:` package, class names, generic-function names, the **portable macros**
`define-objc-subclass` / `define-objc-method` (each impl expands them itself),
`make-instance`→alloc/init, `slot-value`→ivar access, and the **condition
hierarchy** (CL's idiom for `NSError**` — errors are *signalled conditions*, not
`(values result error)`; part of the contract). What is **not** shared — *below*
the contract: the binding implementation (emitter FFI output, callback/block
bridges, threading, distribution) **and the `objc-class` metaclass / MOP
mechanism** (SBCL/CCL realize the macros via the metaclass; LispWorks via plain
`standard-class` + `standard-objc-object` — so **LispWorks is a first-class
conformant member**, conforming by *behaviour* through a different mechanism, not
a fallback tier). Application source written against the contract is **portable
across CL impls**; binding source is not. This is a **spec-level** share, never
shared binding code — so it does **not** reopen the CFFI question (`sb-alien`
stays, ADR-0005) and does **not** breach ADR-0011's *substrate* isolation; it adds
a new **family-level interface-sharing axis** (ADR-0033) **gated on a sharp
precondition (decision C3): a family qualifies only if it has a single,
standardized, well-accepted object model portable across its impls.** CL qualifies
(ANSI CLOS + AMOP); the Scheme family is **ineligible** (no portable object model —
Racket classes / TinyCLOS / Gerbil MOP are mutually incompatible), so
racket/chez/gerbil stay fully hermetic under ADR-0011's default. Aligned with
Clozure CL's existing Cocoa-bridge API for de-facto portability with the existing
CL-Cocoa codebase.
_Avoid_: "shared binding / portable CFFI layer" (that is the rejected code-level
share — different FFI per impl, contract is spec-only; refuted by Objective-CL's
per-impl breakage, research §C3); treating the contract as overturning ADR-0011
(it scopes an *exception*, native substrate stays isolated); placing the contract
spec in a per-target unit (it is *cross-target* within the CL family — main-tier
doc); listing **the `objc-class` metaclass as part of the shared surface** (C1: the
metaclass is *mechanism, below the contract* — the surface is package/names/macros/
conditions); calling **LispWorks a fallback/degraded tier** (it is a first-class
member conforming through a different mechanism).

**`libAPIAnywareSbcl` / sbcl trampoline layer** _(reframed 030, 2026-06-20)_:
The sbcl target's native (Swift) library is the **trampoline layer of the
complete-API binding model** (ADR-0025), *not* a bespoke "Swift coverage device."
SBCL reaches ObjC **directly** (`objc_msgSend` via `sb-alien`, **trampoline
elided**) and routes only the **Swift-native residual** — `objc_exposed == false`
top-level functions/constants, plus the receiver-handle method frontier — through
`libAPIAnywareSbcl`'s flat C-ABI re-exports, bound by typed `sb-alien` call sites.
Because SBCL (like gerbil's `gsc`, ADR-0029) **cannot compile Swift inline**, the
dylib is **necessary** (only Swift calls the Swift ABI), **trampoline-only** (it
does *not* absorb the MOP runtime/object model), and **per-target hermetic**
(ADR-0011/0029 settled this fork — no family-shared substrate). The residual is a
**deterministic function of the shared IR** (gerbil reproduced racket's 51 funcs +
7 constants exactly), which is *itself* what makes the CL family converge: same
analysis → same C ABI → same surface. This is the contract's **lower layer**; the
`ns:`/CLOS surface is the **upper layer**.
_Avoid_: "Swift coverage library" / "second mechanism" (it is the trampoline layer
of one model — ADR-0025 retired "ObjC-only target" as a description); "family-
shared substrate" (ADR-0029 settled hermetic per-target duplication); routing ObjC
through it (ObjC is direct, trampoline elided).

## Native binding mechanism

**Generated typed dispatch**:
The `racket` target's outbound method-dispatch mechanism: the emitter generates
**one typed native (Swift/C) dispatch entry per distinct method ABI signature**,
derived from the API analysis, and emits a thin Racket ffi2 binding that calls
it. Chosen over in-Racket `tell`/typed `get-ffi-obj` msgSend, generic
NSInvocation, and generic libffi because the signature set is *known at
generation time* — so compile-time ABI specialisation (~5–6 ns/call: ~2× faster
than the status-quo typed `get-ffi-obj` msgSend on simple shapes, **~8× on struct
returns** where Racket otherwise pays to marshal a CGRect) is bought with
generated code at zero hand-maintenance. libffi (the generic alternative) is
actually *slower* than the typed status quo on non-struct shapes and is kept only
as the escape hatch for signatures the emitter cannot type statically. See
**ADR-0013** and `docs/specs/2026-05-31-racket-native-binding-design.md`.
_Avoid_: "msgSend wrapper" (ambiguous with the deleted `aw_common_msg_*`);
"libffi dispatch" (libffi is only the rejected generic alternative / escape hatch).

**Marshalling-depth spectrum**:
How much of a method's argument/result marshalling and lifetime handling moves
into its generated native entry, so the scripting side never sees it. *Depth 0*
= dispatch only (opaque pointers). *Depth 1* (the target) = typed marshalling per
method — strings/structs cross as Racket-friendly representations, the Racket
wrapper is a coercion-free ffi2 call. *Depth 2* = semantic batching (collections
in one native call, `NSError**` → `(values result error)`). The emitter walks the
spectrum *per method* from the IR types. Embodies ADR-0010's "target never
considers the FFI boundary."
_Avoid_: treating it as a global switch (it is per-method).

**Native trampoline**:
The inbound-callback mechanism: a native Swift object/IMP
(`DelegateBridge`/`BlockBridge`) receives the ObjC call, owns thread-safety
(bouncing foreign-OS-thread invocations to a Racket-safe thread via
`main-thread.rkt`), and invokes the registered Racket `_cprocedure` callback.
Kept and deepened (not replaced) by the ffi2 migration: ffi2 callbacks SIGILL on
foreign threads and have a void-return bug. See **ADR-0014**.
_Avoid_: "ffi2 callback" (rejected); "inbound embedding" (the rejected
Racket-CS-C-API alternative).

## Gerbil native binding mechanism

**Manifest class hierarchy (gerbil)**:
The gerbil object model (ADR-0020, supersedes ADR-0018): the **full ObjC class
graph reified as a Gerbil `defclass` hierarchy** (`NSButton : NSControl : NSView
: NSResponder : NSObject`), full ancestor chain incl. intermediate classes we
bind no methods of, matching Apple's documented graph. Root is a runtime-owned
`NSObject` carrying the `ptr` slot; each class defined once by its owning
framework's module (cross-framework ancestry ⇒ cross-module import). Lifetime is
a Gambit **will** + entry-point autoreleasepool (ADR-0019).
_Avoid_: `objc-obj` / a single `(defstruct objc-obj (ptr))` handle (the
superseded ADR-0018 model — receiver-only dispatch over one type is vacuous);
"no class graph".

**Class registry / `register-objc-class!` (gerbil)**:
The wrap-boundary + subclassing-bridge registry (ADR-0020). Each emitted class
module, right after its `(defclass …)`, emits
`(register-objc-class! <gerbil-class> "<objc-name>" "<objc-super>")` — a runtime
call (runtime owns the proc, leaf 050) that records the **ObjC-name → Gerbil-type**
mapping the wrap boundary consults (`object_getClass` → the exact bound type, with
the runtime walking the ObjC superclass chain to the **nearest bound ancestor** when
a class is unbound) and the **ObjC superclass name** the subclassing bridge passes
to `objc_allocateClassPair`. Registration is **inline per class module** (not a
central table), so importing a class registers it and the framework facade
registers them all; the nearest-bound-ancestor fallback covers classes whose
module was not loaded.
_Avoid_: a per-framework registration table; deriving the ObjC super from the
resolved Gerbil parent (the registration's super is the *real* IR `superclass`,
even when the Gerbil parent degrades to the runtime root).

**Cross-framework parent resolution / `ClassRegistry` (gerbil, emitter)**:
The emitter-side seam (leaf 030) for placing a `defclass` parent that lives in
another framework. `Class.ancestors` is sorted alphabetically (not chain order),
so the graph is built from each class's immediate `superclass` edge. A parent is
**local** (same framework — the common case, resolved from the framework's own
class set), the **runtime root** (`NSObject` / empty super), **cross-framework**
(resolved via a `ClassRegistry` mapping class-name → owning-framework, built once
over all loaded frameworks by the CLI pre-pass — leaf 060), or a **synthesized
bare node** (a same-framework ancestor referenced but not collected: emitted as a
minimal `defclass`-only module rooted on `NSObject`, since its own parent is
unknowable from an unordered ancestor set). The per-framework emitter cannot see
other frameworks, so an empty registry degrades a cross-framework parent to the
runtime root while preserving the true ObjC super in the registration.
_Avoid_: reconstructing the chain from `ancestors` ordering; re-defining a
cross-framework ancestor locally (import it from its owner instead).

**Conformed-protocol method flattening / `ProtocolRegistry` (gerbil, emitter)**:
The protocol analogue of `ClassRegistry` (leaf 120). The emitter flattens
instance methods/properties declared on the protocols a class conforms to onto
that class, so e.g. `SCNNode.runAction:` (declared on `SCNActionable`) is a
first-class generated binding. It flattens **only the class's own conformance
closure** — `Class.protocols` closed over protocol `inherits` edges — *not* the
wholesale `all_methods` chez/racket flatten: ancestor conformances ride the
`defclass` graph structurally (ADR-0020). `ProtocolRegistry` maps protocol-name →
`inherits`, built once over all loaded frameworks by the CLI pre-pass, because
those edges cross frameworks (`NSSecureCoding` → `NSCoding`). The closure
**excludes the `NSObject` protocol** (name-collides with the root class) and
**skips registry-unknown protocols** (their `all_methods` entries are
minimal wrong-arity stubs that would emit broken `objc_msgSend` crossings). Own
methods win selector ties; a protocol `initWithCoder:` never suppresses the
synthesized `make-<cls>` (the default-ctor check is own-inits-only). Protocol
*properties* need no separate path — their accessors arrive as protocol methods.
_Avoid_: flattening the full `all_methods` set for gerbil (re-emits ancestor
surfaces the manifest graph already carries); emitting an unknown protocol's
stub methods.

**Generated `define-c-lambda` dispatch (gerbil)**:
The gerbil outbound-dispatch mechanism: the emitter open-codes one typed
`define-c-lambda` per distinct method ABI signature into the binding library,
with an inline-cast `objc_msgSend` body (arm64 forbids variadic msgSend). The
compiled-FFI analogue of chez's per-signature `foreign-procedure` (ADR-0015) —
**converges with chez, diverges from racket's generated native dispatch
(ADR-0013) and from the 020 spike's fat-native headline**. Settled on two axes:
runtime is a tie (a native shim is free in a compiled-FFI binary), and the
compile-time penalty is a *one-time binding-build cost*, not per-app, because
Gerbil compiles a binding **library to `.ssi`+`.o1` once** and importing apps
reuse it (the **precompilation** finding). See ADR-0017.
_Avoid_: "fat-native dispatch" / "Swift dispatch table" for gerbil (that is
racket ADR-0013; gerbil keeps the crossing in Gerbil).

**Dual dispatch surface / proc core (gerbil)**:
Over the manifest class hierarchy the emitter exposes **both** Gerbil dispatch
surfaces (ADR-0020): the built-in `{sel obj}` MOP (42.8 ns) *and* `:std/generic`
`(sel obj)` generics (29.4 ns), sharing identifiers (spike `07-dual-surface.ss`
proved no collision — `{}` keys on the method-table symbol, the generic is a
top-level binding). Both forward to an inlinable **proc core** (`nsstring-length`,
16.3 ns — DRY substrate + designated fast path) bottoming out in the `%msg-…`
crossings. OO is the natural **extension** surface, generics the **consumption**
surface.
_Avoid_: "OO veneer" / "opt-in single layer" (superseded ADR-0018); calling `{}`
"rejected" (both surfaces are emitted now).

**Transparent extensible subclassing (gerbil)**:
The gerbil extension model (ADR-0020): deriving `(defclass (MyView NSView) …)`
with override methods **transparently synthesizes a real ObjC subclass** at
runtime (`objc_allocateClassPair` + IMP trampolines + `objc_registerClassPair`)
so the frameworks dispatch callbacks into the user's Gerbil methods —
*deriving in Gerbil = deriving in ObjC*. The binding library re-exports
`defclass`/`defmethod` that **shadow** the built-ins (falling through for
non-ObjC classes); the runtime owns the libobjc synthesis bridge (gerbil analogue
of racket's `dynamic-class.rkt`). Promotes dynamic-class synthesis from a
deferred native-core item to the core of the object model.
_Avoid_: a detached `define-objc-subclass` macro (that is racket's shape; gerbil
integrates with `defclass`); "dynamic classes are out of scope / later".

**ObjC-in-gsc native core (gerbil)**:
The gerbil native core (block/delegate bridges, dynamic classes, lifetime
helpers, thread activation) authored as **Objective-C compiled by `gsc` into the
static executable** (via `c-declare`/a companion `.m`, `-x objective-c`), NOT a
separate Swift dylib. Keeps the static-exe self-contained (ADR-0009); ADR-0011
licenses diverging from racket/chez's Swift dylib. Honours ADR-0010 (a
purpose-built native core) in the language gsc speaks. See ADR-0017.
_Avoid_: "Swift dylib"/`libAPIAnywareGerbil.dylib` (that is the
racket/chez shape; gerbil compiles ObjC inline via gsc).

## Documentation structure

**Main docs / main tier**:
The cross-cutting documentation that applies to the project as a whole or to the
shared `collect → analyse → generate` pipeline — not to any one target.
Consolidated under a single top-level **`docs/`** tree: `adr/` (the central
decision log, all targets), `pipeline/`, `specs/`, `research/`, `apps/`
(language-agnostic app portfolio specs), `testing/` (TestAnyware methodology),
`guides/`, and `docs/README.md` as the map. `README.md` and `CONTEXT.md` remain
at the repo root. The former `knowledge/` tree is dissolved into this.
_Avoid_: "knowledge base" (the `knowledge/` tree is retired); treating `docs/`
as holding per-target material (ADRs are the sole per-target-flavoured content
kept central — see below).

**Per-language docs / co-located target docs**:
Target-specific documentation, co-located inside the target's own on-disk unit
`generation/targets/<lang>/` (ADR-0011 hermetic isolation extended to docs):
`docs/reference.md`, `docs/developer-guide.md`, `docs/design/`,
`docs/research/`, and per-app `apps/<app>/learnings.md` +
`test-results/<app>/report.md`. The **one exception** is ADRs: the decision log
is a connected graph crossing target boundaries (supersession chains;
later targets cite earlier ones), so *all* ADRs stay central in `docs/adr/` with
global numbering.
_Avoid_: a central `docs/targets/<lang>/` tree (re-centralizes what isolation
separates); per-target ADR renumbering (breaks the cross-target decision graph).

## Example dialogue

> **Dev**: Should we add a `--style functional` to the CLI for the new Chez
> target so it shares the racket emitter?
>
> **Domain**: No — the paradigm dimension is retired. If Chez wants a
> functional shape, it's a separate **target** (`chez` or `chez-functional`)
> with its own emitter crate, its own sample apps, its own knowledge entries.
> The CLI only knows about targets; binding style is implicit per target.
