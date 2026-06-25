//! The **authored-vs-derived cross-check** (REFACTOR §37; node-brief D1, child
//! `conformance-k55`) — the reconciliation that makes the hybrid conformance report safe.
//!
//! A conformance report is part *authored judgment* ([`crate::conformance::model`]) and part
//! *derived reality* ([`crate::derive`]). The two can drift: a target's §37 `app-support`
//! call is authored once and then the binding or its sample apps move underneath it. This
//! module catches the drift — the brief's canonical example, *"an authored `unsupported` must
//! not contradict a passing VM-verify report"* — by comparing each [`AppSupport`] call's
//! authored [`status`](crate::conformance::AppSupport::status) against the
//! [`derive_app_statuses`](crate::derive::derive_app_statuses)-computed status of each common
//! app it names as an `exemplar`.
//!
//! The exemplar list is the **grounding link**: the support call is a judgment about an
//! app-kind, and the apps it names are the judgment's evidence. A support call with no
//! exemplars is a pure judgment (no derived fact to contradict) and is never flagged — only
//! grounded claims are checked. The check is intentionally *one-directional and lenient*:
//! only the two genuinely contradictory shapes are flagged (a claim of non-support against a
//! shipped app, and a claim of full `pass` against an unverified app); hedged statuses
//! (`research` / `partial` / `skipped`) are compatible with any derived reality and pass
//! silently.

use std::collections::BTreeMap;

use crate::conformance::model::ConformanceReport;
use crate::derive::{AppImplStatus, ConformanceStatus};

/// One authored-vs-derived contradiction found by [`crosscheck`].
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Contradiction {
    /// The app-kind whose `app-support` call is contradicted.
    pub app_kind: String,
    /// The exemplar common app the contradiction concerns.
    pub app: String,
    /// The authored support status.
    pub authored: ConformanceStatus,
    /// The derived status of the exemplar app, or [`None`] when the exemplar names no
    /// implemented app at all (a dangling reference).
    pub derived: Option<ConformanceStatus>,
    /// A human-facing one-line explanation.
    pub message: String,
}

/// Cross-check one authored conformance `report` against the `derived` per-app statuses for
/// the same target (from [`crate::derive::derive_app_statuses`]). Returns every contradiction;
/// an empty vec means the authored judgment is consistent with the derived reality.
pub fn crosscheck(report: &ConformanceReport, derived: &[AppImplStatus]) -> Vec<Contradiction> {
    let by_app: BTreeMap<&str, &AppImplStatus> =
        derived.iter().map(|s| (s.app.as_str(), s)).collect();

    let mut contradictions = Vec::new();
    for support in &report.app_support {
        for exemplar in &support.exemplars {
            match by_app.get(exemplar.as_str()) {
                None => contradictions.push(Contradiction {
                    app_kind: support.app_kind.clone(),
                    app: exemplar.clone(),
                    authored: support.status,
                    derived: None,
                    message: format!(
                        "app-support `{}` names exemplar `{}`, but no such app is implemented \
                         under app-implementations/",
                        support.app_kind, exemplar
                    ),
                }),
                Some(found) => {
                    if let Some(reason) = contradiction_reason(support.status, found.status) {
                        contradictions.push(Contradiction {
                            app_kind: support.app_kind.clone(),
                            app: exemplar.clone(),
                            authored: support.status,
                            derived: Some(found.status),
                            message: format!(
                                "app-support `{}` is authored `{}`, but exemplar `{}` derives \
                                 `{}` — {reason}",
                                support.app_kind,
                                support.status.as_str(),
                                exemplar,
                                found.status.as_str(),
                            ),
                        });
                    }
                }
            }
        }
    }
    contradictions
}

/// Whether an `authored` support status genuinely contradicts the `derived` per-app status,
/// and why. `None` means they are compatible (consistent, or the authored claim is hedged).
///
/// Only two shapes are contradictions: a non-support claim against an app that is actually
/// shipped (the brief's example), and a full `pass` claim against an app that ships but is not
/// VM-verified. Derived statuses are only ever `Pass` / `Partial` (see
/// [`crate::derive::derive_app_statuses`]), so those are the cases enumerated.
fn contradiction_reason(
    authored: ConformanceStatus,
    derived: ConformanceStatus,
) -> Option<&'static str> {
    use ConformanceStatus::*;
    match (authored, derived) {
        (Unsupported | Failed, Pass) => {
            Some("the exemplar is implemented and VM-verified, contradicting a non-support claim")
        }
        (Unsupported | Failed, Partial) => {
            Some("the exemplar is implemented, contradicting a non-support claim")
        }
        (Pass, Partial) => {
            Some("the exemplar is implemented but not VM-verified, so a `pass` claim is unproven")
        }
        _ => None,
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::conformance::model::{AppSupport, ConformanceReport};

    fn report(support: Vec<AppSupport>) -> ConformanceReport {
        ConformanceReport {
            id: "racket".into(),
            platform: "macos".into(),
            doc: None,
            app_support: support,
            unsupported: vec![],
            research: vec![],
            known_issues: vec![],
        }
    }

    fn support(app_kind: &str, status: ConformanceStatus, exemplars: &[&str]) -> AppSupport {
        AppSupport {
            app_kind: app_kind.into(),
            status,
            doc: None,
            exemplars: exemplars.iter().map(|s| s.to_string()).collect(),
        }
    }

    fn derived(app: &str, status: ConformanceStatus) -> AppImplStatus {
        AppImplStatus {
            app: app.into(),
            implemented: true,
            vm_verified: status == ConformanceStatus::Pass,
            status,
        }
    }

    #[test]
    fn consistent_pass_is_clean() {
        let r = report(vec![support(
            "gui-app",
            ConformanceStatus::Pass,
            &["hello-window"],
        )]);
        let d = vec![derived("hello-window", ConformanceStatus::Pass)];
        assert!(crosscheck(&r, &d).is_empty());
    }

    #[test]
    fn unsupported_claim_against_a_passing_app_is_flagged() {
        // The brief's canonical example.
        let r = report(vec![support(
            "gui-app",
            ConformanceStatus::Unsupported,
            &["hello-window"],
        )]);
        let d = vec![derived("hello-window", ConformanceStatus::Pass)];
        let found = crosscheck(&r, &d);
        assert_eq!(found.len(), 1);
        assert_eq!(found[0].app, "hello-window");
        assert_eq!(found[0].authored, ConformanceStatus::Unsupported);
        assert_eq!(found[0].derived, Some(ConformanceStatus::Pass));
    }

    #[test]
    fn pass_claim_against_an_unverified_app_is_flagged() {
        let r = report(vec![support(
            "gui-app",
            ConformanceStatus::Pass,
            &["note-editor"],
        )]);
        let d = vec![derived("note-editor", ConformanceStatus::Partial)];
        let found = crosscheck(&r, &d);
        assert_eq!(found.len(), 1);
        assert!(found[0].message.contains("not VM-verified"));
    }

    #[test]
    fn dangling_exemplar_is_flagged() {
        let r = report(vec![support(
            "gui-app",
            ConformanceStatus::Pass,
            &["ghost-app"],
        )]);
        let found = crosscheck(&r, &[]);
        assert_eq!(found.len(), 1);
        assert_eq!(found[0].derived, None);
        assert!(found[0].message.contains("no such app is implemented"));
    }

    #[test]
    fn hedged_claims_never_contradict() {
        // research / partial against any derived reality is compatible.
        let r = report(vec![
            support(
                "spotlight-importer",
                ConformanceStatus::Research,
                &["note-editor"],
            ),
            support(
                "menu-bar-daemon",
                ConformanceStatus::Partial,
                &["hello-window"],
            ),
        ]);
        let d = vec![
            derived("note-editor", ConformanceStatus::Partial),
            derived("hello-window", ConformanceStatus::Pass),
        ];
        assert!(crosscheck(&r, &d).is_empty());
    }

    #[test]
    fn a_support_call_with_no_exemplars_is_never_checked() {
        let r = report(vec![support("cli-tool", ConformanceStatus::Pass, &[])]);
        assert!(crosscheck(&r, &[]).is_empty());
    }
}
