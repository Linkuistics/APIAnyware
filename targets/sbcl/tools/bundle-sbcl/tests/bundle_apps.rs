//! Integration tests for the sbcl bundler.
//!
//! The cheap, deterministic checks (residual classification against the real app
//! tree, the missing-driver precheck) run in any `cargo test`. The heavy
//! end-to-end build — drive `save-lisp-and-die`, assemble the bundle, then revive
//! the dumped image through the stub — needs SBCL + the swift toolchain and is
//! seconds-to-minutes long, so it is `#[ignore]`d and run explicitly:
//!
//! ```text
//! cargo test -p apianyware-bundle-sbcl -- --ignored --nocapture
//! ```

use std::fs;
use std::path::PathBuf;
use std::process::Command;
use std::sync::OnceLock;

use apianyware_bundle_sbcl::{bundle_app, driver_needs_dylib, AppSpec, BundleError};

fn workspace_root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .ancestors()
        .nth(4)
        .expect("workspace root above bundle-sbcl crate")
        .to_path_buf()
}

/// The sbcl app tree the bundler expects: a single `source_root` with an `apps/`
/// child, from which it reads `apps/<script>/dump.lisp`. The §18 refactor
/// (`move-sbcl-material-k14`) moved the apps to
/// `targets/sbcl/app-implementations/macos/`, so we stitch that home back into
/// the `apps/`-rooted shape the bundler expects with a symlink fixture — the same
/// directory-symlink case the bundler already canonicalizes through (mirrors
/// gerbil's `gerbil_root()`; sbcl needs only `apps/`, because each app's own
/// `dump.lisp` loads the binding tree self-relative via `load-bindings.lisp`).
///
/// TODO(bindings/adapter-model workstream, root brief item 6): teach the bundler
/// the apps-root / bindings-root split natively so this fixture isn't needed.
fn sbcl_root() -> PathBuf {
    static FIXTURE: OnceLock<PathBuf> = OnceLock::new();
    FIXTURE
        .get_or_init(|| {
            let apps = workspace_root()
                .join("targets")
                .join("sbcl")
                .join("app-implementations")
                .join("macos");
            let fixture = PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join("sbcl-bundle-fixture");
            let _ = fs::remove_dir_all(&fixture);
            fs::create_dir_all(&fixture).expect("create sbcl bundle fixture root");
            std::os::unix::fs::symlink(&apps, fixture.join("apps"))
                .unwrap_or_else(|e| panic!("symlink apps -> {apps:?}: {e}"));
            fixture
        })
        .clone()
}

fn driver(script: &str) -> PathBuf {
    sbcl_root().join("apps").join(script).join("dump.lisp")
}

fn sbcl_tree_present() -> bool {
    driver("hello-window").is_file()
}

/// The residual classification must match the real app tree: hello-window is
/// pure-ObjC (no dylib); swift-native-probe loads libAPIAnywareSbcl. This anchors
/// `driver_needs_dylib` against the actual dump drivers the bundler reuses.
#[test]
fn classifies_residual_apps_against_real_tree() {
    if !sbcl_tree_present() {
        eprintln!("SKIPPED: sbcl app tree not present (emit/apps not local)");
        return;
    }
    assert!(
        !driver_needs_dylib(&driver("hello-window")),
        "hello-window is pure ObjC — no libAPIAnywareSbcl"
    );
    assert!(
        driver_needs_dylib(&driver("swift-native-probe")),
        "swift-native-probe loads libAPIAnywareSbcl (§6d residual)"
    );
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
    let err = bundle_app(&spec, &sbcl_root(), temp.path(), &workspace_root()).unwrap_err();
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
    let root = sbcl_root();
    let out = tempfile::tempdir().expect("out tempdir");
    let spec = AppSpec::from_script_name("hello-window");

    let app = bundle_app(&spec, &root, out.path(), &workspace_root()).expect("bundle hello-window");

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
    // Pure-ObjC app: no residual dylib vendored.
    assert!(
        !app.join("Contents")
            .join("Frameworks")
            .join("libAPIAnywareSbcl.dylib")
            .exists(),
        "hello-window is pure ObjC — no libAPIAnywareSbcl vendored"
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
