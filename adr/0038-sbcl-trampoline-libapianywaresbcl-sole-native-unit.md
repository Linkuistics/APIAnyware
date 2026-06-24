# `libAPIAnywareSbcl` is the SBCL target's sole native unit — trampolines plus the runtime concerns gerbil kept in ObjC

**Status:** accepted

Decides the **sbcl** target's mechanism for vending C-ABI **trampolines** for the
Swift-native residual (`objc_exposed == false`), the sbcl counterpart to
**ADR-0027** (racket), **ADR-0028** (chez), and **ADR-0029** (gerbil). Refines
**ADR-0025** (the complete-API binding model + trampoline elision), consumes
**ADR-0026** (the `objc_exposed` IR fact), is governed by **ADR-0011** (the
trampoline layer is per-target) and **ADR-0010** (the native library *is* the
binding), and realizes the **lower layer** of the CL-family interface contract
(**ADR-0033** §5, contract spec §5). It reuses the racket design spec
`targets/racket/docs/design/2026-06-15-racket-trampoline.md` for the marshalling taxonomy, the
method frontier (§8/§9), the deferred buckets, and the B1–B5 swift-residual close —
same shared IR → identical residual.

It is the sbcl realization of the leaf `030-design/040-trampoline-layer`, and it
**composes** the already-settled sibling decisions: ADR-0034 (object model + startup
re-resolution), ADR-0035 (main-thread bounce), ADR-0036 (lifetime + release queue),
ADR-0037 (`NSError**`/`throws` → `ns:cocoa-error`). Where those ADRs said "the
native core" or "`libAPIAnywareSbcl`", this ADR fixes precisely *what that one dylib
contains and why it is broader than gerbil's*.

## Context — SBCL has one native home, where gerbil had two

ADR-0029 could scope gerbil's Swift dylib to **trampoline-only** because gerbil
already had a *second* native compilation unit — the ObjC core compiled inline by
`gsc` (ADR-0017: `runtime/objc.ss` `c-declare`, `native_block.c`) — which hosts the
block bridge, the delegate/subclass IMPs, and the main-thread bounce (ADR-0022). The
Swift dylib only had to carry what *must* be Swift (the trampolines) plus two small
hermetic helpers (`OpaqueHandle`, `ThrowsBridge`).

**SBCL has no such second home.** SBCL is a Lisp; it cannot compile ObjC *or* Swift
inline. Its *only* native compilation unit is the SwiftPM package
`libAPIAnywareSbcl`. So every genuinely-native concern the gerbil target spread
across two homes must converge into that one dylib here. Two of those concerns are
not optional:

- **The main-thread callback bounce is structurally forced to be native (ADR-0035).**
  The threading spike proved Lisp must *never* run on a foreign (GCD/framework)
  thread — and `sb-alien:define-alien-callable` **is** Lisp at the IMP entry point;
  invoking it on a foreign thread triggers the GC-unsafe attachment that crashed 5/5.
  So the IMP that AppKit calls on a foreign thread must be **native** code that
  `dispatch_sync`/`dispatch_async`es to main *before* re-entering Lisp. That native
  code has nowhere to live but this dylib.
- **Subclass-synthesis IMP installation needs that same native shim (ADR-0034 §5).**
  `objc_allocateClassPair`/`objc_registerClassPair` are plain libobjc C calls Lisp
  drives directly via `sb-alien`; but `class_addMethod` needs an **IMP function
  pointer**, and that pointer must be the native bounce shim, not a raw
  `define-alien-callable` (which would re-introduce the foreign-thread hazard).

## Decision

### 1. One broader dylib — the sole native unit (the fork this leaf settled)

A single SwiftPM dynamic-library target **`APIAnywareSbcl`** is added to
`swift/Package.swift` (alongside `APIAnywareRacket`, `APIAnywareChez`,
`APIAnywareGerbil`). It is the SBCL target's **sole native compilation unit** and
hosts:

| File | Role | Precedent |
|---|---|---|
| `Generated/Trampolines.swift` | the Swift-native residual `@_cdecl` re-exports (functions, constants, methods, inits) | racket/chez/gerbil `Generated/Trampolines.swift` |
| `OpaqueHandle.swift` | `AwSbclValueBox` + uniform `aw_sbcl_box_free` | gerbil `OpaqueHandle.swift` |
| `ThrowsBridge.swift` | `NSError**` out-param bridge feeding `ns:cocoa-error` | gerbil `ThrowsBridge.swift`; ADR-0037 |
| `AsyncBridge.swift` | async-method dispatch; completion delivered **on main** | racket/gerbil `AsyncBridge`; spec §9 |
| `CallbackBounce.swift` | the foreign-thread → main-thread IMP/block bounce | **new** — gerbil kept this in ObjC-in-gsc (ADR-0022) |
| `SubclassSynth.swift` | builds the native bounce-shim IMP and installs it (`class_addMethod`) | **new** — gerbil kept this in ObjC-in-gsc |

The reconciliation with the glossary's *"trampoline-only"* framing is exact:
**"trampoline-only" means the dylib does not absorb the MOP object model** — the
`objc-class` metaclass, the `sb-mop` hooks, the class graph, the dispatch generics,
and the startup re-resolution pass *stay in Lisp* (ADR-0034). The dylib is broader
than gerbil's **only** by hosting the genuinely-native *runtime* concerns gerbil
placed in its ObjC-in-gsc home — which is not a substrate the dylib absorbs, but the
same category of native helper (`OpaqueHandle`/`ThrowsBridge`) it already carries,
just more of it. The object model is untouched by this consolidation.

*Rejected: a second native unit* (a separate `libAPIAnywareSbclCore` ObjC/C target,
the closest analogue to gerbil's split). It buys per-unit "purity" (the trampoline
dylib would stay uniform with the peers) at the cost of a **second** build, vendor,
relocate, and codesign artifact in every `.app`, for no functional gain — Swift
expresses `DispatchQueue.main` and `@convention(c)` IMPs as well as ObjC. One artifact
is simpler everywhere it matters (build order, bundling, self-containment).

### 2. Generated `@_cdecl` trampolines, called by name — same as the peers

`apianyware-generate` emits a gitignored
`swift/Sources/APIAnywareSbcl/Generated/Trampolines.swift` in a global pass
(`run_sbcl_trampolines`, modelled on `run_gerbil_trampolines`), then `swift build`
compiles it into `libAPIAnywareSbcl.dylib`. Each residual decl becomes one `@_cdecl`
that `import`s the owning module and calls the API by reconstructed name + labels;
swiftc owns ABI correctness. Entry naming is content-addressed, reconstructible by
the sbcl emitter with no shared counter (ADR-0013 precedent):

- `aw_sbcl_swift_<Fw>_<name>` (functions), `aw_sbcl_swift_const_<Fw>_<name>`
  (constants), `aw_sbcl_swift_m_<Fw>_<Owner>_<base>` (methods),
  `aw_sbcl_swift_init_<Fw>_<Owner>` (inits) — a short overload hash appended only when
  `(module[, owner], name)` is overloaded (spec §2, §8.4).

The classification taxonomy (`ArgMarshal`/`RetMarshal`, the value-box gate, the
receiver-marshal kinds, the deferred reasons) is **identical to racket/chez/gerbil** —
a property of the shared IR + the flat C ABI, not re-derived per target.

### 3. Lisp-side marshalling, bound via typed `sb-alien` (the ADR-0015 idiom)

SBCL is a **compiled-FFI** target (ADR-0015): its `sb-alien` `objc_msgSend` crossing
is already at the dispatch floor, so — exactly as chez (ADR-0028 §2) and gerbil
(ADR-0029 §2) — value marshalling stays **Lisp-side**; a native marshalling hop would
only add cost. SBCL binds the C ABI through its own idiom, not chez's
`foreign-procedure` nor gerbil's `define-c-lambda`:

- Each `aw_sbcl_*` entry is bound by a **per-signature typed `sb-alien`**
  (`define-alien-routine` / `alien-funcall` on an `extern-alien`) in a new runtime
  `swift-trampoline` cluster — the same compiled-FFI shape the direct `objc_msgSend`
  dispatch uses.
- A `String`-returning trampoline returns the bridged `NSString` `id`; the sbcl
  binding coerces it with the **existing** sbcl string bridge — no new native string
  bridge (the chez/gerbil §2 pattern).
- An **object**-returning trampoline returns a raw `id`; the binding **wraps it to its
  exact bound type** through the **ADR-0034 MOP class registry** (walking the ObjC
  superclass chain to the nearest bound `objc-class`-backed ancestor) — the same
  wrapping every `id`-returning method already gets. This mirrors gerbil's substantive
  divergence (ADR-0029 §2, forced there by the ADR-0020 manifest hierarchy; here by the
  ADR-0034 metaclass graph).
- **No lazy-instantiation forcing reference.** The chez §3 hazard (an R6RS library body
  loads the dylib lazily) does not arise: the sbcl runtime `load-shared-object`s
  `libAPIAnywareSbcl` eagerly when the runtime file loads, and SBCL **re-opens it
  automatically** on image restart (§5). The chez §3 idiom is **not** ported — the
  gerbil §4 position.

### 4. The native runtime concerns the dylib hosts (the broader-than-gerbil part)

These realize the already-accepted sibling ADRs; this ADR fixes only their *home*:

- **Main-thread bounce (ADR-0035).** `CallbackBounce.swift` is the native entry every
  foreign-thread callback (delegate IMP, block invoke, subclass IMP) lands on:
  `dispatch_sync` to the main queue for value-returning callbacks, `dispatch_async`
  for void completions, direct inward call when already on main (zero hop). Only then
  is the Lisp IMP (a `define-alien-callable` pointer Lisp handed down) invoked — on
  main, GC-safe.
- **Subclass synthesis (ADR-0034 §5, refined).** Class-pair allocation
  (`objc_allocateClassPair`/`objc_registerClassPair`) is driven **Lisp-side** via
  `sb-alien` (plain libobjc calls). Per overridden selector, Lisp passes its
  `define-alien-callable` pointer + the selector's type encoding to a dylib entry
  (`SubclassSynth.swift`) that builds the native **bounce-shim IMP** wrapping that
  pointer and `class_addMethod`s it. The IMP build is dylib-side because the installed
  IMP *must* be the native bounce shim (§1). *Mechanism note for `050`:* a
  `@convention(c)` IMP is signature-specific, so the bounce shim is either generated
  per overridable selector-signature (the emitter already generates per-selector code)
  or forwarded via `NSInvocation` — a build-leaf choice, not fixed here.
- **`ThrowsBridge`/`AsyncBridge`/`OpaqueHandle`** carry their racket/gerbil roles;
  `ThrowsBridge` feeds the *one* `ns:cocoa-error` signaller that also serves the direct
  `NSError**` path (ADR-0037).

### 5. `save-lisp-and-die` interaction — the relive-burden split (the leaf's headline question)

A dumped image (`save-lisp-and-die`, D4) keeps baked Lisp metadata but loses live
foreign pointers (ADR-0034 §6, spike `…/sbcl-mop-spike/5-startup-re-resolution.sh`).
The burden splits cleanly between the dylib and the Lisp pass — **the dylib does not
absorb the `Class`/`SEL` relive**:

- **The dylib's own symbols re-resolve for free.** `load-shared-object` registers
  `libAPIAnywareSbcl` in SBCL's `*shared-objects*`, which SBCL **re-opens on image
  restart**. So every `aw_sbcl_*` `@_cdecl` re-links automatically; the trampoline
  layer needs no revival of its own.
- **dyld re-loads the dylib's framework subset.** `libAPIAnywareSbcl` links (at
  `swift build` time, via the residual decls' `import`s) exactly the
  **residual-owning** frameworks (CreateML, CoreML, …). Re-opening the dylib transitively
  re-loads those through dyld — so the Lisp startup pass does **not** need to re-`dlopen`
  them.
- **The Lisp pass owns everything else.** The **majority** of frameworks are reached by
  direct `objc_msgSend` (AppKit, Foundation, …) and are *not* dylib dependencies; and
  **all** `Class`/`SEL` re-resolution is over the **baked Lisp class graph**, which only
  Lisp holds. So the ADR-0034 §6 startup re-resolution pass stays a **Lisp** pass: it
  re-`dlopen`s the direct-msgSend frameworks and re-resolves every `Class` via
  `objc_getClass` / every `SEL` via `sel_registerName` from baked string identity —
  calling those libobjc functions **directly** via `sb-alien`, never through the dylib.

⇒ **The dylib stays passive** — no `aw_sbcl_revive` entry. The relive is Lisp-metadata
work; routing it through the dylib would buy nothing and couple two independent concerns.
This is the precise answer to the leaf's "does the dylib's load-time setup absorb part of
the relive burden?": **only for its own framework subset, via dyld, for free; the rest
stays Lisp-side.**

### 6. Self-containment preserved by the existing relocation path (gerbil ADR-0029 §3)

> **SUPERSEDED by ADR-0041 for the relocation *mechanism*.** Building the 060 sample
> apps proved `install_name_tool` **impossible** on a `save-lisp-and-die` image (the Lisp
> core sits past `__LINKEDIT`). `bundle-sbcl` does **not** reuse `bundle-gerbil`'s
> `relocate.rs`; it closes the two gaps at runtime instead — `libzstd` via a stub's
> `DYLD_FALLBACK_LIBRARY_PATH`, `libAPIAnywareSbcl` via a relocated `*shared-objects*`
> namestring. The framing below (the dylib is the only new non-system dependency; the
> Swift runtime is OS-resident) still holds; only the `install_name_tool` paragraph is
> wrong. See ADR-0041.

`save-lisp-and-die :executable t` embeds the SBCL runtime into the dumped executable;
the exe `dlopen`s `libAPIAnywareSbcl` at startup. Self-containment is upheld by the
**same machinery** gerbil uses, not a new exception:

- **The Swift runtime is OS-resident** (`/usr/lib/swift/` on macOS ≥ 12), linked as any
  system library — no vendored Swift runtime. The dylib is the only new non-system,
  non-framework dependency.
- **`bundle-sbcl` vendors-and-relocates exactly this category.** It copies the built
  `libAPIAnywareSbcl.dylib` into `Contents/Frameworks/` and rewrites the exe's load
  command to `@executable_path/../Frameworks/libAPIAnywareSbcl.dylib` via
  `install_name_tool` — the same path `bundle-gerbil`'s `relocate.rs` runs for the
  gerbil dylib and openssl@3 (ADR-0029 §3), after which `otool -L` on the bundled exe
  shows only `/usr/lib/*`, system frameworks, and `@executable_path/..`.

### 7. Scope — reproduces the §6d invariant exactly

The residual is a deterministic function of the shared IR, so the sbcl pass reproduces
racket's/chez's/gerbil's classification **exactly** — the spec **§6d invariant**:
**51 function trampolines + 7 constants + 576 init + 554 method trampolines**, with the
byte-identical per-reason deferred breakdown (`6 closure_param / 10 nonbridged_struct_param
/ 4 unnameable_param / 34 unbindable_generic` for free functions, plus the method-frontier
reasons of spec §8.6/§9.3). That equality is the strongest evidence the port is faithful.
sbcl inherits the **B1–B5 swift-residual close** (the `.v26` deployment floor, umbrella
re-attribution, owner-availability fold, curated `KNOWN_UNBINDABLE`) **through the shared
IR** — those were emitter-side fixes the IR carries (racket spec §8.8), so sbcl does not
re-derive them.

## The ADR-0011 shared-source call — keep hermetic duplication; the trigger still did not fire

sbcl is now the **fourth** Swift-trampoline target. ADR-0028's revisit trigger ("a third
near-identical copy *and* the per-target divergences shrinking") was already declined at
gerbil (ADR-0029) — and sbcl diverges **more**, not less: a typed `sb-alien` binding (not
`get-ffi-obj`/`foreign-procedure`/`define-c-lambda`), object returns wrapped through the
**ADR-0034 MOP class registry**, and — uniquely — the **broader-dylib consolidation**
(§1), since sbcl has no second native home to spread these across. The shared half remains
a *taxonomy* (centralised in the IR via `objc_exposed`); the per-target half is larger.

**Call: keep hermetic per-target duplication (the ADR-0011 default). Do not extract a
shared trampoline source.** Four targets now confirm the duplication is cheap
(LLM-assisted, ADR-0011) and the divergences real and load-bearing.

This is **orthogonal to ADR-0033's spec-level interface share**: the CL family shares the
*interface contract* (the `ns:`/CLOS surface), never *binding code*. The trampoline layer
is the contract's lower layer, per-target hermetic; the contract documents the upper
surface that the shared-IR convergence produces. No shared code crosses the impl boundary.

## Considered options

- **One broader dylib (chosen).** All native concerns in `libAPIAnywareSbcl`. Simplest
  build/bundle; Swift expresses the bounce + IMPs; ADR-0035 already placed the bounce here.
- **Two native units** (trampoline dylib + a separate ObjC/C core). "Purer" per unit; a
  second build/vendor/relocate/codesign artifact for no functional gain. Rejected (§1).
- **Lisp-side bounce, no native shim.** Rejected structurally — the IMP entry point is the
  foreign-thread entry, and any `define-alien-callable` there runs Lisp on the foreign
  thread (the GC-unsafe case the ADR-0035 spike crashed on). The bounce *must* precede
  Lisp, in native code.
- **A `aw_sbcl_revive` dylib entry owning the relive.** Rejected (§5) — the `Class`/`SEL`
  relive is over the baked *Lisp* graph; the dylib has no view of it. The dylib re-resolves
  its own symbols via SBCL's `*shared-objects*` reopen for free.

## Consequences

- A new gitignored generated artifact,
  `swift/Sources/APIAnywareSbcl/Generated/Trampolines.swift`, written by `generate` before
  `swift build` (`--sbcl-trampolines-out` / `--no-sbcl-trampolines` flags mirror the
  racket/chez/gerbil ones); a new `APIAnywareSbcl` SwiftPM target with the six files of §1.
- **Build order:** `generate → swift build → load in SBCL → (for an app) save-lisp-and-die`.
  The app image `load-shared-object`s the dylib; `bundle-sbcl` vendors + relocates it into
  `Contents/Frameworks/`.
- **Build-leaf boundaries.** `050` builds the dylib (the six files) + binds the `aw_sbcl_*`
  entries via `sb-alien` + the per-signature bounce-shim mechanism + composes the Lisp
  startup re-resolution pass (ADR-0034 §6) with the dylib's auto-reopen (§5). `040` (emitter)
  routes `objc_exposed == false` decls to trampoline bindings and emits the global pass.
  `070` (`bundle-sbcl`) extends the vendor set to include `libAPIAnywareSbcl`.
- **The SBCL target design spec** (`targets/sbcl/docs/design/2026-06-20-sbcl-target-design.md`,
  authored in this leaf) synthesizes ADR-0034/0035/0036/0037 + this ADR into the full
  buildable design.
- **Hard to reverse:** the sole-native-unit shape, the `aw_sbcl_*` entry convention, and the
  relive-split are baked into every generated binding, every sample app, and `bundle-sbcl`.
- Target-local under **ADR-0011**; the contract's lower layer under **ADR-0033**.

See `CONTEXT.md` (*`libAPIAnywareSbcl` / sbcl trampoline layer*, *Trampoline*, *Opaque
handle*, *Unbindable residual*) for the glossary, ADR-0029 (gerbil) for the closest
sibling, ADR-0015 for the Lisp-side-marshalling reasoning, ADR-0034/0035/0036/0037 for the
sibling decisions this composes, ADR-0033 + the contract spec for the lower-layer role, and
the racket design spec for the taxonomy + the §6d invariant this reproduces.
