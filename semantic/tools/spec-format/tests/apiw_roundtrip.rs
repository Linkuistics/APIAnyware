//! The authored `.apiw` overlay (KDL 2.0) round-trips the typed annotation model.
//!
//! `write_apiw` then `parse_apiw` must reproduce a `FrameworkAnnotations`
//! structurally — including the ADR-0046 §4 provenance stamp (source /
//! confidence / provenance) and the k17 keyword-string force-quote footgun.

use apianyware_spec_format::apiw;
use apianyware_types::annotation::{
    AnnotationSource, BlockInvocationStyle, BlockParamAnnotation, ClassAnnotations, Confidence,
    ErrorPattern, FrameworkAnnotations, MethodAnnotation, OwnershipKind, ParamOwnership,
    SubagentReport, ThreadingConstraint,
};

/// Structural (serde) equality — `FrameworkAnnotations` has no `PartialEq`.
fn assert_same(a: &FrameworkAnnotations, b: &FrameworkAnnotations) {
    assert_eq!(
        serde_json::to_value(a).unwrap(),
        serde_json::to_value(b).unwrap()
    );
}

fn rich() -> FrameworkAnnotations {
    FrameworkAnnotations {
        framework: "Foundation".to_string(),
        classes: vec![ClassAnnotations {
            class_name: "NSArray".to_string(),
            methods: vec![
                MethodAnnotation {
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
                    source: AnnotationSource::Heuristic,
                    confidence: None,
                    provenance: None,
                },
                MethodAnnotation {
                    selector: "writeToURL:error:".to_string(),
                    is_instance: true,
                    parameter_ownership: vec![],
                    block_parameters: vec![],
                    threading: None,
                    error_pattern: Some(ErrorPattern::ErrorOutParam),
                    source: AnnotationSource::Llm,
                    confidence: Some(Confidence::High),
                    provenance: Some("Foundation Release Notes".to_string()),
                },
            ],
        }],
        subagent_report: Some(SubagentReport {
            block_synchronous: Some(1),
            block_async_copied: Some(0),
            block_stored: Some(0),
            parameter_ownership: Some(1),
            threading_main_thread_only: None,
            threading_any_thread: Some(1),
            error_pattern: Some(1),
        }),
    }
}

#[test]
fn rich_framework_annotations_round_trip() {
    let original = rich();
    let text = apiw::write_apiw(&original);
    let parsed = apiw::parse_apiw("test.apiw", &text).expect("parse the written .apiw");
    assert_same(&original, &parsed);
}

#[test]
fn class_method_annotation_minimal_round_trip() {
    // The smallest valid method: just a required source, no overlay/stamp.
    let original = FrameworkAnnotations {
        framework: "WidgetKit".to_string(),
        classes: vec![ClassAnnotations {
            class_name: "WidgetCenter".to_string(),
            methods: vec![MethodAnnotation {
                selector: "getCurrentConfigurations(_:)".to_string(),
                is_instance: true,
                parameter_ownership: vec![],
                block_parameters: vec![BlockParamAnnotation {
                    param_index: 0,
                    invocation: BlockInvocationStyle::AsyncCopied,
                }],
                threading: None,
                error_pattern: None,
                source: AnnotationSource::Llm,
                confidence: None,
                provenance: None,
            }],
        }],
        subagent_report: None,
    };
    let text = apiw::write_apiw(&original);
    let parsed = apiw::parse_apiw("widgetkit.apiw", &text).unwrap();
    assert_same(&original, &parsed);
}

#[test]
fn keyword_valued_strings_round_trip() {
    // k17 footgun: the `kdl` crate emits `null`/`true`/`false`/`nan` bare, then
    // its own parser rejects them. A class or selector that literally spells a
    // KDL keyword must survive the round trip (force-quoted on write).
    let original = FrameworkAnnotations {
        framework: "Edge".to_string(),
        classes: vec![ClassAnnotations {
            class_name: "null".to_string(),
            methods: vec![MethodAnnotation {
                selector: "true".to_string(),
                is_instance: false,
                parameter_ownership: vec![],
                block_parameters: vec![],
                threading: None,
                error_pattern: None,
                source: AnnotationSource::Llm,
                confidence: None,
                provenance: None,
            }],
        }],
        subagent_report: None,
    };
    let text = apiw::write_apiw(&original);
    // The written text must re-parse at all (the footgun breaks this) ...
    let parsed = apiw::parse_apiw("edge.apiw", &text).expect("keyword strings must re-parse");
    // ... and preserve the keyword-valued names.
    assert_same(&original, &parsed);
}

#[test]
fn unknown_enum_value_is_a_located_schema_error() {
    // A structurally-valid KDL doc with a bad enum value is a schema error, not
    // a panic — and carries a span (good miette errors).
    let bad = r#"
framework "Foundation" {
    class "NSArray" {
        method "count" is-instance=#true {
            source "wizardry"
        }
    }
}
"#;
    let err = apiw::parse_apiw("bad.apiw", bad).unwrap_err();
    let msg = err.to_string();
    assert!(
        msg.contains("wizardry") || msg.contains("source"),
        "error should name the offending value/field, got: {msg}"
    );
}
