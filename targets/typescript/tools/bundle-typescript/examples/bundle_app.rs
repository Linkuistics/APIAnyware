//! Build a self-contained Node TypeScript `.app` (ADR-0060) for one sample
//! app already built via its own `build.sh` (+ the native addon's).
//!
//! Usage (from workspace root):
//!
//! ```text
//! cargo run --example bundle_app -p apianyware-bundle-typescript -- <script-name>
//! ```
//!
//! Output: `targets/typescript/app-implementations/macos/<script-name>/build/<App Name>.app`.
//!
//! Display name comes from `apps/macos/<script>/docs/spec.md`'s first H1 when
//! present.

use std::path::PathBuf;
use std::process::ExitCode;

use apianyware_bundle_typescript::{bundle_app, read_display_name_from_spec, AppSpec};

fn main() -> ExitCode {
    let script = std::env::args().nth(1).unwrap_or_else(|| {
        eprintln!("usage: bundle_app <script-name>");
        std::process::exit(2);
    });

    let workspace = workspace_root();
    let app_dir = workspace
        .join("targets")
        .join("typescript")
        .join("app-implementations")
        .join("macos")
        .join(&script);
    let native_dir = workspace.join("targets").join("typescript").join("bindings").join("node").join("native");
    let output_dir = app_dir.join("build");

    let mut spec = AppSpec::from_script_name(&script);
    let spec_path = workspace.join("apps").join("macos").join(&script).join("docs").join("spec.md");
    if let Some(display) = read_display_name_from_spec(&spec_path) {
        spec.bundle_id = format!("com.linkuistics.{}", display.replace(' ', ""));
        spec.app_name = display;
    }
    // PDFKit's classes are not resolvable via a bare objc_getClass unless PDFKit is an
    // explicit launcher link, unlike every other framework this ladder has touched so far
    // (confirmed empirically — see pdfkit-viewer/learnings.md). Mirrors that app's own dev
    // build.sh, which links `-framework PDFKit` for the same reason.
    if script == "pdfkit-viewer" {
        spec.extra_frameworks.push("PDFKit".to_string());
    }

    eprintln!("building {} (compiling the native launcher + vendoring libnode)…", spec.app_name);
    match bundle_app(&spec, &app_dir, &native_dir, &output_dir) {
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
        .nth(4)
        .expect("workspace root above bundle-typescript crate")
        .to_path_buf()
}
