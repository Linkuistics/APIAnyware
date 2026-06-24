//! Shared bundling vocabulary for the chez target: the [`AppSpec`] an app
//! is described by, the [`BundleError`] surface, and the code-signing
//! identity resolution every bundle uses.
//!
//! The bundle *pipeline* itself lives in [`crate::standalone`] — chez apps
//! ship as self-contained binaries that embed the Chez kernel (ADR-0009;
//! `targets/chez/docs/design/2026-05-29-chez-standalone-distribution-design.md`). There is
//! no longer a source-exec / system-Chez path: this module holds only the
//! types and helpers that pipeline drives.

use std::collections::HashMap;
use std::path::PathBuf;

use apianyware_stub_launcher::StubError;
use plist::Value as PlistValue;

/// The persistent self-signed identity documented in docs/codesigning-identity.md.
/// Shared with bundle-racket: the chez bundle uses the same identity
/// because TCC grants attach to the bundle id and identity, not the
/// target language.
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
/// (`<script_name>.sls`). `app_name` is the human-readable display name
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
    /// dylib, and the full bundle. `None` selects ad-hoc.
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

    #[error("could not resolve entry script {0}: {1}")]
    ResolveEntry(PathBuf, std::io::Error),

    #[error("entry script {entry} is outside source root {root}")]
    EntryOutsideRoot { entry: PathBuf, root: PathBuf },

    #[error("entry script {entry} not found")]
    EntryMissing { entry: PathBuf },

    #[error("chez binary {chez_bin:?} not available: {source}")]
    ChezNotAvailable {
        chez_bin: String,
        #[source]
        source: std::io::Error,
    },

    #[error("chez deps walker failed:\n{stderr}")]
    DepsExtractFailed { stderr: String },

    #[error(
        "Chez kernel artifacts (libkernel.a, petite.boot, scheme.boot, scheme.h) \
         not found. Searched: {searched}. Set AW_CHEZ_KERNEL_DIR to override."
    )]
    KernelArtifactsNotFound { searched: String },

    #[error("standalone collision probe failed (chez):\n{stderr}")]
    CollisionProbeFailed { stderr: String },

    #[error(
        "collision probe reported facade {facade} but it does not appear \
         verbatim in the app entry's import form — cannot rewrite it to an \
         (except ...) clause"
    )]
    FacadeNotInSource { facade: String },

    #[error(
        "app entry does not end in a top-level `(main)` call — the wrapper \
         generator cannot install its `(scheme-start ...)` thunk"
    )]
    WrapperNoTrailingMain,

    #[error("boot prelude compile failed (chez):\n{stderr}")]
    PreludeCompileFailed { stderr: String },

    #[error("whole-program compile failed (chez):\n{stderr}")]
    WholeProgramCompileFailed { stderr: String },

    #[error("make-boot-file failed (chez):\n{stderr}")]
    MakeBootFailed { stderr: String },

    #[error("cc link of the embedding host failed:\n{stderr}")]
    CcLinkFailed { stderr: String },

    #[error("`cc` not available: {0}")]
    CcNotAvailable(#[source] std::io::Error),

    #[error(
        "dependency walker reported file {target} outside source root {root} \
         (chez resolved a library to a path outside the bundle tree)"
    )]
    DepOutsideRoot { target: PathBuf, root: PathBuf },

    #[error(
        "libAPIAnywareChez.dylib not found under source root {source_root} — \
         chez bundles require the dylib (mandatory, no fallback). Build it \
         with the swift target first."
    )]
    DylibMissing { source_root: PathBuf },

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
