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

**ObjC runtime class name (vs Swift-overlay name)** _(collection IR fact; settled — k38)_:
The class identity APIAnyware keys on: the name the **live ObjC runtime** reports
(`class_getName`), recovered at collection from the clang **USR**
(`c:objc(cs)NSScanner`, or the `@objc`-Swift infixed `c:@M@…@objc(cs)NSScanner` →
`NSScanner`), **not** the Swift import name the overlay may rename it to (`Scanner`,
`URLSession`, `FileHandle`, the `Unit*` family, the private `_NSKeyValueObservation`). Set
in `extract-swift` `map_class` (`objc_runtime_class_name`). Because the Swift↔ObjC merge
(`merge_swift_into_objc`) matches by `name`, keying on the runtime name **unifies** a
Swift-overlay class with its clang twin into **one** IR class — instead of two classes that
split the runtime class's methods (the ObjC methods on `NSScanner`, the Swift-native residual
on a separate `Scanner`). A shared, analysis-level fact, so the unification fixes **all
targets** at once. Without it, every target baked the overlay name into its class-identity
registry, so a live object's runtime name missed the registry (no auto-wrap) and
`objc_getClass(<overlay-name>)` returned nil (no construct).
_Avoid_: keying a registry/dispatch table on the Swift-overlay name (the k38 bug — it cannot
match `class_getName`); a per-target NS-prefix heuristic to recover the runtime name (misses
non-NS renames like `_NSKeyValueObservation`; the USR is the authoritative source).

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
finalizers — see `adr/0007-chez-lifetime-model.md`.
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
main-thread release queue*). See `adr/0007-chez-lifetime-model.md`,
`adr/0036-sbcl-lifetime-finalize-and-main-thread-release-queue.md`.
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
`adr/0016-chez-outbound-callbacks-with-thread-activation.md`.
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
`targets/racket/docs/research/2026-05-31-racket-9.2-ffi2-migration.md`.
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

**value-struct CLOS projection / `ns:value-struct` (sbcl)** _(settled — ADR-0042)_:
The **population-B (value-struct) dual** of the `objc-class` projection above. A Swift
value struct (`objc_exposed == false`, e.g. `IndexSet`, `CharacterSet`) with bindable
Swift-native methods/inits projects to a **plain CLOS class** `(defclass ns:<struct>
(ns:value-struct) ())` — a `standard-class`, **not** the `objc-class` metaclass (a value
struct has no ObjC `Class`, so alloc/init, ivar offsets and subclass synthesis are all
inapplicable). The runtime-owned root **`ns:value-struct`** holds the opaque
`AwSbclValueBox` handle in a **`ptr` slot — the same slot name `ns:ns-object` uses** — so
`aw-ptr` reads it unchanged: a value-struct method's receiver coerces through the *same*
`(aw-ptr self)` as a class owner (and a value-struct arg through `(aw-ptr arg)`), with the
unbox + `mutating` write-back living entirely in the `@_cdecl` Swift side. Methods bind as
`(defmethod ns:<gen> ((self ns:<struct>) …))` (their generics fold into `generics.lisp`
like a class owner's); inits bind as `(defun ns:make-<struct> … (make-instance 'ns:<struct>
:ptr <box>))` constructors that **wrap the box into an instance** (the sole root producer —
method/fn returns of a value type stay un-nameable opaque boxes). Lands in a per-framework
**`structs.lisp`** (residual-gated, loaded like `functions.lisp`). The `ns:value-struct`
root arms a **box finalizer** (`aw-box-free`) — freed **directly off the finalizer thread**
(no main-thread queue: a value box has no UI `dealloc` affinity, unlike a wrapped ObjC `id`,
ADR-0036). A residual method whose generic post-kebabs to an already-declared name at a
**different arity** is **dropped** (a CLOS generic cannot carry two arities — it would crash
at load), surfaced as a `WARN`. This is a **cross-target divergence**: gerbil keeps value
structs **procedural** (`(->ptr self)` passes the raw box, methods are plain `define`s —
Scheme has no `defun`/`defgeneric` symbol collision); SBCL's single `ns:` package forces the
CLOS class (a bare `defun ns:foo` cannot coexist with `defgeneric ns:foo`).
_Avoid_: an `objc-class` metaclass for a value struct (no ObjC Class behind it); a bare
`defun` value-struct method (collides with same-named generics in the single `ns:` package);
a constructor that hands back the **raw box** (it would not dispatch through the struct's
methods); routing `make-instance 'ns:<struct>` through the trampoline (it is the standard
CLOS make — the named `ns:make-<struct>` is the constructor surface).

**CL-family interface contract** _(settled — ADR-0033 + `targets/_shared/docs/design/2026-06-20-cl-family-interface-contract.md`)_:
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

**bundle-sbcl / sbcl distribution** _(settled — ADR-0041; supersedes ADR-0038 §6)_:
The crate that packages a sample app as a self-contained `.app`. Pipeline: drive the
app's **own `dump.lisp`** (`save-lisp-and-die :executable t`) to write the image into
`Contents/Resources/`, behind a Swift **stub** (`CFBundleExecutable`) that
`execv`s it. Self-containment is closed **at runtime, never editing the image** —
post-dump `install_name_tool` is *impossible* (the Lisp core sits past `__LINKEDIT`).
Two gaps: **libzstd** (a hard `LC_LOAD_DYLIB`) is vendored into `Contents/Frameworks/`
and resolved by leaf name via the stub's `DYLD_FALLBACK_LIBRARY_PATH`; the `dlopen`ed
**libAPIAnywareSbcl** (residual apps) is re-opened via a relocated `@executable_path/..`
`*shared-objects*` namestring (the `AW_NATIVE_DYLIB_RECORD_AS` hook on
`aw-load-native-dylib`). The dumped image keeps its own ad-hoc signature (signed
*around*, not re-signed). _Avoid_: "vendor + `install_name_tool` like bundle-gerbil"
(ADR-0041 — impossible on a dumped image); re-signing the dumped image.

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
**ADR-0013** and `targets/racket/docs/design/2026-05-31-racket-native-binding-design.md`.
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

Documentation **lives with its subject** (REFACTOR §10, ADR-0024/ADR-0045):
there is **no large top-level `docs/` tree**. Each domain owns its docs under a
local `docs/`, and the root `README.md` is a map only (§11). `README.md` and
`CONTEXT.md` remain at the repo root.

**Co-located docs / docs-with-subject** (the §10 placement rule):
- semantic vocabulary → `semantic/docs/` (the analysis/enrich pipeline docs
  `analysis.md`, `enrich-rules.md`, `api-pattern-catalog.md`,
  `memory-architecture.md`; cross-cutting design specs under `semantic/docs/design/`).
- platform truth → `platforms/<platform>/docs/` (`collection.md`,
  `annotation-workflow.md`, `codesigning-identity.md`).
- shared target machinery → `targets/_shared/docs/` (the new-target guide
  `adding-a-language-target.md`, `emitter-contract.md`, `type-mapping.md`;
  the cl-family contract + IR ObjC-exposure boundary specs under `design/`; the
  cross-family `research/`).
- per-target docs → `targets/<target>/docs/` (`reference.md`,
  `developer-guide.md`, `design/`, `research/`), ADR-0011 hermetic isolation
  extended to docs; per-app `learnings.md` + `report.md` stay in the target unit.
- common app docs → `apps/<platform>/<app>/docs/` (`spec.md` + the
  `logging-contract.md`/`observable-state.md` contracts + `run-results.md`; optional
  app-universal `learnings.md`), with the `#lang app-spec` suite in `<app>/scenarios/`
  and per-app `run-values*.rkt` alongside; portfolio index + design at
  `apps/<platform>/docs/`. (Pre-AppSpec `test-strategy.md` checklists retired,
  `apps-layout-finalize-k84`.)
- schema docs → `schemas/docs/`.
- test model + methodology → `testing/` (the multi-layer `test-model.md`, the
  `testanyware-workflow.md` GUI-testing runbook, and `strategies/`).
_Avoid_: a "main tier" / single top-level `docs/` (dissolved by the
`structural-refactoring` grove); treating `docs/` as a place at all.

**Central record dirs / `adr/` + `prd/`**:
The two cross-cutting *record* artifacts that resist co-location, kept as small,
single-purpose **top-level** dirs (ADR-0045): `adr/` — the global decision log (a
connected graph crossing every target: supersession chains, later targets citing
earlier ones; global numbering, the sole per-target-flavoured content kept
central) — and `prd/` — human-facing agreement checkpoints. A focused `adr/`/`prd/`
is the deliberate §10 carve-out for record graphs owned by no single domain, *not*
the banned top-level `docs/`.
_Avoid_: co-locating or per-target-renumbering ADRs (severs the cross-target
graph); reading `adr/`/`prd/` as a re-centralized `docs/` tree.

**Process/tooling docs / `process/`**:
Development-process artifacts owned by no domain (completed implementation plans,
the grove/skill design spec) parked at root `process/`. TODO: a later maintenance
pass owns their final home (possibly an external skills repo).
_Avoid_: filing process docs under a domain `docs/` (they document *how we work*,
not a subject).

## Repository domains (refactor structure)

These terms are introduced by the `structural-refactoring` grove, which
re-architects the repo from its *pipeline-phase* shape (`collection/` → `analysis/`
→ `generation/`) into five *domain* partitions (REFACTOR.md §8/§9). The skeleton
node creates the homes; later leaves move material in. While the migration is in
flight the old phase dirs still exist; a term's "lives under" path is the **target**
home unless noted.

**Domain partition**:
The top-level organising axis of the refactored repo: directories partition by
*meaning / role*, not by pipeline phase. The five domains are `semantic/`,
`platforms/`, `apps/`, `targets/`, `schemas/`. These boundaries are load-bearing and
preserved throughout (REFACTOR.md §8).
_Avoid_: "phase" as a structural axis (retired — `collection/`/`analysis/`/
`generation/` are dissolved into the domains); calling any domain a "module".

**`semantic/`**:
The *shared language of meaning* domain — projection-independent source semantics:
the meaning of platform APIs expressed once, first-class multi-API pattern-kinds
(§7.5/§31/§32), relationship entities, and the semantic-graph vocabulary docs.
_Avoid_: putting any target-projection or platform-specific extraction detail here
(those are `targets/` and `platforms/`).

**`platforms/`**:
The *source platform truth* domain — per-platform formal API specs, kept
**projection-free** (§7.1/§45.10). `platforms/macos/` is the only live platform;
`linux/` and `dotnet/` slot in without redesign. A family's spec is the three-stage
**spec triad** `extracted.kdl` → `annotations.apiw` → `resolved.kdl` under `api/<family>/`
(§14; machine `.json` + authored `.apiw` KDL per ADR-0046 as amended by the k17 retreat — see
*Spec format*).
_Avoid_: "platform" meaning the generation destination (that is a *target*); any
target-language detail leaking into a platform spec.

**`apps/`**:
The *common target-independent behavioural exemplars* domain — AppSpec definitions
shared across all targets (`apps/<platform>/<app>/`, §15). Generated apps are
conformance tests, not demos (§7.8). Target *implementations* live under
`targets/<t>/app-implementations/<platform>/<app>/`, never here.
_Avoid_: putting any target-specific app code under `apps/` (that is an
implementation, not a spec).

**`targets/`**:
The *target-language expression and proof* domain — everything specific to one
target: capability profiles, idiom catalogues, policies, native adapters, bindings,
app-implementations, conformance reports, docs (§18). Projection lives here, never
in `platforms/`. The four live target units (`racket`/`chez`/`gerbil`/`sbcl`),
currently at `generation/targets/<name>/`, migrate to `targets/<name>/` as the grove
proceeds (supersedes the *Target* entry's on-disk path above once the move lands).
_Avoid_: a central `tools/` for target machinery (rejected — ADR-0043); re-reading
"target" as "platform".

**`targets/_shared/`**:
The home for cross-target machinery consumed by every target but owned by none — the
shared projection substrate `emit` (with the `naming` acronym table), `stub-launcher`,
and the generate CLI (ADR-0044). The leading underscore is intentional: `_shared`
sorts/reads as *"not a target"*. Hermetic per-target isolation (ADR-0011) governs
generated runtime artifacts, **not** this shared emitter code (ADR-0043 Consequences).
_Avoid_: treating `_shared` as a target (it has no `target.yaml`, no bindings); a
top-level `shared/` (it is domain-placed under `targets/`, not a sixth domain).

**`schemas/`**:
The *formal validation* domain — the schemas validating every artifact (extracted /
annotations / resolved specs, app-kinds, AppSpecs, capability profiles, conformance
reports). The "obvious place for schemas" the success criteria demand (§45.13).
_Avoid_: scattering per-artifact schemas next to each artifact (validation is
centralised here, even though docs co-locate).

**Crate-home convention (`tools/`)**:
Rust crates live under a `tools/` subdirectory of the domain they serve — shared
crates at `<domain>/tools/<crate>/`, per-target crates at `targets/<t>/tools/<crate>/`.
§14/§18 give specs/data homes but none for the Rust code; `tools/` is that addition,
keeping each crate co-located with its subject (ADR-0043) while leaving the `api/`,
`idioms/`, `adapters/`, … data trees clean. One Cargo workspace, distributed members.
_Avoid_: a single central `tools/` at the repo root (rejected — D2/ADR-0043);
splitting the `naming` table *data* out of the `emit` *code* (skeleton over-engineering,
rejected).

## Spec format / data model (refactor workstream 2)

Introduced by the `structural-refactoring` grove, workstream 2 (`spec-format-k16`),
replacing the JSON enriched IR. Settled 2026-06-24: ADR-0046 (format), ADR-0047 (conventions),
PRD `prd/2026-06-24-spec-format-data-model.md`. **Implemented** by `pipeline-cutover-k20`: the
live pipeline reads/writes the per-family triad (collect→`extracted.kdl`; analyze runs the
in-process `linked`→annotate→enrich passes folding in `annotations.apiw`→`resolved.kdl`;
generate consumes `resolved.kdl`). Remaining child leaf: `conventions-datalog-k21` (retire
imperative `heuristics.rs` for ascent rules, ADR-0047).

**Spec triad**:
The three per-API-family files under `platforms/macos/api/<Framework>/` (REFACTOR §14):
`extracted.kdl` (mechanical extraction facts — the datalog fact base), `annotations.apiw` (the
**one** authored semantic overlay — manual + accepted-LLM), and `resolved.kdl` (the
deterministic merged graph; the generator input, ≈ the retired `enriched`). Replaces today's four
JSON checkpoints with **one** per-family triad; the intermediate stages stay in-process, not on
disk. **All three are now KDL 2.0** — the ws8 spike (`machine-format-spike-k150`) measured the
*non-preserving* machine codec k17 never tested and the machine IR **un-retreated to KDL** (D3 GO,
2026-07-04; recorded in ADR-0046 §5, amended in place — the k17 no-go reversed on the ws8 spike).
Machine-side implemented by the ws8 codec cutover (`machine-kdl-codec-k152`); one format, one
schema language.
_Avoid_: the `.yaml` filenames of §14 (superseded); `extracted.json`/`resolved.json` (the machine
side un-retreated to KDL at ws8 — that JSON was the transient k17→ws8 state); calling `resolved.kdl`
the "enriched IR" (that term is retired).

**KDL interchange / `.apiw`** _(KDL everywhere again, post-ws8)_:
The interchange format (ADR-0046; machine side amended in place at ws8): **KDL 2.0 everywhere** — the
**authored** overlay (`.apiw`) *and* the **machine** artifacts (`extracted.kdl`/`resolved.kdl`).
The authored overlay uses the format-preserving `kdl` crate (authoring eval backs it,
`semantic/docs/research/2026-06-24-kdl-authoring-eval/`; diagnostics matter). The machine IR uses a
hand-written **non-preserving JiK codec** over `serde_json::Value` (ADR-0046 §5; homed in
`semantic/tools/spec-format`) — the k17 ~80–100× tax was the *format-preserving document model*, not
KDL; the non-preserving codec runs at ~1.3× raw / ~2.4–3.2× typed (spike
`2026-07-04-kdl-machine-codec-spike/`). No YAML anywhere.
_Avoid_: "the machine IR is JSON" (that was the transient k17→ws8 state — un-retreated to KDL, ADR-0046 §5); "KDL is too
slow for the machine IR" (that was the *document-model* crate; the machine codec is non-preserving);
"the YAML interchange" (§29's YAML was reversed); "a YAML dialect" (`.apiw` is KDL, not YAML).

**Schema contract (`annotations.kdl-schema`)** _(authored overlay only; ws2 owns it)_:
The authoritative, **language-neutral** contract for the authored `.apiw` overlay, written in the
**KDL Schema Language** (KDL-in-KDL) at `schemas/spec-format/annotations.kdl-schema` (ADR-0046 §3,
`kdl-schema-k19`). The Rust serde types are *one conforming implementation*, not the source of
truth; any KDL tool in any language validates an `.apiw` file against it. There is **no maintained
KDL-2.0 schema validator** (the language is frozen at SCHEMA-SPEC 1.0), so the `spec-format` crate
ships a focused in-crate validator of the contract's subset as the §29 validator step. The machine
`extracted.kdl`/`resolved.kdl` get a **machine KDL-Schema** (ws8 `machine-kdl-schema-k153`) validated
by the **same generic engine** (`apianyware_spec_format::validate_against_schema`) — the
machine-JSON-Schema seam every prior workstream deferred to ws8 **dissolved** when the machine IR became KDL (ADR-0046 §5; one schema
language). ws8 also owns the single tree-walking validation command (`apianyware-validate`, homed at
`schemas/tools/validate/`) + `make validate`; CI is deferred (none exists). AppSpec is **not** ws8's
(ADR-0052 — external format, owns its own validation).
_Avoid_: deriving the contract from the Rust types (types conform to the schema, not vice-versa);
"a machine JSON Schema" (the machine IR is KDL, ADR-0046 §5, so its schema is a
KDL-Schema); putting the `.apiw` schema or its validator in ws8 (ws2 owns the `.apiw` schema +
validator step; ws8 owns the machine schema + the umbrella).

**`linked` (datalog stage)** _(rename, replacing the colliding "resolved" stage)_:
The in-process datalog cross-reference stage (cross-class/protocol linking + convention rules),
formerly confusingly also called *"resolved"* (`analysis/ir/resolved`). Renamed `linked` so the
word **resolved** carries exactly one meaning: `resolved.kdl`, the final merged generator input.
_Avoid_: "resolved" for the datalog linking stage (the collision ADR-0046 retires).

**Convention rule (datalog)**:
A "platform convention rule" (§28's precedence tier) expressed as a declarative compile-time
`ascent` datalog rule over `extracted.kdl`, replacing the imperative `annotate/heuristics.rs`
(ADR-0047). Same engine as resolution/ownership inference. Its derived facts land in
`resolved.kdl` stamped `source="convention:<rule>"` — datalog's derivation trace **is** the
provenance.
_Avoid_: "heuristic classifier" (the retired imperative form); a runtime-loaded rule DSL
(compile-time ascent — runtime is a deferred enhancement).

**Provenance stamp / precedence / confidence** _(carried in-format; workflow is ws5)_:
The data model's record of *where a fact came from and who won*. Every `resolved.kdl` fact has a
`source ∈ {extraction, convention:<rule>, llm, manual}`; authored facts add `confidence`
(enum **`high|medium|low`**, not a float) + `provenance` (doc URL/rationale). Precedence
(`manual > accepted-LLM > convention > extraction > unknown`, §28) is applied in resolve — the
winner stamped, losers kept as a `superseded-by` record; a fact with no producer is explicit
`unknown`. The *format* carries this (ws2); the caching/regeneration/review-accept/diff
*workflow* is ws5.
_Avoid_: a float confidence (false precision — enum chosen); a separate provenance store keyed
to facts (it is in-format); silently defaulting an unknown (it stays explicit).

## Validation (refactor workstream 8)

Introduced by the `structural-refactoring` grove, workstream 8 (`schema-validation-k149`).
"Formal validation of every artifact" (root BRIEF #8), settled around **ADR-0046 §5** and the
node running log **D4–D8/D10**. Model prose: `schemas/docs/validation-model.md`.

**One schema language, one engine**:
Every schema in `schemas/spec-format/` (all thirteen) is **KDL Schema Language** (KDL-in-KDL) and
every validator delegates to **one** generic engine, `apianyware_spec_format::validate_against_schema`
(homed in `semantic/tools/spec-format`). No JSON Schema anywhere — the machine-JSON-Schema seam
ws2–ws6 deferred to ws8 **dissolved** when the machine IR un-retreated to KDL (ADR-0046 §5).
_Avoid_: "a machine JSON Schema" / "JSON Schema over a JSON projection" (rejected, ADR-0046 §3 —
one language); calling any producing crate's validator the source of truth (the schema is the
contract; serde types conform to it).

**Validation umbrella / `apianyware-validate`** _(the one command; `validate-umbrella-k154`, D6)_:
The single tree-walking validation command, homed at the crate `schemas/tools/validate/`. A **lean
driver** — it embeds no schema and re-implements no validation; it dispatches every authored `.apiw`
to its producing crate's validator and reports per-class. **Coverage-as-a-guard**: any `.apiw` that
matches no known layout is a **failure** (exit 1, "unclassified"), so a new artifact type can't
silently escape validation. Wired to **`make validate`**. Exit codes: 0 clean · 1 failure or
unclassified · 2 usage/precondition.
_Avoid_: "the umbrella re-validates" (it delegates); putting the generic *engine* in
`schemas/tools/validate` (the engine is a semantic-domain concern in `spec-format`; the umbrella is
a driver).

**Three validation layers** _(complementary, deliberately overlapping)_:
(1) the `apianyware-validate` **umbrella** (runnable driver, `make validate`); (2) the per-crate
**`tests/*_registry.rs`** guards (the `cargo test` face — each crate loads + validates every real
authored file of its class); (3) **`lint-annotations`** (`apianyware-analyze annotations
stale|audit`, ADR-0050 §5) — the overlay **drift** gate, freshness not validity. Validation runs
**locally** (`make` + `cargo test`); **CI is deferred** — `.github/workflows/` is absent (D5).
_Avoid_: "CI validates the schemas" (no CI exists — deferred, net-new infra); conflating
`lint-annotations` freshness with schema validity (orthogonal — an overlay can be schema-valid and
stale).

**Authored vs. machine validation** _(the opt-in split; D10)_:
Authored `.apiw` (committed, closed content model) is validated **by default** — fast, zero
precondition, fresh-checkout-friendly. The **machine IR** (`extracted.kdl`/`resolved.kdl`, derived +
gitignored, **open** content model) is validated **only under `--machine`** (opt-in) because it runs
on the format-preserving `kdl` parser (~2 s/MB → minutes-scale on the materialized corpus; a
flattened `resolved.kdl` can exceed 80 MB); `--machine` validates authored **+** machine in one run,
streams cheapest-first, and errors (exit 2) with a "run the pipeline first" precondition when the IR
is absent. **Deferred trigger** (D10): a `serde_json::Value`-based engine reusing the schema *model*
would cut machine validation ~50× — build only if `--machine` wall-time is ever felt (mirrors D4's
native-serde-JiK deferral).
_Avoid_: running `--machine` in `make validate` (it must stay fast); "the machine IR is un-validated"
(it is — on opt-in).

**Derived reports stay on-demand** _(D8)_:
ws8 schemas the machine **IR** (stable core data model) but **not** ad-hoc derived reports —
conformance coverage + capability/representability stay **derived / uncommitted / un-schema'd**
(constraint 4; ws6/ws7 point at the report). Only conformance's *authored judgment slice*
(`conformance.apiw`) has a schema; the derived slice is computed on demand by `apianyware-conformance`.
**Reopen trigger**: IF a real machine consumer of a report materializes.
_Avoid_: committing or schema-ing a derived report pre-emptively (constraint 4 — recompute it).

## Semantic model (refactor workstream 3)

Introduced by the `structural-refactoring` grove, workstream 3 (`semantic-model-k27`):
patterns and relationships as **first-class semantic entities** under `semantic/`
(REFACTOR §7.5/§12/§31/§32). Design settled 2026-06-25 (ADR-0048, PRD
`prd/2026-06-25-semantic-pattern-kind-model.md`); the build children realize it. The
spine ws2 (spec-format) provides the `.apiw` DSL + triad + provenance machinery this
reuses. Projection stays in `targets/`, never here.

**Pattern-kind** _(the broad first-class entity)_:
A **reusable, framework- and target-independent definition** of a semantic shape —
authored once as `semantic/pattern-kinds/<kind>.apiw`. A kind declares a set of
**roles** and a set of **laws** (constraints). The word is deliberately **broad**: it
covers *both* multi-operation **behavioral contracts** (`bracket`, `builder`,
`observer` — operation-roles + ordering/threading laws, §32) *and* **structural
relationships** (`parent-child`, `callback-destroy-notifier`, collection/element
ownership — type-roles + ownership/lifetime/invalidation laws, §31). A relationship is
the **degenerate pattern-kind**: no operation sequence, just typed endpoints and their
ownership/invalidation laws (decision D4 — relationships fold *into* pattern-kinds, not
a sibling entity). The 10 legacy `PatternStereotype` Rust enum variants become this
*authored data registry* (D2), no longer a closed enum.
_Avoid_: "pattern" alone (ambiguous with an *instance*); "stereotype" (the retired
closed-enum framing); a separate "relationship entity" (D4 dissolved that — §31's
relationships are pattern-kinds); reading "pattern-kind" as only-behavioral (it covers
typed edges too).

**Pattern-instance**:
A **concrete occurrence** of a pattern-kind in a specific framework — it binds the
kind's roles to concrete **participants** and carries the ADR-0046 §4 provenance stamp
(`source`/`confidence`/`provenance`). An instance is **platform knowledge**, so it
lives in the **platform spec triad** (`platforms/macos/api/<Framework>/resolved.kdl`),
*not* in `semantic/` (decision D1 — the two-level kind/instance split that keeps
`semantic/` projection-AND-platform-independent). Produced by three precedence tiers —
**convention** (datalog detection, D3), **llm**, **manual** — resolved by the ws2
precedence `manual > llm > convention > extraction` (D2). Supersedes the old
`Framework.api_patterns: Vec<ApiPattern>` IR list.
_Avoid_: storing an instance under `semantic/pattern-kinds/` (a binding to NSView is
macOS knowledge — D1); "pattern-kind" for an instance (the kind is the reusable
definition, the instance is the concrete binding).

**Role / participant**:
A pattern-kind declares **roles** (e.g. `bracket`'s `acquire`/`release`/`operation`).
A role's `binds` fixes *what kind* of participant fills it at instance time, drawn from
**{type, operation/selector, parameter, another pattern-instance-ref}**. The **parameter**
binding lets a role address one operation's *parameter* — a single-operation-scoped
relationship like `callback-destroy-notifier`, whose `callback`/`user-data`/`destroy`
roles all bind to params of one register call (DP2). The **pattern-instance-ref** binding
is how §32's "patterns compose operations **plus relationships**" is realized (decision
D5): a `subscription` instance binds its `destroy` role to a `callback-destroy-notifier`
relationship-*instance*. Each role also carries a **cardinality** (`1`/`?`/`*`/`+`). One
schema serves both behavioral and structural kinds — the difference is only *which* roles
(operation- vs type-/parameter-) and *which* laws a kind declares.
_Avoid_: participants being only types+operations (they also admit parameters and
pattern-instance refs — DP2/D5); "compose" meaning a separate relationship entity
(relationships are pattern-instances a role binds to).

**Law / controlled vocabulary** _(the DP1 spine)_:
A pattern-kind's constraints are **laws**, and a law is **not free prose**: it names a
`category` and asserts one or more `token`s drawn from that category's **controlled
vocabulary** — REFACTOR **§30**'s enumerated "source semantic weirdness" sets (ownership /
lifetime / threading / error / callback / buffer / relationship). That controlled-token
discipline is what keeps the registry **non-vacuous** (doubt-pass DP1); a free-text `doc`
field carries only nuance the tokens cannot. Behavioral sequencing is a separate
**`ordering`** construct (a happens-before graph over role names), present on behavioral
kinds, absent on structural relationships. The §30 tables live in
`apianyware-patterns::vocab`; the focused validator enforces token∈category (the KDL
Schema cannot state a conditional enum — ADR-0046 §3 / ADR-0048 D7).
_Avoid_: re-introducing free-prose laws (DP1 forbids it); inventing tokens outside §30;
treating `ordering` as a law (it is a distinct, role-referencing construct).

**Convention-tier pattern detection** _(datalog; D3 — realized, `apianyware-pattern-detection`, ws3 child 3)_:
The cheap structural producer of pattern-*instances* — the (retired) imperative
`detect_patterns` re-expressed as **`ascent` datalog rules** (the same engine + the
ADR-0047 precedent that put Cocoa naming heuristics in `platforms/macos/tools/`,
*not* shared `semantic/tools/datalog` which holds only the engine). Each derived
tuple names the rule that produced it, so the `source=convention` + `convention:<rule>`
provenance falls out of the derivation trace. Detection is Cocoa-specific → lives in
the **`apianyware-pattern-detection` crate** (`platforms/macos/tools/pattern-detection`,
beside `conventions`). Five detectors (factory-cluster, observer, paired-state, delegate,
bracket) bind the authored kinds' roles, then each instance is content-id'd (DP4),
home-resolved (DP3) and **registry-validated** at the producer (an ill-formed instance —
e.g. a class cluster with no public factory class methods — is dropped, not emitted).
The CLI (`apianyware-analyze`) loads the kind registry once (`--pattern-kinds-dir`) and
populates `Framework.patterns` per family. No consumer projects instances yet (ws6), so
emit goldens are unmoved.
_Avoid_: imperative `detect_patterns` as the mechanism (retired into datalog, D3); a
shared `semantic/tools` home for the *rules* (the engine is shared, the Cocoa rules are
platform-specific — the ADR-0047 split).

**Pattern-model crate homes** _(D8 / the ws3 seam)_:
A **new `semantic/tools/patterns` crate** owns the pattern-kind **registry** + `.apiw`
parsing (a dedicated home for the pattern-model code, diverging from folding into
`spec-format`). Instance **detection** is datalog in the `apianyware-pattern-detection`
crate (`platforms/macos/tools/pattern-detection`, beside `conventions`; D3); instance
**carriage** extends `types` + `resolve`. ws3 authors the pattern-kind
**`.apiw` KDL Schema** + a focused in-crate validator
(`schemas/spec-format/pattern-kinds.kdl-schema`, D7, mirroring ws2's
`annotations.kdl-schema`); ws8 owns the machine JSON Schema + validation tooling/CI. The
per-fact provenance *workflow* (cache/regen/review/diff/precedence-audit) is **ws5's**,
not ws3's — ws3 defines the carriage only (D6, mirroring the k26 seam).
_Avoid_: folding the kind registry into `spec-format` (D8 chose a dedicated crate);
ws3 building the provenance workflow (that is ws5); ws3 authoring the machine JSON
Schema (that is ws8).

## Platform model (refactor workstream 4)

Introduced by the `structural-refactoring` grove, workstream 4 (`platform-model-k32`):
the macOS **source-platform** truth under `platforms/macos/` (REFACTOR §13/§14) — the
platform manifest, app-kinds, and platform-level semantic tests, built *around* the
per-family API triad ws2 already relocated there. Platform truth is **projection-free**
(the domain rule): it states what the macOS API *means*, never how a target expresses
it. Design settled 2026-06-25 (running log in the `platform-model-k32` brief).

**Platform spec**:
The whole `platforms/<platform>/` body of source truth for one platform — for macOS:
the `platform.apiw` manifest, the per-family API triad under `api/<Framework>/`, the
`app-kinds/`, and the `tests/`. States types/operations/ownership/lifetimes/threading/
errors/callbacks/patterns/app-kinds (REFACTOR §13) and **must not** state projection
(no "generate Rust Drop"). The shape is platform-neutral — `platforms/linux/` and
`platforms/dotnet/` reuse it without redesign (§45.8).
_Avoid_: putting any target/projection statement under `platforms/` (that is `targets/`,
ws6); "the IR" (the spec is the triad + manifest + app-kinds + tests, not just IR).

**Platform manifest** _(`platforms/macos/platform.apiw`; D1)_:
The single **authored** policy file describing the platform *itself* — `sdk`,
`deployment-target` floor, and the framework roster as a curated **include/ignore
policy** (the ignore-list is an authored decision). KDL (`.apiw`), **not** `platform.yaml`
— REFACTOR §14's literal name predates ADR-0046's no-YAML retreat (authored overlays are
`.apiw`, machine files JSON). The **resolved** framework roster and the cross-family
**dependency graph** are *derived and uncommitted* — recomputable from `api/`, so not
materialized (constraint 4).
_Avoid_: `platform.yaml` (YAML is dead — ADR-0046); committing the resolved roster or
dep-graph (derived); putting per-family facts here (those are the `api/<F>/` triad).

**App-kind** _(`platforms/macos/app-kinds/<kind>/kind.apiw`; D2)_:
A **kind of macOS application** a target can be asked to build (`cli-tool`, `gui-app`,
`menu-bar-daemon`, `launch-agent`, `spotlight-importer`, `quicklook-extension`,
`finder-sync-extension`) — **platform process-model truth**: entry/run-loop/termination
model, bundle type + required Info.plist keys + `LSUIElement`/extension-point identifiers,
and test-obligation references. A **distinct entity** with its own authored `.apiw`
registry, parsed by the new `platforms/macos/tools/app-kinds` crate (crate-home
convention; *mirrors* the `apianyware-patterns` mechanism, not its entity). **Zero
projection.** Relationship axis: the app-kind is the platform *category*; a ws7 **app-spec**
(`apps/macos/<app>/`) *names* its kind (category↔instance); **pattern-kinds** (ws3,
`semantic/`) are an orthogonal *API-usage* axis sharing only the authored-registry
mechanism.
_Avoid_: confusing app-kind (platform category, `platforms/`) with app-spec (one concrete
app, `apps/`) or with pattern-kind (API-usage shape, `semantic/`); any projection in
`kind.apiw`; folding app-kinds into the `apianyware-patterns` crate (domain violation —
platform truth stays in `platforms/`).
_Realized_ (`mechanism-k35`; **ADR-0049**, contract `schemas/spec-format/app-kind.kdl-schema`):
`kind.apiw` carries a `process` block (`entry` ∈ {`c-main`, `ns-application-main`,
`host-loaded`} · `run-loop` ∈ {`none`, `ns-application`, `cf-run-loop`, `host-driven`} ·
`termination` ∈ {`return`, `ns-application-terminate`, `signal`, `host-controlled`}), an
`activation` policy ∈ {`regular`, `accessory`=`LSUIElement`, `background`=`LSBackgroundOnly`,
`hosted`}, a `bundle` ∈ {`none`, `app`, `mdimporter`, `appex`} (with optional
`package-type` / `principal-class-key` / `extension-point` / `info-plist { require … }`),
and `test-obligation` refs. These are **flat enums** → expressed as schema `enum`s + serde
enums (unlike a pattern law's category-conditional tokens — no side `vocab` table); the
focused validator adds only cross-field semantics (`none` carries no bundle metadata;
`extension-point` ⟹ hosted bundle; `require`/`obligation` uniqueness). **Identity is the
containing directory** (every file is `kind.apiw`, so the loader checks `app-kind "<name>"`
= dir name, not file stem). **All seven kinds authored** (`gui-app` exemplar in
`mechanism-k35`; the other six in `remaining-kinds-k36`) — spanning standalone programs
(`cli-tool`/`launch-agent` bare `none`; `gui-app`/`menu-bar-daemon` `.app`, the latter an
`accessory` `LSUIElement`) and hosted plug-ins (`spotlight-importer` a legacy `.mdimporter`
CFPlugIn — C factory, no principal class; `quicklook-extension`/`finder-sync-extension`
NSExtension `.appex`, `XPC!`). The grammar absorbed all six with **no** crate/schema change.

**Platform-semantic test / expectation declaration** _(`platforms/macos/tests/`; D3)_:
An **authored, projection-free, target-independent** statement of what a macOS API
semantic must hold — `tests/api-semantics/{ownership,callbacks,threading,errors}.apiw`,
per-app-kind obligations `tests/app-kinds/<kind>.apiw` — plus raw **fixtures**
(`tests/fixtures/{pasteboard,spotlight,sample-documents,sample-images}/`). ws4 **authors
+ schema-validates** these (goldens-green) but does **not execute** them; the multi-layer
test *model* (§33), the runner, and TestAnyware/AppSpec *execution* (§34) are **ws9**
(per-target hooks ws6) — the declare-now / execute-later seam (mirrors ws3→ws8).
_Avoid_: building a runner under `platforms/` (execution is ws9); target-specific
expectations (declarations are platform truth — target-independent). The two families
are **distinct entities sharing one mechanism** (D6, ADR-0049): two sibling KDL-Schemas
(`app-kind-tests.kdl-schema`, `api-semantics.kdl-schema`) + two submodules
(`src/app_kind_tests/`, `src/api_semantics/`) in **one crate**
(`apianyware-platform-tests`).

**api-semantics declaration** _(`tests/api-semantics/<facet>.apiw`; `api-semantics-k40`)_:
One file per **convention facet** (the four `apianyware-conventions` maps:
`ownership` ↔ ParamOwnership, `callbacks` ↔ BlockParamAnnotation, `threading`, `errors`);
**facet = file stem**, a flat schema `enum`. Grammar: `api-semantics "<facet>"` ⟶
`api "<receiver>" "<selector>"` (a concrete Foundation/AppKit shape) ⟶ `weirdness "<tag>"`
(≥1) + `expect "<id>" { doc }` (≥1). The **`weirdness` tag** is a §30 source-semantic
weirdness term whose allowed set is **facet-conditional** (ownership unions §30 ownership +
lifetime; the others map 1:1; §30 buffer/relationship are out of scope — no convention
facet). Because KDL-Schema cannot state a conditional enum, `weirdness` is a plain string
in the schema and a **focused validator vocab** (`api_semantics::vocab`, an own §30 token
table kept in lockstep with REFACTOR §30 — *not* reused from `apianyware-patterns`, the
domain rule) enforces per-facet membership — the **category-conditional** controlled-vocab
shape (cf. `pattern-kinds.kdl-schema` law tokens), in contrast to the app-kind flat enums.
The §30 weirdness is the platform truth **ws6 consumes** to compute representability; it is
never itself a status. _Avoid_: putting `weirdness` in the schema as an `enum`
(facet-conditional → semantic check); a representability status here (ws6/§20).

> Representability note (D4): the §7.7 statuses (`fully-`/`conventionally-`/
> `lossily-represented`, `unsafe-only`, `unsupported`, `research`) are per
> **target×platform** → **ws6/§20**, *not* ws4. ws4 carries only the §30 **source
> weirdness** vocabulary (`fork-unsafe`, `may-reenter`, `ownership-unknown`, …) that ws6
> *consumes* to compute a status. No representability metadata lives in `platforms/`.

## LLM side-channel workflow (refactor workstream 5)

Introduced by the `structural-refactoring` grove, workstream 5 (`llm-side-channel-k43`):
the *operating layer* over the per-family `annotations.apiw` overlay that makes
LLM-produced semantic facts cached / regenerable / diffable / reviewable /
provenance-tracked / confidence-scored, and realizes the ADR-0046 §4 fact-precedence /
disagreement audit. Design settled 2026-06-25 (ADR-0050; running log in the
`llm-side-channel-k43` node brief). **The overlay is already a git-committed `.apiw` text
file**, so *diffable* / *reviewable* / *accept* are delivered by git + the KDL format;
ws5 builds only the genuinely-new layer (the provenance/precedence mechanism + staleness
detection + reworked orchestration), **not** a bespoke staging/cache subsystem (ADR-0050).

**Side-channel workflow** _(the ws5 deliverable)_:
The lean mechanism over the committed overlay: (1) the resolve-time **disagreement audit**
(below), (2) a **staleness** detector + **regeneration** worklist, (3) Claude-Code-subagent
**orchestration** that authors `.apiw` directly, (4) reworked/retired legacy tooling. Lives
in the **platforms** domain (annotations are platform knowledge) — extends
`platforms/macos/tools/annotate` + `apianyware-analyze` subcommands, never `semantic/`.
_Avoid_: a staging area distinct from the committed overlay; a propose/accept *state machine*
(git is the accept boundary — below); an external-provider LLM flow (economic constraint —
annotation runs in Claude Code subagents, [[llm_annotation_constraint]]); re-reshaping the
side-channel (ws2's `pipeline-cutover-k20` already did the `*.llm.json`→`annotations.apiw` move).

**Authored-overlay source vs resolved source** _(two vocabularies, two homes)_:
The **overlay** (`annotations.apiw`, committed) carries only **authored** tiers —
`source ∈ {llm, manual}`. The **resolved graph** (`resolved.kdl`, derived + gitignored)
carries the **full ladder** — `source ∈ {extraction, convention:<rule>, llm, manual, unknown}`
— after the disagreement audit. The `AnnotationSource` Rust enum (ws5 `provenance-vocab-k44`)
reconciles to this: `Heuristic`→`Convention` (gaining a `<rule>` payload when per-fact
convention stamps land), `HumanReviewed`→`Manual`, `Llm` unchanged; `Extraction`/`Unknown`
added by the children that produce them. Per-fact provenance is **emit-invisible** (emit
projects the *facts*, never their `source`) — the goldens-as-truth safety invariant for the
whole rollout.
_Avoid_: the legacy spellings `heuristic`/`human_reviewed` (ADR-0046 §4 vocab is
`convention`/`manual`); `convention`/`extraction`/`unknown` tokens in the *overlay* (those
are resolved-side only); a float confidence (enum `high|medium|low`, ws2).

**accepted-LLM** _(≡ a committed `source llm` fact)_:
The §28 precedence tier above `convention` but below `manual`. There is **no separate
proposed/accepted on-disk state**: an LLM fact in a *committed* overlay **is** accepted (the
human accepted it by committing the `git diff`); an unreviewed fact lives only in the working
tree / a PR branch. Git is the propose→review→accept boundary (ADR-0050).
_Avoid_: a `status proposed|accepted` flag (git carries it); reading `accepted-LLM` as a
distinct *source* value (it is just committed `llm`).

**Disagreement audit / `superseded-by`** _(ADR-0046 §4; realized by ws5 `precedence-audit-k45`)_:
The resolve-time merge: per `(receiver, selector)` **fact-slot** (one semantic claim — a
param's ownership, a method's threading, etc.), gather every producing tier, apply §28
precedence (`manual > accepted-LLM > convention > extraction > unknown`), **stamp the
winner's `source`** on the resolved fact, and record each *disagreeing* loser as a
`superseded-by { source; value }` entry. A fact-slot with no producer stays **explicit
`unknown`** (never silently defaulted). Lands in `resolved.kdl` only; emit-invisible →
goldens unmoved. Surfaced by the `annotations audit` report (ws5 `disagreement-report`).
**Realized carriage** (`apianyware_types::annotation`): a resolved-only
`MethodAnnotation.fact_provenance: Option<MethodFactProvenance>` — one `SlotProvenance
{ param_index?, source, rules, superseded_by: Vec<SupersededFact{source,value}> }` per producing
slot (ownership/block keyed by `param_index`, threading/error method-level). `rules` carries the
winner's `convention:<rule>` stamp(s) (empty for non-convention winners). The winner is chosen by
`AnnotationSource::precedence()` (lower rank wins). The legacy `AnnotationDisagreement`/`compare_annotations`
record is retired in its favour. Two realized nuances: (i) a **fact-less method** carries
method-level `source = Unknown` (not a silent `Convention`); (ii) blocks stay **all-or-nothing**
(a non-empty overlay block list replaces convention's wholesale — golden-neutral), so a convention
block on a param the overlay omits is dropped with **no** `superseded-by` slot (no winning fact to attach to).
_Avoid_: writing the audit into the overlay (it is derived → resolved.kdl); dropping a
loser that merely *agrees* (only disagreements are `superseded-by`); a winning *value* change
(precedence here only stamps provenance — the winning value already matches today's merge, so
goldens cannot move).

**Staleness / regeneration** _(replaces `check-llm-annotation-drift.sh`; ws5 `staleness-regen-k46`)_:
Staleness is computed **live** by set-diffing a family's committed overlay against the current
**resolved API surface** (`resolved.kdl`) — **no stored hash** (artifacts-not-state). The
comparison surface is the *resolved* graph, **not** raw `extracted.kdl`: the overlay is
authored over the inheritance-flattened / protocol-conformance-flattened / Swift-renamed surface
(the LLM is dispatched over `all_methods`), so a naive diff vs pre-resolve `extracted.kdl`
mis-reports ~⅓ of facts as orphaned (k46 found this — a fact under the *subclass* `NSBlockOperation`
for a method declared on `NSOperation`; `FileManager` vs `NSFileManager`). `resolved.kdl` is
self-contained (its `all_methods` carry the cross-framework closure), so the check is a pure file
read — **no resolve pass, no dep loading** — but `resolved.kdl` must be current (run resolve
first). Three signals: *orphaned* (overlay fact names a `(receiver, selector)` absent from the
current surface), *new-surface* (a current method with an **annotatable shape** and no overlay
fact), *shape-changed* (an overlay fact's targeted `param_index` no longer holds its kind — block /
object). **Annotatable shape** = the *structural* predicate, a **block param** or an **`NSError **`
out-param** (`apianyware_annotate::surface::is_annotatable`) — the shapes the LLM reliably
annotates; the `delegate`/`observer` **selector substring** is excluded (accessor getters the LLM
declines, ~75% steady-state noise). Surfaced by `apianyware-analyze annotations stale [--only F,…]
[--json]` (exit 1 iff any family stale → it gates). Regeneration = dispatch Claude-Code subagents
for the stale families only (annotate runs *once per SDK update*, k26); each subagent writes that
family's `annotations.apiw` directly.
_Avoid_: diffing against `extracted.kdl` (pre-resolve → false orphans); a content-hash cache
store (set-diff is cheap, stores nothing); auto-regenerating on every pipeline run (regeneration
is explicit, post-SDK-bump); the retired `_llm-annotations/` + `analysis/ir/` paths.

## Target model (refactor workstream 6)

Introduced by the `structural-refactoring` grove, workstream 6 (`target-model-k50`): the
authored **target-model knowledge layer** under `targets/<t>/` (REFACTOR §17–§27, §37) over
the four already-built, VM-verified bindings (racket/chez/gerbil/sbcl) — capability profiles,
idiom catalogues, projection policies, adapter specs, conformance reports, and mapping docs.
ws6 is the great **consumer**: it projects ws3 pattern-kinds (via `emit/pattern_dispatch`),
projects ws4 app-kinds to concrete builds, and reads the ws4 §30 source-weirdness + ws5
per-fact provenance — it *authors none of those*. Its one new surface is **projection +
representability** (the projection-lives-in-`targets` domain rule). Design settled 2026-06-25
(running log in the `target-model-k50` node brief).

**Target model**:
The whole `targets/<t>/` body of target-language expression + proof for one implementation —
the `target.apiw` descriptor, `capability.apiw` profile, `idioms/`, `policies/<platform>/`,
`adapters/<platform>/spec.apiw`, `conformance/<platform>.apiw`, the mapping/overview docs, and
the *already-present* `adapters/` native code + `bindings/` + `app-implementations/` + emit/bundle
`tools/`. Projection lives **here**, never in `platforms/` (§45.10). The **authored** layer is the
ws6 deliverable; the binding code itself was built by the four target groves.
_Avoid_: putting any target/projection statement under `platforms/` or `semantic/` (the domain
rule — those stay target-independent); treating ws6 as *re-porting* the bindings (it adds the
authored knowledge layer over them).

**Target descriptor** _(`targets/<t>/target.apiw`; authored; D4)_:
The §17 per-implementation model — `family` / `dialect` / `implementation` / `ffi-backend` /
`runtime-model` / `projection-policy` / `adapter-strategy` as authored facets (e.g. sbcl:
`common-lisp` / `ansi-cl` / `sbcl` / `sb-alien` / `image-dump` / …). `targets/<t>/` **is one
implementation**; the directory is flat and no `implementations/` subdir is materialized until a
*second* impl of one language lands (lazy). Family grouping (the CL-family contract) is the
`family` facet + the `_shared` family doc — **not** a `targets/<family>/<impl>/` directory.
_Avoid_: `target.yaml` (YAML is dead — ADR-0046); a per-impl subdir for a single impl (§18's
`implementations/` sketch, not materialized yet); renaming dirs to family/impl.

**Capability profile** _(`targets/<t>/capability.apiw`; authored; platform-INDEPENDENT; D2)_:
The §20 statement of what an implementation **can express**, as an authored map from a **§20
capability dimension** (a shared controlled vocabulary in `targets/_shared` —
`foreign-thread-callbacks`, `struct-by-value`, `deterministic-cleanup`, …) → a **representability
ladder** rung. Describes the *implementation*, so it is reusable across platforms. Has **two
faces**: per-API *semantic* capabilities (feed representability) and §36 *app-form* capabilities
(`packaging`/`app-bundle`/`plugin`/`sandboxing`/`native-runtime-embedding` — feed per-app-kind
feasibility, not per-API representability).
_Avoid_: keying the profile on macOS §30 weirdness tags (couples intrinsic capability to one
platform — rejected); committing a per-API status here (that is *derived* — below).

**Representability ladder** _(the unified §20/§7.7 vocabulary; D2)_:
One **7-rung** ladder collapsing §20's "levels" and §7.7's "statuses" (the same ladder under two
names): `exact-static` (≡ fully-represented) > `exact-runtime` (≡ runtime-represented) >
`idiomatic-conventional` (≡ conventionally-represented) > `lossy-but-documented` (≡
lossily-represented) > `unsafe-only` > `not-representable` (≡ unsupported) > `research`.
_Avoid_: maintaining §20 levels and §7.7 statuses as two separate enums with a translation table
(they always move together — one ladder).

**Representability status** _(DERIVED, uncommitted; per target×platform×API; D1/D2)_:
The §7.7 per-API rung, **computed not authored**: `status(api, target) =` the worst (lowest) ladder
rung over `{ profile[needs(w)] : w ∈ platform.weirdness(api) }`, where `needs` is the shared,
target-independent **`weirdness → capability` map** (`may-reenter → foreign-thread-callbacks`) and
`platform.weirdness(api)` is the ws4 §30 source-weirdness the api-semantics declarations carry. An
API with **no** authored weirdness tag defaults to `exact-static`/fully-represented — the
**trampoline-elision limit** (the directly-reachable ObjC surface is fully represented; only the
weird / Swift-native residual drops down the ladder). Cheap → computed on demand, stays
uncommitted (constraint 4).
_Avoid_: committing the per-API status (derivable → rots against SDK/binding drift); authoring it
in `platforms/` (the §30 weirdness is platform truth, but the *status* is ws6 — the ws4 D4 line).

**Idiom catalogue + the `pattern_dispatch` seam** _(`targets/<t>/idioms/catalogue.apiw`; authored; D3; child `idioms-k53`)_:
The §21 source-concept → target-construct catalogue, **one file per target** keyed by a §21 idiom
**category** (a shared 25-token vocab in `targets/_shared` `vocab.rs`, lockstep with REFACTOR §21 —
like the capability dimensions, validator-enforced not a schema enum). Each `idiom "<category>"`
authors this target's `construct` (open prose, grounded in the target's shipped idiom) and — for the
minority of categories with an emit projection — `projects "<kind>" { emit "<construct>"; name "<id>" }`
mapping a ws3 pattern-**kind** to the closed **`EmitConstruct`** taxonomy + a generated identifier.
**Two axes:** the *source-concept* category (coarse, §21) and the *pattern-kind* projection (finer,
ws3) — one category may project several kinds (`bracketed-use` → `bracket` + `paired-state`). The
catalogue is the **authored data** the shared `emit/pattern_dispatch::classify_pattern` reads: it
keys on a pattern-instance's `kind`, looks up the catalogue's kind→projection index, and renders the
authored `EmitConstruct` + name (a kind no idiom projects → pass-through). The refactor was
**golden-neutral** (`classify_pattern` had zero callers, every emitter pattern-blind — the mapping
moved from a hardcoded Rust match into authored `.apiw`). The eight emit-relevant kinds project
uniform `with-*`/`make-*`/`-sequence` names across the scheme family (they share the convention; the
model permits a future non-Lisp target to author its own). **Applying** projection — emitters
consuming pattern-instances to emit `with-bracket`/`make-foo` wrappers — **moves goldens + needs
per-target VM-verify** and is a clearly-scoped, golden-INTENTIONAL follow-on, not folded in. §21
idiom docs live under `idioms/docs/`.
_Avoid_: leaving the idiom map Rust-baked (D1 — the catalogue is authored `.apiw`); turning on
generation this grove (goldens move — deferred); a target-neutral catalogue (each target authors
its own idioms — the maximize-idiom rule); putting the `EmitConstruct` taxonomy in `emit` (it is
authored target-model data — `emit` depends on `target-model`, never the reverse).

**Projection policy** _(`targets/<t>/policies/<platform>/projection.apiw`; authored; §23; child `policy-adapter-k54`)_:
The per-platform projection *choices* a target makes — "how to map source semantics into target
idioms". **One file per platform** (`policies/macos/projection.apiw`, the idioms-style one-file
partition — the `*.apiw` glob stays open for a future second concern, added lazily). Each
`choice "<concern>"` maps a projection **concern** (an *open* source-shape token —
`directly-reachable-objc`, `swift-native-async`, `escaping-callback`, … — validator-checked for
per-policy uniqueness, no fixed §-vocabulary) to a `spectrum` rung on the closed **§24
direct-call-vs-adapter ladder** (`SpectrumPoint`: `direct-call` > `direct-call-plus-wrapper` >
`adapter-call` > `adapter-call-plus-wrapper` > `unsafe-escape-hatch` > `unsupported-marker` — a
schema `enum`, like the rung ladder, not a vocab). An optional `posture` echoes the descriptor
facet; all four live targets are `thin-direct` (directly-reachable ObjC → `direct-call`, the
trampoline-elision limit; the Swift-native residual → adapter). Projection-bearing → lives in
`targets/`, never `platforms/`. Identity: `projection-policy "<id>"` = the target dir (the file's
**great-grandparent**), `platform` = the parent dir.
_Avoid_: `policies/*.yaml` (YAML dead); any projection statement leaking into `platforms/`;
splitting into multiple files before a second policy concern exists (lazy).

**Adapter spec** _(`targets/<t>/adapters/<platform>/spec.apiw`; authored; §24–26; child `policy-adapter-k54`)_:
The authored description of the *existing* native adapter library (`adapters/<platform>/sources/`,
already built — the spec sits beside the `sources/` it documents). Carries the §24 `output` (the
dylib `library` name + `kind` + `symbol-prefix` — `APIAnywareRacket`/`aw_racket_`, …), the §26
adapter **roles** the library provides (`direct-forwarder`/`callback-adapter`/`thread-adapter`/… —
`ADAPTER_ROLES`, 12 tokens), the §26 runtime **services** it offers (`object-registry`/
`callback-registry`/`main-thread-dispatch`/`autorelease-pool-management`/… — `RUNTIME_SERVICES`, 7
tokens), and the §26 **direct-call policy** (`allow`/`deny` API-category lists, validator-checked
disjoint). Roles + services are **validator vocabularies** kebab-cased from §26's "*suggested*"
extensible underscore lists (not schema enums — §26 grows per target/platform pair); each service
is rated by the closed **`ServiceStatus`** enum (`required` / `parity` / `optional` — e.g. chez's
`callback-registry` is `parity`: exported for cross-target parity, but chez's runtime uses
Scheme-side `lock-object` instead). Per-target richness reflects the real library: racket carries 9
roles, gerbil is **trampoline-only** (3 roles — its callback adaptation lives in the gsc ObjC home,
not this dylib), sbcl carries `reflection-adapter` (SubclassSynth) alone. The *spec* is ws6's
authored layer; the adapter *code* was built by the target grove. Identity: `adapter-spec "<id>"` =
the target dir (the file's **great-grandparent**), `platform` = the parent dir.
_Avoid_: authoring adapter *code* here (it exists); a §25 ABI redesign (the adapters ship a
working ABI — the spec documents it); claiming a role/service the target's dylib does not actually
ship (documentation-of-the-existing, grounded in the `sources/` survey).

**Conformance report** _(`targets/<t>/conformance/<platform>.apiw` + derived; §37)_:
The §37 per-target×platform report — **authored *judgment* slice** (`unsupported` features,
`research` items, `known issues`, the app-kind support call) committed as `.apiw`, plus the
**derived** slice (`API coverage`, common-app-implementation `status`) computed from the generated
bindings + the VM-verify reports already under `bindings/<platform>/reports/`. Statuses per §37 are
the `ConformanceStatus` ladder `pass`/`partial`/`research`/`unsupported`/`failed`/`skipped` (lives in
`derive.rs` beside `Representability`, re-used by the authored model — the capability/`rung` mirror).
Derived *coverage* is the representability histogram over the platform's declared weird-API surface
(reuses the `derive::representability` floor); derived *app status* is `pass` when an
`app-implementations/<platform>/<app>/` port has VM-verify evidence under `reports/<app>/`, else
`partial`. The report-generating CLI is **`apianyware-conformance`** (`targets/_shared/tools/
conformance-cli`; the ws6 consumer wiring the platform api-semantics registry to the targets model,
ADR-0051 §5 seam) — `--json`/`--check` (CI gate). Its **cross-check** confirms each authored
`app-support` `exemplar` app's derived status does not contradict the call (an `unsupported`/`failed`
claim against a VM-verified app, or a `pass` claim against an unverified one). The `binding tests`
field *references* ws9 results; ws6 does not build the runner (per-target execution hooks are ws6's,
the runner is ws9's — the ws4 D3 mirror).
_Avoid_: committing the derived coverage/app-status (recomputable → constraint 4); building the
test runner here (ws9); committing a per-app `status` in the authored slice (it is derived — the
exemplar grouping is the only app-level judgment).

**target-model crate** _(`targets/_shared/tools/target-model`; D5)_:
The single shared, **target-independent** crate that parses + focused-validates every target-model
`.apiw` entity (submodules `descriptor/` `capability/` `idioms/` `policy/` `adapter_spec/`
`conformance/` — the descriptor submodule is `descriptor/`, not `target/`, so the stock Rust
`target/` build-dir gitignore does not swallow its source), holds the shared `vocab.rs` (§20
capability dimensions + `weirdness → capability`
map) and `derive.rs` (representability floor + conformance-coverage derivation). One crate because
the schema is identical across targets; only the authored `.apiw` *data* differs (the ws4
one-crate/submodules `apianyware-platform-tests` precedent). ws6 authors the `.apiw` **KDL Schemas**
(`schemas/spec-format/{target,capability,idioms,policy,adapter-spec,conformance}.kdl-schema`) +
the in-crate validators; **ws8** owns the *machine* JSON Schema + validation tooling/CI.
_Avoid_: per-target target-model crates (4× duplicated machinery — D5); folding the model into
`emit` (a rendering crate consumes the model, not owns it); authoring the machine JSON Schema (ws8).

## App model / AppSpec (refactor workstream 7)

The app layer is **not** a grove-native `.apiw` entity — it is **consumed from an
external sibling project** (ADR-0052, REFACTOR §34). Three layers, three repos:
**TestAnyware** (the VM-automation substrate) → **AppSpec** (the spec/test toolkit +
formats; *holds no app data*) → **APIAnyware** (`apps/macos/<app>/` holds the app
data; `targets/<t>/app-implementations/` holds the implementations).

**AppSpec (the project)** _(the authority — `~/Development/AppSpec`, `Linkuistics/AppSpec`)_:
The external, LLM-driven **spec/test toolkit**: the scenario language (`#lang app-spec`),
the harness / Driver / runner, the (reverse- and forward-) generators, the
`testanyware-sdk`, config + self-tests. *"The single authoritative operational
specification of an app's behaviour, written once and verified against every
implementation end-to-end in a live macOS VM."* APIAnyware **consumes/references** it,
never reinvents it (ADR-0052). Will be *"largely prompts + workflows, not coding of
tools."* **Three colliding "AppSpec" meanings — disambiguate:** (1) **this external
project** [the authority — what "AppSpec" means by default]; (2) the older grove briefs'
loose "the common app-spec entity" use → now read as *"the app's AppSpec data under
`apps/macos/<app>/`"*; (3) the bundler Rust struct
`apianyware_bundle_racket::AppSpec` — Info.plist/signing **bundle config**, wholly
unrelated. _Avoid_: "the AppSpec format is ours"; minting a grove-native `.apiw`
AppSpec entity (ADR-0052 declined it).

**App** _(AppSpec vocab)_:
A native UI application whose behaviour an AppSpec specifies, **independent of how it is
built** (e.g. *hello-window*, *Modaliser*). _Avoid_: conflating an App with a single
Implementation of it.

**Implementation / impl** _(AppSpec vocab)_:
A concrete build of an App in some language/runtime — the thing under test, selected
with `--impl`. In APIAnyware these live at
`targets/<t>/app-implementations/<platform>/<app>/`. _Avoid_: **"target"** (an
APIAnyware target — racket/chez/gerbil/sbcl — *produces* impls; an impl is one app
built by one target), "variant", "build".

**Scenario / Scenario suite** _(AppSpec vocab)_:
A **scenario** is one verifiable behaviour, impl-agnostic (authored as `#lang app-spec`
source); a **scenario suite** is an App's set of scenarios, colocated with the App
(`apps/macos/<app>/scenarios/`). _Avoid_: "test case" / "spec file" (reserve "test" for
an impl's own unit tests).

**Contract** _(AppSpec vocab)_:
A conformance requirement every impl must satisfy to be verifiable — the structured log
format (`logging-contract.md`) and observable state (`observable-state.md`), colocated
with the App. They double as the **porting guide** for a new impl. _Avoid_: confusing
with the CL-family *interface contract* (a different, target-side concept).

**Reverse-gen / forward-gen** _(the LLM-driven, human-in-the-loop authoring model; ADR-0052)_:
**Reverse-gen** = point at an existing app/impl → LLM-generate description/spec/PRD docs
detailed enough to *reliably replicate* it (human-annotated). **Forward-gen** = LLM
synthesize test suites that *correlate with* a spec, from best-practice guidelines,
attack-vectors, and patterns/anti-patterns (human-validated). Git is the
propose→review→accept boundary — the **ws5 side-channel philosophy** (ADR-0050) applied
to app specs. The durable human-adjacent artifact is the **spec**, not the hand-written
suite. _Avoid_: hand-authoring suites (that authors the generator's output by hand).

## Test model (refactor workstream 9)

Introduced by the `structural-refactoring` grove, workstream 9 (`testing-architecture-k156`). The
**behaviour axis** of conformance — "does the binding *behave*?" — orthogonal to ws8 **validation**
("is the artifact *well-formed*?"). REFACTOR §33/§34, settled around **ADR-0053** and the node
running log **D1–D5**. Model prose: `testing/test-model.md` (the behaviour-axis twin of
`schemas/docs/validation-model.md`).

**Multi-layer test model** _(the ws9 deliverable)_:
A **documented federation**, not a test-running machine. It maps REFACTOR §33's twelve **test
layers** to the homes that already realise them (spec-validation → ws8 `apianyware-validate`;
extraction → emit goldens + `extract-*/tests`; annotation → ws5 `annotations {stale,audit}`;
conformance → ws6 `apianyware-conformance`; sample-app / GUI → the external AppSpec suites), marks
the **honest gaps** (performance §11, dedicated leak/lifetime/threading stress §12, and the layer-6
api-semantics **execution**), and names the external-runner seam. ws9 builds **no runner and no
crate** — the runner is external (AppSpec, ADR-0052) and per-target execution hooks are ws6's.
_Avoid_: "the test runner" / "the test harness" (there is none grove-side — execution is AppSpec's,
ADR-0052); conflating the **test model** (behaviour, `testing/`) with the **validation model**
(well-formedness, `schemas/`); claiming layer-6 / perf / stress coverage that is documented as a gap.

**Test layer** _(REFACTOR §33 vocab)_:
One of the twelve levels at which testing happens (spec-validation · extraction-regression ·
annotation-review · adapter-ABI · target-binding-unit · semantic-pattern · cross-target-conformance ·
AppSpec-sample-app · GUI/accessibility · packaging/signing/install · performance ·
leak/lifetime/threading stress). Each layer has a **home** (an existing crate / goldens / declaration /
external suite) or is a **documented gap**. _Avoid_: treating the layers as one suite to be *run* by a
single command (they are a federation of independently-homed test kinds — D1); "test level" is an
acceptable synonym.

## Example dialogue

> **Dev**: Should we add a `--style functional` to the CLI for the new Chez
> target so it shares the racket emitter?
>
> **Domain**: No — the paradigm dimension is retired. If Chez wants a
> functional shape, it's a separate **target** (`chez` or `chez-functional`)
> with its own emitter crate, its own sample apps, its own knowledge entries.
> The CLI only knows about targets; binding style is implicit per target.
