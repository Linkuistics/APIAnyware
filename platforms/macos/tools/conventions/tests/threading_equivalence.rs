//! Characterization test (the goldens-as-truth equivalence gate, ADR-0047).
//!
//! Asserts the `ConventionProgram`'s threading facet reproduces the legacy
//! imperative `heuristics.rs` `threading` output **exactly** — over synthetic
//! fixtures covering every legacy threading signal (class-level `@MainActor`
//! including the `_Concurrency.`-qualified form, the hardcoded UIKit class list,
//! and the UI selector list), their negatives (unrelated attributes, AppKit
//! classes without an attribute), class-method propagation, the protocol-gets-
//! no-class-attribute case, and the same-named class/protocol collision — and
//! over the real committed IR corpus (Foundation + AppKit) when present. AppKit
//! is the strong corpus: it carries the `NS_SWIFT_UI_ACTOR` / `@MainActor`
//! attributes and UI selectors (`drawRect:`, `layout`) this facet keys on.
//!
//! Sibling to `block_equivalence.rs` / `ownership_equivalence.rs`. Threading is
//! a **class/receiver-level** facet whose only derived value is `MainThreadOnly`
//! (the heuristic never emits `AnyThread`), so the comparison grain is the
//! **set** of `(receiver, selector)` methods classified main-thread-only.

use std::collections::BTreeSet;
use std::path::PathBuf;

use apianyware_annotate::heuristics::{
    annotate_method_heuristic, annotate_protocol_method_heuristic,
};
use apianyware_conventions::derive_threading;
use apianyware_types::annotation::ThreadingConstraint;
use apianyware_types::ir::{Class, Framework, Method, Param, Protocol};
use apianyware_types::type_ref::{TypeRef, TypeRefKind};

// ---------------------------------------------------------------------------
// Normalized comparison form — the set of main-thread-only methods
// ---------------------------------------------------------------------------

type MainThreadSet = BTreeSet<(String, String)>;

/// The legacy expected set: run `heuristics.rs` over the same method set the
/// annotate step classifies, keeping only methods whose threading is
/// `MainThreadOnly`.
fn legacy_main_thread(fw: &Framework) -> MainThreadSet {
    let mut set = MainThreadSet::new();

    let mut insert = |receiver: &str, selector: &str, threading: Option<ThreadingConstraint>| {
        if threading == Some(ThreadingConstraint::MainThreadOnly) {
            set.insert((receiver.to_string(), selector.to_string()));
        }
    };

    for class in &fw.classes {
        let methods = if class.all_methods.is_empty() {
            &class.methods
        } else {
            &class.all_methods
        };
        for method in methods {
            let ann = annotate_method_heuristic(class, method);
            insert(&class.name, &method.selector, ann.threading);
        }
        for group in &class.category_methods {
            for method in &group.methods {
                let ann = annotate_method_heuristic(class, method);
                insert(&class.name, &method.selector, ann.threading);
            }
        }
    }

    for proto in &fw.protocols {
        for method in proto.required_methods.iter().chain(&proto.optional_methods) {
            let ann = annotate_protocol_method_heuristic(proto, method);
            insert(&proto.name, &method.selector, ann.threading);
        }
    }

    set
}

/// The new set: the convention program's threading facet keys (every method the
/// rules classified `MainThreadOnly`).
fn rules_main_thread(fw: &Framework) -> MainThreadSet {
    derive_threading(std::slice::from_ref(fw))
        .into_keys()
        .collect()
}

fn assert_equivalent(fw: &Framework, label: &str) {
    let legacy = legacy_main_thread(fw);
    let rules = rules_main_thread(fw);
    // Surface the symmetric difference for a legible failure.
    let only_legacy: Vec<_> = legacy.difference(&rules).take(20).collect();
    let only_rules: Vec<_> = rules.difference(&legacy).take(20).collect();
    assert_eq!(
        legacy, rules,
        "[{label}] convention rules diverge from heuristics.rs threading classification\n  \
         in legacy not rules (≤20): {only_legacy:?}\n  \
         in rules not legacy (≤20): {only_rules:?}"
    );
}

// ---------------------------------------------------------------------------
// IR builders (mirror the legacy heuristics-test constructors)
// ---------------------------------------------------------------------------

fn ty(kind: TypeRefKind) -> TypeRef {
    TypeRef {
        nullable: false,
        kind,
    }
}

fn param(name: &str, param_type: TypeRef) -> Param {
    Param {
        name: name.to_string(),
        param_type,
    }
}

fn method_kind(selector: &str, params: Vec<Param>, class_method: bool) -> Method {
    Method {
        selector: selector.to_string(),
        class_method,
        init_method: false,
        params,
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

/// An instance method with no parameters (the common threading-test shape — the
/// signals key on receiver name / selector / class attributes, not params).
fn method(selector: &str) -> Method {
    method_kind(selector, vec![], false)
}

/// A class (`+`) method — used to prove `@MainActor` propagates to class methods.
fn class_method(selector: &str) -> Method {
    method_kind(selector, vec![], true)
}

fn class_with(name: &str, methods: Vec<Method>, swift_attributes: Vec<String>) -> Class {
    Class {
        name: name.to_string(),
        superclass: String::new(),
        protocols: vec![],
        properties: vec![],
        methods,
        category_methods: vec![],
        swift_attributes,
        ancestors: vec![],
        all_methods: vec![],
        all_properties: vec![],
        objc_exposed: true,
        swift_name: None,
    }
}

/// A class carrying no Swift attributes.
fn class(name: &str, methods: Vec<Method>) -> Class {
    class_with(name, methods, vec![])
}

fn protocol(name: &str, required: Vec<Method>) -> Protocol {
    Protocol {
        name: name.to_string(),
        inherits: vec![],
        required_methods: required,
        optional_methods: vec![],
        properties: vec![],
        source: None,
        provenance: None,
        doc_refs: None,
        objc_exposed: true,
    }
}

fn framework(name: &str, classes: Vec<Class>, protocols: Vec<Protocol>) -> Framework {
    Framework {
        format_version: "1.0".to_string(),
        checkpoint: "linked".to_string(),
        name: name.to_string(),
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

fn attrs(values: &[&str]) -> Vec<String> {
    values.iter().map(|s| s.to_string()).collect()
}

// ---------------------------------------------------------------------------
// Synthetic coverage — every legacy threading signal + its negatives
// ---------------------------------------------------------------------------

#[test]
fn synthetic_threading_cases_match_heuristics() {
    let classes = vec![
        // --- Signal 1: class-level @MainActor → every method main-thread,
        //     instance AND class method alike ---
        class_with(
            "MainActorClass",
            vec![method("instanceMethod"), class_method("classMethod")],
            attrs(&["MainActor"]),
        ),
        // --- Signal 1: the `_Concurrency.`-qualified form also matches ---
        class_with(
            "QualifiedMainActor",
            vec![method("doThing")],
            attrs(&["_Concurrency.MainActor"]),
        ),
        // --- Signal 1 negative: unrelated attributes do NOT trigger ---
        class_with(
            "UnrelatedAttrs",
            vec![method("doThing")],
            attrs(&["Available", "HasStorage", "MacroRole"]),
        ),
        // --- Signal 2: hardcoded UIKit class list (no attribute needed) ---
        class("UIView", vec![method("someMethod")]),
        class("UIViewController", vec![method("someMethod")]),
        // --- Signal 2 negative: AppKit class without an attribute is NOT in the
        //     hardcoded list (it would reach the heuristic via swift_attributes) ---
        class("NSWindow", vec![method("someMethod")]),
        // --- Signal 1 on an AppKit class: NSWindow + @MainActor → main-thread ---
        class_with(
            "NSWindowActor",
            vec![method("someMethod")],
            attrs(&["MainActor"]),
        ),
        // --- Signal 3: UI selector list on ANY class ---
        class(
            "PlainClass",
            vec![
                method("display"),
                method("setNeedsDisplay"),
                method("setNeedsLayout"),
                method("layout"),
                method_kind(
                    "drawRect:",
                    vec![param(
                        "rect",
                        ty(TypeRefKind::Struct {
                            name: "CGRect".to_string(),
                        }),
                    )],
                    false,
                ),
                method("updateLayer"),
                // Non-UI selectors on the same class stay unconstrained.
                method("length"),
                method("count"),
            ],
        ),
        // --- A no-signal class: nothing main-thread ---
        class("NSString", vec![method("length"), method("substring")]),
    ];

    let protocols = vec![
        // Protocols carry no swift-attributes → no class-@MainActor signal.
        protocol("MyProtocol", vec![method("doStuff"), method("configure")]),
        // …but the UI selector signal is selector-only, so it DOES apply to a
        // protocol method named `layout`.
        protocol("MyDrawing", vec![method("layout"), method("custom")]),
    ];

    assert_equivalent(&framework("Synthetic", classes, protocols), "synthetic");
}

#[test]
fn category_methods_inherit_class_main_actor() {
    // A category method on a @MainActor class is classified exactly as a direct
    // method (the loader enumerates category methods too).
    let mut c = class_with("MAClass", vec![method("direct")], attrs(&["MainActor"]));
    c.category_methods
        .push(apianyware_types::ir::CategoryGroup {
            category: "Extra".to_string(),
            origin_framework: "CatFW".to_string(),
            methods: vec![method("categoryMethod")],
        });
    assert_equivalent(&framework("CatFW", vec![c], vec![]), "category");
}

#[test]
fn same_named_class_and_protocol_collision() {
    // A class `NSObject` with @MainActor and a same-named protocol `NSObject`
    // (the real Cocoa collision). The class's attribute must NOT leak to the
    // protocol's distinct method — `legacy` passes `&[]` for protocols, and the
    // rules' `is_class` tag reproduces that exactly.
    let classes = vec![class_with(
        "NSObject",
        vec![method("classOnlySelector"), method("shared")],
        attrs(&["MainActor"]),
    )];
    let protocols = vec![protocol(
        "NSObject",
        vec![method("protocolOnlySelector"), method("isEqual:")],
    )];
    assert_equivalent(&framework("Collision", classes, protocols), "collision");
}

// ---------------------------------------------------------------------------
// Real IR corpus — the strongest equivalence proof (skips when IR absent)
// ---------------------------------------------------------------------------

fn api_root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("..")
        .join("..")
        .join("api")
}

fn load_resolved(name: &str) -> Option<Framework> {
    let path = api_root().join(name).join("resolved.json");
    if !path.exists() {
        return None;
    }
    Some(apianyware_datalog::loading::load_framework_from_file(&path).unwrap())
}

#[test]
fn real_ir_threading_matches_heuristics() {
    let mut ran = false;
    for name in ["Foundation", "AppKit"] {
        if let Some(fw) = load_resolved(name) {
            assert_equivalent(&fw, name);
            ran = true;
        }
    }
    if !ran {
        eprintln!(
            "skipping real-IR threading equivalence: no resolved.json under {} \
             (gitignored — regenerate the pipeline to exercise this)",
            api_root().display()
        );
    }
}

// ---------------------------------------------------------------------------
// Provenance stamp shape (ADR-0046 §4)
// ---------------------------------------------------------------------------

#[test]
fn derived_threading_facts_carry_convention_rule_stamps() {
    let fw = framework(
        "P",
        vec![
            // @MainActor only → one stamp.
            class_with("Actor", vec![method("foo")], attrs(&["MainActor"])),
            // UIKit list only → one stamp. (A distinct UIKit-list name from the
            // triple-signal `UIView` below — two same-named classes would merge
            // facts under the bare-name key.)
            class("UIButton", vec![method("bar")]),
            // UI selector only → one stamp.
            class("Plain", vec![method("layout")]),
            // All three signals on one method → three stamps (disjunction).
            class_with("UIView", vec![method("drawRect:")], attrs(&["MainActor"])),
        ],
        vec![],
    );

    let facets = derive_threading(std::slice::from_ref(&fw));

    let actor = &facets[&("Actor".to_string(), "foo".to_string())];
    assert_eq!(actor.threading, ThreadingConstraint::MainThreadOnly);
    assert_eq!(actor.provenance, vec!["convention:main-actor-attribute"]);

    let uikit = &facets[&("UIButton".to_string(), "bar".to_string())];
    assert_eq!(uikit.provenance, vec!["convention:uikit-class"]);

    let selector = &facets[&("Plain".to_string(), "layout".to_string())];
    assert_eq!(selector.provenance, vec!["convention:ui-selector"]);

    // The triple-signal method carries every firing rule's stamp, sorted+deduped.
    let triple = &facets[&("UIView".to_string(), "drawRect:".to_string())];
    assert_eq!(
        triple.provenance,
        vec![
            "convention:main-actor-attribute",
            "convention:ui-selector",
            "convention:uikit-class",
        ]
    );

    // Every stamp is a well-formed `convention:<rule>`.
    for facet in facets.values() {
        assert_eq!(facet.threading, ThreadingConstraint::MainThreadOnly);
        assert!(!facet.provenance.is_empty(), "a present facet has ≥1 stamp");
        for stamp in &facet.provenance {
            assert!(
                stamp.starts_with("convention:") && stamp.len() > "convention:".len(),
                "malformed provenance stamp: {stamp}"
            );
        }
    }
}
