//! Enrichment output types for the generation-facing enriched checkpoint.
//!
//! These types represent the annotation-derived and pattern-derived relations
//! computed during enrichment (Datalog pass 2). The enriched checkpoint is
//! the final analysis output, consumed directly by emitters.

use serde::{Deserialize, Serialize};

/// Enrichment data derived from annotation-aware Datalog analysis.
///
/// Contains all annotation-derived and pattern-derived relations that emitters
/// need beyond the raw annotations — block lifecycle classification, delegate
/// detection, collection iterability, scoped resources, and thread affinity.
///
/// In addition to the class-keyed relations, this struct also carries
/// protocol-keyed relations (block classification, error patterns, thread
/// affinity, weak parameters for protocol methods) and weak-parameter
/// ownership for both classes and protocols.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct EnrichmentData {
    /// Methods with synchronous block parameters (no `Block_copy`, caller frees).
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub sync_block_methods: Vec<BlockMethodEntry>,

    /// Methods with asynchronous (copied) block parameters (`Block_copy`, runtime-managed).
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub async_block_methods: Vec<BlockMethodEntry>,

    /// Methods with stored block parameters (copied, called multiple times).
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub stored_block_methods: Vec<BlockMethodEntry>,

    /// Protocols suitable for typed delegate builders.
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub delegate_protocols: Vec<String>,

    /// Methods with NSError** out-param that can get a result-or-error wrapper.
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub convenience_error_methods: Vec<ClassSelectorEntry>,

    /// Classes with count + objectAtIndex: or NSFastEnumeration conformance.
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub collection_iterables: Vec<String>,

    /// Classes with begin/end or open/close scoped resource pairs.
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub scoped_resources: Vec<ScopedResourceEntry>,

    /// Classes where all methods must be called from the main thread.
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub main_thread_classes: Vec<String>,

    /// Methods with weak-reference parameters (class-keyed).
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub weak_param_methods: Vec<WeakParamEntry>,

    /// Protocol methods with synchronous block parameters (protocol-keyed:
    /// the `class` field of each entry holds a protocol name).
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub protocol_sync_block_methods: Vec<BlockMethodEntry>,

    /// Protocol methods with asynchronous (copied) block parameters.
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub protocol_async_block_methods: Vec<BlockMethodEntry>,

    /// Protocol methods with stored block parameters.
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub protocol_stored_block_methods: Vec<BlockMethodEntry>,

    /// Protocol methods with an NSError** out-param.
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub protocol_convenience_error_methods: Vec<ClassSelectorEntry>,

    /// Protocol methods with weak-reference parameters.
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub protocol_weak_param_methods: Vec<WeakParamEntry>,

    /// Protocols all of whose methods must be called from the main thread.
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub protocol_main_thread_protocols: Vec<String>,
}

/// A method with a block parameter at a specific index.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BlockMethodEntry {
    /// Class or protocol name.
    pub class: String,
    /// Selector name.
    pub selector: String,
    /// Zero-based parameter index of the block.
    pub param_index: usize,
}

/// A method parameter that is a weak reference (e.g. a delegate/dataSource).
///
/// The `class` field holds a class name when the entry comes from the
/// class-keyed `weak_param_methods`, or a protocol name when it comes from
/// `protocol_weak_param_methods`.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WeakParamEntry {
    /// Class or protocol name.
    pub class: String,
    /// Selector name.
    pub selector: String,
    /// Zero-based parameter index of the weak parameter.
    pub param_index: usize,
}

/// A (class, selector) pair identifying a method.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ClassSelectorEntry {
    /// Class or protocol name.
    pub class: String,
    /// Selector name.
    pub selector: String,
}

/// A scoped resource pattern: open/close selector pair on a class.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ScopedResourceEntry {
    /// Class name.
    pub class: String,
    /// Selector that opens/begins the resource scope.
    pub open_selector: String,
    /// Selector that closes/ends the resource scope.
    pub close_selector: String,
}

/// Verification report for enrichment completeness checks.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct VerificationReport {
    /// Whether all verification rules passed (no violations).
    pub passed: bool,

    /// Individual violations found.
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub violations: Vec<Violation>,
}

/// A single verification violation.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Violation {
    /// Which verification rule was violated (e.g., `"unclassified_block"`,
    /// `"flag_mismatch"`).
    pub rule: String,

    /// Class name where the violation occurs.
    pub class: String,

    /// Selector name where the violation occurs.
    pub selector: String,

    /// Block parameter index (for block-related violations).
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub param_index: Option<usize>,

    /// Human-readable description of the violation.
    pub description: String,
}
