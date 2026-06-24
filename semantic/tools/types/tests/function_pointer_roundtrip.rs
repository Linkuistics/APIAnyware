//! Tests: round-trip serialization/deserialization of FunctionPointer TypeRefKind.

use apianyware_types::type_ref::{TypeRef, TypeRefKind};

#[test]
fn function_pointer_with_name_roundtrip() {
    let fp = TypeRef {
        nullable: false,
        kind: TypeRefKind::FunctionPointer {
            name: Some("CGEventTapCallBack".to_string()),
            params: vec![
                TypeRef {
                    nullable: false,
                    kind: TypeRefKind::Alias {
                        name: "CGEventTapProxy".to_string(),
                        framework: None,
                        underlying_primitive: None,
                    },
                },
                TypeRef {
                    nullable: false,
                    kind: TypeRefKind::Primitive {
                        name: "uint32".to_string(),
                    },
                },
            ],
            return_type: Box::new(TypeRef {
                nullable: false,
                kind: TypeRefKind::Alias {
                    name: "CGEventRef".to_string(),
                    framework: None,
                    underlying_primitive: None,
                },
            }),
        },
    };

    let json = serde_json::to_string_pretty(&fp).unwrap();
    let deserialized: TypeRef = serde_json::from_str(&json).unwrap();

    match &deserialized.kind {
        TypeRefKind::FunctionPointer {
            name,
            params,
            return_type,
        } => {
            assert_eq!(name.as_deref(), Some("CGEventTapCallBack"));
            assert_eq!(params.len(), 2);
            assert!(
                matches!(&params[0].kind, TypeRefKind::Alias { name, .. } if name == "CGEventTapProxy")
            );
            assert!(
                matches!(&return_type.kind, TypeRefKind::Alias { name, .. } if name == "CGEventRef")
            );
        }
        other => panic!("expected FunctionPointer, got {other:?}"),
    }
}

#[test]
fn function_pointer_without_name_roundtrip() {
    let fp = TypeRef {
        nullable: false,
        kind: TypeRefKind::FunctionPointer {
            name: None,
            params: vec![TypeRef {
                nullable: false,
                kind: TypeRefKind::Pointer,
            }],
            return_type: Box::new(TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "void".to_string(),
                },
            }),
        },
    };

    let json = serde_json::to_string_pretty(&fp).unwrap();

    // The top-level FunctionPointer should not have a "name" key serialized,
    // but nested types (Primitive) may have their own "name" fields.
    // Verify by deserializing and checking the name is None.
    let deserialized: TypeRef = serde_json::from_str(&json).unwrap();
    match &deserialized.kind {
        TypeRefKind::FunctionPointer {
            name,
            params,
            return_type,
        } => {
            assert!(name.is_none());
            assert_eq!(params.len(), 1);
            assert!(matches!(&return_type.kind, TypeRefKind::Primitive { name } if name == "void"));
        }
        other => panic!("expected FunctionPointer, got {other:?}"),
    }
}

#[test]
fn function_pointer_json_has_correct_kind_tag() {
    let fp = TypeRef {
        nullable: false,
        kind: TypeRefKind::FunctionPointer {
            name: Some("MyCallback".to_string()),
            params: vec![],
            return_type: Box::new(TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "void".to_string(),
                },
            }),
        },
    };

    let json = serde_json::to_string(&fp).unwrap();
    assert!(json.contains(r#""kind":"function_pointer""#));
}

#[test]
fn function_pointer_in_framework_roundtrip() {
    use apianyware_types::ir::{Framework, Function, Param};

    let fw = Framework {
        format_version: "1.0".to_string(),
        checkpoint: "extracted".to_string(),
        name: "TestFramework".to_string(),
        sdk_version: None,
        collected_at: None,
        depends_on: vec![],
        skipped_symbols: vec![],
        classes: vec![],
        protocols: vec![],
        enums: vec![],
        structs: vec![],
        functions: vec![Function {
            name: "TestFuncWithCallback".to_string(),
            params: vec![Param {
                name: "callback".to_string(),
                param_type: TypeRef {
                    nullable: false,
                    kind: TypeRefKind::FunctionPointer {
                        name: Some("TestCallback".to_string()),
                        params: vec![TypeRef {
                            nullable: false,
                            kind: TypeRefKind::Pointer,
                        }],
                        return_type: Box::new(TypeRef {
                            nullable: false,
                            kind: TypeRefKind::Primitive {
                                name: "void".to_string(),
                            },
                        }),
                    },
                },
            }],
            return_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "void".to_string(),
                },
            },
            inline: false,
            variadic: false,
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: true,
            swift_fn: None,
        }],
        constants: vec![],
        class_annotations: vec![],
        api_patterns: vec![],
        enrichment: None,
        verification: None,
    };

    let json = serde_json::to_string_pretty(&fw).unwrap();
    let deserialized: Framework = serde_json::from_str(&json).unwrap();

    assert_eq!(deserialized.functions.len(), 1);
    let func = &deserialized.functions[0];
    assert_eq!(func.params.len(), 1);
    assert!(matches!(
        &func.params[0].param_type.kind,
        TypeRefKind::FunctionPointer { name: Some(n), .. } if n == "TestCallback"
    ));
}
