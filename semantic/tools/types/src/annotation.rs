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

    /// Resolved-only per-fact provenance from the §28 precedence audit
    /// (ADR-0050 §3). Populated *only* at resolve time, after the convention
    /// and authored-overlay tiers are reconciled per fact-slot; `None` in the
    /// authored `annotations.apiw` overlay (ADR-0050 D3 — per-fact provenance
    /// lives in `resolved.kdl`, never the overlay). Emit-invisible: the audit
    /// stamps *provenance*, never a winning value, so this field cannot move a
    /// golden.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub fact_provenance: Option<MethodFactProvenance>,
}

/// Per-fact-slot provenance for a resolved method annotation (ADR-0046 §4 /
/// ADR-0050 §3 disagreement audit).
///
/// One entry per *producing* fact-slot: the §28 tier that won the slot, the
/// `convention:<rule>` stamp(s) backing a convention win, and any *disagreeing*
/// losing tiers retained as [`SupersededFact`]s. A fact-slot with no producer
/// has **no entry** — its unknown-ness is the absence (the audit never
/// fabricates a tier for a slot nobody produced; ADR-0050 §3 "explicit
/// `unknown`, never silently defaulted"). Populated solely by the resolve-time
/// audit; absent in the authored overlay.
#[derive(Debug, Clone, Default, Serialize, Deserialize, PartialEq, Eq)]
pub struct MethodFactProvenance {
    /// Provenance per ownership fact-slot, keyed by `param_index` (ascending).
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub parameter_ownership: Vec<SlotProvenance>,
    /// Provenance per block-invocation fact-slot, keyed by `param_index`.
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub block_parameters: Vec<SlotProvenance>,
    /// Provenance for the method-level threading fact-slot, if produced.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub threading: Option<SlotProvenance>,
    /// Provenance for the method-level error-pattern fact-slot, if produced.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub error_pattern: Option<SlotProvenance>,
}

/// Provenance for a single resolved fact-slot: the winning §28 tier plus any
/// disagreeing losers (ADR-0046 §4).
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct SlotProvenance {
    /// `param_index` for per-parameter slots (ownership / block); `None` for the
    /// method-level scalar slots (threading / error pattern).
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub param_index: Option<usize>,
    /// The §28 tier that produced the winning value.
    pub source: AnnotationSource,
    /// The `convention:<rule>` stamp(s) backing a `Convention` win (ADR-0046 §4,
    /// `convention:<rule>`). Empty for non-convention winners.
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub rules: Vec<String>,
    /// Disagreeing losing tiers — a producing tier whose value differs from the
    /// winner's. Tiers that *agree* with the winner are redundant, not
    /// disagreeing, and are **not** recorded here (ADR-0050 §3).
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub superseded_by: Vec<SupersededFact>,
}

/// A disagreeing losing fact retained by the precedence audit (ADR-0046 §4
/// `superseded-by { source; value }`).
///
/// Evolves the legacy `AnnotationDisagreement` heuristic/llm value pair into a
/// per-loser `{ source, value }` record: each loser names its own §28 tier and
/// its rendered value, so an N-tier disagreement is N − 1 records against the
/// one winner rather than a single fixed heuristic-vs-llm pair.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct SupersededFact {
    /// The losing tier.
    pub source: AnnotationSource,
    /// The losing value, rendered to the slot's serde token (e.g. `"strong"`,
    /// `"main_thread_only"`) so the audit/diff report reads without the
    /// producing types.
    pub value: String,
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
///
/// Also the vocabulary of the **declared** ownership qualifier on
/// [`crate::ir::Property`] — `@property (weak)`/`(copy)`/`(strong)`/`(assign)` map
/// onto exactly these four (ADR-0047 §4), so the convention tier's
/// declared-attribute rules carry the extracted value straight to the annotation
/// slot with no token table in between. `Hash` is derived so the value can key an
/// `ascent` relation column.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
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

/// Where a resolved fact came from — the §28 precedence ladder (ADR-0046 §4 /
/// ADR-0050 D3 provenance vocabulary).
///
/// Two homes (ADR-0050 D3): the authored `annotations.apiw` overlay carries only
/// `{Llm, Manual}`; the derived `resolved.kdl` carries the full ladder after the
/// precedence audit. As a *method-level* tag (`MethodAnnotation::source`) the
/// variant is the coarsest producing tier; the `convention:<rule>` rule payload
/// rides per fact-slot on [`SlotProvenance::rules`], not on this enum, so the one
/// enum serves both the method-level tag and the per-fact stamp.
///
/// Precedence, high → low: `Manual > Extraction > Llm (accepted) > Convention >
/// Unknown` (see [`AnnotationSource::precedence`]) — evidence classes
/// strongest-first: a human, the compiler, accepted prose, a naming pattern.
/// Re-ranked by `declared-fact-precedence-k87` (2026-07-13, ADR-0047 §4): a
/// declared fact now outranks accepted prose, closing the inversion where the
/// LLM tier silently superseded a fact the compiler already stated.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum AnnotationSource {
    /// Authored/resolved by a human directly (the highest-precedence tier).
    Manual,
    /// Mechanically extracted from the SDK headers (the datalog fact base) —
    /// **including** a convention rule whose *sole* premises are compiler
    /// declarations (ADR-0047 §4, k87): membership is the *evidence class*, not
    /// the producing mechanism, so such a rule produces here even though it
    /// runs in the same `apianyware-conventions` datalog engine as
    /// [`AnnotationSource::Convention`]. Membership test: could the rule fire on
    /// a corpus with all names stripped? Producers today: the
    /// declared-property-attribute ownership rule (one per [`OwnershipKind`])
    /// and `block-copy-property-setter`. Outranks `Llm` — a declared fact beats
    /// accepted prose.
    Extraction,
    /// Derived from LLM analysis of Apple documentation. `accepted-LLM` ≡ a
    /// committed `source llm` fact (ADR-0050 D2 — git is the accept boundary).
    Llm,
    /// Derived from a platform convention rule (`apianyware-conventions`
    /// datalog). The backing `convention:<rule>` stamp(s) ride per-slot on
    /// [`SlotProvenance::rules`]. Rules here are the **fallback for the
    /// undeclared case** — a name sniff, a positional default — never a
    /// substitute for reading a declaration the compiler already hands us; a
    /// declaration-premised rule belongs to `Extraction` instead (ADR-0047 §4).
    Convention,
    /// No tier produced the fact-slot. Carried as the method-level `source` of a
    /// method with no producing facts, so a fact-less method is *explicitly*
    /// unknown rather than silently defaulted to `Convention` (ADR-0050 §3).
    Unknown,
}

impl AnnotationSource {
    /// The §28 precedence rank — **lower is higher precedence** (`Manual` = 0).
    /// The audit picks the minimum rank among a fact-slot's producing tiers.
    /// Re-ranked by `declared-fact-precedence-k87`: `Extraction` moved above
    /// `Llm` — a declared fact now outranks accepted prose.
    pub fn precedence(self) -> u8 {
        match self {
            AnnotationSource::Manual => 0,
            AnnotationSource::Extraction => 1,
            AnnotationSource::Llm => 2,
            AnnotationSource::Convention => 3,
            AnnotationSource::Unknown => 4,
        }
    }
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

// The legacy `AnnotationDisagreement` / `DisagreementResolution` records (a fixed
// heuristic-vs-llm value pair plus a manual `trust` resolution) are superseded by
// the resolve-time precedence audit: disagreeing losers are now retained per
// fact-slot as [`SupersededFact`]s on [`SlotProvenance`], and "resolution" is git
// — a human accepts by committing the overlay (ADR-0050 D2). See [`SupersededFact`].

// ---------------------------------------------------------------------------
// Multi-method patterns
// ---------------------------------------------------------------------------
//
// The former heuristic `ApiPattern` / `PatternStereotype` / `PatternConstraint`
// types (a closed Rust enum of stereotypes with an untyped `participants` blob)
// are superseded by the first-class, authored pattern-kind model: a typed
// [`crate::pattern_instance::PatternInstance`] referencing a kind in the
// `apianyware-patterns` registry (ADR-0048). See `crate::pattern_instance`.
