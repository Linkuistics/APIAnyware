//! The runnable done-bar for `validate-umbrella-k154`: run the umbrella over the
//! **real committed** authored `.apiw` tree and assert it is a total, clean cover.
//!
//! This is the umbrella's own responsibility — that every authored file is
//! *dispatched* to a validator and *passes*, and that **no** `.apiw` is left
//! unclassified (a coverage gap). It complements, not duplicates, the per-crate
//! `tests/*_registry.rs`: those prove each crate validates its own files; this
//! proves the driver wires all of them together with nothing falling through.
//!
//! Unlike the machine-IR guard, the authored artifacts are **committed**, so this
//! test never skips — a checkout always has them.

use std::path::PathBuf;

use apianyware_validate::{find_repo_root, validate_authored};

fn repo_root() -> PathBuf {
    // …/schemas/tools/validate — walk up to the domain-holding ancestor.
    let manifest = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    find_repo_root(&manifest).expect("repo root (holding semantic/ platforms/ targets/ schemas/)")
}

#[test]
fn every_authored_apiw_validates_and_is_classified() {
    let report = validate_authored(&repo_root());

    // Every .apiw must land in a class — no coverage gap.
    assert!(
        report.unclassified.is_empty(),
        "these authored .apiw files matched no validator (wire a class in \
         schemas/tools/validate/src/lib.rs):\n{}",
        report.unclassified.join("\n")
    );

    // Every classified file must validate.
    let failures: Vec<String> = report
        .outcomes
        .iter()
        .filter_map(|o| {
            o.error
                .as_ref()
                .map(|e| format!("{} [{}]: {e}", o.rel_path, o.class))
        })
        .collect();
    assert!(
        failures.is_empty(),
        "authored artifacts must conform to their schemas; violations:\n{}",
        failures.join("\n")
    );

    // Sanity: the tree is real (guards against a walk that silently found nothing —
    // e.g. a wrong root — reporting a hollow pass).
    assert!(
        report.passed() > 100,
        "expected the umbrella to validate the full authored corpus (100+ files), got {}",
        report.passed()
    );
}
