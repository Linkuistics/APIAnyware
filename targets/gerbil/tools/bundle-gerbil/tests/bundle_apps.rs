//! Integration tests for the gerbil bundler.
//!
//! The cheap, deterministic checks (closure walk against the real binding
//! tree, the entry precheck) run in any `cargo test`. The heavy end-to-end
//! build — drive `gxc` for the whole AppKit closure, assemble + relocate,
//! then assert `otool -L` is Homebrew-clean — needs the bottle gerbil
//! toolchain and is minutes-long, so it is `#[ignore]`d and run explicitly:
//!
//! ```text
//! cargo test -p apianyware-bundle-gerbil -- --ignored --nocapture
//! ```
//!
//! That ignored test is the in-crate proof of the node's first two done-bars
//! (a dylib-clean `.app`); the GUI-draws bar is grove leaf 070/040 (VM).

use std::path::PathBuf;
use std::process::Command;

use apianyware_bundle_gerbil::{bundle_app, collect_closure, AppSpec, BundleError};

fn workspace_root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .ancestors()
        .nth(4)
        .expect("workspace root above bundle-gerbil crate")
        .to_path_buf()
}

/// The app-implementations root: gerbil sample apps live at
/// `<apps_root>/<app>/<app>.ss` (§18 split, `move-gerbil-material-k13`). The
/// bundler reads the entry from here and the closure from [`lib_root`] natively
/// — `collect_closure` already takes the two separately, so no stitching.
fn apps_root() -> PathBuf {
    workspace_root()
        .join("targets")
        .join("gerbil")
        .join("app-implementations")
        .join("macos")
}

/// The binding package root: the `gerbil-bindings` package (committed
/// `runtime/` + emitted `<fw>/` modules) lives under its `generated/` child.
fn bindings_root() -> PathBuf {
    workspace_root()
        .join("targets")
        .join("gerbil")
        .join("bindings")
        .join("macos")
}

/// The `gerbil-bindings` package root the closure walk resolves
/// `:gerbil-bindings/…` names against (`bindings_root/generated`).
fn lib_root() -> PathBuf {
    bindings_root().join("generated")
}

/// True when `apianyware-generate` has been run locally — the signal this
/// closure-walk test skips on (it needs the emitted binding tree).
///
/// Gate on an **emitted** framework module (`generated/appkit/nsapplication.ss`),
/// not the hand-written `generated/runtime/`. `move-gerbil-material-k13` made
/// gerbil's `runtime/` a *committed* part of the package root (`.gitignore`:
/// `generated/*` minus `runtime`) while the per-framework `appkit/`,
/// `foundation/`, … libraries stay gitignored emit output. The committed
/// `runtime/objc.ss` is therefore always present and is no longer a valid proxy
/// for "emit was run" — gating on it made the test run (and fail with
/// `ImportNotFound`) against an absent emitted tree in a clean checkout.
fn gerbil_tree_present() -> bool {
    lib_root().join("appkit").join("nsapplication.ss").is_file()
        && apps_root()
            .join("hello-window")
            .join("hello-window.ss")
            .is_file()
}

/// The hello-window closure must be exactly the 13 binding modules
/// `build.sh` lists, ordered dependencies-first. This anchors the walker
/// against the real binding tree (it is also the set `gxc -O` precompiles).
#[test]
fn computes_hello_window_closure() {
    if !gerbil_tree_present() {
        eprintln!("SKIPPED: gerbil binding tree not present (emit not run locally)");
        return;
    }
    let lib = lib_root();
    let entry = apps_root().join("hello-window").join("hello-window.ss");

    let closure = collect_closure(&entry, &lib).expect("closure walk");
    let rels: Vec<String> = closure
        .iter()
        .map(|p| {
            p.strip_prefix(&lib)
                .unwrap()
                .to_string_lossy()
                .replace(".ss", "")
        })
        .collect();

    // Sharded generics (ADR-0023): the closure pulls the facade `generics` plus
    // its `generics/NNN` shards (count tracks selector count — brittle to pin).
    // Partition them out and check the rest exactly.
    let (generics_mods, rest): (Vec<&str>, Vec<&str>) = rels
        .iter()
        .map(String::as_str)
        .partition(|r| *r == "generics" || r.starts_with("generics/"));

    let expected: std::collections::HashSet<&str> = [
        "runtime/ffi",
        "runtime/native-core",
        "runtime/objc",
        "runtime/cocoa",
        "appkit/nsresponder",
        "appkit/nsview",
        "appkit/nscontrol",
        "appkit/nstextfield",
        "appkit/nsapplication",
        "appkit/nswindow",
        "appkit/nsfont",
        "appkit/enums",
    ]
    .into_iter()
    .collect();
    let got: std::collections::HashSet<&str> = rest.into_iter().collect();
    assert_eq!(
        got, expected,
        "non-generics closure set drifted:\n{rels:#?}"
    );

    // The facade and at least one shard are in the closure.
    assert!(
        generics_mods.contains(&"generics"),
        "generics facade in closure"
    );
    assert!(
        generics_mods.iter().any(|m| m.starts_with("generics/")),
        "≥1 generics shard in closure: {generics_mods:?}"
    );

    // Topological spot-checks: each module appears after its dependencies.
    let pos = |rel: &str| rels.iter().position(|r| r == rel).unwrap();
    assert!(pos("runtime/ffi") < pos("runtime/native-core"));
    assert!(pos("runtime/native-core") < pos("runtime/objc"));
    assert!(pos("runtime/objc") < pos("runtime/cocoa"));
    assert!(pos("appkit/nsresponder") < pos("appkit/nsview"));
    assert!(pos("appkit/nsview") < pos("appkit/nscontrol"));
    assert!(pos("appkit/nscontrol") < pos("appkit/nstextfield"));
    assert!(pos("appkit/nsresponder") < pos("appkit/nswindow"));
    // Sharded generics ordering: shards precede the facade (it re-exports them),
    // and the facade precedes the class modules (they import it).
    let first_shard = rels
        .iter()
        .position(|r| r.starts_with("generics/"))
        .expect("a generics shard in the closure");
    assert!(first_shard < pos("generics"), "shards before facade");
    assert!(
        pos("generics") < pos("appkit/nsresponder"),
        "facade before class modules"
    );
}

/// A script name with no matching `apps/<script>/<script>.ss` entry fails
/// with `EntryMissing` — checked before any toolchain work.
#[test]
fn rejects_missing_app() {
    if !gerbil_tree_present() {
        eprintln!("SKIPPED: gerbil binding tree not present");
        return;
    }
    let temp = tempfile::tempdir().expect("tempdir");
    let spec = AppSpec::from_script_name("definitely-not-an-app");
    let err = bundle_app(&spec, &apps_root(), &bindings_root(), temp.path()).unwrap_err();
    assert!(
        matches!(err, BundleError::EntryMissing { .. }),
        "expected EntryMissing, got {err:?}"
    );
}

fn gxc_available() -> bool {
    apianyware_bundle_gerbil::discover_gerbil_bin_dir().is_ok()
}

/// End-to-end: build the hello-window `.app` and assert it is Homebrew-clean.
/// Heavy (drives `gxc` over the AppKit closure) and toolchain-dependent, so
/// `#[ignore]`d. This is the in-crate proof of the node's dylib-clean done-bar.
#[test]
#[ignore = "heavy: drives gxc end-to-end; run explicitly with --ignored"]
fn builds_dylib_clean_hello_window_app() {
    if !gerbil_tree_present() {
        eprintln!("SKIPPED: gerbil binding tree not present");
        return;
    }
    if !gxc_available() {
        eprintln!("SKIPPED: gerbil bottle toolchain not found");
        return;
    }
    let out = tempfile::tempdir().expect("out tempdir");
    let spec = AppSpec::from_script_name("hello-window");

    let app =
        bundle_app(&spec, &apps_root(), &bindings_root(), out.path()).expect("bundle hello-window");

    // Layout.
    let exe = app.join("Contents").join("MacOS").join("hello-window");
    assert!(exe.is_file(), "exe at Contents/MacOS/hello-window");
    assert!(
        app.join("Contents").join("Info.plist").is_file(),
        "Info.plist present"
    );

    // The done-bar: no /opt/homebrew dylib deps remain on the exe.
    let otool = Command::new("otool")
        .arg("-L")
        .arg(&exe)
        .output()
        .expect("otool -L");
    let listing = String::from_utf8_lossy(&otool.stdout);
    assert!(
        !listing.contains("/opt/homebrew/"),
        "exe still has Homebrew dylib deps:\n{listing}"
    );
    // And the openssl dylibs were vendored + relocated.
    assert!(listing.contains("@executable_path/../Frameworks/libssl.3.dylib"));
    assert!(app
        .join("Contents")
        .join("Frameworks")
        .join("libssl.3.dylib")
        .is_file());
}
