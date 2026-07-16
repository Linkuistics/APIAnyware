//! Regression test for array-typed global constant extraction
//! (`array-constant-symbol-value-k109`).
//!
//! An `extern const T X[]` / `extern const T X[N]` global's *value* is its own symbol
//! address — not something stored at that address the way an ordinary pointer *variable*'s
//! value is. `Constant::array_element` records the array's element type so a downstream
//! target can tell a byte/char buffer (a plausible banner string) from anything else, without
//! misreading a `dlsym`'d array symbol as if it held a stored pointer.

use std::fs;
use std::path::PathBuf;
use std::sync::LazyLock;

use apianyware_extract_objc::extract_declarations::{
    extract_from_translation_unit, ExtractionResult,
};
use apianyware_extract_objc::{create_index, init_clang};
use apianyware_types::type_ref::TypeRefKind;

const FRAMEWORK_NAME: &str = "ArrayConstTestFW";

const SYNTHETIC_HEADER: &str = r#"
    // An incomplete (unsized) byte-array global — the measured *VersionString banner shape.
    extern const unsigned char TestVersionString[];

    // A sized byte-array global — the same species, just with a known length.
    extern const unsigned char TestFixedBuffer[16];

    // A non-byte-element array global (mirrors the real Kerberos::krb5_gss_oid_array case:
    // an array of a typedef'd struct, not a byte/char buffer).
    typedef struct { unsigned long length; void *elements; } TestOidDesc;
    extern const TestOidDesc TestOidArray[3];

    // An ordinary POINTER *variable* (not an array) — must NOT be misclassified as an
    // array-symbol global. Mirrors the real `NSFontIdentityMatrix` shape
    // (`const CGFloat * NSFontIdentityMatrix`, verified against the raw SDK header: a
    // pointer, not a `CGFloat[6]` array as an earlier measurement assumed).
    extern const double * TestMatrixPointer;
"#;

/// Shared extraction result (see `filter_internal_linkage.rs` for why this is a
/// `LazyLock<ExtractionResult>` rather than holding `clang::Clang` directly).
static EXTRACTED: LazyLock<ExtractionResult> = LazyLock::new(|| {
    let sdk = SyntheticSdk::new(FRAMEWORK_NAME);
    let header_path = sdk.write_header("ArrayConstTestFW.h", SYNTHETIC_HEADER);

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

/// Minimal synthetic SDK layout rooted at a temp directory (mirrors
/// `filter_internal_linkage.rs`'s helper of the same name — each integration test file keeps
/// its own copy rather than sharing one, the established pattern in this test suite).
struct SyntheticSdk {
    root: PathBuf,
    headers_dir: PathBuf,
}

impl SyntheticSdk {
    fn new(framework_name: &str) -> Self {
        let root = std::env::temp_dir().join(format!(
            "apianyware-extract-objc-array-const-test-{}",
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

fn constant(name: &str) -> &'static apianyware_types::ir::Constant {
    EXTRACTED
        .constants
        .iter()
        .find(|c| c.name == name)
        .unwrap_or_else(|| panic!("constant {name} not extracted"))
}

#[test]
fn incomplete_byte_array_carries_its_byte_element_type() {
    let c = constant("TestVersionString");
    // The declared type stays `Pointer` — still the ABI-correct shape for a `dlsym`'d symbol.
    assert!(matches!(c.constant_type.kind, TypeRefKind::Pointer));
    match &c.array_element {
        Some(elem) => match &elem.kind {
            TypeRefKind::Primitive { name } => assert_eq!(name, "uint8"),
            other => panic!("expected a uint8 primitive element, got {other:?}"),
        },
        None => panic!("expected array_element to be populated for an incomplete array global"),
    }
}

#[test]
fn sized_byte_array_carries_its_byte_element_type_too() {
    // A `ConstantArray` (known length) is the same species as an `IncompleteArray` for this
    // purpose — both are array-typed globals whose symbol address IS the array.
    let c = constant("TestFixedBuffer");
    match &c.array_element {
        Some(elem) => match &elem.kind {
            TypeRefKind::Primitive { name } => assert_eq!(name, "uint8"),
            other => panic!("expected a uint8 primitive element, got {other:?}"),
        },
        None => panic!("expected array_element to be populated for a sized array global"),
    }
}

#[test]
fn non_byte_element_array_still_carries_its_element_type() {
    // A struct-element array (the real Kerberos::krb5_gss_oid_array shape) is still recorded —
    // classification into "has a first-pass surface or not" is the emitter's job, not
    // extraction's; extraction's only job is to not lose the fact.
    let c = constant("TestOidArray");
    match &c.array_element {
        Some(elem) => assert!(
            matches!(&elem.kind, TypeRefKind::Struct { name } if name == "TestOidDesc"),
            "expected a TestOidDesc struct element, got {:?}",
            elem.kind
        ),
        None => panic!("expected array_element to be populated for a struct-element array"),
    }
}

#[test]
fn a_genuine_pointer_variable_is_not_misclassified_as_an_array_symbol() {
    // `const double * X` is an ordinary pointer VARIABLE (the real `NSFontIdentityMatrix`
    // shape) — its value is a stored pointer to load through, not its own address. Must not
    // carry `array_element`, or a downstream reader would wrongly treat a genuine stored
    // pointer as if dlsym's return value were the data itself.
    let c = constant("TestMatrixPointer");
    assert!(matches!(c.constant_type.kind, TypeRefKind::Pointer));
    assert!(
        c.array_element.is_none(),
        "a pointer variable must not carry array_element, got {:?}",
        c.array_element
    );
}
