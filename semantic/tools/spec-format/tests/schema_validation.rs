//! The `.apiw` schema validator (`kdl-schema-k19`) checks an authored overlay
//! against the language-neutral KDL Schema contract
//! (`schemas/spec-format/annotations.kdl-schema`, ADR-0046 §3).
//!
//! Two fixtures pin the validator step (the brief's done-bar): a well-formed
//! overlay passes, and a deliberately-malformed one fails with a located error.
//! A third test ties the *conforming implementations* together — anything the
//! k18 writer (`write_apiw`) emits must validate against the k19 schema.

use apianyware_spec_format::{apiw, validate_apiw};
use apianyware_types::annotation::{
    AnnotationSource, BlockInvocationStyle, BlockParamAnnotation, ClassAnnotations, Confidence,
    ErrorPattern, FrameworkAnnotations, MethodAnnotation, OwnershipKind, ParamOwnership,
    SubagentReport, ThreadingConstraint,
};

const VALID: &str = include_str!("fixtures/valid.apiw");
const INVALID: &str = include_str!("fixtures/invalid.apiw");

#[test]
fn valid_fixture_conforms_to_the_schema() {
    validate_apiw("valid.apiw", VALID).expect("the well-formed fixture must validate");
}

#[test]
fn invalid_fixture_is_a_located_schema_error() {
    let err = validate_apiw("invalid.apiw", INVALID).expect_err("the bad fixture must be rejected");
    let msg = err.to_string();
    assert!(
        msg.contains("owns"),
        "the error should name the offending enum value, got: {msg}"
    );
}

/// The k18 writer and the k19 schema are two conforming implementations of the
/// same contract: every `.apiw` document `write_apiw` produces must validate.
#[test]
fn written_overlay_validates_against_the_schema() {
    let model = FrameworkAnnotations {
        framework: "Foundation".to_string(),
        classes: vec![ClassAnnotations {
            class_name: "NSArray".to_string(),
            methods: vec![MethodAnnotation {
                selector: "enumerateObjectsUsingBlock:".to_string(),
                is_instance: true,
                parameter_ownership: vec![ParamOwnership {
                    param_index: 0,
                    ownership: OwnershipKind::UnsafeUnretained,
                }],
                block_parameters: vec![BlockParamAnnotation {
                    param_index: 0,
                    invocation: BlockInvocationStyle::AsyncCopied,
                }],
                threading: Some(ThreadingConstraint::MainThreadOnly),
                error_pattern: Some(ErrorPattern::NilOnFailure),
                source: AnnotationSource::Manual,
                confidence: Some(Confidence::Medium),
                provenance: Some("AppKit Release Notes".to_string()),
                fact_provenance: None,
            }],
        }],
        subagent_report: Some(SubagentReport {
            block_synchronous: Some(0),
            block_async_copied: Some(1),
            block_stored: None,
            parameter_ownership: Some(1),
            threading_main_thread_only: Some(1),
            threading_any_thread: None,
            error_pattern: Some(1),
        }),
    };
    let text = apiw::write_apiw(&model);
    validate_apiw("written.apiw", &text)
        .unwrap_or_else(|e| panic!("write_apiw output must conform to the schema:\n{text}\n{e}"));
}
