//! Annotation schema for semantic method classification.
//!
//! Annotations describe how Cocoa APIs behave at runtime — block invocation
//! styles, parameter ownership, threading constraints, and error patterns.
//! They are produced by heuristic analysis and LLM classification, then
//! merged in the annotate step.

use serde::{Deserialize, Serialize};

/// Annotations for an entire framework, keyed by class/protocol name and selector.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FrameworkAnnotations {
    /// Framework name (e.g., `"Foundation"`, `"AppKit"`).
    pub framework: String,
    /// Per-class and per-protocol method annotations. Despite the field name,
    /// each entry may describe a protocol's methods as well as a class's.
    pub classes: Vec<ClassAnnotations>,
    /// Subagent's self-reported aggregate counts. Optional. When present,
    /// `llm-validate` cross-checks these against the actual content of this
    /// file and emits a warning (not an error) on divergence — the file
    /// content is the authoritative source of truth for downstream merge.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub subagent_report: Option<SubagentReport>,
}

/// A subagent's self-reported aggregate counts of the annotations it emitted.
///
/// Stored alongside the annotations so `llm-validate` can flag the
/// CoreData-style discrepancy where a subagent's narrative report disagrees
/// with what it actually wrote (e.g. report claims `async_copied=18 / stored=8`
/// but `jq` of the file finds `15 / 11`).
///
/// Each field is `Option<usize>` so we can distinguish "subagent did not
/// track this category" (`None`) from "subagent tracked it and found zero"
/// (`Some(0)`). A subagent that only classifies block invocations should
/// emit only the `block_*` fields and leave the rest absent.
#[derive(Debug, Clone, Default, Serialize, Deserialize, PartialEq, Eq)]
pub struct SubagentReport {
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub block_synchronous: Option<usize>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub block_async_copied: Option<usize>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub block_stored: Option<usize>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub parameter_ownership: Option<usize>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub threading_main_thread_only: Option<usize>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub threading_any_thread: Option<usize>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub error_pattern: Option<usize>,
}

/// Annotations for all methods of a single class or protocol.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ClassAnnotations {
    /// Class or protocol name (e.g., `"NSString"`, `"NSCopying"`). The field
    /// is named `class_name` for checkpoint-format backward compatibility; it
    /// also carries protocol names since the annotate step extends to
    /// protocol methods.
    pub class_name: String,
    /// Per-method annotations.
    pub methods: Vec<MethodAnnotation>,
}

/// Annotations for a single method or property.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MethodAnnotation {
    /// Selector name (e.g., `"initWithString:"`, `"setDelegate:"`).
    pub selector: String,

    /// Whether this is an instance method (`true`) or class method (`false`).
    pub is_instance: bool,

    /// Per-parameter ownership annotations.
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub parameter_ownership: Vec<ParamOwnership>,

    /// Block invocation style for block-typed parameters.
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub block_parameters: Vec<BlockParamAnnotation>,

    /// Threading constraints for this method.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub threading: Option<ThreadingConstraint>,

    /// Error handling pattern for this method.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub error_pattern: Option<ErrorPattern>,

    /// Where this annotation came from.
    pub source: AnnotationSource,

    /// Authoring confidence for this fact (ADR-0046 §4). A coarse enum, never a
    /// float — false precision in LLM self-assessment is the failure mode the
    /// enum avoids. `None` on mechanically-derived (extraction/heuristic) facts;
    /// carried on authored facts in the `.apiw` overlay.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub confidence: Option<Confidence>,

    /// Provenance for this fact (ADR-0046 §4): a documentation URL or short
    /// rationale backing an authored annotation. `None` when the fact has no
    /// authored provenance (e.g. heuristic/extraction facts).
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub provenance: Option<String>,
}

/// Coarse authoring-confidence level for an annotated fact (ADR-0046 §4).
///
/// Deliberately a three-valued enum rather than a numeric score: an LLM's
/// self-reported certainty does not warrant the false precision of a float, and
/// `high`/`medium`/`low` stays legible in the authored `.apiw` overlay.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum Confidence {
    /// Well-supported by documentation or an unambiguous signal.
    High,
    /// Reasonable inference; some ambiguity remains.
    Medium,
    /// Weak signal; flagged for review.
    Low,
}

/// Ownership kind for a method parameter.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ParamOwnership {
    /// Zero-based parameter index.
    pub param_index: usize,
    /// How the receiver treats this parameter's reference.
    pub ownership: OwnershipKind,
}

/// How a receiver treats a parameter's reference.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum OwnershipKind {
    /// Receiver retains (strong reference). Default for most object params.
    Strong,
    /// Receiver does NOT retain. Caller must keep the object alive.
    /// Common for delegates and data sources.
    Weak,
    /// Receiver copies the value. Common for block params and strings.
    Copy,
    /// Raw pointer with no ownership transfer. Rare, only for C-level APIs.
    UnsafeUnretained,
}

/// Block parameter invocation style annotation.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BlockParamAnnotation {
    /// Zero-based parameter index of the block parameter.
    pub param_index: usize,
    /// How the block is invoked by the receiver.
    pub invocation: BlockInvocationStyle,
}

/// How a Cocoa API invokes a block parameter.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum BlockInvocationStyle {
    /// Block is invoked synchronously during the method call and NOT copied.
    /// Caller must free the block explicitly after the method returns.
    Synchronous,
    /// Block is copied (`Block_copy`) for later async invocation.
    /// The ObjC runtime manages the block lifecycle via copy/dispose helpers.
    AsyncCopied,
    /// Block is stored by the receiver for repeated invocation (e.g., observers).
    /// Similar to `AsyncCopied` but may be called multiple times.
    Stored,
}

/// Threading constraints for a method.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum ThreadingConstraint {
    /// Must be called on the main thread only.
    MainThreadOnly,
    /// Safe to call from any thread.
    AnyThread,
}

/// Error handling pattern for a method.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum ErrorPattern {
    /// Last parameter is `NSError**` out-param. Method returns nil/NO on failure.
    ErrorOutParam,
    /// Method throws an ObjC exception on failure (rare in modern Cocoa).
    ThrowsException,
    /// Returns nil on failure (no error object).
    NilOnFailure,
}

/// Where an annotation came from (ADR-0046 §4 / ADR-0050 provenance vocabulary).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum AnnotationSource {
    /// Derived from a platform convention rule (`apianyware-conventions` datalog).
    /// The `<rule>` payload + `Extraction`/`Unknown` tiers arrive with the resolved-side
    /// per-fact carriage (ws5 `precedence-audit`); ws5 `provenance-vocab-k44` only renamed it.
    Convention,
    /// Derived from LLM analysis of Apple documentation.
    Llm,
    /// Authored/resolved by a human directly (the highest-precedence authored tier).
    Manual,
}

/// Override file: human-reviewed resolutions stored separately for merging.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct AnnotationOverrides {
    /// Framework name.
    pub framework: String,
    /// Per-selector overrides.
    pub overrides: Vec<AnnotationOverride>,
}

/// A single human override for a method annotation.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AnnotationOverride {
    /// Class name.
    pub class_name: String,
    /// Selector name.
    pub selector: String,
    /// The field being overridden (e.g., `"block_parameters"`, `"threading"`).
    pub field: String,
    /// The overridden value (serialized as the appropriate type).
    pub value: serde_json::Value,
    /// Reason for the override.
    pub reason: String,
}

/// A disagreement between heuristic and LLM annotations for human review.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AnnotationDisagreement {
    /// Class name.
    pub class_name: String,
    /// Selector name.
    pub selector: String,
    /// What the heuristic says.
    pub heuristic_value: String,
    /// What the LLM says.
    pub llm_value: String,
    /// Which annotation field disagrees (e.g., `"threading"`, `"parameter_ownership[0]"`).
    pub field: String,
    /// Human resolution (if any).
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub resolution: Option<DisagreementResolution>,
}

/// Human resolution of a disagreement.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DisagreementResolution {
    /// Which source to trust: `"convention"` or `"llm"`.
    pub trust: String,
    /// Reason for the decision.
    pub reason: String,
}

// ---------------------------------------------------------------------------
// Multi-method patterns
// ---------------------------------------------------------------------------
//
// The former heuristic `ApiPattern` / `PatternStereotype` / `PatternConstraint`
// types (a closed Rust enum of stereotypes with an untyped `participants` blob)
// are superseded by the first-class, authored pattern-kind model: a typed
// [`crate::pattern_instance::PatternInstance`] referencing a kind in the
// `apianyware-patterns` registry (ADR-0048). See `crate::pattern_instance`.
