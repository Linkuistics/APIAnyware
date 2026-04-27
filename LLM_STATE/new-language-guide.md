# Adding a New Language Target

Step-by-step guide for adding a language target to APIAnyware-MacOS.

> **Note:** A *target* is a language+paradigm combination (e.g., `racket-oo`,
> `racket-functional`, `haskell-monadic`). Each target is independent with its own
> emitter crate, runtime, generated output, and apps.

> **Knowledge system:** After creating a target, populate `knowledge/targets/{target}.md`
> with learnings. Run `./LLM_STATE/targets/{target}/run.sh` to start the three-phase
> work cycle (see `../Ravel-Lite/README.md`).

## Prerequisites

- Milestone 8 (Test Infrastructure & Workflow) is complete
- The shared emitter framework (`generation/crates/emit/`) is available
- At least one language target (Racket) has been completed as a reference
- The target language has a working FFI mechanism for calling C functions

## Step 1: Plan the target

Create the plan directory `LLM_STATE/targets/{target}/` with four files by following
`../Ravel-Lite/defaults/create-plan.md`. Start with `backlog.md` by instantiating
`LLM_STATE/targets/template.md`:

1. Copy the template structure into `backlog.md`
2. Fill in the header fields:
   - **Language** — display name
   - **Paradigm** — the binding style variant (e.g., "OO", "Functional", "Monadic")
   - **Target** — `{lang}-{paradigm}` slug (e.g., `haskell-monadic`)
   - **Implementations** — which compilers/runtimes (e.g., "GHC" for Haskell, "SBCL, CCL" for Common Lisp)
   - **Binding styles** — what paradigm variants to generate (e.g., "Monadic, Lens-based")
   - **Swift dylib** — `libAPIAnyware{Lang}.dylib`
   - **Status** — initial status (usually "not started")
   - **Emitter crate** — `emit-{target}`
   - **Runtime location** — `generation/targets/{target}/runtime/`
3. Each step uses Do/Verify/Observe structure: what to do, how to verify it worked, and what to note as learnings
4. Rename the style-specific steps (X.7, X.8) to match the binding styles
5. Add any language-specific notes

## Step 2: Create the emitter crate

```
generation/crates/emit-{target}/
  Cargo.toml
  src/
    lib.rs
    naming.rs
    method_filter.rs
    emit_class.rs
    emit_protocol.rs
    emit_enums.rs
    emit_constants.rs
    emit_framework.rs
```

### Cargo.toml

```toml
[package]
name = "apianyware-macos-emit-{target}"
version.workspace = true
edition.workspace = true
license.workspace = true
description = "{Language} ({Paradigm}) code generation: ..."

[dependencies]
apianyware-macos-types.workspace = true
apianyware-macos-emit.workspace = true
serde_json.workspace = true

[dev-dependencies]
tempfile = "3"

[lints]
workspace = true
```

### Add to workspace

In the root `Cargo.toml`:

1. Add `"generation/crates/emit-{target}"` to `[workspace] members`
2. Add `apianyware-macos-emit-{target} = { path = "generation/crates/emit-{target}" }` to `[workspace.dependencies]`

### Implement FfiTypeMapper

If the target language needs a different FFI type mapping than any existing language, implement the `FfiTypeMapper` trait:

```rust
use apianyware_macos_emit::ffi_type_mapping::FfiTypeMapper;
use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

pub struct {Lang}FfiTypeMapper;

impl FfiTypeMapper for {Lang}FfiTypeMapper {
    fn map_type(&self, type_ref: &TypeRef, is_return_type: bool) -> String {
        // Map each TypeRefKind to the target language's FFI type string
        todo!()
    }
}
```

### Implement LanguageInfo

In `emit_framework.rs`:

```rust
use apianyware_macos_emit::binding_style::{BindingStyle, LanguageInfo};

pub const {LANG}_LANGUAGE_INFO: LanguageInfo = LanguageInfo {
    id: "{lang}",
    display_name: "{Language}",
    supported_styles: &[BindingStyle::Functional],  // adjust per language
    default_style: BindingStyle::Functional,
};
```

### Key design decisions per language

- **Naming conventions** — how ObjC selectors map to the language's identifier style
- **Dispatch strategy** — how methods are called (direct FFI, message passing, etc.)
- **Memory model** — how the language's GC/ownership interacts with ObjC retain/release
- **Block bridging** — how closures/lambdas become ObjC blocks
- **Error handling** — how error-out parameters map to the language's error model

Use the Racket emitter (`generation/crates/emit-racket/`) as a reference implementation.

## Step 3: Create the runtime library

Create `generation/targets/{target}/runtime/` with source files in the target language.

Every runtime must provide:

| Module | Purpose |
|--------|---------|
| Swift helpers | Conditional loading of `libAPIAnyware{Lang}.dylib` |
| Object base | Wrap ObjC pointers with release finalizers |
| Coercion | Auto-convert native types to ObjC types for method parameters |
| Block bridging | Create ObjC blocks from native closures |
| Delegate bridging | Create ObjC delegate instances from native callbacks |
| Type mapping | String, array, dictionary conversions + geometry structs |
| Variadic helpers | Alternatives for variadic ObjC methods |

The runtime must work with and without the Swift dylib (graceful fallback to libobjc).

## Step 4: Create or extend the Swift dylib

If the language needs a Swift dylib:

1. Check if `swift/Sources/APIAnyware{Lang}/` exists (Chez and Gerbil have stubs)
2. If not, create a new product in `swift/Package.swift`:
   - Add a `.library(name: "APIAnyware{Lang}", type: .dynamic, targets: ["APIAnyware{Lang}"])`
   - Create `swift/Sources/APIAnyware{Lang}/` importing `APIAnywareCommon`
3. Add language-specific modules as needed (block bridging, delegate bridging, GC prevention)
4. Run `swift build` and `swift test`

## Step 5: Register with the generation CLI

In `generation/crates/cli/`:

1. Add the emitter crate as a dependency
2. Add the target to the `--lang` flag's accepted values
3. Wire up: `--lang {target}` → load enriched IR → call emitter → write output

## Step 6: Create snapshot tests and golden files

Use the shared snapshot testing harness (`apianyware_macos_emit::snapshot_testing`):

1. Create `generation/crates/emit-{target}/tests/snapshot_test.rs`:

```rust
use std::path::PathBuf;
use apianyware_macos_emit::binding_style::{BindingStyle, LanguageEmitter};
use apianyware_macos_emit::snapshot_testing::GoldenTest;
use apianyware_macos_emit::test_fixtures::build_snapshot_test_framework;

#[test]
fn snapshot_{lang}_{style}_testkit() {
    let framework = build_snapshot_test_framework();
    let temp_dir = tempfile::tempdir().unwrap();
    let emitter = {Lang}Emitter;
    emitter.emit_framework(&framework, temp_dir.path(), BindingStyle::{Style})
        .expect("emitter should succeed");

    let generated_dir = temp_dir.path().join("testkit");
    let golden_test = GoldenTest::new(
        &PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("tests/golden"),
        "{lang}",
        BindingStyle::{Style},
    );
    if let Err(mismatch) = golden_test.assert_matches(&generated_dir) {
        panic!("Snapshot mismatch. Run UPDATE_GOLDEN=1 to accept.\n\n{mismatch}");
    }
}
```

2. Generate initial golden files:
```bash
UPDATE_GOLDEN=1 cargo test -p apianyware-macos-emit-{target} --test snapshot_test
```

3. Review the generated golden files for correctness
4. Add one test per binding style
5. Golden files go to `generation/crates/emit-{target}/tests/golden/{style}/`

The shared `build_snapshot_test_framework()` provides a deterministic 5-class `TestKit` framework
that exercises all emitter code paths. Optionally add Foundation/AppKit golden tests for
comprehensive coverage.

## Step 7: Write smoke tests

Create non-GUI tests in the target language that verify basic binding functionality:

- Object creation and method calls
- Property get/set
- Block creation and invocation
- Type conversions (string, array, dictionary)
- Error handling patterns

## Step 8: Build sample apps

Implement the 7 standard sample apps (one set per binding style):

1. Read the spec in `generation/apps/specs/{app}.md`
2. Implement in `generation/targets/{target}/apps/{style}/{app}/`
3. Verify it builds and runs
4. Run TestAnyware validation against it

### App bundling for TCC permissions

Apps that require macOS permissions (Accessibility, Camera, etc.) must be packaged as
`.app` bundles with unique Swift stub launchers. Use `apianyware-macos-stub-launcher`:

```rust
use apianyware_macos_stub_launcher::{StubConfig, create_app_bundle};

let config = StubConfig {
    app_name: "MyApp".into(),
    runtime_path: "/opt/homebrew/bin/{runtime}".into(),
    runtime_args: vec![],
    script_resource_name: "main".into(),
    script_resource_type: "{ext}".into(),
    script_resource_dir: "{target}-app".into(),
    bundle_identifier: "com.linkuistics.{target}.MyApp".into(),
};
let app_path = create_app_bundle(&config, output_dir)?;
// Populate app_path/Contents/Resources/{target}-app/ with scripts and runtime files
```

Without the stub, all apps sharing the same runtime binary (e.g., `/opt/homebrew/bin/racket`)
get the same CDHash, causing TCC to share permission grants across unrelated apps. Each
compiled stub has a unique CDHash, giving per-app permission isolation.

## Step 9: Validate and review

- All Rust tests pass
- All snapshot tests pass
- All smoke tests pass
- All sample apps pass TestAnyware validation
- Per-framework exercisers work
- Documentation requirements recorded

## Reference implementations

- **Racket** — `generation/crates/emit-racket/` and `generation/targets/racket-oo/` — the most complete reference
- **Shared framework** — `generation/crates/emit/` — common utilities available to all emitters
- **Swift helpers** — `swift/Sources/APIAnywareCommon/` — shared C-callable ObjC runtime interface

## Checklist

```
[ ] LLM_STATE/targets/{target}/ directory created (backlog.md, session-log.md, memory.md, phase.md, prompt-*.md, run.sh)
[ ] emit-{target} crate created, compiles, tests pass
[ ] Runtime library written, loads in target language
[ ] Swift dylib builds and FFI verified
[ ] Registered in generation CLI
[ ] Golden files checked in
[ ] Smoke tests pass
[ ] Sample apps — Style 1 (all 7)
[ ] Sample apps — Style 2 (all 7, if applicable)
[ ] App bundles created for TCC-dependent apps (stub-launcher)
[ ] TestAnyware validation complete
[ ] Per-framework exercisers pass
[ ] knowledge/targets/{target}.md populated with learnings
[ ] Review gate passed
[ ] LLM_STATE/overview.md updated with target status
```
