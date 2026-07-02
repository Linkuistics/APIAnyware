//! Assemble a `.app` bundle for a racket sample app.

use std::collections::HashMap;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

use apianyware_stub_launcher::{codesign_path, create_app_bundle, StubConfig, StubError};
use plist::Value as PlistValue;

use crate::deps::{absolutize, collect_dependencies_in, SourceRoots};

/// Default Racket runtime path baked into stub binaries. Matches the
/// homebrew install location used everywhere else in the project (sample
/// apps, runtime-load harness, knowledge docs).
pub const DEFAULT_RACKET_PATH: &str = "/opt/homebrew/bin/racket";

/// The persistent self-signed identity documented in platforms/macos/docs/codesigning-identity.md.
pub const LOCAL_SIGNING_IDENTITY: &str = "APIAnyware Local Signing";

/// Resolve the signing identity to bake into bundled apps. Uses the
/// persistent local identity when the keychain has it (stable CDHash
/// across rebuilds), otherwise `None` (link-time ad-hoc — bundling still
/// works, but TCC grants reset on rebuild).
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

/// Query the keychain for a code-signing identity by name.
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
/// (`<script_name>.rkt`). `app_name` is the human-readable display name
/// that ends up as `CFBundleName` and the menu-bar app label. Use
/// [`AppSpec::from_script_name`] to derive both from the kebab form.
#[derive(Debug, Clone)]
pub struct AppSpec {
    /// Display name (`CFBundleName`, menu-bar bold name). Example: `"Hello Window"`.
    pub app_name: String,
    /// Bundle identifier (`CFBundleIdentifier`). Example: `"com.linkuistics.HelloWindow"`.
    pub bundle_id: String,
    /// Source directory + entry-script base name. Example: `"hello-window"`.
    pub script_name: String,
    /// Absolute path to the racket runtime binary baked into the stub.
    pub runtime_path: String,
    /// Extra keys to merge into the generated `Info.plist`. Keys here
    /// override any key of the same name produced by the base template —
    /// use this to declare `LSUIElement`, `NSAccessibilityUsageDescription`,
    /// `NSScreenCaptureUsageDescription`, custom `CFBundleURLTypes`, or
    /// any other plist key an app needs. An empty map (the default) leaves
    /// the base template untouched.
    pub info_plist_overrides: HashMap<String, PlistValue>,
    /// Codesign identity applied to the stub binary (and to the full
    /// bundle once Resources are populated). [`AppSpec::from_script_name`]
    /// resolves this automatically: it uses [`LOCAL_SIGNING_IDENTITY`] when
    /// the keychain has it (stable CDHash across rebuilds, TCC grants
    /// persist), falling back to `None` (ad-hoc) when the certificate is
    /// absent. Override with `Some("-")` for explicit ad-hoc or
    /// `Some("My Self-Signed Cert")` for any other identity.
    pub signing_identity: Option<String>,
}

impl AppSpec {
    /// Derive an [`AppSpec`] from a kebab-case script name.
    ///
    /// `"hello-window"` → display `"Hello Window"`, bundle id
    /// `"com.linkuistics.HelloWindow"`. The runtime path defaults to
    /// [`DEFAULT_RACKET_PATH`] and can be overridden afterwards.
    /// `info_plist_overrides` defaults to empty.
    pub fn from_script_name(script_name: impl Into<String>) -> Self {
        let script_name = script_name.into();
        let app_name = title_case_kebab(&script_name);
        let bundle_id = format!("com.linkuistics.{}", app_name.replace(' ', ""));
        Self {
            app_name,
            bundle_id,
            script_name,
            runtime_path: DEFAULT_RACKET_PATH.to_string(),
            info_plist_overrides: HashMap::new(),
            signing_identity: resolve_signing_identity(keychain_has_identity),
        }
    }
}

/// Errors from bundling.
#[derive(Debug, thiserror::Error)]
pub enum BundleError {
    #[error("could not resolve source root {0}: {1}")]
    ResolveSourceRoot(PathBuf, std::io::Error),

    #[error("could not resolve entry script {0}: {1}")]
    ResolveEntry(PathBuf, std::io::Error),

    #[error("entry script {entry} is outside source root {root}")]
    EntryOutsideRoot { entry: PathBuf, root: PathBuf },

    #[error("could not read source file {0}: {1}")]
    ReadSource(PathBuf, std::io::Error),

    #[error("require {target} from {referrer} could not be resolved: {source}")]
    ResolveRequire {
        referrer: PathBuf,
        target: String,
        source: std::io::Error,
    },

    #[error("require from {referrer} resolved to {target}, which is outside source root {root}")]
    RequireOutsideRoot {
        referrer: PathBuf,
        target: PathBuf,
        root: PathBuf,
    },

    #[error("entry script {entry} not found")]
    EntryMissing { entry: PathBuf },

    #[error("entry script {0} has no file stem — stub launcher needs a base name")]
    EntryHasNoStem(PathBuf),

    #[error("entry script {0} has no file extension — stub launcher needs a resource type")]
    EntryHasNoExtension(PathBuf),

    #[error("could not run `{raco}` (is Racket installed at the spec's runtime_path?): {source}")]
    RacoNotAvailable {
        raco: PathBuf,
        source: std::io::Error,
    },

    #[error("{step} failed (exit {status:?}):\n{stderr}")]
    RacoStep {
        step: &'static str,
        status: Option<i32>,
        stderr: String,
    },

    #[error("I/O error: {0}")]
    Io(#[from] std::io::Error),

    #[error("stub-launcher error: {0}")]
    Stub(#[from] StubError),

    #[error("could not merge Info.plist overrides: {0}")]
    InfoPlistMerge(#[from] plist::Error),

    #[error("Info.plist at {0} is not a top-level dictionary")]
    InfoPlistRootNotDict(PathBuf),
}

/// Bundle a sample app into `output_dir/<App Name>.app` from the §18 domain
/// tree, where app-implementations and the binding package live in separate
/// roots. Returns the path to the new bundle.
///
/// The entry script is `apps_root/<script_name>/<script_name>.rkt`; the
/// binding package (`runtime/`, `generated/`, `lib/`) lives under
/// `bindings_root`. The app's relative `(require "../../{generated,runtime}/…")`
/// lines are honoured via a virtual colocated root ([`SourceRoots::split`]),
/// and the bundle's `Resources/racket-app/` mirrors that colocated shape
/// (`apps/<name>/`, `runtime/`, `generated/`, `lib/` as siblings) so the same
/// requires keep resolving inside the bundle.
///
/// For a genuinely colocated project whose entry isn't at
/// `apps/<name>/<name>.rkt` (e.g. a root-level `main.rkt` with a `bindings/`
/// symlink), use [`bundle_app_with_entry`] directly.
pub fn bundle_app(
    spec: &AppSpec,
    apps_root: &Path,
    bindings_root: &Path,
    output_dir: &Path,
) -> Result<PathBuf, BundleError> {
    let roots = SourceRoots::split(apps_root, bindings_root)?;
    let entry = roots
        .logical_root()
        .join("apps")
        .join(&spec.script_name)
        .join(format!("{}.rkt", spec.script_name));

    if !roots.to_physical(&entry).exists() {
        return Err(BundleError::EntryMissing { entry });
    }

    bundle_app_with_roots(spec, &entry, &roots, output_dir)
}

/// Bundle an arbitrary Racket entry script into a `.app` at
/// `output_dir/<App Name>.app`.
///
/// Resource layout: every `.rkt` file the entry script transitively
/// requires gets copied to `Resources/racket-app/<rel>` where `<rel>` is
/// the file's **logical** path relative to `source_root`. Symlinks inside
/// the source tree are preserved in the bundle layout but resolved at
/// read time, so a directory symlink (e.g. Modaliser-Racket's
/// `bindings/` → `APIAnyware/targets/racket/bindings/macos/`) lands
/// as a real copy under `bindings/` in the bundle rather than an
/// absolute symlink. The `lib/` directory at `source_root` (if any) is
/// copied to `Resources/racket-app/lib/`, with two distributability
/// passes applied:
///
/// - `compiled/` subdirectories are skipped. Racket's `.zo` linklets
///   bake host-specific absolute paths into their bytecode and corrupt
///   the bundle on another machine.
/// - Each `.dylib`'s `LC_ID_DYLIB` is rewritten via `install_name_tool`
///   to `@executable_path/../Resources/racket-app/lib/<name>`, so the
///   bundled dylib's self-reported identity resolves within the bundle
///   rather than through an external `LC_RPATH`. Racket's `ffi-lib`
///   loads by explicit path and is indifferent; the rewrite is for
///   any native consumer (direct-link tools, dyld introspection). A
///   missing `install_name_tool` is logged as a warning and does not
///   fail the bundle.
///
/// The Swift stub is generated and compiled by `stub-launcher`. Its
/// `script_resource_dir`, `script_resource_name`, and
/// `script_resource_type` are derived from `entry` relative to
/// `source_root`, so `Bundle.main.path(forResource:ofType:inDirectory:)`
/// finds the entry script inside the bundle at runtime.
pub fn bundle_app_with_entry(
    spec: &AppSpec,
    entry: &Path,
    source_root: &Path,
    output_dir: &Path,
) -> Result<PathBuf, BundleError> {
    let roots = SourceRoots::single(source_root)?;
    bundle_app_with_roots(spec, entry, &roots, output_dir)
}

/// Bundle an arbitrary Racket entry, resolving every source file through
/// `roots` (single colocated root, or the split apps-root / bindings-root of
/// the §18 domain tree). The bundle's `Resources/racket-app/` always mirrors
/// the logical colocated tree, so the resolution model is invisible to the
/// produced bundle.
fn bundle_app_with_roots(
    spec: &AppSpec,
    entry: &Path,
    roots: &SourceRoots,
    output_dir: &Path,
) -> Result<PathBuf, BundleError> {
    let abs_root = roots.logical_root().to_path_buf();
    let abs_entry =
        absolutize(entry).map_err(|e| BundleError::ResolveEntry(entry.to_path_buf(), e))?;

    if !abs_entry.starts_with(&abs_root) {
        return Err(BundleError::EntryOutsideRoot {
            entry: abs_entry,
            root: abs_root,
        });
    }

    if !roots.to_physical(&abs_entry).exists() {
        return Err(BundleError::EntryMissing { entry: abs_entry });
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

    // Discover everything the entry transitively requires before we
    // touch the output directory — fail fast if a require is broken.
    let dependencies = collect_dependencies_in(&abs_entry, roots)?;

    let stub_config = StubConfig {
        app_name: spec.app_name.clone(),
        runtime_path: spec.runtime_path.clone(),
        runtime_args: vec![],
        script_resource_name,
        script_resource_type,
        script_resource_dir,
        bundle_identifier: spec.bundle_id.clone(),
        signing_identity: spec.signing_identity.clone(),
        libdirs_resource_subdir: None,
    };

    fs::create_dir_all(output_dir)?;
    let app_path = create_app_bundle(&stub_config, output_dir)?;

    if !spec.info_plist_overrides.is_empty() {
        let plist_path = app_path.join("Contents").join("Info.plist");
        merge_info_plist_overrides(&plist_path, &spec.info_plist_overrides)?;
    }

    let racket_app = app_path
        .join("Contents")
        .join("Resources")
        .join("racket-app");

    for logical in &dependencies {
        let rel = logical
            .strip_prefix(&abs_root)
            .expect("dependency was validated to be under source root");
        let dst = racket_app.join(rel);
        fs::create_dir_all(dst.parent().expect("dst has parent"))?;
        fs::copy(roots.to_physical(logical), &dst)?;
    }

    // Optional Swift helper dylib — referenced by runtime/swift-helpers.rkt
    // via `(ffi-lib (build-path this-dir 'up "lib" "libAPIAnywareRacket"))`.
    // Copy the lib/ directory if it exists in the source tree; the
    // runtime's exn:fail handler in swift-helpers.rkt makes the bundle
    // work in either mode.
    let lib_src = roots.to_physical(&abs_root.join("lib"));
    if lib_src.is_dir() {
        let lib_dst = racket_app.join("lib");
        copy_dir_recursive(&lib_src, &lib_dst)?;
        normalize_dylib_install_names(&lib_dst)?;
    }

    // Re-sign the fully populated bundle so the signature covers
    // Resources and any bundled dylib, not just the stub binary that
    // stub-launcher signed earlier. Without this pass, callers who set
    // a signing_identity end up with an inconsistent bundle: signed
    // binary, unsigned resources — which makes Gatekeeper reject the
    // bundle and can confuse notarization tooling.
    if let Some(identity) = &spec.signing_identity {
        codesign_path(&app_path, identity)?;
    }

    tracing::info!(
        app = %spec.app_name,
        path = %app_path.display(),
        files = dependencies.len(),
        "bundled racket app"
    );

    Ok(app_path)
}

/// `racket-app/` is always the top of the bundle's Racket tree. Append
/// the entry's parent dir relative to `abs_root` so the stub's
/// `Bundle.main.path(forResource:ofType:inDirectory:)` lookup finds the
/// script at its logical location.
///
/// - `$root/main.rkt` → `"racket-app"`
/// - `$root/apps/foo/foo.rkt` → `"racket-app/apps/foo"`
fn derive_script_resource_dir(abs_entry: &Path, abs_root: &Path) -> String {
    let parent_rel = abs_entry
        .parent()
        .and_then(|p| p.strip_prefix(abs_root).ok())
        .unwrap_or_else(|| Path::new(""));
    if parent_rel.as_os_str().is_empty() {
        "racket-app".to_string()
    } else {
        format!("racket-app/{}", parent_rel.to_string_lossy())
    }
}

pub(crate) fn copy_dir_recursive(src: &Path, dst: &Path) -> std::io::Result<()> {
    fs::create_dir_all(dst)?;
    for entry in fs::read_dir(src)? {
        let entry = entry?;
        let from = entry.path();
        let to = dst.join(entry.file_name());
        let ftype = entry.file_type()?;
        if ftype.is_dir() {
            // Skip Racket's bytecode cache — `.zo` linklets bake in
            // host-specific absolute paths and corrupt the bundle on
            // another machine (confirmed 2026-04-18 on a Tahoe VM).
            if entry.file_name() == "compiled" {
                continue;
            }
            copy_dir_recursive(&from, &to)?;
        } else {
            fs::copy(&from, &to)?;
        }
    }
    Ok(())
}

/// Read the `Info.plist` at `plist_path`, merge each entry from
/// `overrides` into its top-level dictionary (overriding any
/// existing key of the same name), and write the result back as XML.
///
/// Assumes the file already exists — callers only invoke this when
/// `create_app_bundle` has produced the base template. The result is no
/// longer byte-identical to the base template (the `plist` crate
/// canonicalizes formatting), so the caller is expected to skip this
/// step entirely when `overrides` is empty.
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

/// Rewrite each `.dylib`'s LC_ID_DYLIB to `@executable_path/<rel>` where
/// `<rel>` is the dylib's location relative to the stub binary at
/// `Contents/MacOS/<App Name>`. That is `../Resources/racket-app/lib/<name>`
/// given our bundle layout. Without this, the dylib still carries its
/// build-time `@rpath/...` identity, which relies on an externally-set
/// LC_RPATH and therefore breaks the "self-contained" invariant — the
/// bundle can no longer tell a native consumer where to find its own
/// dylib.
///
/// Racket's own `ffi-lib` uses an explicit filesystem path and is
/// indifferent to this identity. The rewrite is for introspection and
/// any future direct-link consumer of the dylib.
///
/// Non-fatal: if `install_name_tool` isn't on PATH, emit a warning and
/// leave the dylib as-is. Failing the bundle here would make
/// `bundle_app` unusable on stripped-down systems that otherwise have a
/// working `swiftc`.
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
            let new_id = format!("@executable_path/../Resources/racket-app/lib/{file_name}");
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

/// `"hello-window"` → `"Hello Window"`. Splits on `-`, capitalizes each
/// word's first ASCII char, joins with a single space.
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
    fn title_case_three_words() {
        assert_eq!(
            title_case_kebab("ui-controls-gallery"),
            "Ui Controls Gallery"
        );
    }

    #[test]
    fn from_script_name_derives_display_and_bundle_id() {
        let spec = AppSpec::from_script_name("hello-window");
        assert_eq!(spec.app_name, "Hello Window");
        assert_eq!(spec.bundle_id, "com.linkuistics.HelloWindow");
        assert_eq!(spec.script_name, "hello-window");
        assert_eq!(spec.runtime_path, DEFAULT_RACKET_PATH);
    }

    #[test]
    fn from_script_name_handles_single_word() {
        let spec = AppSpec::from_script_name("modaliser");
        assert_eq!(spec.app_name, "Modaliser");
        assert_eq!(spec.bundle_id, "com.linkuistics.Modaliser");
    }

    #[test]
    fn script_resource_dir_root_level_entry_is_racket_app() {
        let dir = derive_script_resource_dir(Path::new("/root/main.rkt"), Path::new("/root"));
        assert_eq!(dir, "racket-app");
    }

    #[test]
    fn script_resource_dir_apps_sample_layout_appends_path() {
        let dir = derive_script_resource_dir(
            Path::new("/root/apps/hello-window/hello-window.rkt"),
            Path::new("/root"),
        );
        assert_eq!(dir, "racket-app/apps/hello-window");
    }

    #[test]
    fn script_resource_dir_nested_subdir() {
        let dir =
            derive_script_resource_dir(Path::new("/root/src/cli/tool.rkt"), Path::new("/root"));
        assert_eq!(dir, "racket-app/src/cli");
    }

    #[test]
    fn resolves_convention_identity_when_present() {
        assert_eq!(
            resolve_signing_identity(|_name| true),
            Some("APIAnyware Local Signing".to_string())
        );
    }

    #[test]
    fn falls_back_to_none_when_identity_absent() {
        assert_eq!(resolve_signing_identity(|_name| false), None);
    }
}
