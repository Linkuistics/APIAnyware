//! Tests: round-trip serialization/deserialization of annotation types.

use apianyware_types::annotation::{
    AnnotationOverride, AnnotationOverrides, AnnotationSource, ApiPattern, BlockInvocationStyle,
    BlockParamAnnotation, ClassAnnotations, ErrorPattern, FrameworkAnnotations, MethodAnnotation,
    OwnershipKind, ParamOwnership, PatternConstraint, PatternStereotype, SubagentReport,
    ThreadingConstraint,
};

#[test]
fn method_annotation_roundtrip() {
    let annotation = MethodAnnotation {
        selector: "enumerateObjectsUsingBlock:".to_string(),
        is_instance: true,
        parameter_ownership: vec![ParamOwnership {
            param_index: 0,
            ownership: OwnershipKind::Copy,
        }],
        block_parameters: vec![BlockParamAnnotation {
            param_index: 0,
            invocation: BlockInvocationStyle::Synchronous,
        }],
        threading: Some(ThreadingConstraint::AnyThread),
        error_pattern: None,
        source: AnnotationSource::Llm,
    };

    let json = serde_json::to_string_pretty(&annotation).unwrap();
    let deserialized: MethodAnnotation = serde_json::from_str(&json).unwrap();

    assert_eq!(deserialized.selector, "enumerateObjectsUsingBlock:");
    assert!(deserialized.is_instance);
    assert_eq!(deserialized.parameter_ownership.len(), 1);
    assert_eq!(
        deserialized.parameter_ownership[0].ownership,
        OwnershipKind::Copy
    );
    assert_eq!(deserialized.block_parameters.len(), 1);
    assert_eq!(
        deserialized.block_parameters[0].invocation,
        BlockInvocationStyle::Synchronous
    );
    assert_eq!(deserialized.threading, Some(ThreadingConstraint::AnyThread));
    assert_eq!(deserialized.error_pattern, None);
    assert_eq!(deserialized.source, AnnotationSource::Llm);
}

#[test]
fn framework_annotations_roundtrip() {
    let annotations = FrameworkAnnotations {
        framework: "Foundation".to_string(),
        classes: vec![ClassAnnotations {
            class_name: "NSArray".to_string(),
            methods: vec![
                MethodAnnotation {
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
                },
                MethodAnnotation {
                    selector: "writeToURL:error:".to_string(),
                    is_instance: true,
                    parameter_ownership: vec![],
                    block_parameters: vec![],
                    threading: None,
                    error_pattern: Some(ErrorPattern::ErrorOutParam),
                    source: AnnotationSource::Llm,
                },
            ],
        }],
        subagent_report: None,
    };

    let json = serde_json::to_string_pretty(&annotations).unwrap();
    let deserialized: FrameworkAnnotations = serde_json::from_str(&json).unwrap();

    assert_eq!(deserialized.framework, "Foundation");
    assert_eq!(deserialized.classes.len(), 1);
    assert_eq!(deserialized.classes[0].methods.len(), 2);
    assert_eq!(
        deserialized.classes[0].methods[1].error_pattern,
        Some(ErrorPattern::ErrorOutParam)
    );
}

#[test]
fn annotation_overrides_roundtrip() {
    let overrides = AnnotationOverrides {
        framework: "AppKit".to_string(),
        overrides: vec![AnnotationOverride {
            class_name: "NSWindow".to_string(),
            selector: "setDelegate:".to_string(),
            field: "parameter_ownership".to_string(),
            value: serde_json::json!([{"param_index": 0, "ownership": "weak"}]),
            reason: "NSWindow delegates are always weak references".to_string(),
        }],
    };

    let json = serde_json::to_string_pretty(&overrides).unwrap();
    let deserialized: AnnotationOverrides = serde_json::from_str(&json).unwrap();

    assert_eq!(deserialized.framework, "AppKit");
    assert_eq!(deserialized.overrides.len(), 1);
    assert_eq!(deserialized.overrides[0].class_name, "NSWindow");
    assert_eq!(deserialized.overrides[0].selector, "setDelegate:");
}

#[test]
fn ownership_kind_serialization() {
    assert_eq!(
        serde_json::to_string(&OwnershipKind::Strong).unwrap(),
        "\"strong\""
    );
    assert_eq!(
        serde_json::to_string(&OwnershipKind::Weak).unwrap(),
        "\"weak\""
    );
    assert_eq!(
        serde_json::to_string(&OwnershipKind::Copy).unwrap(),
        "\"copy\""
    );
    assert_eq!(
        serde_json::to_string(&OwnershipKind::UnsafeUnretained).unwrap(),
        "\"unsafe_unretained\""
    );
}

#[test]
fn block_invocation_style_serialization() {
    assert_eq!(
        serde_json::to_string(&BlockInvocationStyle::Synchronous).unwrap(),
        "\"synchronous\""
    );
    assert_eq!(
        serde_json::to_string(&BlockInvocationStyle::AsyncCopied).unwrap(),
        "\"async_copied\""
    );
    assert_eq!(
        serde_json::to_string(&BlockInvocationStyle::Stored).unwrap(),
        "\"stored\""
    );
}

#[test]
fn annotation_source_serialization() {
    assert_eq!(
        serde_json::to_string(&AnnotationSource::Heuristic).unwrap(),
        "\"heuristic\""
    );
    assert_eq!(
        serde_json::to_string(&AnnotationSource::Llm).unwrap(),
        "\"llm\""
    );
    assert_eq!(
        serde_json::to_string(&AnnotationSource::HumanReviewed).unwrap(),
        "\"human_reviewed\""
    );
}

#[test]
fn empty_optional_fields_skipped_in_serialization() {
    let annotation = MethodAnnotation {
        selector: "init".to_string(),
        is_instance: true,
        parameter_ownership: vec![],
        block_parameters: vec![],
        threading: None,
        error_pattern: None,
        source: AnnotationSource::Heuristic,
    };

    let json = serde_json::to_string(&annotation).unwrap();
    // Empty vecs and None options should be skipped
    assert!(!json.contains("parameter_ownership"));
    assert!(!json.contains("block_parameters"));
    assert!(!json.contains("threading"));
    assert!(!json.contains("error_pattern"));
}

#[test]
fn api_pattern_roundtrip() {
    let pattern = ApiPattern {
        stereotype: PatternStereotype::ResourceLifecycle,
        name: "NSMutableAttributedString editing session".to_string(),
        participants: serde_json::json!({
            "open": {"class": "NSMutableAttributedString", "selector": "beginEditing"},
            "operations": [
                {"class": "NSMutableAttributedString", "selector": "addAttribute:value:range:"}
            ],
            "close": {"class": "NSMutableAttributedString", "selector": "endEditing"}
        }),
        constraints: vec![
            PatternConstraint {
                kind: "ordering".to_string(),
                description: "beginEditing must precede mutations; endEditing must follow"
                    .to_string(),
            },
            PatternConstraint {
                kind: "thread_safety".to_string(),
                description: "not thread-safe; all calls must be on same thread".to_string(),
            },
        ],
        source: AnnotationSource::Llm,
        doc_ref: Some(
            "Attributed String Programming Guide > Changing an Attributed String".to_string(),
        ),
    };

    let json = serde_json::to_string_pretty(&pattern).unwrap();
    let deserialized: ApiPattern = serde_json::from_str(&json).unwrap();

    assert_eq!(
        deserialized.stereotype,
        PatternStereotype::ResourceLifecycle
    );
    assert_eq!(
        deserialized.name,
        "NSMutableAttributedString editing session"
    );
    assert_eq!(deserialized.constraints.len(), 2);
    assert_eq!(deserialized.constraints[0].kind, "ordering");
    assert_eq!(deserialized.source, AnnotationSource::Llm);
    assert!(deserialized.doc_ref.is_some());
}

#[test]
fn framework_annotations_with_subagent_report_roundtrip() {
    let annotations = FrameworkAnnotations {
        framework: "CoreData".to_string(),
        classes: vec![],
        subagent_report: Some(SubagentReport {
            block_synchronous: Some(4),
            block_async_copied: Some(15),
            block_stored: Some(11),
            parameter_ownership: Some(5),
            threading_main_thread_only: Some(0),
            threading_any_thread: Some(0),
            error_pattern: Some(58),
        }),
    };

    let json = serde_json::to_string_pretty(&annotations).unwrap();
    let deserialized: FrameworkAnnotations = serde_json::from_str(&json).unwrap();

    let report = deserialized.subagent_report.expect("report present");
    assert_eq!(report.block_async_copied, Some(15));
    assert_eq!(report.block_stored, Some(11));
    assert_eq!(report.parameter_ownership, Some(5));
    assert_eq!(report.error_pattern, Some(58));
}

#[test]
fn framework_annotations_without_subagent_report_is_backward_compatible() {
    // Legacy .llm.json files have no subagent_report — they must still parse.
    let legacy = r#"{
        "framework": "TestKit",
        "classes": []
    }"#;
    let parsed: FrameworkAnnotations = serde_json::from_str(legacy).unwrap();
    assert_eq!(parsed.framework, "TestKit");
    assert!(parsed.subagent_report.is_none());
}

#[test]
fn subagent_report_omits_unset_fields_in_serialization() {
    // A subagent that only tracked block invocations should not emit zeroed
    // ownership/threading/error fields — None means "not tracked".
    let report = SubagentReport {
        block_synchronous: Some(4),
        block_async_copied: Some(15),
        block_stored: Some(11),
        parameter_ownership: None,
        threading_main_thread_only: None,
        threading_any_thread: None,
        error_pattern: None,
    };
    let json = serde_json::to_string(&report).unwrap();
    assert!(json.contains("block_synchronous"));
    assert!(!json.contains("parameter_ownership"));
    assert!(!json.contains("threading_main_thread_only"));
    assert!(!json.contains("error_pattern"));
}

#[test]
fn pattern_stereotype_serialization() {
    assert_eq!(
        serde_json::to_string(&PatternStereotype::ResourceLifecycle).unwrap(),
        "\"resource_lifecycle\""
    );
    assert_eq!(
        serde_json::to_string(&PatternStereotype::ObserverPair).unwrap(),
        "\"observer_pair\""
    );
    assert_eq!(
        serde_json::to_string(&PatternStereotype::PairedState).unwrap(),
        "\"paired_state\""
    );
    assert_eq!(
        serde_json::to_string(&PatternStereotype::FactoryCluster).unwrap(),
        "\"factory_cluster\""
    );
    assert_eq!(
        serde_json::to_string(&PatternStereotype::TargetAction).unwrap(),
        "\"target_action\""
    );
}
