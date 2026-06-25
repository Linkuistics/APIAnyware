//! The typed projection-policy model (REFACTOR §23; node-brief D1, child
//! `policy-adapter-k54`): the per-platform projection *choices* a target makes — "how to
//! map source semantics into target idioms".
//!
//! A policy maps a projection **concern** (an open source-shape token —
//! `directly-reachable-objc`, `swift-native-async`, `escaping-callback`, …) to a point on
//! the REFACTOR §24 direct-call-vs-adapter [`SpectrumPoint`]. The concern axis is open
//! (each target authors the concerns its posture distinguishes — there is no fixed
//! §-vocabulary of concerns); the spectrum is the one closed, code-bound taxonomy, so it
//! is a serde enum whose `kebab-case` spelling IS its `.apiw` token (the single source of
//! truth, like [`Representability`](crate::derive::Representability) and
//! [`EmitConstruct`](crate::idioms::EmitConstruct)).
//!
//! The model describes *one implementation's* projection posture — projection lives in
//! `targets/`, never `platforms/` (the domain rule). It is authored knowledge: which
//! spectrum point a concern gets is a target-policy decision (the racket trampoline-elision
//! posture, the sbcl direct-msgSend posture), grounded in the target's shipped binding and
//! ADRs.

use serde::{Deserialize, Serialize};

/// One authored projection policy (`targets/<id>/policies/<platform>/projection.apiw`).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ProjectionPolicy {
    /// The target's stable id — the **target** directory name (`racket`, `chez`, …); the
    /// policy file lives two levels deeper at `<id>/policies/<platform>/projection.apiw`,
    /// so the registry checks `projection-policy "<id>"` against the *great-grandparent*
    /// directory.
    pub id: String,
    /// The platform this policy projects toward (`macos`, …); the registry checks it
    /// matches the file's parent directory.
    pub platform: String,
    /// Optional one-line human description.
    pub doc: Option<String>,
    /// The headline projection posture, echoing the sibling `target.apiw`
    /// `projection-policy` facet (`thin-direct`, …). Optional.
    pub posture: Option<String>,
    /// The authored choices, one per concern the policy distinguishes, in authored order.
    pub choices: Vec<ProjectionChoice>,
}

impl ProjectionPolicy {
    /// The choice for a projection `concern`, if the policy distinguishes it.
    pub fn choice(&self, concern: &str) -> Option<&ProjectionChoice> {
        self.choices.iter().find(|c| c.concern == concern)
    }
}

/// One authored projection choice — a concern mapped to a §24 spectrum point.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ProjectionChoice {
    /// The projection concern — an open source-shape token (the validator enforces
    /// per-policy uniqueness, not membership in a fixed vocabulary).
    pub concern: String,
    /// The §24 direct-call-vs-adapter spectrum point this concern maps to.
    pub spectrum: SpectrumPoint,
    /// Optional one-line elaboration (typically citing the grounding ADR / native bridge).
    pub doc: Option<String>,
}

/// The closed REFACTOR §24 direct-call-vs-adapter **spectrum** — the points a target's
/// binding can choose for a given concern (node-brief D1). One variant per §24 choice.
///
/// A genuinely bounded, stable spec taxonomy (a spectrum, not an open list), so — like the
/// `rung` ladder and `runtime-model` — it is a schema `enum`, not a `vocab` list. The serde
/// `kebab-case` spelling of a variant IS its `.apiw` token (the single source of truth);
/// the taxonomy is a closed `enum` in `policy.kdl-schema`, decoded here.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[serde(rename_all = "kebab-case")]
pub enum SpectrumPoint {
    /// Call the platform API directly through the target's FFI — no wrapper, no adapter
    /// (the trampoline-elision limit: the directly-reachable ObjC surface).
    DirectCall,
    /// Direct FFI call wrapped in a thin idiomatic shim (still no native adapter).
    DirectCallPlusWrapper,
    /// Route the call through the native adapter library.
    AdapterCall,
    /// Adapter call wrapped in a thin idiomatic shim on the target side.
    AdapterCallPlusWrapper,
    /// Reachable only through an explicit unsafe escape hatch.
    UnsafeEscapeHatch,
    /// Not representable — surfaced as an unsupported marker.
    UnsupportedMarker,
}
