//! Synthetic tests for the resolution Datalog program.
//!
//! These tests use hand-built Framework IR to exercise resolution rules
//! without depending on collected JSON files. They cover single-framework
//! inheritance, cross-framework inheritance, method/property override
//! semantics, ownership detection, and protocol conformance.

use apianyware_types::ir::{Class, Method, Param, Property, Protocol};
use apianyware_types::type_ref::{TypeRef, TypeRefKind};
use apianyware_types::Framework;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

fn empty_framework(name: &str) -> Framework {
    Framework {
        format_version: "1.0".to_string(),
        checkpoint: "collected".to_string(),
        name: name.to_string(),
        sdk_version: None,
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
        api_patterns: vec![],
        enrichment: None,
        verification: None,
    }
}

fn make_class(name: &str, superclass: &str) -> Class {
    Class {
        name: name.to_string(),
        superclass: superclass.to_string(),
        protocols: vec![],
        properties: vec![],
        methods: vec![],
        category_methods: vec![],
        swift_attributes: vec![],
        ancestors: vec![],
        all_methods: vec![],
        all_properties: vec![],
        objc_exposed: true,
        swift_name: None,
    }
}

fn make_method(selector: &str, class_method: bool) -> Method {
    Method {
        selector: selector.to_string(),
        class_method,
        init_method: selector.starts_with("init"),
        params: vec![],
        return_type: TypeRef::void(),
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

fn make_method_with_params(selector: &str, params: Vec<Param>) -> Method {
    Method {
        selector: selector.to_string(),
        class_method: false,
        init_method: selector.starts_with("init"),
        params,
        return_type: TypeRef {
            nullable: false,
            kind: TypeRefKind::Id,
        },
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

fn make_property(name: &str) -> Property {
    Property {
        name: name.to_string(),
        property_type: TypeRef {
            nullable: false,
            kind: TypeRefKind::Id,
        },
        readonly: false,
        class_property: false,
        is_copy: false,
        deprecated: false,
        source: None,
        provenance: None,
        doc_refs: None,
        origin: None,
        objc_exposed: true,
    }
}

fn resolve(frameworks: &[Framework]) -> Vec<Framework> {
    apianyware_resolve::resolve_loaded_frameworks(frameworks).unwrap()
}

fn find_class<'a>(frameworks: &'a [Framework], class_name: &str) -> &'a Class {
    frameworks
        .iter()
        .flat_map(|fw| &fw.classes)
        .find(|c| c.name == class_name)
        .unwrap_or_else(|| panic!("class {class_name} not found in resolved frameworks"))
}

// ---------------------------------------------------------------------------
// objc_exposed survives the resolve flatten transform (ADR-0026)
// ---------------------------------------------------------------------------

#[test]
fn objc_exposed_false_survives_resolve_flattening() {
    // A class carrying a Swift-native method (objc_exposed: false) — the
    // per-member trampoline residual. Resolve flattens own + inherited methods
    // into `all_methods`; the fact must ride through unchanged so the emitter
    // still sees it after resolve.
    let mut fw = empty_framework("TestKit");
    let mut parent = make_class("Parent", "");
    let mut swift_method = make_method("swiftOnly", false);
    swift_method.objc_exposed = false;
    parent.methods = vec![make_method("objcOnly", false), swift_method];
    let child = make_class("Child", "Parent");
    fw.classes = vec![parent, child];

    let resolved = resolve(&[fw]);

    // Own class: the method retains objc_exposed: false in all_methods.
    let parent = find_class(&resolved, "Parent");
    let swift = parent
        .all_methods
        .iter()
        .find(|m| m.selector == "swiftOnly")
        .expect("swiftOnly should be in Parent.all_methods");
    assert!(
        !swift.objc_exposed,
        "objc_exposed false must survive flatten"
    );
    let objc = parent
        .all_methods
        .iter()
        .find(|m| m.selector == "objcOnly")
        .expect("objcOnly should be in Parent.all_methods");
    assert!(objc.objc_exposed, "objc_exposed true preserved");

    // Inherited into the child: the fact rides through inheritance flattening.
    let child = find_class(&resolved, "Child");
    let inherited = child
        .all_methods
        .iter()
        .find(|m| m.selector == "swiftOnly")
        .expect("swiftOnly should be inherited into Child.all_methods");
    assert!(
        !inherited.objc_exposed,
        "inherited Swift-native method keeps objc_exposed: false"
    );
}

// ---------------------------------------------------------------------------
// Single-framework ancestry
// ---------------------------------------------------------------------------

#[test]
fn direct_parent_becomes_ancestor() {
    let mut fw = empty_framework("TestKit");
    fw.classes = vec![make_class("Parent", ""), make_class("Child", "Parent")];

    let resolved = resolve(&[fw]);
    let child = find_class(&resolved, "Child");

    assert!(child.ancestors.contains(&"Parent".to_string()));
}

#[test]
fn root_class_has_no_ancestors() {
    let mut fw = empty_framework("TestKit");
    fw.classes = vec![make_class("Root", "")];

    let resolved = resolve(&[fw]);
    let root = find_class(&resolved, "Root");

    assert!(root.ancestors.is_empty());
}

#[test]
fn transitive_ancestors_computed() {
    let mut fw = empty_framework("TestKit");
    fw.classes = vec![
        make_class("GrandParent", ""),
        make_class("Parent", "GrandParent"),
        make_class("Child", "Parent"),
    ];

    let resolved = resolve(&[fw]);
    let child = find_class(&resolved, "Child");

    assert!(child.ancestors.contains(&"Parent".to_string()));
    assert!(child.ancestors.contains(&"GrandParent".to_string()));
    assert_eq!(child.ancestors.len(), 2);
}

// ---------------------------------------------------------------------------
// Cross-framework ancestry
// ---------------------------------------------------------------------------

#[test]
fn cross_framework_ancestor_resolved() {
    let mut fw1 = empty_framework("BaseKit");
    fw1.classes = vec![make_class("BaseObject", "")];

    let mut fw2 = empty_framework("AppKit");
    fw2.classes = vec![make_class("AppWidget", "BaseObject")];

    let resolved = resolve(&[fw1, fw2]);
    let widget = find_class(&resolved, "AppWidget");

    assert!(widget.ancestors.contains(&"BaseObject".to_string()));
}

#[test]
fn cross_framework_transitive_ancestors() {
    let mut fw1 = empty_framework("BaseKit");
    fw1.classes = vec![make_class("Root", ""), make_class("BaseObject", "Root")];

    let mut fw2 = empty_framework("AppKit");
    fw2.classes = vec![make_class("AppWidget", "BaseObject")];

    let resolved = resolve(&[fw1, fw2]);
    let widget = find_class(&resolved, "AppWidget");

    assert!(widget.ancestors.contains(&"BaseObject".to_string()));
    assert!(widget.ancestors.contains(&"Root".to_string()));
    assert_eq!(widget.ancestors.len(), 2);
}

// ---------------------------------------------------------------------------
// Method inheritance
// ---------------------------------------------------------------------------

#[test]
fn child_inherits_parent_methods() {
    let mut parent = make_class("Parent", "");
    parent.methods = vec![make_method("doSomething", false)];

    let child = make_class("Child", "Parent");

    let mut fw = empty_framework("TestKit");
    fw.classes = vec![parent, child];

    let resolved = resolve(&[fw]);
    let child = find_class(&resolved, "Child");

    let inherited = child
        .all_methods
        .iter()
        .find(|m| m.selector == "doSomething");
    assert!(inherited.is_some(), "child should inherit parent method");

    let method = inherited.unwrap();
    assert_eq!(
        method.origin.as_deref(),
        Some("Parent"),
        "inherited method should have origin=Parent"
    );
}

#[test]
fn own_methods_have_no_origin() {
    let mut parent = make_class("Parent", "");
    parent.methods = vec![make_method("parentMethod", false)];

    let mut child = make_class("Child", "Parent");
    child.methods = vec![make_method("childMethod", false)];

    let mut fw = empty_framework("TestKit");
    fw.classes = vec![parent, child];

    let resolved = resolve(&[fw]);
    let child = find_class(&resolved, "Child");

    let own = child
        .all_methods
        .iter()
        .find(|m| m.selector == "childMethod")
        .expect("child should have its own method");
    assert_eq!(own.origin, None, "own methods should not have origin set");
}

#[test]
fn child_override_replaces_parent_method() {
    let mut parent = make_class("Parent", "");
    parent.methods = vec![make_method("doSomething", false)];

    let mut child = make_class("Child", "Parent");
    child.methods = vec![make_method("doSomething", false)];

    let mut fw = empty_framework("TestKit");
    fw.classes = vec![parent, child];

    let resolved = resolve(&[fw]);
    let child = find_class(&resolved, "Child");

    let matching: Vec<_> = child
        .all_methods
        .iter()
        .filter(|m| m.selector == "doSomething" && !m.class_method)
        .collect();

    assert_eq!(
        matching.len(),
        1,
        "overridden method should appear exactly once"
    );
    assert_eq!(
        matching[0].origin, None,
        "overriding method is the child's own, so origin should be None"
    );
}

#[test]
fn class_and_instance_methods_are_separate_namespaces() {
    let mut parent = make_class("Parent", "");
    parent.methods = vec![
        make_method("sharedMethod", true),  // class method
        make_method("sharedMethod", false), // instance method
    ];

    let child = make_class("Child", "Parent");

    let mut fw = empty_framework("TestKit");
    fw.classes = vec![parent, child];

    let resolved = resolve(&[fw]);
    let child = find_class(&resolved, "Child");

    let shared: Vec<_> = child
        .all_methods
        .iter()
        .filter(|m| m.selector == "sharedMethod")
        .collect();

    assert_eq!(
        shared.len(),
        2,
        "both class and instance method should be inherited"
    );
    assert!(shared.iter().any(|m| m.class_method));
    assert!(shared.iter().any(|m| !m.class_method));
}

// ---------------------------------------------------------------------------
// Cross-framework method inheritance
// ---------------------------------------------------------------------------

#[test]
fn cross_framework_method_inheritance() {
    let mut parent = make_class("BaseObject", "");
    parent.methods = vec![make_method("baseMethod", false)];

    let mut fw1 = empty_framework("BaseKit");
    fw1.classes = vec![parent];

    let mut fw2 = empty_framework("AppKit");
    fw2.classes = vec![make_class("AppWidget", "BaseObject")];

    let resolved = resolve(&[fw1, fw2]);
    let widget = find_class(&resolved, "AppWidget");

    let inherited = widget
        .all_methods
        .iter()
        .find(|m| m.selector == "baseMethod");
    assert!(
        inherited.is_some(),
        "child should inherit cross-framework method"
    );
    assert_eq!(inherited.unwrap().origin.as_deref(), Some("BaseObject"));
}

#[test]
fn cross_framework_override_uses_child_version() {
    let mut parent = make_class("BaseObject", "");
    parent.methods = vec![make_method("doWork", false)];

    let mut fw1 = empty_framework("BaseKit");
    fw1.classes = vec![parent];

    let mut child = make_class("AppWidget", "BaseObject");
    child.methods = vec![make_method("doWork", false)];

    let mut fw2 = empty_framework("AppKit");
    fw2.classes = vec![child];

    let resolved = resolve(&[fw1, fw2]);
    let widget = find_class(&resolved, "AppWidget");

    let matching: Vec<_> = widget
        .all_methods
        .iter()
        .filter(|m| m.selector == "doWork" && !m.class_method)
        .collect();

    assert_eq!(matching.len(), 1, "overridden method appears once");
    assert_eq!(
        matching[0].origin, None,
        "child's own override has no origin"
    );
}

// ---------------------------------------------------------------------------
// Property inheritance
// ---------------------------------------------------------------------------

#[test]
fn child_inherits_parent_properties() {
    let mut parent = make_class("Parent", "");
    parent.properties = vec![make_property("title")];

    let child = make_class("Child", "Parent");

    let mut fw = empty_framework("TestKit");
    fw.classes = vec![parent, child];

    let resolved = resolve(&[fw]);
    let child = find_class(&resolved, "Child");

    let inherited = child.all_properties.iter().find(|p| p.name == "title");
    assert!(inherited.is_some(), "child should inherit parent property");
    assert_eq!(inherited.unwrap().origin.as_deref(), Some("Parent"));
}

#[test]
fn child_property_override_replaces_parent() {
    let mut parent = make_class("Parent", "");
    parent.properties = vec![make_property("title")];

    let mut child = make_class("Child", "Parent");
    child.properties = vec![make_property("title")];

    let mut fw = empty_framework("TestKit");
    fw.classes = vec![parent, child];

    let resolved = resolve(&[fw]);
    let child = find_class(&resolved, "Child");

    let matching: Vec<_> = child
        .all_properties
        .iter()
        .filter(|p| p.name == "title")
        .collect();

    assert_eq!(matching.len(), 1, "overridden property appears once");
    assert_eq!(matching[0].origin, None, "own property has no origin");
}

// ---------------------------------------------------------------------------
// Ownership detection (returns_retained)
// ---------------------------------------------------------------------------

#[test]
fn init_method_returns_retained() {
    let mut cls = make_class("MyClass", "");
    cls.methods = vec![make_method_with_params(
        "initWithName:",
        vec![Param {
            name: "name".to_string(),
            param_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Id,
            },
        }],
    )];

    let mut fw = empty_framework("TestKit");
    fw.classes = vec![cls];

    let resolved = resolve(&[fw]);
    let cls = find_class(&resolved, "MyClass");

    let init = cls
        .all_methods
        .iter()
        .find(|m| m.selector == "initWithName:")
        .expect("should have init method");

    assert_eq!(init.returns_retained, Some(true));
}

#[test]
fn new_class_method_returns_retained() {
    let mut cls = make_class("MyClass", "");
    cls.methods = vec![{
        let mut m = make_method("new", true);
        m.return_type = TypeRef {
            nullable: false,
            kind: TypeRefKind::Id,
        };
        m
    }];

    let mut fw = empty_framework("TestKit");
    fw.classes = vec![cls];

    let resolved = resolve(&[fw]);
    let cls = find_class(&resolved, "MyClass");

    let new_m = cls
        .all_methods
        .iter()
        .find(|m| m.selector == "new" && m.class_method)
        .expect("should have new class method");

    assert_eq!(new_m.returns_retained, Some(true));
}

#[test]
fn regular_method_not_retained() {
    let mut cls = make_class("MyClass", "");
    cls.methods = vec![make_method("doSomething", false)];

    let mut fw = empty_framework("TestKit");
    fw.classes = vec![cls];

    let resolved = resolve(&[fw]);
    let cls = find_class(&resolved, "MyClass");

    let regular = cls
        .all_methods
        .iter()
        .find(|m| m.selector == "doSomething")
        .expect("should have regular method");

    assert_eq!(regular.returns_retained, Some(false));
}

#[test]
fn copy_method_returns_retained() {
    let mut cls = make_class("MyClass", "");
    cls.methods = vec![{
        let mut m = make_method("copy", false);
        m.return_type = TypeRef {
            nullable: false,
            kind: TypeRefKind::Id,
        };
        m
    }];

    let mut fw = empty_framework("TestKit");
    fw.classes = vec![cls];

    let resolved = resolve(&[fw]);
    let cls = find_class(&resolved, "MyClass");

    let copy = cls
        .all_methods
        .iter()
        .find(|m| m.selector == "copy")
        .expect("should have copy method");

    assert_eq!(copy.returns_retained, Some(true));
}

// ---------------------------------------------------------------------------
// Protocol conformance
// ---------------------------------------------------------------------------

#[test]
fn protocol_method_satisfaction_detected() {
    let mut cls = make_class("MyClass", "");
    cls.protocols = vec!["NSCoding".to_string()];
    cls.methods = vec![make_method_with_params(
        "encodeWithCoder:",
        vec![Param {
            name: "coder".to_string(),
            param_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Id,
            },
        }],
    )];

    let proto = Protocol {
        name: "NSCoding".to_string(),
        inherits: vec![],
        required_methods: vec![make_method_with_params(
            "encodeWithCoder:",
            vec![Param {
                name: "coder".to_string(),
                param_type: TypeRef {
                    nullable: false,
                    kind: TypeRefKind::Id,
                },
            }],
        )],
        optional_methods: vec![],
        properties: vec![],
        source: None,
        provenance: None,
        doc_refs: None,
        objc_exposed: true,
    };

    let mut fw = empty_framework("TestKit");
    fw.classes = vec![cls];
    fw.protocols = vec![proto];

    let resolved = resolve(&[fw]);
    let cls = find_class(&resolved, "MyClass");

    let encode = cls
        .all_methods
        .iter()
        .find(|m| m.selector == "encodeWithCoder:")
        .expect("should have encode method");

    assert_eq!(
        encode.satisfies_protocol.as_deref(),
        Some("NSCoding"),
        "method should be tagged as satisfying NSCoding"
    );
}

#[test]
fn inherited_method_satisfies_protocol() {
    let mut parent = make_class("Parent", "");
    parent.methods = vec![make_method("hash", false)];

    let mut child = make_class("Child", "Parent");
    child.protocols = vec!["NSObject".to_string()];

    let proto = Protocol {
        name: "NSObject".to_string(),
        inherits: vec![],
        required_methods: vec![make_method("hash", false)],
        optional_methods: vec![],
        properties: vec![],
        source: None,
        provenance: None,
        doc_refs: None,
        objc_exposed: true,
    };

    let mut fw = empty_framework("TestKit");
    fw.classes = vec![parent, child];
    fw.protocols = vec![proto];

    let resolved = resolve(&[fw]);
    let child = find_class(&resolved, "Child");

    let hash = child
        .all_methods
        .iter()
        .find(|m| m.selector == "hash")
        .expect("should inherit hash method");

    assert_eq!(
        hash.satisfies_protocol.as_deref(),
        Some("NSObject"),
        "inherited method should satisfy protocol"
    );
}

#[test]
fn class_inherits_protocol_method_when_not_declared() {
    // Class conforms to a protocol but does not declare the protocol's method.
    // The resolved `all_methods` should contain the protocol method with the
    // protocol name as origin, so emitters can render it on the class binding.
    let mut cls = make_class("MyClass", "");
    cls.protocols = vec!["MyActionable".to_string()];

    let proto = Protocol {
        name: "MyActionable".to_string(),
        inherits: vec![],
        required_methods: vec![make_method_with_params(
            "runAction:",
            vec![Param {
                name: "action".to_string(),
                param_type: TypeRef {
                    nullable: false,
                    kind: TypeRefKind::Id,
                },
            }],
        )],
        optional_methods: vec![],
        properties: vec![],
        source: None,
        provenance: None,
        doc_refs: None,
        objc_exposed: true,
    };

    let mut fw = empty_framework("TestKit");
    fw.classes = vec![cls];
    fw.protocols = vec![proto];

    let resolved = resolve(&[fw]);
    let cls = find_class(&resolved, "MyClass");

    let run_action = cls
        .all_methods
        .iter()
        .find(|m| m.selector == "runAction:")
        .expect("class should inherit runAction: from MyActionable protocol");

    assert_eq!(
        run_action.origin.as_deref(),
        Some("MyActionable"),
        "protocol-inherited method origin should be the protocol name"
    );
    assert_eq!(
        run_action.params.len(),
        1,
        "protocol-inherited method should preserve the protocol's parameter list"
    );
}

#[test]
fn class_does_not_duplicate_protocol_method_already_declared() {
    // When a class both conforms to a protocol AND declares the protocol's
    // method directly, the class's declaration wins and no duplicate is emitted.
    let mut cls = make_class("MyClass", "");
    cls.protocols = vec!["MyActionable".to_string()];
    cls.methods = vec![make_method_with_params(
        "runAction:",
        vec![Param {
            name: "action".to_string(),
            param_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Id,
            },
        }],
    )];

    let proto = Protocol {
        name: "MyActionable".to_string(),
        inherits: vec![],
        required_methods: vec![make_method_with_params(
            "runAction:",
            vec![Param {
                name: "action".to_string(),
                param_type: TypeRef {
                    nullable: false,
                    kind: TypeRefKind::Id,
                },
            }],
        )],
        optional_methods: vec![],
        properties: vec![],
        source: None,
        provenance: None,
        doc_refs: None,
        objc_exposed: true,
    };

    let mut fw = empty_framework("TestKit");
    fw.classes = vec![cls];
    fw.protocols = vec![proto];

    let resolved = resolve(&[fw]);
    let cls = find_class(&resolved, "MyClass");

    let matching: Vec<_> = cls
        .all_methods
        .iter()
        .filter(|m| m.selector == "runAction:")
        .collect();

    assert_eq!(
        matching.len(),
        1,
        "class's own declaration should override protocol inheritance, not duplicate"
    );
    assert_eq!(
        matching[0].origin, None,
        "own method should have no origin (declared on the class itself)"
    );
}

#[test]
fn class_inherits_optional_protocol_methods() {
    // Optional protocol methods should also propagate to conforming classes —
    // emitters need to know about them so the binding exposes them.
    let mut cls = make_class("MyView", "");
    cls.protocols = vec!["MyDelegate".to_string()];

    let proto = Protocol {
        name: "MyDelegate".to_string(),
        inherits: vec![],
        required_methods: vec![],
        optional_methods: vec![make_method("optionalCallback", false)],
        properties: vec![],
        source: None,
        provenance: None,
        doc_refs: None,
        objc_exposed: true,
    };

    let mut fw = empty_framework("TestKit");
    fw.classes = vec![cls];
    fw.protocols = vec![proto];

    let resolved = resolve(&[fw]);
    let cls = find_class(&resolved, "MyView");

    assert!(
        cls.all_methods
            .iter()
            .any(|m| m.selector == "optionalCallback"),
        "class should inherit optional protocol methods"
    );
}

#[test]
fn class_inherits_methods_from_transitive_protocol_inheritance() {
    // Class conforms to ProtoA which inherits from ProtoB.
    // The class should see methods from both ProtoA and ProtoB.
    let mut cls = make_class("MyRenderer", "");
    cls.protocols = vec!["ProtoA".to_string()];

    let proto_a = Protocol {
        name: "ProtoA".to_string(),
        inherits: vec!["ProtoB".to_string()],
        required_methods: vec![make_method("methodA", false)],
        optional_methods: vec![],
        properties: vec![],
        source: None,
        provenance: None,
        doc_refs: None,
        objc_exposed: true,
    };
    let proto_b = Protocol {
        name: "ProtoB".to_string(),
        inherits: vec![],
        required_methods: vec![make_method("methodB", false)],
        optional_methods: vec![],
        properties: vec![],
        source: None,
        provenance: None,
        doc_refs: None,
        objc_exposed: true,
    };

    let mut fw = empty_framework("TestKit");
    fw.classes = vec![cls];
    fw.protocols = vec![proto_a, proto_b];

    let resolved = resolve(&[fw]);
    let cls = find_class(&resolved, "MyRenderer");

    assert!(
        cls.all_methods.iter().any(|m| m.selector == "methodA"),
        "should have direct-protocol method"
    );
    assert!(
        cls.all_methods.iter().any(|m| m.selector == "methodB"),
        "should have transitive-protocol method via inherits"
    );
}

#[test]
fn subclass_inherits_protocol_methods_from_superclass_conformance() {
    // Parent class conforms to a protocol; child class inherits from parent.
    // Child should see the protocol methods via the existing inherits_from rule
    // (no special-casing required — protocol propagation puts them on parent's
    // effective_method, and superclass inheritance carries them down).
    let mut parent = make_class("Parent", "");
    parent.protocols = vec!["MyActionable".to_string()];

    let child = make_class("Child", "Parent");

    let proto = Protocol {
        name: "MyActionable".to_string(),
        inherits: vec![],
        required_methods: vec![make_method("act", false)],
        optional_methods: vec![],
        properties: vec![],
        source: None,
        provenance: None,
        doc_refs: None,
        objc_exposed: true,
    };

    let mut fw = empty_framework("TestKit");
    fw.classes = vec![parent, child];
    fw.protocols = vec![proto];

    let resolved = resolve(&[fw]);
    let child = find_class(&resolved, "Child");

    assert!(
        child.all_methods.iter().any(|m| m.selector == "act"),
        "subclass should see protocol methods inherited via parent conformance"
    );
}

#[test]
fn cross_framework_protocol_method_inheritance() {
    // Protocol declared in one framework, class conforming to it in another.
    // The resolved class should still get the protocol's methods.
    let proto = Protocol {
        name: "NSCopying".to_string(),
        inherits: vec![],
        required_methods: vec![make_method_with_params(
            "copyWithZone:",
            vec![Param {
                name: "zone".to_string(),
                param_type: TypeRef {
                    nullable: true,
                    kind: TypeRefKind::Pointer,
                },
            }],
        )],
        optional_methods: vec![],
        properties: vec![],
        source: None,
        provenance: None,
        doc_refs: None,
        objc_exposed: true,
    };
    let mut fw_foundation = empty_framework("Foundation");
    fw_foundation.protocols = vec![proto];

    let mut cls = make_class("MyDoc", "");
    cls.protocols = vec!["NSCopying".to_string()];
    let mut fw_app = empty_framework("AppKit");
    fw_app.classes = vec![cls];

    let resolved = resolve(&[fw_foundation, fw_app]);
    let cls = find_class(&resolved, "MyDoc");

    let copy = cls
        .all_methods
        .iter()
        .find(|m| m.selector == "copyWithZone:")
        .expect("class should inherit copyWithZone: from cross-framework protocol");

    assert_eq!(copy.origin.as_deref(), Some("NSCopying"));
    assert_eq!(
        copy.params.len(),
        1,
        "cross-framework lookup should preserve the actual parameter list"
    );
}

// ---------------------------------------------------------------------------
// Multi-framework isolation
// ---------------------------------------------------------------------------

#[test]
fn resolution_results_partitioned_by_framework() {
    // FW1: Root with method "rootMethod"
    let mut root = make_class("Root", "");
    root.methods = vec![make_method("rootMethod", false)];

    let mut fw1 = empty_framework("BaseKit");
    fw1.classes = vec![root];

    // FW2: Child inherits Root, adds "childMethod"
    let mut child = make_class("Child", "Root");
    child.methods = vec![make_method("childMethod", false)];

    let mut fw2 = empty_framework("AppKit");
    fw2.classes = vec![child];

    let resolved = resolve(&[fw1, fw2]);

    // Find Root in the BaseKit output — it should NOT have Child's methods
    let root_fw = resolved.iter().find(|fw| fw.name == "BaseKit").unwrap();
    let root_cls = root_fw.classes.iter().find(|c| c.name == "Root").unwrap();

    assert!(
        root_cls
            .all_methods
            .iter()
            .all(|m| m.selector != "childMethod"),
        "parent framework should not contain child's methods"
    );

    // Find Child in the AppKit output — it should have both
    let child_fw = resolved.iter().find(|fw| fw.name == "AppKit").unwrap();
    let child_cls = child_fw.classes.iter().find(|c| c.name == "Child").unwrap();

    assert!(
        child_cls
            .all_methods
            .iter()
            .any(|m| m.selector == "rootMethod"),
        "child should inherit rootMethod"
    );
    assert!(
        child_cls
            .all_methods
            .iter()
            .any(|m| m.selector == "childMethod"),
        "child should have its own childMethod"
    );
}

#[test]
fn checkpoint_set_to_resolved() {
    let mut fw = empty_framework("TestKit");
    fw.classes = vec![make_class("MyClass", "")];

    let resolved = resolve(&[fw]);
    assert_eq!(resolved[0].checkpoint, "resolved");
}

#[test]
fn three_level_inheritance_chain_effective_methods() {
    let mut grandparent = make_class("GrandParent", "");
    grandparent.methods = vec![make_method("gpMethod", false)];
    grandparent.properties = vec![make_property("gpProp")];

    let mut parent = make_class("Parent", "GrandParent");
    parent.methods = vec![make_method("parentMethod", false)];

    let mut child = make_class("Child", "Parent");
    child.methods = vec![make_method("childMethod", false)];

    let mut fw = empty_framework("TestKit");
    fw.classes = vec![grandparent, parent, child];

    let resolved = resolve(&[fw]);
    let child = find_class(&resolved, "Child");

    // Child should have all three methods
    let selectors: Vec<&str> = child
        .all_methods
        .iter()
        .map(|m| m.selector.as_str())
        .collect();
    assert!(
        selectors.contains(&"gpMethod"),
        "should inherit from grandparent"
    );
    assert!(
        selectors.contains(&"parentMethod"),
        "should inherit from parent"
    );
    assert!(selectors.contains(&"childMethod"), "should have own method");

    // And grandparent's property
    assert!(
        child.all_properties.iter().any(|p| p.name == "gpProp"),
        "should inherit grandparent property"
    );
}

#[test]
fn mid_chain_override_uses_overriders_version() {
    // GrandParent declares "doWork", Parent overrides it, Child inherits Parent's version
    let mut grandparent = make_class("GrandParent", "");
    grandparent.methods = vec![make_method("doWork", false)];

    let mut parent = make_class("Parent", "GrandParent");
    parent.methods = vec![make_method("doWork", false)];

    let child = make_class("Child", "Parent");

    let mut fw = empty_framework("TestKit");
    fw.classes = vec![grandparent, parent, child];

    let resolved = resolve(&[fw]);
    let child = find_class(&resolved, "Child");

    let do_work: Vec<_> = child
        .all_methods
        .iter()
        .filter(|m| m.selector == "doWork")
        .collect();

    assert_eq!(do_work.len(), 1, "doWork should appear exactly once");
    assert_eq!(
        do_work[0].origin.as_deref(),
        Some("Parent"),
        "child should get Parent's version, not GrandParent's"
    );
}

// ---------------------------------------------------------------------------
// Cross-framework metadata preservation
// ---------------------------------------------------------------------------

#[test]
fn cross_framework_inherited_method_preserves_params() {
    let mut parent = make_class("BaseObject", "");
    parent.methods = vec![make_method_with_params(
        "initWithName:",
        vec![Param {
            name: "name".to_string(),
            param_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Id,
            },
        }],
    )];

    let mut fw1 = empty_framework("BaseKit");
    fw1.classes = vec![parent];

    let mut fw2 = empty_framework("AppKit");
    fw2.classes = vec![make_class("AppWidget", "BaseObject")];

    let resolved = resolve(&[fw1, fw2]);
    let widget = find_class(&resolved, "AppWidget");

    let init = widget
        .all_methods
        .iter()
        .find(|m| m.selector == "initWithName:")
        .expect("should inherit initWithName:");

    assert_eq!(
        init.params.len(),
        1,
        "cross-framework inherited method should preserve parameter metadata"
    );
    assert_eq!(init.params[0].name, "name");
}

#[test]
fn cross_framework_inherited_method_preserves_return_type() {
    let mut parent = make_class("BaseObject", "");
    parent.methods = vec![{
        let mut m = make_method("description", false);
        m.return_type = TypeRef {
            nullable: false,
            kind: TypeRefKind::Id,
        };
        m
    }];

    let mut fw1 = empty_framework("BaseKit");
    fw1.classes = vec![parent];

    let mut fw2 = empty_framework("AppKit");
    fw2.classes = vec![make_class("AppWidget", "BaseObject")];

    let resolved = resolve(&[fw1, fw2]);
    let widget = find_class(&resolved, "AppWidget");

    let desc = widget
        .all_methods
        .iter()
        .find(|m| m.selector == "description")
        .expect("should inherit description");

    assert!(
        !matches!(desc.return_type.kind, TypeRefKind::Primitive { ref name } if name == "void"),
        "cross-framework inherited method should preserve return type, not void"
    );
}

#[test]
fn cross_framework_inherited_property_preserves_type() {
    let mut parent = make_class("BaseObject", "");
    parent.properties = vec![Property {
        name: "title".to_string(),
        property_type: TypeRef {
            nullable: true,
            kind: TypeRefKind::Id,
        },
        readonly: true,
        class_property: false,
        is_copy: false,
        deprecated: false,
        source: None,
        provenance: None,
        doc_refs: None,
        origin: None,
        objc_exposed: true,
    }];

    let mut fw1 = empty_framework("BaseKit");
    fw1.classes = vec![parent];

    let mut fw2 = empty_framework("AppKit");
    fw2.classes = vec![make_class("AppWidget", "BaseObject")];

    let resolved = resolve(&[fw1, fw2]);
    let widget = find_class(&resolved, "AppWidget");

    let title = widget
        .all_properties
        .iter()
        .find(|p| p.name == "title")
        .expect("should inherit title property");

    assert!(
        title.property_type.nullable,
        "cross-framework inherited property should preserve nullable flag"
    );
    assert!(
        title.readonly,
        "cross-framework inherited property should preserve readonly flag"
    );
}
