//! Tests: round-trip serialization/deserialization of annotation types.

use std::collections::BTreeMap;

use apianyware_types::annotation::{
    AnnotationOverride, AnnotationOverrides, AnnotationSource, BlockInvocationStyle,
    BlockParamAnnotation, ClassAnnotations, Confidence, ErrorPattern, FrameworkAnnotations,
    MethodAnnotation, OwnershipKind, ParamOwnership, SubagentReport, ThreadingConstraint,
};
use apianyware_types::pattern_instance::{InstanceSource, Participant, PatternInstance};

#[test]
fn confidence_serialization() {
    // The authored-overlay confidence is a coarse enum (ADR-0046 §4) — not a float.
    assert_eq!(
        serde_json::to_string(&Confidence::High).unwrap(),
        "\"high\""
    );
    assert_eq!(
        serde_json::to_string(&Confidence::Medium).unwrap(),
        "\"medium\""
    );
    assert_eq!(serde_json::to_string(&Confidence::Low).unwrap(), "\"low\"");
}

#[test]
fn method_annotation_carries_provenance_stamp() {
    // ADR-0046 §4: authored facts carry confidence + provenance alongside source.
    let annotation = MethodAnnotation {
        selector: "sortedArrayUsingComparator:".to_string(),
        is_instance: true,
        parameter_ownership: vec![],
        block_parameters: vec![],
        threading: None,
        error_pattern: None,
        source: AnnotationSource::Llm,
        confidence: Some(Confidence::High),
        provenance: Some("Foundation Release Notes".to_string()),
        fact_provenance: None,
    };

    let json = serde_json::to_string_pretty(&annotation).unwrap();
    let back: MethodAnnotation = serde_json::from_str(&json).unwrap();

    assert_eq!(back.confidence, Some(Confidence::High));
    assert_eq!(back.provenance.as_deref(), Some("Foundation Release Notes"));
}

#[test]
fn provenance_stamp_omitted_when_absent_and_backward_compatible() {
    // Legacy .llm.json has neither field — it must still parse, and a stamp-free
    // annotation must not emit the keys (keeps machine JSON stable).
    let legacy = r#"{
        "selector": "init",
        "is_instance": true,
        "source": "convention"
    }"#;
    let parsed: MethodAnnotation = serde_json::from_str(legacy).unwrap();
    assert_eq!(parsed.confidence, None);
    assert_eq!(parsed.provenance, None);

    let json = serde_json::to_string(&parsed).unwrap();
    assert!(!json.contains("confidence"));
    assert!(!json.contains("provenance"));
}

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
        confidence: None,
        provenance: None,
        fact_provenance: None,
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
                    source: AnnotationSource::Convention,
                    confidence: None,
                    provenance: None,
                    fact_provenance: None,
                },
                MethodAnnotation {
                    selector: "writeToURL:error:".to_string(),
                    is_instance: true,
                    parameter_ownership: vec![],
                    block_parameters: vec![],
                    threading: None,
                    error_pattern: Some(ErrorPattern::ErrorOutParam),
                    source: AnnotationSource::Llm,
                    confidence: None,
                    provenance: None,
                    fact_provenance: None,
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
        serde_json::to_string(&AnnotationSource::Convention).unwrap(),
        "\"convention\""
    );
    assert_eq!(
        serde_json::to_string(&AnnotationSource::Llm).unwrap(),
        "\"llm\""
    );
    assert_eq!(
        serde_json::to_string(&AnnotationSource::Manual).unwrap(),
        "\"manual\""
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
        source: AnnotationSource::Convention,
        confidence: None,
        provenance: None,
        fact_provenance: None,
    };

    let json = serde_json::to_string(&annotation).unwrap();
    // Empty vecs and None options should be skipped
    assert!(!json.contains("parameter_ownership"));
    assert!(!json.contains("block_parameters"));
    assert!(!json.contains("threading"));
    assert!(!json.contains("error_pattern"));
}

#[test]
fn pattern_instance_roundtrip() {
    // A `bracket` instance bound to a real begin/end pair, provenance-stamped —
    // the resolved.json carriage shape (ADR-0048, workstream-3 child 2).
    let op = |selector: &str| {
        vec![Participant::Operation {
            framework: Some("Foundation".to_string()),
            class: Some("NSMutableAttributedString".to_string()),
            selector: selector.to_string(),
        }]
    };
    let mut roles: BTreeMap<String, Vec<Participant>> = BTreeMap::new();
    roles.insert("acquire".to_string(), op("beginEditing"));
    roles.insert("operation".to_string(), op("addAttribute:value:range:"));
    roles.insert("release".to_string(), op("endEditing"));

    let instance = PatternInstance {
        id: PatternInstance::compute_id("bracket", &roles),
        kind: "bracket".to_string(),
        home: "Foundation".to_string(),
        roles,
        source: InstanceSource::Llm,
        confidence: Some(Confidence::Medium),
        provenance: Some(
            "Attributed String Programming Guide > Changing an Attributed String".to_string(),
        ),
    };

    let json = serde_json::to_string_pretty(&instance).unwrap();
    // Wire-format pins: the participant tag and snake_case source enum.
    assert!(json.contains("\"participant\": \"operation\""));
    assert!(json.contains("\"source\": \"llm\""));

    let deserialized: PatternInstance = serde_json::from_str(&json).unwrap();
    assert_eq!(deserialized, instance, "instance round-trips losslessly");
    assert_eq!(deserialized.kind, "bracket");
    assert_eq!(deserialized.home, "Foundation");
    assert_eq!(deserialized.roles.len(), 3);
    assert_eq!(deserialized.confidence, Some(Confidence::Medium));
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
fn instance_source_serialization() {
    // The ADR-0046 §4 provenance tiers serialize as snake_case tokens.
    assert_eq!(
        serde_json::to_string(&InstanceSource::Extraction).unwrap(),
        "\"extraction\""
    );
    assert_eq!(
        serde_json::to_string(&InstanceSource::Convention).unwrap(),
        "\"convention\""
    );
    assert_eq!(
        serde_json::to_string(&InstanceSource::Llm).unwrap(),
        "\"llm\""
    );
    assert_eq!(
        serde_json::to_string(&InstanceSource::Manual).unwrap(),
        "\"manual\""
    );
}

#[test]
fn pattern_ref_participant_roundtrip() {
    // The §32-composition case: a role bound to another instance by content id.
    let r = Participant::Pattern {
        id: "callback-destroy-notifier-0123456789abcdef".to_string(),
    };
    let json = serde_json::to_string(&r).unwrap();
    assert!(json.contains("\"participant\":\"pattern\""));
    let back: Participant = serde_json::from_str(&json).unwrap();
    assert_eq!(back, r);
}
