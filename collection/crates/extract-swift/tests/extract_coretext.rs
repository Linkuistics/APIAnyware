//! Real-SDK integration test: extract the `CoreText` Swift module.
//!
//! Actually invokes `swift-api-digester` against the installed macOS SDK,
//! so it requires Xcode to be present. Serves as the canary for the
//! `c:@macro@` USR filter class: CoreText's Swift digester output consists
//! almost entirely of `kCTVersionNumber*` constants whose USRs live under
//! `c:@macro@…`. The filter in `declaration_mapping::non_c_linkable_skip_reason`
//! must drop every one of them from `fw.constants` and route them to
//! `fw.skipped_symbols`, otherwise downstream `dlsym`-based bindings will
//! fail at load time.

use std::sync::LazyLock;

use apianyware_extract_swift::{digester, extract_swift_framework};
use apianyware_types::ir;

/// Extracted CoreText framework, shared across tests in this file.
static CORETEXT: LazyLock<ir::Framework> = LazyLock::new(|| {
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
    let coretext = modules
        .iter()
        .find(|m| m.name == "CoreText")
        .expect("CoreText should have a .swiftmodule");

    extract_swift_framework(coretext, sdk_path, &sdk_version).expect("extract CoreText")
});

fn coretext() -> &'static ir::Framework {
    &CORETEXT
}

#[test]
fn coretext_framework_shape() {
    let fw = coretext();
    assert_eq!(fw.name, "CoreText");
    assert_eq!(fw.format_version, "1.0");
    assert_eq!(fw.checkpoint, "collected");
    assert!(
        fw.sdk_version.is_some(),
        "CoreText framework should record sdk_version"
    );
    assert!(
        fw.collected_at.is_some(),
        "CoreText framework should record collected_at"
    );
}

/// Positive control for digester discovery: `CTGetCoreTextVersion` is the
/// single top-level C function CoreText's Swift module re-exports with a
/// plain `c:@F@` USR. It must survive filtering and reach `fw.functions`.
/// If it stops appearing, swift-api-digester invocation or our Func arm is
/// broken — the whole integration should fail loudly rather than silently
/// reporting empty output from this module.
#[test]
fn coretext_has_version_function_positive_control() {
    let fw = coretext();
    let found = fw
        .functions
        .iter()
        .find(|f| f.name == "CTGetCoreTextVersion");
    assert!(
        found.is_some(),
        "CTGetCoreTextVersion must survive filtering \
         (positive control for extract-swift real-SDK harness). \
         functions.len() = {}",
        fw.functions.len()
    );
}

/// Canary for the `c:@macro@` USR filter. libclang surfaces `#define` names
/// as macro cursors with no dylib symbol; binding them with `get-ffi-obj`
/// at the call site fails at runtime. The Swift API digester reflects
/// every `kCTVersionNumber*` CoreText macro as a top-level `Var` with a
/// `c:@macro@` USR. All of them must be absent from `fw.constants`.
#[test]
fn coretext_filters_ct_version_number_macros() {
    let fw = coretext();
    let leaked: Vec<&str> = fw
        .constants
        .iter()
        .map(|c| c.name.as_str())
        .filter(|name| name.starts_with("kCTVersionNumber"))
        .collect();
    assert!(
        leaked.is_empty(),
        "c:@macro@ filter failed: kCTVersionNumber* constants \
         leaked into fw.constants: {leaked:?}"
    );
}

/// The other half of the filter contract: dropped symbols must be recorded
/// into `fw.skipped_symbols` so post-hoc audit tooling can see why they
/// vanished. Every `kCTVersionNumber*` macro must show up with the
/// "preprocessor macro cursor" reason.
#[test]
fn coretext_records_macro_filter_skips() {
    let fw = coretext();
    let macro_skips: Vec<&ir::SkippedSymbol> = fw
        .skipped_symbols
        .iter()
        .filter(|s| s.name.starts_with("kCTVersionNumber"))
        .collect();

    assert!(
        !macro_skips.is_empty(),
        "expected kCTVersionNumber* entries in skipped_symbols, found none. \
         skipped_symbols.len() = {}",
        fw.skipped_symbols.len()
    );

    for skip in &macro_skips {
        assert_eq!(skip.kind, "constant");
        assert!(
            skip.reason.contains("preprocessor macro"),
            "unexpected skip reason for {}: {}",
            skip.name,
            skip.reason
        );
    }
}

/// `extract_imports` output: CoreText's Swift module re-exports Foundation
/// alongside its own submodules, so `depends_on` must be non-empty and must
/// contain `Foundation`. This is the only real-SDK assertion on the import
/// path — the synthetic fixture tests cover the filtering shape, this one
/// pins that the digester actually emits `Import` nodes end-to-end.
#[test]
fn coretext_depends_on_contains_foundation() {
    let fw = coretext();
    assert!(
        !fw.depends_on.is_empty(),
        "CoreText.depends_on must be non-empty: extract_imports produced no entries"
    );
    assert!(
        fw.depends_on.iter().any(|d| d == "Foundation"),
        "CoreText.depends_on must include Foundation; got {:?}",
        fw.depends_on
    );
}

/// Private imports (names starting with `_`) are Swift-internal cross-module
/// re-exports like `_SwiftConcurrencyShims`; they must be filtered out of
/// `depends_on` by `extract_imports`.
#[test]
fn coretext_depends_on_excludes_private_imports() {
    let fw = coretext();
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
