//! Shared bundling vocabulary for the Node TypeScript target: the [`AppSpec`]
//! an app is described by, and the [`BundleError`] surface every stage of the
//! pipeline raises.
//!
//! The bundle *pipeline* lives in [`crate::standalone`] — a Node TypeScript
//! `.app` embeds a vendored, pinned `libnode` behind a per-app native launcher
//! that owns `main()` (ADR-0060). There is no stub / `execv` path: that model
//! is the four Lisp targets', ruled out by ADR-0060's own "Context" section
//! (the native side must own `main()`, so the launcher cannot be a
//! byte-identical stub that `execv`s a shared runtime).

use std::collections::HashMap;
use std::path::PathBuf;

use apianyware_stub_launcher::StubError;
use plist::Value as PlistValue;

/// The persistent self-signed identity documented in
/// `platforms/macos/docs/codesigning-identity.md`. Shared with every other
/// target's bundler: TCC grants attach to the bundle id and identity, not the
/// target language.
pub const LOCAL_SIGNING_IDENTITY: &str = "APIAnyware Local Signing";

/// Resolve the signing identity to bake into bundled apps. Uses the
/// persistent local identity when the keychain has it (stable CDHash across
/// rebuilds), otherwise `None` (link-time ad-hoc).
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
/// directory (`app-implementations/macos/<script_name>/`) and the compiled
/// entry (`build/js/app-implementations/macos/<script_name>/app.js`).
/// `app_name` is the human-readable display name that ends up as
/// `CFBundleName`. Use [`AppSpec::from_script_name`] to derive both from the
/// kebab form.
#[derive(Debug, Clone)]
pub struct AppSpec {
    /// Display name (`CFBundleName`). Example: `"Hello Window"`.
    pub app_name: String,
    /// Bundle identifier. Example: `"com.linkuistics.HelloWindow"`.
    pub bundle_id: String,
    /// Source directory + compiled-entry base name. Example: `"hello-window"`.
    pub script_name: String,
    /// Extra keys to merge into the generated `Info.plist`. Keys here
    /// override any key of the same name produced by the base template.
    pub info_plist_overrides: HashMap<String, PlistValue>,
    /// Codesign identity applied to the native launcher, every vendored
    /// dylib/addon, and the full bundle. `None` selects ad-hoc.
    pub signing_identity: Option<String>,
    /// Extra `-framework <name>` args the launcher link needs beyond the
    /// baseline AppKit/Foundation/CoreFoundation every app gets. Most system
    /// frameworks (SceneKit, WebKit, …) resolve their ObjC classes fine
    /// without an explicit link in this environment, but PDFKit does not —
    /// `objc_getClass` returns nil unless PDFKit is a load command of the
    /// launcher itself (confirmed empirically, `pdfkit-viewer/learnings.md`).
    /// Mirrors the same per-app `-framework` list each sample app's own dev
    /// `build.sh` already states.
    pub extra_frameworks: Vec<String>,
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
            extra_frameworks: Vec::new(),
        }
    }
}

#[derive(Debug, thiserror::Error)]
pub enum BundleError {
    #[error(
        "app not built: {app_js} does not exist — run the app's own build.sh first \
         (targets/typescript/app-implementations/macos/{script}/build.sh)"
    )]
    AppNotBuilt { app_js: PathBuf, script: String },

    #[error(
        "native addon not built: {addon} does not exist — run \
         targets/typescript/bindings/node/native/build.sh first"
    )]
    AddonNotBuilt { addon: PathBuf },

    #[error("loader not found: {0}")]
    LoaderMissing(PathBuf),

    #[error(
        "node embedder toolchain not found (need a `node` on PATH whose prefix ships \
         include/node/node.h and a shared libnode.<ver>.dylib): {reason}"
    )]
    NodeToolchainNotFound { reason: String },

    #[error("clang++ failed to compile {file}:\n{stderr}")]
    ClangFailed { file: PathBuf, stderr: String },

    #[error("swiftc failed to link the native launcher:\n{stderr}")]
    SwiftcLinkFailed { stderr: String },

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
