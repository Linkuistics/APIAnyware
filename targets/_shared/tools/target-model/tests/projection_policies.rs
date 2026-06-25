//! The authored `targets/<id>/policies/macos/projection.apiw` policies load, validate, and
//! state each target's macOS projection posture (the policy-adapter-k54 done-bar).
//!
//! Standing guard that every authored projection policy conforms to `policy.kdl-schema` AND
//! passes the focused semantic checks (per-policy concern uniqueness, id = the target
//! directory, platform = the parent directory). It also pins the **shared posture**: all four
//! live targets are `thin-direct` — the directly-reachable ObjC surface is a `direct-call`
//! (trampoline-elision), and the Swift-native residual routes through the adapter.

use std::path::PathBuf;

use apianyware_target_model::{ProjectionPolicyRegistry, SpectrumPoint};

/// The `targets/` root, relative to this crate's manifest
/// (`targets/_shared/tools/target-model/` up to `targets/`).
fn targets_dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("../../..")
        .canonicalize()
        .expect("targets/ resolves")
}

fn registry() -> ProjectionPolicyRegistry {
    ProjectionPolicyRegistry::load_dir(&targets_dir())
        .expect("every authored projection policy loads, validates, and passes semantic checks")
}

const TARGETS: [&str; 4] = ["racket", "chez", "gerbil", "sbcl"];

/// All four live targets are authored and load — and the registry holds *exactly* those four
/// (no extras, no gaps; `_shared/` carries no policy and is skipped).
#[test]
fn all_four_policies_present() {
    let reg = registry();
    for id in TARGETS {
        let p = reg
            .get(id)
            .unwrap_or_else(|| panic!("missing authored projection policy `{id}`"));
        assert_eq!(p.platform, "macos", "{id} policy is for macos");
    }
    assert_eq!(
        reg.len(),
        TARGETS.len(),
        "registry has exactly the four live targets (no extras, no gaps; _shared skipped)"
    );
}

/// Every target's headline posture is `thin-direct` — bind the directly-reachable surface
/// natively, route only the irreducible residual through the adapter (the CONTEXT target-model
/// model the four bindings embody).
#[test]
fn every_target_is_thin_direct() {
    let reg = registry();
    for id in TARGETS {
        let p = reg.get(id).unwrap();
        assert_eq!(
            p.posture.as_deref(),
            Some("thin-direct"),
            "{id} posture should be thin-direct"
        );
    }
}

/// The shared spine: the directly-reachable ObjC surface is a `direct-call` for every target
/// (the trampoline-elision limit) — the projection posture that makes the binding thin.
#[test]
fn directly_reachable_objc_is_a_direct_call_everywhere() {
    let reg = registry();
    for id in TARGETS {
        let p = reg.get(id).unwrap();
        let choice = p
            .choice("directly-reachable-objc")
            .unwrap_or_else(|| panic!("{id} policy does not map directly-reachable-objc"));
        assert_eq!(
            choice.spectrum,
            SpectrumPoint::DirectCall,
            "{id}: directly-reachable ObjC should be a direct call"
        );
    }
}

/// The Swift-native residual every target shares routes off the direct path: async + throws
/// are adapter-call-plus-wrapper, value returns are an adapter-call (OpaqueHandle boxing).
#[test]
fn the_swift_native_residual_routes_through_the_adapter() {
    let reg = registry();
    for id in TARGETS {
        let p = reg.get(id).unwrap();
        for concern in ["swift-native-async", "swift-native-throws"] {
            let c = p
                .choice(concern)
                .unwrap_or_else(|| panic!("{id} policy does not map `{concern}`"));
            assert_eq!(
                c.spectrum,
                SpectrumPoint::AdapterCallPlusWrapper,
                "{id}: `{concern}` should be adapter-call-plus-wrapper"
            );
        }
        let value = p
            .choice("swift-native-value-return")
            .unwrap_or_else(|| panic!("{id} policy does not map swift-native-value-return"));
        assert_eq!(
            value.spectrum,
            SpectrumPoint::AdapterCall,
            "{id}: value returns should be an adapter call"
        );
    }
}
