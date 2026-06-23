//! Integration tests for the chez bundler's standalone surface.
//!
//! chez apps ship as self-contained binaries that embed the Chez kernel
//! (ADR-0009; design spec
//! `generation/targets/chez/docs/design/2026-05-29-chez-standalone-distribution-design.md`). The
//! source-exec / system-Chez path it replaced is gone, so these tests
//! cover only what is cheap and deterministic to assert in a unit run:
//! the entry-point/dylib prechecks [`bundle_app`] performs *before* any
//! whole-program compile, and the per-app duplicate-import collision set.
//!
//! The heavy end-to-end path — whole-program compile → `make-boot-file` →
//! `cc`-link → assemble + codesign, then *launch* — is proven by the 060/010
//! spike (`generation/targets/chez/docs/research/2026-05-29-chez-standalone-spike.md`) and re-verified
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
        .nth(3)
        .expect("workspace root above bundle-chez crate")
        .to_path_buf()
}

fn chez_root() -> PathBuf {
    workspace_root()
        .join("generation")
        .join("targets")
        .join("chez")
}

fn chez_available() -> bool {
    Command::new("chez")
        .arg("--version")
        .output()
        .map(|o| o.status.success())
        .unwrap_or(false)
}

fn chez_runtime_present() -> bool {
    chez_root()
        .join("apianyware")
        .join("runtime")
        .join("ffi.sls")
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
    if !chez_runtime_present() {
        eprintln!("SKIPPED: chez runtime tree not present");
        return;
    }
    let root = chez_root();
    let entry = root
        .join("apps")
        .join("hello-window")
        .join("hello-window.sls");

    let collisions = compute_collisions(&entry, &root).expect("collision probe");

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
    // apps/<script>/<script>.sls exists (passes the EntryMissing check),
    // but there is no lib/libAPIAnywareChez.dylib.
    let app_dir = project.path().join("apps").join("main");
    fs::create_dir_all(&app_dir).unwrap();
    fs::write(app_dir.join("main.sls"), "(import (chezscheme))\n(main)\n").unwrap();

    let spec = AppSpec::from_script_name("main");
    let out = tempfile::tempdir().expect("out tempdir");
    let err = bundle_app(&spec, project.path(), out.path()).unwrap_err();
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

/// A script name with no matching `apps/<script>/<script>.sls` entry fails
/// with `EntryMissing` — the first thing [`bundle_app`] checks.
#[test]
fn rejects_missing_app() {
    let temp = tempfile::tempdir().expect("tempdir");
    let spec = AppSpec::from_script_name("definitely-not-an-app");
    let err = bundle_app(&spec, &chez_root(), temp.path()).unwrap_err();
    assert!(
        matches!(err, BundleError::EntryMissing { .. }),
        "expected EntryMissing, got {err:?}"
    );
}
