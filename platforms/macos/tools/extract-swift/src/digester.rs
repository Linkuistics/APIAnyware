//! Invoke `swift-api-digester -dump-sdk` and discover Swift modules.
//!
//! This module handles locating the swift-api-digester tool via `xcrun`,
//! discovering which frameworks have `.swiftmodule` directories, and
//! invoking the digester to produce ABIRoot JSON output.

use std::path::{Path, PathBuf};
use std::process::Command;

use anyhow::{Context, Result};

/// Information about a discovered Swift module within a framework.
#[derive(Debug, Clone)]
pub struct SwiftModuleInfo {
    /// Module name (e.g., `"Foundation"`, `"SwiftData"`).
    pub name: String,
    /// Path to the `.swiftmodule` directory.
    pub swiftmodule_dir: PathBuf,
    /// Path to the parent `.framework` directory.
    pub framework_dir: PathBuf,
}

/// Discover frameworks that have a `.swiftmodule` directory.
///
/// Scans `{sdk_path}/System/Library/Frameworks/` for `.framework` directories
/// containing a `Modules/{FrameworkName}.swiftmodule/` subdirectory.
pub fn discover_swift_modules(sdk_path: &Path) -> Result<Vec<SwiftModuleInfo>> {
    let frameworks_dir = sdk_path.join("System/Library/Frameworks");
    if !frameworks_dir.exists() {
        anyhow::bail!(
            "frameworks directory not found: {}",
            frameworks_dir.display()
        );
    }

    let mut modules = Vec::new();

    for entry in std::fs::read_dir(&frameworks_dir)
        .with_context(|| format!("failed to read {}", frameworks_dir.display()))?
    {
        let entry = entry?;
        let path = entry.path();

        if !path.is_dir() {
            continue;
        }

        let dir_name = match path.file_name().and_then(|n| n.to_str()) {
            Some(name) => name.to_string(),
            None => continue,
        };

        let framework_name = match dir_name.strip_suffix(".framework") {
            Some(name) => name.to_string(),
            None => continue,
        };

        let swiftmodule_dir = path
            .join("Modules")
            .join(format!("{framework_name}.swiftmodule"));

        if swiftmodule_dir.is_dir() {
            modules.push(SwiftModuleInfo {
                name: framework_name,
                swiftmodule_dir,
                framework_dir: path,
            });
        }
    }

    modules.sort_by(|a, b| a.name.cmp(&b.name));
    Ok(modules)
}

/// Locate the `swift-api-digester` binary via `xcrun`.
pub fn find_swift_api_digester() -> Result<PathBuf> {
    let output = Command::new("xcrun")
        .args(["--find", "swift-api-digester"])
        .output()
        .context("failed to execute xcrun --find swift-api-digester")?;

    if !output.status.success() {
        anyhow::bail!(
            "xcrun --find swift-api-digester failed: {}",
            String::from_utf8_lossy(&output.stderr)
        );
    }

    let path = String::from_utf8(output.stdout)
        .context("xcrun output is not valid UTF-8")?
        .trim()
        .to_string();

    Ok(PathBuf::from(path))
}

/// Run `swift-api-digester -dump-sdk` for a module and return the JSON output.
///
/// Invokes:
/// ```text
/// xcrun swift-api-digester -dump-sdk \
///   -module {module_name} \
///   -sdk {sdk_path} \
///   -target arm64-apple-macos14.0
/// ```
///
/// Returns the raw JSON string (not yet parsed).
pub fn run_swift_api_digester(module_name: &str, sdk_path: &Path) -> Result<String> {
    let temp_dir = std::env::temp_dir();
    let output_path = temp_dir.join(format!("swift_abi_{module_name}.json"));

    let output = Command::new("xcrun")
        .args([
            "swift-api-digester",
            "-dump-sdk",
            "-module",
            module_name,
            "-sdk",
            &sdk_path.to_string_lossy(),
            "-target",
            "arm64-apple-macos14.0",
            "-o",
            &output_path.to_string_lossy(),
        ])
        .output()
        .with_context(|| {
            format!("failed to execute swift-api-digester for module {module_name}")
        })?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        anyhow::bail!("swift-api-digester failed for module {module_name}: {stderr}");
    }

    let json = std::fs::read_to_string(&output_path).with_context(|| {
        format!(
            "failed to read swift-api-digester output: {}",
            output_path.display()
        )
    })?;

    // Clean up temp file
    let _ = std::fs::remove_file(&output_path);

    Ok(json)
}
