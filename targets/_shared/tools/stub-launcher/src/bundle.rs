//! Compilation and app bundle assembly.

use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

use crate::codesign::codesign_path;
use crate::generate::{generate_info_plist, generate_stub_source};
use crate::{StubConfig, StubError};

/// Compile Swift source code into a macOS binary.
///
/// Writes the source to a temporary file next to the output, invokes `swiftc`,
/// and places the resulting binary at `output_path`. The temporary source file
/// is cleaned up regardless of success or failure.
pub fn compile_stub(source: &str, output_path: &Path) -> Result<(), StubError> {
    let source_dir = output_path.parent().ok_or_else(|| {
        StubError::Io(std::io::Error::new(
            std::io::ErrorKind::InvalidInput,
            "output_path has no parent directory",
        ))
    })?;

    let source_path = source_dir.join("_stub_launcher.swift");
    fs::write(&source_path, source)?;

    let result = Command::new("swiftc")
        .args(["-O", "-o"])
        .arg(output_path)
        .arg(&source_path)
        .output();

    // Always clean up the temporary source file
    let _ = fs::remove_file(&source_path);

    let output = result.map_err(StubError::CompilerNotFound)?;

    if !output.status.success() {
        return Err(StubError::CompilationFailed {
            stderr: String::from_utf8_lossy(&output.stderr).to_string(),
        });
    }

    Ok(())
}

/// Create a complete `.app` bundle directory structure.
///
/// Generates the Swift stub, compiles it, writes `Info.plist`, and assembles the
/// bundle at `{output_dir}/{app_name}.app/`. Returns the path to the `.app` directory.
///
/// The caller is responsible for populating
/// `Contents/Resources/{script_resource_dir}/` with the actual script files
/// and runtime dependencies.
pub fn create_app_bundle(config: &StubConfig, output_dir: &Path) -> Result<PathBuf, StubError> {
    let app_dir = output_dir.join(format!("{}.app", config.app_name));
    let contents_dir = app_dir.join("Contents");
    let macos_dir = contents_dir.join("MacOS");
    let resources_dir = contents_dir.join("Resources");

    fs::create_dir_all(&macos_dir)?;
    fs::create_dir_all(&resources_dir)?;

    // Generate and compile the stub binary
    let source = generate_stub_source(config);
    let binary_path = macos_dir.join(&config.app_name);
    compile_stub(&source, &binary_path)?;

    // Write Info.plist
    let plist = generate_info_plist(config);
    fs::write(contents_dir.join("Info.plist"), plist)?;

    // Re-sign the binary with a stable identity, if requested. The
    // signature has to be applied before the caller populates
    // Resources/, otherwise any subsequent bundle-level sign would need
    // --deep to cover the binary as well.
    if let Some(identity) = &config.signing_identity {
        codesign_path(&binary_path, identity)?;
    }

    tracing::info!(
        app_name = %config.app_name,
        path = %app_dir.display(),
        "created app bundle"
    );

    Ok(app_dir)
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;

    fn test_config() -> StubConfig {
        StubConfig {
            app_name: "TestApp".to_string(),
            runtime_path: "/usr/bin/env".to_string(),
            runtime_args: vec![],
            script_resource_name: "main".to_string(),
            script_resource_type: "rkt".to_string(),
            script_resource_dir: "racket-app".to_string(),
            bundle_identifier: "com.test.TestApp".to_string(),
            signing_identity: None,
            libdirs_resource_subdir: None,
        }
    }

    #[test]
    fn compile_stub_produces_executable() {
        let dir = tempfile::tempdir().unwrap();
        let binary_path = dir.path().join("TestApp");
        let source = generate_stub_source(&test_config());

        compile_stub(&source, &binary_path).unwrap();

        assert!(binary_path.exists(), "compiled binary should exist");

        #[cfg(unix)]
        {
            use std::os::unix::fs::PermissionsExt;
            let permissions = fs::metadata(&binary_path).unwrap().permissions();
            assert!(
                permissions.mode() & 0o111 != 0,
                "binary should be executable"
            );
        }
    }

    #[test]
    fn compile_stub_rejects_invalid_swift() {
        let dir = tempfile::tempdir().unwrap();
        let binary_path = dir.path().join("Bad");

        let result = compile_stub("this is not valid swift {{{", &binary_path);
        assert!(result.is_err());

        match result.unwrap_err() {
            StubError::CompilationFailed { stderr } => {
                assert!(!stderr.is_empty(), "should have compiler error output");
            }
            other => panic!("expected CompilationFailed, got: {other}"),
        }
    }

    #[test]
    fn create_app_bundle_creates_directory_structure() {
        let dir = tempfile::tempdir().unwrap();
        let config = test_config();

        let app_path = create_app_bundle(&config, dir.path()).unwrap();

        assert!(app_path.ends_with("TestApp.app"));
        assert!(app_path.join("Contents/MacOS/TestApp").exists());
        assert!(app_path.join("Contents/Info.plist").exists());
        assert!(app_path.join("Contents/Resources").exists());
    }

    #[test]
    fn create_app_bundle_info_plist_matches_config() {
        let dir = tempfile::tempdir().unwrap();
        let config = test_config();

        let app_path = create_app_bundle(&config, dir.path()).unwrap();

        let plist_content = fs::read_to_string(app_path.join("Contents/Info.plist")).unwrap();
        assert!(plist_content.contains("com.test.TestApp"));
        assert!(plist_content.contains("TestApp"));
    }

    #[test]
    fn create_app_bundle_binary_is_executable() {
        let dir = tempfile::tempdir().unwrap();
        let config = test_config();

        let app_path = create_app_bundle(&config, dir.path()).unwrap();
        let binary_path = app_path.join("Contents/MacOS/TestApp");

        #[cfg(unix)]
        {
            use std::os::unix::fs::PermissionsExt;
            let permissions = fs::metadata(&binary_path).unwrap().permissions();
            assert!(
                permissions.mode() & 0o111 != 0,
                "bundle executable should be executable"
            );
        }
    }

    #[test]
    fn create_app_bundle_applies_signing_identity_when_set() {
        let dir = tempfile::tempdir().unwrap();
        let mut config = test_config();
        config.signing_identity = Some("-".to_string());

        let app_path = create_app_bundle(&config, dir.path()).unwrap();
        let binary_path = app_path.join("Contents/MacOS/TestApp");

        // `codesign -dv` exits 0 when a signature is present, non-zero
        // otherwise. The default linker-supplied ad-hoc signature does
        // technically show up, but running our explicit ad-hoc sign via
        // `--force` exercises the code path the StubConfig field gates.
        let status = Command::new("codesign")
            .arg("-dv")
            .arg(&binary_path)
            .output()
            .expect("run codesign");
        assert!(
            status.status.success(),
            "binary must carry a signature after signing_identity=Some(...): {}",
            String::from_utf8_lossy(&status.stderr)
        );
    }
}
