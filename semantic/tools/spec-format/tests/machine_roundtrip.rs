//! The machine interchange seam round-trips a `Framework` through JSON on disk.
//!
//! `extracted.json` / `resolved.json` stay JSON (ADR-0046 §5, k17 retreat); this
//! pins that the crate's read/write seam preserves the IR structurally.

use std::path::PathBuf;

use apianyware_spec_format::machine;
use apianyware_types::ir::Framework;

/// A unique scratch directory for this test process (no time/random needed —
/// the pid plus a label is unique enough for a single test binary).
fn scratch(label: &str) -> PathBuf {
    let dir = std::env::temp_dir().join(format!(
        "apianyware-spec-format-{}-{}",
        std::process::id(),
        label
    ));
    std::fs::create_dir_all(&dir).unwrap();
    dir
}

const FRAMEWORK_JSON: &str = r#"{
    "format_version": "1.0",
    "checkpoint": "extracted",
    "name": "Foundation",
    "sdk_version": "15.4",
    "depends_on": ["CoreFoundation"],
    "classes": [
        { "name": "NSString", "super": "NSObject", "protocols": ["NSCopying", "NSSecureCoding"] },
        { "name": "NSArray", "super": "NSObject", "protocols": ["NSFastEnumeration"] }
    ],
    "protocols": [],
    "enums": [],
    "structs": [],
    "functions": [],
    "constants": []
}"#;

#[test]
fn framework_round_trips_through_the_json_seam() {
    let original: Framework = serde_json::from_str(FRAMEWORK_JSON).unwrap();
    let path = scratch("machine").join("extracted.json");

    machine::write_framework(&original, &path).unwrap();
    let reread = machine::read_framework(&path).unwrap();

    // Structural (serde) equality — `Framework` has no `PartialEq`.
    assert_eq!(
        serde_json::to_value(&original).unwrap(),
        serde_json::to_value(&reread).unwrap()
    );
    assert_eq!(reread.name, "Foundation");
    assert_eq!(reread.classes.len(), 2);
    assert_eq!(
        reread.classes[0].protocols,
        vec!["NSCopying", "NSSecureCoding"]
    );
}

#[test]
fn written_machine_json_is_pretty_and_newline_terminated() {
    // Goldens-as-truth review reads these files by hand, so the writer emits
    // indented JSON with a trailing newline (matches the existing checkpoints).
    let original: Framework = serde_json::from_str(FRAMEWORK_JSON).unwrap();
    let path = scratch("machine-pretty").join("resolved.json");

    machine::write_framework(&original, &path).unwrap();
    let text = std::fs::read_to_string(&path).unwrap();

    assert!(text.contains("\n  "), "expected indented (pretty) JSON");
    assert!(text.ends_with('\n'), "expected a trailing newline");
}
