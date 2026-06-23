//! Regression test for the platform-unavailability filter.
//!
//! Declarations marked `API_UNAVAILABLE(macos)` (or the more specific
//! `__attribute__((availability(macos, unavailable)))`) have no dylib
//! symbol in the macOS variant of the framework binary — the symbol
//! exists only in the sibling platform dylibs (visionOS, iOS, etc.).
//! Downstream `dlsym`-based bindings that reference such a declaration
//! fail at load time with
//! `get-ffi-obj: could not find export from foreign library`.
//!
//! Real-world trigger: AudioToolbox's
//! `kAudioServicesDetailIntendedSpatialExperience` is
//! `extern const CFStringRef` with `API_AVAILABLE(visionos(26.0))
//! API_UNAVAILABLE(ios, watchos, tvos, macos)`. It has `Linkage::External`
//! (so the existing internal-linkage filter does not catch it) and a
//! bare `c:@<name>` USR (indistinguishable from a legitimate macOS C
//! VarDecl by USR shape alone). The discriminator must be the libclang
//! platform availability API, not linkage or USR.

use std::fs;
use std::path::PathBuf;
use std::sync::LazyLock;

use apianyware_extract_objc::extract_declarations::{
    extract_from_translation_unit, ExtractionResult,
};
use apianyware_extract_objc::{create_index, init_clang};
use apianyware_types::ir;

const FRAMEWORK_NAME: &str = "AvailabilityTestFW";

const SYNTHETIC_HEADER: &str = r#"
    // --- constants: available vs unavailable-on-macos ---

    // Plain extern — available on all platforms by default.
    extern const int AvailableConst;

    // Explicitly unavailable on macos — no dylib symbol on macOS.
    extern const int UnavailableOnMacosConst
        __attribute__((availability(macos, unavailable)));

    // Visionos-only canary (mirrors the real AudioToolbox shape):
    // available on visionos, unavailable on all other Apple platforms.
    // The `unavailable` attribute on macos is the load-bearing signal
    // even if other platforms are also listed.
    extern const int VisionosOnlyConst
        __attribute__((availability(visionos, introduced=1.0)))
        __attribute__((availability(ios, unavailable)))
        __attribute__((availability(watchos, unavailable)))
        __attribute__((availability(tvos, unavailable)))
        __attribute__((availability(macos, unavailable)));

    // --- functions: same three shapes ---

    extern int available_function(int x);

    extern int unavailable_on_macos_function(int x)
        __attribute__((availability(macos, unavailable)));

    extern int visionos_only_function(int x)
        __attribute__((availability(visionos, introduced=1.0)))
        __attribute__((availability(macos, unavailable)));

    // --- classes: wholesale drop when the class itself is unavailable ---

    // Plain available class — a control case.
    @interface AvailableClass
    - (int)plainMethod;
    @end

    // Whole class unavailable on macos — `objc_msgSend` against this
    // selector-family would crash with `unrecognized selector` at
    // first call. Drop wholesale to keep the IR honest.
    __attribute__((availability(macos, unavailable)))
    @interface UnavailableClass
    - (int)doomedMethod;
    @end

    // --- mixed-availability class: the subtle case ---
    //
    // Class is fully available on macos, but individual selectors are
    // not. This is the shape that `API_UNAVAILABLE(macos)` takes on a
    // single method declared inside a shared header — common in
    // CoreMIDI / UIKit-family categories. libclang must expose
    // per-method availability for this to work.
    @interface MixedClass
    - (int)availableInstanceMethod;
    - (int)unavailableInstanceMethod
        __attribute__((availability(macos, unavailable)));
    + (int)availableClassMethod;
    + (int)unavailableClassMethod
        __attribute__((availability(macos, unavailable)));

    // Per-property availability — symmetric to per-method. A
    // property declared on an available class can still be
    // platform-gated; its getter/setter selectors have no
    // implementation in the macos variant of the dylib and would
    // crash at first call with `unrecognized selector`.
    @property int availableInstanceProperty;
    @property int unavailableInstanceProperty
        __attribute__((availability(macos, unavailable)));
    @property (class) int availableClassProperty;
    @property (class) int unavailableClassProperty
        __attribute__((availability(macos, unavailable)));
    @end

    // --- protocols: same two shapes ---

    @protocol AvailableProtocol
    - (void)protoMethod;
    @end

    __attribute__((availability(macos, unavailable)))
    @protocol UnavailableProtocol
    - (void)doomedProtoMethod;
    @end
"#;

/// Shared extraction result.
///
/// `clang::Clang` is `!Send + !Sync`, so it cannot live inside a
/// `LazyLock`. Extraction runs once inside the closure, `Clang` is
/// dropped, and the plain `ExtractionResult` (which is `Send + Sync`)
/// is cached.
static EXTRACTED: LazyLock<ExtractionResult> = LazyLock::new(|| {
    let sdk = SyntheticSdk::new(FRAMEWORK_NAME);
    let header_path = sdk.write_header("AvailabilityTestFW.h", SYNTHETIC_HEADER);

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
});

/// Minimal synthetic SDK layout rooted at a temp directory. Mirrors the
/// real SDK's `System/Library/Frameworks/{Name}.framework/Headers/`
/// path so `extract_from_translation_unit`'s framework filter accepts
/// the headers.
struct SyntheticSdk {
    root: PathBuf,
    headers_dir: PathBuf,
}

impl SyntheticSdk {
    fn new(framework_name: &str) -> Self {
        let root = std::env::temp_dir().join(format!(
            "apianyware-extract-objc-availability-test-{}",
            std::process::id()
        ));
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

fn class_names() -> Vec<&'static str> {
    EXTRACTED.classes.iter().map(|c| c.name.as_str()).collect()
}

fn protocol_names() -> Vec<&'static str> {
    EXTRACTED
        .protocols
        .iter()
        .map(|p| p.name.as_str())
        .collect()
}

fn method_selectors_for(class_name: &str) -> Vec<&str> {
    let class = EXTRACTED
        .classes
        .iter()
        .find(|c| c.name == class_name)
        .unwrap_or_else(|| panic!("class {class_name} not extracted; got {:?}", class_names()));
    class.methods.iter().map(|m| m.selector.as_str()).collect()
}

fn property_names_for(class_name: &str) -> Vec<&str> {
    let class = EXTRACTED
        .classes
        .iter()
        .find(|c| c.name == class_name)
        .unwrap_or_else(|| panic!("class {class_name} not extracted; got {:?}", class_names()));
    class.properties.iter().map(|p| p.name.as_str()).collect()
}

#[test]
fn available_constant_is_kept() {
    let names = constant_names();
    assert!(
        names.contains(&"AvailableConst"),
        "plain extern const should be kept, got: {names:?}"
    );
}

#[test]
fn unavailable_on_macos_constant_is_filtered() {
    let names = constant_names();
    assert!(
        !names.contains(&"UnavailableOnMacosConst"),
        "extern const marked unavailable on macos must be filtered, got: {names:?}"
    );
}

#[test]
fn visionos_only_constant_is_filtered() {
    let names = constant_names();
    assert!(
        !names.contains(&"VisionosOnlyConst"),
        "visionos-only extern const must be filtered when unavailable on macos, got: {names:?}"
    );
}

#[test]
fn available_function_is_kept() {
    let names = function_names();
    assert!(
        names.contains(&"available_function"),
        "plain extern function should be kept, got: {names:?}"
    );
}

#[test]
fn unavailable_on_macos_function_is_filtered() {
    let names = function_names();
    assert!(
        !names.contains(&"unavailable_on_macos_function"),
        "extern function marked unavailable on macos must be filtered, got: {names:?}"
    );
}

#[test]
fn visionos_only_function_is_filtered() {
    let names = function_names();
    assert!(
        !names.contains(&"visionos_only_function"),
        "visionos-only extern function must be filtered when unavailable on macos, got: {names:?}"
    );
}

// ---------------------------------------------------------------------------
// Classes
// ---------------------------------------------------------------------------

#[test]
fn available_class_is_kept() {
    let names = class_names();
    assert!(
        names.contains(&"AvailableClass"),
        "plain @interface should be kept, got: {names:?}"
    );
}

#[test]
fn unavailable_class_is_filtered_wholesale() {
    let names = class_names();
    assert!(
        !names.contains(&"UnavailableClass"),
        "class marked unavailable on macos must be dropped wholesale, got: {names:?}"
    );
}

// ---------------------------------------------------------------------------
// Methods — per-selector availability on an otherwise-available class
// ---------------------------------------------------------------------------

#[test]
fn mixed_class_is_kept() {
    let names = class_names();
    assert!(
        names.contains(&"MixedClass"),
        "class available on macos must be kept even if some selectors are not, got: {names:?}"
    );
}

#[test]
fn available_instance_method_is_kept() {
    let selectors = method_selectors_for("MixedClass");
    assert!(
        selectors.contains(&"availableInstanceMethod"),
        "plain instance method should be kept, got: {selectors:?}"
    );
}

#[test]
fn unavailable_instance_method_is_filtered() {
    let selectors = method_selectors_for("MixedClass");
    assert!(
        !selectors.contains(&"unavailableInstanceMethod"),
        "instance method marked unavailable on macos must be filtered, got: {selectors:?}"
    );
}

#[test]
fn available_class_method_is_kept() {
    let selectors = method_selectors_for("MixedClass");
    assert!(
        selectors.contains(&"availableClassMethod"),
        "plain class method should be kept, got: {selectors:?}"
    );
}

#[test]
fn unavailable_class_method_is_filtered() {
    let selectors = method_selectors_for("MixedClass");
    assert!(
        !selectors.contains(&"unavailableClassMethod"),
        "class method marked unavailable on macos must be filtered, got: {selectors:?}"
    );
}

// ---------------------------------------------------------------------------
// Properties — per-property availability on an otherwise-available class
// ---------------------------------------------------------------------------

#[test]
fn available_instance_property_is_kept() {
    let names = property_names_for("MixedClass");
    assert!(
        names.contains(&"availableInstanceProperty"),
        "plain instance property should be kept, got: {names:?}"
    );
}

#[test]
fn unavailable_instance_property_is_filtered() {
    let names = property_names_for("MixedClass");
    assert!(
        !names.contains(&"unavailableInstanceProperty"),
        "instance property marked unavailable on macos must be filtered, got: {names:?}"
    );
}

#[test]
fn available_class_property_is_kept() {
    let names = property_names_for("MixedClass");
    assert!(
        names.contains(&"availableClassProperty"),
        "plain class property should be kept, got: {names:?}"
    );
}

#[test]
fn unavailable_class_property_is_filtered() {
    let names = property_names_for("MixedClass");
    assert!(
        !names.contains(&"unavailableClassProperty"),
        "class property marked unavailable on macos must be filtered, got: {names:?}"
    );
}

// ---------------------------------------------------------------------------
// Protocols
// ---------------------------------------------------------------------------

#[test]
fn available_protocol_is_kept() {
    let names = protocol_names();
    assert!(
        names.contains(&"AvailableProtocol"),
        "plain @protocol should be kept, got: {names:?}"
    );
}

#[test]
fn unavailable_protocol_is_filtered_wholesale() {
    let names = protocol_names();
    assert!(
        !names.contains(&"UnavailableProtocol"),
        "protocol marked unavailable on macos must be dropped wholesale, got: {names:?}"
    );
}

// ---------------------------------------------------------------------------
// Skip recording — see `skipped_symbol_reason::PLATFORM_UNAVAILABLE_MACOS`.
//
// The availability filter used to return `None` silently, so the ~1,738
// real-world removals (876 constants + 862 functions, plus thousands of
// class/method/property drops) were invisible post-hoc. These tests pin
// each filtered declaration to an explicit audit trail entry in
// `result.skipped_symbols` with a tagged reason that downstream tooling
// can match on.
// ---------------------------------------------------------------------------

const PLATFORM_TAG: &str = "platform_unavailable_macos";

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

fn assert_platform_skip(name: &str, kind: &str) {
    let entry = find_skipped(name, kind).unwrap_or_else(|| {
        panic!(
            "expected {name} ({kind}) to be recorded in skipped_symbols; got: {:?}",
            skipped_summary()
        )
    });
    assert!(
        entry.reason.contains(PLATFORM_TAG),
        "reason should carry the '{PLATFORM_TAG}' tag, got: {}",
        entry.reason
    );
}

#[test]
fn unavailable_constants_are_recorded_in_skipped_symbols() {
    assert_platform_skip("UnavailableOnMacosConst", "constant");
    assert_platform_skip("VisionosOnlyConst", "constant");
}

#[test]
fn unavailable_functions_are_recorded_in_skipped_symbols() {
    assert_platform_skip("unavailable_on_macos_function", "function");
    assert_platform_skip("visionos_only_function", "function");
}

#[test]
fn unavailable_class_is_recorded_in_skipped_symbols() {
    assert_platform_skip("UnavailableClass", "class");
}

#[test]
fn unavailable_protocol_is_recorded_in_skipped_symbols() {
    assert_platform_skip("UnavailableProtocol", "protocol");
}

#[test]
fn unavailable_instance_method_is_recorded_in_skipped_symbols() {
    assert_platform_skip("MixedClass.unavailableInstanceMethod", "method");
}

#[test]
fn unavailable_class_method_is_recorded_in_skipped_symbols() {
    assert_platform_skip("MixedClass.unavailableClassMethod", "method");
}

#[test]
fn unavailable_instance_property_is_recorded_in_skipped_symbols() {
    assert_platform_skip("MixedClass.unavailableInstanceProperty", "property");
}

#[test]
fn unavailable_class_property_is_recorded_in_skipped_symbols() {
    assert_platform_skip("MixedClass.unavailableClassProperty", "property");
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
