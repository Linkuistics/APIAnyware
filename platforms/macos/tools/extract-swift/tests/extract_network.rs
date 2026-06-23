//! Real-SDK integration test: extract the `Network` Swift module.
//!
//! Actually invokes `swift-api-digester` against the installed macOS SDK.
//! Network is the canary for the `c:@Ea@` / `c:@EA@` anonymous-enum-member
//! filter: its `nw_browse_result_change_*` family lives under `c:@Ea@`
//! (single-character case difference from `c:@EA@`), and earlier filter
//! iterations that only caught one of the two prefixes let most of the
//! leak survive. All seven members must be filtered and recorded into
//! `fw.skipped_symbols`.
//!
//! Network also serves as a large-framework positive control — it has
//! 400+ `nw_*` C functions, so discovery breakage or a pipeline-wide
//! regression fails this test loudly rather than silently producing
//! empty output.

use std::sync::LazyLock;

use apianyware_extract_swift::{digester, extract_swift_framework};
use apianyware_types::ir;

/// Extracted Network framework, shared across tests in this file.
static NETWORK: LazyLock<ir::Framework> = LazyLock::new(|| {
    let sdk_path_output = std::process::Command::new("xcrun")
        .args(["--show-sdk-path"])
        .output()
        .expect("xcrun --show-sdk-path should succeed");
    let sdk_path_string =
        String::from_utf8(sdk_path_output.stdout).expect("sdk path should be UTF-8");
    let sdk_path = std::path::Path::new(sdk_path_string.trim());

    let sdk_version_output = std::process::Command::new("xcrun")
        .args(["--show-sdk-version"])
        .output()
        .expect("xcrun --show-sdk-version should succeed");
    let sdk_version =
        String::from_utf8(sdk_version_output.stdout).expect("sdk version should be UTF-8");
    let sdk_version = sdk_version.trim().to_string();

    let modules = digester::discover_swift_modules(sdk_path).expect("discover swift modules");
    let network = modules
        .iter()
        .find(|m| m.name == "Network")
        .expect("Network should have a .swiftmodule");

    extract_swift_framework(network, sdk_path, &sdk_version).expect("extract Network")
});

fn network() -> &'static ir::Framework {
    &NETWORK
}

#[test]
fn network_framework_shape() {
    let fw = network();
    assert_eq!(fw.name, "Network");
    assert_eq!(fw.format_version, "1.0");
    assert_eq!(fw.checkpoint, "collected");
    assert!(
        fw.sdk_version.is_some(),
        "Network framework should record sdk_version"
    );
}

/// Positive control: Network exports 400+ top-level `nw_*` C functions.
/// Any regression in discovery, digester invocation, or the `Func` arm
/// would drop that count to zero. Use a bulk floor rather than an exact
/// count so SDK drift does not constantly invalidate the test.
#[test]
fn network_has_many_nw_functions_positive_control() {
    let fw = network();
    let nw_count = fw
        .functions
        .iter()
        .filter(|f| f.name.starts_with("nw_"))
        .count();
    assert!(
        nw_count > 400,
        "expected >400 nw_* functions, found {nw_count}. \
         Total functions: {}",
        fw.functions.len()
    );
}

/// Positive control: a specific load-bearing `nw_*` function must round-trip
/// through the extractor. If this disappears we want the test to name it
/// explicitly so the failure message points at the right place, rather
/// than just reporting a bulk count drop.
#[test]
fn network_has_parameters_create_positive_control() {
    let fw = network();
    let found = fw
        .functions
        .iter()
        .any(|f| f.name == "nw_parameters_create");
    assert!(
        found,
        "nw_parameters_create must survive extraction \
         (positive control for a commonly-used Network API)"
    );
}

/// Canary for the `c:@Ea@` filter half: the seven
/// `nw_browse_result_change_*` members are anonymous enum values with no
/// dylib symbol. They must all be absent from `fw.constants`. A leak here
/// typically means the filter was weakened to only `c:@EA@` (uppercase),
/// which is a one-character regression that would miss this whole family.
#[test]
fn network_filters_nw_browse_result_change_members() {
    let fw = network();
    let leaked: Vec<&str> = fw
        .constants
        .iter()
        .map(|c| c.name.as_str())
        .filter(|name| name.starts_with("nw_browse_result_change_"))
        .collect();
    assert!(
        leaked.is_empty(),
        "c:@Ea@ filter failed: nw_browse_result_change_* constants \
         leaked into fw.constants: {leaked:?}"
    );
}

/// Canary for the broader `c:@Ea@` / `c:@EA@` family: Network carries ~150
/// anonymous-enum members across both USR prefixes, so at least several
/// dozen must appear in `fw.skipped_symbols` with the anonymous-enum
/// reason. This guards against a regression that silently drops symbols
/// without recording them (observability gap).
#[test]
fn network_records_anonymous_enum_filter_skips() {
    let fw = network();
    let anon_enum_skips: Vec<&ir::SkippedSymbol> = fw
        .skipped_symbols
        .iter()
        .filter(|s| s.reason.contains("anonymous enum member"))
        .collect();

    assert!(
        anon_enum_skips.len() >= 50,
        "expected >=50 anonymous-enum skipped_symbols in Network, \
         found {}. Total skipped_symbols: {}",
        anon_enum_skips.len(),
        fw.skipped_symbols.len()
    );

    let browse_skips: Vec<&str> = anon_enum_skips
        .iter()
        .map(|s| s.name.as_str())
        .filter(|n| n.starts_with("nw_browse_result_change_"))
        .collect();
    assert_eq!(
        browse_skips.len(),
        7,
        "expected exactly 7 nw_browse_result_change_* entries \
         in skipped_symbols, found {browse_skips:?}"
    );
}

/// `extract_imports` output: Network imports Foundation and Dispatch. Pin
/// both so a regression that loses either one (or the whole import path)
/// fails loudly. This is the only real-SDK assertion on `depends_on` for
/// Network — synthetic tests cover the filter shape; this one exercises
/// the digester end-to-end.
#[test]
fn network_depends_on_contains_foundation_and_dispatch() {
    let fw = network();
    assert!(
        !fw.depends_on.is_empty(),
        "Network.depends_on must be non-empty: extract_imports produced no entries"
    );
    for required in ["Foundation", "Dispatch"] {
        assert!(
            fw.depends_on.iter().any(|d| d == required),
            "Network.depends_on must include {required}; got {:?}",
            fw.depends_on
        );
    }
}

/// Private imports (`_`-prefixed) must be filtered out by `extract_imports`.
#[test]
fn network_depends_on_excludes_private_imports() {
    let fw = network();
    let private: Vec<&str> = fw
        .depends_on
        .iter()
        .map(String::as_str)
        .filter(|d| d.starts_with('_'))
        .collect();
    assert!(
        private.is_empty(),
        "extract_imports must drop `_`-prefixed private imports; leaked: {private:?}"
    );
}
