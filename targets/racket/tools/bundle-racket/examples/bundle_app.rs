//! Bundle one or all racket sample apps into `.app` directories.
//!
//! Usage (from workspace root):
//!
//! ```text
//! cargo run --example bundle_app -p apianyware-bundle-racket -- <script-name>
//! cargo run --example bundle_app -p apianyware-bundle-racket -- --all
//! ```
//!
//! Output: `targets/racket/app-implementations/macos/<script-name>/build/<App Name>.app`
//! per app.
//!
//! The display name comes from `apps/macos/<script>/docs/spec.md`'s first
//! H1 when present (so `ui-controls-gallery` correctly becomes
//! `UI Controls Gallery`, not `Ui Controls Gallery`), falling back to a
//! kebab→title conversion. The bundle id is derived from the display
//! name (`com.linkuistics.<NoSpaceTitle>`). The runtime path defaults to
//! `/opt/homebrew/bin/racket`.

use std::fs;
use std::path::{Path, PathBuf};
use std::process::ExitCode;

use apianyware_bundle_racket::{bundle_app, read_display_name_from_spec, AppSpec};

fn main() -> ExitCode {
    let arg = std::env::args().nth(1).unwrap_or_else(|| {
        eprintln!("usage: bundle_app <script-name> | --all");
        eprintln!("examples:");
        eprintln!("  bundle_app file-lister");
        eprintln!("  bundle_app --all");
        std::process::exit(2);
    });

    let workspace = workspace_root();
    // The §18 domain tree splits the racket material in two: sample apps under
    // `targets/racket/app-implementations/macos/`, the binding package
    // (runtime / generated / lib) under `targets/racket/bindings/macos/`. The
    // bundler resolves the apps' `(require "../../{generated,runtime}/…")`
    // across both natively (`SourceRoots::split`), so no stitching is needed.
    let apps_root = workspace
        .join("targets")
        .join("racket")
        .join("app-implementations")
        .join("macos");
    let bindings_root = workspace
        .join("targets")
        .join("racket")
        .join("bindings")
        .join("macos");
    // Common, target-independent app specs live at `apps/macos/<app>/docs/spec.md`
    // (§15; co-located by `co-locate-docs-k9`).
    let common_app_specs = workspace.join("apps").join("macos");

    let scripts: Vec<String> = if arg == "--all" {
        match discover_app_scripts(&apps_root) {
            Ok(s) if !s.is_empty() => s,
            Ok(_) => {
                eprintln!("no sample apps found under {}", apps_root.display());
                return ExitCode::FAILURE;
            }
            Err(e) => {
                eprintln!("could not list apps directory: {e}");
                return ExitCode::FAILURE;
            }
        }
    } else {
        vec![arg]
    };

    let mut any_failed = false;
    for script in scripts {
        match bundle_one(&script, &apps_root, &bindings_root, &common_app_specs) {
            Ok(path) => println!("{}", path.display()),
            Err(e) => {
                eprintln!("{script}: {e}");
                any_failed = true;
            }
        }
    }

    if any_failed {
        ExitCode::FAILURE
    } else {
        ExitCode::SUCCESS
    }
}

fn bundle_one(
    script: &str,
    apps_root: &Path,
    bindings_root: &Path,
    common_app_specs: &Path,
) -> Result<PathBuf, Box<dyn std::error::Error>> {
    let output_dir = apps_root.join(script).join("build");
    if output_dir.exists() {
        fs::remove_dir_all(&output_dir)?;
    }

    let mut spec = AppSpec::from_script_name(script);
    let spec_path = common_app_specs.join(script).join("docs").join("spec.md");
    if let Some(display) = read_display_name_from_spec(&spec_path) {
        spec.bundle_id = format!("com.linkuistics.{}", display.replace(' ', ""));
        spec.app_name = display;
    }

    let app_path = bundle_app(&spec, apps_root, bindings_root, &output_dir)?;
    eprintln!("built: {} ({})", app_path.display(), spec.bundle_id);
    Ok(app_path)
}

/// List script names by walking `<apps_root>/*` for directories containing a
/// matching `<dir>/<dir>.rkt` entry. Anything else (build output dirs,
/// README, etc.) is skipped.
fn discover_app_scripts(apps_root: &Path) -> std::io::Result<Vec<String>> {
    let mut scripts: Vec<String> = Vec::new();
    for entry in fs::read_dir(apps_root)? {
        let entry = entry?;
        if !entry.file_type()?.is_dir() {
            continue;
        }
        let name = entry.file_name().to_string_lossy().into_owned();
        let entry_rkt = entry.path().join(format!("{name}.rkt"));
        if entry_rkt.is_file() {
            scripts.push(name);
        }
    }
    scripts.sort();
    Ok(scripts)
}

fn workspace_root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .ancestors()
        .nth(4)
        .expect("workspace root above bundle-racket crate")
        .to_path_buf()
}
