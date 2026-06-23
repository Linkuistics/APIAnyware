//! macOS SDK discovery via `xcrun`.
//!
//! Locates the active macOS SDK and queries its version, providing the
//! base paths needed for framework discovery and header parsing.

use std::path::{Path, PathBuf};
use std::process::Command;

use anyhow::{Context, Result};

/// Information about the active macOS SDK.
#[derive(Debug, Clone)]
pub struct SdkInfo {
    /// Absolute path to the SDK root (e.g., `/Applications/Xcode.app/.../MacOSX.sdk`).
    pub path: PathBuf,
    /// SDK version string (e.g., `"15.4"`).
    pub version: String,
}

/// Discover the active macOS SDK via `xcrun`.
pub fn discover_sdk() -> Result<SdkInfo> {
    let path = sdk_path()?;
    let version = sdk_version()?;
    Ok(SdkInfo { path, version })
}

/// Get the SDK root path via `xcrun --show-sdk-path`.
fn sdk_path() -> Result<PathBuf> {
    let output = Command::new("xcrun")
        .args(["--show-sdk-path"])
        .output()
        .context("failed to execute xcrun --show-sdk-path")?;

    if !output.status.success() {
        anyhow::bail!(
            "xcrun --show-sdk-path failed: {}",
            String::from_utf8_lossy(&output.stderr)
        );
    }

    let path = String::from_utf8(output.stdout)
        .context("xcrun output is not valid UTF-8")?
        .trim()
        .to_string();

    Ok(PathBuf::from(path))
}

/// Get the SDK version via `xcrun --show-sdk-version`.
fn sdk_version() -> Result<String> {
    let output = Command::new("xcrun")
        .args(["--show-sdk-version"])
        .output()
        .context("failed to execute xcrun --show-sdk-version")?;

    if !output.status.success() {
        anyhow::bail!(
            "xcrun --show-sdk-version failed: {}",
            String::from_utf8_lossy(&output.stderr)
        );
    }

    let version = String::from_utf8(output.stdout)
        .context("xcrun output is not valid UTF-8")?
        .trim()
        .to_string();

    Ok(version)
}

/// Frameworks that are structurally incompatible with ObjC/C extraction.
///
/// - `DriverKit`: C++ headers, not ObjC — libclang parsing fails
/// - `Tk`: Tcl/Tk toolkit, not a native macOS framework
pub const IGNORED_FRAMEWORKS: &[&str] = &["DriverKit", "Tk"];

/// Returns `true` if the given framework name is in the ignore list.
pub fn is_framework_ignored(name: &str) -> bool {
    IGNORED_FRAMEWORKS.contains(&name)
}

/// Discover available frameworks by scanning `{SDK}/System/Library/Frameworks/`.
///
/// Returns framework names (e.g., `"Foundation"`, `"AppKit"`) for directories
/// that contain an umbrella header matching the framework name. Frameworks in
/// [`IGNORED_FRAMEWORKS`] are excluded with an informational log message.
pub fn discover_frameworks(sdk_path: &Path) -> Result<Vec<FrameworkInfo>> {
    let frameworks_dir = sdk_path.join("System/Library/Frameworks");
    if !frameworks_dir.exists() {
        anyhow::bail!(
            "frameworks directory not found: {}",
            frameworks_dir.display()
        );
    }

    let mut frameworks = Vec::new();

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

        // Framework directories end with .framework
        let framework_name = match dir_name.strip_suffix(".framework") {
            Some(name) => name.to_string(),
            None => continue,
        };

        // Skip ignored frameworks
        if is_framework_ignored(&framework_name) {
            tracing::info!(
                framework = %framework_name,
                "skipping ignored framework"
            );
            continue;
        }

        // Check for umbrella header
        let umbrella_header = path.join("Headers").join(format!("{framework_name}.h"));
        if !umbrella_header.exists() {
            tracing::debug!(
                framework = %framework_name,
                "skipping framework: no umbrella header"
            );
            continue;
        }

        frameworks.push(FrameworkInfo {
            name: framework_name,
            umbrella_header,
            framework_dir: path,
        });
    }

    // Append synthetic pseudo-frameworks for symbols that live outside
    // the framework directory tree (libdispatch, pthread) but are still
    // part of the macOS ABI. The umbrella header is checked into this
    // crate and referenced by absolute path.
    frameworks.extend(synthetic_frameworks());

    frameworks.sort_by(|a, b| a.name.cmp(&b.name));
    Ok(frameworks)
}

/// Synthetic frameworks: pseudo-frameworks whose umbrella header lives
/// inside this crate and whose declarations originate from system
/// headers under `{SDK}/usr/include/` rather than a real `.framework/`
/// directory.
fn synthetic_frameworks() -> Vec<FrameworkInfo> {
    let crate_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    let libdispatch_header = crate_dir
        .join("synthetic-frameworks")
        .join("libdispatch")
        .join("libdispatch.h");
    if !libdispatch_header.exists() {
        return Vec::new();
    }
    vec![FrameworkInfo {
        name: "libdispatch".to_string(),
        umbrella_header: libdispatch_header.clone(),
        framework_dir: libdispatch_header
            .parent()
            .expect("synthetic umbrella has a parent dir")
            .to_path_buf(),
    }]
}

/// Information about a discovered framework.
#[derive(Debug, Clone)]
pub struct FrameworkInfo {
    /// Framework name (e.g., `"Foundation"`).
    pub name: String,
    /// Path to the umbrella header (e.g., `.../Foundation.framework/Headers/Foundation.h`).
    pub umbrella_header: PathBuf,
    /// Path to the framework directory.
    pub framework_dir: PathBuf,
}
