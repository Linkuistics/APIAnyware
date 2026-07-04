//! Integration tests for the sbcl bundler.
//!
//! The cheap, deterministic check (the missing-driver precheck) runs in any
//! `cargo test`. The heavy end-to-end build — drive `save-lisp-and-die`, assemble
//! the bundle, then revive the dumped image through the stub — needs SBCL + the
//! swift toolchain and is seconds-to-minutes long, so it is `#[ignore]`d and run
//! explicitly:
//!
//! ```text
//! cargo test -p apianyware-bundle-sbcl -- --ignored --nocapture
//! ```

use std::path::PathBuf;
use std::process::Command;

use apianyware_bundle_sbcl::{bundle_app, AppSpec, BundleError};

fn workspace_root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .ancestors()
        .nth(4)
        .expect("workspace root above bundle-sbcl crate")
        .to_path_buf()
}

/// The app-implementations root: sbcl sample apps live at
/// `<apps_root>/<script>/dump.lisp` (§18 split, `move-sbcl-material-k14`). The
/// bundler needs only this root — each app's `dump.lisp` self-resolves the
/// binding tree via `../_support/load-bindings.lisp`, so no bindings root and no
/// stitching fixture is required.
fn apps_root() -> PathBuf {
    workspace_root()
        .join("targets")
        .join("sbcl")
        .join("app-implementations")
        .join("macos")
}

fn driver(script: &str) -> PathBuf {
    apps_root().join(script).join("dump.lisp")
}

fn sbcl_tree_present() -> bool {
    driver("hello-window").is_file()
}

/// A script with no matching `apps/<script>/dump.lisp` fails with
/// `DumpDriverMissing` — before any toolchain work.
#[test]
fn rejects_missing_driver() {
    if !sbcl_tree_present() {
        eprintln!("SKIPPED: sbcl app tree not present");
        return;
    }
    let temp = tempfile::tempdir().expect("tempdir");
    let spec = AppSpec::from_script_name("definitely-not-an-app");
    let err = bundle_app(&spec, &apps_root(), temp.path(), &workspace_root()).unwrap_err();
    assert!(
        matches!(err, BundleError::DumpDriverMissing { .. }),
        "expected DumpDriverMissing, got {err:?}"
    );
}

fn sbcl_available() -> bool {
    Command::new("sbcl")
        .arg("--version")
        .output()
        .map(|o| o.status.success())
        .unwrap_or(false)
}

/// End-to-end: build the hello-window `.app`, assert its self-contained layout,
/// then **revive the dumped image through the stub** with the construction-smoke
/// env — proving dump → stub `execv` → `DYLD_FALLBACK` → startup re-resolution all
/// work in the bundled artifact on-host. (The clean-target guarantee — libzstd
/// resolved only via the vendored copy — is the VM's bar; here Homebrew's libzstd
/// is present, so this proves the pipeline runs and the image revives.)
#[test]
#[ignore = "heavy: drives save-lisp-and-die end-to-end; run explicitly with --ignored"]
fn builds_and_revives_hello_window_app() {
    if !sbcl_tree_present() {
        eprintln!("SKIPPED: sbcl app tree not present");
        return;
    }
    if !sbcl_available() {
        eprintln!("SKIPPED: sbcl not found");
        return;
    }
    let out = tempfile::tempdir().expect("out tempdir");
    let spec = AppSpec::from_script_name("hello-window");

    let app = bundle_app(&spec, &apps_root(), out.path(), &workspace_root())
        .expect("bundle hello-window");

    // Layout: stub is CFBundleExecutable; image is a Resource; libzstd vendored.
    let stub = app.join("Contents").join("MacOS").join("hello-window");
    let image = app.join("Contents").join("Resources").join("hello-window");
    let zstd = app
        .join("Contents")
        .join("Frameworks")
        .join("libzstd.1.dylib");
    assert!(stub.is_file(), "stub at Contents/MacOS/hello-window");
    assert!(image.is_file(), "image at Contents/Resources/hello-window");
    assert!(zstd.is_file(), "libzstd vendored into Frameworks");
    assert!(
        app.join("Contents").join("Info.plist").is_file(),
        "Info.plist present"
    );
    // hello-window is residual: its applicationWillTerminate: delegate needs
    // libAPIAnywareSbcl's subclass bounce shim (k70), so the dylib is vendored.
    assert!(
        app.join("Contents")
            .join("Frameworks")
            .join("libAPIAnywareSbcl.dylib")
            .is_file(),
        "hello-window loads libAPIAnywareSbcl — dylib vendored into Frameworks"
    );

    // Revive through the stub: the construction-smoke env makes the image build
    // the UI (exercising startup re-resolution in the dumped image) then exit 0.
    let revive = Command::new(&stub)
        .env("AW_HELLO_SMOKE", "1")
        .output()
        .expect("run stub");
    let combined = format!(
        "{}{}",
        String::from_utf8_lossy(&revive.stdout),
        String::from_utf8_lossy(&revive.stderr)
    );
    assert!(
        revive.status.success(),
        "stub→image revive exited non-zero:\n{combined}"
    );
    assert!(
        combined.contains("revived hello-window construction OK"),
        "revive smoke marker missing:\n{combined}"
    );
}
