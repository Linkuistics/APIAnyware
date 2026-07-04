//! Registry-style validation of the **real materialized** machine IR against the
//! machine-IR KDL Schema (`schemas/spec-format/machine-ir.kdl-schema`, ADR-0046
//! §5) — the ws8 `machine-kdl-schema-k153` done-bar's real-data guard.
//!
//! The machine IR is derived + gitignored (constraint 4), so this test
//! **skips-as-pass when it is not materialized** (mirroring the emit snapshot
//! tests' `resolved.kdl`-absent skip and the [[sbcl_6d_test_stale]] pattern): a
//! fresh checkout with no `platforms/macos/api/<F>/*.kdl` reports SKIPPED and
//! passes. The instant, IR-independent correctness guard is the unit test
//! `machine_schema::tests::jik_emitted_framework_validates`, which validates a
//! rich Framework emitted through the *production* codec; this test adds coverage
//! of real SDK-scale shapes.
//!
//! ## Why it is work-bounded (not "validate every file")
//!
//! `validate_machine_kdl` runs on the shared generic engine, whose front door is
//! the format-preserving `kdl::KdlDocument::parse` — the very ~84×-`serde_json`
//! parser JiK exists to bypass (ADR-0046 §5). Measured cost is ~2 s per MB and is
//! almost entirely that parse (the validation walk is <2%). The materialized IR
//! runs to tens of MB per family (a flattened `resolved.kdl` can exceed 80 MB), so
//! validating all of it would take minutes. This test therefore validates
//! materialized files in **ascending size order up to a cumulative work budget**,
//! covering as many families / both phases as the budget allows, and **prints
//! every file it skipped for the budget** (no silent cap). Bounding machine-scale
//! validation — or giving it a `jik`-parser fast path — is the umbrella command's
//! call (`validate-umbrella-k154`); this test only needs to prove the schema
//! matches the real on-disk shape.

use std::path::{Path, PathBuf};

use apianyware_spec_format::validate_machine_kdl;

/// Cumulative bytes of machine IR to validate before stopping. ~2 s/MB ⇒ this
/// keeps the test near ~7 s even when a large corpus is materialized, while
/// reliably covering several families across both `extracted` and `resolved`.
const WORK_BUDGET_BYTES: u64 = 3_500_000;

/// `platforms/macos/api`, found by walking up from this crate to the repo root.
/// `None` if the tree is not present (skips-as-pass).
fn api_root() -> Option<PathBuf> {
    let manifest = PathBuf::from(env!("CARGO_MANIFEST_DIR")); // …/semantic/tools/spec-format
    manifest
        .ancestors()
        .map(|a| a.join("platforms").join("macos").join("api"))
        .find(|p| p.is_dir())
}

/// Every materialized `extracted.kdl` / `resolved.kdl` under `api_root`, as
/// `(label, path, size)`, sorted by ascending size.
fn materialized_files(api_root: &Path) -> Vec<(String, PathBuf, u64)> {
    let mut out = Vec::new();
    let Ok(entries) = std::fs::read_dir(api_root) else {
        return out;
    };
    for entry in entries.flatten() {
        let family_dir = entry.path();
        if !family_dir.is_dir() {
            continue;
        }
        let family = entry.file_name().to_string_lossy().into_owned();
        for phase in ["extracted", "resolved"] {
            let path = family_dir.join(format!("{phase}.kdl"));
            if let Ok(meta) = std::fs::metadata(&path) {
                out.push((format!("{family}/{phase}.kdl"), path, meta.len()));
            }
        }
    }
    out.sort_by_key(|(_, _, size)| *size);
    out
}

#[test]
fn real_materialized_machine_ir_conforms_to_the_schema() {
    let Some(api_root) = api_root() else {
        eprintln!("SKIPPED: platforms/macos/api not found — machine IR is derived/gitignored.");
        return;
    };
    let files = materialized_files(&api_root);
    if files.is_empty() {
        eprintln!(
            "SKIPPED: no materialized extracted.kdl / resolved.kdl under {}. \
             Run the analysis pipeline first: cargo run --bin apianyware-analyze",
            api_root.display()
        );
        return;
    }

    let mut budget = WORK_BUDGET_BYTES;
    let mut validated = 0usize;
    let mut failures: Vec<String> = Vec::new();
    let mut skipped_for_budget: Vec<String> = Vec::new();

    for (label, path, size) in &files {
        // Always validate at least one file; then stop taking new files once the
        // budget is spent (a single over-budget file is still finished if it is
        // the first, so a corpus of only huge files still gets one real check).
        if validated > 0 && *size > budget {
            skipped_for_budget.push(format!("{label} ({:.1} MB)", *size as f64 / 1_048_576.0));
            continue;
        }
        let text = std::fs::read_to_string(path).expect("materialized IR is readable");
        if let Err(e) = validate_machine_kdl(label, &text) {
            failures.push(format!("{label}: {e}"));
        }
        validated += 1;
        budget = budget.saturating_sub(*size);
    }

    eprintln!(
        "validated {validated}/{} materialized machine IR file(s) against machine-ir.kdl-schema",
        files.len()
    );
    if !skipped_for_budget.is_empty() {
        eprintln!(
            "skipped {} file(s) for the ~{:.1} MB work budget (validation is ~2 s/MB): {}",
            skipped_for_budget.len(),
            WORK_BUDGET_BYTES as f64 / 1_048_576.0,
            skipped_for_budget.join(", ")
        );
    }

    assert!(
        failures.is_empty(),
        "real machine IR must conform to machine-ir.kdl-schema; violations:\n{}",
        failures.join("\n")
    );
    assert!(
        validated > 0,
        "expected to validate at least one materialized file"
    );
}
