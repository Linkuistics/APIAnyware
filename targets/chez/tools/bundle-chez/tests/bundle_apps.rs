//! Integration tests for the chez bundler's standalone surface.
//!
//! chez apps ship as self-contained binaries that embed the Chez kernel
//! (ADR-0009; design spec
//! `targets/chez/docs/design/2026-05-29-chez-standalone-distribution-design.md`). The
//! source-exec / system-Chez path it replaced is gone, so these tests
//! cover only what is cheap and deterministic to assert in a unit run:
//! the entry-point/dylib prechecks [`bundle_app`] performs *before* any
//! whole-program compile, and the per-app duplicate-import collision set.
//!
//! The heavy end-to-end path — whole-program compile → `make-boot-file` →
//! `cc`-link → assemble + codesign, then *launch* — is proven by the 060/010
//! spike (`targets/chez/docs/research/2026-05-29-chez-standalone-spike.md`) and re-verified
//! per app on a no-Chez VM in node-leaf 050. It is not re-run here: a single
//! standalone build is ~160 s for an AppKit app and needs `cc`, the Chez
//! kernel artifacts, and codesign — environment a default `cargo test` should
//! not assume.

use std::fs;
use std::path::PathBuf;
use std::process::Command;

use apianyware_bundle_chez::{bundle_app, compute_collisions, AppSpec, BundleError, Collisions};

fn workspace_root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .ancestors()
        .nth(4)
        .expect("workspace root above bundle-chez crate")
        .to_path_buf()
}

/// The app-implementations root: chez sample apps live at
/// `<apps_root>/<app>/<app>.sls` (§18 split, `move-chez-material-k12`). The
/// bundler reads the entry from here and resolves `(import (apianyware …))`
/// from [`bindings_root`] natively, staging both into one colocated
/// whole-program-compile tree.
fn apps_root() -> PathBuf {
    workspace_root()
        .join("targets")
        .join("chez")
        .join("app-implementations")
        .join("macos")
}

/// The binding package root: `apianyware/` (the package root — committed
/// `runtime/` + emitted `<fw>/` libraries) and `lib/` (the mandatory dylib,
/// ADR-0005) are its real children (§18 split).
fn bindings_root() -> PathBuf {
    workspace_root()
        .join("targets")
        .join("chez")
        .join("bindings")
        .join("macos")
}

fn chez_available() -> bool {
    Command::new("chez")
        .arg("--version")
        .output()
        .map(|o| o.status.success())
        .unwrap_or(false)
}

/// True when `apianyware-generate` has been run locally — the emitted
/// per-framework `apianyware/<fw>/` libraries exist. The hand-written
/// `apianyware/runtime/` is committed, but the framework modules are gitignored
/// (`.gitignore`: `apianyware/*` minus `runtime`), so the committed runtime is
/// no longer a valid proxy for "emit was run". The collision probe expands the
/// whole AppKit facade closure, so it needs the emitted appkit modules; without
/// this guard it fails with a library-not-found in any clean checkout. Mirrors
/// racket's `racket_emit_present()` / gerbil's `gerbil_tree_present()`.
fn chez_emit_present() -> bool {
    bindings_root()
        .join("apianyware")
        .join("appkit")
        .join("nswindow.sls")
        .is_file()
        && apps_root()
            .join("hello-window")
            .join("hello-window.sls")
            .is_file()
}

/// The standalone wrapper's collision set for `hello-window` must be
/// exactly the spike's 4 names, mapped to the right facades (spec §3, the
/// regression anchor for leaf 020). Heavy: the probe expands the whole
/// AppKit facade closure (~75s), so it is `#[ignore]`d — run with
/// `cargo test -p apianyware-bundle-chez -- --ignored
/// computes_hello_window_collision_set`. The probe is pure (no `.so`
/// writes), so running it against the source tree leaves it untouched.
#[test]
#[ignore = "heavy: expands the AppKit facade (~75s); run explicitly with --ignored"]
fn computes_hello_window_collision_set() {
    if !chez_available() {
        eprintln!("SKIPPED: chez not available");
        return;
    }
    if !chez_emit_present() {
        eprintln!("SKIPPED: chez emitted binding tree not present (generate not run locally)");
        return;
    }
    let entry = apps_root().join("hello-window").join("hello-window.sls");

    // The probe sets `(library-directories bindings_root)` and reads the entry
    // directly — no need to colocate the app under the bindings root.
    let collisions = compute_collisions(&entry, &bindings_root()).expect("collision probe");

    let expected = Collisions::from([
        (
            "(apianyware appkit)".to_string(),
            vec!["nsevent-location-in-window".to_string()],
        ),
        (
            "(apianyware foundation)".to_string(),
            vec![
                "nserror-code".to_string(),
                "nserror-domain".to_string(),
                "reverse".to_string(),
            ],
        ),
    ]);
    assert_eq!(collisions, expected, "hello-window collision set drifted");
}

/// The mandatory-dylib precheck (ADR-0005) fires before any expensive
/// compile work: a project whose entry exists but whose `lib/` lacks
/// `libAPIAnywareChez.dylib` fails fast with `DylibMissing`.
#[test]
fn rejects_missing_dylib() {
    let project = tempfile::tempdir().expect("project tempdir");
    // The app entry exists under the apps root (passes the EntryMissing
    // check), but the bindings root has no lib/libAPIAnywareChez.dylib.
    let apps_root = project.path().join("app-implementations");
    let bindings_root = project.path().join("bindings");
    let app_dir = apps_root.join("main");
    fs::create_dir_all(&app_dir).unwrap();
    fs::write(app_dir.join("main.sls"), "(import (chezscheme))\n(main)\n").unwrap();
    fs::create_dir_all(&bindings_root).unwrap();

    let spec = AppSpec::from_script_name("main");
    let out = tempfile::tempdir().expect("out tempdir");
    let err = bundle_app(&spec, &apps_root, &bindings_root, out.path()).unwrap_err();
    match err {
        BundleError::DylibMissing { .. } => {}
        other => panic!("expected DylibMissing, got {other:?}"),
    }
    // No partial bundle left behind (precheck runs before output is touched).
    assert!(
        fs::read_dir(out.path()).unwrap().next().is_none(),
        "output dir should be empty when bundle fails at precheck"
    );
}

/// A script name with no matching `<apps_root>/<script>/<script>.sls` entry
/// fails with `EntryMissing` — the first thing [`bundle_app`] checks.
#[test]
fn rejects_missing_app() {
    let temp = tempfile::tempdir().expect("tempdir");
    let spec = AppSpec::from_script_name("definitely-not-an-app");
    let err = bundle_app(&spec, &apps_root(), &bindings_root(), temp.path()).unwrap_err();
    assert!(
        matches!(err, BundleError::EntryMissing { .. }),
        "expected EntryMissing, got {err:?}"
    );
}
