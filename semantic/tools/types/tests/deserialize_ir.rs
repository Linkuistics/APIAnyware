//! Schema-evolution tests for `Framework` deserialization.
//!
//! These tests pin the serde defaults for fields added after the initial
//! checkpoint schema. A single synthetic JSON literal exercises every
//! default and round-trip guarantee in one pass — no on-disk SDK fixtures.

use apianyware_types::ir::Framework;
use apianyware_types::type_ref::{TypeRef, TypeRefKind};

/// Minimal modern document: the absolute-minimum set of fields a valid
/// checkpoint must carry, with every post-minimum field omitted so the
/// serde `default` attributes are exercised.
const MINIMAL_FRAMEWORK_JSON: &str = r#"{
    "format_version": "1.0",
    "name": "Foundation",
    "depends_on": ["CoreFoundation"],
    "classes": [],
    "protocols": [],
    "enums": [],
    "structs": [],
    "functions": [],
    "constants": []
}"#;

#[test]
fn format_version_deserializes() {
    let fw: Framework = serde_json::from_str(MINIMAL_FRAMEWORK_JSON).unwrap();
    assert_eq!(fw.format_version, "1.0");
}

#[test]
fn name_deserializes() {
    let fw: Framework = serde_json::from_str(MINIMAL_FRAMEWORK_JSON).unwrap();
    assert_eq!(fw.name, "Foundation");
}

#[test]
fn post_minimum_fields_default_when_missing() {
    let fw: Framework = serde_json::from_str(MINIMAL_FRAMEWORK_JSON).unwrap();
    assert!(fw.sdk_version.is_none());
    assert!(fw.collected_at.is_none());
    assert!(fw.checkpoint.is_empty());
    assert!(fw.skipped_symbols.is_empty());
    assert!(fw.class_annotations.is_empty());
    assert!(fw.patterns.is_empty());
    assert!(fw.enrichment.is_none());
    assert!(fw.verification.is_none());
}

#[test]
fn depends_on_round_trips() {
    let fw: Framework = serde_json::from_str(MINIMAL_FRAMEWORK_JSON).unwrap();
    assert_eq!(fw.depends_on, vec!["CoreFoundation".to_string()]);
}

/// Round-trip: deserialise → serialise → deserialise preserves semantics.
#[test]
fn minimal_round_trip_preserves_semantics() {
    let original: Framework = serde_json::from_str(MINIMAL_FRAMEWORK_JSON).unwrap();
    let reserialised = serde_json::to_string(&original).unwrap();
    let reparsed: Framework = serde_json::from_str(&reserialised).unwrap();

    assert_eq!(reparsed.format_version, original.format_version);
    assert_eq!(reparsed.name, original.name);
    assert_eq!(reparsed.depends_on, original.depends_on);
}

// ---------------------------------------------------------------------------
// objc_exposed checkpoint contract (ADR-0026)
//
// The field defaults to `true` and is omitted from JSON when true, so the
// every-stage checkpoint diff audits exactly the trampoline residual. These
// tests pin that contract — it is what lets `objc_exposed` ride additively
// through collect → resolve → annotate → enrich (each stage round-trips the
// checkpoint via this same serde behaviour).
// ---------------------------------------------------------------------------

fn cstring_type() -> TypeRef {
    TypeRef {
        nullable: false,
        kind: TypeRefKind::Primitive {
            name: "int32".to_string(),
        },
    }
}

/// A pre-objc_exposed checkpoint (field absent) deserialises as ObjC-exposed.
#[test]
fn objc_exposed_defaults_true_when_absent() {
    // A constant with no `objc_exposed` key — exactly how every existing ObjC
    // golden looks.
    let json = r#"{
        "format_version": "1.0", "name": "F",
        "constants": [{ "name": "kFoo", "type": { "kind": "primitive", "name": "int32" } }]
    }"#;
    let fw: Framework = serde_json::from_str(json).unwrap();
    assert!(
        fw.constants[0].objc_exposed,
        "absent objc_exposed must default to true (the ObjC-exposed limit)"
    );
}

/// `objc_exposed: true` is omitted on serialisation; `false` is written.
#[test]
fn objc_exposed_skipped_when_true_emitted_when_false() {
    let exposed = apianyware_types::ir::Constant {
        name: "kObjc".to_string(),
        constant_type: cstring_type(),
        array_element: None,
        source: None,
        provenance: None,
        doc_refs: None,
        macro_value: None,
        objc_exposed: true,
    };
    let native = apianyware_types::ir::Constant {
        name: "kSwift".to_string(),
        objc_exposed: false,
        ..exposed.clone()
    };

    let exposed_json = serde_json::to_string(&exposed).unwrap();
    assert!(
        !exposed_json.contains("objc_exposed"),
        "true must be omitted; got {exposed_json}"
    );
    let native_json = serde_json::to_string(&native).unwrap();
    assert!(
        native_json.contains("\"objc_exposed\":false"),
        "false must be serialised; got {native_json}"
    );
}

/// The Swift-native residual survives a full serialise → deserialise checkpoint
/// boundary (the operation every pipeline stage performs).
#[test]
fn objc_exposed_false_survives_checkpoint_round_trip() {
    let json = r#"{
        "format_version": "1.0", "name": "F",
        "functions": [{ "name": "swiftFn", "return_type": { "kind": "primitive", "name": "void" }, "objc_exposed": false }],
        "constants": [{ "name": "kSwift", "type": { "kind": "primitive", "name": "int32" }, "objc_exposed": false }]
    }"#;
    let fw: Framework = serde_json::from_str(json).unwrap();
    let reparsed: Framework = serde_json::from_str(&serde_json::to_string(&fw).unwrap()).unwrap();
    assert!(!reparsed.functions[0].objc_exposed);
    assert!(!reparsed.constants[0].objc_exposed);
}

// ---------------------------------------------------------------------------
// Protocol-qualified `id` (`protocol-qualifier-ir-k81`)
// ---------------------------------------------------------------------------

/// The qualifier is additive: an unqualified `id` serialises exactly as it did
/// before `protocols` existed. This is what lets the four Lisp targets' goldens
/// stay byte-identical across the change — the wire format did not move.
#[test]
fn unqualified_id_serialises_without_a_protocols_key() {
    let json = serde_json::to_string(&TypeRef {
        nullable: false,
        kind: TypeRefKind::Id {
            protocols: Vec::new(),
        },
    })
    .unwrap();
    assert_eq!(json, r#"{"nullable":false,"kind":"id"}"#);
}

/// A pre-qualifier document — `{"kind":"id"}` with no `protocols` key — still
/// deserialises. Every checkpoint written before this change is one of these.
#[test]
fn id_without_protocols_key_deserialises_as_unqualified() {
    let t: TypeRef = serde_json::from_str(r#"{"kind":"id"}"#).unwrap();
    match t.kind {
        TypeRefKind::Id { protocols } => assert!(protocols.is_empty()),
        other => panic!("expected Id, got {other:?}"),
    }
}

/// `id<NSObject, NSCopying>` is legal ObjC, so the qualifier is a list, and it
/// survives the serialise → deserialise checkpoint boundary in order.
#[test]
fn qualified_id_round_trips_its_protocol_list() {
    let original = TypeRef {
        nullable: true,
        kind: TypeRefKind::Id {
            protocols: vec!["NSObject".to_string(), "NSCopying".to_string()],
        },
    };
    let json = serde_json::to_string(&original).unwrap();
    assert_eq!(
        json,
        r#"{"nullable":true,"kind":"id","protocols":["NSObject","NSCopying"]}"#
    );

    let reparsed: TypeRef = serde_json::from_str(&json).unwrap();
    match reparsed.kind {
        TypeRefKind::Id { protocols } => assert_eq!(protocols, ["NSObject", "NSCopying"]),
        other => panic!("expected Id, got {other:?}"),
    }
}
