//! The typed conformance-report model (REFACTOR §37; node-brief D1, child
//! `conformance-k55`) — the authored **judgment slice** of one target/platform pair's
//! conformance report.
//!
//! A conformance report is a **hybrid** artifact (node-brief D1): this model carries only the
//! authored judgment a machine cannot derive — the §37 per-app-kind support call
//! ([`AppSupport`]), the `unsupported` features, the `research` items, and the `known issues`
//! ([`JudgmentItem`]). The §37 *derived* slice (per-API coverage, per-app implementation
//! status) is computed on demand by [`crate::derive`] and has no authored form; the two are
//! reconciled by [`crate::conformance::crosscheck`].
//!
//! The support [`status`](AppSupport::status) re-uses the §37 [`ConformanceStatus`] ladder
//! defined in [`crate::derive`] — exactly as the authored [`crate::capability`] profile
//! re-uses the [`Representability`](crate::derive::Representability) ladder. The `app-kind`
//! token is checked against the seven macOS app-kinds ([`crate::vocab::APP_KINDS`]) by the
//! focused validator (the targets domain does not depend on the platforms domain; the domain
//! rule).

use crate::derive::ConformanceStatus;

/// One authored conformance report (`targets/<id>/conformance/<platform>.apiw`).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ConformanceReport {
    /// The target's stable id — the **target** directory name (`racket`, …); the report file
    /// lives one level deeper at `<id>/conformance/<platform>.apiw`, so the registry checks
    /// `conformance "<id>"` against the *grandparent* directory.
    pub id: String,
    /// The platform this report covers (`macos`, …); the registry checks it matches the file
    /// **stem** (platform-in-filename, unlike policy/adapter's platform directory).
    pub platform: String,
    /// Optional one-line human description.
    pub doc: Option<String>,
    /// The §37 per-app-kind support calls, in authored order.
    pub app_support: Vec<AppSupport>,
    /// The §37 unsupported features, in authored order.
    pub unsupported: Vec<JudgmentItem>,
    /// The §37 research items, in authored order.
    pub research: Vec<JudgmentItem>,
    /// The §37 known issues, in authored order.
    pub known_issues: Vec<JudgmentItem>,
}

impl ConformanceReport {
    /// The support call for an `app_kind`, if the report makes one.
    pub fn support(&self, app_kind: &str) -> Option<&AppSupport> {
        self.app_support.iter().find(|s| s.app_kind == app_kind)
    }
}

/// One §37 per-app-kind support call — the human judgment of whether this target/platform pair
/// can ship a given app-kind, optionally grounded in the common apps that exemplify it.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct AppSupport {
    /// The app-kind token — a member of the seven macOS [`crate::vocab::APP_KINDS`] (the
    /// focused validator enforces membership and per-report uniqueness).
    pub app_kind: String,
    /// The §37 support status.
    pub status: ConformanceStatus,
    /// Optional one-line justification (typically citing the grounding capability app-form rung
    /// or §36 hard case).
    pub doc: Option<String>,
    /// The common sample apps that exemplify this app-kind's support — the judgment grouping
    /// the cross-check uses to ground the call in the *derived* per-app VM-verify reality.
    /// May be empty (a pure judgment with no exemplar app).
    pub exemplars: Vec<String>,
}

/// One §37 judgment item — an `unsupported` feature, a `research` item, or a `known issue`.
/// All three share this shape (a token + an optional elaboration); the enclosing field on
/// [`ConformanceReport`] fixes which §37 list it belongs to.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct JudgmentItem {
    /// The item token — a free string (the validator checks per-list uniqueness, not
    /// membership in any vocabulary).
    pub name: String,
    /// Optional one-line elaboration.
    pub doc: Option<String>,
}
