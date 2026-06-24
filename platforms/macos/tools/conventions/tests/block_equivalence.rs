//! Characterization test (the goldens-as-truth equivalence gate, ADR-0047).
//!
//! Asserts the `ConventionProgram`'s block-invocation facet reproduces the
//! legacy imperative `heuristics.rs` `block_parameters` output **exactly** —
//! over synthetic fixtures covering every legacy block-classification case (the
//! full sync / async / stored substring tables, the last-param async-method
//! rule, the `@property (copy)` block-setter override on both classes and
//! protocols, and their negatives + precedence orderings), and over the real
//! committed IR corpus when present. Sibling to `ownership_equivalence.rs`; the
//! block facet is the gnarliest (most string patterns), so this is the gate the
//! final pipeline flip leans on.

use std::collections::BTreeMap;
use std::path::PathBuf;

use apianyware_annotate::heuristics::{
    annotate_method_heuristic, annotate_protocol_method_heuristic,
};
use apianyware_conventions::derive_block_invocations;
use apianyware_types::annotation::BlockInvocationStyle;
use apianyware_types::ir::{Class, Framework, Method, Param, Property, Protocol};
use apianyware_types::type_ref::{TypeRef, TypeRefKind};

// ---------------------------------------------------------------------------
// Normalized comparison form
// ---------------------------------------------------------------------------

/// A stable code per invocation style so the facet can be compared without
/// requiring `Ord`/`Hash` on `BlockInvocationStyle`.
fn style_code(s: BlockInvocationStyle) -> u8 {
    match s {
        BlockInvocationStyle::Synchronous => 0,
        BlockInvocationStyle::AsyncCopied => 1,
        BlockInvocationStyle::Stored => 2,
    }
}

/// `(param_index, style_code)` pairs, sorted — the comparison grain.
type BlockSet = Vec<(usize, u8)>;

fn norm(entries: impl Iterator<Item = (usize, BlockInvocationStyle)>) -> BlockSet {
    let mut v: BlockSet = entries.map(|(i, s)| (i, style_code(s))).collect();
    v.sort_unstable();
    v.dedup();
    v
}

/// The legacy expected map: run `heuristics.rs` over the same method set the
/// annotate step classifies, keeping only methods with ≥1 block-param entry.
fn legacy_blocks(fw: &Framework) -> BTreeMap<(String, String), BlockSet> {
    let mut map: BTreeMap<(String, String), BlockSet> = BTreeMap::new();

    let mut insert = |receiver: &str, selector: &str, ann: &[(usize, BlockInvocationStyle)]| {
        if ann.is_empty() {
            return;
        }
        let key = (receiver.to_string(), selector.to_string());
        let combined = map.entry(key).or_default();
        combined.extend(ann.iter().map(|(i, s)| (*i, style_code(*s))));
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
                .block_parameters
                .iter()
                .map(|b| (b.param_index, b.invocation))
                .collect();
            insert(&class.name, &method.selector, &pairs);
        }
        for group in &class.category_methods {
            for method in &group.methods {
                let ann = annotate_method_heuristic(class, method);
                let pairs: Vec<_> = ann
                    .block_parameters
                    .iter()
                    .map(|b| (b.param_index, b.invocation))
                    .collect();
                insert(&class.name, &method.selector, &pairs);
            }
        }
    }

    for proto in &fw.protocols {
        for method in proto.required_methods.iter().chain(&proto.optional_methods) {
            let ann = annotate_protocol_method_heuristic(proto, method);
            let pairs: Vec<_> = ann
                .block_parameters
                .iter()
                .map(|b| (b.param_index, b.invocation))
                .collect();
            insert(&proto.name, &method.selector, &pairs);
        }
    }

    map
}

/// The new map: the convention program's block-invocation facet, same grain.
fn rules_blocks(fw: &Framework) -> BTreeMap<(String, String), BlockSet> {
    derive_block_invocations(std::slice::from_ref(fw))
        .into_iter()
        .map(|(key, facet)| {
            let set = norm(
                facet
                    .block_parameters
                    .iter()
                    .map(|b| (b.param_index, b.invocation)),
            );
            (key, set)
        })
        .collect()
}

fn assert_equivalent(fw: &Framework, label: &str) {
    let legacy = legacy_blocks(fw);
    let rules = rules_blocks(fw);
    assert_eq!(
        legacy, rules,
        "[{label}] convention rules diverge from heuristics.rs block-invocation classification"
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

fn param(name: &str, param_type: TypeRef) -> Param {
    Param {
        name: name.to_string(),
        param_type,
    }
}

fn block_param(name: &str) -> Param {
    param(name, block_ty())
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

fn class_with(name: &str, methods: Vec<Method>, properties: Vec<Property>) -> Class {
    Class {
        name: name.to_string(),
        superclass: String::new(),
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

fn class(name: &str, methods: Vec<Method>) -> Class {
    class_with(name, methods, vec![])
}

fn protocol_with(name: &str, required: Vec<Method>, properties: Vec<Property>) -> Protocol {
    Protocol {
        name: name.to_string(),
        inherits: vec![],
        required_methods: required,
        optional_methods: vec![],
        properties,
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

fn class_property(name: &str, property_type: TypeRef, is_copy: bool) -> Property {
    let mut p = property(name, property_type, is_copy);
    p.class_property = true;
    p
}

/// The synthesised single-arg setter `set<Cap>:` carrying a block param named
/// after the property — the shape `is_copy_block_property_setter` recognises.
fn block_setter(prop_name: &str) -> Method {
    let cap = {
        let mut c = prop_name.chars();
        let first = c.next().unwrap().to_ascii_uppercase();
        let mut s = String::with_capacity(prop_name.len());
        s.push(first);
        s.extend(c);
        s
    };
    method(&format!("set{cap}:"), vec![block_param(prop_name)])
}

// ---------------------------------------------------------------------------
// Synthetic coverage — every legacy block-classification case
// ---------------------------------------------------------------------------

#[test]
fn synthetic_block_cases_match_heuristics() {
    let classes = vec![
        // --- Sync substring table (one selector per token) → synchronous ---
        class(
            "Sync",
            vec![
                method("enumerateObjectsUsingBlock:", vec![block_param("block")]),
                method("sortedArrayUsingComparator:", vec![block_param("cmptr")]), // sortedarray + comparator
                method("sortUsingComparator:", vec![block_param("cmptr")]),        // sortusing
                method("predicateWithBlock:", vec![block_param("block")]),         // predicate
                method("filteredArrayUsingBlock:", vec![block_param("block")]),    // filteredarray
                method("filteredSetUsingBlock:", vec![block_param("block")]),      // filtered
                method("indexOfObjectPassingTest:", vec![block_param("block")]), // indexofobject + passingtest
                method("indexesOfObjectsPassingTest:", vec![block_param("block")]), // indexesofobjects
            ],
        ),
        // --- Async token table → async_copied ---
        class(
            "AsyncToken",
            vec![
                method("fooWithCompletion:", vec![block_param("block")]), // completion
                method("fooWithHandler:", vec![block_param("block")]),    // handler
                method("registerCallback:", vec![block_param("block")]),  // callback
                method("sendReply:", vec![block_param("block")]),         // reply
                method("doWithResponse:", vec![block_param("block")]),    // withresponse
            ],
        ),
        // --- Last-param + async-method token → async_copied ---
        class(
            "AsyncMethodLast",
            vec![
                method(
                    "dataTaskWithURL:thenBlock:",
                    vec![param("url", id_ty()), block_param("block")],
                ), // datatask
                method("downloadUsingBlock:", vec![block_param("block")]), // download
                method("uploadUsingBlock:", vec![block_param("block")]),   // upload
                method("fetchUsingBlock:", vec![block_param("block")]),    // fetch
                method("loadUsingBlock:", vec![block_param("block")]),     // load
                method("performUsingBlock:", vec![block_param("block")]),  // perform
                method("animateUsingBlock:", vec![block_param("block")]),  // animate
            ],
        ),
        // --- Async-method token but block NOT last → token ignored ---
        // `fetch` would mark async only as last param; here the block is index
        // 0 of two params, so it falls through to the default (also async, but
        // via a different rule — the *style* must still match legacy).
        class(
            "AsyncMethodNotLast",
            vec![method(
                "fetchUsingBlock:withTimeout:",
                vec![block_param("block"), param("timeout", id_ty())],
            )],
        ),
        // --- Stored substring table → stored ---
        class(
            "Stored",
            vec![
                method(
                    "addObserver:usingBlock:",
                    vec![param("name", id_ty()), block_param("block")],
                ), // addobserver
                method("observeChangesWithBlock:", vec![block_param("block")]), // observe
                method("notificationUsingBlock:", vec![block_param("block")]),  // notification
                method("addOperationWithBlock:", vec![block_param("block")]),   // addoperation
            ],
        ),
        // --- Default → async_copied (no token matches) ---
        class(
            "Default",
            vec![method("doThingWithBlock:", vec![block_param("block")])],
        ),
        // --- Precedence: sync beats async-token; async-token beats stored ---
        class(
            "Precedence",
            vec![
                // enumerate (sync) + handler (async) → synchronous wins.
                method("enumerateUsingHandlerBlock:", vec![block_param("block")]),
                // completion (async) + observe (stored) → async wins.
                method("observeWithCompletion:", vec![block_param("block")]),
            ],
        ),
        // --- Last-param gate flips stored↔async (download + observe) ---
        class(
            "Gate",
            vec![
                // block last → download (async-method) wins over observe.
                method(
                    "downloadAndObserve:block:",
                    vec![param("arg", id_ty()), block_param("block")],
                ),
                // block not last → download token ignored, observe (stored) wins.
                method(
                    "downloadAndObserveWithBlock:extra:",
                    vec![block_param("block"), param("extra", id_ty())],
                ),
            ],
        ),
        // --- Non-block params produce no block facet (mixed method) ---
        class(
            "Mixed",
            vec![method(
                "configureWith:completion:",
                vec![param("config", id_ty()), block_param("completion")],
            )],
        ),
        // --- @property (copy) block setter → stored (override) ---
        class_with(
            "CopySetter",
            vec![
                // Would classify async via "completion"/"handler"; the copy
                // block property forces stored.
                block_setter("completionHandler"),
            ],
            vec![property("completionHandler", block_ty(), true)],
        ),
        // --- copy-setter negatives ---
        class_with(
            "CopySetterNegatives",
            vec![
                // Non-copy block property → not stored (falls to "handler").
                block_setter("handler"),
                // Two-arg "setter" → not a synthesised setter → falls to token.
                method(
                    "setHandler:withOptions:",
                    vec![block_param("handler"), param("options", id_ty())],
                ),
                // Setter targeting a different property name than the copy block
                // property → no match (falls to "callback").
                method("setCallback:", vec![block_param("callback")]),
            ],
            vec![
                property("handler", block_ty(), false),
                property("storedBlock", block_ty(), true),
            ],
        ),
        // --- copy attribute on a NON-block property must not pull the block
        //     setter into stored (name matches but type is not a block) ---
        class_with(
            "CopyNonBlock",
            vec![block_setter("title")],
            vec![property("title", id_ty(), true)],
        ),
        // --- class (not instance) copy block property must NOT match ---
        class_with(
            "ClassProp",
            vec![block_setter("handler")],
            vec![class_property("handler", block_ty(), true)],
        ),
    ];

    // A protocol may declare a `@property (copy)` block property; its setter
    // requirement must classify as stored exactly like a class's.
    let protocols = vec![
        protocol_with(
            "MyHandling",
            vec![block_setter("completionHandler")],
            vec![property("completionHandler", block_ty(), true)],
        ),
        protocol_with(
            "MyIterating",
            vec![method(
                "enumerateItemsUsingBlock:",
                vec![block_param("block")],
            )],
            vec![],
        ),
    ];

    assert_equivalent(&framework("Synthetic", classes, protocols), "synthetic");
}

#[test]
fn category_block_methods_are_classified() {
    // A category block method must be classified exactly as a direct method.
    let mut c = class("NSArray", vec![]);
    c.category_methods
        .push(apianyware_types::ir::CategoryGroup {
            category: "Sorting".to_string(),
            origin_framework: "CatFW".to_string(),
            methods: vec![method(
                "sortedArrayUsingComparator:",
                vec![block_param("cmptr")],
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
fn real_ir_blocks_match_heuristics() {
    let mut ran = false;
    for name in ["Foundation", "AppKit"] {
        if let Some(fw) = load_resolved(name) {
            assert_equivalent(&fw, name);
            ran = true;
        }
    }
    if !ran {
        eprintln!(
            "skipping real-IR block equivalence: no resolved.json under {} \
             (gitignored — regenerate the pipeline to exercise this)",
            api_root().display()
        );
    }
}

// ---------------------------------------------------------------------------
// Provenance stamp shape (ADR-0046 §4)
// ---------------------------------------------------------------------------

#[test]
fn derived_block_facts_carry_convention_rule_stamp() {
    let fw = framework(
        "P",
        vec![class_with(
            "X",
            vec![
                method("enumerateObjectsUsingBlock:", vec![block_param("block")]),
                method("fooWithCompletion:", vec![block_param("block")]),
                block_setter("completionHandler"),
            ],
            vec![property("completionHandler", block_ty(), true)],
        )],
        vec![],
    );

    let facets = derive_block_invocations(std::slice::from_ref(&fw));

    let sync = &facets[&("X".to_string(), "enumerateObjectsUsingBlock:".to_string())];
    assert_eq!(sync.provenance[&0], vec!["convention:block-sync"]);

    let async_token = &facets[&("X".to_string(), "fooWithCompletion:".to_string())];
    assert_eq!(
        async_token.provenance[&0],
        vec!["convention:block-async-token"]
    );

    let stored = &facets[&("X".to_string(), "setCompletionHandler:".to_string())];
    assert_eq!(
        stored.provenance[&0],
        vec!["convention:block-copy-property-setter"]
    );

    // Every stamp is a single well-formed `convention:<rule>` (one rule wins).
    for facet in facets.values() {
        for stamps in facet.provenance.values() {
            assert_eq!(stamps.len(), 1, "exactly one winning rule per block param");
            let stamp = &stamps[0];
            assert!(
                stamp.starts_with("convention:") && stamp.len() > "convention:".len(),
                "malformed provenance stamp: {stamp}"
            );
        }
    }
}
