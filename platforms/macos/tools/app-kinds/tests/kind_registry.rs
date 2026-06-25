//! The authored `platforms/macos/app-kinds/<kind>/kind.apiw` registry loads,
//! validates, and has the expected process-model shapes (the app-kinds done-bar).
//!
//! This is the standing guard that every authored app-kind conforms to
//! `app-kind.kdl-schema` AND passes the semantic checks (bundle/metadata coherence,
//! extension-point hosting, require/obligation uniqueness, name = containing
//! directory). As `mechanism-k35` authors only the `gui-app` exemplar, this guard
//! asserts that one kind end-to-end; child 2 (`remaining-kinds`) extends it to all
//! seven.

use std::path::PathBuf;

use apianyware_app_kinds::{
    ActivationPolicy, AppKindRegistry, BundleType, EntryModel, RunLoopModel, TerminationModel,
};

/// The authored kind directory, relative to this crate's manifest
/// (`platforms/macos/tools/app-kinds/` up to `platforms/macos/app-kinds/`).
fn app_kinds_dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("../../app-kinds")
        .canonicalize()
        .expect("platforms/macos/app-kinds/ resolves")
}

fn registry() -> AppKindRegistry {
    AppKindRegistry::load_dir(&app_kinds_dir())
        .expect("every authored app-kind loads, validates, and passes semantic checks")
}

/// The `gui-app` exemplar is authored and loads (the mechanism-k35 done-bar). As
/// child 2 adds kinds this count grows toward seven.
#[test]
fn gui_app_is_authored_and_loads() {
    let reg = registry();
    assert!(
        reg.get("gui-app").is_some(),
        "the gui-app exemplar is authored and loads"
    );
    assert!(!reg.is_empty(), "the registry has at least the exemplar");
}

/// `gui-app` carries the canonical bundled-NSApplication process model: an
/// `NSApplicationMain` entry, the AppKit run loop, `terminate:`, a regular Dock
/// presence, and a `.app` bundle with `CFBundlePackageType=APPL` and the standard
/// required Info.plist keys.
#[test]
fn gui_app_shape() {
    let reg = registry();
    let gui = reg.get("gui-app").expect("gui-app present");

    assert_eq!(gui.process.entry, EntryModel::NsApplicationMain);
    assert_eq!(gui.process.run_loop, RunLoopModel::NsApplication);
    assert_eq!(
        gui.process.termination,
        TerminationModel::NsApplicationTerminate
    );
    assert_eq!(gui.activation, ActivationPolicy::Regular);

    assert_eq!(gui.bundle.bundle_type, BundleType::App);
    assert_eq!(gui.bundle.package_type.as_deref(), Some("APPL"));
    assert_eq!(
        gui.bundle.principal_class_key.as_deref(),
        Some("NSPrincipalClass")
    );
    assert!(
        gui.bundle.extension_point.is_none(),
        "a gui-app is not hosted"
    );
    assert!(!gui.is_hosted());

    // The standard NSApplication bundle keys the bundlers actually emit.
    for key in [
        "CFBundleName",
        "CFBundleIdentifier",
        "CFBundleExecutable",
        "CFBundlePackageType",
        "LSMinimumSystemVersion",
    ] {
        assert!(
            gui.bundle.required_plist_keys.iter().any(|k| k == key),
            "gui-app requires Info.plist key `{key}`"
        );
    }
}

/// Every loaded kind names its containing directory and carries a coherent bundle
/// (load_dir would have errored otherwise — this re-asserts the invariant shape).
#[test]
fn every_kind_is_well_formed() {
    let reg = registry();
    for kind in reg.kinds() {
        assert!(!kind.name.is_empty(), "a kind has a name");
        // A bare executable carries no Info.plist keys; a real bundle may.
        if kind.bundle.bundle_type == BundleType::None {
            assert!(
                kind.bundle.required_plist_keys.is_empty(),
                "kind `{}` is a bare executable with no Info.plist keys",
                kind.name
            );
        }
    }
}
