# Adding a New Language Target

Step-by-step guide for adding a language target to APIAnyware. Written
against the real four-target world (`racket`, `chez`, `gerbil`, `sbcl`) — follow
it and you could plausibly stand up a fifth.

> **Layout (`structural-refactoring` domain tree).** The repository is partitioned
> by *domain*, not pipeline phase: there is no `generation/` tree. Crates live
> under `<domain>/tools/` — the **shared** emit substrate at
> `targets/_shared/tools/emit` (ADR-0044), the generate CLI at
> `targets/_shared/tools/generate-cli`, and each target's own crates at
> `targets/<id>/tools/<crate>` (the *crate-home convention*; the authoritative
> crate→domain map is the root `Cargo.toml` `members`). Each target unit
> `targets/<id>/` holds its `bindings/<platform>/` (runtime + emitted source +
> dylib + `reports/`), `adapters/<platform>/` (the native Swift package),
> `app-implementations/<platform>/<app>/`, the authored target-model `.apiw`
> entities (`target.apiw`, `capability.apiw`, `idioms/`, `policies/`, `adapters/`,
> `conformance/`), and `docs/`. The live `targets/<id>/` units are authoritative
> for current paths; the step paths below are written against this tree.

> **Fundamental design goal (ADR-0010):** the per-target **native (Swift)
> library is the binding** — purpose-built for one target, it maps the macOS API
> idiomatically into that language and owns memory / callbacks / closures /
> lifetimes / threading, using the target's own FFI/embedding C-API wherever
> possible. The generated/scripting side is a thin, static seam; in the limit the
> binding is almost entirely native (a fat native core behind a thin crossing).
> LLM-assisted coding makes a bespoke native library per target affordable. Plan
> every target toward this north star — the steps below serve it.

> **Targets are hermetically isolated (ADR-0011):** a target's generator,
> runtime, and native library share *nothing* with other targets — no shared
> native substrate. The only cross-target commonality is the **API analysis**
> (`collect → analyse`). Duplication across similar targets is accepted by
> design (it's cheap; LLM-assisted) so that paradigmatically-alien future targets
> never pay a wrong-abstraction tax. Build a new target standalone.

> **A *target* is a complete pipeline output for one language** — its emitter
> crate, runtime support, sample apps, bundler integration, and knowledge files.
> The on-disk unit is `targets/<id>/`. There is **one binding style
> per target**, implicit in the target and never selected at the CLI: the old
> paradigm / `BindingStyle` dimension was retired (**ADR-0004**). If a future
> language genuinely needs two shapes (e.g. class-based vs. functional), register
> **two targets** (`lang-class`, `lang-functional`) rather than reintroducing a
> style axis. See `CONTEXT.md` for the **Target** / **Binding style** / **Target
> idiom** glossary entries.

> **Each target is maximally idiomatic, not a portable subset** (**ADR-0005**).
> An emitter writes the source a native programmer of that language would
> actually write — `(import (chezscheme))`, `foreign-procedure`, and guardians
> for chez; `ffi/unsafe/objc` and `tell` for racket. Cross-target symmetry lives
> at the **on-disk layout** and **IR-decision** levels (which classes/methods get
> emitted), **not** at the source-form level. Do not aim for "portable R6RS that
> any Scheme loads".

> **Docs co-locate with their subject (ADR-0024 + REFACTOR §10):** there is **no
> top-level `docs/` tree** — every domain owns a local `docs/`, and the cross-cutting
> decision log + agreement checkpoints live in the small top-level `adr/` and `prd/`
> (ADR-0024). You **read** the shared docs co-located across domains and **produce**
> the per-target docs inside `targets/<id>/docs/`; doing so is a sequenced step of
> authoring, not an afterthought (Step 9), and a target is not *done* until its docs
> exist in the canonical structure. See **"Documentation"** immediately below for the
> read-vs-produce split. `racket`, `chez`, and `gerbil` are the worked examples
> (`targets/<id>/docs/reference.md`).

## Documentation: read the shared docs, produce the per-target docs

Per **ADR-0024**, documentation co-locates with code on the same axis ADR-0011
uses for the binding itself. Before you start, know which docs you *read* and
which you *produce* — and treat the ones you produce as deliverables, not notes.

**Read (shared docs, co-located across the domains — you consult, not edit, these to add a target):**

| Doc | Why you read it |
|---|---|
| `semantic/docs/` (`analysis.md`, `enrich-rules.md`, `api-pattern-catalog.md`) + `platforms/macos/docs/` (`collection.md`, `annotation-workflow.md`) | how `collect → analyse → generate` feeds your emitter |
| `targets/_shared/docs/` (`emitter-contract.md`, `type-mapping.md`) | the contract your `TargetEmitter` must satisfy |
| `apps/macos/docs/_index.md` + per-app `apps/macos/<app>/docs/spec.md` | the language-agnostic sample-app portfolio you must implement and VM-verify |
| `testing/` | the multi-layer test model (`test-model.md`) + the TestAnyware VM-verification methodology (`testanyware-workflow.md`) every app is held to |
| ADR-0010, ADR-0011 | the north star (native library *is* the binding) and hermetic isolation — why you build standalone |
| ADR-0004, ADR-0005 | one binding style per target; maximally idiomatic, not a portable subset |
| ADR-0024 | docs co-locate with their subject; the central `adr/`/`prd/` carve-out |

**Produce (the per-target docs — two co-located doc sets, the shape every live
target now carries):**

The **§18 target docs** sit at `targets/<id>/docs/` — a map + four deep-dives describing
what the *target* is. The **§22 binding mapping docs** sit at
`targets/<id>/bindings/<platform>/docs/` — how this target's *binding* maps the platform
API. Every doc **points at the target's authored `.apiw` entities** (`target.apiw`,
`capability.apiw`, `idioms/`, `policies/`, `adapters/`, `conformance/`) and **cites
`apianyware-conformance`** for derived coverage rather than copying recomputable facts
(constraint 4: no snapshotted numbers that rot).

| Slot | Contents | Produced during |
|---|---|---|
| `README.md` | target overview / index — the entry point to the unit | Step 9 (as the build settles) |
| `docs/overview.md` | §18 map: what the target is, its idiom posture, links into the deep-dives + the unit layout | Step 9 |
| `docs/language-characteristics.md` | §18 deep-dive: the language's relevant traits (typing, GC, macros, module system) | Step 9 |
| `docs/ffi-model.md` | §18 deep-dive: the FFI/embedding mechanism, dispatch, memory model, threading | Steps 3–8, consolidated in Step 9 |
| `docs/idiom-map.md` | §18 deep-dive — a **thin pointer** to the authoritative `idioms/docs/idiom-map.md` (the catalogue, not a copy) | Step 9 |
| `docs/representability.md` | §18 deep-dive: how the §20 capability profile × §30 weirdness yields the §7.7 representability floor for this target | Step 9 |
| `docs/reference.md` | the deep target reference (FFI patterns, dispatch, quirks, distribution) — the worked-example doc | Steps 3–8, consolidated in Step 9 |
| `docs/developer-guide.md` | user-facing app-writing guide — **where warranted** (racket has one; chez/gerbil/sbcl make the §22 `user-guide.md` their primary user doc) | Step 9 |
| `docs/design/`, `docs/research/` | the per-target design spec(s) and spikes raised while building | Step 1 onward / per spike |
| `bindings/<platform>/docs/user-guide.md` | §22: how to use the binding to write an app — the primary user doc for targets without a `developer-guide.md` | Step 9 |
| `bindings/<platform>/docs/platform-docs-mapping.md` | §22: how the platform's own API docs map onto this binding's surface | Step 9 |
| `bindings/<platform>/docs/api-coverage.md` | §22: what's covered — **citing `apianyware-conformance`**, not a copied table | Step 9 |
| `bindings/<platform>/docs/unsafe-escape-hatches.md` | §22: the unsafe/raw seams and when to reach for them | Step 9 |
| `app-implementations/<platform>/<app>/learnings.md` | per-app realization notes — what this target had to do to make that app work | Step 7, per app |
| `bindings/<platform>/reports/<app>/report.md` | the VM-verification report (+ screenshots) for each app | Step 7, per app |

ADRs are **the one exception**: target-flavoured decisions still land in the
central `adr/` log with global numbering (the decision graph crosses target
boundaries — gerbil ADRs cite chez ADRs, supersession chains span targets), per
ADR-0024. Raise ADRs there as you make them, not under the target unit.

## Prerequisites

- The shared emitter framework (`targets/_shared/tools/emit/`) is available.
- At least one target is complete as a reference: **racket** (the most complete),
  **chez** (the idiomatic-Scheme + self-contained-bundle reference), **gerbil**
  (compiled-FFI OO Scheme, no Swift dylib), and **sbcl** (CLOS/MOP, dumped image).
- The target language has a working FFI mechanism for calling C functions and
  the libobjc runtime.

## Step 1: Plan the target

Brainstorm the design, then capture it as a design spec (the standard project
workflow). The canonical statement of the idiom posture every new target
inherits is **ADR-0005** — read it first.

1. **Brainstorm** the design — FFI mechanism, naming conventions, dispatch
   strategy, memory model, block bridging, error handling, and (crucially) the
   *one* idiomatic shape this target emits.
2. **Write a design spec** to the target's own co-located design dir —
   `targets/<id>/docs/design/YYYY-MM-DD-<id>-design.md` (per-target
   docs co-locate, ADR-0024; cross-cutting specs live with their domain —
   `semantic/docs/`, `targets/_shared/docs/` — not a central `docs/specs/`)
   — recording at minimum:
   - **Language / display name** — e.g. "Chez Scheme".
   - **Target id** — the CLI `--target` value and on-disk dir name (`racket`,
     `chez`). A plain language id; no `{lang}-{paradigm}` slug.
   - **Implementation(s)** — which compiler/runtime (e.g. Chez 10.4.1).
   - **Idiom commitments** — the language constructs the emitter leans on, per
     ADR-0005 (chez: `library` form, `foreign-procedure`/`foreign-callable`,
     ftypes, guardians).
   - **Swift dylib** — `libAPIAnyware{Lang}.dylib`, if needed.
   - **Emitter crate** — `emit-{id}` (at `targets/{id}/tools/emit-{id}`).
   - **Runtime location** — `targets/{id}/bindings/<platform>/runtime/` (or the
     target's own convention — chez uses `bindings/macos/apianyware/runtime/`).
   - **Distribution model** — how a sample app ships (racket: stub-launcher +
     system runtime; chez: self-contained standalone binary, ADR-0009).

   Two concrete design specs exist to model yours on, both now co-located in the
   chez unit: `targets/chez/docs/design/2026-05-27-chez-target-design.md`
   (the target) and
   `targets/chez/docs/design/2026-05-29-chez-standalone-distribution-design.md`
   (its distribution).
3. For a long build, drive it as a **grove** (see the `grove` skill) rather than
   a single up-front plan — the chez target was built that way.

## Step 2: Create the emitter crate

Per the crate-home convention, a target's own crates live under its
`tools/` (a per-target emitter is target-specific, so it homes in the
target unit, not `_shared`):

```text
targets/{id}/tools/emit-{id}/
  Cargo.toml
  src/
    lib.rs
    naming.rs            — ObjC selector → language identifier conventions
    ffi_type_mapping.rs  — FfiTypeMapper impl
    method_filter.rs     — which methods/params are bindable vs. deferred
    emit_class.rs
    emit_protocol.rs
    emit_enums.rs
    emit_constants.rs
    emit_functions.rs
    emit_framework.rs     — TargetInfo + TargetEmitter impl, per-framework driver
```

### Cargo.toml

```toml
[package]
name = "apianyware-emit-{id}"
version.workspace = true
edition.workspace = true
license.workspace = true
description = "{Language} code generation: <one line on the idiom — e.g. 'idiomatic Chez library form, foreign-procedure FFI, guardian-managed lifetimes'>"

[dependencies]
apianyware-types.workspace = true
apianyware-emit.workspace = true
serde_json.workspace = true

[dev-dependencies]
tempfile = "3"

[lints]
workspace = true
```

In the root `Cargo.toml`: add `"targets/{id}/tools/emit-{id}"` to `[workspace]
members` and `apianyware-emit-{id} = { path = "targets/{id}/tools/emit-{id}" }`
to `[workspace.dependencies]`.

### Implement `FfiTypeMapper`

If the target needs a distinct FFI type mapping (it will):

```rust
use apianyware_emit::ffi_type_mapping::FfiTypeMapper;
use apianyware_types::type_ref::TypeRef;

pub struct {Lang}FfiTypeMapper;

impl FfiTypeMapper for {Lang}FfiTypeMapper {
    fn map_type(&self, type_ref: &TypeRef, is_return_type: bool) -> String {
        // Map each TypeRefKind to the target's FFI type token.
        todo!()
    }
}
```

### Implement `TargetInfo` + `TargetEmitter`

In `emit_framework.rs`. `TargetInfo` is **three fields** — there is no
`supported_styles` / `default_style`:

```rust
use apianyware_emit::target_emitter::{TargetInfo, TargetEmitter, EmitResult};
use apianyware_types::framework::Framework;
use std::io;
use std::path::Path;

pub const {LANG}_TARGET_INFO: TargetInfo = TargetInfo {
    id: "{id}",                  // CLI --target value + on-disk dir
    display_name: "{Language}",
    generated_subdir: "generated", // subdir under bindings/<platform>/ for framework
                                    // output. racket uses "generated"; chez uses
                                    // "apianyware" so Chez's (apianyware <fw> <cls>)
                                    // library-name resolution finds emitted files.
};

pub struct {Lang}Emitter;

impl TargetEmitter for {Lang}Emitter {
    fn target_info(&self) -> &TargetInfo { &{LANG}_TARGET_INFO }

    // No `style` parameter — one binding style per target (ADR-0004).
    fn emit_framework(&self, framework: &Framework, output_dir: &Path)
        -> io::Result<EmitResult>
    {
        // Create {output_dir}/{framework}/ and emit the target's idiomatic source.
        todo!()
    }
}
```

(The trait and types live in `targets/_shared/tools/emit/src/target_emitter.rs`.
It was once `binding_style.rs`, but the `BindingStyle` enum is gone — ADR-0004.)

### Key design decisions per language

- **Naming** — ObjC selectors → the language's identifier style.
- **Dispatch** — how methods are called (direct FFI message-send, etc.) and how
  Scheme/native callbacks become ObjC IMPs/blocks/delegates.
- **Memory model** — how the language's GC/ownership interacts with ObjC
  retain/release. Racket uses per-object finalizers; chez uses a guardian +
  entry-point autoreleasepool (ADR-0007).
- **Block / delegate bridging** — closures → ObjC blocks; native callbacks →
  delegate instances.
- **Error handling** — error-out params → the language's error model (chez:
  `(values result error)`, ADR-0006).

Use `targets/racket/tools/emit-racket/` and `targets/chez/tools/emit-chez/` as
reference implementations — they make *different* idiomatic choices on purpose.

## Step 3: Create the runtime library

Create the target's runtime under `targets/{id}/bindings/<platform>/` (racket:
`runtime/`; chez: `apianyware/runtime/`). Typical modules:

| Module | Purpose |
|--------|---------|
| Swift/dylib loader | conditional load of `libAPIAnyware{Lang}.dylib` |
| Object base | wrap ObjC `id` pointers; lifetime (finalizer or guardian) |
| Coercion | native → ObjC argument conversion |
| Dispatch | block / delegate / dynamic-subclass bridging |
| Type mapping | string/array/dictionary + geometry structs (ftypes/cstructs) |

## Step 4: Create the native adapter (Swift dylib)

The native adapter is a **per-target, hermetically-isolated** Swift package
(ADR-0011 — no shared `APIAnywareCommon` substrate) at
`targets/{id}/adapters/<platform>/`. If the language needs a Swift dylib:

1. Create `targets/{id}/adapters/<platform>/Package.swift` declaring a
   `.library(name: "APIAnyware{Lang}", type: .dynamic, …)` product, with sources
   under `sources/` — standalone, importing no shared substrate (gerbil ships
   *no* dylib at all, ADR-0017).
2. Add language-specific modules (block/delegate bridging, GC prevention).
3. `swift build --product APIAnyware{Lang} && swift test` from the package dir.
4. Author the adapter's `spec.apiw` (§24–26 roles / runtime services /
   direct-call policy) beside `Package.swift` — the target-model adapter entity.

## Step 5: Register with the generation CLI

Emitters are registered in one place — `targets/_shared/tools/generate-cli/src/registry.rs`,
`EmitterRegistry::new()`:

```rust
let emitters: Vec<Box<dyn TargetEmitter>> = vec![
    Box::new(apianyware_emit_racket::RacketEmitter),
    Box::new(apianyware_emit_chez::ChezEmitter),
    Box::new(apianyware_emit_{id}::{Lang}Emitter),   // ← add this
];
```

Add `apianyware-emit-{id}` as a `cli` dependency. The registry keys on
`target_info().id`, so `--target {id}` and `--list-targets` work with no
further wiring. (`--target` takes repeated values; default is all registered
languages.)

## Step 6: Snapshot / golden tests (optional but recommended)

The shared harness (`apianyware_emit::snapshot_testing::GoldenTest`) gives
deterministic golden tests against the 5-class `TestKit` fixture
(`build_snapshot_test_framework()`):

```rust
use apianyware_emit::snapshot_testing::GoldenTest;
use apianyware_emit::test_fixtures::build_snapshot_test_framework;
use apianyware_emit_{id}::emit_framework::{Lang}Emitter;
use apianyware_emit::target_emitter::TargetEmitter;

#[test]
fn snapshot_{id}_testkit() {
    let framework = build_snapshot_test_framework();
    let tmp = tempfile::tempdir().unwrap();
    {Lang}Emitter.emit_framework(&framework, tmp.path()).expect("emit");
    let golden = GoldenTest::new(&golden_dir(), "{id}");   // (dir, language) — no BindingStyle
    golden.assert_matches(&tmp.path().join("testkit")).expect("snapshot");
}
```

Generate goldens with `UPDATE_GOLDEN=1 cargo test -p apianyware-emit-{id}`.
**Target asymmetry is fine:** racket uses external golden files
(`tests/golden/`); chez instead relies on per-module inline `#[test]`s in
`emit-chez/src/*.rs` plus the VM-verified sample-app portfolio (below). Pick what
fits the target — there is no requirement that all targets test emission the same
way.

## Step 7: Build and VM-verify the sample apps

Implement the standard sample apps (`apps/macos/docs/_index.md`) under
`targets/{id}/app-implementations/<platform>/<app>/`. The runtime-feature ladder
(`hello-window` → `ui-controls-gallery` → `scenekit-viewer` → `pdfkit-viewer` →
`mini-browser` → `note-editor` → `drawing-canvas`) is ordered so each app adds one
runtime piece and a regression localises to the newest one.

**Every app gets a dedicated TestAnyware VM-verification, and CLI smoke never
satisfies the bar** — a window must actually draw and behave. Record each app's
result under `targets/{id}/bindings/<platform>/reports/<app>/report.md` (+
screenshots) and `targets/{id}/app-implementations/<platform>/<app>/learnings.md`.
See the existing reports under `targets/<id>/docs/reference.md` for the format and
the no-Chez-VM recipe in `targets/chez/docs/reference.md` §9.

## Step 8: Bundling / distribution

Sample apps must be packaged as `.app` bundles for a correct menu-bar name
(`CFBundleName`) and a per-app TCC identity (a unique CDHash). The existing
targets take **different** approaches — pick what fits the language:

- **racket** (`bundle-racket`, targets/racket/docs/reference.md §9) — a Swift
  **stub-launcher** + the source tree staged under `Resources/`, exec'ing the
  system runtime. Build: `cargo run --example bundle_app -p
  apianyware-bundle-racket -- <script>`.
- **chez** (`bundle-chez`, targets/chez/docs/reference.md §9, ADR-0009) — a
  **self-contained standalone binary** that embeds the language kernel +
  whole-program boot, so it needs no runtime installed on the target machine.
  Build: `cargo run --example bundle_app -p apianyware-bundle-chez --
  <script>`.
- **gerbil** (`bundle-gerbil`, targets/gerbil/docs/reference.md §8) — the language's
  own **`gxc -exe` static-runtime binary** (the toolchain already embeds the
  Gambit runtime) + vendoring/relocating the one Homebrew dylib dependency
  (openssl@3) into `Contents/Frameworks/`. Build: `cargo run --example
  bundle_app -p apianyware-bundle-gerbil -- <script>`.

The language-agnostic `apianyware-stub-launcher` crate provides the `.app`
skeleton + codesigning; per-target bundler crates do dependency discovery and
staging. Bundle ids are `com.linkuistics.<NoSpaceTitle>`; display names come from
the H1 of `apps/macos/<app>/docs/spec.md`.

## Step 9: Document the target

A target is **not done until its docs exist in the canonical structure**
(ADR-0024). Some of these docs you have been writing all along — the design spec
since Step 1, per-app `learnings.md` and VM-verify `reports/` since Step 7.
This step is where you fill **every** remaining slot of the per-language tier and
confirm the unit is self-describing. Do not invent a layout; fill the one below.

The canonical per-target doc layout — two co-located doc sets (§18 target docs at
`docs/`, §22 binding mapping docs at `bindings/<platform>/docs/`). Create each slot
that applies:

```text
targets/<id>/
  README.md                       # target overview / index: what this target is,
                                  #   how it's built, where the pieces live,
                                  #   pointers into docs/. The entry point.
  docs/                           # §18 TARGET docs — a map + four deep-dives
    overview.md                   # the §18 map: what the target is, idiom posture,
                                  #   links into the deep-dives + the unit layout
    language-characteristics.md   # typing, GC, macros, module system — the relevant traits
    ffi-model.md                  # the FFI/embedding mechanism, dispatch, memory, threading
    idiom-map.md                  # a THIN pointer to idioms/docs/idiom-map.md (don't copy it)
    representability.md           # §20 capability × §30 weirdness → the §7.7 floor
    reference.md                  # the deep reference a future maintainer reads first
                                  #   (FFI patterns, quirks, a distribution section)
    developer-guide.md            # OPTIONAL — a user-facing "how to write an app in
                                  #   <lang>" guide. racket has one; chez/gerbil/sbcl
                                  #   make the §22 bindings/.../user-guide.md their
                                  #   primary user doc. Don't create an empty stub.
    design/
      YYYY-MM-DD-<id>-design.md   # the design spec(s) from Step 1 onward
    research/
      YYYY-MM-DD-<topic>-spike/   # per-target spikes + their evidence
  bindings/<platform>/docs/       # §22 BINDING MAPPING docs — every one points at the
                                  #   authored .apiw entities + cites apianyware-conformance
    user-guide.md                 # how to use the binding to write an app
    platform-docs-mapping.md      # how the platform's own API docs map onto this binding
    api-coverage.md               # coverage — CITING apianyware-conformance, not a copy
    unsafe-escape-hatches.md      # the unsafe/raw seams and when to reach for them
  app-implementations/<platform>/<app>/
    README.md                     # per-app overview
    learnings.md                  # what THIS target had to do to make THIS app work
  bindings/<platform>/reports/<app>/report.md   # the VM-verification report (+ screenshots)
```

For each slot:

1. **`README.md`** — write the target's index: a paragraph on what the target is
   and its idiom posture, the on-disk map (emitter crate, runtime, dylib if any,
   bundler), and links into `docs/`. Model it on `targets/gerbil/README.md`.
2. **§18 `docs/` target docs** — the map (`overview.md`) + the four deep-dives
   (`language-characteristics.md`, `ffi-model.md`, `idiom-map.md`,
   `representability.md`). `idiom-map.md` is a **thin pointer** to the
   authoritative `idioms/docs/idiom-map.md`, not a copy. `representability.md`
   narrates how the §20 capability profile × the platform's §30 weirdness yields
   the §7.7 floor — citing `apianyware-conformance` for any derived numbers, never
   snapshotting them (constraint 4). racket/chez/gerbil/sbcl `docs/` are the worked
   examples.
3. **`docs/reference.md`** — consolidate the target-wide learnings accumulated
   across Steps 3–8: FFI mechanism, naming, dispatch, memory model, block/delegate
   bridging, error handling, runtime quirks, and a **distribution** section. The
   worked-example doc the next target's author reads.
4. **§22 `bindings/<platform>/docs/` mapping docs** — `user-guide.md`,
   `platform-docs-mapping.md`, `api-coverage.md`, `unsafe-escape-hatches.md`. Every
   one **points at the authored `.apiw` entities** and **cites
   `apianyware-conformance`** for coverage rather than copying recomputable tables.
   For a target with no `developer-guide.md` (chez/gerbil/sbcl), `user-guide.md` is
   the **primary user doc** — write it so.
5. **`docs/developer-guide.md`** — only **where warranted**. If app authors need a
   narrative "how to write an app in this language" beyond the §22 `user-guide.md`,
   write it (see `targets/racket/docs/developer-guide.md`); otherwise skip it.
6. **`docs/design/`** + **`docs/research/`** — ensure every design spec and spike
   you raised during the build lives here, evidence intact (cross-cutting specs
   co-locate by domain — there is no central `docs/specs/`), per Step 1 and ADR-0024.
7. **`app-implementations/<platform>/<app>/learnings.md`** +
   **`bindings/<platform>/reports/<app>/report.md`** — one of each per sample app,
   from Step 7. Confirm all seven exist.

ADRs are the **exception** and do **not** go under the target unit — target
decisions land in the central `adr/` log with global numbering (ADR-0024).

## Step 10: Validate and review

- Rust tests pass (`cargo test`); any snapshot/golden tests pass.
- Every sample app passes its TestAnyware VM verification.
- **Docs exist in the canonical structure (Step 9)** — `README.md`, the §18
  `docs/` set (`overview` + the four deep-dives, `reference.md`), the §22
  `bindings/<platform>/docs/` set, `docs/design/`/`docs/research/` (if any spikes),
  and per app a `learnings.md` + `bindings/<platform>/reports/<app>/report.md`.
  This is part of the target's definition of done, not optional polish (ADR-0024).
- `README.md` (the repo-root one) Current Status updated with the target.

## Reference implementations

- **racket** — `targets/racket/tools/emit-racket/`, `targets/racket/`,
  `targets/racket/docs/reference.md`. Stdlib-rich; stub-launcher distribution.
- **chez** — `targets/chez/tools/emit-chez/`, `targets/chez/`,
  `targets/chez/docs/reference.md`. Idiomatic Scheme; self-contained standalone
  distribution (ADR-0009).
- **gerbil** — `targets/gerbil/tools/emit-gerbil/`, `targets/gerbil/`,
  `targets/gerbil/docs/reference.md`. Compiled-FFI OO Scheme (manifest `defclass`
  graph, dual dispatch surface, ADR-0020); ObjC-in-gsc native core, no Swift
  dylib (ADR-0017); self-contained `gxc -exe` distribution.
- **sbcl** — `targets/sbcl/tools/emit-sbcl/`, `targets/sbcl/`,
  `targets/sbcl/docs/reference.md`. CLOS/MOP projection; `save-lisp-and-die`
  dumped-image distribution behind a Swift stub (ADR-0041).
- **Shared framework** — `targets/_shared/tools/emit/`.
- **Native adapters** — `targets/<id>/adapters/macos/` (per-target Swift package, no
  shared substrate — ADR-0011; gerbil has none, ADR-0017).

## Checklist

```text
Build
[ ] Design spec written (targets/<id>/docs/design/YYYY-MM-DD-<id>-design.md); ADR-0005 idiom posture understood
[ ] emit-<id> crate created at targets/<id>/tools/emit-<id>, compiles, tests pass
[ ] TargetInfo {id, display_name, generated_subdir} + TargetEmitter::emit_framework implemented
[ ] Runtime library written under targets/<id>/bindings/<platform>/, loads in the target language
[ ] Native adapter (targets/<id>/adapters/<platform>/) builds and FFI verified (if needed)
[ ] Registered in EmitterRegistry::new() (targets/_shared/tools/generate-cli/src/registry.rs); --target <id> works
[ ] Snapshot/golden or inline emission tests in place (target's choice)
[ ] All 7 sample apps built under targets/<id>/app-implementations/<platform>/
[ ] All 7 sample apps pass TestAnyware VM verification
[ ] Bundler integration: apps package as .app (stub-launcher or standalone)

Document the target (Step 9 — canonical per-language structure, ADR-0024)
[ ] targets/<id>/README.md (target overview / index)
[ ] §18 targets/<id>/docs/ set: overview + language-characteristics + ffi-model + idiom-map (thin pointer) + representability
[ ] targets/<id>/docs/reference.md populated (incl. a distribution section)
[ ] §22 targets/<id>/bindings/<platform>/docs/ set: user-guide + platform-docs-mapping + api-coverage (cites apianyware-conformance) + unsafe-escape-hatches
[ ] targets/<id>/docs/developer-guide.md — where warranted (racket has one; else the §22 user-guide.md is the primary user doc)
[ ] targets/<id>/docs/design/ holds every build-time design spec; docs/research/ holds every spike + its evidence
[ ] app-implementations/<platform>/<app>/learnings.md for each of the 7 apps
[ ] bindings/<platform>/reports/<app>/report.md for each of the 7 apps
[ ] Target ADRs raised in the central adr/ log (NOT under the target unit)
[ ] README.md (repo root) Current Status updated
```
