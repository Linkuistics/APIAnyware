//! Build a self-contained, open-world chez `.app` (no system Chez at
//! runtime — ADR-0009) for one sample app.
//!
//! Usage (from workspace root):
//!
//! ```text
//! cargo run --example bundle_app -p apianyware-macos-bundle-chez -- <script-name>
//! ```
//!
//! Output: `generation/targets/chez/apps/<script-name>/build/<App Name>.app`.
//!
//! The whole-program compile is one-time-per-app and slow (~160 s / ~1.6 GB
//! RSS for the AppKit closure; spike F7) — the shipped launch is ~50×
//! faster than the retired source-exec bundle. Display name comes from
//! `knowledge/apps/<script>/spec.md`'s first H1 when present.

use std::path::PathBuf;
use std::process::ExitCode;

use apianyware_macos_bundle_chez::{bundle_app, read_display_name_from_spec, AppSpec};

fn main() -> ExitCode {
    let script = std::env::args().nth(1).unwrap_or_else(|| {
        eprintln!("usage: bundle_app <script-name>");
        std::process::exit(2);
    });

    let workspace = workspace_root();
    let source_root = workspace.join("generation").join("targets").join("chez");
    let output_dir = source_root.join("apps").join(&script).join("build");

    let mut spec = AppSpec::from_script_name(&script);
    let spec_path = workspace
        .join("knowledge")
        .join("apps")
        .join(&script)
        .join("spec.md");
    if let Some(display) = read_display_name_from_spec(&spec_path) {
        spec.bundle_id = format!("com.linkuistics.{}", display.replace(' ', ""));
        spec.app_name = display;
    }

    eprintln!(
        "building standalone {} (this compiles the whole closure)…",
        spec.app_name
    );
    match bundle_app(&spec, &source_root, &output_dir) {
        Ok(path) => {
            println!("{}", path.display());
            eprintln!("built: {} ({})", path.display(), spec.bundle_id);
            ExitCode::SUCCESS
        }
        Err(e) => {
            eprintln!("{script}: {e}");
            ExitCode::FAILURE
        }
    }
}

fn workspace_root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .ancestors()
        .nth(3)
        .expect("workspace root above bundle-chez crate")
        .to_path_buf()
}
