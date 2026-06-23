//! Snapshot (golden-file) regression tests for the SBCL emitter (leaf 040/060).
//!
//! Two layers, mirroring the racket/chez/gerbil precedent:
//!   1. **TestKit (synthetic)** — always runs, no enriched IR needed. The shared
//!      `build_snapshot_test_framework` rich fixture (5 classes incl. a 2-deep
//!      inheritance chain, 2 protocols, 1 enum, constants, functions) is emitted
//!      through the real [`TargetEmitter`] (with the whole-program registries the
//!      CLI pre-pass builds) to a temp dir — the facade + `generics.lisp` + the
//!      per-class files + the data files — then the whole tree is compared against
//!      committed goldens. The "representative framework subset" the node's done-bar
//!      asks for; keeps CI green with no IR on disk.
//!   2. **Foundation (real IR)** — goldens-as-truth over a curated subset
//!      (the facade, the generics module, the heavyweight classes, the data files).
//!      SKIPPED-as-pass when the enriched IR is absent (it is gitignored, 16-90 MB),
//!      so default `cargo test` stays green everywhere. Once the analysis pipeline
//!      has been run locally, bootstrap/refresh with `UPDATE_GOLDEN=1`.
//!
//! To update golden files after intentional emitter changes:
//!   UPDATE_GOLDEN=1 cargo test -p apianyware-macos-emit-sbcl --test snapshot_test

use std::path::PathBuf;

use apianyware_macos_emit::snapshot_testing::GoldenTest;
use apianyware_macos_emit::target_emitter::TargetEmitter;
use apianyware_macos_emit::test_fixtures::build_snapshot_test_framework;
use apianyware_macos_emit_sbcl::class_graph::ClassRegistry;
use apianyware_macos_emit_sbcl::protocol_registry::ProtocolRegistry;
use apianyware_macos_emit_sbcl::SbclEmitter;
use apianyware_macos_types::ir::Framework;

/// Build the emitter exactly as the CLI pre-pass does (`generate.rs` sbcl branch):
/// with the whole-program class + protocol registries over the frameworks under
/// test, so the goldens capture what the real pipeline emits (cross-framework
/// metaclass parents + conformed-protocol method flattening).
fn pipeline_emitter(frameworks: &[&Framework]) -> SbclEmitter {
    SbclEmitter::with_registries(
        ClassRegistry::from_framework_refs(frameworks),
        ProtocolRegistry::from_framework_refs(frameworks),
    )
}

fn crate_root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
}

fn golden_dir() -> PathBuf {
    crate_root().join("tests").join("golden")
}

fn golden_foundation_dir() -> PathBuf {
    crate_root().join("tests").join("golden-foundation")
}

/// Curated subset of real Foundation files for golden comparison — the facade, the
/// shared generics module, the string/collection/data/url/error heavyweights, and
/// the three data files. Paths are relative to the emitter's output root (the facade
/// sits next to the `foundation/` directory). A representative slice, not all 300+
/// class files.
const FOUNDATION_GOLDEN_FILES: &[&str] = &[
    "foundation.lisp",
    "foundation/generics.lisp",
    "foundation/nsstring.lisp",
    "foundation/nsarray.lisp",
    "foundation/nsurl.lisp",
    "foundation/nsdata.lisp",
    "foundation/nserror.lisp",
    "foundation/enums.lisp",
    "foundation/constants.lisp",
    "foundation/functions.lisp",
    "foundation/structs.lisp",
];

#[test]
fn testkit_snapshot_matches_golden() {
    let fw = build_snapshot_test_framework();
    let emitter = pipeline_emitter(&[&fw]);

    let tmp = tempfile::tempdir().unwrap();
    emitter.emit_framework(&fw, tmp.path()).unwrap();

    GoldenTest::new(&golden_dir(), "sbcl")
        .assert_matches(tmp.path())
        .unwrap();
}

/// Load one enriched IR framework from the analysis pipeline output, or `None` if
/// it is not present locally (the IR is gitignored). Read directly so the test
/// needs no datalog dependency (gerbil's pattern).
fn load_enriched_framework(name: &str) -> Option<Framework> {
    let enriched_dir = crate_root()
        .parent() // emit-sbcl → crates
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
fn foundation_subset_matches_golden() {
    // Real-IR layer: load enriched Foundation, emit, compare the curated subset.
    // Skips-as-pass when the gitignored IR is absent (CI without a regeneration
    // step) or the golden subset has not been bootstrapped yet.
    let foundation = match load_enriched_framework("Foundation") {
        Some(fw) => fw,
        None => {
            eprintln!(
                "SKIP foundation_subset_matches_golden: Foundation enriched IR not found \
                 (gitignored — run the analysis pipeline, then UPDATE_GOLDEN=1 to bootstrap)"
            );
            return;
        }
    };
    // Until the goldens are bootstrapped the golden dir is absent — skip-as-pass on
    // a fresh checkout rather than fail.
    if !golden_foundation_dir().exists() && std::env::var("UPDATE_GOLDEN").as_deref() != Ok("1") {
        eprintln!("SKIP foundation_subset_matches_golden: sbcl goldens not bootstrapped yet");
        return;
    }

    // Foundation is a base framework, so its own class set resolves its parents;
    // the registries over `&[&foundation]` match what the CLI builds for it.
    let emitter = pipeline_emitter(&[&foundation]);
    let tmp = tempfile::tempdir().unwrap();
    let result = emitter.emit_framework(&foundation, tmp.path()).unwrap();
    // Lower bound, not an exact count (SDK-drift tolerant). Dropped from the
    // historical 300+ after the k38 fix: the Swift overlay renames ~27 Foundation
    // ObjC classes (NSScanner → Scanner, NSURLSession → URLSession, …) and these
    // are now keyed on their ObjC runtime name (collection/extract-swift), so each
    // overlay unifies with its clang twin instead of inflating the count as a
    // duplicate class. The de-duplicated Foundation is ~277 classes.
    assert!(
        result.classes_emitted >= 270,
        "Foundation should emit 270+ classes (got {})",
        result.classes_emitted
    );

    GoldenTest::new(&golden_foundation_dir(), "sbcl")
        .assert_subset_matches(tmp.path(), FOUNDATION_GOLDEN_FILES)
        .unwrap();
}
