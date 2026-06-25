//! The authored `platforms/macos/app-kinds/<kind>/kind.apiw` registry loads,
//! validates, and has the expected process-model shapes (the app-kinds done-bar).
//!
//! This is the standing guard that every authored app-kind conforms to
//! `app-kind.kdl-schema` AND passes the semantic checks (bundle/metadata coherence,
//! extension-point hosting, require/obligation uniqueness, name = containing
//! directory). `mechanism-k35` authored the `gui-app` exemplar; `remaining-kinds-k36`
//! authored the other six, so this guard asserts all **seven** kinds end-to-end with
//! an exact count (no extras, no gaps) and each kind's family shape.

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

/// All seven §14 kinds named in the brief are authored and load — and the registry
/// holds *exactly* those seven (no extras, no gaps), mirroring the patterns crate's
/// `all_brief_kinds_present` guard.
#[test]
fn all_seven_kinds_present() {
    let reg = registry();
    let expected = [
        "cli-tool",
        "gui-app",
        "menu-bar-daemon",
        "launch-agent",
        "spotlight-importer",
        "quicklook-extension",
        "finder-sync-extension",
    ];
    for name in expected {
        assert!(
            reg.get(name).is_some(),
            "missing authored app-kind `{name}`"
        );
    }
    assert_eq!(
        reg.len(),
        expected.len(),
        "registry has exactly the brief's seven kinds (no extras, no gaps)"
    );
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

/// The two **bare-executable** kinds (`cli-tool`, `launch-agent`) are `bundle "none"`
/// with no bundle metadata at all, and differ only in their process/run-loop model.
#[test]
fn bare_executable_kinds_shape() {
    let reg = registry();

    let cli = reg.get("cli-tool").expect("cli-tool present");
    assert_eq!(cli.bundle.bundle_type, BundleType::None);
    assert_eq!(cli.process.entry, EntryModel::CMain);
    assert_eq!(cli.process.run_loop, RunLoopModel::None);
    assert_eq!(cli.process.termination, TerminationModel::Return);
    assert_eq!(cli.activation, ActivationPolicy::Background);

    let agent = reg.get("launch-agent").expect("launch-agent present");
    assert_eq!(agent.bundle.bundle_type, BundleType::None);
    assert_eq!(agent.process.entry, EntryModel::CMain);
    assert_eq!(agent.process.run_loop, RunLoopModel::CfRunLoop);
    assert_eq!(agent.process.termination, TerminationModel::Signal);
    assert_eq!(agent.activation, ActivationPolicy::Background);

    // A bare executable carries no bundle metadata (the semantic check enforces this
    // at load; re-assert the realized shape).
    for kind in [cli, agent] {
        assert!(kind.bundle.package_type.is_none());
        assert!(kind.bundle.principal_class_key.is_none());
        assert!(kind.bundle.extension_point.is_none());
        assert!(
            kind.bundle.required_plist_keys.is_empty(),
            "bare-executable kind `{}` has no Info.plist keys",
            kind.name
        );
        assert!(!kind.is_hosted());
    }
}

/// `menu-bar-daemon` is the AppKit **accessory** app: same process model as a
/// `gui-app` but an `accessory` activation requiring `LSUIElement`.
#[test]
fn menu_bar_daemon_is_accessory() {
    let reg = registry();
    let mbd = reg.get("menu-bar-daemon").expect("menu-bar-daemon present");

    assert_eq!(mbd.process.entry, EntryModel::NsApplicationMain);
    assert_eq!(mbd.process.run_loop, RunLoopModel::NsApplication);
    assert_eq!(
        mbd.process.termination,
        TerminationModel::NsApplicationTerminate
    );
    assert_eq!(mbd.activation, ActivationPolicy::Accessory);
    assert_eq!(mbd.bundle.bundle_type, BundleType::App);
    assert!(
        mbd.bundle
            .required_plist_keys
            .iter()
            .any(|k| k == "LSUIElement"),
        "an accessory menu-bar-daemon requires LSUIElement"
    );
    assert!(!mbd.is_hosted());
}

/// The three **hosted** extension kinds (`spotlight-importer`, `quicklook-extension`,
/// `finder-sync-extension`) share the host-owned process model (`host-loaded` /
/// `host-driven` / `host-controlled`, `hosted` activation) and a hosted bundle.
#[test]
fn hosted_extension_kinds_shape() {
    let reg = registry();
    for name in [
        "spotlight-importer",
        "quicklook-extension",
        "finder-sync-extension",
    ] {
        let k = reg.get(name).expect("hosted kind present");
        assert_eq!(k.process.entry, EntryModel::HostLoaded, "{name} entry");
        assert_eq!(k.process.run_loop, RunLoopModel::HostDriven, "{name} loop");
        assert_eq!(
            k.process.termination,
            TerminationModel::HostControlled,
            "{name} termination"
        );
        assert_eq!(k.activation, ActivationPolicy::Hosted, "{name} activation");
        assert!(
            matches!(
                k.bundle.bundle_type,
                BundleType::Mdimporter | BundleType::Appex
            ),
            "{name} produces a hosted bundle"
        );
        assert!(k.is_hosted(), "{name} is hosted");
    }

    // The legacy Spotlight importer is a CFPlugIn `.mdimporter` — no principal class
    // (it registers a C factory), no NSExtension extension-point.
    let imp = reg.get("spotlight-importer").unwrap();
    assert_eq!(imp.bundle.bundle_type, BundleType::Mdimporter);
    assert!(imp.bundle.principal_class_key.is_none());
    assert!(imp.bundle.extension_point.is_none());

    // The two appex extensions plug into their NSExtension point and name a
    // principal class.
    for (name, point) in [
        ("quicklook-extension", "com.apple.quicklook.preview"),
        ("finder-sync-extension", "com.apple.FinderSync"),
    ] {
        let k = reg.get(name).unwrap();
        assert_eq!(
            k.bundle.bundle_type,
            BundleType::Appex,
            "{name} is an appex"
        );
        assert_eq!(
            k.bundle.package_type.as_deref(),
            Some("XPC!"),
            "{name} XPC!"
        );
        assert_eq!(
            k.bundle.extension_point.as_deref(),
            Some(point),
            "{name} plugs into {point}"
        );
        assert_eq!(
            k.bundle.principal_class_key.as_deref(),
            Some("NSExtensionPrincipalClass"),
            "{name} names its NSExtension principal class"
        );
    }
}

/// Every loaded kind names its containing directory, declares at least one test
/// obligation, and carries a coherent bundle (load_dir would have errored otherwise
/// — this re-asserts the invariant shape across all seven).
#[test]
fn every_kind_is_well_formed() {
    let reg = registry();
    for kind in reg.kinds() {
        assert!(!kind.name.is_empty(), "a kind has a name");
        assert!(
            !kind.test_obligations.is_empty(),
            "kind `{}` declares at least one test obligation",
            kind.name
        );
        // A bare executable carries no Info.plist keys; a real bundle may.
        if kind.bundle.bundle_type == BundleType::None {
            assert!(
                kind.bundle.required_plist_keys.is_empty(),
                "kind `{}` is a bare executable with no Info.plist keys",
                kind.name
            );
        }
        // An extension-point implies a hosted bundle (re-assert the semantic rule).
        if kind.bundle.extension_point.is_some() {
            assert!(
                kind.is_hosted(),
                "kind `{}` has an extension-point only on a hosted bundle",
                kind.name
            );
        }
    }
}
