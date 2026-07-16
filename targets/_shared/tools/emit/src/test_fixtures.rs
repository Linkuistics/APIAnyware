//! Shared test fixtures for emitter snapshot tests.
//!
//! Provides a deterministic synthetic framework that exercises all major
//! emitter code paths: constructors, instance/class methods, properties,
//! protocols, enums, constants, block parameters, and dispatch strategies.
//!
//! The fixtures are intentionally small (5 classes, 2 protocols, 1 enum, 2
//! constants) to keep golden files reviewable while covering all generation
//! branches.

use apianyware_types::enrichment::{ClassSelectorEntry, EnrichmentData};
use apianyware_types::ir::{
    Class, Constant, Enum, EnumValue, Framework, Function, Method, Param, Property, Protocol,
};
use apianyware_types::type_ref::{TypeRef, TypeRefKind};

/// Build a deterministic synthetic framework for snapshot testing.
///
/// The framework name is `"TestKit"` and contains:
/// - `TKObject` — root class with init, dealloc, description
/// - `TKView` — subclass with properties, class methods, and a block-param method
/// - `TKButton` — subclass of TKView with an action method
/// - `TKManager` — class with a class method (factory) and an error-out-style method
/// - `TKHelper` — class with only static methods (no constructors)
/// - `TKCopying` protocol — required `copyWithZone:` method
/// - `TKDelegate` protocol — optional callbacks with void/bool/id return types
/// - `TKAlignment` enum — 3 values
/// - 3 constants: `TKVersionString`, `TKDefaultTimeout`, `TKStatusAttribute` (CFSTR macro)
/// - 6 C functions: `TKComputeDistance`, `TKTransformPoint`, `TKReset`, `TKCreateBuffer`,
///   `TKGetName` (CString return), `TKRegisterCallback` (function pointer param)
///   (plus 1 variadic and 1 inline function to test filtering)
pub fn build_snapshot_test_framework() -> Framework {
    Framework {
        format_version: "1.0".to_string(),
        checkpoint: "resolved".to_string(),
        name: "TestKit".to_string(),
        sdk_version: Some("15.4".to_string()),
        collected_at: Some("2026-01-01T00:00:00Z".to_string()),
        depends_on: vec![],
        skipped_symbols: vec![],
        classes: vec![
            build_tkobject(),
            build_tkview(),
            build_tkbutton(),
            build_tkmanager(),
            build_tkhelper(),
        ],
        protocols: vec![build_tkcopying_protocol(), build_tkdelegate_protocol()],
        enums: vec![build_tkalignment_enum()],
        structs: vec![],
        functions: vec![
            build_tk_compute_distance(),
            build_tk_transform_point(),
            build_tk_reset(),
            build_tk_create_buffer(),
            build_tk_get_name(),
            build_tk_register_callback(),
            build_tk_log_variadic(),
            build_tk_fast_hash_inline(),
        ],
        constants: vec![
            build_version_constant(),
            build_timeout_constant(),
            build_cfstr_constant(),
        ],
        class_annotations: vec![],
        patterns: vec![],
        // Enrichment carries the analysis-stage `convenience_error_methods`
        // relation (`ErrorPattern::ErrorOutParam`): `TKManager loadResource:error:`
        // is the local witness for NSError out-param native routing (leaf 050/040)
        // — its wrapper drops the trailing `error` param and returns
        // `(values result error)`. The racket emitter consumes this; chez ignores
        // `fw.enrichment` entirely, so this leaves the chez goldens untouched.
        enrichment: Some(EnrichmentData {
            convenience_error_methods: vec![ClassSelectorEntry {
                class: "TKManager".to_string(),
                selector: "loadResource:error:".to_string(),
            }],
            ..Default::default()
        }),
        verification: None,
    }
}

// ---------------------------------------------------------------------------
// Type helpers
// ---------------------------------------------------------------------------

fn type_id() -> TypeRef {
    TypeRef {
        nullable: false,
        kind: TypeRefKind::Id {
            protocols: Vec::new(),
        },
    }
}

fn type_id_nullable() -> TypeRef {
    TypeRef {
        nullable: true,
        kind: TypeRefKind::Id {
            protocols: Vec::new(),
        },
    }
}

fn type_instancetype() -> TypeRef {
    TypeRef {
        nullable: false,
        kind: TypeRefKind::Instancetype,
    }
}

fn type_void() -> TypeRef {
    TypeRef {
        nullable: false,
        kind: TypeRefKind::Primitive {
            name: "void".to_string(),
        },
    }
}

fn type_bool() -> TypeRef {
    TypeRef {
        nullable: false,
        kind: TypeRefKind::Primitive {
            name: "BOOL".to_string(),
        },
    }
}

fn type_int() -> TypeRef {
    TypeRef {
        nullable: false,
        kind: TypeRefKind::Primitive {
            name: "int64".to_string(),
        },
    }
}

fn type_double() -> TypeRef {
    TypeRef {
        nullable: false,
        kind: TypeRefKind::Primitive {
            name: "double".to_string(),
        },
    }
}

fn type_class(name: &str) -> TypeRef {
    TypeRef {
        nullable: false,
        kind: TypeRefKind::Class {
            name: name.to_string(),
            framework: None,
            params: vec![],
        },
    }
}

fn type_class_nullable(name: &str) -> TypeRef {
    TypeRef {
        nullable: true,
        kind: TypeRefKind::Class {
            name: name.to_string(),
            framework: None,
            params: vec![],
        },
    }
}

/// A geometry struct passed/returned by value (e.g. `NSRect`). libclang
/// classifies these typedefs as aliases, so the FFI mapper recognises them via
/// `TypeRefKind::Alias` → `_NSRect` (see `ffi_type_mapping`). Exercises the
/// struct-by-value native dispatch path (leaf 050/020).
fn type_struct(name: &str) -> TypeRef {
    TypeRef {
        nullable: false,
        kind: TypeRefKind::Alias {
            name: name.to_string(),
            framework: None,
            underlying_primitive: None,
        },
    }
}

fn type_pointer() -> TypeRef {
    TypeRef {
        nullable: false,
        kind: TypeRefKind::Pointer,
    }
}

fn type_selector() -> TypeRef {
    TypeRef {
        nullable: false,
        kind: TypeRefKind::Selector,
    }
}

fn type_block(params: Vec<TypeRef>, return_type: TypeRef) -> TypeRef {
    TypeRef {
        nullable: false,
        kind: TypeRefKind::Block {
            params,
            return_type: Box::new(return_type),
        },
    }
}

// ---------------------------------------------------------------------------
// Method helper
// ---------------------------------------------------------------------------

fn method(
    selector: &str,
    class_method: bool,
    init_method: bool,
    params: Vec<Param>,
    return_type: TypeRef,
) -> Method {
    Method {
        selector: selector.to_string(),
        class_method,
        init_method,
        params,
        return_type,
        deprecated: false,
        variadic: false,
        source: None,
        provenance: None,
        doc_refs: None,
        origin: None,
        category: None,
        overrides: None,
        returns_retained: None,
        satisfies_protocol: None,
        objc_exposed: true,
        swift_fn: None,
    }
}

fn param(name: &str, param_type: TypeRef) -> Param {
    Param {
        name: name.to_string(),
        param_type,
    }
}

fn property(name: &str, property_type: TypeRef, readonly: bool) -> Property {
    Property {
        name: name.to_string(),
        property_type,
        readonly,
        class_property: false,
        ownership: None,
        deprecated: false,
        source: None,
        provenance: None,
        doc_refs: None,
        origin: None,
        objc_exposed: true,
    }
}

// ---------------------------------------------------------------------------
// Classes
// ---------------------------------------------------------------------------

/// Root class: `TKObject` with init, dealloc, description.
fn build_tkobject() -> Class {
    Class {
        name: "TKObject".to_string(),
        superclass: String::new(),
        protocols: vec![],
        properties: vec![],
        methods: vec![
            method("init", false, true, vec![], type_instancetype()),
            method("dealloc", false, false, vec![], type_void()),
            method("description", false, false, vec![], type_class("NSString")),
        ],
        category_methods: vec![],
        swift_attributes: vec![],
        ancestors: vec![],
        all_methods: vec![],
        all_properties: vec![],
        objc_exposed: true,
        swift_name: None,
    }
}

/// `TKView` — subclass with properties and a block-param method.
fn build_tkview() -> Class {
    Class {
        name: "TKView".to_string(),
        superclass: "TKObject".to_string(),
        protocols: vec![],
        properties: vec![
            property("title", type_class_nullable("NSString"), false),
            property("hidden", type_bool(), false),
            property("tag", type_int(), false),
            property("frame", type_struct("NSRect"), false),
        ],
        methods: vec![
            method("init", false, true, vec![], type_instancetype()),
            method(
                "initWithFrame:",
                false,
                true,
                vec![param("frame", type_struct("NSRect"))],
                type_instancetype(),
            ),
            // Instance method returning void — should use `tell` dispatch
            method("setNeedsDisplay", false, false, vec![], type_void()),
            // Method with block parameter — exercises block bridging path
            method(
                "animateWithDuration:animations:",
                false,
                false,
                vec![
                    param("duration", type_double()),
                    param("animations", type_block(vec![], type_void())),
                ],
                type_void(),
            ),
            // Class method — exercises class method dispatch
            method("appearance", true, false, vec![], type_id()),
        ],
        category_methods: vec![],
        swift_attributes: vec![],
        ancestors: vec!["TKObject".to_string()],
        all_methods: vec![
            // Inherited from TKObject
            method("dealloc", false, false, vec![], type_void()),
            method("description", false, false, vec![], type_class("NSString")),
        ],
        all_properties: vec![],
        objc_exposed: true,
        swift_name: None,
    }
}

/// `TKButton` — subclass with target-action pattern method.
fn build_tkbutton() -> Class {
    Class {
        name: "TKButton".to_string(),
        superclass: "TKView".to_string(),
        protocols: vec![],
        properties: vec![
            property("label", type_class("NSString"), false),
            property("enabled", type_bool(), false),
        ],
        methods: vec![
            method("init", false, true, vec![], type_instancetype()),
            // Target-action: object + selector params — exercises typed msgSend
            method(
                "setTarget:action:",
                false,
                false,
                vec![
                    param("target", type_id_nullable()),
                    param("action", type_selector()),
                ],
                type_void(),
            ),
            // Method returning BOOL — exercises non-void typed msgSend
            method("isHighlighted", false, false, vec![], type_bool()),
        ],
        category_methods: vec![],
        swift_attributes: vec![],
        ancestors: vec!["TKView".to_string(), "TKObject".to_string()],
        all_methods: vec![
            method("dealloc", false, false, vec![], type_void()),
            method("description", false, false, vec![], type_class("NSString")),
            method("setNeedsDisplay", false, false, vec![], type_void()),
            method(
                "animateWithDuration:animations:",
                false,
                false,
                vec![
                    param("duration", type_double()),
                    param("animations", type_block(vec![], type_void())),
                ],
                type_void(),
            ),
        ],
        all_properties: vec![
            property("title", type_class_nullable("NSString"), false),
            property("hidden", type_bool(), false),
            property("tag", type_int(), false),
            property("frame", type_struct("NSRect"), false),
        ],
        objc_exposed: true,
        swift_name: None,
    }
}

/// `TKManager` — factory + error-out pattern.
fn build_tkmanager() -> Class {
    Class {
        name: "TKManager".to_string(),
        superclass: "TKObject".to_string(),
        protocols: vec![],
        properties: vec![],
        methods: vec![
            // Class factory method — exercises class method + instancetype
            method("sharedManager", true, false, vec![], type_instancetype()),
            // Method with pointer param (error out-param pattern)
            method(
                "loadResource:error:",
                false,
                false,
                vec![
                    param("name", type_class("NSString")),
                    param("error", type_pointer()),
                ],
                type_bool(),
            ),
            // Method returning nullable object
            method(
                "resourceNamed:",
                false,
                false,
                vec![param("name", type_class("NSString"))],
                type_class_nullable("TKObject"),
            ),
        ],
        category_methods: vec![],
        swift_attributes: vec![],
        ancestors: vec!["TKObject".to_string()],
        all_methods: vec![
            method("init", false, true, vec![], type_instancetype()),
            method("dealloc", false, false, vec![], type_void()),
            method("description", false, false, vec![], type_class("NSString")),
            // The NSError out-param witness (leaf 050/040). Mirrors the `methods`
            // entry; present in `all_methods` so it survives `effective_methods`
            // (which prefers the flattened set when non-empty) and is emitted.
            method(
                "loadResource:error:",
                false,
                false,
                vec![
                    param("name", type_class("NSString")),
                    param("error", type_pointer()),
                ],
                type_bool(),
            ),
        ],
        all_properties: vec![],
        objc_exposed: true,
        swift_name: None,
    }
}

/// `TKHelper` — only class methods, no constructors.
fn build_tkhelper() -> Class {
    Class {
        name: "TKHelper".to_string(),
        superclass: "TKObject".to_string(),
        protocols: vec![],
        properties: vec![],
        methods: vec![
            method("versionString", true, false, vec![], type_class("NSString")),
            method("maximumCount", true, false, vec![], type_int()),
        ],
        category_methods: vec![],
        swift_attributes: vec![],
        ancestors: vec!["TKObject".to_string()],
        all_methods: vec![
            method("init", false, true, vec![], type_instancetype()),
            method("dealloc", false, false, vec![], type_void()),
            method("description", false, false, vec![], type_class("NSString")),
        ],
        all_properties: vec![],
        objc_exposed: true,
        swift_name: None,
    }
}

// ---------------------------------------------------------------------------
// Functions
// ---------------------------------------------------------------------------

/// `TKComputeDistance` — simple function: (double, double) -> double.
fn build_tk_compute_distance() -> Function {
    Function {
        name: "TKComputeDistance".to_string(),
        params: vec![param("x", type_double()), param("y", type_double())],
        return_type: type_double(),
        inline: false,
        variadic: false,
        source: None,
        provenance: None,
        doc_refs: None,
        objc_exposed: true,
        swift_fn: None,
    }
}

/// `TKTransformPoint` — function with struct param and return: (NSPoint) -> NSPoint.
fn build_tk_transform_point() -> Function {
    Function {
        name: "TKTransformPoint".to_string(),
        params: vec![param(
            "point",
            TypeRef {
                nullable: false,
                kind: TypeRefKind::Alias {
                    name: "NSPoint".to_string(),
                    framework: None,
                    underlying_primitive: None,
                },
            },
        )],
        return_type: TypeRef {
            nullable: false,
            kind: TypeRefKind::Alias {
                name: "NSPoint".to_string(),
                framework: None,
                underlying_primitive: None,
            },
        },
        inline: false,
        variadic: false,
        source: None,
        provenance: None,
        doc_refs: None,
        objc_exposed: true,
        swift_fn: None,
    }
}

/// `TKReset` — void-returning function with no params: () -> void.
fn build_tk_reset() -> Function {
    Function {
        name: "TKReset".to_string(),
        params: vec![],
        return_type: type_void(),
        inline: false,
        variadic: false,
        source: None,
        provenance: None,
        doc_refs: None,
        objc_exposed: true,
        swift_fn: None,
    }
}

/// `TKCreateBuffer` — function returning a pointer with object param: (NSString, uint32) -> pointer.
fn build_tk_create_buffer() -> Function {
    Function {
        name: "TKCreateBuffer".to_string(),
        params: vec![
            param("name", type_class("NSString")),
            param(
                "size",
                TypeRef {
                    nullable: false,
                    kind: TypeRefKind::Primitive {
                        name: "uint32".to_string(),
                    },
                },
            ),
        ],
        return_type: type_pointer(),
        inline: false,
        variadic: false,
        source: None,
        provenance: None,
        doc_refs: None,
        objc_exposed: true,
        swift_fn: None,
    }
}

/// `TKGetName` — function returning `const char *` (CString). Exercises
/// nullable return contract: `_string` maps NULL to `#f`, contract must accept it.
fn build_tk_get_name() -> Function {
    Function {
        name: "TKGetName".to_string(),
        params: vec![param(
            "id",
            TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "uint32".to_string(),
                },
            },
        )],
        return_type: TypeRef {
            nullable: false,
            kind: TypeRefKind::CString,
        },
        inline: false,
        variadic: false,
        source: None,
        provenance: None,
        doc_refs: None,
        objc_exposed: true,
        swift_fn: None,
    }
}

/// `TKRegisterCallback` — function with a C callback parameter.
/// Exercises foreign-thread safety warning emission.
fn build_tk_register_callback() -> Function {
    Function {
        name: "TKRegisterCallback".to_string(),
        params: vec![
            param("context", type_pointer()),
            Param {
                name: "callback".to_string(),
                param_type: TypeRef {
                    nullable: false,
                    kind: TypeRefKind::FunctionPointer {
                        name: Some("TKCallbackFunc".to_string()),
                        params: vec![
                            type_pointer(),
                            TypeRef {
                                nullable: false,
                                kind: TypeRefKind::Primitive {
                                    name: "int32".to_string(),
                                },
                            },
                        ],
                        return_type: Box::new(type_void()),
                    },
                },
            },
        ],
        return_type: type_void(),
        inline: false,
        variadic: false,
        source: None,
        provenance: None,
        doc_refs: None,
        objc_exposed: true,
        swift_fn: None,
    }
}

/// `TKLog` — variadic function (should be skipped by emitter).
fn build_tk_log_variadic() -> Function {
    Function {
        name: "TKLog".to_string(),
        params: vec![param("format", type_class("NSString"))],
        return_type: type_void(),
        inline: false,
        variadic: true,
        source: None,
        provenance: None,
        doc_refs: None,
        objc_exposed: true,
        swift_fn: None,
    }
}

/// `TKFastHash` — inline function (should be skipped by emitter).
fn build_tk_fast_hash_inline() -> Function {
    Function {
        name: "TKFastHash".to_string(),
        params: vec![param("data", type_pointer())],
        return_type: TypeRef {
            nullable: false,
            kind: TypeRefKind::Primitive {
                name: "uint64".to_string(),
            },
        },
        inline: true,
        variadic: false,
        source: None,
        provenance: None,
        doc_refs: None,
        objc_exposed: true,
        swift_fn: None,
    }
}

// ---------------------------------------------------------------------------
// Protocols
// ---------------------------------------------------------------------------

/// `TKCopying` — single required method returning id.
fn build_tkcopying_protocol() -> Protocol {
    Protocol {
        name: "TKCopying".to_string(),
        inherits: vec![],
        required_methods: vec![method(
            "copyWithZone:",
            false,
            false,
            vec![param("zone", type_pointer())],
            type_id(),
        )],
        optional_methods: vec![],
        properties: vec![],
        source: None,
        provenance: None,
        doc_refs: None,
        objc_exposed: true,
    }
}

/// `TKDelegate` — optional callbacks with diverse return types (void/bool/id).
fn build_tkdelegate_protocol() -> Protocol {
    Protocol {
        name: "TKDelegate".to_string(),
        inherits: vec![],
        required_methods: vec![],
        optional_methods: vec![
            method(
                "managerDidFinish:",
                false,
                false,
                vec![param("manager", type_class("TKManager"))],
                type_void(),
            ),
            method(
                "managerShouldContinue:",
                false,
                false,
                vec![param("manager", type_class("TKManager"))],
                type_bool(),
            ),
            method(
                "managerWillReturnResult:",
                false,
                false,
                vec![param("manager", type_class("TKManager"))],
                type_id(),
            ),
        ],
        properties: vec![],
        source: None,
        provenance: None,
        doc_refs: None,
        objc_exposed: true,
    }
}

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

fn build_tkalignment_enum() -> Enum {
    Enum {
        name: "TKAlignment".to_string(),
        enum_type: TypeRef {
            nullable: false,
            kind: TypeRefKind::Primitive {
                name: "NSInteger".to_string(),
            },
        },
        values: vec![
            EnumValue {
                name: "TKAlignmentLeft".to_string(),
                value: 0,
            },
            EnumValue {
                name: "TKAlignmentCenter".to_string(),
                value: 1,
            },
            EnumValue {
                name: "TKAlignmentRight".to_string(),
                value: 2,
            },
        ],
        source: None,
        provenance: None,
        doc_refs: None,
        objc_exposed: true,
    }
}

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

fn build_version_constant() -> Constant {
    Constant {
        name: "TKVersionString".to_string(),
        constant_type: type_class("NSString"),
        array_element: None,
        source: None,
        provenance: None,
        doc_refs: None,
        macro_value: None,
        objc_exposed: true,
    }
}

fn build_timeout_constant() -> Constant {
    Constant {
        name: "TKDefaultTimeout".to_string(),
        constant_type: type_double(),
        array_element: None,
        source: None,
        provenance: None,
        doc_refs: None,
        macro_value: None,
        objc_exposed: true,
    }
}

fn build_cfstr_constant() -> Constant {
    Constant {
        name: "TKStatusAttribute".to_string(),
        constant_type: TypeRef {
            nullable: true,
            kind: TypeRefKind::Id {
                protocols: Vec::new(),
            },
        },
        array_element: None,
        source: None,
        provenance: None,
        doc_refs: None,
        macro_value: Some("TKStatus".to_string()),
        objc_exposed: true,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_snapshot_framework_is_deterministic() {
        let fw1 = build_snapshot_test_framework();
        let fw2 = build_snapshot_test_framework();

        let json1 = serde_json::to_string_pretty(&fw1).unwrap();
        let json2 = serde_json::to_string_pretty(&fw2).unwrap();
        assert_eq!(json1, json2, "Framework builder must be deterministic");
    }

    #[test]
    fn test_snapshot_framework_structure() {
        let fw = build_snapshot_test_framework();
        assert_eq!(fw.name, "TestKit");
        assert_eq!(fw.classes.len(), 5);
        assert_eq!(fw.protocols.len(), 2);
        assert_eq!(fw.enums.len(), 1);
        assert_eq!(fw.functions.len(), 8);
        assert_eq!(fw.constants.len(), 3);
    }

    #[test]
    fn test_snapshot_framework_class_names() {
        let fw = build_snapshot_test_framework();
        let names: Vec<&str> = fw.classes.iter().map(|c| c.name.as_str()).collect();
        assert_eq!(
            names,
            vec!["TKObject", "TKView", "TKButton", "TKManager", "TKHelper"]
        );
    }

    #[test]
    fn test_snapshot_framework_has_block_param_method() {
        let fw = build_snapshot_test_framework();
        let tkview = &fw.classes[1];
        let block_method = tkview
            .methods
            .iter()
            .find(|m| m.selector == "animateWithDuration:animations:")
            .expect("TKView should have animateWithDuration:animations:");
        assert_eq!(block_method.params.len(), 2);
        matches!(
            block_method.params[1].param_type.kind,
            TypeRefKind::Block { .. }
        );
    }

    #[test]
    fn test_snapshot_framework_has_inherited_methods() {
        let fw = build_snapshot_test_framework();
        let tkbutton = &fw.classes[2];
        assert!(
            !tkbutton.all_methods.is_empty(),
            "TKButton should have inherited methods"
        );
        assert!(
            !tkbutton.all_properties.is_empty(),
            "TKButton should have inherited properties"
        );
    }
}
