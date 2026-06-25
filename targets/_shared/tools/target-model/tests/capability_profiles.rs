//! The authored `targets/<id>/capability.apiw` profiles load, validate, and drive the
//! representability derivation (the capability-k52 done-bar).
//!
//! This is the standing guard that every authored capability profile conforms to
//! `capability.kdl-schema` AND passes the focused semantic checks (face-conditional
//! dimensions, per-face uniqueness, id = containing directory). It also exercises the
//! genuinely novel model of ws6 — the [`representability`] floor — end-to-end against
//! the four profiles, asserting:
//!
//! - the `foreign-thread-callbacks` differentiator (chez ACTIVATES the foreign thread →
//!   `exact-runtime`; racket / gerbil / sbcl BOUNCE to main → `idiomatic-conventional`);
//! - a no-weirdness API derives the trampoline-elision default `exact-static`;
//! - a §30-weirdness-carrying API derives the per-target floor.
//!
//! The weirdness tags used here are the §30 tokens the platform's api-semantics
//! declarations carry (e.g. `platforms/macos/tests/api-semantics/threading.apiw`
//! declares `NSRunLoop run` with `may-reenter`, `NSApplication run` with
//! `main-thread-only` + `requires-run-loop`). They are passed as literal tags — not
//! read from the platform registry — so this targets-domain test stays decoupled from
//! the platforms-domain crate (the domain rule); a future child-5 consumer wires the
//! two registries together.

use std::path::PathBuf;

use apianyware_target_model::{representability, CapabilityRegistry, Representability};

/// The `targets/` root, relative to this crate's manifest
/// (`targets/_shared/tools/target-model/` up to `targets/`).
fn targets_dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("../../..")
        .canonicalize()
        .expect("targets/ resolves")
}

fn registry() -> CapabilityRegistry {
    CapabilityRegistry::load_dir(&targets_dir())
        .expect("every authored capability profile loads, validates, and passes semantic checks")
}

/// All four live targets are authored and load — and the registry holds *exactly* those
/// four (no extras, no gaps; `_shared/` carries no `capability.apiw` and is skipped).
#[test]
fn all_four_profiles_present() {
    let reg = registry();
    let expected = ["racket", "chez", "gerbil", "sbcl"];
    for id in expected {
        assert!(
            reg.get(id).is_some(),
            "missing authored capability profile `{id}`"
        );
    }
    assert_eq!(
        reg.len(),
        expected.len(),
        "registry has exactly the four live targets (no extras, no gaps; _shared skipped)"
    );
}

/// The `foreign-thread-callbacks` differentiator (node-brief D2, the capability-k52
/// done-bar): chez genuinely ACTIVATES the foreign thread (ADR-0016) → `exact-runtime`;
/// racket / gerbil / sbcl BOUNCE to the main thread (ADR-0014/0022/0035) → the
/// conventional rung.
#[test]
fn foreign_thread_callbacks_differentiates_activation_from_bounce() {
    let reg = registry();
    assert_eq!(
        reg.get("chez")
            .unwrap()
            .semantic_rung("foreign-thread-callbacks"),
        Some(Representability::ExactRuntime),
        "chez activates the foreign thread → exact-runtime"
    );
    for id in ["racket", "gerbil", "sbcl"] {
        assert_eq!(
            reg.get(id)
                .unwrap()
                .semantic_rung("foreign-thread-callbacks"),
            Some(Representability::IdiomaticConventional),
            "{id} bounces foreign-thread callbacks to main → idiomatic-conventional"
        );
    }
}

/// An API with NO §30 weirdness derives the trampoline-elision default, `exact-static`,
/// for every target — the vast directly-reachable ObjC surface is fully represented.
#[test]
fn no_weirdness_derives_exact_static_for_every_target() {
    let reg = registry();
    let no_weirdness: &[&str] = &[];
    for id in ["racket", "chez", "gerbil", "sbcl"] {
        let profile = reg.get(id).unwrap();
        assert_eq!(
            representability(profile, no_weirdness),
            Representability::ExactStatic,
            "{id}: a no-weirdness API is fully represented (trampoline-elision limit)"
        );
    }
}

/// A `may-reenter` API (e.g. `NSRunLoop run`) derives the foreign-thread-callbacks rung
/// — the activation-vs-bounce difference shows up in the *derived per-API status*, not
/// just the profile: exact-runtime for chez, conventional for the others.
#[test]
fn may_reenter_api_derives_the_foreign_thread_rung() {
    let reg = registry();
    let weirdness = ["may-reenter"];
    assert_eq!(
        representability(reg.get("chez").unwrap(), &weirdness),
        Representability::ExactRuntime,
        "chez: may-reenter → foreign-thread-callbacks → exact-runtime (activation)"
    );
    for id in ["racket", "gerbil", "sbcl"] {
        assert_eq!(
            representability(reg.get(id).unwrap(), &weirdness),
            Representability::IdiomaticConventional,
            "{id}: may-reenter → foreign-thread-callbacks → idiomatic-conventional (bounce)"
        );
    }
}

/// A multi-weirdness API takes the FLOOR (worst rung). `NSApplication run` carries
/// `main-thread-only` (→ main-thread-dispatch, exact-runtime) + `requires-run-loop`
/// (→ async-event-integration, idiomatic-conventional); the floor is conventional, for
/// every target (all four bounce/integrate the run loop the same way).
#[test]
fn multi_weirdness_takes_the_floor() {
    let reg = registry();
    let weirdness = ["main-thread-only", "requires-run-loop"];
    for id in ["racket", "chez", "gerbil", "sbcl"] {
        assert_eq!(
            representability(reg.get(id).unwrap(), &weirdness),
            Representability::IdiomaticConventional,
            "{id}: floor over {{exact-runtime, idiomatic-conventional}} is idiomatic-conventional"
        );
    }
}

/// An `nserror-out-param` API (the §30 error weirdness `NSError**` shapes carry) derives
/// the `platform-errors` rung — exact-runtime for all four (NSError surfaced as
/// conditions/exceptions; ADR-0037 for the CL family).
#[test]
fn nserror_api_derives_platform_errors_rung() {
    let reg = registry();
    let weirdness = ["nserror-out-param"];
    for id in ["racket", "chez", "gerbil", "sbcl"] {
        assert_eq!(
            representability(reg.get(id).unwrap(), &weirdness),
            Representability::ExactRuntime,
            "{id}: nserror-out-param → platform-errors → exact-runtime"
        );
    }
}

/// Every authored profile rates all eighteen §20 semantic dimensions and all five
/// app-form dimensions — so the derivation never falls through to the `research` default
/// for an authored target (an unrated demanded dimension would silently derive
/// `research`). This guards profile completeness as the standing invariant.
#[test]
fn every_profile_rates_the_full_vocabulary() {
    use apianyware_target_model::vocab::{APP_FORM, SEMANTIC};
    let reg = registry();
    for id in ["racket", "chez", "gerbil", "sbcl"] {
        let p = reg.get(id).unwrap();
        for dim in SEMANTIC {
            assert!(
                p.semantic_rung(dim).is_some(),
                "{id} profile is missing semantic dimension `{dim}`"
            );
        }
        for dim in APP_FORM {
            assert!(
                p.app_form_rung(dim).is_some(),
                "{id} profile is missing app-form dimension `{dim}`"
            );
        }
    }
}
