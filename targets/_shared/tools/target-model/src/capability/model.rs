//! The typed capability-profile model (REFACTOR §20; node-brief D2): the authored,
//! **platform-independent** statement of what one implementation *can express*.
//!
//! A profile maps a **capability dimension** (a shared controlled vocabulary —
//! [`crate::vocab`]) to a [`Representability`] ladder rung, across the two faces D2
//! names:
//!
//! - the **semantic** face ([`CapabilityProfile::semantic`]) — per-API capabilities
//!   ([`crate::vocab::SEMANTIC`]) that feed the representability floor
//!   ([`crate::derive::representability`]);
//! - the **app-form** face ([`CapabilityProfile::app_form`]) — packaging /
//!   bundle / plugin / sandboxing feasibilities ([`crate::vocab::APP_FORM`]) that feed
//!   per-app-kind support (child-5 conformance), **not** per-API representability.
//!
//! The profile describes the *implementation*, so it is **reusable across platforms**
//! (a CL impl "supports finalization" regardless of macOS). The macOS binding happens
//! in the *derivation*, which reads the platform's §30 weirdness — never here (keying a
//! profile on platform weirdness tags was rejected as coupling intrinsic capability to
//! one platform; node-brief D2).

use crate::derive::Representability;

/// One authored capability profile (`targets/<id>/capability.apiw`).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct CapabilityProfile {
    /// The target's stable id — the directory name (`racket`, `chez`, …). The registry
    /// checks `capability "<id>"` matches the containing directory.
    pub id: String,
    /// Optional one-line human description.
    pub doc: Option<String>,
    /// The per-API **semantic** capabilities (each dimension ∈ [`crate::vocab::SEMANTIC`]),
    /// in authored order. Feeds representability.
    pub semantic: Vec<CapabilityEntry>,
    /// The **app-form** capabilities (each dimension ∈ [`crate::vocab::APP_FORM`]), in
    /// authored order. Feeds per-app-kind feasibility.
    pub app_form: Vec<CapabilityEntry>,
}

impl CapabilityProfile {
    /// The authored rung for a **semantic** capability `dimension`, or [`None`] if the
    /// profile does not rate it. The derivation floor reads this; an unrated demanded
    /// dimension derives [`Representability::Research`] (see [`crate::derive`]).
    pub fn semantic_rung(&self, dimension: &str) -> Option<Representability> {
        self.semantic
            .iter()
            .find(|e| e.dimension == dimension)
            .map(|e| e.rung)
    }

    /// The authored rung for an **app-form** capability `dimension`, or [`None`] if the
    /// profile does not rate it.
    pub fn app_form_rung(&self, dimension: &str) -> Option<Representability> {
        self.app_form
            .iter()
            .find(|e| e.dimension == dimension)
            .map(|e| e.rung)
    }
}

/// One `dimension → rung` rating within a profile face.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct CapabilityEntry {
    /// The §20 capability dimension — a member of the enclosing face's controlled
    /// vocabulary ([`crate::vocab::SEMANTIC`] or [`crate::vocab::APP_FORM`]; the focused
    /// validator enforces face membership).
    pub dimension: String,
    /// The representability ladder rung the implementation reaches for this dimension.
    pub rung: Representability,
    /// Optional one-line justification (typically citing the grounding ADR / CONTEXT
    /// fact).
    pub doc: Option<String>,
}
