//! Map swift-api-digester type nodes to IR [`TypeRef`] values.
//!
//! The digester represents types as `TypeNominal`, `TypeFunc`, and other
//! node kinds within the ABIRoot tree. This module converts those nodes
//! into the shared [`TypeRef`] / [`TypeRefKind`] representation.

use apianyware_types::type_ref::{TypeRef, TypeRefKind};

use crate::abi_types::AbiNode;

/// Map an ABI type node (typically `TypeNominal` or `TypeFunc`) to an IR [`TypeRef`].
///
/// Returns a best-effort mapping. Unknown or unrepresentable types fall back
/// to `Primitive { name: printedName }`.
pub fn map_swift_type(node: &AbiNode) -> TypeRef {
    match node.kind.as_str() {
        "TypeNominal" => map_type_nominal(node),
        "TypeFunc" => map_type_func(node),
        // TypeNameAlias: a type reference through a typedef. The first child
        // is the resolved underlying type — recurse into it rather than
        // storing the alias's printedName as a Primitive.
        "TypeNameAlias" if !node.children.is_empty() => map_swift_type(&node.children[0]),
        _ => TypeRef {
            nullable: false,
            kind: TypeRefKind::Primitive {
                name: node.printed_name.clone(),
            },
        },
    }
}

/// Map a `TypeNominal` node to a [`TypeRef`].
///
/// Handles Swift standard library types, Foundation bridged types, Optional,
/// Array, Dictionary, class references, and protocol existentials.
fn map_type_nominal(node: &AbiNode) -> TypeRef {
    let name = node.name.as_str();
    let usr = node.usr.as_deref().unwrap_or("");

    // Optional<T> → nullable inner type
    if name == "Optional" && !node.children.is_empty() {
        let mut inner = map_swift_type(&node.children[0]);
        inner.nullable = true;
        return inner;
    }

    // Void → primitive void
    if name == "Void" {
        return TypeRef {
            nullable: false,
            kind: TypeRefKind::Primitive {
                name: "void".to_string(),
            },
        };
    }

    // Swift primitive types
    if let Some(type_ref) = map_swift_primitive(name) {
        return type_ref;
    }

    // Array<T> → class NSArray with type params
    if name == "Array" {
        let params: Vec<TypeRef> = node.children.iter().map(map_swift_type).collect();
        return TypeRef {
            nullable: false,
            kind: TypeRefKind::Class {
                name: "NSArray".to_string(),
                framework: Some("Foundation".to_string()),
                params,
            },
        };
    }

    // Dictionary<K, V> → class NSDictionary with type params
    if name == "Dictionary" {
        let params: Vec<TypeRef> = node.children.iter().map(map_swift_type).collect();
        return TypeRef {
            nullable: false,
            kind: TypeRefKind::Class {
                name: "NSDictionary".to_string(),
                framework: Some("Foundation".to_string()),
                params,
            },
        };
    }

    // Set<T> → class NSSet with type params
    if name == "Set" {
        let params: Vec<TypeRef> = node.children.iter().map(map_swift_type).collect();
        return TypeRef {
            nullable: false,
            kind: TypeRefKind::Class {
                name: "NSSet".to_string(),
                framework: Some("Foundation".to_string()),
                params,
            },
        };
    }

    // ObjC-bridged class: USR starts with "c:objc(cs)"
    if usr.starts_with("c:objc(cs)") {
        let objc_name = usr.strip_prefix("c:objc(cs)").unwrap_or(name);
        return TypeRef {
            nullable: false,
            kind: TypeRefKind::Class {
                name: objc_name.to_string(),
                framework: framework_from_printed_name(&node.printed_name),
                params: node.children.iter().map(map_swift_type).collect(),
            },
        };
    }

    // ObjC-bridged protocol: USR starts with "c:objc(pl)".
    //
    // The protocol's name is right here and is *not* carried onto the `id` — the Swift
    // dual of the ObjC qualifier gap `protocol-qualifier-ir-k81` closed. Filling it moves
    // the Swift-sourced IR and every target's goldens, so it belongs with the other
    // analysis-phase lowering repairs (`objc-object-type-lowering-k85`), not here.
    if usr.starts_with("c:objc(pl)") {
        return TypeRef {
            nullable: false,
            kind: TypeRefKind::Id {
                protocols: Vec::new(),
            },
        };
    }

    // Generic type parameter → id (erased)
    if name == "GenericTypeParam" {
        return TypeRef {
            nullable: false,
            kind: TypeRefKind::Id {
                protocols: Vec::new(),
            },
        };
    }

    // Metatype → class_ref
    if name == "Metatype" {
        return TypeRef {
            nullable: false,
            kind: TypeRefKind::ClassRef,
        };
    }

    // Known Foundation bridged types (Swift name → ObjC name)
    if let Some(bridged) = map_foundation_bridged_type(name) {
        return TypeRef {
            nullable: false,
            kind: TypeRefKind::Class {
                name: bridged.to_string(),
                framework: Some("Foundation".to_string()),
                params: vec![],
            },
        };
    }

    // Known POD/geometry struct (`swift-interface-nominal-lowering-k77`).
    // Framework-agnostic — CGRect belongs to CoreGraphics but is referenced
    // everywhere, so no local declaration can prove it; the name itself is
    // the proof, exactly as extract-objc's typedef expansion treats it (kept
    // in sync with `emit-typescript`'s `ffi_type_mapping::pod_struct_type`;
    // duplicated rather than shared since extract-swift is analysis-level and
    // must not depend on a target crate — ADR-0011).
    if is_pod_struct_name(name) {
        return TypeRef {
            nullable: false,
            kind: TypeRefKind::Struct {
                name: name.to_string(),
            },
        };
    }

    // Swift-native class/struct — extract framework from printedName
    let framework = framework_from_printed_name(&node.printed_name);
    let params: Vec<TypeRef> = node
        .children
        .iter()
        .filter(|c| c.kind == "TypeNominal")
        .map(map_swift_type)
        .collect();

    TypeRef {
        nullable: false,
        kind: TypeRefKind::Class {
            name: name.to_string(),
            framework,
            params,
        },
    }
}

/// Map a `TypeFunc` node to a block-style [`TypeRef`].
///
/// Swift closures `(A, B) -> R` map to ObjC blocks in the IR.
fn map_type_func(node: &AbiNode) -> TypeRef {
    // TypeFunc children: [0] = return type, [1] = parameter tuple
    if node.children.len() >= 2 {
        let return_type = map_swift_type(&node.children[0]);
        let param_node = &node.children[1];
        let params = if param_node.name == "Void" {
            vec![]
        } else if param_node.kind == "TypeNominal" && param_node.name == "Tuple" {
            param_node.children.iter().map(map_swift_type).collect()
        } else {
            vec![map_swift_type(param_node)]
        };

        TypeRef {
            nullable: false,
            kind: TypeRefKind::Block {
                params,
                return_type: Box::new(return_type),
            },
        }
    } else {
        TypeRef {
            nullable: false,
            kind: TypeRefKind::Primitive {
                name: node.printed_name.clone(),
            },
        }
    }
}

/// Map Swift primitive type names to IR [`TypeRef`] values.
fn map_swift_primitive(name: &str) -> Option<TypeRef> {
    let prim = |s: &str| {
        Some(TypeRef {
            nullable: false,
            kind: TypeRefKind::Primitive {
                name: s.to_string(),
            },
        })
    };

    match name {
        "Bool" => prim("bool"),
        "Int" => prim("int64"),
        "UInt" => prim("uint64"),
        "Int8" => prim("int8"),
        "Int16" => prim("int16"),
        "Int32" => prim("int32"),
        "Int64" => prim("int64"),
        "UInt8" => prim("uint8"),
        "UInt16" => prim("uint16"),
        "UInt32" => prim("uint32"),
        "UInt64" => prim("uint64"),
        "Float" => prim("float"),
        "Double" => prim("double"),
        "Float32" => prim("float"),
        "Float64" => prim("double"),
        _ => None,
    }
}

/// Map well-known Swift types that bridge to Foundation ObjC classes.
fn map_foundation_bridged_type(swift_name: &str) -> Option<&'static str> {
    match swift_name {
        "String" => Some("NSString"),
        "Data" => Some("NSData"),
        "Date" => Some("NSDate"),
        "URL" => Some("NSURL"),
        "UUID" => Some("NSUUID"),
        "IndexSet" => Some("NSIndexSet"),
        "Locale" => Some("NSLocale"),
        "TimeZone" => Some("NSTimeZone"),
        "Calendar" => Some("NSCalendar"),
        "DateInterval" => Some("NSDateInterval"),
        "Decimal" => Some("NSDecimalNumber"),
        "Measurement" => Some("NSMeasurement"),
        "URLRequest" => Some("NSURLRequest"),
        "URLComponents" => Some("NSURLComponents"),
        "CharacterSet" => Some("NSCharacterSet"),
        "Notification" => Some("NSNotification"),
        _ => None,
    }
}

/// The closed set of nine POD/geometry C struct names every target must
/// recognise identically (ADR-0055 §5a; `pod-struct-types-k73`).
fn is_pod_struct_name(name: &str) -> bool {
    matches!(
        name,
        "NSRect"
            | "CGRect"
            | "NSPoint"
            | "CGPoint"
            | "NSSize"
            | "CGSize"
            | "NSRange"
            | "NSEdgeInsets"
            | "NSDirectionalEdgeInsets"
            | "NSAffineTransformStruct"
            | "CGAffineTransform"
            | "CGVector"
    )
}

/// Extract framework name from a printed name like `"Foundation.URL"` → `Some("Foundation")`.
fn framework_from_printed_name(printed_name: &str) -> Option<String> {
    if let Some(dot_idx) = printed_name.find('.') {
        let prefix = &printed_name[..dot_idx];
        // Only treat it as a framework if the prefix starts with uppercase
        if prefix.starts_with(|c: char| c.is_ascii_uppercase()) {
            return Some(prefix.to_string());
        }
    }
    None
}

#[cfg(test)]
mod tests {
    use super::*;

    fn nominal(name: &str, usr: &str, printed: &str, children: Vec<AbiNode>) -> AbiNode {
        AbiNode {
            kind: "TypeNominal".to_string(),
            name: name.to_string(),
            printed_name: printed.to_string(),
            usr: Some(usr.to_string()),
            children,
            ..default_node()
        }
    }

    fn default_node() -> AbiNode {
        AbiNode {
            kind: String::new(),
            name: String::new(),
            printed_name: String::new(),
            children: vec![],
            decl_kind: None,
            usr: None,
            mangled_name: None,
            module_name: None,
            intro_macos: None,
            intro_ios: None,
            intro_tvos: None,
            intro_watchos: None,
            intro_swift: None,
            decl_attributes: vec![],
            superclass_usr: None,
            superclass_names: vec![],
            conformances: vec![],
            generic_sig: None,
            is_static: false,
            func_self_kind: None,
            throwing: false,
            is_async: false,
            init_kind: None,
            protocol_req: false,
            accessors: vec![],
            accessor_kind: None,
            is_let: false,
            has_storage: false,
            is_from_extension: false,
            req_new_witness_table_entry: false,
            enum_raw_type_name: None,
            is_enum_exhaustive: false,
            overriding: false,
            implicit: false,
            has_default_arg: false,
            param_value_ownership: None,
            type_attributes: vec![],
        }
    }

    #[test]
    fn map_void() {
        let node = nominal("Void", "", "()", vec![]);
        let result = map_swift_type(&node);
        assert!(!result.nullable);
        assert!(matches!(result.kind, TypeRefKind::Primitive { ref name } if name == "void"));
    }

    #[test]
    fn map_swift_bool() {
        let node = nominal("Bool", "s:Sb", "Swift.Bool", vec![]);
        let result = map_swift_type(&node);
        assert!(matches!(result.kind, TypeRefKind::Primitive { ref name } if name == "bool"));
    }

    #[test]
    fn map_swift_int() {
        let node = nominal("Int", "s:Si", "Swift.Int", vec![]);
        let result = map_swift_type(&node);
        assert!(matches!(result.kind, TypeRefKind::Primitive { ref name } if name == "int64"));
    }

    #[test]
    fn map_optional_string() {
        let inner = nominal("String", "s:SS", "Swift.String", vec![]);
        let node = nominal("Optional", "s:Sq", "Swift.String?", vec![inner]);
        let result = map_swift_type(&node);
        assert!(result.nullable, "Optional should be nullable");
        // String bridges to NSString
        assert!(matches!(result.kind, TypeRefKind::Class { ref name, .. } if name == "NSString"));
    }

    #[test]
    fn map_objc_bridged_class() {
        let node = nominal(
            "UndoManager",
            "c:objc(cs)NSUndoManager",
            "Foundation.UndoManager",
            vec![],
        );
        let result = map_swift_type(&node);
        assert!(
            matches!(result.kind, TypeRefKind::Class { ref name, .. } if name == "NSUndoManager")
        );
    }

    #[test]
    fn map_array_type() {
        let elem = nominal("String", "s:SS", "Swift.String", vec![]);
        let node = nominal("Array", "s:Sa", "[Swift.String]", vec![elem]);
        let result = map_swift_type(&node);
        match &result.kind {
            TypeRefKind::Class { name, params, .. } => {
                assert_eq!(name, "NSArray");
                assert_eq!(params.len(), 1);
            }
            other => panic!("expected Class, got {other:?}"),
        }
    }

    #[test]
    fn map_pod_geometry_struct_lowers_to_struct_not_class() {
        // CGRect crosses the .swiftinterface digester with no ObjC-class USR —
        // the same shape a genuine Swift-native class arrives with — so it must
        // be recognised by name, not by USR prefix
        // (swift-interface-nominal-lowering-k77).
        let node = nominal("CGRect", "", "CoreGraphics.CGRect", vec![]);
        let result = map_swift_type(&node);
        assert!(
            matches!(result.kind, TypeRefKind::Struct { ref name } if name == "CGRect"),
            "CGRect should lower to Struct, not Class, got {:?}",
            result.kind
        );
    }

    #[test]
    fn map_generic_type_param() {
        let node = nominal("GenericTypeParam", "", "Subject", vec![]);
        let result = map_swift_type(&node);
        assert!(matches!(result.kind, TypeRefKind::Id { .. }));
    }

    fn type_name_alias(name: &str, printed: &str, children: Vec<AbiNode>) -> AbiNode {
        AbiNode {
            kind: "TypeNameAlias".to_string(),
            name: name.to_string(),
            printed_name: printed.to_string(),
            children,
            ..default_node()
        }
    }

    #[test]
    fn map_type_name_alias_resolves_to_underlying_type() {
        // CFStringEncoding is a typedef for UInt32 — should resolve to uint32, not Primitive("CoreFoundation.CFStringEncoding")
        let underlying = nominal("UInt32", "s:s6UInt32V", "Swift.UInt32", vec![]);
        let node = type_name_alias(
            "CFStringEncoding",
            "CoreFoundation.CFStringEncoding",
            vec![underlying],
        );
        let result = map_swift_type(&node);
        assert!(
            matches!(result.kind, TypeRefKind::Primitive { ref name } if name == "uint32"),
            "CFStringEncoding should resolve to uint32 via underlying UInt32, got {:?}",
            result.kind
        );
    }

    #[test]
    fn map_type_name_alias_resolves_void() {
        // TypeNameAlias for Void should resolve to void, not Primitive("Swift.Void")
        let underlying = nominal("Void", "", "()", vec![]);
        let node = type_name_alias("Void", "Swift.Void", vec![underlying]);
        let result = map_swift_type(&node);
        assert!(
            matches!(result.kind, TypeRefKind::Primitive { ref name } if name == "void"),
            "TypeNameAlias(Void) should resolve to void, got {:?}",
            result.kind
        );
    }

    #[test]
    fn map_type_name_alias_resolves_class() {
        // A typedef alias to a class type should resolve to the class
        let underlying = nominal(
            "NSObject",
            "c:objc(cs)NSObject",
            "ObjectiveC.NSObject",
            vec![],
        );
        let node = type_name_alias("SomeAlias", "Framework.SomeAlias", vec![underlying]);
        let result = map_swift_type(&node);
        assert!(
            matches!(result.kind, TypeRefKind::Class { ref name, .. } if name == "NSObject"),
            "TypeNameAlias to class should resolve to the class, got {:?}",
            result.kind
        );
    }

    #[test]
    fn map_type_name_alias_no_children_falls_back() {
        // Edge case: TypeNameAlias with no children uses printed_name as Primitive
        let node = type_name_alias("Unknown", "SomeModule.Unknown", vec![]);
        let result = map_swift_type(&node);
        assert!(
            matches!(result.kind, TypeRefKind::Primitive { ref name } if name == "SomeModule.Unknown"),
            "TypeNameAlias with no children should fall back to Primitive, got {:?}",
            result.kind
        );
    }

    #[test]
    fn map_closure_type() {
        let ret = nominal("Void", "", "()", vec![]);
        let param = nominal("Void", "", "()", vec![]);
        let node = AbiNode {
            kind: "TypeFunc".to_string(),
            name: "Function".to_string(),
            printed_name: "() -> ()".to_string(),
            children: vec![ret, param],
            ..default_node()
        };
        let result = map_swift_type(&node);
        match &result.kind {
            TypeRefKind::Block { params, .. } => {
                assert!(params.is_empty(), "void param → empty params");
            }
            other => panic!("expected Block, got {other:?}"),
        }
    }
}
