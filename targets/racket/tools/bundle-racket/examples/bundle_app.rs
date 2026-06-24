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
//! The display name comes from `docs/apps/<script>/spec.md`'s first
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
    // TODO(bindings/adapter-model workstream, root brief item 6): the §18 refactor
    // (`move-racket-material-k11`) split the racket tree — sample apps now live
    // under `targets/racket/app-implementations/macos/` while runtime/generated/lib
    // moved to `targets/racket/bindings/macos/`. The bundler still expects them
    // colocated under one `source_root` (`source_root/apps/...` + sibling
    // runtime/generated/lib). Until it learns the apps-root/bindings-root split,
    // this example cannot bundle from the new tree as-is; see the stitched symlink
    // fixture in `tests/bundle_apps.rs::racket_root` for the shape it needs.
    let source_root = workspace
        .join("targets")
        .join("racket")
        .join("app-implementations")
        .join("macos");
    let knowledge_apps = workspace.join("knowledge").join("apps");

    let scripts: Vec<String> = if arg == "--all" {
        match discover_app_scripts(&source_root) {
            Ok(s) if !s.is_empty() => s,
            Ok(_) => {
                eprintln!("no sample apps found under {}/apps", source_root.display());
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
        match bundle_one(&script, &source_root, &knowledge_apps) {
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
    source_root: &Path,
    knowledge_apps: &Path,
) -> Result<PathBuf, Box<dyn std::error::Error>> {
    let output_dir = source_root.join("apps").join(script).join("build");
    if output_dir.exists() {
        fs::remove_dir_all(&output_dir)?;
    }

    let mut spec = AppSpec::from_script_name(script);
    let spec_path = knowledge_apps.join(script).join("spec.md");
    if let Some(display) = read_display_name_from_spec(&spec_path) {
        spec.bundle_id = format!("com.linkuistics.{}", display.replace(' ', ""));
        spec.app_name = display;
    }

    let app_path = bundle_app(&spec, source_root, &output_dir)?;
    eprintln!("built: {} ({})", app_path.display(), spec.bundle_id);
    Ok(app_path)
}

/// List script names by walking `<source_root>/apps/*` for directories
/// containing a matching `<dir>/<dir>.rkt` entry. Anything else (build
/// output dirs, README, etc.) is skipped.
fn discover_app_scripts(source_root: &Path) -> std::io::Result<Vec<String>> {
    let apps_dir = source_root.join("apps");
    let mut scripts: Vec<String> = Vec::new();
    for entry in fs::read_dir(&apps_dir)? {
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
