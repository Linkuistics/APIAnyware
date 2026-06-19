//! Integration tests for the enrichment Datalog program.
//!
//! Tests derive enrichment relations from synthetic and real framework data.

use apianyware_macos_types::annotation::{
    AnnotationSource, BlockInvocationStyle, BlockParamAnnotation, ClassAnnotations, ErrorPattern,
    MethodAnnotation, PatternStereotype, ThreadingConstraint,
};
use apianyware_macos_types::enrichment::EnrichmentData;
use apianyware_macos_types::ir::{Class, Method, Param, Property, Protocol};
use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};
use apianyware_macos_types::Framework;

fn make_method(selector: &str, params: Vec<Param>, return_kind: TypeRefKind) -> Method {
    Method {
        selector: selector.to_string(),
        class_method: false,
        init_method: selector.starts_with("init"),
        params,
        return_type: TypeRef {
            nullable: false,
            kind: return_kind,
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

fn block_param(name: &str) -> Param {
    Param {
        name: name.to_string(),
        param_type: TypeRef {
            nullable: false,
            kind: TypeRefKind::Block {
                params: vec![],
                return_type: Box::new(TypeRef::void()),
            },
        },
    }
}

fn empty_framework() -> Framework {
    Framework {
        format_version: "1.0".to_string(),
        checkpoint: "annotated".to_string(),
        name: "TestKit".to_string(),
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

fn enrich(
    fw: &Framework,
) -> (
    EnrichmentData,
    apianyware_macos_types::enrichment::VerificationReport,
) {
    let enriched =
        apianyware_macos_enrich::enrich_loaded_frameworks(std::slice::from_ref(fw)).unwrap();
    let e = enriched[0].enrichment.clone().unwrap();
    let v = enriched[0].verification.clone().unwrap();
    (e, v)
}

// -----------------------------------------------------------------------
// Block classification tests
// -----------------------------------------------------------------------

#[test]
fn sync_block_method_derived() {
    let mut fw = empty_framework();
    fw.classes = vec![Class {
        name: "NSArray".to_string(),
        superclass: "NSObject".to_string(),
        protocols: vec![],
        properties: vec![],
        methods: vec![make_method(
            "enumerateObjectsUsingBlock:",
            vec![block_param("block")],
            TypeRefKind::Primitive {
                name: "void".to_string(),
            },
        )],
        category_methods: vec![],
        swift_attributes: vec![],
        ancestors: vec![],
        all_methods: vec![],
        all_properties: vec![],
        objc_exposed: true,
    }];
    fw.class_annotations = vec![ClassAnnotations {
        class_name: "NSArray".to_string(),
        methods: vec![MethodAnnotation {
            selector: "enumerateObjectsUsingBlock:".to_string(),
            is_instance: true,
            parameter_ownership: vec![],
            block_parameters: vec![BlockParamAnnotation {
                param_index: 0,
                invocation: BlockInvocationStyle::Synchronous,
            }],
            threading: None,
            error_pattern: None,
            source: AnnotationSource::Heuristic,
        }],
    }];

    let (e, v) = enrich(&fw);
    assert_eq!(e.sync_block_methods.len(), 1);
    assert_eq!(
        e.sync_block_methods[0].selector,
        "enumerateObjectsUsingBlock:"
    );
    assert!(v.passed);
}

#[test]
fn async_and_stored_block_methods() {
    let mut fw = empty_framework();
    fw.classes = vec![Class {
        name: "NSOperation".to_string(),
        superclass: String::new(),
        protocols: vec![],
        properties: vec![],
        methods: vec![
            make_method(
                "setCompletionBlock:",
                vec![block_param("block")],
                TypeRefKind::Primitive {
                    name: "void".to_string(),
                },
            ),
            make_method(
                "addObserver:",
                vec![block_param("observer")],
                TypeRefKind::Primitive {
                    name: "void".to_string(),
                },
            ),
        ],
        category_methods: vec![],
        swift_attributes: vec![],
        ancestors: vec![],
        all_methods: vec![],
        all_properties: vec![],
        objc_exposed: true,
    }];
    fw.class_annotations = vec![ClassAnnotations {
        class_name: "NSOperation".to_string(),
        methods: vec![
            MethodAnnotation {
                selector: "setCompletionBlock:".to_string(),
                is_instance: true,
                parameter_ownership: vec![],
                block_parameters: vec![BlockParamAnnotation {
                    param_index: 0,
                    invocation: BlockInvocationStyle::AsyncCopied,
                }],
                threading: None,
                error_pattern: None,
                source: AnnotationSource::Heuristic,
            },
            MethodAnnotation {
                selector: "addObserver:".to_string(),
                is_instance: true,
                parameter_ownership: vec![],
                block_parameters: vec![BlockParamAnnotation {
                    param_index: 0,
                    invocation: BlockInvocationStyle::Stored,
                }],
                threading: None,
                error_pattern: None,
                source: AnnotationSource::Heuristic,
            },
        ],
    }];

    let (e, _) = enrich(&fw);
    assert_eq!(e.async_block_methods.len(), 1);
    assert_eq!(e.stored_block_methods.len(), 1);
    assert_eq!(e.async_block_methods[0].selector, "setCompletionBlock:");
    assert_eq!(e.stored_block_methods[0].selector, "addObserver:");
}

// -----------------------------------------------------------------------
// Main thread class tests
// -----------------------------------------------------------------------

#[test]
fn main_thread_class_derived_from_threading_annotation() {
    let mut fw = empty_framework();
    fw.classes = vec![Class {
        name: "NSView".to_string(),
        superclass: String::new(),
        protocols: vec![],
        properties: vec![],
        methods: vec![make_method(
            "setNeedsDisplay:",
            vec![],
            TypeRefKind::Primitive {
                name: "void".to_string(),
            },
        )],
        category_methods: vec![],
        swift_attributes: vec![],
        ancestors: vec![],
        all_methods: vec![],
        all_properties: vec![],
        objc_exposed: true,
    }];
    fw.class_annotations = vec![ClassAnnotations {
        class_name: "NSView".to_string(),
        methods: vec![MethodAnnotation {
            selector: "setNeedsDisplay:".to_string(),
            is_instance: true,
            parameter_ownership: vec![],
            block_parameters: vec![],
            threading: Some(ThreadingConstraint::MainThreadOnly),
            error_pattern: None,
            source: AnnotationSource::Heuristic,
        }],
    }];

    let (e, _) = enrich(&fw);
    assert_eq!(e.main_thread_classes, vec!["NSView".to_string()]);
}

// -----------------------------------------------------------------------
// Convenience error method tests
// -----------------------------------------------------------------------

#[test]
fn convenience_error_method_derived() {
    let mut fw = empty_framework();
    fw.classes = vec![Class {
        name: "NSFileManager".to_string(),
        superclass: String::new(),
        protocols: vec![],
        properties: vec![],
        methods: vec![make_method(
            "contentsOfDirectoryAtPath:error:",
            vec![],
            TypeRefKind::Id,
        )],
        category_methods: vec![],
        swift_attributes: vec![],
        ancestors: vec![],
        all_methods: vec![],
        all_properties: vec![],
        objc_exposed: true,
    }];
    fw.class_annotations = vec![ClassAnnotations {
        class_name: "NSFileManager".to_string(),
        methods: vec![MethodAnnotation {
            selector: "contentsOfDirectoryAtPath:error:".to_string(),
            is_instance: true,
            parameter_ownership: vec![],
            block_parameters: vec![],
            threading: None,
            error_pattern: Some(ErrorPattern::ErrorOutParam),
            source: AnnotationSource::Heuristic,
        }],
    }];

    let (e, _) = enrich(&fw);
    assert_eq!(e.convenience_error_methods.len(), 1);
    assert_eq!(
        e.convenience_error_methods[0].selector,
        "contentsOfDirectoryAtPath:error:"
    );
}

// -----------------------------------------------------------------------
// Collection iterable tests
// -----------------------------------------------------------------------

#[test]
fn collection_iterable_from_count_and_object_at_index() {
    let mut fw = empty_framework();
    fw.classes = vec![Class {
        name: "NSArray".to_string(),
        superclass: String::new(),
        protocols: vec![],
        properties: vec![Property {
            name: "count".to_string(),
            property_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "NSUInteger".to_string(),
                },
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
        }],
        methods: vec![make_method("objectAtIndex:", vec![], TypeRefKind::Id)],
        category_methods: vec![],
        swift_attributes: vec![],
        ancestors: vec![],
        all_methods: vec![],
        all_properties: vec![],
        objc_exposed: true,
    }];

    let (e, _) = enrich(&fw);
    assert!(e.collection_iterables.contains(&"NSArray".to_string()));
}

#[test]
fn collection_iterable_from_fast_enumeration() {
    let mut fw = empty_framework();
    fw.classes = vec![Class {
        name: "NSSet".to_string(),
        superclass: String::new(),
        protocols: vec!["NSFastEnumeration".to_string()],
        properties: vec![],
        methods: vec![],
        category_methods: vec![],
        swift_attributes: vec![],
        ancestors: vec![],
        all_methods: vec![],
        all_properties: vec![],
        objc_exposed: true,
    }];

    let (e, _) = enrich(&fw);
    assert!(e.collection_iterables.contains(&"NSSet".to_string()));
}

// -----------------------------------------------------------------------
// Delegate protocol tests
// -----------------------------------------------------------------------

#[test]
fn delegate_protocol_detected_from_set_delegate() {
    let mut fw = empty_framework();
    fw.classes = vec![Class {
        name: "NSWindow".to_string(),
        superclass: String::new(),
        protocols: vec!["NSWindowDelegate".to_string()],
        properties: vec![],
        methods: vec![make_method(
            "setDelegate:",
            vec![],
            TypeRefKind::Primitive {
                name: "void".to_string(),
            },
        )],
        category_methods: vec![],
        swift_attributes: vec![],
        ancestors: vec![],
        all_methods: vec![],
        all_properties: vec![],
        objc_exposed: true,
    }];
    fw.protocols = vec![Protocol {
        name: "NSWindowDelegate".to_string(),
        inherits: vec![],
        required_methods: vec![],
        optional_methods: vec![make_method(
            "windowDidResize:",
            vec![],
            TypeRefKind::Primitive {
                name: "void".to_string(),
            },
        )],
        properties: vec![],
        source: None,
        provenance: None,
        doc_refs: None,
        objc_exposed: true,
    }];

    let (e, _) = enrich(&fw);
    assert!(e
        .delegate_protocols
        .contains(&"NSWindowDelegate".to_string()));
}

// -----------------------------------------------------------------------
// Verification tests
// -----------------------------------------------------------------------

#[test]
fn unclassified_block_violation() {
    let mut fw = empty_framework();
    fw.classes = vec![Class {
        name: "MyClass".to_string(),
        superclass: String::new(),
        protocols: vec![],
        properties: vec![],
        methods: vec![make_method(
            "doWork:",
            vec![block_param("handler")],
            TypeRefKind::Primitive {
                name: "void".to_string(),
            },
        )],
        category_methods: vec![],
        swift_attributes: vec![],
        ancestors: vec![],
        all_methods: vec![],
        all_properties: vec![],
        objc_exposed: true,
    }];
    // No annotations — block param is unclassified

    let (_, v) = enrich(&fw);
    assert!(!v.passed);
    assert_eq!(v.violations.len(), 1);
    assert_eq!(v.violations[0].rule, "unclassified_block");
    assert_eq!(v.violations[0].class, "MyClass");
    assert_eq!(v.violations[0].selector, "doWork:");
    assert_eq!(v.violations[0].param_index, Some(0));
}

#[test]
fn classified_block_no_violation() {
    let mut fw = empty_framework();
    fw.classes = vec![Class {
        name: "MyClass".to_string(),
        superclass: String::new(),
        protocols: vec![],
        properties: vec![],
        methods: vec![make_method(
            "doWork:",
            vec![block_param("handler")],
            TypeRefKind::Primitive {
                name: "void".to_string(),
            },
        )],
        category_methods: vec![],
        swift_attributes: vec![],
        ancestors: vec![],
        all_methods: vec![],
        all_properties: vec![],
        objc_exposed: true,
    }];
    fw.class_annotations = vec![ClassAnnotations {
        class_name: "MyClass".to_string(),
        methods: vec![MethodAnnotation {
            selector: "doWork:".to_string(),
            is_instance: true,
            parameter_ownership: vec![],
            block_parameters: vec![BlockParamAnnotation {
                param_index: 0,
                invocation: BlockInvocationStyle::AsyncCopied,
            }],
            threading: None,
            error_pattern: None,
            source: AnnotationSource::Heuristic,
        }],
    }];

    let (_, v) = enrich(&fw);
    assert!(v.passed);
}

// -----------------------------------------------------------------------
// Scoped resource tests (from api_patterns)
// -----------------------------------------------------------------------

#[test]
fn scoped_resource_from_paired_state_pattern() {
    let mut fw = empty_framework();
    fw.api_patterns = vec![apianyware_macos_types::annotation::ApiPattern {
        stereotype: PatternStereotype::PairedState,
        name: "NSLock critical section".to_string(),
        participants: serde_json::json!({
            "lock": { "class": "NSLock", "selector": "lock" },
            "unlock": { "class": "NSLock", "selector": "unlock" }
        }),
        constraints: vec![],
        source: AnnotationSource::Heuristic,
        doc_ref: None,
    }];

    let (e, _) = enrich(&fw);
    assert_eq!(e.scoped_resources.len(), 1);
    assert_eq!(e.scoped_resources[0].class, "NSLock");
    assert_eq!(e.scoped_resources[0].open_selector, "lock");
    assert_eq!(e.scoped_resources[0].close_selector, "unlock");
}

// -----------------------------------------------------------------------
// Foundation integration test
// -----------------------------------------------------------------------

#[test]
fn foundation_enrichment_integration() {
    let annotated_dir = std::path::PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("..")
        .join("..")
        .join("..")
        .join("analysis")
        .join("ir")
        .join("annotated");

    if !annotated_dir.join("Foundation.json").exists() {
        eprintln!(
            "skipping: no Foundation.json at {}",
            annotated_dir.display()
        );
        return;
    }

    let fw = apianyware_macos_datalog::loading::load_framework_from_file(
        &annotated_dir.join("Foundation.json"),
    )
    .unwrap();

    let enriched = apianyware_macos_enrich::enrich_loaded_frameworks(&[fw]).unwrap();
    assert_eq!(enriched.len(), 1);

    let e = enriched[0].enrichment.as_ref().unwrap();
    let v = enriched[0].verification.as_ref().unwrap();

    // Enrichment relations should be populated
    assert!(
        e.sync_block_methods.len() > 50,
        "expected >50 sync blocks, got {}",
        e.sync_block_methods.len()
    );
    assert!(
        e.async_block_methods.len() > 50,
        "expected >50 async blocks, got {}",
        e.async_block_methods.len()
    );
    assert!(
        e.convenience_error_methods.len() > 100,
        "expected >100 error methods, got {}",
        e.convenience_error_methods.len()
    );
    assert!(
        e.collection_iterables.len() >= 5,
        "expected >=5 iterables, got {}",
        e.collection_iterables.len()
    );
    assert!(
        e.scoped_resources.len() >= 3,
        "expected >=3 scoped resources, got {}",
        e.scoped_resources.len()
    );

    // Verification should pass
    assert!(
        v.passed,
        "verification should pass, violations: {:?}",
        v.violations
    );

    // Checkpoint should be enriched
    assert_eq!(enriched[0].checkpoint, "enriched");
}

// -----------------------------------------------------------------------
// Multi-framework isolation tests
// -----------------------------------------------------------------------

#[test]
fn verification_violations_are_per_framework_not_global() {
    // FW_A has an unclassified block → should have a violation
    let mut fw_a = empty_framework();
    fw_a.name = "FrameworkA".to_string();
    fw_a.classes = vec![Class {
        name: "ClassA".to_string(),
        superclass: String::new(),
        protocols: vec![],
        properties: vec![],
        methods: vec![make_method(
            "doWork:",
            vec![block_param("handler")],
            TypeRefKind::Primitive {
                name: "void".to_string(),
            },
        )],
        category_methods: vec![],
        swift_attributes: vec![],
        ancestors: vec![],
        all_methods: vec![],
        all_properties: vec![],
        objc_exposed: true,
    }];
    // No annotations — block param is unclassified

    // FW_B has no blocks → should pass verification
    let mut fw_b = empty_framework();
    fw_b.name = "FrameworkB".to_string();
    fw_b.classes = vec![Class {
        name: "ClassB".to_string(),
        superclass: String::new(),
        protocols: vec![],
        properties: vec![],
        methods: vec![make_method(
            "simpleMethod",
            vec![],
            TypeRefKind::Primitive {
                name: "void".to_string(),
            },
        )],
        category_methods: vec![],
        swift_attributes: vec![],
        ancestors: vec![],
        all_methods: vec![],
        all_properties: vec![],
        objc_exposed: true,
    }];

    let enriched = apianyware_macos_enrich::enrich_loaded_frameworks(&[fw_a, fw_b]).unwrap();
    assert_eq!(enriched.len(), 2);

    let v_a = enriched[0].verification.as_ref().unwrap();
    let v_b = enriched[1].verification.as_ref().unwrap();

    // FW_A should have the violation
    assert!(!v_a.passed, "FrameworkA should have violations");
    assert_eq!(v_a.violations.len(), 1);
    assert_eq!(v_a.violations[0].class, "ClassA");

    // FW_B should NOT have FW_A's violation
    assert!(
        v_b.passed,
        "FrameworkB should pass verification, but got violations: {:?}",
        v_b.violations
    );
    assert!(
        v_b.violations.is_empty(),
        "FrameworkB should have no violations"
    );
}

#[test]
fn enrichment_data_is_per_framework_not_global() {
    // FW_A has a main-thread class
    let mut fw_a = empty_framework();
    fw_a.name = "FrameworkA".to_string();
    fw_a.classes = vec![Class {
        name: "ViewA".to_string(),
        superclass: String::new(),
        protocols: vec![],
        properties: vec![],
        methods: vec![make_method(
            "draw",
            vec![],
            TypeRefKind::Primitive {
                name: "void".to_string(),
            },
        )],
        category_methods: vec![],
        swift_attributes: vec![],
        ancestors: vec![],
        all_methods: vec![],
        all_properties: vec![],
        objc_exposed: true,
    }];
    fw_a.class_annotations = vec![ClassAnnotations {
        class_name: "ViewA".to_string(),
        methods: vec![MethodAnnotation {
            selector: "draw".to_string(),
            is_instance: true,
            parameter_ownership: vec![],
            block_parameters: vec![],
            threading: Some(ThreadingConstraint::MainThreadOnly),
            error_pattern: None,
            source: AnnotationSource::Heuristic,
        }],
    }];

    // FW_B has no threading constraints
    let mut fw_b = empty_framework();
    fw_b.name = "FrameworkB".to_string();
    fw_b.classes = vec![Class {
        name: "UtilB".to_string(),
        superclass: String::new(),
        protocols: vec![],
        properties: vec![],
        methods: vec![make_method(
            "compute",
            vec![],
            TypeRefKind::Primitive {
                name: "void".to_string(),
            },
        )],
        category_methods: vec![],
        swift_attributes: vec![],
        ancestors: vec![],
        all_methods: vec![],
        all_properties: vec![],
        objc_exposed: true,
    }];

    let enriched = apianyware_macos_enrich::enrich_loaded_frameworks(&[fw_a, fw_b]).unwrap();

    let e_a = enriched[0].enrichment.as_ref().unwrap();
    let e_b = enriched[1].enrichment.as_ref().unwrap();

    // FW_A should have its main-thread class
    assert_eq!(e_a.main_thread_classes, vec!["ViewA".to_string()]);

    // FW_B should NOT have FW_A's main-thread class
    assert!(
        e_b.main_thread_classes.is_empty(),
        "FrameworkB should have no main-thread classes, but got: {:?}",
        e_b.main_thread_classes
    );
}

// -----------------------------------------------------------------------
// Multi-framework: cross-framework delegate protocol attribution
// -----------------------------------------------------------------------

/// Delegate protocol detection relies on a class having `setDelegate:` and
/// conforming to a protocol ending in "Delegate". When the class is in FW_A
/// but the protocol is declared in FW_B, the delegate_protocol relation should
/// be attributed to FW_B (where the protocol is declared), not FW_A.
#[test]
fn cross_framework_delegate_protocol_attributed_to_protocol_framework() {
    // FW_A: class with setDelegate: that conforms to FW_B's protocol
    let mut fw_a = empty_framework();
    fw_a.name = "AppKit".to_string();
    fw_a.classes = vec![Class {
        name: "NSTableView".to_string(),
        superclass: "NSView".to_string(),
        protocols: vec!["NSTableViewDelegate".to_string()],
        properties: vec![],
        methods: vec![make_method(
            "setDelegate:",
            vec![],
            TypeRefKind::Primitive {
                name: "void".to_string(),
            },
        )],
        category_methods: vec![],
        swift_attributes: vec![],
        ancestors: vec![],
        all_methods: vec![],
        all_properties: vec![],
        objc_exposed: true,
    }];
    // FW_A does NOT declare the protocol
    fw_a.protocols = vec![];

    // FW_B: declares the delegate protocol
    let mut fw_b = empty_framework();
    fw_b.name = "AppKitProtocols".to_string();
    fw_b.classes = vec![];
    fw_b.protocols = vec![Protocol {
        name: "NSTableViewDelegate".to_string(),
        inherits: vec![],
        required_methods: vec![],
        optional_methods: vec![make_method(
            "tableView:shouldSelectRow:",
            vec![],
            TypeRefKind::Primitive {
                name: "BOOL".to_string(),
            },
        )],
        properties: vec![],
        source: None,
        provenance: None,
        doc_refs: None,
        objc_exposed: true,
    }];

    let enriched = apianyware_macos_enrich::enrich_loaded_frameworks(&[fw_a, fw_b]).unwrap();

    let e_a = enriched[0].enrichment.as_ref().unwrap();
    let e_b = enriched[1].enrichment.as_ref().unwrap();

    // Protocol is attributed to FW_B (where it's declared)
    assert!(
        e_b.delegate_protocols
            .contains(&"NSTableViewDelegate".to_string()),
        "delegate protocol should appear in the framework that declares it, got: {:?}",
        e_b.delegate_protocols
    );

    // FW_A should NOT have the delegate protocol (it doesn't declare it)
    assert!(
        !e_a.delegate_protocols
            .contains(&"NSTableViewDelegate".to_string()),
        "delegate protocol should NOT appear in framework that only uses it, got: {:?}",
        e_a.delegate_protocols
    );
}

// -----------------------------------------------------------------------
// Multi-framework: block classification with mixed violations
// -----------------------------------------------------------------------

/// Both frameworks have block params. FW_A classifies its blocks; FW_B does not.
/// Violations should only appear in FW_B. This is more thorough than the existing
/// test because both frameworks contribute block facts to the global program.
#[test]
fn multi_framework_block_violations_scoped_correctly() {
    // FW_A: classified block (async)
    let mut fw_a = empty_framework();
    fw_a.name = "Foundation".to_string();
    fw_a.classes = vec![Class {
        name: "NSOperationQueue".to_string(),
        superclass: String::new(),
        protocols: vec![],
        properties: vec![],
        methods: vec![make_method(
            "addOperationWithBlock:",
            vec![block_param("block")],
            TypeRefKind::Primitive {
                name: "void".to_string(),
            },
        )],
        category_methods: vec![],
        swift_attributes: vec![],
        ancestors: vec![],
        all_methods: vec![],
        all_properties: vec![],
        objc_exposed: true,
    }];
    fw_a.class_annotations = vec![ClassAnnotations {
        class_name: "NSOperationQueue".to_string(),
        methods: vec![MethodAnnotation {
            selector: "addOperationWithBlock:".to_string(),
            is_instance: true,
            parameter_ownership: vec![],
            block_parameters: vec![BlockParamAnnotation {
                param_index: 0,
                invocation: BlockInvocationStyle::AsyncCopied,
            }],
            threading: None,
            error_pattern: None,
            source: AnnotationSource::Heuristic,
        }],
    }];

    // FW_B: unclassified block — should produce violation
    let mut fw_b = empty_framework();
    fw_b.name = "CoreAnimation".to_string();
    fw_b.classes = vec![Class {
        name: "CATransaction".to_string(),
        superclass: String::new(),
        protocols: vec![],
        properties: vec![],
        methods: vec![make_method(
            "setCompletionBlock:",
            vec![block_param("completion")],
            TypeRefKind::Primitive {
                name: "void".to_string(),
            },
        )],
        category_methods: vec![],
        swift_attributes: vec![],
        ancestors: vec![],
        all_methods: vec![],
        all_properties: vec![],
        objc_exposed: true,
    }];
    // No annotations → unclassified

    let enriched = apianyware_macos_enrich::enrich_loaded_frameworks(&[fw_a, fw_b]).unwrap();

    let v_a = enriched[0].verification.as_ref().unwrap();
    let v_b = enriched[1].verification.as_ref().unwrap();
    let e_a = enriched[0].enrichment.as_ref().unwrap();
    let e_b = enriched[1].enrichment.as_ref().unwrap();

    // FW_A should pass verification (its block is classified)
    assert!(
        v_a.passed,
        "Foundation should pass, got: {:?}",
        v_a.violations
    );
    assert_eq!(e_a.async_block_methods.len(), 1);
    assert_eq!(
        e_a.async_block_methods[0].selector,
        "addOperationWithBlock:"
    );

    // FW_B should fail verification (unclassified block)
    assert!(!v_b.passed, "CoreAnimation should have violations");
    assert_eq!(v_b.violations.len(), 1);
    assert_eq!(v_b.violations[0].class, "CATransaction");
    assert_eq!(v_b.violations[0].selector, "setCompletionBlock:");

    // FW_B should have no enrichment block methods (none classified)
    assert!(e_b.sync_block_methods.is_empty());
    assert!(e_b.async_block_methods.is_empty());
    assert!(e_b.stored_block_methods.is_empty());
}

// -----------------------------------------------------------------------
// Multi-framework: collection iterable isolation
// -----------------------------------------------------------------------

/// Two frameworks with different iterable patterns: FW_A uses NSFastEnumeration
/// conformance, FW_B uses count+objectAtIndex:. Each should only see its own.
#[test]
fn cross_framework_collection_iterables_isolated() {
    // FW_A: iterable via NSFastEnumeration
    let mut fw_a = empty_framework();
    fw_a.name = "Foundation".to_string();
    fw_a.classes = vec![Class {
        name: "NSSet".to_string(),
        superclass: String::new(),
        protocols: vec!["NSFastEnumeration".to_string()],
        properties: vec![],
        methods: vec![],
        category_methods: vec![],
        swift_attributes: vec![],
        ancestors: vec![],
        all_methods: vec![],
        all_properties: vec![],
        objc_exposed: true,
    }];

    // FW_B: iterable via count + objectAtIndex:
    let mut fw_b = empty_framework();
    fw_b.name = "UIKit".to_string();
    fw_b.classes = vec![Class {
        name: "UICollectionView".to_string(),
        superclass: String::new(),
        protocols: vec![],
        properties: vec![Property {
            name: "count".to_string(),
            property_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "NSUInteger".to_string(),
                },
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
        }],
        methods: vec![make_method("objectAtIndex:", vec![], TypeRefKind::Id)],
        category_methods: vec![],
        swift_attributes: vec![],
        ancestors: vec![],
        all_methods: vec![],
        all_properties: vec![],
        objc_exposed: true,
    }];

    let enriched = apianyware_macos_enrich::enrich_loaded_frameworks(&[fw_a, fw_b]).unwrap();

    let e_a = enriched[0].enrichment.as_ref().unwrap();
    let e_b = enriched[1].enrichment.as_ref().unwrap();

    // FW_A: only NSSet
    assert_eq!(e_a.collection_iterables, vec!["NSSet".to_string()]);
    assert!(
        !e_a.collection_iterables
            .contains(&"UICollectionView".to_string()),
        "FW_A should not contain FW_B's iterable"
    );

    // FW_B: only UICollectionView
    assert_eq!(
        e_b.collection_iterables,
        vec!["UICollectionView".to_string()]
    );
    assert!(
        !e_b.collection_iterables.contains(&"NSSet".to_string()),
        "FW_B should not contain FW_A's iterable"
    );
}

// -----------------------------------------------------------------------
// Multi-framework: comprehensive isolation of all relation types
// -----------------------------------------------------------------------

/// Three frameworks, each with a different enrichment relation. Verifies that
/// all relation types are correctly scoped when enriched together.
#[test]
fn three_framework_comprehensive_enrichment_isolation() {
    // FW_A: error method + main thread class
    let mut fw_a = empty_framework();
    fw_a.name = "Foundation".to_string();
    fw_a.classes = vec![Class {
        name: "NSFileManager".to_string(),
        superclass: String::new(),
        protocols: vec![],
        properties: vec![],
        methods: vec![
            make_method("removeItemAtPath:error:", vec![], TypeRefKind::Id),
            make_method(
                "setUbiquitous:",
                vec![],
                TypeRefKind::Primitive {
                    name: "void".to_string(),
                },
            ),
        ],
        category_methods: vec![],
        swift_attributes: vec![],
        ancestors: vec![],
        all_methods: vec![],
        all_properties: vec![],
        objc_exposed: true,
    }];
    fw_a.class_annotations = vec![ClassAnnotations {
        class_name: "NSFileManager".to_string(),
        methods: vec![
            MethodAnnotation {
                selector: "removeItemAtPath:error:".to_string(),
                is_instance: true,
                parameter_ownership: vec![],
                block_parameters: vec![],
                threading: None,
                error_pattern: Some(ErrorPattern::ErrorOutParam),
                source: AnnotationSource::Heuristic,
            },
            MethodAnnotation {
                selector: "setUbiquitous:".to_string(),
                is_instance: true,
                parameter_ownership: vec![],
                block_parameters: vec![],
                threading: Some(ThreadingConstraint::MainThreadOnly),
                error_pattern: None,
                source: AnnotationSource::Heuristic,
            },
        ],
    }];

    // FW_B: sync block + stored block
    let mut fw_b = empty_framework();
    fw_b.name = "CoreData".to_string();
    fw_b.classes = vec![Class {
        name: "NSManagedObjectContext".to_string(),
        superclass: String::new(),
        protocols: vec![],
        properties: vec![],
        methods: vec![
            make_method(
                "performBlockAndWait:",
                vec![block_param("block")],
                TypeRefKind::Primitive {
                    name: "void".to_string(),
                },
            ),
            make_method(
                "setMergePolicy:",
                vec![block_param("policy")],
                TypeRefKind::Primitive {
                    name: "void".to_string(),
                },
            ),
        ],
        category_methods: vec![],
        swift_attributes: vec![],
        ancestors: vec![],
        all_methods: vec![],
        all_properties: vec![],
        objc_exposed: true,
    }];
    fw_b.class_annotations = vec![ClassAnnotations {
        class_name: "NSManagedObjectContext".to_string(),
        methods: vec![
            MethodAnnotation {
                selector: "performBlockAndWait:".to_string(),
                is_instance: true,
                parameter_ownership: vec![],
                block_parameters: vec![BlockParamAnnotation {
                    param_index: 0,
                    invocation: BlockInvocationStyle::Synchronous,
                }],
                threading: None,
                error_pattern: None,
                source: AnnotationSource::Heuristic,
            },
            MethodAnnotation {
                selector: "setMergePolicy:".to_string(),
                is_instance: true,
                parameter_ownership: vec![],
                block_parameters: vec![BlockParamAnnotation {
                    param_index: 0,
                    invocation: BlockInvocationStyle::Stored,
                }],
                threading: None,
                error_pattern: None,
                source: AnnotationSource::Heuristic,
            },
        ],
    }];

    // FW_C: collection iterable + scoped resource
    let mut fw_c = empty_framework();
    fw_c.name = "AppKit".to_string();
    fw_c.classes = vec![Class {
        name: "NSArrayController".to_string(),
        superclass: String::new(),
        protocols: vec!["NSFastEnumeration".to_string()],
        properties: vec![],
        methods: vec![],
        category_methods: vec![],
        swift_attributes: vec![],
        ancestors: vec![],
        all_methods: vec![],
        all_properties: vec![],
        objc_exposed: true,
    }];
    fw_c.api_patterns = vec![apianyware_macos_types::annotation::ApiPattern {
        stereotype: PatternStereotype::PairedState,
        name: "NSGraphicsContext save/restore".to_string(),
        participants: serde_json::json!({
            "open": { "class": "NSGraphicsContext", "selector": "saveGraphicsState" },
            "close": { "class": "NSGraphicsContext", "selector": "restoreGraphicsState" }
        }),
        constraints: vec![],
        source: AnnotationSource::Heuristic,
        doc_ref: None,
    }];

    let enriched = apianyware_macos_enrich::enrich_loaded_frameworks(&[fw_a, fw_b, fw_c]).unwrap();

    let e_a = enriched[0].enrichment.as_ref().unwrap();
    let e_b = enriched[1].enrichment.as_ref().unwrap();
    let e_c = enriched[2].enrichment.as_ref().unwrap();
    let v_a = enriched[0].verification.as_ref().unwrap();
    let v_b = enriched[1].verification.as_ref().unwrap();
    let v_c = enriched[2].verification.as_ref().unwrap();

    // FW_A: error method + main thread, nothing else
    assert_eq!(e_a.convenience_error_methods.len(), 1);
    assert_eq!(
        e_a.convenience_error_methods[0].selector,
        "removeItemAtPath:error:"
    );
    assert_eq!(e_a.main_thread_classes, vec!["NSFileManager".to_string()]);
    assert!(e_a.sync_block_methods.is_empty());
    assert!(e_a.stored_block_methods.is_empty());
    assert!(e_a.collection_iterables.is_empty());
    assert!(e_a.scoped_resources.is_empty());
    assert!(v_a.passed);

    // FW_B: sync + stored blocks, nothing else
    assert_eq!(e_b.sync_block_methods.len(), 1);
    assert_eq!(e_b.sync_block_methods[0].selector, "performBlockAndWait:");
    assert_eq!(e_b.stored_block_methods.len(), 1);
    assert_eq!(e_b.stored_block_methods[0].selector, "setMergePolicy:");
    assert!(e_b.convenience_error_methods.is_empty());
    assert!(e_b.main_thread_classes.is_empty());
    assert!(e_b.collection_iterables.is_empty());
    assert!(e_b.scoped_resources.is_empty());
    assert!(v_b.passed);

    // FW_C: iterable + scoped resource, nothing else
    assert_eq!(
        e_c.collection_iterables,
        vec!["NSArrayController".to_string()]
    );
    assert_eq!(e_c.scoped_resources.len(), 1);
    assert_eq!(e_c.scoped_resources[0].class, "NSGraphicsContext");
    assert_eq!(e_c.scoped_resources[0].open_selector, "saveGraphicsState");
    assert_eq!(
        e_c.scoped_resources[0].close_selector,
        "restoreGraphicsState"
    );
    assert!(e_c.sync_block_methods.is_empty());
    assert!(e_c.convenience_error_methods.is_empty());
    assert!(e_c.main_thread_classes.is_empty());
    assert!(v_c.passed);
}

// -----------------------------------------------------------------------
// Multi-framework: flag mismatch violation scoped to correct framework
// -----------------------------------------------------------------------

/// Returns-retained flag mismatch violations should only appear in the
/// framework whose class triggers the mismatch, not in sibling frameworks.
///
/// Uses "copy" family (retained for both instance and class methods per Cocoa
/// naming) with `returns_retained = Some(false)` to trigger the mismatch rule.
#[test]
fn flag_mismatch_violation_scoped_to_owning_framework() {
    // FW_A: instance method "copyItems" — naming says retained (copy family),
    // but resolve says NOT retained → mismatch
    let mut fw_a = empty_framework();
    fw_a.name = "ProblemFramework".to_string();
    fw_a.classes = vec![Class {
        name: "Factory".to_string(),
        superclass: String::new(),
        protocols: vec![],
        properties: vec![],
        methods: vec![{
            let mut m = make_method("copyItems", vec![], TypeRefKind::Id);
            // Resolve explicitly processed this method and says NOT retained,
            // but naming convention ("copy" family) says retained → mismatch
            m.returns_retained = Some(false);
            m
        }],
        category_methods: vec![],
        swift_attributes: vec![],
        ancestors: vec![],
        all_methods: vec![],
        all_properties: vec![],
        objc_exposed: true,
    }];

    // FW_B: clean framework with no issues
    let mut fw_b = empty_framework();
    fw_b.name = "CleanFramework".to_string();
    fw_b.classes = vec![Class {
        name: "Helper".to_string(),
        superclass: String::new(),
        protocols: vec![],
        properties: vec![],
        methods: vec![make_method(
            "doSomething",
            vec![],
            TypeRefKind::Primitive {
                name: "void".to_string(),
            },
        )],
        category_methods: vec![],
        swift_attributes: vec![],
        ancestors: vec![],
        all_methods: vec![],
        all_properties: vec![],
        objc_exposed: true,
    }];

    let enriched = apianyware_macos_enrich::enrich_loaded_frameworks(&[fw_a, fw_b]).unwrap();

    let v_a = enriched[0].verification.as_ref().unwrap();
    let v_b = enriched[1].verification.as_ref().unwrap();

    // FW_A should have the flag_mismatch violation
    assert!(!v_a.passed, "ProblemFramework should have violations");
    let mismatch_violations: Vec<_> = v_a
        .violations
        .iter()
        .filter(|v| v.rule == "flag_mismatch")
        .collect();
    assert!(
        !mismatch_violations.is_empty(),
        "ProblemFramework should have flag_mismatch violation, got: {:?}",
        v_a.violations
    );
    assert_eq!(mismatch_violations[0].class, "Factory");
    assert_eq!(mismatch_violations[0].selector, "copyItems");

    // FW_B should be clean
    assert!(
        v_b.passed,
        "CleanFramework should pass, got: {:?}",
        v_b.violations
    );
}
