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
boundary and never reach the guardian. Originated in the chez lifetime model;
the racket runtime relies on per-thread autorelease pools instead. **Generalized
to the CL family** (ADR-0036 + ADR-0033 C1): the *user obligation* — wrap your own
non-runloop loops, the same rule Cocoa imposes on ObjC command-line tools — is
family-level **observable behaviour**, but the *mechanism* is per-impl (sbcl: the
pool boundary doubles as the main-thread release-queue drain — see *sbcl lifetime /
main-thread release queue*). See `docs/adr/0007-chez-lifetime-model.md`,
`docs/adr/0036-sbcl-lifetime-finalize-and-main-thread-release-queue.md`.
_Avoid_: "main pool" (ambiguous with NSRunLoop's autorelease pool); calling it
chez-only (it is now a family convention with per-impl realization).

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

**sbcl emitter conventions** _(settled — `emit-sbcl` leaf 040/010, 2026-06-20)_:
The fixed spellings every later emitter leaf + the runtime (050) must match, so
the binding is internally consistent. **Names** (contract §3.1/§3.2): the **`ns:`
package**; classes are acronym-aware kebab-case (`NSString` → `ns:ns-string`,
`NSURLHandleClient` → `ns:ns-url-handle-client`, `NSOpenGLView` →
`ns:ns-opengl-view`) via the **shared** `emit::naming::acronym_aware_kebab` (the
acronym/compound table is shared analysis-level data — pile-up acronyms split,
brand compounds stay whole — extend it there, not per-impl); a selector maps to
one generic-function symbol that **preserves selector structure** (ADR-0039): each
`:` → `_`, each camelCase hump → `-` (`objectAtIndex:` → `ns:object-at-index_`,
`setObject:forKey:` → `ns:set-object_for-key_`, `cancel`→`ns:cancel` but
`cancel:`→`ns:cancel_`), plus a keyword-symbol list (`(:object-at-index)`). This map
is **injective** — the colon and the hump never merge — so distinct ObjC selectors
never collide and need NO rename table / global reconciliation / emitter-side
collision detector (macOS's surface is collision-free, integrity is an analysis-phase
invariant). The pre-ADR-0039 `-`-join dropped the colon and collided `foo`/`foo:`. **FFI spellings** (`SbclFfiTypeMapper`,
grounded in the 030 spikes): opaque ObjC `id`/`Class`/`SEL`/block/raw-pointer →
`sb-alien:system-area-pointer` (a SAP, **not** `(* t)`); C strings →
`sb-alien:c-string`; scalars → `(sb-alien:signed N)`/`(sb-alien:unsigned N)`/
`sb-alien:float`/`sb-alien:double`; ObjC `BOOL` → `(sb-alien:boolean 8)`; geometry
structs pass **by value** as `(sb-alien:struct <name>)` with `NSRect`/`CGRect`
canonicalised to `ns-rect` (the runtime `define-alien-type`s these + confirms
by-value passing). The `TargetInfo` `generated_subdir` is **`generated`** (SBCL
imposes no library-path-resolution constraint, unlike chez's `apianyware`).
_Avoid_: re-deriving the acronym table inside `emit-sbcl` (it lives in shared
`emit`); `(* t)` for ObjC pointers (the spikes use SAP); lowercasing class names
to `nsstring` (that is the scheme targets' convention — sbcl is hyphenated +
`ns:`-qualified).

**sbcl emitter on-disk layout + the 040→050 package seam** _(settled — `emit-sbcl`
leaf 040/060, 2026-06-20)_: per framework the orchestrator writes a **facade**
`<fw_low>.lisp` next to a `<fw_low>/` dir holding `generics.lisp` (one `defgeneric`
per selector — a CL package unifies generics across files, so there is **no**
gerbil-style global generics module and no sharding), one **`<class>.lisp` per
class** (lowercased ObjC name — `NSString` → `nsstring.lisp` — each its own
`defclass` + dispatch + `register-*`, the gerbil per-class on-disk symmetry), a
file per synthesized bare node, and `protocols.lisp`/`enums.lisp`/`constants.lisp`/
`functions.lisp` (each present only when non-empty). Every file opens with
`(in-package #:apianyware-sbcl-impl)` — the **runtime/impl package** the runtime
(050) must define (`(:use :cl sb-mop)` + the `aw-*` helpers + the `ns` package).
The **facade is the CL form of gerbil's re-export**: it `(export …)`s every bound
`ns:` symbol (spelled `ns::…` to intern) so the construct files' **single-colon**
`ns:` references — the contract's named surface — read as external symbols. This
fixes a **load order** the runtime's ASDF system must honour: **facade first**,
then `generics.lisp`, then the per-class files **superclass-before-subclass**, then
the rest. The Swift-native **fn/const residual** is bound here (`render_binding`);
a **class** owner's **method/init residual** is wired by leaf **045**
(`emit_swift_native_residual`) — each bindable method a receiver-specialized
`(defmethod ns:<base-labels> ((self ns:<owner>) …) …)` (selector-analogous generic =
base + non-wildcard labels; folded into `collect_generics` for the defgeneric
lockstep), each bindable initializer a `(defun ns:make-<owner>… )` constructor (a
class owner `aw-wrap`s the returned id — **not** §3.3's `make-instance` path, since a
Swift-native init calls `Owner(labels:)` through the trampoline, not ObjC
`alloc`/`init`). **Value-struct (population-B) owners** stay deferred — no CLOS class
to specialize on (an object-model decision for a follow-up leaf); their residual is
still collected for the §6d count. _Avoid_: a per-framework
single `classes.lisp` (per-class files are the convention — reviewable goldens +
gerbil symmetry); emitting bound names double-colon `ns::` in definitions (that is
the facade's interning spelling only — definitions use single-colon).

**sbcl runtime seam (the `sb-alien` FFI foundation)** _(realized — leaf 050/020,
2026-06-20)_: the runtime lives at `generation/targets/sbcl/lib/runtime/`
(module-per-concern, peer gerbil's): `packages.lisp` (the `ns` + `apianyware-sbcl-impl`
packages — `ns` `(:use)` nothing, impl `(:use :cl sb-mop)`), `ffi.lisp` (the seam),
`swift-trampoline.lisp` (the Swift-native residual binding shape), `load.lisp` (the
**dev** loader — the production ASDF system that also sequences the `generated/` facade
+ construct files is 050/070's). The seam reaches ObjC **directly**: `+objc-msgsend+`
is `objc_msgSend`'s address taken **once as a raw SAP**, `sap-alien`-recast to the exact
`(function <ret> sap sap <args>…)` type **per call site** — arm64 needs **no
`_stret`/`_fpret`** variant (those symbols exist for x86 compat but the plain entry
returns structs/floats correctly via x8; verified with `-rangeOfString:`). Classes +
selectors resolve **lazily from baked strings, cached** (`aw-class`/`aw-sel` over
`*class-cache*`/`*sel-cache*`) — a framework must be `dlopen`ed (`aw-load-framework`)
before its classes resolve, and 050/070 clears the caches + re-resolves after a dump
(the SAP is never baked). The object boundary is `aw-ptr` (outbound, reads the `ptr`
slot) / `aw-wrap` (inbound, `*objc-class-registry*` → `make-instance` — registry empty
here, **populated by 050/030**); the UTF-8 string bridge is
`aw-make-nsstring`/`nsstring->string`. The residual loads `libAPIAnywareSbcl` via
`aw-load-native-dylib` (`*native-dylib-path*`) and binds each `aw_sbcl_*` entry with a
typed `sb-alien` crossing (the canonical shape: `aw-box-free` ↔ `aw_sbcl_box_free`).
_Avoid_: `extern-alien` for `objc_msgSend` (it is selector-polymorphic — take the SAP +
recast); baking a `Class`/`SEL` **pointer** (bake the string, re-resolve per process);
CFFI (the seam is `sb-alien`, ADR-0015).

**MOP projection / `objc-class` metaclass (sbcl)** _(settled — ADR-0034; mechanisms verified first-hand on SBCL 2.6.5)_:
The `sbcl` object model: ObjC's class system is **projected into CLOS via the
Metaobject Protocol** (`sb-mop`), not mirrored as plain `defclass`. An `objc-class`
metaclass (subclass of `standard-class`) backs every bound ObjC class; each ObjC
class is a CLOS class of that metaclass carrying the ObjC `Class` pointer (foreign
`ptr` slot on the runtime-owned root `ns:ns-object`); the full ancestor chain is
reified. ObjC methods are **per-selector `defgeneric`/`defmethod` specialized on
the receiver** over the real metaclass-backed class graph (CLOS generic dispatch +
method combination + `call-next-method` for subclass overrides — **not** literal
multiple-argument dispatch, since ObjC is single-receiver; settled **D6**,
2026-06-20, holding D3's line against the single-dispatch veneer of all prior CL
bridges and dodging the "vacuous" critique the gerbil way: dispatch rides a *real*
class graph, not one wrapper type). The emitter emits **one explicit `defgeneric`
per selector** (authoritative arglist/docstring — the named contract surface) + one
`defmethod` per (class × selector). **Generic explosion is a non-issue:** the
full AppKit+Foundation scale (6,500 generics + 40,000 methods) compiles **cold in
~8.4 s** on SBCL — gerbil's ADR-0023 5h blow-up lived in Gambit's `:std/generic`
*macro*, not in SBCL's native CLOS, so **no sharding / no-`-O` / parallel-compile
machinery is needed**. Instance **ivars** are foreign slots: `slot-value-using-class`
+ a custom foreign slot-definition class carrying a **baked bit-offset** + foreign
ctype, discriminating foreign ivars from plain-Lisp slots (the `ptr` handle falls
through to standard storage); baked offsets are SDK-drift-sensitive (a fast path
over the always-safe accessor-selector path). `make-instance` routes through
**`allocate-instance` specialized on `objc-class`** → `alloc`/`init` (no init
initargs ⇒ alloc-only); deriving `(define-objc-subclass my-view (ns:ns-view) …)`
(→ `:metaclass objc-class`) synthesizes a real ObjC subclass via
`objc_allocateClassPair` + IMP install + `objc_registerClassPair`. The **emitter
statically generates the class graph** (per ADR-0010 / the shared-IR model); the
**MOP machinery lives in the runtime** — diverging from Clozure CL, whose bridge
synthesizes classes dynamically from the live ObjC runtime. Because
`save-lisp-and-die` (D4) keeps baked Lisp metadata but **loses live foreign
pointers** (verified: a revived image sees `objc_getClass "NSString"` → NULL until
Foundation is re-`dlopen`ed), the runtime owns a CCL-`revive-objc-classes`-equivalent
**startup re-resolution pass**: re-`dlopen` each framework, then re-resolve every
`Class`/`SEL` from its **baked string identity** (never reuse a baked pointer) —
load-bearing for `070` `bundle-sbcl`. The MOP is the *mechanism*; the class graph
stays statically emitted. A `define-objc-method` override's IMP is libobjc's
`_objc_msgForward` (installed by `SubclassSynth.swift`); the framework callback bounces
to the main thread, then **one** Lisp forwarding dispatcher reads the call's ABI shape
**live** off the `NSInvocation`'s `NSMethodSignature` and routes through the `ns:`
generic. ObjC super-chaining from an override is the explicit **`call-super` /
`call-super-id`** (`objc_msgSendSuper`), set in 050/040.
_Avoid_: `call-next-method` to reach the **ObjC** inherited implementation (a bound
method sends `objc_msgSend` to *self*, which re-enters the forwarding IMP → infinite
recursion — use `call-super`; `call-next-method` is for Lisp-subclass-of-Lisp-subclass
chains only); a raw `define-alien-callable` installed *as* an IMP (it runs Lisp on the
framework's foreign thread — the ADR-0035 crash; the IMP must be the dylib's native
bounce shim); a single `objc-object` wrapper class with generics (gerbil pre-rejected
as "vacuous" — receiver-only dispatch over one type, ADR-0018→0020); "manifest
`defclass` graph" *without* the MOP (that is gerbil's shape, ADR-0020 — sbcl goes
further); "dynamic synthesis from the ObjC runtime" as sbcl's mechanism (that is
CCL's model — sbcl emits the graph statically, runtime owns only the MOP hooks);
"multiple dispatch" (ObjC dispatches on the receiver only — the generics are
receiver-specialized over the real class graph, D6); **porting gerbil's
generics-sharding / no-`-O` / parallel-compile pipeline** (ADR-0023 — that fixes a
Gambit-macro cost SBCL's native CLOS does not have); reusing a baked foreign
`Class`/`SEL` pointer after an image dump (it is stale — re-resolve from the string).

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

**`libAPIAnywareSbcl` / sbcl trampoline layer** _(reframed 030, 2026-06-20; lower layer settled ADR-0038)_:
The sbcl target's native (Swift) library is the **trampoline layer of the
complete-API binding model** (ADR-0025), *not* a bespoke "Swift coverage device."
SBCL reaches ObjC **directly** (`objc_msgSend` via `sb-alien`, **trampoline
elided**) and routes only the **Swift-native residual** — `objc_exposed == false`
top-level functions/constants, plus the receiver-handle method frontier — through
`libAPIAnywareSbcl`'s flat C-ABI re-exports, bound by typed `sb-alien` call sites
(Lisp-side marshalling, ADR-0015; object returns wrapped to bound type via the
ADR-0034 MOP class registry; no lazy-load forcing reference). Because SBCL (like
gerbil's `gsc`, ADR-0029) **cannot compile Swift inline**, the dylib is
**necessary** (only Swift calls the Swift ABI) and **per-target hermetic**
(ADR-0011/0029 settled this fork — no family-shared substrate). It is the SBCL
target's **sole native compilation unit** — so, *unlike* gerbil's strictly
trampoline-only dylib (which had a second ObjC-in-`gsc` home), it **also hosts the
genuinely-native runtime concerns** gerbil kept in ObjC: the main-thread callback
bounce (ADR-0035), the `objc_allocateClassPair` subclass-IMP synthesis (ADR-0034 §5),
and the `OpaqueHandle`/`ThrowsBridge`/`AsyncBridge` marshalling helpers. It is
**"trampoline-only" in the exact sense that it does *not* absorb the MOP object
model** (metaclass, hooks, class graph, dispatch generics, startup re-resolution all
stay Lisp-side). On `save-lisp-and-die` the dylib stays **passive**: SBCL
auto-reopens it (in `*shared-objects*`) so its `aw_sbcl_*` symbols re-link for free
and dyld re-loads its linked framework subset, while the **Lisp** startup pass owns
the direct-msgSend frameworks + **all** `Class`/`SEL` re-resolution over the baked
graph (ADR-0034 §6 / ADR-0038 §5). The residual is a **deterministic function of the
shared IR** (the §6d invariant: 51 funcs + 7 constants + 576 init + 554 method,
identical across targets), which is *itself* what makes the CL family converge: same
analysis → same C ABI → same surface. This is the contract's **lower layer**; the
`ns:`/CLOS surface is the **upper layer**.
_Avoid_: "Swift coverage library" / "second mechanism" (it is the trampoline layer
of one model — ADR-0025 retired "ObjC-only target" as a description); "family-
shared substrate" (ADR-0029 settled hermetic per-target duplication); routing ObjC
through it (ObjC is direct, trampoline elided); reading "trampoline-only" as "only
trampolines" (it is the *sole native unit* and hosts the bounce/IMP/marshalling
helpers — "trampoline-only" means *no MOP object model*, ADR-0038); a second native
unit / a `aw_sbcl_revive` dylib entry (one dylib; the relive is a Lisp pass).

**sbcl main-thread bounce** _(settled — ADR-0035; spiked first-hand on SBCL 2.6.5/arm64)_:
The `sbcl` threading/callback model: a **foreign** OS thread (a GCD worker /
framework completion SBCL never created) must **never** run Lisp directly — the
native-core callback trampolines (delegate IMPs, block invokes, subclass IMPs)
**bounce to the main thread** (SBCL-native, suspendable, runs the AppKit loop)
before re-entering Lisp, in `libAPIAnywareSbcl` Swift (`dispatch_sync`
value-returning / `dispatch_async` void — gerbil ADR-0022's split). Reached
**empirically**, not by inheritance: the 2026-06-20 threading spike crashed 5/5
when concurrent GCD workers ran Lisp (`cannot suspend thread: ENOTSUP` inside
`GC-STOP-THE-WORLD` — SBCL can't stop-the-world-suspend foreign threads on macOS),
so chez's `Sactivate_thread` activation (ADR-0016) is **rejected**. **Richer than
gerbil:** SBCL-**native** `sb-thread` workers *do* run real concurrent Lisp safely
(the spike's control survived), so background compute uses `sb-thread`, not captured
foreign threads — the bounce scopes to *foreign* entry only.
_Avoid_: "activate the foreign thread" (chez's model — empirically unsafe here);
"bounce everything" (native `sb-thread`s need no bounce); framing it as inherited
from gerbil (same outcome, opposite cause — gerbil crashes at entry, sbcl inside GC).

**sbcl lifetime / main-thread release queue** _(settled — ADR-0036; finalizer-thread fact verified on SBCL 2.6.5)_:
The `sbcl` lifetime model for wrapped ObjC `id`s — the two-mechanism shape of chez
ADR-0007 / gerbil ADR-0019, with an SBCL twist. **Retained objects:**
`sb-ext:finalize` (idiomatic; O(dead) like chez's guardian) is the GC-death trigger;
its closure captures **only the raw `id`** (never the wrapper) and **enqueues** it
— because `sb-ext:finalize` runs on a dedicated **`"finalizer"` thread**, so a direct
`release` would fire off-main and an off-main `dealloc` of an AppKit object is UB.
A **main-thread drain** at the entry-point pool boundary sends `release` on main
(UI-safe). **Autoreleased (+0) transients:** the entry-point `@autoreleasepool`
drains them and doubles as the release-queue drain point. The off-main-finalizer
issue is *UI-affinity*, not GC-safety (the finalizer thread is SBCL-native, hence
suspendable — unlike the foreign threads of the bounce model).
_Avoid_: "guardian" (chez's primitive — SBCL uses `sb-ext:finalize`); "weak-pointer
scan" (rejected — O(live), loses the O(dead) efficiency); "release on the finalizer
thread" (off-main AppKit dealloc is UB — the queue routes it to main).

**`ns:objc-error` condition hierarchy** _(settled — ADR-0037; back-fills contract spec §3.7)_:
The CL-family error surface for `NSError**` / `NSException`, **signalled** as CL
conditions (not `(values result error)` — ADR-0033/0006 contrast). **Flat, split by
source:** root `ns:objc-error` `: cl:error` (stable family-portable `handler-case`
target); `ns:cocoa-error` (the `NSError**` path; `domain`/`code`/`user-info`/
`localized-description` readers); `ns:objc-exception` (the `NSException` path;
`name`/`reason`/`user-info`). Condition types are **distinct symbols** from the
projected CLOS classes `ns:ns-error`/`ns:ns-exception` (the condition wraps the
object). **No per-domain subclasses** (keeps cross-impl conformance cheap — callers
branch on `domain`/`code`). **Minimal restarts:** `use-value` + `continue`/
`return-nil` (`retry` deferred). Signals **only** when the primary return indicates
failure (Cocoa rule — `NSError**` may be garbage on success); the **same signaller**
serves the direct path and the Swift-`throws` trampoline (`ThrowsBridge`).
_Avoid_: naming a condition `ns:ns-error`/`ns:ns-exception` (those are the bound CLOS
classes); per-(domain×code) condition subclasses (rejected — bloats the contract);
"returns an error tuple" (the family signals, per ADR-0033).

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
