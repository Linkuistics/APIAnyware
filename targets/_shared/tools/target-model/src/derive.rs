//! The **representability** model (REFACTOR §7.7/§20; node-brief D2, child
//! `capability-k52`): the unified 7-rung [`Representability`] ladder and the
//! [`representability`] **floor** that derives a per-API status from an authored
//! [`CapabilityProfile`] and the platform §30 source-weirdness an API carries.
//!
//! Representability is **derived, never authored** (node-brief D1): committing a
//! per-API status would duplicate a derivable fact and rot against SDK / binding
//! drift, so the status is computed on demand and stays uncommitted (constraint 4).
//! This module is the pure kernel of that computation — a *library*, with the CLI /
//! report surface deferred to child 5 (conformance). It is also **domain-pure**: the
//! floor takes the API's weirdness *tags*, not the platform's `ApiSemanticsRegistry`,
//! so the targets-domain crate never depends on the platforms-domain crate. A consumer
//! (child 5) loads the platform api-semantics registry, reads an API's weirdness, and
//! passes the tags here.
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
}
