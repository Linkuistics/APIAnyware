# Adding a New Language Target

Step-by-step guide for adding a language target to APIAnyware. Written
against the real two-target world (`racket` and `chez`) — follow it and you could
plausibly stand up a third.

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
> The on-disk unit is `generation/targets/<id>/`. There is **one binding style
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

> **Docs co-locate with the target (ADR-0024):** the project's documentation is
> split into a **main tier** (cross-cutting, under the top-level `docs/` tree) and
> a **per-language tier** co-located inside `generation/targets/<id>/`. You
> **read** the main tier and **produce** the per-language tier; doing so is a
> sequenced step of authoring, not an afterthought (Step 9), and a target is not
> *done* until its docs exist in the canonical structure. See **"Documentation"**
> immediately below for the read-vs-produce split. `racket`, `chez`, and `gerbil`
> are the worked examples (`generation/targets/<id>/docs/reference.md`).

## Documentation: read the main tier, produce the per-language tier

Per **ADR-0024**, documentation co-locates with code on the same axis ADR-0011
uses for the binding itself. Before you start, know which docs you *read* and
which you *produce* — and treat the ones you produce as deliverables, not notes.

**Read (the main tier — shared, you do not edit these to add a target):**

| Doc | Why you read it |
|---|---|
| `docs/pipeline/` (`collection.md`, `analysis.md`, `type-mapping.md`, `emitter-contract.md`, …) | how `collect → analyse → generate` feeds your emitter; the contract your `TargetEmitter` must satisfy |
| `docs/apps/` (`_index.md` + per-app `spec.md`) | the language-agnostic sample-app portfolio you must implement and VM-verify |
| `docs/testing/` | the TestAnyware VM-verification methodology every app is held to |
| ADR-0010, ADR-0011 | the north star (native library *is* the binding) and hermetic isolation — why you build standalone |
| ADR-0004, ADR-0005 | one binding style per target; maximally idiomatic, not a portable subset |
| ADR-0024 | this read-vs-produce split and the canonical per-target doc layout |
| `docs/prd/2026-06-14-docs-restructure-main-and-per-language.md` | the full doc structure and move-map |

**Produce (the per-language tier — co-located in `generation/targets/<id>/`):**

| Slot | Contents | Produced during |
|---|---|---|
| `README.md` | target overview / index — the entry point to the unit | Step 9 (as the build settles) |
| `docs/reference.md` | the deep target reference: FFI patterns, dispatch, memory model, runtime quirks, distribution | Steps 3–8, consolidated in Step 9 |
| `docs/developer-guide.md` | user-facing app-writing guide — **where warranted** (racket has one; chez/gerbil rely on `reference.md`) | Step 9 |
| `docs/design/` | the per-target design spec(s) raised while building (`YYYY-MM-DD-<id>-design.md`, distribution design, native-binding design) | Step 1 onward |
| `docs/research/` | per-target spikes and their evidence (dispatch, threading, standalone-distribution probes) | whenever a spike is run |
| `apps/<app>/learnings.md` | per-app realization notes — what this target had to do to make that app work | Step 7, per app |
| `test-results/<app>/report.md` | the VM-verification report (+ screenshots) for each app — already co-located | Step 7, per app |

ADRs are **the one exception**: target-flavoured decisions still land in the
central `docs/adr/` log with global numbering (the decision graph crosses target
boundaries — gerbil ADRs cite chez ADRs, supersession chains span targets), per
ADR-0024. Raise ADRs there as you make them, not under the target unit.

## Prerequisites

- The shared emitter framework (`generation/crates/emit/`) is available.
- At least one target is complete as a reference: **racket** (the most complete)
  and **chez** (the idiomatic-Scheme + self-contained-bundle reference).
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
   `generation/targets/<id>/docs/design/YYYY-MM-DD-<id>-design.md` (per-target
   docs co-locate, ADR-0024; central `docs/specs/` is for cross-cutting specs
   only) — recording at minimum:
   - **Language / display name** — e.g. "Chez Scheme".
   - **Target id** — the CLI `--target` value and on-disk dir name (`racket`,
     `chez`). A plain language id; no `{lang}-{paradigm}` slug.
   - **Implementation(s)** — which compiler/runtime (e.g. Chez 10.4.1).
   - **Idiom commitments** — the language constructs the emitter leans on, per
     ADR-0005 (chez: `library` form, `foreign-procedure`/`foreign-callable`,
     ftypes, guardians).
   - **Swift dylib** — `libAPIAnyware{Lang}.dylib`, if needed.
   - **Emitter crate** — `emit-{id}`.
   - **Runtime location** — `generation/targets/{id}/runtime/` (or the target's
     own convention — chez uses `apianyware/runtime/`).
   - **Distribution model** — how a sample app ships (racket: stub-launcher +
     system runtime; chez: self-contained standalone binary, ADR-0009).

   Two concrete design specs exist to model yours on, both now co-located in the
   chez unit: `generation/targets/chez/docs/design/2026-05-27-chez-target-design.md`
   (the target) and
   `generation/targets/chez/docs/design/2026-05-29-chez-standalone-distribution-design.md`
   (its distribution).
3. For a long build, drive it as a **grove** (see the `grove` skill) rather than
   a single up-front plan — the chez target was built that way.

## Step 2: Create the emitter crate

```text
generation/crates/emit-{id}/
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

In the root `Cargo.toml`: add `"generation/crates/emit-{id}"` to `[workspace]
members` and `apianyware-emit-{id} = { path = "…" }` to
`[workspace.dependencies]`.

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
    generated_subdir: "generated", // subdir under targets/{id}/ for framework output.
                                    // racket uses "generated"; chez uses "apianyware"
                                    // so Chez's (apianyware <fw> <cls>) library-name
                                    // resolution finds emitted files.
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

(The trait and types live in `emit/src/target_emitter.rs`. It was once
`binding_style.rs`, but the `BindingStyle` enum is gone — ADR-0004.)

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

Use `generation/crates/emit-racket/` and `generation/crates/emit-chez/` as
reference implementations — they make *different* idiomatic choices on purpose.

## Step 3: Create the runtime library

Create the target's runtime under `generation/targets/{id}/` (racket:
`runtime/`; chez: `apianyware/runtime/`). Typical modules:

| Module | Purpose |
|--------|---------|
| Swift/dylib loader | conditional load of `libAPIAnyware{Lang}.dylib` |
| Object base | wrap ObjC `id` pointers; lifetime (finalizer or guardian) |
| Coercion | native → ObjC argument conversion |
| Dispatch | block / delegate / dynamic-subclass bridging |
| Type mapping | string/array/dictionary + geometry structs (ftypes/cstructs) |

## Step 4: Create or extend the Swift dylib

If the language needs a Swift dylib:

1. Check if `swift/Sources/APIAnyware{Lang}/` exists.
2. If not, add a `.library(name: "APIAnyware{Lang}", type: .dynamic, …)` product
   to `swift/Package.swift` and create the source dir importing `APIAnywareCommon`.
3. Add language-specific modules (block/delegate bridging, GC prevention).
4. `swift build && swift test`.

## Step 5: Register with the generation CLI

Emitters are registered in one place — `generation/crates/cli/src/registry.rs`,
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

Implement the standard sample apps (`docs/apps/_index.md`) under
`generation/targets/{id}/apps/<app>/`. The runtime-feature ladder
(`hello-window` → `ui-controls-gallery` → `scenekit-viewer` → `pdfkit-viewer` →
`mini-browser` → `note-editor` → `drawing-canvas`) is ordered so each app adds one
runtime piece and a regression localises to the newest one.

**Every app gets a dedicated TestAnyware VM-verification, and CLI smoke never
satisfies the bar** — a window must actually draw and behave. Record each app's
result under `generation/targets/{id}/test-results/<app>/report.md` (+
screenshots) and `generation/targets/{id}/apps/<app>/learnings.md`. See the existing reports under
`generation/targets/<id>/docs/reference.md` for the format and the no-Chez-VM
recipe in `generation/targets/chez/docs/reference.md` §9.

## Step 8: Bundling / distribution

Sample apps must be packaged as `.app` bundles for a correct menu-bar name
(`CFBundleName`) and a per-app TCC identity (a unique CDHash). The existing
targets take **different** approaches — pick what fits the language:

- **racket** (`bundle-racket`, generation/targets/racket/docs/reference.md §9) — a Swift
  **stub-launcher** + the source tree staged under `Resources/`, exec'ing the
  system runtime. Build: `cargo run --example bundle_app -p
  apianyware-bundle-racket -- <script>`.
- **chez** (`bundle-chez`, generation/targets/chez/docs/reference.md §9, ADR-0009) — a
  **self-contained standalone binary** that embeds the language kernel +
  whole-program boot, so it needs no runtime installed on the target machine.
  Build: `cargo run --example bundle_app -p apianyware-bundle-chez --
  <script>`.
- **gerbil** (`bundle-gerbil`, generation/targets/gerbil/docs/reference.md §8) — the language's
  own **`gxc -exe` static-runtime binary** (the toolchain already embeds the
  Gambit runtime) + vendoring/relocating the one Homebrew dylib dependency
  (openssl@3) into `Contents/Frameworks/`. Build: `cargo run --example
  bundle_app -p apianyware-bundle-gerbil -- <script>`.

The language-agnostic `apianyware-stub-launcher` crate provides the `.app`
skeleton + codesigning; per-target bundler crates do dependency discovery and
staging. Bundle ids are `com.linkuistics.<NoSpaceTitle>`; display names come from
the H1 of `docs/apps/<app>/spec.md`.

## Step 9: Document the target

A target is **not done until its docs exist in the canonical structure**
(ADR-0024). Some of these docs you have been writing all along — the design spec
since Step 1, per-app `learnings.md` and `test-results/` reports since Step 7.
This step is where you fill **every** remaining slot of the per-language tier and
confirm the unit is self-describing. Do not invent a layout; fill the one below.

The canonical per-target doc layout — create each slot that applies:

```text
generation/targets/<id>/
  README.md                       # target overview / index: what this target is,
                                  #   how it's built, where the pieces live,
                                  #   pointers into docs/ and apps/. The entry point.
  docs/
    reference.md                  # the deep reference: FFI patterns, naming, dispatch,
                                  #   memory model, block/delegate bridging, runtime
                                  #   quirks, a distribution section (§ like chez §9).
                                  #   This is the doc a future maintainer reads first.
    developer-guide.md            # OPTIONAL — a user-facing "how to write an app in
                                  #   <lang>" guide. Write one only where it earns its
                                  #   place (racket has one; chez/gerbil fold this into
                                  #   reference.md). Don't create an empty stub.
    design/
      YYYY-MM-DD-<id>-design.md   # the design spec(s) from Step 1 onward — the target
      ...                         #   design, distribution design, native-binding design
    research/
      YYYY-MM-DD-<topic>-spike/   # per-target spikes + their evidence (scripts,
      ...                         #   transcripts, screenshots, FINDINGS.md)
  apps/<app>/
    README.md                     # per-app overview
    learnings.md                  # what THIS target had to do to make THIS app work
  test-results/<app>/report.md    # the VM-verification report (+ screenshots)
```

For each slot:

1. **`README.md`** — write the target's index: a paragraph on what the target is
   and its idiom posture, the on-disk map (emitter crate, runtime, dylib if any,
   bundler), and links into `docs/` and `apps/`. Model it on
   `generation/targets/gerbil/README.md`.
2. **`docs/reference.md`** — consolidate the target-wide learnings accumulated
   across Steps 3–8: FFI mechanism, naming, dispatch, memory model, block/delegate
   bridging, error handling, runtime quirks, and a **distribution** section. This
   is the worked-example doc the next target's author reads; `racket`, `chez`, and
   `gerbil`'s `reference.md` are the templates.
3. **`docs/developer-guide.md`** — only **where warranted**. If app authors need
   a narrative "how to write an app in this language" beyond the reference, write
   it (see `generation/targets/racket/docs/developer-guide.md`); otherwise skip it
   and let `reference.md` carry that weight.
4. **`docs/design/`** — ensure every design spec you wrote during the build lives
   here (not in central `docs/specs/`), per Step 1 and ADR-0024.
5. **`docs/research/`** — move any spike directories you ran into here, with their
   evidence intact, so the *why* behind a non-obvious choice is recoverable.
6. **`apps/<app>/learnings.md`** + **`test-results/<app>/report.md`** — one of
   each per sample app, from Step 7. Confirm all seven exist.

ADRs are the **exception** and do **not** go under the target unit — target
decisions land in the central `docs/adr/` log with global numbering (ADR-0024).

## Step 10: Validate and review

- Rust tests pass (`cargo test`); any snapshot/golden tests pass.
- Every sample app passes its TestAnyware VM verification.
- **Docs exist in the canonical structure (Step 9)** — `README.md`,
  `docs/reference.md`, `docs/design/`, `docs/research/` (if any spikes), and per
  app a `learnings.md` + `test-results/.../report.md`. This is part of the
  target's definition of done, not optional polish (ADR-0024).
- `README.md` (the repo-root one) Current Status updated with the target.

## Reference implementations

- **racket** — `generation/crates/emit-racket/`, `generation/targets/racket/`,
  `generation/targets/racket/docs/reference.md`. Stdlib-rich; stub-launcher distribution.
- **chez** — `generation/crates/emit-chez/`, `generation/targets/chez/`,
  `generation/targets/chez/docs/reference.md`. Idiomatic Scheme; self-contained standalone
  distribution (ADR-0009).
- **gerbil** — `generation/crates/emit-gerbil/`, `generation/targets/gerbil/`,
  `generation/targets/gerbil/docs/reference.md`. Compiled-FFI OO Scheme (manifest `defclass`
  graph, dual dispatch surface, ADR-0020); ObjC-in-gsc native core, no Swift
  dylib (ADR-0017); self-contained `gxc -exe` distribution.
- **Shared framework** — `generation/crates/emit/`.
- **Swift helpers** — `swift/Sources/APIAnyware{Racket,Chez}/` (per-target, no
  shared substrate — ADR-0011; gerbil has none, ADR-0017).

## Checklist

```text
Build
[ ] Design spec written (generation/targets/<id>/docs/design/YYYY-MM-DD-<id>-design.md); ADR-0005 idiom posture understood
[ ] emit-<id> crate created, compiles, tests pass
[ ] TargetInfo {id, display_name, generated_subdir} + TargetEmitter::emit_framework implemented
[ ] Runtime library written, loads in the target language
[ ] Swift dylib builds and FFI verified (if needed)
[ ] Registered in EmitterRegistry::new() (cli/src/registry.rs); --target <id> works
[ ] Snapshot/golden or inline emission tests in place (target's choice)
[ ] All 7 sample apps built
[ ] All 7 sample apps pass TestAnyware VM verification
[ ] Bundler integration: apps package as .app (stub-launcher or standalone)

Document the target (Step 9 — canonical per-language structure, ADR-0024)
[ ] generation/targets/<id>/README.md (target overview / index)
[ ] generation/targets/<id>/docs/reference.md populated (incl. a distribution section)
[ ] generation/targets/<id>/docs/developer-guide.md — where warranted (racket has one; else skip)
[ ] generation/targets/<id>/docs/design/ holds every build-time design spec
[ ] generation/targets/<id>/docs/research/ holds every spike + its evidence
[ ] apps/<app>/learnings.md for each of the 7 apps
[ ] test-results/<app>/report.md for each of the 7 apps
[ ] Target ADRs raised in the central docs/adr/ log (NOT under the target unit)
[ ] README.md (repo root) Current Status updated
```
