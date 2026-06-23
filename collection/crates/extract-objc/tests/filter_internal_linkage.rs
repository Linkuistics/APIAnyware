//! Regression test for the internal-linkage filter.
//!
//! Symbols declared as `static const` or `static inline` have internal
//! linkage: the compiler inlines them at use sites and emits no dynamic
//! symbol in the framework dylib. Downstream emitters that build
//! `dlsym`-style bindings (e.g. the Racket OO target's `get-ffi-obj`)
//! fail at load time on such symbols with
//! `could not find export from foreign library`. The extractor must
//! therefore skip them.

use std::fs;
use std::path::PathBuf;
use std::sync::LazyLock;

use apianyware_extract_objc::extract_declarations::{
    extract_from_translation_unit, ExtractionResult,
};
use apianyware_extract_objc::{create_index, init_clang};
use apianyware_types::ir;

const FRAMEWORK_NAME: &str = "LinkageTestFW";

const SYNTHETIC_HEADER: &str = r#"
    // --- constants: external vs internal linkage ---

    // External — real dylib export, must survive.
    extern const int ExternalIntConst;

    // Static const — internal linkage, inlined at use site, no dylib
    // symbol. Must be filtered out.
    static const int StaticIntConst = 42;
    static const long StaticLongConst = 99;

    // --- functions: external vs internal linkage ---

    // External — real dylib export, must survive.
    extern int external_function(int x);

    // Static inline — internal linkage, inlined at call site, no dylib
    // symbol. Must be filtered out.
    static inline int static_inline_function(int x) { return x + 1; }
    static int static_function(int x);
"#;

/// Shared extraction result.
///
/// `clang::Clang` is `!Send + !Sync`, so we cannot hold a `Clang` in a
/// `LazyLock`. Instead, we run extraction once inside the closure,
/// drop `Clang` before returning, and cache the plain `ExtractionResult`
/// (which is `Send + Sync`).
static EXTRACTED: LazyLock<ExtractionResult> = LazyLock::new(|| {
    let sdk = SyntheticSdk::new(FRAMEWORK_NAME);
    let header_path = sdk.write_header("LinkageTestFW.h", SYNTHETIC_HEADER);

    let clang = init_clang().expect("init clang");
    let index = create_index(&clang);
    let tu = index
        .parser(&header_path)
        .arguments(&["-x", "objective-c", "-w"])
        .detailed_preprocessing_record(true)
        .skip_function_bodies(true)
        .parse()
        .expect("parse header");

    extract_from_translation_unit(&tu.get_entity(), FRAMEWORK_NAME, sdk.root_path())
    // `sdk`, `tu`, `index`, and `clang` all drop here; only the plain
    // `ExtractionResult` survives.
});

/// Minimal synthetic SDK layout rooted at a temp directory.
///
/// `extract_from_translation_unit` filters declarations by header path
/// (`System/Library/Frameworks/{Name}.framework/Headers/`). To exercise
/// the extractor without depending on the real macOS SDK, we mirror that
/// layout under a temp directory and point `sdk_path` at the temp root.
struct SyntheticSdk {
    root: PathBuf,
    headers_dir: PathBuf,
}

impl SyntheticSdk {
    fn new(framework_name: &str) -> Self {
        let root = std::env::temp_dir().join(format!(
            "apianyware-extract-objc-linkage-test-{}",
            std::process::id()
        ));
        // Remove any stale directory from a prior crashed run.
        let _ = fs::remove_dir_all(&root);
        let headers_dir = root.join(format!(
            "System/Library/Frameworks/{framework_name}.framework/Headers"
        ));
        fs::create_dir_all(&headers_dir).expect("create headers dir");
        Self { root, headers_dir }
    }

    fn write_header(&self, file_name: &str, content: &str) -> PathBuf {
        let path = self.headers_dir.join(file_name);
        fs::write(&path, content).expect("write header");
        path
    }

    fn root_path(&self) -> &std::path::Path {
        &self.root
    }
}

impl Drop for SyntheticSdk {
    fn drop(&mut self) {
        let _ = fs::remove_dir_all(&self.root);
    }
}

fn constant_names() -> Vec<&'static str> {
    EXTRACTED
        .constants
        .iter()
        .map(|c| c.name.as_str())
        .collect()
}

fn function_names() -> Vec<&'static str> {
    EXTRACTED
        .functions
        .iter()
        .map(|f| f.name.as_str())
        .collect()
}

#[test]
fn extern_const_variable_is_kept() {
    let names = constant_names();
    assert!(
        names.contains(&"ExternalIntConst"),
        "extern const should be kept, got: {names:?}"
    );
}

#[test]
fn static_const_variables_are_filtered() {
    let names = constant_names();
    assert!(
        !names.contains(&"StaticIntConst"),
        "static const should be filtered (internal linkage), got: {names:?}"
    );
    assert!(
        !names.contains(&"StaticLongConst"),
        "static const should be filtered (internal linkage), got: {names:?}"
    );
}

#[test]
fn extern_function_is_kept() {
    let names = function_names();
    assert!(
        names.contains(&"external_function"),
        "extern function should be kept, got: {names:?}"
    );
}

#[test]
fn static_functions_are_filtered() {
    let names = function_names();
    assert!(
        !names.contains(&"static_inline_function"),
        "static inline function should be filtered, got: {names:?}"
    );
    assert!(
        !names.contains(&"static_function"),
        "static function should be filtered, got: {names:?}"
    );
}

// ---------------------------------------------------------------------------
// Skip recording — see `skipped_symbol_reason::INTERNAL_LINKAGE`.
//
// The internal-linkage filter used to return `None` silently, making the
// handful of static-const / static-inline removals per framework invisible
// post-hoc. These tests pin each filtered symbol to an explicit audit
// trail entry in `result.skipped_symbols` with a tagged reason so
// downstream audit tooling can match on it.
// ---------------------------------------------------------------------------

fn find_skipped(name: &str, kind: &str) -> Option<&'static ir::SkippedSymbol> {
    EXTRACTED
        .skipped_symbols
        .iter()
        .find(|s| s.name == name && s.kind == kind)
}

fn skipped_summary() -> Vec<(String, String, String)> {
    EXTRACTED
        .skipped_symbols
        .iter()
        .map(|s| (s.name.clone(), s.kind.clone(), s.reason.clone()))
        .collect()
}

#[test]
fn static_const_constants_are_recorded_in_skipped_symbols() {
    for name in ["StaticIntConst", "StaticLongConst"] {
        let entry = find_skipped(name, "constant").unwrap_or_else(|| {
            panic!(
                "expected {name} to be recorded in skipped_symbols with kind 'constant'; got: {:?}",
                skipped_summary()
            )
        });
        assert!(
            entry.reason.contains("internal_linkage"),
            "reason should carry the 'internal_linkage' tag, got: {}",
            entry.reason
        );
    }
}

#[test]
fn static_functions_are_recorded_in_skipped_symbols() {
    for name in ["static_inline_function", "static_function"] {
        let entry = find_skipped(name, "function").unwrap_or_else(|| {
            panic!(
                "expected {name} to be recorded in skipped_symbols with kind 'function'; got: {:?}",
                skipped_summary()
            )
        });
        assert!(
            entry.reason.contains("internal_linkage"),
            "reason should carry the 'internal_linkage' tag, got: {}",
            entry.reason
        );
    }
}

#[test]
fn skipped_symbols_have_no_duplicate_entries() {
    let mut seen = std::collections::HashSet::new();
    for entry in &EXTRACTED.skipped_symbols {
        let key = (entry.name.clone(), entry.kind.clone());
        assert!(
            seen.insert(key.clone()),
            "duplicate (name, kind) skip entry: {key:?} — full list: {:?}",
            skipped_summary()
        );
    }
}
