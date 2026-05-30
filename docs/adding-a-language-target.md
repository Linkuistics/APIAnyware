# Adding a New Language Target

Step-by-step guide for adding a language target to APIAnyware-MacOS. Written
against the real two-target world (`racket` and `chez`) — follow it and you could
plausibly stand up a third.

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

> **Knowledge system:** after building a target, populate
> `knowledge/targets/<id>.md` with target-wide learnings (FFI patterns, runtime
> quirks, distribution). `racket.md` and `chez.md` are the two worked examples.

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
2. **Write a design spec** to `docs/specs/YYYY-MM-DD-<id>-design.md` recording at
   minimum:
   - **Language / display name** — e.g. "Chez Scheme".
   - **Target id** — the CLI `--lang` value and on-disk dir name (`racket`,
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

   Two concrete design specs exist to model yours on:
   `docs/specs/2026-05-27-chez-target-design.md` (the target) and
   `docs/specs/2026-05-29-chez-standalone-distribution-design.md` (its
   distribution).
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
    emit_framework.rs     — LanguageInfo + LanguageEmitter impl, per-framework driver
```

### Cargo.toml

```toml
[package]
name = "apianyware-macos-emit-{id}"
version.workspace = true
edition.workspace = true
license.workspace = true
description = "{Language} code generation: <one line on the idiom — e.g. 'idiomatic Chez library form, foreign-procedure FFI, guardian-managed lifetimes'>"

[dependencies]
apianyware-macos-types.workspace = true
apianyware-macos-emit.workspace = true
serde_json.workspace = true

[dev-dependencies]
tempfile = "3"

[lints]
workspace = true
```

In the root `Cargo.toml`: add `"generation/crates/emit-{id}"` to `[workspace]
members` and `apianyware-macos-emit-{id} = { path = "…" }` to
`[workspace.dependencies]`.

### Implement `FfiTypeMapper`

If the target needs a distinct FFI type mapping (it will):

```rust
use apianyware_macos_emit::ffi_type_mapping::FfiTypeMapper;
use apianyware_macos_types::type_ref::TypeRef;

pub struct {Lang}FfiTypeMapper;

impl FfiTypeMapper for {Lang}FfiTypeMapper {
    fn map_type(&self, type_ref: &TypeRef, is_return_type: bool) -> String {
        // Map each TypeRefKind to the target's FFI type token.
        todo!()
    }
}
```

### Implement `LanguageInfo` + `LanguageEmitter`

In `emit_framework.rs`. `LanguageInfo` is **three fields** — there is no
`supported_styles` / `default_style`:

```rust
use apianyware_macos_emit::language_emitter::{LanguageInfo, LanguageEmitter, EmitResult};
use apianyware_macos_types::framework::Framework;
use std::io;
use std::path::Path;

pub const {LANG}_LANGUAGE_INFO: LanguageInfo = LanguageInfo {
    id: "{id}",                  // CLI --lang value + on-disk dir
    display_name: "{Language}",
    generated_subdir: "generated", // subdir under targets/{id}/ for framework output.
                                    // racket uses "generated"; chez uses "apianyware"
                                    // so Chez's (apianyware <fw> <cls>) library-name
                                    // resolution finds emitted files.
};

pub struct {Lang}Emitter;

impl LanguageEmitter for {Lang}Emitter {
    fn language_info(&self) -> &LanguageInfo { &{LANG}_LANGUAGE_INFO }

    // No `style` parameter — one binding style per target (ADR-0004).
    fn emit_framework(&self, framework: &Framework, output_dir: &Path)
        -> io::Result<EmitResult>
    {
        // Create {output_dir}/{framework}/ and emit the target's idiomatic source.
        todo!()
    }
}
```

(The trait and types live in `emit/src/language_emitter.rs`. It was once
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
let emitters: Vec<Box<dyn LanguageEmitter>> = vec![
    Box::new(apianyware_macos_emit_racket::RacketEmitter),
    Box::new(apianyware_macos_emit_chez::ChezEmitter),
    Box::new(apianyware_macos_emit_{id}::{Lang}Emitter),   // ← add this
];
```

Add `apianyware-macos-emit-{id}` as a `cli` dependency. The registry keys on
`language_info().id`, so `--lang {id}` and `--list-languages` work with no
further wiring. (`--lang` takes repeated values; default is all registered
languages.)

## Step 6: Snapshot / golden tests (optional but recommended)

The shared harness (`apianyware_macos_emit::snapshot_testing::GoldenTest`) gives
deterministic golden tests against the 5-class `TestKit` fixture
(`build_snapshot_test_framework()`):

```rust
use apianyware_macos_emit::snapshot_testing::GoldenTest;
use apianyware_macos_emit::test_fixtures::build_snapshot_test_framework;
use apianyware_macos_emit_{id}::emit_framework::{Lang}Emitter;
use apianyware_macos_emit::language_emitter::LanguageEmitter;

#[test]
fn snapshot_{id}_testkit() {
    let framework = build_snapshot_test_framework();
    let tmp = tempfile::tempdir().unwrap();
    {Lang}Emitter.emit_framework(&framework, tmp.path()).expect("emit");
    let golden = GoldenTest::new(&golden_dir(), "{id}");   // (dir, language) — no BindingStyle
    golden.assert_matches(&tmp.path().join("testkit")).expect("snapshot");
}
```

Generate goldens with `UPDATE_GOLDEN=1 cargo test -p apianyware-macos-emit-{id}`.
**Target asymmetry is fine:** racket uses external golden files
(`tests/golden/`); chez instead relies on per-module inline `#[test]`s in
`emit-chez/src/*.rs` plus the VM-verified sample-app portfolio (below). Pick what
fits the target — there is no requirement that all targets test emission the same
way.

## Step 7: Build and VM-verify the sample apps

Implement the standard sample apps (`knowledge/apps/_index.md`) under
`generation/targets/{id}/apps/<app>/`. The runtime-feature ladder
(`hello-window` → `ui-controls-gallery` → `scenekit-viewer` → `pdfkit-viewer` →
`mini-browser` → `note-editor` → `drawing-canvas`) is ordered so each app adds one
runtime piece and a regression localises to the newest one.

**Every app gets a dedicated TestAnyware VM-verification, and CLI smoke never
satisfies the bar** — a window must actually draw and behave. Record each app's
result under `generation/targets/{id}/test-results/<app>/report.md` (+
screenshots) and `knowledge/matrix/<app>/{id}.md`. See `knowledge/targets/`
existing reports for the format and the no-Chez-VM recipe in `chez.md` §9.

## Step 8: Bundling / distribution

Sample apps must be packaged as `.app` bundles for a correct menu-bar name
(`CFBundleName`) and a per-app TCC identity (a unique CDHash). The two targets
take **different** approaches — pick what fits the language:

- **racket** (`bundle-racket`, knowledge/targets/racket.md §9) — a Swift
  **stub-launcher** + the source tree staged under `Resources/`, exec'ing the
  system runtime. Build: `cargo run --example bundle_app -p
  apianyware-macos-bundle-racket -- <script>`.
- **chez** (`bundle-chez`, knowledge/targets/chez.md §9, ADR-0009) — a
  **self-contained standalone binary** that embeds the language kernel +
  whole-program boot, so it needs no runtime installed on the target machine.
  Build: `cargo run --example bundle_app -p apianyware-macos-bundle-chez --
  <script>`.

The language-agnostic `apianyware-macos-stub-launcher` crate provides the `.app`
skeleton + codesigning; per-target bundler crates do dependency discovery and
staging. Bundle ids are `com.linkuistics.<NoSpaceTitle>`; display names come from
the H1 of `knowledge/apps/<app>/spec.md`.

## Step 9: Validate and review

- Rust tests pass (`cargo test`); any snapshot/golden tests pass.
- Every sample app passes its TestAnyware VM verification.
- `knowledge/targets/{id}.md` populated with learnings + distribution.
- `README.md` Current Status updated with the target.

## Reference implementations

- **racket** — `generation/crates/emit-racket/`, `generation/targets/racket/`,
  `knowledge/targets/racket.md`. Stdlib-rich; stub-launcher distribution.
- **chez** — `generation/crates/emit-chez/`, `generation/targets/chez/`,
  `knowledge/targets/chez.md`. Idiomatic Scheme; self-contained standalone
  distribution (ADR-0009).
- **Shared framework** — `generation/crates/emit/`.
- **Swift helpers** — `swift/Sources/APIAnywareCommon/`.

## Checklist

```text
[ ] Design spec written (docs/specs/YYYY-MM-DD-<id>-design.md); ADR-0005 idiom posture understood
[ ] emit-<id> crate created, compiles, tests pass
[ ] LanguageInfo {id, display_name, generated_subdir} + LanguageEmitter::emit_framework implemented
[ ] Runtime library written, loads in the target language
[ ] Swift dylib builds and FFI verified (if needed)
[ ] Registered in EmitterRegistry::new() (cli/src/registry.rs); --lang <id> works
[ ] Snapshot/golden or inline emission tests in place (target's choice)
[ ] All 7 sample apps built
[ ] All 7 sample apps pass TestAnyware VM verification (one report each)
[ ] Bundler integration: apps package as .app (stub-launcher or standalone)
[ ] knowledge/targets/<id>.md populated (incl. a distribution section)
[ ] README.md Current Status updated
```
