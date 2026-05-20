//! Integration test: extract Foundation framework and spot-check results.
//!
//! This test actually invokes libclang to parse Foundation headers,
//! so it requires Xcode to be installed.

use std::sync::LazyLock;

use apianyware_macos_extract_objc::{create_index, extract_framework, init_clang, sdk};
use apianyware_macos_types::type_ref::TypeRefKind;

/// Shared extracted Foundation framework (expensive to compute, shared across tests).
static FOUNDATION: LazyLock<apianyware_macos_types::ir::Framework> = LazyLock::new(|| {
    let sdk = sdk::discover_sdk().expect("should discover macOS SDK");
    let frameworks = sdk::discover_frameworks(&sdk.path).expect("should discover frameworks");
    let foundation = frameworks
        .iter()
        .find(|f| f.name == "Foundation")
        .expect("Foundation not found");

    let clang = init_clang().expect("should initialize clang");
    let index = create_index(&clang);
    extract_framework(&index, foundation, &sdk).expect("should extract Foundation")
});

fn foundation() -> &'static apianyware_macos_types::ir::Framework {
    &FOUNDATION
}

#[test]
fn foundation_has_classes() {
    let fw = foundation();
    assert_eq!(fw.name, "Foundation");
    assert_eq!(fw.format_version, "1.0");
    assert_eq!(fw.checkpoint, "collected");
    assert!(fw.sdk_version.is_some());
    assert!(fw.collected_at.is_some());

    // Foundation should have many classes
    assert!(
        fw.classes.len() > 100,
        "expected >100 classes, got {}",
        fw.classes.len()
    );
}

#[test]
fn foundation_has_nsstring() {
    let fw = foundation();
    let nsstring = fw
        .classes
        .iter()
        .find(|c| c.name == "NSString")
        .expect("NSString not found");

    assert_eq!(nsstring.superclass, "NSObject");
    assert!(!nsstring.methods.is_empty(), "NSString should have methods");
    assert!(
        !nsstring.properties.is_empty(),
        "NSString should have properties"
    );
    assert!(
        nsstring.protocols.contains(&"NSCopying".to_string()),
        "NSString should conform to NSCopying"
    );
}

#[test]
fn foundation_nsstring_init_method() {
    let fw = foundation();
    let nsstring = fw.classes.iter().find(|c| c.name == "NSString").unwrap();
    let init = nsstring
        .methods
        .iter()
        .find(|m| m.selector == "init")
        .expect("init method not found on NSString");

    assert!(init.init_method);
    assert!(!init.class_method);
    assert!(matches!(init.return_type.kind, TypeRefKind::Instancetype));
}

#[test]
fn foundation_nsstring_length_property() {
    let fw = foundation();
    let nsstring = fw.classes.iter().find(|c| c.name == "NSString").unwrap();
    let length = nsstring
        .properties
        .iter()
        .find(|p| p.name == "length")
        .expect("length property not found on NSString");

    assert!(length.readonly);
    assert!(!length.class_property);
}

#[test]
fn foundation_has_protocols() {
    let fw = foundation();
    assert!(
        fw.protocols.len() > 10,
        "expected >10 protocols, got {}",
        fw.protocols.len()
    );

    let ns_copying = fw
        .protocols
        .iter()
        .find(|p| p.name == "NSCopying")
        .expect("NSCopying not found");
    assert!(!ns_copying.required_methods.is_empty());
}

#[test]
fn foundation_has_enums() {
    let fw = foundation();
    assert!(
        fw.enums.len() > 50,
        "expected >50 enums, got {}",
        fw.enums.len()
    );
}

#[test]
fn foundation_has_functions() {
    let fw = foundation();
    assert!(
        fw.functions.len() > 20,
        "expected >20 functions, got {}",
        fw.functions.len()
    );
}

#[test]
fn foundation_skips_static_const_variables() {
    // `NSHashTableCopyIn`, `NSHashTableStrongMemory`, and similar symbols
    // in NSHashTable.h are declared as `static const NSPointerFunctionsOptions`.
    // They have internal linkage, no dylib symbol, and must be filtered from
    // the constants list so downstream `dlsym`-based bindings don't fail
    // at load time.
    let fw = foundation();
    let leaked: Vec<&str> = fw
        .constants
        .iter()
        .map(|c| c.name.as_str())
        .filter(|name| {
            matches!(
                *name,
                "NSHashTableCopyIn"
                    | "NSHashTableStrongMemory"
                    | "NSHashTableWeakMemory"
                    | "NSHashTableObjectPointerPersonality"
                    | "NSHashTableZeroingWeakMemory"
            )
        })
        .collect();
    assert!(
        leaked.is_empty(),
        "static const variables should be filtered out, but found: {leaked:?}"
    );
}

#[test]
fn foundation_has_constants() {
    let fw = foundation();
    assert!(
        fw.constants.len() > 100,
        "expected >100 constants, got {}",
        fw.constants.len()
    );
}

#[test]
fn foundation_has_block_params() {
    let fw = foundation();
    let has_block = fw.classes.iter().flat_map(|c| &c.methods).any(|m| {
        m.params
            .iter()
            .any(|p| matches!(p.param_type.kind, TypeRefKind::Block { .. }))
    });
    assert!(
        has_block,
        "expected at least one method with a block parameter"
    );
}

#[test]
fn foundation_methods_have_provenance() {
    let fw = foundation();
    let nsstring = fw.classes.iter().find(|c| c.name == "NSString").unwrap();
    let init = nsstring
        .methods
        .iter()
        .find(|m| m.selector == "init")
        .unwrap();

    let provenance = init
        .provenance
        .as_ref()
        .expect("init should have provenance");
    assert!(provenance.header.is_some(), "should have header path");
    assert!(provenance.line.is_some(), "should have line number");
}

#[test]
fn foundation_methods_have_doc_refs() {
    let fw = foundation();
    let nsstring = fw.classes.iter().find(|c| c.name == "NSString").unwrap();
    // Not all methods have USRs, but at least some should
    let has_usr = nsstring
        .methods
        .iter()
        .any(|m| m.doc_refs.as_ref().and_then(|d| d.usr.as_ref()).is_some());
    assert!(has_usr, "at least some NSString methods should have USRs");
}

#[test]
fn foundation_methods_have_source_field() {
    let fw = foundation();
    let nsstring = fw.classes.iter().find(|c| c.name == "NSString").unwrap();
    for method in &nsstring.methods {
        assert_eq!(
            method.source,
            Some(apianyware_macos_types::provenance::DeclarationSource::ObjcHeader),
            "method {} should have source ObjcHeader",
            method.selector
        );
    }
}

#[test]
fn foundation_bool_return_resolves_to_primitive_bool() {
    // ObjC `BOOL` is a typedef (unsigned char on intel, bool on arm64) that
    // libclang surfaces as a typedef node. The extractor must resolve it to
    // `TypeRefKind::Primitive { name: "bool" }` so the Racket FFI mapper emits
    // `_bool` — not `_uint8`. `_uint8` decodes to an integer in Racket, and
    // all integers (including 0) are truthy, silently misidentifying `NO`.
    //
    // `NSBundle -load` is a well-known BOOL-returning method present in
    // every macOS SDK.
    let fw = foundation();
    let nsbundle = fw.classes.iter().find(|c| c.name == "NSBundle").unwrap();
    let load = nsbundle
        .methods
        .iter()
        .find(|m| m.selector == "load")
        .expect("load should be present on NSBundle");

    match &load.return_type.kind {
        TypeRefKind::Primitive { name } => {
            assert_eq!(
                name, "bool",
                "NSBundle -load should return Primitive {{ name: \"bool\" }}, got {name:?}"
            );
        }
        other => {
            panic!("NSBundle -load return should be Primitive {{ name: \"bool\" }}, got {other:?}")
        }
    }
}

#[test]
fn foundation_nsundomanager_captures_swift_ui_actor_macro() {
    // `NSUndoManager` carries class-level `NS_SWIFT_UI_ACTOR`, which expands
    // to `__attribute__((swift_attr("@MainActor")))`. The ObjC extractor must
    // surface this in `swift_attributes` so the `derive_threading` heuristic
    // sees the MainActor signal even when the Swift digester output omits it
    // (e.g. for a pure-ObjC re-extraction without the Swift merge step).
    let fw = foundation();
    let undo_manager = fw
        .classes
        .iter()
        .find(|c| c.name == "NSUndoManager")
        .expect("NSUndoManager not found");

    assert!(
        undo_manager
            .swift_attributes
            .iter()
            .any(|a| a == "MainActor"),
        "NSUndoManager should carry \"MainActor\" in swift_attributes, got {:?}",
        undo_manager.swift_attributes
    );
}

#[test]
fn foundation_nsstring_has_no_swift_ui_actor_attribute() {
    // Negative case: NSString has no MainActor annotation in its ObjC header,
    // so the extractor must not spuriously synthesise one.
    let fw = foundation();
    let nsstring = fw.classes.iter().find(|c| c.name == "NSString").unwrap();
    assert!(
        !nsstring.swift_attributes.iter().any(|a| a == "MainActor"),
        "NSString should not carry MainActor swift_attribute"
    );
}

#[test]
fn foundation_serializes_to_json() {
    let fw = foundation();
    let json = serde_json::to_string_pretty(&fw).expect("should serialize to JSON");
    assert!(json.contains("\"name\": \"Foundation\""));
    assert!(json.contains("\"checkpoint\": \"collected\""));

    // Verify roundtrip
    let deserialized: apianyware_macos_types::ir::Framework =
        serde_json::from_str(&json).expect("should deserialize from JSON");
    assert_eq!(deserialized.name, "Foundation");
    assert_eq!(deserialized.classes.len(), fw.classes.len());
}
