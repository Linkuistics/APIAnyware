//! Integration tests for the Node TypeScript bundler.
//!
//! The cheap, deterministic checks (the entry prechecks) run in any `cargo
//! test`. The heavy end-to-end build — compile the native launcher, vendor +
//! relocate libnode's Homebrew closure, assemble, and sign — needs `hello-window`
//! already built (its own `build.sh` + `bindings/node/native/build.sh`) and a
//! working Node embedder toolchain, so it is `#[ignore]`d and run explicitly:
//!
//! ```text
//! cargo test -p apianyware-bundle-typescript -- --ignored --nocapture
//! ```

use std::path::PathBuf;
use std::process::Command;

use apianyware_bundle_typescript::{bundle_app, AppSpec, BundleError};

fn workspace_root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .ancestors()
        .nth(4)
        .expect("workspace root above bundle-typescript crate")
        .to_path_buf()
}

fn app_dir(script: &str) -> PathBuf {
    workspace_root().join("targets/typescript/app-implementations/macos").join(script)
}

fn native_dir() -> PathBuf {
    workspace_root().join("targets/typescript/bindings/node/native")
}

fn hello_window_built() -> bool {
    app_dir("hello-window")
        .join("build/js/app-implementations/macos/hello-window/app.js")
        .is_file()
        && native_dir().join("build/APIAnywareTypeScript.node").is_file()
}

/// A script name with no matching build output fails with `AppNotBuilt` —
/// checked before any toolchain work.
#[test]
fn rejects_unbuilt_app() {
    let spec = AppSpec::from_script_name("definitely-not-an-app");
    let out = tempfile::tempdir().expect("tempdir");
    let err = bundle_app(&spec, &app_dir("definitely-not-an-app"), &native_dir(), out.path()).unwrap_err();
    assert!(matches!(err, BundleError::AppNotBuilt { .. }), "expected AppNotBuilt, got {err:?}");
}

/// End-to-end: build the hello-window `.app` and assert it is a genuinely
/// relocated, double-clickable bundle (ADR-0060's own "Done when").
#[test]
#[ignore = "heavy: compiles the native launcher + vendors libnode's Homebrew closure; run explicitly with --ignored"]
fn builds_relocated_hello_window_app() {
    if !hello_window_built() {
        eprintln!("SKIPPED: hello-window not built locally (run its build.sh + native/build.sh first)");
        return;
    }
    let out = tempfile::tempdir().expect("out tempdir");
    let spec = AppSpec::from_script_name("hello-window");

    let app = bundle_app(&spec, &app_dir("hello-window"), &native_dir(), out.path()).expect("bundle hello-window");

    // Layout.
    let exe = app.join("Contents/MacOS/hello-window");
    assert!(exe.is_file(), "launcher at Contents/MacOS/hello-window");
    assert!(app.join("Contents/Info.plist").is_file(), "Info.plist present");
    assert!(app.join("Contents/Frameworks/APIAnywareTypeScript.node").is_file(), "native addon vendored");
    assert!(
        app.join("Contents/Resources/app/build/js/app-implementations/macos/hello-window/app.js").is_file(),
        "app.js laid out under Resources/app/"
    );
    assert!(app.join("Contents/Resources/app/bootstrap.cjs").is_file());
    assert!(app.join("Contents/Resources/app/loader.mjs").is_file());

    // The done-bar: no /opt/homebrew dylib deps remain on the launcher.
    let otool = Command::new("otool").arg("-L").arg(&exe).output().expect("otool -L");
    let listing = String::from_utf8_lossy(&otool.stdout);
    assert!(!listing.contains("/opt/homebrew/"), "launcher still has Homebrew dylib deps:\n{listing}");
    assert!(listing.contains("@executable_path/../Frameworks/libnode"));
    assert!(app.join("Contents/Frameworks").join("libnode.147.dylib").is_file() || {
        // The pinned libnode version may differ across hosts; accept any vendored libnode*.dylib.
        std::fs::read_dir(app.join("Contents/Frameworks"))
            .unwrap()
            .filter_map(|e| e.ok())
            .any(|e| e.file_name().to_string_lossy().starts_with("libnode."))
    });
}
