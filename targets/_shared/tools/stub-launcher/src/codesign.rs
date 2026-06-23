//! Wrapper around the system `codesign` utility.
//!
//! Signing a stub binary (or a full bundle) with a *stable* identity
//! keeps the resulting CDHash consistent across rebuilds when the input
//! bytes don't change, which is what macOS TCC uses as the grant key for
//! Accessibility, Screen Recording, and similar permissions. Without
//! this, every rebuild produces a fresh ad-hoc signature and users must
//! re-grant permissions each time.
//!
//! For local development, any self-signed keychain certificate works —
//! create one via Keychain Access → Certificate Assistant → Create a
//! Certificate (identity type: Code Signing). Then pass the certificate
//! common name as the `identity` argument here.
//!
//! `codesign` handles both plain Mach-O binaries and `.app` bundles via
//! the same argument shape, so this helper accepts either.

use std::path::Path;
use std::process::Command;

use crate::StubError;

/// Run `codesign --force --sign <identity> <path>` on the given path.
///
/// The `--force` flag replaces any signature already present (the
/// automatic ad-hoc one from the linker, or a previous sign from this
/// helper). `identity` is passed verbatim to `codesign -s` — use `"-"`
/// for explicit ad-hoc, a Developer ID CN for distribution, or the CN
/// of a self-signed certificate for local dev.
///
/// Errors map to [`StubError::CodesignNotFound`] if `codesign` itself
/// isn't on PATH, and [`StubError::CodesignFailed`] if the signing run
/// exits non-zero (bad identity, unsupported path, keychain locked, etc.).
pub fn codesign_path(path: &Path, identity: &str) -> Result<(), StubError> {
    let output = Command::new("codesign")
        .arg("--force")
        .arg("--sign")
        .arg(identity)
        .arg(path)
        .output()
        .map_err(StubError::CodesignNotFound)?;

    if output.status.success() {
        tracing::debug!(
            path = %path.display(),
            identity = %identity,
            "signed with codesign"
        );
        return Ok(());
    }

    Err(StubError::CodesignFailed {
        path: path.to_path_buf(),
        identity: identity.to_string(),
        stderr: String::from_utf8_lossy(&output.stderr).to_string(),
    })
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;
    use std::process::Command;

    /// codesign is present on every macOS; skip on other platforms
    /// (CI containers, Linux dev boxes).
    fn codesign_available() -> bool {
        Command::new("codesign")
            .arg("-h")
            .output()
            .map(|o| o.status.code().is_some())
            .unwrap_or(false)
    }

    /// Compile a minimal Swift executable to sign in tests. Avoids
    /// pulling in the full stub-launcher pipeline just to get a binary
    /// that codesign will accept (plain shell scripts are rejected —
    /// codesign requires a Mach-O).
    fn swiftc_available() -> bool {
        Command::new("swiftc")
            .arg("--version")
            .output()
            .map(|o| o.status.success())
            .unwrap_or(false)
    }

    fn write_tiny_binary(dir: &Path, name: &str) -> std::path::PathBuf {
        let src = dir.join("_tiny.swift");
        fs::write(&src, "print(\"ok\")\n").expect("write tiny source");
        let out = dir.join(name);
        let status = Command::new("swiftc")
            .arg("-O")
            .arg("-o")
            .arg(&out)
            .arg(&src)
            .status()
            .expect("run swiftc");
        assert!(status.success(), "tiny binary must compile");
        out
    }

    #[test]
    fn codesign_path_accepts_ad_hoc_identity() {
        if !codesign_available() || !swiftc_available() {
            eprintln!("SKIPPED: codesign or swiftc unavailable");
            return;
        }
        let dir = tempfile::tempdir().expect("tempdir");
        let bin = write_tiny_binary(dir.path(), "adhoc");

        codesign_path(&bin, "-").expect("ad-hoc sign must succeed");

        // Verify codesign can now read a signature off the binary.
        let out = Command::new("codesign")
            .arg("-dv")
            .arg(&bin)
            .output()
            .expect("run codesign -dv");
        assert!(
            out.status.success(),
            "codesign -dv failed after signing: {}",
            String::from_utf8_lossy(&out.stderr)
        );
    }

    #[test]
    fn codesign_path_rejects_unknown_identity() {
        if !codesign_available() || !swiftc_available() {
            eprintln!("SKIPPED: codesign or swiftc unavailable");
            return;
        }
        let dir = tempfile::tempdir().expect("tempdir");
        let bin = write_tiny_binary(dir.path(), "bad");

        let err = codesign_path(&bin, "CertificateThatShouldNeverExist-ZZ99").unwrap_err();
        match err {
            StubError::CodesignFailed {
                path,
                identity,
                stderr,
            } => {
                assert_eq!(path, bin);
                assert_eq!(identity, "CertificateThatShouldNeverExist-ZZ99");
                assert!(
                    !stderr.is_empty(),
                    "codesign must report a reason for failure"
                );
            }
            other => panic!("expected CodesignFailed, got {other:?}"),
        }
    }
}
