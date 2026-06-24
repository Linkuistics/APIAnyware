//! Shared bundling vocabulary for the sbcl target: the [`AppSpec`] an app is
//! described by, the [`BundleError`] surface, the code-signing identity
//! resolution, and the `apps/macos/<script>/docs/spec.md` display-name reader.
//!
//! The bundle *pipeline* lives in [`crate::standalone`]. An sbcl `.app` ships a
//! `save-lisp-and-die :executable t` image (which embeds the SBCL runtime) plus
//! a thin Swift stub that sets `DYLD_FALLBACK_LIBRARY_PATH` and `execv`s the
//! image (ADR-0041) — the self-containment mechanism, since post-dump
//! `install_name_tool` is impossible on a dumped image.

use std::collections::HashMap;
use std::path::{Path, PathBuf};

use apianyware_stub_launcher::StubError;
use plist::Value as PlistValue;

/// The persistent self-signed identity documented in platforms/macos/docs/codesigning-identity.md.
/// Shared with bundle-racket / bundle-chez / bundle-gerbil: TCC grants attach to
/// the bundle id and identity, not the target language.
pub const LOCAL_SIGNING_IDENTITY: &str = "APIAnyware Local Signing";

/// Resolve the signing identity to bake into bundled apps. Uses the persistent
/// local identity when the keychain has it (stable CDHash across rebuilds),
/// otherwise `None` (ad-hoc).
pub fn resolve_signing_identity(is_available: impl Fn(&str) -> bool) -> Option<String> {
    if is_available(LOCAL_SIGNING_IDENTITY) {
        Some(LOCAL_SIGNING_IDENTITY.to_string())
    } else {
        tracing::warn!(
            identity = LOCAL_SIGNING_IDENTITY,
            "code-signing identity not found; bundling with ad-hoc signature \
             (TCC grants will reset on rebuild — see platforms/macos/docs/codesigning-identity.md)"
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
/// directory (`apps/<script_name>/`) and the entry/dump driver
/// (`<script_name>/dump.lisp`). `app_name` is the human-readable display name
/// that ends up as `CFBundleName`. Use [`AppSpec::from_script_name`] to derive
/// both from the kebab form.
#[derive(Debug, Clone)]
pub struct AppSpec {
    /// Display name (`CFBundleName`). Example: `"Hello Window"`.
    pub app_name: String,
    /// Bundle identifier. Example: `"com.linkuistics.HelloWindow"`.
    pub bundle_id: String,
    /// Source directory + dump-driver base name. Example: `"hello-window"`.
    pub script_name: String,
    /// Extra keys to merge into the generated `Info.plist`. Keys here override
    /// any key of the same name produced by the base template.
    pub info_plist_overrides: HashMap<String, PlistValue>,
    /// Codesign identity applied to the vendored dylibs, the Swift stub, and
    /// the whole bundle. `None` selects ad-hoc. The dumped SBCL image is
    /// **never** re-signed — `save-lisp-and-die` already ad-hoc signs it on
    /// arm64 and that signature must stay intact (it sits past `__LINKEDIT`).
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

    #[error("dump driver {driver} not found (expected apps/<script>/dump.lisp)")]
    DumpDriverMissing { driver: PathBuf },

    #[error(
        "sbcl not found on PATH. Install the steel-bank-common-lisp bottle \
         (`brew install sbcl`)."
    )]
    SbclNotFound,

    #[error("the Swift-native dylib {dylib} is not built and `swift build` failed:\n{stderr}")]
    SwiftDylibBuildFailed { dylib: PathBuf, stderr: String },

    #[error("`swift build` not available: {source}")]
    SwiftBuildNotAvailable {
        #[source]
        source: std::io::Error,
    },

    #[error("`sbcl` failed to dump the image for {script}:\n{stderr}")]
    DumpFailed { script: String, stderr: String },

    #[error("dump produced no image at {0}")]
    DumpProducedNoImage(PathBuf),

    #[error("`{tool}` not available: {source}")]
    ToolNotAvailable {
        tool: &'static str,
        #[source]
        source: std::io::Error,
    },

    #[error("`otool -L` failed for {path}:\n{stderr}")]
    OtoolFailed { path: PathBuf, stderr: String },

    #[error("vendored dylib source {0} does not exist")]
    DylibSourceMissing(PathBuf),

    #[error("I/O error: {0}")]
    Io(#[from] std::io::Error),

    #[error("stub-launcher error: {0}")]
    Stub(#[from] StubError),

    #[error("Info.plist error: {0}")]
    InfoPlist(#[from] plist::Error),
}

/// Read the first markdown H1 (`# Title`) from `apps/macos/<script>/docs/spec.md` and
/// return it as the display name. Returns `None` if the file is missing,
/// unreadable, or has no leading H1. Identical convention to the peer bundlers —
/// the spec.md is target-agnostic.
pub fn read_display_name_from_spec(spec_md_path: &Path) -> Option<String> {
    let content = std::fs::read_to_string(spec_md_path).ok()?;
    for line in content.lines() {
        let trimmed = line.trim_start();
        if let Some(rest) = trimmed.strip_prefix("# ") {
            let title = rest.trim().to_string();
            if !title.is_empty() {
                return Some(title);
            }
        }
        if !trimmed.is_empty() {
            return None;
        }
    }
    None
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
    use tempfile::TempDir;

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

    #[test]
    fn reads_first_h1_as_display_name() {
        let dir = TempDir::new().unwrap();
        let p = dir.path().join("spec.md");
        std::fs::write(&p, "# Swift Native Probe\n\n**Complexity:** 4/7\n").unwrap();
        assert_eq!(
            read_display_name_from_spec(&p),
            Some("Swift Native Probe".to_string())
        );
    }

    #[test]
    fn display_name_none_when_missing() {
        let dir = TempDir::new().unwrap();
        assert_eq!(
            read_display_name_from_spec(&dir.path().join("nope.md")),
            None
        );
    }
}
