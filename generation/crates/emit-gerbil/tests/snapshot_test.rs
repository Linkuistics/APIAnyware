//! Snapshot (golden-file) regression tests for the Gerbil emitter.
//!
//! Two layers, mirroring the racket/chez precedent:
//!   1. **TestKit (synthetic)** — always runs, no enriched IR needed. The shared
//!      `build_snapshot_test_framework` rich fixture (5 classes incl. a 2-deep
//!      inheritance chain, 2 protocols, 1 enum, constants, functions) is emitted
//!      to a temp dir — the per-framework facade + class/data/protocol modules AND
//!      the shared global `generics.ss` (the whole-program generic-unification
//!      module) — then the whole tree is compared against committed goldens. This
//!      is the "representative framework subset" the node's done-bar asks for, and
//!      it keeps CI green with no IR on disk.
//!   2. **Foundation (real IR)** — goldens-as-truth over a curated subset.
//!      SKIPPED-as-pass when the enriched IR is absent (it is gitignored, 16-90 MB)
//!      or the golden subset has not been bootstrapped yet, so default `cargo test`
//!      stays green everywhere. Once the analysis pipeline has been run locally,
//!      bootstrap/refresh the goldens with `UPDATE_GOLDEN=1`.
//!
//! To update golden files after intentional emitter changes:
//!   UPDATE_GOLDEN=1 cargo test -p apianyware-macos-emit-gerbil --test snapshot_test

use std::path::PathBuf;

use apianyware_macos_emit::snapshot_testing::GoldenTest;
use apianyware_macos_emit::target_emitter::TargetEmitter;
use apianyware_macos_emit::test_fixtures::build_snapshot_test_framework;
use apianyware_macos_emit_gerbil::class_graph::ClassRegistry;
use apianyware_macos_emit_gerbil::protocol_registry::ProtocolRegistry;
use apianyware_macos_emit_gerbil::{write_global_generics_module, GerbilEmitter};

/// Build the emitter exactly as the CLI pre-pass does (leaf 060/120): with the
/// whole-program class + protocol registries over the frameworks under test, so
/// the goldens capture what the real pipeline emits (cross-framework parents +
/// conformed-protocol method flattening).
fn pipeline_emitter(frameworks: &[&apianyware_macos_types::ir::Framework]) -> GerbilEmitter {
    GerbilEmitter::with_registries(
        ClassRegistry::from_framework_refs(frameworks),
        ProtocolRegistry::from_framework_refs(frameworks),
    )
}

/// Root of this crate (for locating golden files relative to source).
fn crate_root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
}

/// Golden files directory for the synthetic TestKit framework.
fn golden_dir() -> PathBuf {
    crate_root().join("tests").join("golden")
}

/// Golden files directory for the real Foundation subset.
fn golden_foundation_dir() -> PathBuf {
    crate_root().join("tests").join("golden-foundation")
}

/// Curated subset of real Foundation files for golden comparison — base class,
/// string/collection/data/url heavyweights, the facade + data modules, the shared
/// generics module, and a representative delegate protocol. Paths are relative to
/// the emitter's package root (the facade sits next to the `foundation/` dir).
const FOUNDATION_GOLDEN_FILES: &[&str] = &[
    "generics.ss",
    "foundation.ss",
    "foundation/constants.ss",
    "foundation/enums.ss",
    "foundation/functions.ss",
    "foundation/nsstring.ss",
    "foundation/nsarray.ss",
    "foundation/nsdata.ss",
    "foundation/nsurl.ss",
    "foundation/nserror.ss",
];

#[test]
fn snapshot_gerbil_testkit() {
    let framework = build_snapshot_test_framework();

    let temp_dir = tempfile::tempdir().unwrap();
    let emitter = pipeline_emitter(&[&framework]);
    let result = emitter
        .emit_framework(&framework, temp_dir.path())
        .expect("Gerbil emitter should succeed");

    assert!(result.files_written > 0, "should generate at least one file");
    assert_eq!(result.classes_emitted, 5, "TestKit has 5 classes");
    assert_eq!(result.protocols_emitted, 2, "TestKit has 2 protocols");
    assert_eq!(result.enums_emitted, 1, "TestKit has 1 enum");

    // Also write the whole-program generics module (a CLI pre-pass artifact, not
    // part of `emit_framework`) into the same tree so the snapshot captures the
    // full single-framework output the pipeline produces.
    write_global_generics_module(&[&framework], temp_dir.path())
        .expect("generics module should write");

    // The facade `testkit.ss` sits next to the `testkit/` dir, so compare the
    // whole generated tree (facade + class/data/protocol modules + generics.ss).
    let golden_test = GoldenTest::new(&golden_dir(), "gerbil");
    if let Err(mismatch) = golden_test.assert_matches(temp_dir.path()) {
        panic!(
            "Gerbil TestKit snapshot mismatch.\n\
             Run `UPDATE_GOLDEN=1 cargo test -p apianyware-macos-emit-gerbil --test snapshot_test` \
             to accept.\n\n{mismatch}"
        );
    }
}

/// Load a real enriched IR framework from the analysis pipeline output, or `None`
/// if it is not present locally (the IR is gitignored).
fn load_enriched_framework(name: &str) -> Option<apianyware_macos_types::ir::Framework> {
    let enriched_dir = crate_root()
        .parent() // emit-gerbil → crates
        .and_then(|p| p.parent()) // crates → generation
        .and_then(|p| p.parent()) // generation → project root
        .map(|p| p.join("analysis").join("ir").join("enriched"))?;

    let framework_path = enriched_dir.join(format!("{name}.json"));
    if !framework_path.exists() {
        return None;
    }
    let json = std::fs::read_to_string(&framework_path).ok()?;
    serde_json::from_str(&json).ok()
}

#[test]
fn snapshot_gerbil_foundation_subset() {
    let framework = match load_enriched_framework("Foundation") {
        Some(fw) => fw,
        None => {
            eprintln!(
                "SKIPPED: Foundation enriched IR not found (gitignored). \
                 Run the analysis pipeline, then UPDATE_GOLDEN=1 to bootstrap."
            );
            return;
        }
    };
    // The goldens are bootstrapped from real IR; until that has happened the
    // golden dir is absent — skip-as-pass rather than fail on a fresh checkout.
    if !golden_foundation_dir().exists() && std::env::var("UPDATE_GOLDEN").as_deref() != Ok("1") {
        eprintln!(
            "SKIPPED: Foundation gerbil goldens not bootstrapped yet. \
             Run UPDATE_GOLDEN=1 with enriched IR present."
        );
        return;
    }

    let temp_dir = tempfile::tempdir().unwrap();
    let emitter = pipeline_emitter(&[&framework]);
    let result = emitter
        .emit_framework(&framework, temp_dir.path())
        .expect("Foundation emission should succeed");
    assert!(
        result.classes_emitted >= 300,
        "Foundation should emit 300+ classes (got {})",
        result.classes_emitted
    );
    write_global_generics_module(&[&framework], temp_dir.path())
        .expect("generics module should write");

    let golden_test = GoldenTest::new(&golden_foundation_dir(), "gerbil");
    if let Err(mismatch) =
        golden_test.assert_subset_matches(temp_dir.path(), FOUNDATION_GOLDEN_FILES)
    {
        panic!(
            "Gerbil Foundation snapshot mismatch.\n\
             Run `UPDATE_GOLDEN=1 cargo test -p apianyware-macos-emit-gerbil --test snapshot_test` \
             to accept.\n\n{mismatch}"
        );
    }
}
