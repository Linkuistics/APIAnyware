//! Pre-compile bundled `.sls` libraries to `.so` so cold-launch
//! doesn't pay the on-import compile cost (~75s for the AppKit
//! facade alone on the dev host).
//!
//! The pass runs after every dependency `.sls` has been staged under
//! the bundle's `Resources/chez-app/` tree. It shells out to Chez
//! itself — the same binary the runtime tests and the deps walker
//! use — running [`PRECOMPILE_SS`] with the bundle's chez-app root
//! as both `--libdirs` and as the script's argument.
//!
//! ## Why next to the source
//!
//! Chez's default `library-extensions` lookup probes
//! `<libdir>/<name>.so` before `<libdir>/<name>.sls`. Pre-compile to
//! the same directory is the no-launcher-change path — the existing
//! `chez --libdirs <chez-app> --script <entry>` invocation transparently
//! picks up the `.so` siblings without any flag or runtime hook.
//!
//! ## Why fail loudly
//!
//! A `.sls` that doesn't compile is almost always an emitter
//! regression (the generated source lost a name, mis-formed a
//! library, etc). Falling back to "ship `.sls` only, compile at
//! runtime" would hide that — the cold-launch slowdown would still
//! happen and the user would see a runtime error days later. So a
//! compile failure here aborts the bundle build with the Chez
//! condition message on stderr.
//!
//! ## Chez-version coupling
//!
//! `.so` files are tied to the exact Chez version that wrote them.
//! If the host's Chez upgrades after a bundle is built, the
//! bundle's `.so` files become incompatible and `--script` startup
//! errors out. Rebuilding the bundle is the only fix. Document this
//! caveat in the per-target README; for development convenience,
//! [`AppSpec::skip_precompile`](crate::AppSpec::skip_precompile)
//! lets callers ship `.sls`-only bundles that tolerate Chez upgrades
//! at the cost of cold-launch time.

use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

use crate::bundle::BundleError;

/// Embedded pre-compile walker, written to a tempfile per invocation
/// so a binary install (where the crate's source tree is absent)
/// still works.
const PRECOMPILE_SS: &str = include_str!("../scripts/precompile.ss");

/// Compile every `(library …)` `.sls` under `chez_app_dir` into a
/// sibling `.so` using `chez_bin`.
pub(crate) fn precompile_bundled_libraries(
    chez_app_dir: &Path,
    chez_bin: &str,
) -> Result<(), BundleError> {
    let script = write_script_to_tempfile()?;
    let output = Command::new(chez_bin)
        .arg("--script")
        .arg(script.path())
        .arg(chez_app_dir)
        .output()
        .map_err(|e| BundleError::ChezNotAvailable {
            chez_bin: chez_bin.to_string(),
            source: e,
        })?;

    if !output.status.success() {
        return Err(BundleError::PrecompileFailed {
            stderr: String::from_utf8_lossy(&output.stderr).into_owned(),
        });
    }
    Ok(())
}

struct ScriptFile {
    _dir: tempfile::TempDir,
    path: PathBuf,
}

impl ScriptFile {
    fn path(&self) -> &Path {
        &self.path
    }
}

fn write_script_to_tempfile() -> Result<ScriptFile, BundleError> {
    let dir = tempfile::tempdir()?;
    let path = dir.path().join("precompile.ss");
    fs::write(&path, PRECOMPILE_SS)?;
    Ok(ScriptFile { _dir: dir, path })
}
