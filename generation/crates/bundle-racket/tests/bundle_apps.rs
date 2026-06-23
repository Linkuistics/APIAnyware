//! Integration tests: bundle real sample apps and verify the resulting
//! `.app` is structurally complete.
//!
//! Uses hello-window as the per-test fixture (simplest app, smallest
//! transitive require tree; minimises noise in negative assertions).
//! `bundles_every_sample_app` covers all apps under `apps/` dynamically.
//!
//! Skipped if `swiftc` isn't available (stub-launcher needs it). Also
//! skipped if the racket source tree is missing — keeps the workspace
//! test run clean on stripped checkouts.

use std::fs;
use std::path::PathBuf;
use std::process::Command;

use apianyware_bundle_racket::{
    bundle_app, bundle_app_with_entry, read_display_name_from_spec, AppSpec,
};

const SCRIPT_NAME: &str = "hello-window";

fn workspace_root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .ancestors()
        .nth(3)
        .expect("workspace root above bundle-racket crate")
        .to_path_buf()
}

fn racket_root() -> PathBuf {
    workspace_root()
        .join("generation")
        .join("targets")
        .join("racket")
}

fn knowledge_apps_dir() -> PathBuf {
    workspace_root().join("knowledge").join("apps")
}

fn discover_app_scripts() -> Vec<String> {
    let apps = racket_root().join("apps");
    let mut scripts: Vec<String> = Vec::new();
    let Ok(entries) = fs::read_dir(&apps) else {
        return scripts;
    };
    for e in entries.flatten() {
        if !e.file_type().map(|t| t.is_dir()).unwrap_or(false) {
            continue;
        }
        let name = e.file_name().to_string_lossy().into_owned();
        if e.path().join(format!("{name}.rkt")).is_file() {
            scripts.push(name);
        }
    }
    scripts.sort();
    scripts
}

fn swiftc_available() -> bool {
    Command::new("swiftc")
        .arg("--version")
        .output()
        .map(|o| o.status.success())
        .unwrap_or(false)
}

fn entry_script_present() -> bool {
    racket_root()
        .join("apps")
        .join(SCRIPT_NAME)
        .join(format!("{SCRIPT_NAME}.rkt"))
        .exists()
}

#[test]
fn bundles_hello_window_into_app_directory() {
    if !swiftc_available() {
        eprintln!("SKIPPED: swiftc not available");
        return;
    }
    if !entry_script_present() {
        eprintln!("SKIPPED: hello-window source not present");
        return;
    }

    let temp = tempfile::tempdir().expect("tempdir");
    let spec = AppSpec::from_script_name(SCRIPT_NAME);
    let app_path = bundle_app(&spec, &racket_root(), temp.path()).expect("bundle");

    // Bundle skeleton from stub-launcher
    assert!(app_path.ends_with("Hello Window.app"), "{app_path:?}");
    let contents = app_path.join("Contents");
    assert!(contents.join("Info.plist").is_file());
    assert!(contents.join("MacOS").join("Hello Window").is_file());

    // Resource layout — entry script and sibling deps
    let racket_app = contents.join("Resources").join("racket-app");
    let entry = racket_app
        .join("apps")
        .join(SCRIPT_NAME)
        .join(format!("{SCRIPT_NAME}.rkt"));
    assert!(entry.is_file(), "entry script missing: {entry:?}");

    // Runtime modules (every Racket app pulls these in transitively)
    assert!(racket_app.join("runtime").join("objc-base.rkt").is_file());
    assert!(racket_app
        .join("runtime")
        .join("type-mapping.rkt")
        .is_file());
    assert!(racket_app.join("runtime").join("app-menu.rkt").is_file());

    // Generated bindings statically required by hello-window. Five
    // appkit classes (NSApplication setup, NSWindow creation,
    // NSTextField label, NSView base class, NSFont label styling).
    let generated = racket_app.join("generated");
    assert!(generated.join("appkit").join("nsapplication.rkt").is_file());
    assert!(generated.join("appkit").join("nswindow.rkt").is_file());
    assert!(generated.join("appkit").join("nstextfield.rkt").is_file());
    assert!(generated.join("appkit").join("nsview.rkt").is_file());
    assert!(generated.join("appkit").join("nsfont.rkt").is_file());

    // Unrelated frameworks should NOT have been pulled in. CoreText /
    // WebKit are unreachable from hello-window's require tree and must
    // stay out of the bundle.
    assert!(
        !generated.join("coretext").exists(),
        "coretext leaked into the bundle"
    );
    assert!(
        !generated.join("webkit").exists(),
        "webkit leaked into the bundle"
    );

    // Files NOT statically required (sanity check on tree pruning).
    // NSString conversions go through type-mapping.rkt which calls
    // objc dynamically, so nsstring.rkt isn't required. Menu APIs go
    // through runtime/app-menu.rkt which uses raw objc_msgSend, so
    // nsmenu/nsmenuitem aren't required either. The tableview /
    // openpanel / filemanager / array / url bindings have no consumer
    // in this simple app.
    assert!(
        !generated.join("foundation").join("nsstring.rkt").exists(),
        "nsstring.rkt leaked: it isn't a static require of hello-window"
    );
    assert!(
        !generated.join("appkit").join("nsmenu.rkt").exists(),
        "nsmenu.rkt leaked: hello-window gets its menu via runtime/app-menu.rkt"
    );
    assert!(
        !generated.join("appkit").join("nstableview.rkt").exists(),
        "nstableview.rkt leaked: hello-window has no table"
    );
    assert!(
        !generated.join("appkit").join("nsopenpanel.rkt").exists(),
        "nsopenpanel.rkt leaked: hello-window has no open dialog"
    );
    assert!(
        !generated
            .join("foundation")
            .join("nsfilemanager.rkt")
            .exists(),
        "nsfilemanager.rkt leaked: hello-window doesn't touch the filesystem"
    );

    // Info.plist carries the derived bundle metadata
    let plist = std::fs::read_to_string(contents.join("Info.plist")).unwrap();
    assert!(plist.contains("<string>Hello Window</string>"));
    assert!(plist.contains("<string>com.linkuistics.HelloWindow</string>"));
}

#[test]
fn entry_script_resolves_under_racket_root() {
    // Sanity: the workspace path computation matches what the example uses.
    let entry = racket_root()
        .join("apps")
        .join(SCRIPT_NAME)
        .join(format!("{SCRIPT_NAME}.rkt"));
    assert!(
        entry.starts_with(workspace_root()),
        "{entry:?} must live under {:?}",
        workspace_root()
    );
}

#[test]
fn rejects_missing_app() {
    if !swiftc_available() {
        eprintln!("SKIPPED: swiftc not available");
        return;
    }
    let temp = tempfile::tempdir().expect("tempdir");
    let spec = AppSpec::from_script_name("definitely-not-an-app");
    let err = bundle_app(&spec, &racket_root(), temp.path()).unwrap_err();
    assert!(
        matches!(
            err,
            apianyware_bundle_racket::BundleError::EntryMissing { .. }
        ),
        "expected EntryMissing, got {err:?}"
    );
}

/// Exercise [`bundle_app_with_entry`] on a Modaliser-style layout:
/// the entry is a root-level `main.rkt`, and the `bindings/` directory
/// is a symlink into another tree (in this test, the APIAnyware
/// racket root, which is what Modaliser-Racket actually does).
///
/// The result must be a self-contained bundle — no absolute symlinks
/// leaking into the `.app`, all bindings copied as real files at their
/// logical in-tree locations.
#[test]
fn bundles_root_level_entry_with_symlinked_bindings_subdir() {
    if !swiftc_available() {
        eprintln!("SKIPPED: swiftc not available");
        return;
    }
    let real_racket = racket_root();
    let required = real_racket.join("runtime").join("objc-base.rkt");
    if !required.is_file() {
        eprintln!("SKIPPED: racket source tree not present");
        return;
    }

    let project = tempfile::tempdir().expect("project tempdir");
    let project_root = project.path();

    // `bindings/` is a symlink to the real racket tree, matching
    // Modaliser-Racket's current layout exactly.
    std::os::unix::fs::symlink(&real_racket, project_root.join("bindings"))
        .expect("symlink bindings/ into racket root");

    // Minimal root-level entry requiring through the symlink — mirrors
    // the initial require lines at the top of Modaliser's main.rkt.
    fs::write(
        project_root.join("main.rkt"),
        concat!(
            "#lang racket/base\n",
            "(require \"bindings/runtime/objc-base.rkt\"\n",
            "         \"bindings/runtime/coerce.rkt\")\n",
        ),
    )
    .expect("write main.rkt");

    let out = tempfile::tempdir().expect("out tempdir");
    let mut spec = AppSpec::from_script_name("main");
    spec.app_name = "Root Entry Demo".to_string();
    spec.bundle_id = "com.linkuistics.RootEntryDemo".to_string();

    let app_path = bundle_app_with_entry(
        &spec,
        &project_root.join("main.rkt"),
        project_root,
        out.path(),
    )
    .expect("bundle with root-level entry");

    // Bundle skeleton — binary named after the display app_name.
    let contents = app_path.join("Contents");
    assert!(contents.join("Info.plist").is_file());
    assert!(contents.join("MacOS").join("Root Entry Demo").is_file());

    // Entry is at the top of racket-app/ — no apps/<name>/ prefix.
    let racket_app = contents.join("Resources").join("racket-app");
    assert!(
        racket_app.join("main.rkt").is_file(),
        "entry not at racket-app/main.rkt"
    );

    // Bindings landed at the logical in-tree location as real copies,
    // not as a symlink to APIAnyware.
    let bindings = racket_app.join("bindings");
    assert!(
        !bindings.is_symlink(),
        "bindings/ must be a real directory, not a symlink — bundle is not distributable otherwise"
    );
    let objc_base = bindings.join("runtime").join("objc-base.rkt");
    assert!(
        objc_base.is_file() && !objc_base.is_symlink(),
        "bindings/runtime/objc-base.rkt must be a regular file"
    );

    // The derived script_resource_dir is unit-tested in src/bundle.rs —
    // seeing `main.rkt` at the top of `racket-app/` (above) is the
    // behavioral evidence that the stub was configured for a root-level
    // entry rather than the `apps/<name>/` sample-app layout.
}

/// A real-world source tree will often have `compiled/` directories
/// scattered throughout — Racket caches bytecode there. Those directories
/// bake host-specific absolute paths into the `.zo` linklets (confirmed
/// 2026-04-18 on Tahoe VM), so they MUST NOT leak into a distributable
/// bundle. The walker already ignores `compiled/` implicitly because it
/// only follows `.rkt` requires, but the `lib/` directory is copied
/// recursively and needs an explicit exclusion.
#[test]
fn bundle_lib_copy_excludes_compiled_subdirectory() {
    if !swiftc_available() {
        eprintln!("SKIPPED: swiftc not available");
        return;
    }
    let real_racket = racket_root();
    if !real_racket.join("runtime").join("objc-base.rkt").is_file() {
        eprintln!("SKIPPED: racket source tree not present");
        return;
    }

    let project = tempfile::tempdir().expect("project tempdir");
    let project_root = project.path();

    // Minimal project: a root-level entry pulling in a single runtime
    // file, plus a `lib/` dir with both a real dylib stand-in and a
    // poisoned `compiled/` subdirectory whose presence would break a
    // distributable bundle.
    std::os::unix::fs::symlink(&real_racket, project_root.join("bindings"))
        .expect("symlink bindings/");
    fs::write(
        project_root.join("main.rkt"),
        "#lang racket/base\n(require \"bindings/runtime/objc-base.rkt\")\n",
    )
    .expect("write main.rkt");

    let lib = project_root.join("lib");
    fs::create_dir_all(lib.join("compiled")).expect("create lib/compiled");
    fs::write(lib.join("compiled").join("poison.zo"), b"host-specific").expect("write zo");
    fs::write(lib.join("keep.txt"), b"kept").expect("write real lib file");

    let out = tempfile::tempdir().expect("out tempdir");
    let mut spec = AppSpec::from_script_name("main");
    spec.app_name = "Compiled Exclude".to_string();
    spec.bundle_id = "com.linkuistics.CompiledExclude".to_string();

    let app_path = bundle_app_with_entry(
        &spec,
        &project_root.join("main.rkt"),
        project_root,
        out.path(),
    )
    .expect("bundle");

    let racket_app = app_path
        .join("Contents")
        .join("Resources")
        .join("racket-app");
    let bundle_lib = racket_app.join("lib");

    assert!(
        bundle_lib.join("keep.txt").is_file(),
        "legitimate lib file was dropped"
    );
    assert!(
        !bundle_lib.join("compiled").exists(),
        "compiled/ subdirectory leaked into bundle — will carry host-specific linklet paths"
    );
}

/// Verify no `compiled/` directories exist anywhere in the bundle tree
/// for real sample apps. Structural invariant, cheap to check.
#[test]
fn bundle_has_no_compiled_directories_anywhere() {
    if !swiftc_available() {
        eprintln!("SKIPPED: swiftc not available");
        return;
    }
    if !entry_script_present() {
        eprintln!("SKIPPED: hello-window source not present");
        return;
    }

    let temp = tempfile::tempdir().expect("tempdir");
    let spec = AppSpec::from_script_name(SCRIPT_NAME);
    let app_path = bundle_app(&spec, &racket_root(), temp.path()).expect("bundle");

    let mut stack: Vec<PathBuf> = vec![app_path.clone()];
    while let Some(dir) = stack.pop() {
        for entry in fs::read_dir(&dir).expect("read_dir") {
            let entry = entry.expect("dir entry");
            let path = entry.path();
            if path.is_dir() {
                assert_ne!(
                    path.file_name().map(|n| n.to_string_lossy().into_owned()),
                    Some("compiled".to_string()),
                    "compiled/ directory found at {path:?} — bundle is not distributable"
                );
                stack.push(path);
            }
        }
    }
}

/// The bundled dylib must carry an install name that resolves within
/// the bundle (not `@rpath/...`), so any native consumer — a future
/// direct-link tool, a dyld introspection tool, or a second-stage
/// loader — can find it without relying on an external rpath setting.
/// Racket's own `ffi-lib` uses an explicit path and doesn't care, but
/// a normalized install name is the defining property of a
/// self-contained bundle.
#[test]
fn bundle_dylib_install_name_is_bundle_relative() {
    if !swiftc_available() {
        eprintln!("SKIPPED: swiftc not available");
        return;
    }
    if !entry_script_present() {
        eprintln!("SKIPPED: hello-window source not present");
        return;
    }
    let dylib_source = racket_root().join("lib").join("libAPIAnywareRacket.dylib");
    if !dylib_source.exists() {
        eprintln!("SKIPPED: libAPIAnywareRacket.dylib not built");
        return;
    }

    let temp = tempfile::tempdir().expect("tempdir");
    let spec = AppSpec::from_script_name(SCRIPT_NAME);
    let app_path = bundle_app(&spec, &racket_root(), temp.path()).expect("bundle");

    let dylib = app_path
        .join("Contents")
        .join("Resources")
        .join("racket-app")
        .join("lib")
        .join("libAPIAnywareRacket.dylib");
    assert!(dylib.is_file(), "dylib missing in bundle");

    let output = Command::new("otool")
        .arg("-D")
        .arg(&dylib)
        .output()
        .expect("run otool");
    let text = String::from_utf8_lossy(&output.stdout);
    let install_name = text
        .lines()
        .last()
        .expect("otool output has last line")
        .trim();
    assert!(
        install_name.starts_with("@executable_path/"),
        "dylib install name must be bundle-relative, got {install_name:?}"
    );
}

/// Bundle every sample app under `apps/` and assert the structural
/// invariants each `.app` must satisfy. This is the safety net for the
/// "ensure all sample apps are bundleable" requirement — adding a new
/// app under `apps/<name>/<name>.rkt` automatically lights up coverage
/// here without test edits.
#[test]
fn bundles_every_sample_app() {
    if !swiftc_available() {
        eprintln!("SKIPPED: swiftc not available");
        return;
    }
    let scripts = discover_app_scripts();
    if scripts.is_empty() {
        eprintln!("SKIPPED: no sample apps discovered");
        return;
    }

    for script in &scripts {
        let temp = tempfile::tempdir().expect("tempdir");

        // Use the same spec-md → display name lookup that the CLI
        // example uses, so the test bundles match what real users get.
        let mut spec = AppSpec::from_script_name(script);
        let spec_md = knowledge_apps_dir().join(script).join("spec.md");
        if let Some(display) = read_display_name_from_spec(&spec_md) {
            spec.bundle_id = format!("com.linkuistics.{}", display.replace(' ', ""));
            spec.app_name = display;
        }

        let app_path = bundle_app(&spec, &racket_root(), temp.path())
            .unwrap_or_else(|e| panic!("bundle {script}: {e}"));

        // Every bundle ships with a CFBundleName-correct Info.plist
        // and a compiled stub binary.
        let contents = app_path.join("Contents");
        let plist = fs::read_to_string(contents.join("Info.plist"))
            .unwrap_or_else(|e| panic!("read Info.plist for {script}: {e}"));
        assert!(
            plist.contains(&format!("<string>{}</string>", spec.app_name)),
            "{script}: CFBundleName missing from Info.plist"
        );
        assert!(
            plist.contains(&format!("<string>{}</string>", spec.bundle_id)),
            "{script}: CFBundleIdentifier missing from Info.plist"
        );

        let exe = contents.join("MacOS").join(&spec.app_name);
        assert!(exe.is_file(), "{script}: stub binary missing at {exe:?}");

        // Resources/racket-app must contain the entry script and at
        // least the runtime modules every Racket app pulls in
        // transitively (objc-base, coerce, type-mapping).
        let racket_app = contents.join("Resources").join("racket-app");
        let entry = racket_app
            .join("apps")
            .join(script)
            .join(format!("{script}.rkt"));
        assert!(entry.is_file(), "{script}: entry script missing");

        let runtime = racket_app.join("runtime");
        for required in [
            "objc-base.rkt",
            "coerce.rkt",
            "type-mapping.rkt",
            "app-menu.rkt",
        ] {
            assert!(
                runtime.join(required).is_file(),
                "{script}: runtime/{required} missing",
            );
        }
    }
}
