//! The authored `targets/<id>/conformance/macos.apiw` reports load, validate, and state each
//! target's macOS §37 conformance judgment (the conformance-k55 done-bar).
//!
//! Standing guard that every authored conformance report conforms to `conformance.kdl-schema`
//! AND passes the focused semantic checks (app-kind vocabulary + per-report/per-entry
//! uniqueness, id = the grandparent directory, platform = the file stem). The load-bearing
//! test is [`authored_judgment_is_grounded_in_derived_reality`]: it runs the authored-vs-derived
//! cross-check against the REAL shipped app-implementations + VM-verify reports, so an authored
//! claim that drifts from the binding (an `unsupported`/`pass` call contradicting a sample
//! app's actual VM-verify status) trips here — the invariant that makes the hybrid report safe.

use std::path::PathBuf;

use apianyware_target_model::{
    crosscheck, derive_app_statuses, ConformanceRegistry, ConformanceStatus,
};

/// The `targets/` root, relative to this crate's manifest
/// (`targets/_shared/tools/target-model/` up to `targets/`).
fn targets_dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("../../..")
        .canonicalize()
        .expect("targets/ resolves")
}

fn registry() -> ConformanceRegistry {
    ConformanceRegistry::load_dir(&targets_dir())
        .expect("every authored conformance report loads, validates, and passes semantic checks")
}

const TARGETS: [&str; 4] = ["racket", "chez", "gerbil", "sbcl"];

/// All four live targets are authored and load — and the registry holds *exactly* those four
/// (no extras, no gaps; `_shared/` carries no report and is skipped).
#[test]
fn all_four_reports_present() {
    let reg = registry();
    for id in TARGETS {
        let r = reg
            .get(id)
            .unwrap_or_else(|| panic!("missing authored conformance report `{id}`"));
        assert_eq!(r.platform, "macos", "{id} report is for macos");
    }
    assert_eq!(
        reg.len(),
        TARGETS.len(),
        "registry has exactly the four live targets (no extras, no gaps; _shared skipped)"
    );
}

/// Every target ships GUI apps: each declares `gui-app` as `pass`, the shared spine of the
/// four bindings (self-contained .app, seven GUI sample apps VM-verified).
#[test]
fn every_target_passes_gui_app() {
    let reg = registry();
    for id in TARGETS {
        let r = reg.get(id).unwrap();
        let gui = r
            .support("gui-app")
            .unwrap_or_else(|| panic!("{id} report does not make a gui-app support call"));
        assert_eq!(
            gui.status,
            ConformanceStatus::Pass,
            "{id}: gui-app should pass"
        );
        assert!(
            !gui.exemplars.is_empty(),
            "{id}: gui-app pass should be grounded in exemplar apps"
        );
    }
}

/// The plugin-style app-kinds every target shares are honestly `research` (loading the runtime
/// into a loadable bundle is the §36 hard case, app-form plugin = research) — not over-claimed.
#[test]
fn plugin_app_kinds_are_research_everywhere() {
    let reg = registry();
    for id in TARGETS {
        let r = reg.get(id).unwrap();
        for kind in [
            "spotlight-importer",
            "quicklook-extension",
            "finder-sync-extension",
        ] {
            let support = r
                .support(kind)
                .unwrap_or_else(|| panic!("{id} report does not rate `{kind}`"));
            assert_eq!(
                support.status,
                ConformanceStatus::Research,
                "{id}: `{kind}` should be research (the §36 plugin-hosting hard case)"
            );
        }
    }
}

/// The load-bearing invariant (node-brief D1): the authored judgment must not contradict the
/// DERIVED reality. For each target, cross-check the authored `app-support` exemplars against
/// the per-app status derived from the shipped `app-implementations/` + VM-verify `reports/`.
/// Zero contradictions — an authored `pass`/`unsupported` call that drifts from a sample app's
/// real VM-verify status would fail here.
#[test]
fn authored_judgment_is_grounded_in_derived_reality() {
    let reg = registry();
    let targets = targets_dir();
    for id in TARGETS {
        let report = reg.get(id).unwrap();
        let derived = derive_app_statuses(&targets.join(id), "macos");
        let contradictions = crosscheck(report, &derived);
        assert!(
            contradictions.is_empty(),
            "{id}: authored conformance contradicts derived reality:\n{}",
            contradictions
                .iter()
                .map(|c| format!("  - {}", c.message))
                .collect::<Vec<_>>()
                .join("\n")
        );
    }
}

/// The derivation actually sees the shipped apps (a guard against a silently-empty scan that
/// would make the cross-check vacuously pass): every target derives at least the seven GUI
/// apps, each VM-verified to `pass`.
#[test]
fn derived_app_statuses_see_the_vm_verified_apps() {
    let targets = targets_dir();
    for id in TARGETS {
        let derived = derive_app_statuses(&targets.join(id), "macos");
        let passing = derived
            .iter()
            .filter(|s| s.status == ConformanceStatus::Pass)
            .count();
        assert!(
            passing >= 7,
            "{id}: expected >= 7 VM-verified (pass) apps, derived {passing} from app-implementations/ + reports/"
        );
    }
}
