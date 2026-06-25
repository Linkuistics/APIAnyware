//! The authored `targets/<id>/adapters/macos/spec.apiw` specs load, validate, and describe
//! each target's existing native adapter dylib (the policy-adapter-k54 done-bar).
//!
//! Standing guard that every authored adapter spec conforms to `adapter-spec.kdl-schema` AND
//! passes the focused semantic checks (the §26 role + service vocabularies, their uniqueness,
//! allow∩deny disjointness, id = the target directory, platform = the parent directory). It
//! also pins the per-target shape the survey established: the dylib name + symbol prefix, the
//! roles each library actually provides (racket richest, gerbil trampoline-only), the
//! main-thread-dispatch service every target needs, and the chez callback-registry parity
//! nuance.

use std::path::PathBuf;

use apianyware_target_model::{AdapterSpecRegistry, ServiceStatus};

fn targets_dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("../../..")
        .canonicalize()
        .expect("targets/ resolves")
}

fn registry() -> AdapterSpecRegistry {
    AdapterSpecRegistry::load_dir(&targets_dir())
        .expect("every authored adapter spec loads, validates, and passes semantic checks")
}

const TARGETS: [&str; 4] = ["racket", "chez", "gerbil", "sbcl"];

/// All four live targets are authored and load — and the registry holds *exactly* those four
/// (no extras, no gaps; `_shared/` carries no spec and is skipped).
#[test]
fn all_four_specs_present() {
    let reg = registry();
    for id in TARGETS {
        let s = reg
            .get(id)
            .unwrap_or_else(|| panic!("missing authored adapter spec `{id}`"));
        assert_eq!(s.platform, "macos", "{id} spec is for macos");
    }
    assert_eq!(reg.len(), TARGETS.len(), "exactly the four live targets");
}

/// Each spec's output names the target's real dylib + ABI prefix (the survey: APIAnyware<T>,
/// a dynamic library, aw_<t>_ symbols per ADR-0011 hermetic naming).
#[test]
fn output_names_the_real_dylib_and_prefix() {
    let expected: [(&str, &str, &str); 4] = [
        ("racket", "APIAnywareRacket", "aw_racket_"),
        ("chez", "APIAnywareChez", "aw_chez_"),
        ("gerbil", "APIAnywareGerbil", "aw_gerbil_"),
        ("sbcl", "APIAnywareSbcl", "aw_sbcl_"),
    ];
    let reg = registry();
    for (id, library, prefix) in expected {
        let s = reg.get(id).unwrap();
        assert_eq!(s.output.library, library, "{id} library name");
        assert_eq!(s.output.kind, "dynamic-library", "{id} library kind");
        assert_eq!(
            s.output.symbol_prefix.as_deref(),
            Some(prefix),
            "{id} symbol prefix"
        );
    }
}

/// Every target needs the main-thread-dispatch service — the load-bearing constraint all four
/// share (the async/callback path must fire on the main thread).
#[test]
fn every_target_requires_main_thread_dispatch() {
    let reg = registry();
    for id in TARGETS {
        let s = reg.get(id).unwrap();
        let svc = s
            .service("main-thread-dispatch")
            .unwrap_or_else(|| panic!("{id} spec lacks main-thread-dispatch"));
        assert_eq!(
            svc.status,
            ServiceStatus::Required,
            "{id}: main-thread-dispatch should be required"
        );
    }
}

/// Each library provides the roles its sources actually ship: every target has the trampoline
/// trio (thread + error + generic-erasure); gerbil is trampoline-only (no callback-adapter —
/// its callback home is in gsc); racket/chez/sbcl carry callback-adapter; sbcl alone carries
/// reflection-adapter (SubclassSynth).
#[test]
fn roles_match_each_library_shape() {
    let reg = registry();
    for id in TARGETS {
        let s = reg.get(id).unwrap();
        for role in ["thread-adapter", "error-adapter", "generic-erasure-adapter"] {
            assert!(s.has_role(role), "{id} should provide `{role}`");
        }
    }
    // gerbil's dylib is strictly trampoline-only — no callback-adapter here (it lives in gsc).
    assert!(
        !reg.get("gerbil").unwrap().has_role("callback-adapter"),
        "gerbil's trampoline-only dylib has no callback-adapter (callbacks live in its gsc home)"
    );
    for id in ["racket", "chez", "sbcl"] {
        assert!(
            reg.get(id).unwrap().has_role("callback-adapter"),
            "{id} should provide callback-adapter"
        );
    }
    // SubclassSynth makes sbcl the one target with a reflective subclass IMP installer.
    assert!(
        reg.get("sbcl").unwrap().has_role("reflection-adapter"),
        "sbcl should provide reflection-adapter (SubclassSynth)"
    );
}

/// The chez callback-registry is `parity` — exported for cross-target parity, but the chez
/// runtime uses Scheme-side lock-object instead (the one non-`required` service nuance).
#[test]
fn chez_callback_registry_is_parity() {
    let reg = registry();
    let svc = reg
        .get("chez")
        .unwrap()
        .service("callback-registry")
        .expect("chez provides callback-registry");
    assert_eq!(svc.status, ServiceStatus::Parity);
}

/// Every spec's direct-call policy allows the directly-reachable ObjC surface (the adapter is
/// not in that path) and denies the Swift-native async residual (it needs the trampoline).
#[test]
fn direct_call_policy_allows_objc_denies_the_residual() {
    let reg = registry();
    for id in TARGETS {
        let s = reg.get(id).unwrap();
        let policy = s
            .direct_call_policy
            .as_ref()
            .unwrap_or_else(|| panic!("{id} spec has a direct-call policy"));
        assert!(
            policy
                .allow
                .iter()
                .any(|r| r.category == "directly-reachable-objc"),
            "{id}: directly-reachable-objc should be allowed (direct)"
        );
        assert!(
            policy
                .deny
                .iter()
                .any(|r| r.category == "swift-native-async"),
            "{id}: swift-native-async should be denied (adapter-mediated)"
        );
    }
}
