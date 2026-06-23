//! Object-model composition tests (leaf 040/020) — the three modules
//! ([`class_graph`], [`emit_class`], [`emit_generics`]) emitted *together* over a
//! small framework, asserting the structural invariants the per-module unit tests
//! cannot see across module boundaries.
//!
//! The whole-file-tree golden snapshot is the orchestration leaf's (060) job; this
//! verifies the pieces *agree*: superclass-before-subclass graph ordering, every
//! `defmethod`'s generic having a matching global `defgeneric` (the lockstep
//! between `collect_generics` and the per-class dispatch), and the
//! `objc_exposed == false` residual being collected, not emitted.

use std::collections::HashSet;

use apianyware_emit_sbcl::class_graph::{build_class_graph, ClassRegistry};
use apianyware_emit_sbcl::emit_class::render_class;
use apianyware_emit_sbcl::emit_generics::{
    collect_generics, collect_residual, generic_arity_conflicts, render_class_dispatch,
    render_generics,
};
use apianyware_emit_sbcl::protocol_registry::ProtocolRegistry;
use apianyware_types::ir::{Class, Framework, Method, Param, Property};
use apianyware_types::type_ref::{TypeRef, TypeRefKind};

fn ty(kind: TypeRefKind) -> TypeRef {
    TypeRef {
        nullable: false,
        kind,
    }
}

fn method(selector: &str, ret: TypeRef, params: Vec<Param>) -> Method {
    Method {
        selector: selector.into(),
        class_method: false,
        init_method: false,
        params,
        return_type: ret,
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

fn param(name: &str, kind: TypeRefKind) -> Param {
    Param {
        name: name.into(),
        param_type: ty(kind),
    }
}

fn prop(name: &str, kind: TypeRefKind, readonly: bool) -> Property {
    Property {
        name: name.into(),
        property_type: ty(kind),
        readonly,
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

fn class(name: &str, superclass: &str, methods: Vec<Method>, properties: Vec<Property>) -> Class {
    Class {
        name: name.into(),
        superclass: superclass.into(),
        protocols: vec![],
        properties,
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

/// A small AppKit-shaped fixture: a 3-deep inheritance chain (NSResponder → NSView
/// → NSControl), a method, a writable property, and one Swift-native (`objc_exposed
/// == false`) method that must land in the residual.
fn fixture() -> Framework {
    let mut swift_native = method("nativeOnly", ty(TypeRefKind::Id), vec![]);
    swift_native.objc_exposed = false;

    Framework {
        format_version: "1.0".into(),
        checkpoint: "enriched".into(),
        name: "AppKit".into(),
        sdk_version: None,
        collected_at: None,
        depends_on: vec![],
        skipped_symbols: vec![],
        classes: vec![
            class("NSResponder", "NSObject", vec![], vec![]),
            class(
                "NSView",
                "NSResponder",
                vec![
                    method(
                        "addSubview:",
                        TypeRef::void(),
                        vec![param("view", TypeRefKind::Id)],
                    ),
                    swift_native,
                ],
                vec![prop(
                    "hidden",
                    TypeRefKind::Primitive {
                        name: "bool".into(),
                    },
                    false,
                )],
            ),
            class(
                "NSControl",
                "NSView",
                vec![method(
                    "integerValue",
                    ty(TypeRefKind::Primitive {
                        name: "int64".into(),
                    }),
                    vec![],
                )],
                vec![],
            ),
        ],
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

/// Render the whole framework's object model: class graph + per-class dispatch +
/// the global generics, concatenated as the orchestration leaf (060) would.
fn render_all(fw: &Framework) -> String {
    let registry = ClassRegistry::from_framework_refs(&[fw]);
    let graph = build_class_graph(fw, &registry);
    let mut out = String::new();
    for cls in &fw.classes {
        let parent = &graph.parents[&cls.name];
        out.push_str(&render_class(cls, &fw.name, parent));
        out.push_str(&render_class_dispatch(cls, &fw.name));
    }
    out.push_str(&render_generics(&collect_generics(
        &[fw],
        &ProtocolRegistry::new(),
    )));
    out
}

#[test]
fn class_graph_reflects_inheritance_chain() {
    let out = render_all(&fixture());
    // NSResponder roots on the runtime ns:ns-object; NSView derives from it;
    // NSControl from NSView — the reified ancestor chain (ADR-0034 §1).
    assert!(out.contains("(defclass ns:ns-responder (ns:ns-object) () (:metaclass objc-class))"));
    assert!(out.contains("(defclass ns:ns-view (ns:ns-responder) () (:metaclass objc-class))"));
    assert!(out.contains("(defclass ns:ns-control (ns:ns-view) () (:metaclass objc-class))"));
}

#[test]
fn every_defmethod_has_a_matching_defgeneric() {
    // The lockstep invariant: collect_generics must declare a generic for every
    // selector the per-class dispatch emits a defmethod for (else the binding loads
    // a defmethod against an undeclared generic). Extract both sets and compare.
    let fw = fixture();
    let out = render_all(&fw);

    let declared: HashSet<String> =
        render_generics(&collect_generics(&[&fw], &ProtocolRegistry::new()))
            .lines()
            .filter_map(|l| l.strip_prefix("(defgeneric "))
            .filter_map(|rest| rest.split([' ', '(']).next())
            .map(|s| s.to_string())
            .collect();

    let method_generics: HashSet<String> = out
        .lines()
        .filter_map(|l| l.trim_start().strip_prefix("(defmethod "))
        .filter_map(|rest| rest.split([' ', '(']).next())
        .map(|s| s.to_string())
        .collect();

    assert!(!method_generics.is_empty(), "fixture emits some defmethods");
    for g in &method_generics {
        assert!(
            declared.contains(g),
            "defmethod generic {g} has no matching defgeneric; declared = {declared:?}"
        );
    }
    // And the obvious members are present (ADR-0039: arg-taking selectors keep the
    // colon as a trailing `_`; 0-arg getters stay bare).
    assert!(declared.contains("ns:add-subview_"));
    assert!(declared.contains("ns:integer-value"));
    assert!(declared.contains("ns:hidden"));
    assert!(declared.contains("ns:set-hidden_"));
}

#[test]
fn swift_native_method_is_residual_only() {
    let fw = fixture();
    let out = render_all(&fw);
    // The objc_exposed == false method is NOT emitted as a defmethod…
    assert!(!out.contains("native-only"));
    assert!(!out.contains("nativeOnly"));
    // …and IS collected as residual for the trampoline (leaf 050).
    let nsview = fw.classes.iter().find(|c| c.name == "NSView").unwrap();
    let residual = collect_residual(nsview);
    assert_eq!(residual.len(), 1);
    assert_eq!(residual[0].selector, "nativeOnly");
    assert_eq!(residual[0].owner, "NSView");
}

#[test]
fn every_class_bakes_its_identity_string() {
    // The Class string table the startup re-resolution pass consumes (ADR-0034 §6).
    let out = render_all(&fixture());
    assert!(out.contains("(register-objc-class 'ns:ns-responder \"NSResponder\" \"NSObject\")"));
    assert!(out.contains("(register-objc-class 'ns:ns-view \"NSView\" \"NSResponder\")"));
    assert!(out.contains("(register-objc-class 'ns:ns-control \"NSControl\" \"NSView\")"));
}

#[test]
fn fixture_has_no_generic_arity_conflicts() {
    let fw = fixture();
    assert!(generic_arity_conflicts(&[&fw], &ProtocolRegistry::new()).is_empty());
}
