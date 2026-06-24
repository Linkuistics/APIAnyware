//! Characterization test (the goldens-as-truth equivalence gate, ADR-0047).
//!
//! Asserts the `ConventionProgram`'s error-pattern facet reproduces the legacy
//! imperative `heuristics.rs` `error_pattern` output **exactly** — over
//! synthetic fixtures covering the trailing `NSError**` signal (exact-`error`
//! name, `…Error`/`…error` suffix), its negatives (a named-`error` non-pointer,
//! a pointer `error` that is not the last param, a non-error last param, and an
//! `error`-substring-but-not-suffix name), the receiver-kind-agnostic protocol
//! case, and the real committed IR corpus (Foundation + AppKit) when present.
//! AppKit's enrich reported `error_methods=72`, so the real corpus is a strong
//! proof.
//!
//! Sibling to `threading_equivalence.rs`. Error-pattern is a **method-level**
//! facet whose only derived value is `ErrorOutParam` (the heuristic never emits
//! `ThrowsException` / `NilOnFailure`), so the comparison grain is the **set** of
//! `(receiver, selector)` methods classified `ErrorOutParam`.

use std::collections::BTreeSet;
use std::path::PathBuf;

use apianyware_annotate::heuristics::{
    annotate_method_heuristic, annotate_protocol_method_heuristic,
};
use apianyware_conventions::derive_error_pattern;
use apianyware_types::annotation::ErrorPattern;
use apianyware_types::ir::{Class, Framework, Method, Param, Protocol};
use apianyware_types::type_ref::{TypeRef, TypeRefKind};

// ---------------------------------------------------------------------------
// Normalized comparison form — the set of error-out-param methods
// ---------------------------------------------------------------------------

type ErrorOutParamSet = BTreeSet<(String, String)>;

/// The legacy expected set: run `heuristics.rs` over the same method set the
/// annotate step classifies, keeping only methods whose error pattern is
/// `ErrorOutParam`.
fn legacy_error_out_params(fw: &Framework) -> ErrorOutParamSet {
    let mut set = ErrorOutParamSet::new();

    let mut insert = |receiver: &str, selector: &str, error: Option<ErrorPattern>| {
        if error == Some(ErrorPattern::ErrorOutParam) {
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
            insert(&class.name, &method.selector, ann.error_pattern);
        }
        for group in &class.category_methods {
            for method in &group.methods {
                let ann = annotate_method_heuristic(class, method);
                insert(&class.name, &method.selector, ann.error_pattern);
            }
        }
    }

    for proto in &fw.protocols {
        for method in proto.required_methods.iter().chain(&proto.optional_methods) {
            let ann = annotate_protocol_method_heuristic(proto, method);
            insert(&proto.name, &method.selector, ann.error_pattern);
        }
    }

    set
}

/// The new set: the convention program's error-pattern facet keys (every method
/// the rules classified `ErrorOutParam`).
fn rules_error_out_params(fw: &Framework) -> ErrorOutParamSet {
    derive_error_pattern(std::slice::from_ref(fw))
        .into_keys()
        .collect()
}

fn assert_equivalent(fw: &Framework, label: &str) {
    let legacy = legacy_error_out_params(fw);
    let rules = rules_error_out_params(fw);
    // Surface the symmetric difference for a legible failure.
    let only_legacy: Vec<_> = legacy.difference(&rules).take(20).collect();
    let only_rules: Vec<_> = rules.difference(&legacy).take(20).collect();
    assert_eq!(
        legacy, rules,
        "[{label}] convention rules diverge from heuristics.rs error-pattern classification\n  \
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

/// A generic ObjC object param (`id`) — the non-pointer foil for the gate.
fn id_param(name: &str) -> Param {
    param(name, ty(TypeRefKind::Id))
}

/// A raw-pointer param — the `NSError**` shape the error gate keys on.
fn pointer_param(name: &str) -> Param {
    param(name, ty(TypeRefKind::Pointer))
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

// ---------------------------------------------------------------------------
// Synthetic coverage — the error signal + every negative
// ---------------------------------------------------------------------------

#[test]
fn synthetic_error_pattern_cases_match_heuristics() {
    let classes = vec![
        // --- Positive: last param named exactly "error" + Pointer ---
        class(
            "NSFileManager",
            vec![method(
                "contentsOfDirectoryAtPath:error:",
                vec![id_param("path"), pointer_param("error")],
            )],
        ),
        // --- Positive: `…Error` suffix + Pointer (case-insensitive ends_with) ---
        class(
            "Parser",
            vec![
                method(
                    "parseWithOptions:outError:",
                    vec![id_param("options"), pointer_param("outError")],
                ),
                // Capitalized exact "Error" → lowercases to "error" → matches.
                method(
                    "loadResource:Error:",
                    vec![id_param("resource"), pointer_param("Error")],
                ),
            ],
        ),
        // --- Negative: named error-ishly but NOT a pointer (id type) ---
        class(
            "Validator",
            vec![method(
                "validateValue:error:",
                vec![id_param("value"), id_param("error")],
            )],
        ),
        // --- Negative: a Pointer named "error" that is NOT the last param ---
        class(
            "Ordering",
            vec![method(
                "error:then:",
                vec![pointer_param("error"), id_param("completion")],
            )],
        ),
        // --- Negative: trailing Pointer not named error-ishly ---
        class(
            "Buffer",
            vec![method(
                "writeBytes:into:",
                vec![id_param("bytes"), pointer_param("into")],
            )],
        ),
        // --- Negative: "errorHandler" — substring, not suffix → no match ---
        class(
            "Setup",
            vec![method(
                "setErrorHandler:",
                vec![pointer_param("errorHandler")],
            )],
        ),
        // --- A no-signal class: a zero-param and a plain method ---
        class(
            "NSString",
            vec![
                method("length", vec![]),
                method("substringFromIndex:", vec![id_param("index")]),
            ],
        ),
    ];

    let protocols = vec![
        // Receiver-kind-agnostic: a protocol method with a trailing NSError**
        // out-param classifies identically to a class method (mirrors the legacy
        // `protocol_method_heuristic_detects_error_outparam` test).
        protocol(
            "NSValidating",
            vec![
                method(
                    "validateValue:error:",
                    vec![id_param("value"), pointer_param("error")],
                ),
                method("describe", vec![]),
            ],
        ),
    ];

    assert_equivalent(&framework("Synthetic", classes, protocols), "synthetic");
}

#[test]
fn category_methods_classified_like_direct_methods() {
    // A category method with a trailing NSError** out-param is classified exactly
    // as a direct method (the loader enumerates category methods too).
    let mut c = class("NSData", vec![method("length", vec![])]);
    c.category_methods
        .push(apianyware_types::ir::CategoryGroup {
            category: "Writing".to_string(),
            origin_framework: "CatFW".to_string(),
            methods: vec![method(
                "writeToURL:error:",
                vec![id_param("url"), pointer_param("error")],
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
fn real_ir_error_pattern_matches_heuristics() {
    let mut ran = false;
    for name in ["Foundation", "AppKit"] {
        if let Some(fw) = load_resolved(name) {
            assert_equivalent(&fw, name);
            ran = true;
        }
    }
    if !ran {
        eprintln!(
            "skipping real-IR error-pattern equivalence: no resolved.json under {} \
             (gitignored — regenerate the pipeline to exercise this)",
            api_root().display()
        );
    }
}

// ---------------------------------------------------------------------------
// Provenance stamp shape (ADR-0046 §4)
// ---------------------------------------------------------------------------

#[test]
fn derived_error_facts_carry_convention_rule_stamps() {
    let fw = framework(
        "P",
        vec![class(
            "NSFileManager",
            vec![method(
                "removeItemAtPath:error:",
                vec![id_param("path"), pointer_param("error")],
            )],
        )],
        vec![],
    );

    let facets = derive_error_pattern(std::slice::from_ref(&fw));

    let facet = &facets[&(
        "NSFileManager".to_string(),
        "removeItemAtPath:error:".to_string(),
    )];
    assert_eq!(facet.error_pattern, ErrorPattern::ErrorOutParam);
    assert_eq!(facet.provenance, vec!["convention:error-out-param"]);

    // Every present facet is `ErrorOutParam` with exactly one well-formed stamp.
    for facet in facets.values() {
        assert_eq!(facet.error_pattern, ErrorPattern::ErrorOutParam);
        assert_eq!(
            facet.provenance,
            vec!["convention:error-out-param"],
            "the single error rule stamps exactly one convention"
        );
    }
}
