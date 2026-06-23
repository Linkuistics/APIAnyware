//! Snapshot (golden-file) regression tests for the Racket emitter.
//!
//! Three test suites:
//!   1. TestKit (synthetic) — full directory comparison, exercises all emitter code paths
//!   2. Foundation (real IR) — curated subset of ~18 representative files
//!   3. AppKit (real IR) — curated subset of ~20 representative files (views, controls, delegates)
//!
//! To update golden files after intentional changes:
//!   UPDATE_GOLDEN=1 cargo test -p apianyware-emit-racket --test snapshot_test

use std::path::PathBuf;

use apianyware_emit::snapshot_testing::GoldenTest;
use apianyware_emit::target_emitter::TargetEmitter;
use apianyware_emit::test_fixtures::build_snapshot_test_framework;
use apianyware_emit_racket::emit_framework::RacketEmitter;

/// Root of this crate (for locating golden files relative to source).
fn crate_root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
}

/// Golden files directory for TestKit.
fn golden_dir() -> PathBuf {
    crate_root().join("tests").join("golden")
}

/// Golden files directory for Foundation subset.
fn golden_foundation_dir() -> PathBuf {
    crate_root().join("tests").join("golden-foundation")
}

/// Golden files directory for AppKit subset.
fn golden_appkit_dir() -> PathBuf {
    crate_root().join("tests").join("golden-appkit")
}

/// Curated subset of Foundation files for golden comparison.
/// Covers: base class, string-heavy class, collection, data, URL,
/// notification center, error domain, file operations, user defaults,
/// formatter/builder, locking, timer, enums, constants, main re-export,
/// and representative protocols (NSCopying, NSCoding, NSLocking, plus
/// NSURLSessionTaskDelegate which carries enrichment-derived block metadata).
///
/// `nsobject.rkt` is intentionally not listed: NSObject lives in
/// `objc/runtime`, not Foundation, so the foreign-module type-decl filter
/// (extract-swift) correctly drops it from Foundation's IR.
const FOUNDATION_GOLDEN_FILES: &[&str] = &[
    "main.rkt",
    "constants.rkt",
    "enums.rkt",
    "nsstring.rkt",
    "nsarray.rkt",
    "nsdata.rkt",
    "nsurl.rkt",
    "nsnotificationcenter.rkt",
    "nserror.rkt",
    "nsfilemanager.rkt",
    "nsuserdefaults.rkt",
    "nsdateformatter.rkt",
    "nslock.rkt",
    "nstimer.rkt",
    "protocols/nscopying.rkt",
    "protocols/nscoding.rkt",
    "protocols/nslocking.rkt",
    "protocols/nsurlsessiontaskdelegate.rkt",
];

/// Curated subset of AppKit files for golden comparison.
/// Covers: view hierarchy (NSResponder→NSView→NSControl→NSButton),
/// window management, table view with data source/delegate protocols,
/// text input, menus, application lifecycle, layout, images, colors,
/// status bar (for Menu Bar Tool app pattern), and split views.
/// NSApplicationDelegate is included so a protocol golden exercises the
/// enrichment-derived block/ownership metadata comments.
const APPKIT_GOLDEN_FILES: &[&str] = &[
    "main.rkt",
    "constants.rkt",
    "enums.rkt",
    "nsresponder.rkt",
    "nsview.rkt",
    "nscontrol.rkt",
    "nsbutton.rkt",
    "nswindow.rkt",
    "nswindowcontroller.rkt",
    "nstableview.rkt",
    "nstextfield.rkt",
    "nstextview.rkt",
    "nsmenu.rkt",
    "nsmenuitem.rkt",
    "nsapplication.rkt",
    "nsstackview.rkt",
    "nsimage.rkt",
    "nscolor.rkt",
    "nsstatusbar.rkt",
    "nssplitview.rkt",
    "protocols/nstableviewdelegate.rkt",
    "protocols/nstableviewdatasource.rkt",
    "protocols/nswindowdelegate.rkt",
    "protocols/nsapplicationdelegate.rkt",
];

#[test]
fn snapshot_racket_testkit() {
    let framework = build_snapshot_test_framework();

    // Generate to a temp directory
    let temp_dir = tempfile::tempdir().unwrap();
    let emitter = RacketEmitter;
    let result = emitter
        .emit_framework(&framework, temp_dir.path())
        .expect("Racket emitter should succeed");

    assert!(
        result.files_written > 0,
        "Should generate at least one file"
    );
    assert_eq!(result.classes_emitted, 5);
    assert_eq!(result.protocols_emitted, 2);
    assert_eq!(result.enums_emitted, 1);
    assert_eq!(result.functions_emitted, 6); // 8 total minus 1 variadic, 1 inline
    assert_eq!(result.constants_emitted, 3);

    // The emitter writes to {output_dir}/{lowercase_framework_name}/
    let generated_framework_dir = temp_dir.path().join("testkit");
    assert!(
        generated_framework_dir.exists(),
        "Expected testkit/ directory in output"
    );

    // Compare against golden files
    let golden_test = GoldenTest::new(&golden_dir(), "racket");
    if let Err(mismatch) = golden_test.assert_matches(&generated_framework_dir) {
        panic!(
            "Racket snapshot mismatch.\n\
             Run `UPDATE_GOLDEN=1 cargo test -p apianyware-emit-racket --test snapshot_test` \
             to accept.\n\n{mismatch}"
        );
    }
}

/// Load a real enriched IR framework from the analysis pipeline output.
fn load_enriched_framework(name: &str) -> Option<apianyware_types::ir::Framework> {
    let enriched_dir = crate_root()
        .parent() // emit-racket → crates
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
fn snapshot_racket_foundation_subset() {
    let framework = match load_enriched_framework("Foundation") {
        Some(fw) => fw,
        None => {
            eprintln!(
                "SKIPPED: Foundation enriched IR not found. \
                 Run the analysis pipeline first: \
                 cargo run --bin apianyware-analyze"
            );
            return;
        }
    };

    // Generate Foundation to a temp directory
    let temp_dir = tempfile::tempdir().unwrap();
    let emitter = RacketEmitter;
    let result = emitter
        .emit_framework(&framework, temp_dir.path())
        .expect("Foundation emission should succeed");

    assert!(
        result.files_written > 100,
        "Foundation should generate many files"
    );
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

    // Compare curated subset against golden files
    let generated_dir = temp_dir.path().join("foundation");
    assert!(generated_dir.exists(), "Expected foundation/ directory");

    let golden_test = GoldenTest::new(&golden_foundation_dir(), "racket");
    if let Err(mismatch) =
        golden_test.assert_subset_matches(&generated_dir, FOUNDATION_GOLDEN_FILES)
    {
        panic!(
            "Racket Foundation snapshot mismatch.\n\
             Run `UPDATE_GOLDEN=1 cargo test -p apianyware-emit-racket --test snapshot_test` \
             to accept.\n\n{mismatch}"
        );
    }
}

#[test]
fn snapshot_racket_appkit_subset() {
    let framework = match load_enriched_framework("AppKit") {
        Some(fw) => fw,
        None => {
            eprintln!(
                "SKIPPED: AppKit enriched IR not found. \
                 Run the analysis pipeline first: \
                 cargo run --bin apianyware-analyze"
            );
            return;
        }
    };

    // Generate AppKit to a temp directory
    let temp_dir = tempfile::tempdir().unwrap();
    let emitter = RacketEmitter;
    let result = emitter
        .emit_framework(&framework, temp_dir.path())
        .expect("AppKit emission should succeed");

    assert!(
        result.files_written > 100,
        "AppKit should generate many files (got {})",
        result.files_written
    );
    assert!(
        result.classes_emitted >= 200,
        "AppKit should emit 200+ classes (got {})",
        result.classes_emitted
    );
    assert!(
        result.protocols_emitted >= 50,
        "AppKit should emit 50+ protocols (got {})",
        result.protocols_emitted
    );

    // Compare curated subset against golden files
    let generated_dir = temp_dir.path().join("appkit");
    assert!(generated_dir.exists(), "Expected appkit/ directory");

    let golden_test = GoldenTest::new(&golden_appkit_dir(), "racket");
    if let Err(mismatch) = golden_test.assert_subset_matches(&generated_dir, APPKIT_GOLDEN_FILES) {
        panic!(
            "Racket AppKit snapshot mismatch.\n\
             Run `UPDATE_GOLDEN=1 cargo test -p apianyware-emit-racket --test snapshot_test` \
             to accept.\n\n{mismatch}"
        );
    }
}
