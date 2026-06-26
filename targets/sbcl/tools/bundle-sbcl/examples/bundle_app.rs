//! Build a self-contained sbcl `.app` (no Homebrew/SBCL dependency on the target
//! — ADR-0041) for one sample app.
//!
//! Usage (from workspace root):
//!
//! ```text
//! cargo run --example bundle_app -p apianyware-bundle-sbcl -- <script-name>
//! ```
//!
//! Output: `targets/sbcl/app-implementations/macos/<script-name>/build/<App Name>.app`.
//!
//! Drives the app's `dump.lisp` (`save-lisp-and-die :executable t`), compiles the
//! DYLD_FALLBACK stub, vendors libzstd (+ the residual dylib), and signs. The
//! display name comes from `apps/macos/<script>/docs/spec.md`'s first H1 when present.

use std::path::PathBuf;
use std::process::ExitCode;

use apianyware_bundle_sbcl::{bundle_app, read_display_name_from_spec, AppSpec};

fn main() -> ExitCode {
    let script = std::env::args().nth(1).unwrap_or_else(|| {
        eprintln!("usage: bundle_app <script-name>");
        std::process::exit(2);
    });

    let workspace = workspace_root();
    // The §18 domain tree homes sbcl apps under app-implementations; each app's
    // dump.lisp self-resolves the binding tree, so no bindings root is needed.
    let apps_root = workspace
        .join("targets")
        .join("sbcl")
        .join("app-implementations")
        .join("macos");
    let output_dir = apps_root.join(&script).join("build");

    let mut spec = AppSpec::from_script_name(&script);
    // Common, target-independent app specs live at `apps/macos/<app>/docs/spec.md`.
    let spec_path = workspace
        .join("apps")
        .join("macos")
        .join(&script)
        .join("docs")
        .join("spec.md");
    if let Some(display) = read_display_name_from_spec(&spec_path) {
        spec.bundle_id = format!("com.linkuistics.{}", display.replace(' ', ""));
        spec.app_name = display;
    }

    eprintln!(
        "building standalone {} (drives save-lisp-and-die)…",
        spec.app_name
    );
    match bundle_app(&spec, &apps_root, &output_dir, &workspace) {
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
        .expect("workspace root above bundle-sbcl crate")
        .to_path_buf()
}
