//! The authored `targets/<id>/target.apiw` descriptors load, validate, and carry the
//! expected §17 facets (the target-descriptor done-bar).
//!
//! This is the standing guard that every authored target descriptor conforms to
//! `target.kdl-schema` AND passes the semantic checks (non-blank facets, id =
//! containing directory). `target-descriptor-k51` authored the four live targets, so
//! this guard asserts all **four** descriptors end-to-end with an exact count (no
//! extras, no gaps) and each target's distinguishing facets. The `targets/_shared/`
//! substrate has no `target.apiw`, so the registry skips it — proving the
//! descriptor-bearing-directory filter.

use std::path::PathBuf;

use apianyware_target_model::{RuntimeModel, TargetRegistry};

/// The `targets/` root, relative to this crate's manifest
/// (`targets/_shared/tools/target-model/` up to `targets/`).
fn targets_dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("../../..")
        .canonicalize()
        .expect("targets/ resolves")
}

fn registry() -> TargetRegistry {
    TargetRegistry::load_dir(&targets_dir())
        .expect("every authored target descriptor loads, validates, and passes semantic checks")
}

/// All four live targets are authored and load — and the registry holds *exactly*
/// those four (no extras, no gaps; `_shared/` carries no `target.apiw` and is skipped).
#[test]
fn all_four_targets_present() {
    let reg = registry();
    let expected = ["racket", "chez", "gerbil", "sbcl"];
    for id in expected {
        assert!(reg.get(id).is_some(), "missing authored target `{id}`");
    }
    assert_eq!(
        reg.len(),
        expected.len(),
        "registry has exactly the four live targets (no extras, no gaps; _shared skipped)"
    );
}

/// `sbcl` carries the canonical CL-family facets: a `common-lisp` family, `sb-alien`
/// FFI, a compiled-FFI runtime model, and the sole-native-unit adapter strategy.
#[test]
fn sbcl_facets() {
    let reg = registry();
    let sbcl = reg.get("sbcl").expect("sbcl present");
    assert_eq!(sbcl.family, "common-lisp");
    assert_eq!(sbcl.dialect.as_deref(), Some("ansi-cl"));
    assert_eq!(sbcl.implementation, "sbcl");
    assert_eq!(sbcl.ffi_backend, "sb-alien");
    assert_eq!(sbcl.runtime_model, RuntimeModel::CompiledFfi);
    assert_eq!(sbcl.projection_policy, "thin-direct");
    assert_eq!(sbcl.adapter_strategy, "sole-native-unit");
}

/// The three Scheme-family targets share `family "scheme"`; `racket` is the lone
/// interpreted-FFI target, `chez`/`gerbil` are compiled-FFI (ADR-0015).
#[test]
fn scheme_family_and_ffi_execution_model() {
    let reg = registry();
    for id in ["racket", "chez", "gerbil"] {
        assert_eq!(
            reg.get(id).expect("scheme target present").family,
            "scheme",
            "{id} is in the scheme family"
        );
    }
    assert_eq!(
        reg.get("racket").unwrap().runtime_model,
        RuntimeModel::InterpretedFfi,
        "racket is the interpreted-FFI target"
    );
    for id in ["chez", "gerbil", "sbcl"] {
        assert_eq!(
            reg.get(id).unwrap().runtime_model,
            RuntimeModel::CompiledFfi,
            "{id} is a compiled-FFI target"
        );
    }
}

/// Gerbil's dialect is omitted (its dialect coincides with its implementation), proving
/// the optional facet; every other descriptor names a dialect.
#[test]
fn gerbil_omits_dialect_others_name_one() {
    let reg = registry();
    assert_eq!(
        reg.get("gerbil").unwrap().dialect,
        None,
        "gerbil omits the optional dialect facet"
    );
    for id in ["racket", "chez", "sbcl"] {
        assert!(
            reg.get(id).unwrap().dialect.is_some(),
            "{id} names a dialect"
        );
    }
}

/// Every loaded descriptor names its containing directory (load_dir would have errored
/// otherwise) and carries non-blank required facets — re-assert the invariant shape.
#[test]
fn every_descriptor_is_well_formed() {
    let reg = registry();
    for t in reg.targets() {
        assert!(!t.id.is_empty(), "a target has an id");
        for (what, token) in [
            ("family", &t.family),
            ("implementation", &t.implementation),
            ("ffi-backend", &t.ffi_backend),
            ("projection-policy", &t.projection_policy),
            ("adapter-strategy", &t.adapter_strategy),
        ] {
            assert!(
                !token.trim().is_empty(),
                "target `{}` has a non-blank `{what}`",
                t.id
            );
        }
        // All four live targets bind ObjC directly (trampoline-elided), so the primary
        // projection posture is thin-direct.
        assert_eq!(
            t.projection_policy, "thin-direct",
            "target `{}` is thin-direct (direct ObjC, residual via adapter)",
            t.id
        );
    }
}
