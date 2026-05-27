//! Assemble a `.app` bundle for a chez sample app.

use std::collections::HashMap;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

use apianyware_macos_stub_launcher::{codesign_path, create_app_bundle, StubConfig, StubError};
use plist::Value as PlistValue;

use crate::deps::{absolutize, collect_dependencies};

/// Default Chez runtime path baked into stub binaries. Matches the
/// homebrew install location used by the chez runtime tests and
/// `verify.ss`.
pub const DEFAULT_CHEZ_PATH: &str = "/opt/homebrew/bin/chez";

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
    /// Absolute path to the chez runtime binary baked into the stub.
    pub runtime_path: String,
    /// Extra keys to merge into the generated `Info.plist`. Keys here
    /// override any key of the same name produced by the base template.
    pub info_plist_overrides: HashMap<String, PlistValue>,
    /// Codesign identity applied to the stub binary and to the full
    /// bundle once Resources are populated. `None` selects ad-hoc.
    pub signing_identity: Option<String>,
}

impl AppSpec {
    /// Derive an [`AppSpec`] from a kebab-case script name.
    ///
    /// `"hello-window"` → display `"Hello Window"`, bundle id
    /// `"com.linkuistics.HelloWindow"`. Runtime path defaults to
    /// [`DEFAULT_CHEZ_PATH`].
    pub fn from_script_name(script_name: impl Into<String>) -> Self {
        let script_name = script_name.into();
        let app_name = title_case_kebab(&script_name);
        let bundle_id = format!("com.linkuistics.{}", app_name.replace(' ', ""));
        Self {
            app_name,
            bundle_id,
            script_name,
            runtime_path: DEFAULT_CHEZ_PATH.to_string(),
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

    #[error("entry script {0} has no file stem — stub launcher needs a base name")]
    EntryHasNoStem(PathBuf),

    #[error("entry script {0} has no file extension — stub launcher needs a resource type")]
    EntryHasNoExtension(PathBuf),

    #[error("chez binary {chez_bin:?} not available: {source}")]
    ChezNotAvailable {
        chez_bin: String,
        #[source]
        source: std::io::Error,
    },

    #[error("chez deps walker failed:\n{stderr}")]
    DepsExtractFailed { stderr: String },

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

    #[error("could not merge Info.plist overrides: {0}")]
    InfoPlistMerge(#[from] plist::Error),

    #[error("Info.plist at {0} is not a top-level dictionary")]
    InfoPlistRootNotDict(PathBuf),
}

/// Bundle a sample app at `source_root/apps/<script_name>/<script_name>.sls`
/// into `output_dir/<App Name>.app`. Returns the path to the new bundle.
pub fn bundle_app(
    spec: &AppSpec,
    source_root: &Path,
    output_dir: &Path,
) -> Result<PathBuf, BundleError> {
    let entry = source_root
        .join("apps")
        .join(&spec.script_name)
        .join(format!("{}.sls", spec.script_name));

    if !entry.exists() {
        return Err(BundleError::EntryMissing { entry });
    }

    bundle_app_with_entry(spec, &entry, source_root, output_dir)
}

/// Bundle an arbitrary chez entry script into a `.app`.
///
/// Resource layout per design spec §8: every `.sls` file the entry
/// script transitively imports lands at
/// `Resources/chez-app/<rel>` where `<rel>` is the file's path
/// relative to `source_root`. The `lib/` directory at source_root is
/// required to contain `libAPIAnywareChez.dylib` and is copied
/// wholesale (mandatory-dylib invariant — no fallback path, unlike
/// bundle-racket where the dylib is optional).
///
/// The Swift stub is configured to exec `chez --script` against the
/// entry file's bundle-resource location, so
/// `Bundle.main.path(forResource:ofType:inDirectory:)` finds it at
/// runtime.
pub fn bundle_app_with_entry(
    spec: &AppSpec,
    entry: &Path,
    source_root: &Path,
    output_dir: &Path,
) -> Result<PathBuf, BundleError> {
    let abs_root = absolutize(source_root)
        .map_err(|e| BundleError::ResolveSourceRoot(source_root.to_path_buf(), e))?;
    let abs_entry =
        absolutize(entry).map_err(|e| BundleError::ResolveEntry(entry.to_path_buf(), e))?;

    if !abs_entry.starts_with(&abs_root) {
        return Err(BundleError::EntryOutsideRoot {
            entry: abs_entry,
            root: abs_root,
        });
    }
    if !abs_entry.exists() {
        return Err(BundleError::EntryMissing { entry: abs_entry });
    }

    // Mandatory-dylib precheck: design spec §8 calls this out explicitly.
    // Fail before touching the output dir so the user gets one clear
    // error rather than a half-bundled app.
    let lib_src = abs_root.join("lib");
    let dylib_src = lib_src.join("libAPIAnywareChez.dylib");
    if !dylib_src.exists() {
        return Err(BundleError::DylibMissing {
            source_root: abs_root,
        });
    }

    let script_resource_name = abs_entry
        .file_stem()
        .ok_or_else(|| BundleError::EntryHasNoStem(abs_entry.clone()))?
        .to_string_lossy()
        .into_owned();
    let script_resource_type = abs_entry
        .extension()
        .ok_or_else(|| BundleError::EntryHasNoExtension(abs_entry.clone()))?
        .to_string_lossy()
        .into_owned();

    let script_resource_dir = derive_script_resource_dir(&abs_entry, &abs_root);

    let dependencies = collect_dependencies(&abs_entry, &abs_root)?;

    let stub_config = StubConfig {
        app_name: spec.app_name.clone(),
        runtime_path: spec.runtime_path.clone(),
        runtime_args: vec!["--script".to_string()],
        script_resource_name,
        script_resource_type,
        script_resource_dir,
        bundle_identifier: spec.bundle_id.clone(),
        signing_identity: spec.signing_identity.clone(),
        // Chez resolves `(apianyware ...)` library names against
        // <libdir>/apianyware/...; the bundle stages the apianyware
        // tree under Resources/chez-app/apianyware/ so the libdir is
        // the resource subdir itself.
        libdirs_resource_subdir: Some("chez-app".to_string()),
    };

    fs::create_dir_all(output_dir)?;
    let app_path = create_app_bundle(&stub_config, output_dir)?;

    if !spec.info_plist_overrides.is_empty() {
        let plist_path = app_path.join("Contents").join("Info.plist");
        merge_info_plist_overrides(&plist_path, &spec.info_plist_overrides)?;
    }

    let chez_app = app_path.join("Contents").join("Resources").join("chez-app");

    for src in &dependencies {
        let rel = src
            .strip_prefix(&abs_root)
            .expect("dependency was validated to be under source root");
        let dst = chez_app.join(rel);
        fs::create_dir_all(dst.parent().expect("dst has parent"))?;
        fs::copy(src, &dst)?;
    }

    let lib_dst = chez_app.join("lib");
    copy_dir_recursive(&lib_src, &lib_dst)?;
    normalize_dylib_install_names(&lib_dst)?;

    if let Some(identity) = &spec.signing_identity {
        codesign_path(&app_path, identity)?;
    }

    tracing::info!(
        app = %spec.app_name,
        path = %app_path.display(),
        files = dependencies.len(),
        "bundled chez app"
    );

    Ok(app_path)
}

/// `chez-app/` is always the top of the bundle's chez tree. Append the
/// entry's parent dir relative to `abs_root` so the stub's
/// `Bundle.main.path(forResource:ofType:inDirectory:)` lookup finds
/// the script.
fn derive_script_resource_dir(abs_entry: &Path, abs_root: &Path) -> String {
    let parent_rel = abs_entry
        .parent()
        .and_then(|p| p.strip_prefix(abs_root).ok())
        .unwrap_or_else(|| Path::new(""));
    if parent_rel.as_os_str().is_empty() {
        "chez-app".to_string()
    } else {
        format!("chez-app/{}", parent_rel.to_string_lossy())
    }
}

fn copy_dir_recursive(src: &Path, dst: &Path) -> std::io::Result<()> {
    fs::create_dir_all(dst)?;
    for entry in fs::read_dir(src)? {
        let entry = entry?;
        let from = entry.path();
        let to = dst.join(entry.file_name());
        let ftype = entry.file_type()?;
        if ftype.is_dir() {
            copy_dir_recursive(&from, &to)?;
        } else {
            fs::copy(&from, &to)?;
        }
    }
    Ok(())
}

fn merge_info_plist_overrides(
    plist_path: &Path,
    overrides: &HashMap<String, PlistValue>,
) -> Result<(), BundleError> {
    let mut value = PlistValue::from_file(plist_path)?;
    let dict = value
        .as_dictionary_mut()
        .ok_or_else(|| BundleError::InfoPlistRootNotDict(plist_path.to_path_buf()))?;
    for (key, override_value) in overrides {
        dict.insert(key.clone(), override_value.clone());
    }
    plist::to_file_xml(plist_path, &value)?;
    Ok(())
}

/// Rewrite each `.dylib`'s LC_ID_DYLIB so its self-reported identity
/// resolves within the bundle. See bundle-racket for the full rationale —
/// the chez story is identical except the path component is `chez-app/`.
fn normalize_dylib_install_names(lib_dst: &Path) -> std::io::Result<()> {
    for entry in fs::read_dir(lib_dst)? {
        let entry = entry?;
        let path = entry.path();
        if path.extension().map(|e| e == "dylib").unwrap_or(false) {
            let file_name = path
                .file_name()
                .expect("dylib path has file name")
                .to_string_lossy()
                .into_owned();
            let new_id = format!("@executable_path/../Resources/chez-app/lib/{file_name}");
            match Command::new("install_name_tool")
                .arg("-id")
                .arg(&new_id)
                .arg(&path)
                .output()
            {
                Ok(out) if out.status.success() => {}
                Ok(out) => {
                    tracing::warn!(
                        dylib = %path.display(),
                        stderr = %String::from_utf8_lossy(&out.stderr),
                        "install_name_tool -id failed; leaving dylib with original install name"
                    );
                }
                Err(e) => {
                    tracing::warn!(
                        dylib = %path.display(),
                        error = %e,
                        "install_name_tool not available; leaving dylib with original install name"
                    );
                }
            }
        }
    }
    Ok(())
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
        assert_eq!(spec.runtime_path, DEFAULT_CHEZ_PATH);
    }

    #[test]
    fn script_resource_dir_root_level_entry_is_chez_app() {
        let dir = derive_script_resource_dir(Path::new("/root/main.sls"), Path::new("/root"));
        assert_eq!(dir, "chez-app");
    }

    #[test]
    fn script_resource_dir_apps_sample_layout_appends_path() {
        let dir = derive_script_resource_dir(
            Path::new("/root/apps/hello-window/hello-window.sls"),
            Path::new("/root"),
        );
        assert_eq!(dir, "chez-app/apps/hello-window");
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
