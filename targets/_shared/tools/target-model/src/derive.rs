//! The **derivation** layer (REFACTOR §7.7/§20/§37): everything the target model
//! *computes* rather than authors. Two derivations live here, and the §37
//! [`ConformanceStatus`] vocabulary they share with the authored conformance slice:
//!
//! - **Per-API representability** (node-brief D2, child `capability-k52`): the unified
//!   7-rung [`Representability`] ladder and the [`representability`] **floor** that
//!   derives a per-API status from an authored [`CapabilityProfile`] and the platform
//!   §30 source-weirdness an API carries, plus the [`representability_histogram`] that
//!   rolls a whole weird-API surface up into the §37 *coverage* line.
//! - **Per-app conformance** (node-brief D1, child `conformance-k55`): the
//!   [`derive_app_statuses`] scan that reads a target's shipped
//!   `app-implementations/` + VM-verify `reports/` and yields each common app's §37
//!   [`AppImplStatus`] — the *common app-implementation status* line.
//!
//! Both are **derived, never authored** (node-brief D1): committing a per-API status or
//! a per-app status would duplicate a derivable fact and rot against SDK / binding
//! drift, so they are computed on demand and stay uncommitted (constraint 4). The
//! authored *judgment* slice (`conformance/<platform>.apiw`) is cross-checked against
//! these derivations by [`crate::conformance::crosscheck`].
//!
//! This module is **domain-pure**: the representability floor takes the API's weirdness
//! *tags*, not the platform's `ApiSemanticsRegistry`, and the app scan takes a target's
//! own filesystem root — so the targets-domain crate never depends on the
//! platforms-domain crate. The CLI consumer (`apianyware-conformance`, child 5) loads
//! the platform api-semantics registry, reads each API's weirdness, and passes the tags
//! here.
//!
//! ## The floor
//!
//! `status(api, target) =` the **worst (lowest) ladder rung** over
//! `{ profile[needs(w)] : w ∈ platform.weirdness(api) }`, where `needs` is the shared
//! [`crate::vocab::capability_for`] map. Two boundary behaviours carry the model:
//!
//! - An API with **no** weirdness tag (or only *reassuring* tags that demand nothing)
//!   derives the top rung [`Representability::ExactStatic`] — the **trampoline-elision
//!   limit**: the vast directly-reachable ObjC surface is fully represented, and only
//!   the weird / Swift-native residual drops down the ladder.
//! - A weirdness tag that demands a capability the profile has **not** authored a rung
//!   for derives [`Representability::Research`] for that demand — an unestablished
//!   capability leaves the API's representability unestablished (and `Research` sorts
//!   lowest, so it dominates the floor; see [`Representability`]).

use std::collections::BTreeMap;
use std::path::Path;

use serde::{Deserialize, Serialize};

use crate::capability::CapabilityProfile;
use crate::vocab;

/// The unified §20/§7.7 **representability ladder** — one 7-rung scale collapsing
/// REFACTOR §20's capability "levels" and §7.7's per-API "statuses" (the same ladder
/// under two names; node-brief D2).
///
/// **Ordering is load-bearing.** The variants are declared worst → best, so the
/// derived [`Ord`] makes [`Representability::Research`] the smallest and
/// [`Representability::ExactStatic`] the largest, and the [`representability`] floor is
/// simply the `min` over the demanded rungs. Reading top → bottom:
/// `exact-static` (≡ fully-represented) > `exact-runtime` (≡ runtime-represented) >
/// `idiomatic-conventional` (≡ conventionally-represented) > `lossy-but-documented`
/// (≡ lossily-represented) > `unsafe-only` > `not-representable` (≡ unsupported) >
/// `research`. `research` sorts **lowest** deliberately: an unestablished capability
/// dominates the floor — if any demanded capability is unresearched, the API's
/// representability is unestablished, the conservative reading.
///
/// The serde `kebab-case` spelling of a variant IS its `.apiw` token (the single
/// source of truth, exactly like `RuntimeModel`); the ladder is a controlled `enum`
/// (an `enum` constraint in `capability.kdl-schema`, decoded here).
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash, Serialize, Deserialize)]
#[serde(rename_all = "kebab-case")]
pub enum Representability {
    /// Not yet established — the implementation's stance is unresearched. Sorts lowest
    /// (dominates the floor).
    Research,
    /// The platform meaning cannot be represented in this implementation at all
    /// (≡ §7.7 *unsupported*).
    NotRepresentable,
    /// Representable only through an explicit unsafe escape hatch.
    UnsafeOnly,
    /// Representable but with documented loss of fidelity (≡ §7.7 *lossily
    /// represented*).
    LossyButDocumented,
    /// Representable by an idiomatic convention the binding upholds (≡ §7.7
    /// *conventionally represented*) — e.g. a foreign-thread callback handled by a
    /// main-thread bounce rather than native thread activation.
    IdiomaticConventional,
    /// Represented exactly, by a runtime mechanism (≡ §7.7 *runtime represented*) —
    /// e.g. callbacks via foreign-callable, GC finalization, a runtime thread
    /// activation.
    ExactRuntime,
    /// Represented exactly and statically — the directly-reachable, trampoline-elided
    /// surface (≡ §7.7 *fully represented*). The default for an API with no §30
    /// weirdness.
    ExactStatic,
}

impl Representability {
    /// The rung an API derives when nothing demands a lower one — the
    /// trampoline-elision default ([`Representability::ExactStatic`]).
    pub const DEFAULT: Representability = Representability::ExactStatic;
}

/// Derive the [`Representability`] of one API for one target: the **floor** (worst
/// rung) over the capabilities its `weirdness` demands, against the target's authored
/// `profile`.
///
/// `weirdness` is the API's §30 source-weirdness tags (from the platform's
/// api-semantics declarations — passed in, not read here, to keep this domain-pure).
/// Accepts any slice of string-like tags (`&[&str]` or `&[String]`). Empty weirdness —
/// or weirdness whose tags all demand nothing — yields [`Representability::DEFAULT`]
/// (`exact-static`).
pub fn representability<S: AsRef<str>>(
    profile: &CapabilityProfile,
    weirdness: &[S],
) -> Representability {
    weirdness
        .iter()
        .filter_map(|w| vocab::capability_for(w.as_ref()))
        .map(|dimension| {
            // A demanded-but-unauthored capability is unestablished → Research.
            profile
                .semantic_rung(dimension)
                .unwrap_or(Representability::Research)
        })
        .min()
        .unwrap_or(Representability::DEFAULT)
}

/// The §37 conformance **status** ladder (REFACTOR §37; node-brief D1, child
/// `conformance-k55`) — the report's status vocabulary, used for both the *authored*
/// per-app-kind support call (`conformance/<platform>.apiw`) and the *derived* per-app
/// implementation status ([`AppImplStatus::status`]).
///
/// It lives in `derive` alongside [`Representability`] and is re-used by the authored
/// `conformance` model exactly as `Representability` is re-used by the authored `capability`
/// model — the derivation layer owns the two status ladders the target model both authors and
/// derives. A genuinely bounded REFACTOR §37 set, so — like [`Representability`] and the
/// `SpectrumPoint` / `ServiceStatus` taxonomies — it is a schema `enum`, decoded here; the
/// serde **lowercase** spelling of a variant IS its `.apiw` token (the single source of truth).
///
/// Unlike [`Representability`], the variants carry no meaningful order (a derived `failed` is
/// not "less representable" than a `pass` — it is a different *kind* of outcome), so this enum
/// is deliberately **not** `Ord`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum ConformanceStatus {
    /// Fully supported / verified.
    Pass,
    /// Partially supported — feasible by a proven mechanism but not fully exercised.
    Partial,
    /// Stance unestablished, awaiting investigation.
    Research,
    /// Not supported on this target/platform pair.
    Unsupported,
    /// Attempted and observed to fail.
    Failed,
    /// Deliberately not covered.
    Skipped,
}

impl ConformanceStatus {
    /// The status's `.apiw` / report spelling (`"pass"`, `"partial"`, …) — the serde token.
    pub fn as_str(self) -> &'static str {
        match self {
            ConformanceStatus::Pass => "pass",
            ConformanceStatus::Partial => "partial",
            ConformanceStatus::Research => "research",
            ConformanceStatus::Unsupported => "unsupported",
            ConformanceStatus::Failed => "failed",
            ConformanceStatus::Skipped => "skipped",
        }
    }
}

/// The DERIVED implementation status of one common sample app for one target (node-brief D1,
/// child `conformance-k55`) — computed by [`derive_app_statuses`] from the target's shipped
/// `app-implementations/` + VM-verify `reports/`, never authored.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct AppImplStatus {
    /// The common-app directory name (`hello-window`, …).
    pub app: String,
    /// Whether `app-implementations/<platform>/<app>/` exists (the target ships a port).
    pub implemented: bool,
    /// Whether `bindings/<platform>/reports/<app>/` carries VM-verify evidence (a `report.md`
    /// or at least one screenshot) — the [[feedback-vm-verify-every-app]] artifact.
    pub vm_verified: bool,
    /// The §37 status this evidence derives to: [`ConformanceStatus::Pass`] when implemented
    /// **and** VM-verified, [`ConformanceStatus::Partial`] when implemented but not yet
    /// VM-verified.
    pub status: ConformanceStatus,
}

/// Derive each common sample app's §37 implementation status for one target, by reading its
/// shipped `app-implementations/<platform>/` ports and the VM-verify evidence under
/// `bindings/<platform>/reports/` (node-brief D1).
///
/// `target_root` is the target's directory (`targets/<id>`); `platform` selects the macOS
/// (or future) sub-tree. The canonical app set is the implementation directories (a `README.md`
/// file and the sbcl `_support/` helper directory are skipped); an app is
/// [`ConformanceStatus::Pass`] when its `reports/<app>/` directory holds at least one file
/// (a `report.md` or a screenshot), else [`ConformanceStatus::Partial`]. The result is sorted
/// by app name. A missing `app-implementations/<platform>/` directory yields an empty vec
/// (a target not yet homed) rather than an error — the derivation is best-effort over what is
/// actually on disk, exactly like the representability floor over what weirdness is declared.
pub fn derive_app_statuses(target_root: &Path, platform: &str) -> Vec<AppImplStatus> {
    let impl_dir = target_root.join("app-implementations").join(platform);
    let reports_dir = target_root.join("bindings").join(platform).join("reports");

    let mut statuses: Vec<AppImplStatus> = match std::fs::read_dir(&impl_dir) {
        Ok(entries) => entries
            .filter_map(|e| e.ok())
            .filter(|e| e.path().is_dir())
            .filter_map(|e| e.file_name().into_string().ok())
            .filter(|name| name != "_support")
            .map(|app| {
                let vm_verified = dir_has_a_file(&reports_dir.join(&app));
                let status = if vm_verified {
                    ConformanceStatus::Pass
                } else {
                    ConformanceStatus::Partial
                };
                AppImplStatus {
                    app,
                    implemented: true,
                    vm_verified,
                    status,
                }
            })
            .collect(),
        Err(_) => Vec::new(),
    };
    statuses.sort_by(|a, b| a.app.cmp(&b.app));
    statuses
}

/// Whether `dir` exists and contains at least one entry — the VM-verify-evidence test (a
/// `reports/<app>/` directory with a `report.md` or any screenshot).
fn dir_has_a_file(dir: &Path) -> bool {
    std::fs::read_dir(dir)
        .map(|mut entries| entries.any(|e| e.is_ok()))
        .unwrap_or(false)
}

/// Roll a target's whole declared **weird-API surface** up into a §37 *coverage* histogram:
/// the count of APIs that derive each [`Representability`] rung, against the target's authored
/// `profile` (child `conformance-k55`).
///
/// Each element of `apis` is one API's §30 weirdness tags (the consumer flattens the platform
/// api-semantics registry into this); the per-API floor is [`representability`]. APIs with
/// **no** declared weirdness are *not* enumerated here — they derive [`Representability::DEFAULT`]
/// (`exact-static`) by construction (the trampoline-elision limit), so the histogram is
/// deliberately a distribution over the *residual* weird surface, the only part a profile ever
/// rates (ADR-0051). Rungs with a zero count are present in the returned map so the report can
/// show the full ladder.
pub fn representability_histogram<S: AsRef<str>>(
    profile: &CapabilityProfile,
    apis: &[Vec<S>],
) -> BTreeMap<Representability, usize> {
    use Representability::*;
    // Seed every rung at zero so the report renders the full ladder, then tally.
    let mut histogram: BTreeMap<Representability, usize> = [
        Research,
        NotRepresentable,
        UnsafeOnly,
        LossyButDocumented,
        IdiomaticConventional,
        ExactRuntime,
        ExactStatic,
    ]
    .into_iter()
    .map(|rung| (rung, 0))
    .collect();
    for weirdness in apis {
        *histogram
            .entry(representability(profile, weirdness))
            .or_insert(0) += 1;
    }
    histogram
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::capability::{CapabilityEntry, CapabilityProfile};

    /// The ladder orders best → worst as the design states, with `research` lowest.
    #[test]
    fn ladder_orders_best_to_worst() {
        use Representability::*;
        assert!(ExactStatic > ExactRuntime);
        assert!(ExactRuntime > IdiomaticConventional);
        assert!(IdiomaticConventional > LossyButDocumented);
        assert!(LossyButDocumented > UnsafeOnly);
        assert!(UnsafeOnly > NotRepresentable);
        assert!(NotRepresentable > Research);
        // Research is the global minimum; ExactStatic the global maximum.
        assert_eq!(
            [Research, ExactStatic, IdiomaticConventional].iter().min(),
            Some(&Research)
        );
        assert_eq!(Representability::DEFAULT, ExactStatic);
    }

    /// The serde token of a rung is its kebab-case spelling — the `.apiw` source of
    /// truth.
    #[test]
    fn serde_tokens_are_kebab_case() {
        use Representability::*;
        for (rung, token) in [
            (ExactStatic, "exact-static"),
            (ExactRuntime, "exact-runtime"),
            (IdiomaticConventional, "idiomatic-conventional"),
            (LossyButDocumented, "lossy-but-documented"),
            (UnsafeOnly, "unsafe-only"),
            (NotRepresentable, "not-representable"),
            (Research, "research"),
        ] {
            assert_eq!(serde_json::to_value(rung).unwrap(), token);
            let back: Representability = serde_json::from_value(token.into()).unwrap();
            assert_eq!(back, rung);
        }
    }

    /// A tiny two-dimension profile for floor tests: `foreign-thread-callbacks` is
    /// conventional (a bounce), `main-thread-dispatch` is exact-runtime.
    fn profile() -> CapabilityProfile {
        CapabilityProfile {
            id: "test".into(),
            doc: None,
            semantic: vec![
                CapabilityEntry {
                    dimension: "foreign-thread-callbacks".into(),
                    rung: Representability::IdiomaticConventional,
                    doc: None,
                },
                CapabilityEntry {
                    dimension: "main-thread-dispatch".into(),
                    rung: Representability::ExactRuntime,
                    doc: None,
                },
            ],
            app_form: vec![],
        }
    }

    /// No weirdness ⇒ the trampoline-elision default, `exact-static`.
    #[test]
    fn no_weirdness_is_exact_static() {
        let empty: &[&str] = &[];
        assert_eq!(
            representability(&profile(), empty),
            Representability::ExactStatic
        );
    }

    /// A reassuring-only API (weirdness present but demanding nothing) also stays
    /// `exact-static`.
    #[test]
    fn reassuring_only_is_exact_static() {
        assert_eq!(
            representability(&profile(), &["thread-safe", "static-lifetime"]),
            Representability::ExactStatic
        );
    }

    /// A single demanding tag ⇒ that capability's rung. `may-reenter` demands
    /// `foreign-thread-callbacks`, rated conventional here.
    #[test]
    fn single_demand_yields_its_rung() {
        assert_eq!(
            representability(&profile(), &["may-reenter"]),
            Representability::IdiomaticConventional
        );
    }

    /// Multiple demands ⇒ the worst (lowest) rung. `may-reenter` (conventional) +
    /// `main-thread-only` (exact-runtime) ⇒ conventional.
    #[test]
    fn floor_takes_the_worst_rung() {
        assert_eq!(
            representability(&profile(), &["main-thread-only", "may-reenter"]),
            Representability::IdiomaticConventional
        );
    }

    /// A demand the profile has not authored ⇒ `research` (unestablished), and being
    /// the lowest rung it dominates the floor.
    #[test]
    fn unauthored_demand_is_research() {
        // `nserror-out-param` demands `platform-errors`, absent from this profile.
        assert_eq!(
            representability(&profile(), &["nserror-out-param"]),
            Representability::Research
        );
        assert_eq!(
            representability(&profile(), &["may-reenter", "nserror-out-param"]),
            Representability::Research
        );
    }

    /// The §37 status token of each variant is its lowercase spelling — the `.apiw` /
    /// report source of truth, round-tripping through serde.
    #[test]
    fn conformance_status_tokens_are_lowercase() {
        use ConformanceStatus::*;
        for (status, token) in [
            (Pass, "pass"),
            (Partial, "partial"),
            (Research, "research"),
            (Unsupported, "unsupported"),
            (Failed, "failed"),
            (Skipped, "skipped"),
        ] {
            assert_eq!(status.as_str(), token);
            assert_eq!(serde_json::to_value(status).unwrap(), token);
            let back: ConformanceStatus = serde_json::from_value(token.into()).unwrap();
            assert_eq!(back, status);
        }
    }

    /// The coverage histogram tallies the floor per API and seeds the full ladder at zero, so
    /// every rung is present even when unhit.
    #[test]
    fn histogram_tallies_the_floor_over_the_weird_surface() {
        let p = profile();
        // Three APIs: one reassuring-only (exact-static), one `may-reenter`
        // (idiomatic-conventional here), one `nserror-out-param` (research — unauthored).
        let apis: Vec<Vec<&str>> = vec![
            vec!["thread-safe"],
            vec!["may-reenter"],
            vec!["nserror-out-param"],
        ];
        let h = representability_histogram(&p, &apis);
        assert_eq!(h.len(), 7, "all seven rungs seeded");
        assert_eq!(h[&Representability::ExactStatic], 1);
        assert_eq!(h[&Representability::IdiomaticConventional], 1);
        assert_eq!(h[&Representability::Research], 1);
        assert_eq!(h[&Representability::ExactRuntime], 0);
        assert_eq!(h.values().sum::<usize>(), 3);
    }

    /// The app-status scan reads the implementation + reports trees: an implemented app with a
    /// reports directory holding a file is `pass`; an implemented app with no evidence is
    /// `partial`; `_support` and stray files are skipped; a missing impl tree yields empty.
    #[test]
    fn app_status_scan_derives_pass_and_partial() {
        let root = std::env::temp_dir().join("apianyware-target-model-test-app-status");
        let _ = std::fs::remove_dir_all(&root);
        let impls = root.join("app-implementations").join("macos");
        std::fs::create_dir_all(impls.join("hello-window")).expect("impl dir");
        std::fs::create_dir_all(impls.join("note-editor")).expect("impl dir");
        std::fs::create_dir_all(impls.join("_support")).expect("support dir");
        std::fs::write(impls.join("README.md"), "# apps").expect("readme");
        // hello-window is VM-verified (a report file present); note-editor is not.
        let reports = root.join("bindings").join("macos").join("reports");
        std::fs::create_dir_all(reports.join("hello-window")).expect("reports dir");
        std::fs::write(reports.join("hello-window").join("report.md"), "ok").expect("report");

        let statuses = derive_app_statuses(&root, "macos");
        assert_eq!(
            statuses.iter().map(|s| s.app.as_str()).collect::<Vec<_>>(),
            vec!["hello-window", "note-editor"],
            "sorted; _support and README.md skipped"
        );
        let hello = &statuses[0];
        assert!(hello.implemented && hello.vm_verified);
        assert_eq!(hello.status, ConformanceStatus::Pass);
        let note = &statuses[1];
        assert!(note.implemented && !note.vm_verified);
        assert_eq!(note.status, ConformanceStatus::Partial);

        // A target with no implementation tree derives nothing (not an error).
        assert!(derive_app_statuses(&root.join("nonexistent"), "macos").is_empty());

        let _ = std::fs::remove_dir_all(&root);
    }
}
