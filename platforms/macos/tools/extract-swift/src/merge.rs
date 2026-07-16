//! Merge ObjC and Swift declarations into a single IR framework.
//!
//! When a framework has both ObjC headers (extracted by libclang) and a Swift
//! module (extracted by swift-api-digester), this module merges them into a
//! single [`ir::Framework`]. Swift extensions on ObjC classes add methods and
//! properties with `source: SwiftInterface` to the existing ObjC class.

use std::collections::HashMap;

use apianyware_types::ir;
use apianyware_types::type_ref::{TypeRef, TypeRefKind};

/// Merge Swift-extracted declarations into an ObjC-extracted framework.
///
/// - Swift classes that match an existing ObjC class by name: their Swift
///   methods and properties are appended to the ObjC class.
/// - Swift-only classes (no ObjC counterpart): added as new classes.
/// - Swift protocols, enums, structs, functions, constants that don't exist
///   in ObjC: added to the framework.
/// - Duplicate declarations (same name in both): ObjC version is kept,
///   Swift version is skipped (ObjC is the canonical source for bridged types).
///
/// The merged framework preserves the ObjC `collected_at` timestamp and
/// SDK version.
pub fn merge_swift_into_objc(objc: &mut ir::Framework, swift: ir::Framework) {
    // Index ObjC classes by name for fast lookup (owned strings to avoid borrow issues)
    let objc_class_index: HashMap<String, usize> = objc
        .classes
        .iter()
        .enumerate()
        .map(|(i, c)| (c.name.clone(), i))
        .collect();

    // Partition Swift classes into those that merge and those that are new
    let (to_merge, to_add): (Vec<_>, Vec<_>) = swift
        .classes
        .into_iter()
        .partition(|sc| objc_class_index.contains_key(&sc.name));

    for swift_class in to_merge {
        let idx = objc_class_index[&swift_class.name];
        merge_class_members(&mut objc.classes[idx], swift_class);
    }
    objc.classes.extend(to_add);

    // Helper: extend vec with items whose name is not already present
    fn extend_if_absent<T>(existing: &mut Vec<T>, new_items: Vec<T>, name_of: impl Fn(&T) -> &str) {
        let existing_names: std::collections::HashSet<String> = existing
            .iter()
            .map(|item| name_of(item).to_string())
            .collect();
        for item in new_items {
            if !existing_names.contains(name_of(&item)) {
                existing.push(item);
            }
        }
    }

    extend_if_absent(&mut objc.protocols, swift.protocols, |p| &p.name);
    extend_if_absent(&mut objc.enums, swift.enums, |e| &e.name);
    extend_if_absent(&mut objc.structs, swift.structs, |s| &s.name);
    extend_if_absent(&mut objc.functions, swift.functions, |f| &f.name);
    extend_if_absent(&mut objc.constants, swift.constants, |c| &c.name);

    // Carry Swift-side skipped_symbols forward. Both pipelines (extract-objc
    // and extract-swift) record their own filter decisions here; preserving
    // both makes the checkpoint the single place to audit what was dropped
    // and why.
    objc.skipped_symbols.extend(swift.skipped_symbols);

    // Merge imports
    let existing_deps: std::collections::HashSet<String> =
        objc.depends_on.iter().cloned().collect();
    for dep in swift.depends_on {
        if !existing_deps.contains(&dep) {
            objc.depends_on.push(dep);
        }
    }

    normalize_swift_native_enum_refs(objc);
}

/// Recover `.swiftinterface`-sourced type references the extractor could not
/// classify at the reference site and defaulted to `Class{…}`
/// (`swift-interface-nominal-lowering-k77`): a reference naming an enum the
/// merge above just proved has a real, ObjC-verified integer width becomes
/// `Alias{name, underlying_primitive}` — the exact shape `extract-objc`
/// already produces for the same enum reached through its ObjC header.
///
/// Must run **after** the enum merge above: a Swift-native enum node alone
/// never carries a real width (`map_enum`'s `swift_enum` sentinel — Swift
/// enums don't expose one in ABIRoot), so only a merged, ObjC-backed entry is
/// trustworthy enough to convert without lying about the ABI. Skips any name
/// that is *also* a declared class in this framework (the enum/class
/// namespaces never collide in practice, but a stray same-named class must
/// win, not be silently reclassified as an enum — the k66/k76/k90 "lossy map
/// used as a key" lesson). Everything else stays `Class{…}` and keeps
/// deferring — this is a targeted recovery, not a general Class-reference
/// solver.
fn normalize_swift_native_enum_refs(framework: &mut ir::Framework) {
    let declared_class_names: std::collections::HashSet<&str> =
        framework.classes.iter().map(|c| c.name.as_str()).collect();
    let enum_widths: HashMap<String, String> = framework
        .enums
        .iter()
        .filter_map(|e| match &e.enum_type.kind {
            TypeRefKind::Primitive { name } if name != "swift_enum" => {
                if declared_class_names.contains(e.name.as_str()) {
                    None
                } else {
                    Some((e.name.clone(), name.clone()))
                }
            }
            _ => None,
        })
        .collect();
    if enum_widths.is_empty() {
        return;
    }

    for class in &mut framework.classes {
        for method in &mut class.methods {
            normalize_method(method, &enum_widths);
        }
        for property in &mut class.properties {
            normalize_type_ref(&mut property.property_type, &enum_widths);
        }
        for category in &mut class.category_methods {
            for method in &mut category.methods {
                normalize_method(method, &enum_widths);
            }
        }
    }
    for protocol in &mut framework.protocols {
        for method in protocol
            .required_methods
            .iter_mut()
            .chain(protocol.optional_methods.iter_mut())
        {
            normalize_method(method, &enum_widths);
        }
        for property in &mut protocol.properties {
            normalize_type_ref(&mut property.property_type, &enum_widths);
        }
    }
    for s in &mut framework.structs {
        for field in &mut s.fields {
            normalize_type_ref(&mut field.field_type, &enum_widths);
        }
        for method in &mut s.methods {
            normalize_method(method, &enum_widths);
        }
    }
    for function in &mut framework.functions {
        for param in &mut function.params {
            normalize_type_ref(&mut param.param_type, &enum_widths);
        }
        normalize_type_ref(&mut function.return_type, &enum_widths);
    }
    for constant in &mut framework.constants {
        normalize_type_ref(&mut constant.constant_type, &enum_widths);
    }
}

fn normalize_method(method: &mut ir::Method, enum_widths: &HashMap<String, String>) {
    for param in &mut method.params {
        normalize_type_ref(&mut param.param_type, enum_widths);
    }
    normalize_type_ref(&mut method.return_type, enum_widths);
}

/// Rewrite `type_ref` in place — and any `TypeRef` it nests (a block's
/// params/return, a function pointer's params/return, a class ref's generic
/// params) — wherever it is a `Class{name}` naming a known-width merged enum.
fn normalize_type_ref(type_ref: &mut TypeRef, enum_widths: &HashMap<String, String>) {
    match &mut type_ref.kind {
        TypeRefKind::Block {
            params,
            return_type,
        } => {
            for p in params.iter_mut() {
                normalize_type_ref(p, enum_widths);
            }
            normalize_type_ref(return_type, enum_widths);
            return;
        }
        TypeRefKind::FunctionPointer {
            params,
            return_type,
            ..
        } => {
            for p in params.iter_mut() {
                normalize_type_ref(p, enum_widths);
            }
            normalize_type_ref(return_type, enum_widths);
            return;
        }
        TypeRefKind::Class { params, .. } => {
            for p in params.iter_mut() {
                normalize_type_ref(p, enum_widths);
            }
        }
        _ => return,
    }

    let TypeRefKind::Class { name, params, .. } = &type_ref.kind else {
        return;
    };
    if !params.is_empty() {
        return;
    }
    if let Some(underlying) = enum_widths.get(name) {
        type_ref.kind = TypeRefKind::Alias {
            name: name.clone(),
            framework: None,
            underlying_primitive: Some(underlying.clone()),
        };
    }
}

/// Merge Swift methods and properties into an existing ObjC class.
///
/// Adds Swift methods that don't have a matching ObjC selector, and Swift
/// properties that don't have a matching ObjC property name.
fn merge_class_members(objc_class: &mut ir::Class, swift_class: ir::Class) {
    // Index existing ObjC method selectors (owned to avoid borrow issues)
    let existing_selectors: std::collections::HashSet<String> = objc_class
        .methods
        .iter()
        .map(|m| m.selector.clone())
        .collect();

    for method in swift_class.methods {
        if !existing_selectors.contains(&method.selector) {
            objc_class.methods.push(method);
        }
    }

    // Merge properties
    let existing_properties: std::collections::HashSet<String> = objc_class
        .properties
        .iter()
        .map(|p| p.name.clone())
        .collect();

    for property in swift_class.properties {
        if !existing_properties.contains(&property.name) {
            objc_class.properties.push(property);
        }
    }

    // Merge protocol conformances discovered by Swift
    let existing_protocols: std::collections::HashSet<String> =
        objc_class.protocols.iter().cloned().collect();

    for protocol in swift_class.protocols {
        if !existing_protocols.contains(&protocol) {
            objc_class.protocols.push(protocol);
        }
    }

    // Merge Swift-side declaration attributes (e.g. `MainActor`) into the
    // ObjC class. ObjC extraction never produces swift_attributes today,
    // but use set-union so future ObjC-side capture (e.g. _SWIFT_UI_ACTOR
    // macro extraction) merges cleanly without duplicates.
    let existing_swift_attrs: std::collections::HashSet<String> =
        objc_class.swift_attributes.iter().cloned().collect();
    for attr in swift_class.swift_attributes {
        if !existing_swift_attrs.contains(&attr) {
            objc_class.swift_attributes.push(attr);
        }
    }

    // Carry the Swift overlay name onto the unified (clang-extracted) class. The clang
    // side never sets `swift_name`; the Swift overlay does, when it renamed the class
    // (`NSScanner` → `Scanner`). The Swift trampoline needs it to spell a compilable
    // Swift type, since the unified class's `name` is the obsoleted ObjC runtime name.
    if objc_class.swift_name.is_none() {
        objc_class.swift_name = swift_class.swift_name;
    }
}

#[cfg(test)]
mod tests {
    use apianyware_types::{
        ir,
        provenance::DeclarationSource,
        type_ref::{TypeRef, TypeRefKind},
    };

    use super::*;

    fn void_type() -> TypeRef {
        TypeRef {
            nullable: false,
            kind: TypeRefKind::Primitive {
                name: "void".to_string(),
            },
        }
    }

    fn make_method(selector: &str, source: DeclarationSource) -> ir::Method {
        ir::Method {
            selector: selector.to_string(),
            class_method: false,
            init_method: false,
            params: vec![],
            return_type: void_type(),
            deprecated: false,
            variadic: false,
            source: Some(source),
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

    fn make_property(name: &str, source: DeclarationSource) -> ir::Property {
        ir::Property {
            name: name.to_string(),
            property_type: void_type(),
            readonly: false,
            class_property: false,
            ownership: None,
            deprecated: false,
            source: Some(source),
            provenance: None,
            doc_refs: None,
            origin: None,
            objc_exposed: true,
        }
    }

    fn empty_framework(name: &str) -> ir::Framework {
        ir::Framework {
            format_version: "1.0".to_string(),
            checkpoint: "extracted".to_string(),
            name: name.to_string(),
            sdk_version: Some("15.4".to_string()),
            collected_at: None,
            depends_on: vec![],
            skipped_symbols: vec![],
            classes: vec![],
            protocols: vec![],
            enums: vec![],
            structs: vec![],
            functions: vec![],
            constants: vec![],
            class_annotations: vec![],
            patterns: vec![],
            enrichment: None,
            verification: None,
        }
    }

    #[test]
    fn merge_swift_methods_into_objc_class() {
        let mut objc = empty_framework("TestKit");
        objc.classes.push(ir::Class {
            name: "MyClass".to_string(),
            superclass: "NSObject".to_string(),
            protocols: vec![],
            properties: vec![],
            methods: vec![make_method("init", DeclarationSource::ObjcHeader)],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        });

        let mut swift = empty_framework("TestKit");
        swift.classes.push(ir::Class {
            name: "MyClass".to_string(),
            superclass: "NSObject".to_string(),
            protocols: vec!["Sendable".to_string()],
            properties: vec![make_property(
                "swiftProp",
                DeclarationSource::SwiftInterface,
            )],
            methods: vec![
                // Duplicate: should NOT be added
                make_method("init", DeclarationSource::SwiftInterface),
                // New: should be added
                make_method("swiftMethod", DeclarationSource::SwiftInterface),
            ],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        });

        merge_swift_into_objc(&mut objc, swift);

        let class = &objc.classes[0];
        assert_eq!(class.methods.len(), 2, "init + swiftMethod");
        assert_eq!(class.methods[0].selector, "init");
        assert_eq!(
            class.methods[0].source,
            Some(DeclarationSource::ObjcHeader),
            "ObjC version preserved"
        );
        assert_eq!(class.methods[1].selector, "swiftMethod");
        assert_eq!(
            class.methods[1].source,
            Some(DeclarationSource::SwiftInterface)
        );
        assert_eq!(class.properties.len(), 1);
        assert_eq!(class.properties[0].name, "swiftProp");
        assert!(class.protocols.contains(&"Sendable".to_string()));
    }

    #[test]
    fn merge_swift_only_class() {
        let mut objc = empty_framework("TestKit");
        let mut swift = empty_framework("TestKit");
        swift.classes.push(ir::Class {
            name: "SwiftOnlyClass".to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods: vec![make_method("doThing", DeclarationSource::SwiftInterface)],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        });

        merge_swift_into_objc(&mut objc, swift);

        assert_eq!(objc.classes.len(), 1);
        assert_eq!(objc.classes[0].name, "SwiftOnlyClass");
    }

    #[test]
    fn merge_swift_only_protocol() {
        let mut objc = empty_framework("TestKit");
        objc.protocols.push(ir::Protocol {
            name: "ExistingProto".to_string(),
            inherits: vec![],
            required_methods: vec![],
            optional_methods: vec![],
            properties: vec![],
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: true,
        });

        let mut swift = empty_framework("TestKit");
        swift.protocols.push(ir::Protocol {
            name: "ExistingProto".to_string(), // Duplicate: skip
            inherits: vec![],
            required_methods: vec![],
            optional_methods: vec![],
            properties: vec![],
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: true,
        });
        swift.protocols.push(ir::Protocol {
            name: "SwiftProto".to_string(), // New: add
            inherits: vec![],
            required_methods: vec![],
            optional_methods: vec![],
            properties: vec![],
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: true,
        });

        merge_swift_into_objc(&mut objc, swift);

        assert_eq!(objc.protocols.len(), 2);
        assert!(objc.protocols.iter().any(|p| p.name == "ExistingProto"));
        assert!(objc.protocols.iter().any(|p| p.name == "SwiftProto"));
    }

    #[test]
    fn merge_carries_forward_skipped_symbols_from_both_sides() {
        let mut objc = empty_framework("TestKit");
        objc.skipped_symbols.push(ir::SkippedSymbol {
            name: "NSInternalStatic".to_string(),
            kind: "constant".to_string(),
            reason: "internal linkage".to_string(),
        });

        let mut swift = empty_framework("TestKit");
        swift.skipped_symbols.push(ir::SkippedSymbol {
            name: "NSLocalizedString".to_string(),
            kind: "function".to_string(),
            reason: "swift-native top-level declaration".to_string(),
        });

        merge_swift_into_objc(&mut objc, swift);

        let names: Vec<&str> = objc
            .skipped_symbols
            .iter()
            .map(|s| s.name.as_str())
            .collect();
        assert_eq!(names, vec!["NSInternalStatic", "NSLocalizedString"]);
    }

    #[test]
    fn merge_dependencies() {
        let mut objc = empty_framework("TestKit");
        objc.depends_on = vec!["Foundation".to_string()];

        let mut swift = empty_framework("TestKit");
        swift.depends_on = vec!["Foundation".to_string(), "Combine".to_string()];

        merge_swift_into_objc(&mut objc, swift);

        assert_eq!(objc.depends_on.len(), 2);
        assert!(objc.depends_on.contains(&"Foundation".to_string()));
        assert!(objc.depends_on.contains(&"Combine".to_string()));
    }

    fn empty_class(name: &str, methods: Vec<ir::Method>) -> ir::Class {
        ir::Class {
            name: name.to_string(),
            superclass: "NSObject".to_string(),
            protocols: vec![],
            properties: vec![],
            methods,
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        }
    }

    fn class_ref_type(name: &str, framework: Option<&str>) -> TypeRef {
        TypeRef {
            nullable: false,
            kind: TypeRefKind::Class {
                name: name.to_string(),
                framework: framework.map(str::to_string),
                params: vec![],
            },
        }
    }

    #[test]
    fn merge_recovers_swift_native_enum_reference_to_alias() {
        // NEProviderStopReason-shaped: extract-objc already resolved the enum
        // itself (real int64 width), but a Swift-native method signature in
        // the same framework still names it via the extractor's `Class{…}`
        // fallback (swift-interface-nominal-lowering-k77).
        let mut objc = empty_framework("NetworkExtension");
        objc.enums.push(ir::Enum {
            name: "NEProviderStopReason".to_string(),
            enum_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "int64".to_string(),
                },
            },
            values: vec![],
            source: Some(DeclarationSource::ObjcHeader),
            provenance: None,
            doc_refs: None,
            objc_exposed: true,
        });
        objc.classes.push(empty_class("NEAppProxyProvider", vec![]));

        let mut swift_method = make_method(
            "stopProxyWithReason:completionHandler:",
            DeclarationSource::SwiftInterface,
        );
        swift_method.params.push(ir::Param {
            name: "with".to_string(),
            param_type: class_ref_type("NEProviderStopReason", Some("NetworkExtension")),
        });
        let mut swift = empty_framework("NetworkExtension");
        swift
            .classes
            .push(empty_class("NEAppProxyProvider", vec![swift_method]));

        merge_swift_into_objc(&mut objc, swift);

        let class = &objc.classes[0];
        let method = class
            .methods
            .iter()
            .find(|m| m.selector == "stopProxyWithReason:completionHandler:")
            .expect("swift-native method merged in");
        match &method.params[0].param_type.kind {
            TypeRefKind::Alias {
                name,
                underlying_primitive,
                ..
            } => {
                assert_eq!(name, "NEProviderStopReason");
                assert_eq!(underlying_primitive.as_deref(), Some("int64"));
            }
            other => panic!("expected Alias, got {other:?}"),
        }
    }

    #[test]
    fn merge_does_not_reclassify_a_class_that_collides_with_an_enum_name() {
        // A stray same-named declared class must win over the enum recovery —
        // never silently reclassified (the k66/k76/k90 "lossy map used as a
        // key" lesson).
        let mut objc = empty_framework("TestKit");
        objc.enums.push(ir::Enum {
            name: "Ambiguous".to_string(),
            enum_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "int64".to_string(),
                },
            },
            values: vec![],
            source: Some(DeclarationSource::ObjcHeader),
            provenance: None,
            doc_refs: None,
            objc_exposed: true,
        });
        objc.classes.push(empty_class("Ambiguous", vec![]));
        objc.classes.push(empty_class("Holder", vec![]));

        let mut swift_method = make_method("take:", DeclarationSource::SwiftInterface);
        swift_method.params.push(ir::Param {
            name: "value".to_string(),
            param_type: class_ref_type("Ambiguous", None),
        });
        let mut swift = empty_framework("TestKit");
        swift
            .classes
            .push(empty_class("Holder", vec![swift_method]));

        merge_swift_into_objc(&mut objc, swift);

        let holder = objc.classes.iter().find(|c| c.name == "Holder").unwrap();
        assert!(
            matches!(
                holder.methods[0].params[0].param_type.kind,
                TypeRefKind::Class { ref name, .. } if name == "Ambiguous"
            ),
            "a name that is also a declared class must stay Class"
        );
    }
}
