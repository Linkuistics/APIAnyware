//! Shared bundling vocabulary for the gerbil target: the [`AppSpec`] an app
//! is described by, the [`BundleError`] surface, and the code-signing
//! identity resolution every bundle uses.
//!
//! The bundle *pipeline* itself lives in [`crate::standalone`] — gerbil apps
//! ship as self-contained `gxc -exe` binaries that embed the Gerbil/Gambit
//! runtime (ADR-0009; `generation/targets/gerbil/docs/design/2026-06-03-gerbil-target-design.md` §7).
//! This module holds only the types and helpers that pipeline drives.

use std::collections::HashMap;
use std::path::PathBuf;

use apianyware_macos_stub_launcher::StubError;
use plist::Value as PlistValue;

/// The persistent self-signed identity documented in docs/codesigning-identity.md.
/// Shared with bundle-racket / bundle-chez: TCC grants attach to the bundle
/// id and identity, not the target language.
pub const LOCAL_SIGNING_IDENTITY: &str = "APIAnyware Local Signing";

/// Resolve the signing identity to bake into bundled apps. Uses the
/// persistent local identity when the keychain has it (stable CDHash
/// across rebuilds), otherwise `None` (link-time ad-hoc).
pub fn resolve_signing_identity(is_available: impl Fn(&str) -> bool) -> Option<String> {
    if is_available(LOCAL_SIGNING_IDENTITY) {
        Some(LOCAL_SIGNING_IDENTITY.to_string())
    } else {
        tracing::warn!(
            identity = LOCAL_SIGNING_IDENTITY,
            "code-signing identity not found; bundling with ad-hoc signature \
             (TCC grants will reset on rebuild — see docs/codesigning-identity.md)"
        );
        None
    }
}

fn keychain_has_identity(name: &str) -> bool {
    std::process::Command::new("security")
        .args(["find-identity", "-p", "codesigning", "-v"])
        .output()
        .map(|o| String::from_utf8_lossy(&o.stdout).contains(name))
        .unwrap_or(false)
}

/// What to bundle.
///
/// `script_name` is the kebab-case identifier used for both the source
/// directory (`apps/<script_name>/`) and the entry script
/// (`<script_name>.ss`). `app_name` is the human-readable display name
/// that ends up as `CFBundleName`. Use [`AppSpec::from_script_name`] to
/// derive both from the kebab form.
#[derive(Debug, Clone)]
pub struct AppSpec {
    /// Display name (`CFBundleName`). Example: `"Hello Window"`.
    pub app_name: String,
    /// Bundle identifier. Example: `"com.linkuistics.HelloWindow"`.
    pub bundle_id: String,
    /// Source directory + entry-script base name. Example: `"hello-window"`.
    pub script_name: String,
    /// Extra keys to merge into the generated `Info.plist`. Keys here
    /// override any key of the same name produced by the base template.
    pub info_plist_overrides: HashMap<String, PlistValue>,
    /// Codesign identity applied to the standalone binary, the nested
    /// dylibs, and the full bundle. `None` selects ad-hoc.
    pub signing_identity: Option<String>,
}

impl AppSpec {
    /// Derive an [`AppSpec`] from a kebab-case script name.
    ///
    /// `"hello-window"` → display `"Hello Window"`, bundle id
    /// `"com.linkuistics.HelloWindow"`.
    pub fn from_script_name(script_name: impl Into<String>) -> Self {
        let script_name = script_name.into();
        let app_name = title_case_kebab(&script_name);
        let bundle_id = format!("com.linkuistics.{}", app_name.replace(' ', ""));
        Self {
            app_name,
            bundle_id,
            script_name,
            info_plist_overrides: HashMap::new(),
            signing_identity: resolve_signing_identity(keychain_has_identity),
        }
    }
}

#[derive(Debug, thiserror::Error)]
pub enum BundleError {
    #[error("could not resolve source root {0}: {1}")]
    ResolveSourceRoot(PathBuf, std::io::Error),

    #[error("entry script {entry} not found")]
    EntryMissing { entry: PathBuf },

    #[error(
        "gerbil toolchain not found. Searched: {searched}. Install the \
         gerbil-scheme bottle or set {env} to its bin directory."
    )]
    GerbilToolchainNotFound { searched: String, env: &'static str },

    #[error(
        "import {reference} (from {referrer}) does not resolve to a file under \
         the binding library root {lib_root} — expected {expected}"
    )]
    ImportNotFound {
        reference: String,
        referrer: PathBuf,
        lib_root: PathBuf,
        expected: PathBuf,
    },

    #[error("import cycle detected through {0} — the binding closure must be a DAG")]
    ImportCycle(PathBuf),

    #[error("clang failed to compile the native_block.c companion:\n{stderr}")]
    NativeBlockCompileFailed { stderr: String },

    #[error("`native_block.c` companion not found at {0}")]
    NativeBlockMissing(PathBuf),

    #[error("gxc -O failed to compile the binding closure:\n{stderr}")]
    ClosureCompileFailed { stderr: String },

    #[error("gxc -exe failed to link the app binary:\n{stderr}")]
    ExeLinkFailed { stderr: String },

    #[error("`{tool}` not available: {source}")]
    ToolNotAvailable {
        tool: &'static str,
        #[source]
        source: std::io::Error,
    },

    #[error("`otool -L` failed for {path}:\n{stderr}")]
    OtoolFailed { path: PathBuf, stderr: String },

    #[error("`install_name_tool` failed for {path}:\n{stderr}")]
    InstallNameToolFailed { path: PathBuf, stderr: String },

    #[error("vendored dylib source {0} does not exist")]
    DylibSourceMissing(PathBuf),

    #[error("I/O error: {0}")]
    Io(#[from] std::io::Error),

    #[error("stub-launcher error: {0}")]
    Stub(#[from] StubError),

    #[error("Info.plist error: {0}")]
    InfoPlist(#[from] plist::Error),
}

fn title_case_kebab(kebab: &str) -> String {
    kebab
        .split('-')
        .map(|word| {
            let mut chars = word.chars();
            match chars.next() {
                Some(first) => first.to_ascii_uppercase().to_string() + chars.as_str(),
                None => String::new(),
            }
        })
        .collect::<Vec<_>>()
        .join(" ")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn title_case_single_word() {
        assert_eq!(title_case_kebab("modaliser"), "Modaliser");
    }

    #[test]
    fn title_case_two_words() {
        assert_eq!(title_case_kebab("hello-window"), "Hello Window");
    }

    #[test]
    fn from_script_name_derives_display_and_bundle_id() {
        let spec = AppSpec::from_script_name("hello-window");
        assert_eq!(spec.app_name, "Hello Window");
        assert_eq!(spec.bundle_id, "com.linkuistics.HelloWindow");
        assert_eq!(spec.script_name, "hello-window");
    }

    #[test]
    fn resolves_convention_identity_when_present() {
        assert_eq!(
            resolve_signing_identity(|_name| true),
            Some(LOCAL_SIGNING_IDENTITY.to_string())
        );
    }

    #[test]
    fn falls_back_to_none_when_identity_absent() {
        assert_eq!(resolve_signing_identity(|_name| false), None);
    }
}
