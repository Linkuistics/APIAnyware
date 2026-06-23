//! Protocol composition tests (leaf 040/030) — [`emit_protocol`] and the
//! conformed-protocol flattening in [`emit_generics`] assembled *together* over a
//! small framework, the way the orchestration leaf (060) will. The per-module unit
//! tests cover each half in isolation; this asserts the two halves **agree**:
//!
//! - a bound class conforming to a protocol gets the protocol's method as a
//!   callable `defmethod` (flattening), and that flattened generic enters the
//!   global `defgeneric` set;
//! - a protocol's *delegate-only* selectors (no concrete class declares them) get
//!   their `defgeneric` from `emit_protocol`, not duplicated against the class
//!   graph;
//! - every emitted `defmethod` — own, flattened, or to-be-specialized-by-a-Lisp-
//!   subclass — has a matching `defgeneric` somewhere (the lockstep invariant
//!   across the class-graph generics *and* the protocol-contributed generics).

use std::collections::BTreeSet;

use apianyware_macos_emit_sbcl::emit_generics::{
    collect_generics, render_class_dispatch_with, render_generics,
};
use apianyware_macos_emit_sbcl::emit_protocol::render_protocol;
use apianyware_macos_emit_sbcl::protocol_registry::ProtocolRegistry;
use apianyware_macos_types::ir::{Class, Framework, Method, Param, Protocol};
use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

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

/// A method as the resolve phase lands it in `all_methods` for a conformed
/// protocol: origin = the declaring protocol.
fn flattened(selector: &str, origin: &str, ret: TypeRef, params: Vec<Param>) -> Method {
    let mut m = method(selector, ret, params);
    m.origin = Some(origin.into());
    m
}

fn param(name: &str, kind: TypeRefKind) -> Param {
    Param {
        name: name.into(),
        param_type: ty(kind),
    }
}

fn proto(name: &str, required: Vec<Method>, optional: Vec<Method>) -> Protocol {
    Protocol {
        name: name.into(),
        inherits: vec![],
        required_methods: required,
        optional_methods: optional,
        properties: vec![],
        source: None,
        provenance: None,
        doc_refs: None,
        objc_exposed: true,
    }
}

fn class(
    name: &str,
    protocols: Vec<String>,
    methods: Vec<Method>,
    all_methods: Vec<Method>,
) -> Class {
    Class {
        name: name.into(),
        superclass: "NSObject".into(),
        protocols,
        properties: vec![],
        methods,
        category_methods: vec![],
        swift_attributes: vec![],
        ancestors: vec![],
        all_methods,
        all_properties: vec![],
        objc_exposed: true,
        swift_name: None,
    }
}

fn fw(name: &str, classes: Vec<Class>, protocols: Vec<Protocol>) -> Framework {
    Framework {
        format_version: "1.0".into(),
        checkpoint: "enriched".into(),
        name: name.into(),
        sdk_version: None,
        collected_at: None,
        depends_on: vec![],
        skipped_symbols: vec![],
        classes,
        protocols,
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

/// A TestKit-shaped fixture exercising both protocol roles:
/// - `TKCopying` (the NSCopying analogue): one required `copyWithZone:`, conformed
///   by `TKDocument` — so `copyWithZone:` must flatten onto `ns:tk-document`.
/// - `TKDelegate`: optional delegate selectors no concrete class declares — so
///   `emit_protocol` must contribute their generics for a Lisp subclass to
///   specialize.
fn fixture() -> Framework {
    let tkcopying = proto(
        "TKCopying",
        vec![method(
            "copyWithZone:",
            ty(TypeRefKind::Instancetype),
            vec![param("zone", TypeRefKind::Id)],
        )],
        vec![],
    );
    let tkdelegate = proto(
        "TKDelegate",
        vec![],
        vec![
            method("tkDidStart", TypeRef::void(), vec![]),
            method(
                "tkShouldContinue",
                ty(TypeRefKind::Primitive {
                    name: "bool".into(),
                }),
                vec![],
            ),
        ],
    );
    // TKDocument conforms to TKCopying: copyWithZone: arrives in all_methods with
    // origin TKCopying, plus a real own method.
    let tkdocument = class(
        "TKDocument",
        vec!["TKCopying".into()],
        vec![method("title", ty(TypeRefKind::Id), vec![])],
        vec![flattened(
            "copyWithZone:",
            "TKCopying",
            ty(TypeRefKind::Id),
            vec![param("zone", TypeRefKind::Id)],
        )],
    );
    fw("TestKit", vec![tkdocument], vec![tkcopying, tkdelegate])
}

/// Build the registry + the global generic-name set the way 060 will, then render
/// the whole framework's protocol-relevant surface.
fn render_all(framework: &Framework) -> (String, BTreeSet<String>) {
    let registry = ProtocolRegistry::from_framework_refs(&[framework]);
    let generics = collect_generics(&[framework], &registry);
    let global_names: BTreeSet<String> = generics.iter().map(|d| d.name.clone()).collect();

    let mut out = String::new();
    out.push_str(&render_generics(&generics));
    for cls in &framework.classes {
        out.push_str(&render_class_dispatch_with(cls, &framework.name, &registry));
    }
    for p in &framework.protocols {
        out.push_str(&render_protocol(p, &framework.name, &global_names));
    }
    (out, global_names)
}

#[test]
fn conforming_class_flattens_protocol_method() {
    let (out, _) = render_all(&fixture());
    // copyWithZone: from TKCopying flattens onto ns:tk-document as a callable method.
    assert!(out.contains("(defmethod ns:copy-with-zone_ ((self ns:tk-document) zone)"));
    // The class's own method is still there.
    assert!(out.contains("(defmethod ns:title ((self ns:tk-document))"));
}

#[test]
fn flattened_selector_is_not_redeclared_by_its_protocol() {
    // ns:copy-with-zone is in the global generic set (from flattening), so
    // emit_protocol(TKCopying) must NOT emit a second defgeneric for it.
    let (out, names) = render_all(&fixture());
    assert!(names.contains("ns:copy-with-zone_"));
    assert_eq!(out.matches("(defgeneric ns:copy-with-zone_ ").count(), 1);
}

#[test]
fn delegate_only_selectors_get_their_generics_from_the_protocol() {
    // No concrete class declares the TKDelegate selectors, so they are NOT in the
    // class-graph generic set — emit_protocol contributes them for a Lisp subclass
    // to specialize via define-objc-method.
    let (out, names) = render_all(&fixture());
    assert!(
        !names.contains("ns:tk-did-start"),
        "delegate-only selector is not a class-graph generic"
    );
    assert!(out.contains("(defgeneric ns:tk-did-start (receiver)"));
    assert!(out.contains("(defgeneric ns:tk-should-continue (receiver)"));
}

#[test]
fn both_protocols_register_for_runtime_conformance() {
    let (out, _) = render_all(&fixture());
    assert!(out.contains("(register-objc-protocol \"TKCopying\""));
    assert!(out.contains("  :required ((\"copyWithZone:\" ns:copy-with-zone_))"));
    assert!(out.contains("(register-objc-protocol \"TKDelegate\""));
    assert!(out.contains("(\"tkDidStart\" ns:tk-did-start)"));
}

#[test]
fn every_defmethod_and_protocol_selector_has_a_matching_defgeneric() {
    // The lockstep across BOTH generic sources: collect the declared defgenerics
    // (class-graph + protocol-contributed) and confirm every defmethod generic and
    // every protocol-registered generic is declared.
    let (out, _) = render_all(&fixture());

    let declared: BTreeSet<String> = out
        .lines()
        .filter_map(|l| l.trim_start().strip_prefix("(defgeneric "))
        .filter_map(|rest| rest.split([' ', '(']).next())
        .map(str::to_string)
        .collect();

    let defmethod_generics: BTreeSet<String> = out
        .lines()
        .filter_map(|l| l.trim_start().strip_prefix("(defmethod "))
        .filter_map(|rest| rest.split([' ', '(']).next())
        .map(str::to_string)
        .collect();

    assert!(!defmethod_generics.is_empty());
    for g in &defmethod_generics {
        assert!(
            declared.contains(g),
            "defmethod generic {g} has no defgeneric; declared={declared:?}"
        );
    }
    // The delegate-only generics (which a Lisp subclass will specialize) are
    // declared too.
    assert!(declared.contains("ns:tk-did-start"));
    assert!(declared.contains("ns:tk-should-continue"));
}
