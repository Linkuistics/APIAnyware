//! Characterization test (the goldens-as-truth equivalence gate, ADR-0047).
//!
//! Asserts the `ConventionProgram`'s parameter-ownership facet reproduces the
//! legacy imperative `heuristics.rs` `parameter_ownership` output **exactly** —
//! over synthetic fixtures covering every legacy ownership case, and over the
//! real committed IR corpus when present. This is the safety net the remaining
//! facet leaves and the final pipeline flip lean on: the convention rules must
//! reproduce the current classifications before any new rule is added.

use std::collections::BTreeMap;
use std::path::PathBuf;

use apianyware_annotate::heuristics::{
    annotate_method_heuristic, annotate_protocol_method_heuristic,
};
use apianyware_conventions::derive_ownership;
use apianyware_types::annotation::OwnershipKind;
use apianyware_types::ir::{Class, Framework, Method, Param, Property, Protocol};
use apianyware_types::type_ref::{TypeRef, TypeRefKind};

// ---------------------------------------------------------------------------
// Normalized comparison form
// ---------------------------------------------------------------------------

/// A stable code per ownership kind so the facet can be compared without
/// requiring `Ord`/`Hash` on `OwnershipKind`.
fn kind_code(k: OwnershipKind) -> u8 {
    match k {
        OwnershipKind::Strong => 0,
        OwnershipKind::Weak => 1,
        OwnershipKind::Copy => 2,
        OwnershipKind::UnsafeUnretained => 3,
    }
}

/// `(param_index, kind_code)` pairs, sorted — the comparison grain.
type OwnershipSet = Vec<(usize, u8)>;

fn norm(entries: impl Iterator<Item = (usize, OwnershipKind)>) -> OwnershipSet {
    let mut v: OwnershipSet = entries.map(|(i, k)| (i, kind_code(k))).collect();
    v.sort_unstable();
    v.dedup();
    v
}

/// The legacy expected map: run `heuristics.rs` over the same method set the
/// annotate step classifies, keeping only methods with ≥1 ownership entry.
fn legacy_ownership(fw: &Framework) -> BTreeMap<(String, String), OwnershipSet> {
    let mut map: BTreeMap<(String, String), OwnershipSet> = BTreeMap::new();

    let mut insert = |receiver: &str, selector: &str, ann: &[(usize, OwnershipKind)]| {
        if ann.is_empty() {
            return;
        }
        let key = (receiver.to_string(), selector.to_string());
        let combined = map.entry(key).or_default();
        combined.extend(ann.iter().map(|(i, k)| (*i, kind_code(*k))));
        combined.sort_unstable();
        combined.dedup();
    };

    for class in &fw.classes {
        let methods = if class.all_methods.is_empty() {
            &class.methods
        } else {
            &class.all_methods
        };
        for method in methods {
            let ann = annotate_method_heuristic(class, method);
            let pairs: Vec<_> = ann
                .parameter_ownership
                .iter()
                .map(|p| (p.param_index, p.ownership))
                .collect();
            insert(&class.name, &method.selector, &pairs);
        }
        for group in &class.category_methods {
            for method in &group.methods {
                let ann = annotate_method_heuristic(class, method);
                let pairs: Vec<_> = ann
                    .parameter_ownership
                    .iter()
                    .map(|p| (p.param_index, p.ownership))
                    .collect();
                insert(&class.name, &method.selector, &pairs);
            }
        }
    }

    for proto in &fw.protocols {
        for method in proto.required_methods.iter().chain(&proto.optional_methods) {
            let ann = annotate_protocol_method_heuristic(proto, method);
            let pairs: Vec<_> = ann
                .parameter_ownership
                .iter()
                .map(|p| (p.param_index, p.ownership))
                .collect();
            insert(&proto.name, &method.selector, &pairs);
        }
    }

    map
}

/// The new map: the convention program's ownership facet, same grain.
fn rules_ownership(fw: &Framework) -> BTreeMap<(String, String), OwnershipSet> {
    derive_ownership(std::slice::from_ref(fw))
        .into_iter()
        .map(|(key, facet)| {
            let set = norm(
                facet
                    .parameter_ownership
                    .iter()
                    .map(|p| (p.param_index, p.ownership)),
            );
            (key, set)
        })
        .collect()
}

fn assert_equivalent(fw: &Framework, label: &str) {
    let legacy = legacy_ownership(fw);
    let rules = rules_ownership(fw);
    assert_eq!(
        legacy, rules,
        "[{label}] convention rules diverge from heuristics.rs ownership classification"
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

fn id_ty() -> TypeRef {
    ty(TypeRefKind::Id)
}

fn block_ty() -> TypeRef {
    ty(TypeRefKind::Block {
        params: vec![],
        return_type: Box::new(TypeRef::void()),
    })
}

fn prim(name: &str) -> TypeRef {
    ty(TypeRefKind::Primitive {
        name: name.to_string(),
    })
}

fn param(name: &str, param_type: TypeRef) -> Param {
    Param {
        name: name.to_string(),
        param_type,
    }
}

fn method(selector: &str, params: Vec<Param>) -> Method {
    Method {
        selector: selector.to_string(),
        class_method: false,
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

fn class(name: &str, methods: Vec<Method>) -> Class {
    Class {
        name: name.to_string(),
        superclass: String::new(),
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

#[allow(unused)]
fn property(name: &str, property_type: TypeRef, is_copy: bool) -> Property {
    Property {
        name: name.to_string(),
        property_type,
        readonly: false,
        class_property: false,
        is_copy,
        deprecated: false,
        source: None,
        provenance: None,
        doc_refs: None,
        origin: None,
        objc_exposed: true,
    }
}

// ---------------------------------------------------------------------------
// Synthetic coverage — every legacy ownership case, on both classes and protocols
// ---------------------------------------------------------------------------

#[test]
fn synthetic_ownership_cases_match_heuristics() {
    let classes = vec![
        // Delegate / data-source setters → param 0 weak (name + segment + setter).
        class(
            "A",
            vec![method("setDelegate:", vec![param("delegate", id_ty())])],
        ),
        class(
            "B",
            vec![method("setDataSource:", vec![param("dataSource", id_ty())])],
        ),
        // Delegate param by NAME at a non-zero index.
        class(
            "C",
            vec![method(
                "configureWith:delegate:",
                vec![param("config", id_ty()), param("delegate", id_ty())],
            )],
        ),
        // KVO / notification / shared observer → param 0 weak.
        class(
            "D",
            vec![
                method(
                    "addObserver:forKeyPath:options:context:",
                    vec![
                        param("observer", id_ty()),
                        param("keyPath", id_ty()),
                        param("options", prim("NSKeyValueObservingOptions")),
                        param("context", ty(TypeRefKind::Pointer)),
                    ],
                ),
                method(
                    "addObserver:selector:name:object:",
                    vec![
                        param("observer", id_ty()),
                        param("aSelector", prim("SEL")),
                        param("aName", id_ty()),
                        param("anObject", id_ty()),
                    ],
                ),
                method(
                    "addSharedObserver:forKey:options:context:",
                    vec![
                        param("observer", id_ty()),
                        param("key", id_ty()),
                        param("options", prim("NSKeyValueObservingOptions")),
                        param("context", ty(TypeRefKind::Pointer)),
                    ],
                ),
            ],
        ),
        // Observer NEGATIVE cases: block form (param 0 = name) + non-observer
        // first param name → neither weak; the block param IS copy.
        class(
            "E",
            vec![
                method(
                    "addObserverForName:object:queue:usingBlock:",
                    vec![
                        param("name", id_ty()),
                        param("obj", id_ty()),
                        param("queue", id_ty()),
                        param("block", block_ty()),
                    ],
                ),
                method(
                    "addObserver:forKeyPath:options:context:",
                    vec![
                        param("target", id_ty()),
                        param("keyPath", id_ty()),
                        param("options", prim("NSUInteger")),
                        param("context", ty(TypeRefKind::Pointer)),
                    ],
                ),
            ],
        ),
        // Block params → copy (sync + async shapes; ownership is copy either way).
        class(
            "F",
            vec![
                method(
                    "enumerateObjectsUsingBlock:",
                    vec![param("block", block_ty())],
                ),
                method(
                    "sortedArrayUsingComparator:",
                    vec![param("cmptr", block_ty())],
                ),
                method(
                    "dataTaskWithURL:completionHandler:",
                    vec![
                        param("url", id_ty()),
                        param("completionHandler", block_ty()),
                    ],
                ),
            ],
        ),
        // No ownership signal → no entry.
        class("G", vec![method("length", vec![])]),
        class("H", vec![method("compare:", vec![param("other", id_ty())])]),
    ];

    let protocols = vec![protocol(
        "MyIterating",
        vec![
            method(
                "enumerateItemsUsingBlock:",
                vec![param("block", block_ty())],
            ),
            method(
                "validateValue:error:",
                vec![
                    param("value", id_ty()),
                    param("error", ty(TypeRefKind::Pointer)),
                ],
            ),
        ],
    )];

    assert_equivalent(&framework("Synthetic", classes, protocols), "synthetic");
}

#[test]
fn category_methods_are_classified() {
    // A category method must be classified exactly as a direct method.
    let mut c = class("NSArray", vec![]);
    c.category_methods
        .push(apianyware_types::ir::CategoryGroup {
            category: "Sorting".to_string(),
            origin_framework: "CatFW".to_string(),
            methods: vec![method(
                "sortedArrayUsingComparator:",
                vec![param("cmptr", block_ty())],
            )],
        });
    assert_equivalent(&framework("CatFW", vec![c], vec![]), "category");
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
fn real_ir_ownership_matches_heuristics() {
    let mut ran = false;
    for name in ["Foundation", "AppKit"] {
        if let Some(fw) = load_resolved(name) {
            assert_equivalent(&fw, name);
            ran = true;
        }
    }
    if !ran {
        eprintln!(
            "skipping real-IR equivalence: no resolved.json under {} \
             (gitignored — regenerate the pipeline to exercise this)",
            api_root().display()
        );
    }
}

// ---------------------------------------------------------------------------
// Provenance stamp shape (ADR-0046 §4)
// ---------------------------------------------------------------------------

#[test]
fn derived_facts_carry_convention_rule_stamp() {
    let fw = framework(
        "P",
        vec![class(
            "X",
            vec![
                method("setDelegate:", vec![param("delegate", id_ty())]),
                method(
                    "enumerateObjectsUsingBlock:",
                    vec![param("block", block_ty())],
                ),
            ],
        )],
        vec![],
    );

    let facets = derive_ownership(std::slice::from_ref(&fw));

    let delegate = &facets[&("X".to_string(), "setDelegate:".to_string())];
    assert_eq!(
        delegate.provenance[&0],
        vec!["convention:weak-delegate-param"]
    );

    let block = &facets[&("X".to_string(), "enumerateObjectsUsingBlock:".to_string())];
    assert_eq!(block.provenance[&0], vec!["convention:block-param-copy"]);

    // Every stamp is well-formed `convention:<rule>`.
    for facet in facets.values() {
        for stamps in facet.provenance.values() {
            assert!(!stamps.is_empty());
            for stamp in stamps {
                assert!(
                    stamp.starts_with("convention:") && stamp.len() > "convention:".len(),
                    "malformed provenance stamp: {stamp}"
                );
            }
        }
    }
}
