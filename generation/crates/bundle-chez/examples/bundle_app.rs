//! Bundle one or all chez sample apps into `.app` directories.
//!
//! Usage (from workspace root):
//!
//! ```text
//! cargo run --example bundle_app -p apianyware-macos-bundle-chez -- <script-name>
//! cargo run --example bundle_app -p apianyware-macos-bundle-chez -- --all
//! ```
//!
//! Output: `generation/targets/chez/apps/<script-name>/build/<App Name>.app`
//! per app.
//!
//! Display name comes from `knowledge/apps/<script>/spec.md`'s first H1
//! when present, falling back to a kebab→title conversion. Runtime
//! path defaults to `/opt/homebrew/bin/chez`.

use std::fs;
use std::path::{Path, PathBuf};
use std::process::ExitCode;

use apianyware_macos_bundle_chez::{bundle_app, read_display_name_from_spec, AppSpec};

fn main() -> ExitCode {
    let arg = std::env::args().nth(1).unwrap_or_else(|| {
        eprintln!("usage: bundle_app <script-name> | --all");
        std::process::exit(2);
    });

    let workspace = workspace_root();
    let source_root = workspace.join("generation").join("targets").join("chez");
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
    // Convenience for ad-hoc debugging: skip the post-stage `.sls` →
    // `.so` pass when this env var is set. Cold-launch will be slow
    // but the bundle ships with raw source only, which is easier to
    // diff against and survives a host Chez upgrade unchanged.
    if env_skip_precompile() {
        eprintln!("APIANYWARE_BUNDLE_CHEZ_SKIP_PRECOMPILE set — skipping precompile");
        spec.skip_precompile = true;
    }

    let app_path = bundle_app(&spec, source_root, &output_dir)?;
    eprintln!("built: {} ({})", app_path.display(), spec.bundle_id);
    Ok(app_path)
}

fn discover_app_scripts(source_root: &Path) -> std::io::Result<Vec<String>> {
    let apps_dir = source_root.join("apps");
    let mut scripts: Vec<String> = Vec::new();
    for entry in fs::read_dir(&apps_dir)? {
        let entry = entry?;
        if !entry.file_type()?.is_dir() {
            continue;
        }
        let name = entry.file_name().to_string_lossy().into_owned();
        let entry_sls = entry.path().join(format!("{name}.sls"));
        if entry_sls.is_file() {
            scripts.push(name);
        }
    }
    scripts.sort();
    Ok(scripts)
}

fn env_skip_precompile() -> bool {
    std::env::var("APIANYWARE_BUNDLE_CHEZ_SKIP_PRECOMPILE")
        .map(|v| !v.is_empty())
        .unwrap_or(false)
}

fn workspace_root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .ancestors()
        .nth(3)
        .expect("workspace root above bundle-chez crate")
        .to_path_buf()
}
