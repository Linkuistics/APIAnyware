# Gerbil grows a Swift dylib for the Swift-native trampoline (the ADR-0017 deviation)

**Status:** accepted

Decides the **gerbil** target's mechanism for vending C-ABI **trampolines** for
the Swift-native residual (`objc_exposed == false`), the gerbil counterpart to
**ADR-0027** (racket) and **ADR-0028** (chez). It is the **deliberate deviation
from ADR-0017** that `070-gerbil-extend` was opened to design: gerbil grows a
**Swift compilation unit** — a small `libAPIAnywareGerbil.dylib` — where ADR-0017
said gerbil would have *no Swift dylib and no `swift build` step*. Refines
**ADR-0025** (the complete-API binding model + trampoline elision), consumes
**ADR-0026** (the `objc_exposed` IR fact), is governed by **ADR-0011** (the
trampoline layer is per-target) and **ADR-0010** (the native library *is* the
binding), and reuses the racket design spec
`docs/specs/2026-06-15-racket-trampoline.md` for the marshalling taxonomy,
deferred buckets, and known-good exemplars (same shared IR → identical residual).

## Context — why ADR-0017 must bend here, and only here

ADR-0017 chose ObjC-in-`gsc` over a Swift dylib for gerbil's native core, for two
reasons: (1) the native core's concerns (blocks, dynamic classes, lifetime,
thread-bounce) are all expressible as ObjC, which `gsc` compiles natively into the
self-contained static exe (ADR-0009); (2) a dylib would fight that
self-containment. Both reasons held — for the **ObjC-shaped** native core.

The Swift-native residual breaks the first reason. A trampoline for a
Swift-native API **must be Swift** — only Swift can call the Swift ABI; `gsc`
(a C/ObjC compiler) structurally cannot. So the residual is not a case where we
*prefer* ObjC-in-gsc and could use Swift; it is a case where ObjC-in-gsc is
**impossible**. ADR-0017's "no Swift dylib" was a decision about the native core
it was scoped to; it did not contemplate Swift-native API coverage (that grove
came later). This ADR records the bend precisely: **the Swift dylib is admitted
for the trampoline, and nothing else.**

The second reason (self-containment) is preserved, not waived — see Decision §3.

## Decision

### 1. A small Swift dylib, trampoline-only — `libAPIAnywareGerbil`

A new SwiftPM dynamic-library target `APIAnywareGerbil` is added to
`swift/Package.swift` (alongside `APIAnywareRacket`, `APIAnywareChez`). It carries
**only** the Swift-native trampoline plus the genuinely-native marshalling
helpers (§2). The existing ObjC native core (`runtime/objc.ss` `c-declare`,
`runtime/native-core.ss`, `runtime/native_block.c`) stays exactly where ADR-0017
put it — compiled by `gsc`/`clang` into the exe. The dylib does **not** absorb
the native core (scope decided in the 070 grilling: necessity, not a build-time
gamble — see "Build-time finding" below).

`apianyware-macos-generate` emits a gitignored
`swift/Sources/APIAnywareGerbil/Generated/Trampolines.swift` in a global pass
(`run_gerbil_trampolines`, modelled on `run_chez_trampolines`/`run_racket_trampolines`),
then `swift build` compiles it into `libAPIAnywareGerbil.dylib`. Each residual
decl becomes one `@_cdecl` that `import`s the owning module and calls the API by
reconstructed name + labels; swiftc owns ABI correctness. Entry naming is
content-addressed `aw_gerbil_swift_<Fw>_<name>` /
`aw_gerbil_swift_const_<Fw>_<name>` with a short overload hash, so the gerbil
emitter reconstructs the symbol with no shared counter (ADR-0013 precedent). The
classification taxonomy (`ArgMarshal`/`RetMarshal`, the value-struct unbox gate,
the deferred reasons) is **identical to racket/chez** — it is a property of the
shared IR + the flat C ABI.

### 2. Scheme-side marshalling, bound via `define-c-lambda` (the ADR-0015/0017 idiom)

Gerbil is a **compiled-FFI** target (ADR-0015/0017): its `foreign-procedure`-class
crossing is already at the dispatch floor, so — exactly as chez (ADR-0028 §2) —
value marshalling stays **Scheme-side**; a native marshalling layer would only add
a hop. But gerbil binds the C ABI through its own idiom, **not** chez's
`foreign-procedure`:

- Each `aw_gerbil_swift_*` entry is bound by a **per-signature `define-c-lambda`**
  (the ADR-0017 dispatch idiom, mirroring the generated `%msg-…` crossings) in a
  new `runtime/swift-trampoline.ss`.
- A `String`-returning trampoline returns the bridged `NSString` `id`; the gerbil
  binding coerces it with the **existing** gerbil string bridge (`runtime/cocoa.ss`)
  — no new native string bridge.
- An **object**-returning trampoline returns a raw `id`; the binding `wrap`s it to
  its **exact bound type** through the ADR-0020 `register-objc-class!` registry
  (walking the ObjC superclass chain to the nearest bound ancestor) — the same
  wrapping every `id`-returning method already gets. This is gerbil's substantive
  divergence from chez, forced by the ADR-0020 manifest class hierarchy.
- Only the genuinely-native concerns get new **hermetic** Swift in
  `APIAnywareGerbil`: an opaque value-box + uniform `aw_gerbil_box_free`
  (`OpaqueHandle.swift`) and the `throws` `NSError**` out-param bridge
  (`ThrowsBridge.swift`), mirroring chez's `awChez*` shapes renamed `awGerbil*`.

### 3. Self-containment preserved by the existing relocation path — no new mechanism

A dylib would fight ADR-0009 *only if it were an un-relocated dependency*. It is
not, for two reasons:

- **The Swift runtime is OS-resident.** On macOS ≥ 12 `libswiftCore.dylib` et al.
  ship in `/usr/lib/swift/`; `libAPIAnywareGerbil.dylib` links against them as it
  would against any system framework. No vendored Swift runtime is dragged in. The
  dylib is the **only** new non-system, non-framework dependency — the same
  category as the openssl@3 dylib gerbil already tolerates.
- **`bundle-gerbil` already vendors-and-relocates exactly this category.** It
  copies non-system dylibs into `Contents/Frameworks/` and rewrites the exe's and
  inter-dylib load commands to `@executable_path/../Frameworks/<name>` via
  `install_name_tool` (`relocate.rs`). Extending its vendor set from
  `/opt/homebrew/*` to also include the built `libAPIAnywareGerbil.dylib` is a
  **bounded extension of an existing path**, after which `otool -L` on the bundled
  exe again shows only `/usr/lib/*`, system frameworks, and `@executable_path/..`.

So self-containment is upheld by the same machinery, not by a new exception.

### 4. No lazy-load forcing reference (gerbil diverges *less* than chez here)

Chez needed a forcing reference (ADR-0028 §3) because an R6RS library instantiates
**lazily** and the dylib loads in a module body, so a pure-scalar trampoline could
fail to trigger the load. Gerbil has no such hazard: the dylib is linked at
`gxc -exe` time via `-l`, so every `aw_gerbil_swift_*` symbol resolves at image
load regardless of which trampolines a program references. The chez §3 idiom is
**deliberately not ported.**

### 5. Scope — identical residual to racket/chez (spec §5)

Land scalars, Foundation-bridged value returns (Scheme-side), objects→wrapped
typed handle, `Optional`, Swift-`struct`-**return**→opaque box, pointer constants,
**plus `throws`**. `async` (bucket measured empty, spec §5b), generic free
functions, and non-bridged-struct / closure / unnameable **params** are
recorded-with-reason and counted, never silently dropped. Because the residual is
a deterministic function of the shared IR, the gerbil pass reproduces racket's and
chez's classification **exactly** (51 function trampolines, 7 constants; deferred
6 closure / 10 nonbridged-struct / 4 unnameable / 34 unbindable-generic). That
equality is the strongest evidence the port is faithful.

## Build-time finding (N1) — hypothesis evaluated *and measured* (leaf 030)

N1 (2026-06-15) hypothesised that moving native code into a Swift dylib could be a
build-time **win** by offloading work out of the `gsc` compile (gerbil's defining
pain — ADR-0023's generics cold build). The 070 grilling evaluated this and
**scoped the dylib to the trampoline only, on the structural argument that the
win does not hold:**

- Gerbil's compile cost is dominated by the **generics** (`generics.ss`,
  ADR-0023). Those are Scheme `define-c-lambda` codegen; they **cannot move to a
  Swift dylib** — there is no Swift form of them. The dylib cannot offload the one
  thing that is actually expensive.
- The trampoline is **new, small work** (~51 funcs + 7 constants) that **never
  flowed through `gsc`**. It is added cost (a `swift build` step), not redirected
  cost. There is nothing to "offload" from `gsc` because the residual was never
  there.
- The remaining migratable native code (the ObjC core) is small, working, and
  VM-verified; rewriting it in Swift to chase an unproven build-time win violates
  the necessity-only principle and risks regression for speculative gain.

**Conclusion: the Swift dylib is justified by *necessity* (only Swift can call the
Swift ABI), not by a build-time win.** The decision above does not depend on the
measurement (necessity stands regardless); the measurement below closes N1 honestly.

### Measured (leaf 030, 2026-06-18)

Per the brief's "measured, not asserted" bar, leaf `030-rerun-verify` quantified
the added `swift build` step and confirmed the generics compile is untouched:

| | wall-clock |
|---|---|
| `swift build -c release --product APIAnywareGerbil` — **cold** (after `swift package clean`) | **3.96s** (produces an 84 KB dylib) |
| same — warm / no-op rebuild | 0.34s |
| gerbil **generics** compile — 113 shards, cold parallel (ADR-0023, the `gsc`/`gxc` path) | **291.5s**, *unchanged* by the dylib |

The numbers confirm the structural argument exactly. The added `swift build` step is
**~4 seconds of pure addition** (84 KB of `@_cdecl` trampolines + the two hermetic
helpers), **orthogonal to and ~74× smaller than** the ~292s generics compile that
dominates gerbil's cold build. The dylib lives in a **separate toolchain** (`swiftc`)
that never enters the `gsc`/`gxc` graph, so the ADR-0023 generics cost is provably
unchanged — there is nothing in `gsc` for the dylib to offload, because the
trampoline is new work that never flowed through it. **N1's hypothesised build-time
*win* does not materialise; the cost is small, additive, and unavoidable.** Necessity,
not a win — closed honestly. (Full evidence:
`generation/targets/gerbil/test-results/swift-native-probe/report.md`.)

## The ADR-0011 shared-source call — still hermetic duplication; the trigger did not fire

ADR-0028 deferred the per-target-vs-shared-source question with an explicit
**revisit trigger**: "gerbil becoming a *third* near-identical copy *and* the
per-target divergences shrinking." Gerbil is now that third copy — and the second
half of the trigger **did not fire**: gerbil diverges *more*, as ADR-0028
predicted. It has no Swift dylib by default (this ADR admits one specifically),
binds via `define-c-lambda` (not `foreign-procedure`/`get-ffi-obj`), wraps objects
through the ADR-0020 class registry, omits chez's lazy-load forcing reference, and
needs a `bundle-gerbil` relocation extension none of the others need. The shared
half remains a *taxonomy* (already centralised in the IR via `objc_exposed`); the
per-target half is the half that would need co-maintenance, and it is now larger,
not smaller.

**Call: keep hermetic per-target duplication (the ADR-0011 default). Do not
extract a shared trampoline source.** Three targets have now confirmed the
duplication is cheap (LLM-assisted, ADR-0011) and that the divergences are real
and load-bearing.

## Consequences

- A new gitignored generated artifact,
  `swift/Sources/APIAnywareGerbil/Generated/Trampolines.swift`, written by
  `generate` before `swift build` (`--gerbil-trampolines-out` / `--no-gerbil-trampolines`
  flags mirror the chez/racket ones); a new `APIAnywareGerbil` SwiftPM target.
- **Gerbil's build order gains a `swift build` step** — `generate → swift build →
  gxc` — the precise ADR-0017 line this ADR crosses. The gerbil app build links
  `-lAPIAnywareGerbil`; `bundle-gerbil` vendors+relocates the dylib into the
  `.app`. `generation/targets/gerbil/docs/reference.md` is updated to record the
  added step and that self-containment is preserved by relocation.
- The gerbil native lib gains a hermetic marshalling layer (`OpaqueHandle.swift`,
  `ThrowsBridge.swift`); the gerbil runtime gains `runtime/swift-trampoline.ss`;
  the emitter (`emit_functions` / `emit_constants`) routes `objc_exposed == false`
  decls to `define-c-lambda` trampoline bindings, replacing the prior skip at
  `emit_functions.rs:49` / `emit_constants.rs:133`.
- `cargo test --workspace` green (985/0 at leaf 030, incl. the `bundle-gerbil`
  swift-dylib relocation tests); the CLI smoke proves the spec §6a exemplars
  (`CreateML.timestampSeed()` → time-derived `Int`, `MLCreateErrorDomain` →
  `"com.apple.CreateML"`) resolve and run through `libAPIAnywareGerbil`, and is now
  chained into the gerbil `run-smokes.sh` harness as the permanent Swift-native
  regression guard. The full cold rerun + VM-verify (the project done-bar) + the N1
  measurement **landed** in leaf `070-gerbil-extend/030` (2026-06-18) — the residual
  reproduced exactly (51/7; deferred 6/10/4/34), the bundled `.app` passed `otool -L`
  self-containment (dylib relocated into `Contents/Frameworks/`), and the probe
  rendered both exemplars live in the TestAnyware VM. See
  `generation/targets/gerbil/test-results/swift-native-probe/report.md`.
- **Last target.** Completing gerbil closes the charter's "rerun every target"
  done-bar, makes the grove ready to finish, and unpauses
  `add-sbcl-clos-target` (whose paused Swift library is this model's trampoline
  layer).

See `CONTEXT.md` (*Trampoline*, *Opaque handle*, *Unbindable residual*) for the
glossary, ADR-0027 (racket) and ADR-0028 (chez) for the siblings, ADR-0017 for the
native-core decision this deviates from, ADR-0015 for the Scheme-side-marshalling
reasoning, and the racket design spec for the taxonomy this reuses.
