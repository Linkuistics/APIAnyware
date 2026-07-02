//! Assemble a **self-contained** racket `.app` — no Racket runtime, no
//! user-scope `ffi2-lib` package, no source compilation on the target machine
//! (`racket-self-contained-bundle-k76`; the sbcl ADR-0041 stub shape).
//!
//! Mechanism: `raco exe` embeds the app's full module graph (the generated
//! bindings, the runtime, and every collection module they pull in —
//! including the `ffi2` collection from the build host's `ffi2-lib` package)
//! into one executable; `raco distribute` then makes that executable
//! machine-portable, carrying `libAPIAnywareRacket.dylib` along via the
//! runtime's `define-runtime-path` references (swift-helpers.rkt /
//! ffi2-dispatch.rkt) and rewriting them to the distribution-relative copy.
//! The distribution is relocatable, so the Swift stub just `execv`s it.
//!
//! ```text
//! <App>.app/
//!   Contents/
//!     MacOS/<script>            <- Swift stub (CFBundleExecutable): locates the
//!                                  distributed exe relative to itself, execv's it
//!     Resources/racket-dist/
//!       bin/<script>            <- `raco exe` output (embeds all modules, AOT-compiled;
//!                                  cold launch needs no source compilation)
//!       lib/...                 <- Racket CS runtime files +
//!                                  plt/<script>/exts/.../libAPIAnywareRacket.dylib
//!     Info.plist                <- CFBundleName from the spec, com.linkuistics.* id
//! ```
//!
//! Contrast with [`bundle_app`](crate::bundle_app) (the shared-runtime mode,
//! kept for colocated projects like Modaliser): that ships uncompiled `.rkt`
//! source under `Resources/racket-app/` and execs a host
//! `/opt/homebrew/bin/racket` — fine on a dev machine, but a vanilla VM has
//! no Racket (975 MB provisioned) and pays ~14 s of first-run compilation
//! (over the AppSpec run-harness's 10 s `wait-ready` window).

use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

use apianyware_stub_launcher::{codesign_path, compile_stub};
use plist::Value as PlistValue;

use crate::bundle::{copy_dir_recursive, AppSpec, BundleError};
use crate::deps::{absolutize, collect_dependencies_in, SourceRoots};

/// The bundle subdirectory (under `Contents/Resources/`) holding the
/// `raco distribute` output tree.
pub const DIST_RESOURCE_SUBDIR: &str = "racket-dist";

/// Bundle a sample app into a self-contained `output_dir/<App Name>.app`
/// from the §18 domain tree (apps and bindings in separate roots — the same
/// resolution model as [`bundle_app`](crate::bundle_app)). Returns the path
/// to the new bundle.
///
/// The staged colocated tree, `raco exe`, and `raco distribute` all run
/// under `output_dir/raco-staging/` (removed on success). `raco` is located
/// next to the spec's `runtime_path` — the build host still needs a Racket
/// install (and the `ffi2-lib` package); the *produced bundle* does not.
pub fn bundle_app_self_contained(
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

    // Discover everything the entry transitively requires before we touch
    // the output directory — fail fast if a require is broken.
    let abs_root = roots.logical_root().to_path_buf();
    let abs_entry =
        absolutize(&entry).map_err(|e| BundleError::ResolveEntry(entry.to_path_buf(), e))?;
    let dependencies = collect_dependencies_in(&abs_entry, &roots)?;

    fs::create_dir_all(output_dir)?;
    let staging = output_dir.join("raco-staging");
    if staging.exists() {
        fs::remove_dir_all(&staging)?;
    }

    // 1. Materialize the colocated logical tree — the shape the sample apps'
    //    relative `(require "../../{generated,runtime}/…")` lines are written
    //    against — so raco can compile it from real files.
    for logical in &dependencies {
        let rel = logical
            .strip_prefix(&abs_root)
            .expect("dependency was validated to be under source root");
        let dst = staging.join(rel);
        fs::create_dir_all(dst.parent().expect("dst has parent"))?;
        fs::copy(roots.to_physical(logical), &dst)?;
    }

    // The native dylib: the runtime's `define-runtime-path` references must
    // point at a real file at compile time for `raco distribute` to carry it.
    let lib_src = roots.to_physical(&abs_root.join("lib"));
    if lib_src.is_dir() {
        copy_dir_recursive(&lib_src, &staging.join("lib"))?;
    }

    // 2. `raco exe`: embed the module graph into one executable.
    let raco = raco_path(&spec.runtime_path);
    let exe = staging.join(&spec.script_name);
    let staged_entry = staging
        .join("apps")
        .join(&spec.script_name)
        .join(format!("{}.rkt", spec.script_name));
    run_raco(&raco, "raco exe", |c| {
        c.arg("exe").arg("-o").arg(&exe).arg(&staged_entry)
    })?;

    // 3. `raco distribute`: make it machine-portable (Racket CS runtime files
    //    + the runtime-path-referenced dylib, all exe-relative).
    let dist = staging.join("dist");
    run_raco(&raco, "raco distribute", |c| {
        c.arg("distribute").arg(&dist).arg(&exe)
    })?;

    // 4. Lay out the bundle; the dist tree moves in whole (its bin/ ↔ lib/
    //    sibling shape is what makes it relocatable — never split it).
    let app_path = output_dir.join(format!("{}.app", spec.app_name));
    if app_path.exists() {
        fs::remove_dir_all(&app_path)?;
    }
    let contents = app_path.join("Contents");
    let macos = contents.join("MacOS");
    let resources = contents.join("Resources");
    fs::create_dir_all(&macos)?;
    fs::create_dir_all(&resources)?;
    fs::rename(&dist, resources.join(DIST_RESOURCE_SUBDIR))?;

    // 5. The Swift stub becomes CFBundleExecutable (unique CDHash per app for
    //    TCC, same as every other target's bundler).
    let stub = macos.join(&spec.script_name);
    compile_stub(
        &generate_standalone_stub_source(&spec.app_name, &spec.script_name),
        &stub,
    )?;

    // 6. Info.plist (spec overrides folded in).
    write_info_plist(&contents.join("Info.plist"), spec)?;

    fs::remove_dir_all(&staging)?;

    // 7. Sign the whole bundle last — the stub (main exe) plus the sealed
    //    Resources tree. Ad-hoc when no persistent identity is available,
    //    matching the sbcl bundler (ADR-0041 k75 shape).
    let identity = spec.signing_identity.as_deref().unwrap_or("-");
    codesign_path(&app_path, identity)?;

    tracing::info!(
        app = %spec.app_name,
        path = %app_path.display(),
        files = dependencies.len(),
        "bundled self-contained racket app"
    );

    Ok(app_path)
}

/// `raco` lives next to the racket binary the spec names
/// (`/opt/homebrew/bin/racket` → `/opt/homebrew/bin/raco`); fall back to
/// `$PATH` when the spec's runtime path has no parent.
fn raco_path(runtime_path: &str) -> PathBuf {
    match Path::new(runtime_path).parent() {
        Some(dir) if !dir.as_os_str().is_empty() => dir.join("raco"),
        _ => PathBuf::from("raco"),
    }
}

/// Run one raco step, surfacing its stderr on failure (e.g. an unbound
/// identifier in a staged module, or a missing `ffi2-lib` package on the
/// build host).
fn run_raco(
    raco: &Path,
    step: &'static str,
    configure: impl FnOnce(&mut Command) -> &mut Command,
) -> Result<(), BundleError> {
    let mut cmd = Command::new(raco);
    configure(&mut cmd);
    let output = cmd
        .output()
        .map_err(|source| BundleError::RacoNotAvailable {
            raco: raco.to_path_buf(),
            source,
        })?;
    if !output.status.success() {
        return Err(BundleError::RacoStep {
            step,
            status: output.status.code(),
            stderr: String::from_utf8_lossy(&output.stderr).into_owned(),
        });
    }
    Ok(())
}

/// Generate the Swift source for the self-contained stub launcher.
///
/// The stub locates the distributed executable at
/// `Contents/Resources/racket-dist/bin/<script>` relative to itself (so the
/// bundle is relocatable) and `execv`s it. No `DYLD_*` environment is needed:
/// the `raco distribute` tree resolves everything exe-relative.
pub fn generate_standalone_stub_source(app_name: &str, script_name: &str) -> String {
    let app = escape_swift(app_name);
    let script = escape_swift(script_name);
    format!(
        r#"import Foundation

// Locate this stub and the raco-distributed executable — all relative to the
// running executable so the bundle is relocatable.
let exePath = Bundle.main.executablePath ?? CommandLine.arguments[0]
let macosDir = (exePath as NSString).deletingLastPathComponent       // Contents/MacOS
let contents = (macosDir as NSString).deletingLastPathComponent      // Contents
let runtime = contents + "/Resources/{DIST_RESOURCE_SUBDIR}/bin/{script}"

guard FileManager.default.isExecutableFile(atPath: runtime) else {{
    fputs("{app}: distributed racket executable not found at \(runtime)\n", stderr)
    exit(1)
}}

let cArgv: [UnsafeMutablePointer<CChar>?] = [strdup(runtime), nil]
execv(runtime, cArgv)

// execv only returns on failure.
fputs("{app}: exec failed: \(String(cString: strerror(errno)))\n", stderr)
exit(1)
"#
    )
}

/// Write the bundle's `Info.plist`. `CFBundleExecutable` names the Swift stub
/// (the distributed executable is a resource the stub execs, not the bundle
/// executable) — the sbcl bundler's shape, script-named.
fn write_info_plist(path: &Path, spec: &AppSpec) -> Result<(), BundleError> {
    let mut dict = plist::Dictionary::new();
    let mut set = |k: &str, v: &str| {
        dict.insert(k.to_string(), PlistValue::String(v.to_string()));
    };
    set("CFBundleName", &spec.app_name);
    set("CFBundleDisplayName", &spec.app_name);
    set("CFBundleIdentifier", &spec.bundle_id);
    set("CFBundleExecutable", &spec.script_name);
    set("CFBundlePackageType", "APPL");
    set("CFBundleVersion", "1.0");
    set("CFBundleShortVersionString", "1.0");
    set("CFBundleInfoDictionaryVersion", "6.0");
    set("NSPrincipalClass", "NSApplication");
    set("LSMinimumSystemVersion", "14.0");
    dict.insert(
        "NSHighResolutionCapable".to_string(),
        PlistValue::Boolean(true),
    );
    dict.insert(
        "NSSupportsAutomaticGraphicsSwitching".to_string(),
        PlistValue::Boolean(true),
    );
    for (k, v) in &spec.info_plist_overrides {
        dict.insert(k.clone(), v.clone());
    }
    plist::to_file_xml(path, &PlistValue::Dictionary(dict))?;
    Ok(())
}

fn escape_swift(s: &str) -> String {
    s.replace('\\', "\\\\").replace('"', "\\\"")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn stub_execs_the_distributed_exe() {
        let src = generate_standalone_stub_source("Hello Window", "hello-window");
        assert!(
            src.contains(r#"let runtime = contents + "/Resources/racket-dist/bin/hello-window""#)
        );
        assert!(src.contains("execv(runtime, cArgv)"));
    }

    #[test]
    fn stub_needs_no_dyld_environment() {
        let src = generate_standalone_stub_source("Hello Window", "hello-window");
        assert!(
            !src.contains("DYLD"),
            "the raco distribute tree resolves exe-relative; no DYLD override"
        );
    }

    #[test]
    fn stub_reports_missing_exe_and_exec_failure() {
        let src = generate_standalone_stub_source("Hello Window", "hello-window");
        assert!(src.contains("Hello Window: distributed racket executable not found"));
        assert!(src.contains("Hello Window: exec failed"));
    }

    #[test]
    fn stub_escapes_quotes_in_names() {
        let src = generate_standalone_stub_source(r#"Weird"Name"#, "weird");
        assert!(src.contains(r#"Weird\"Name: exec failed"#));
    }

    #[test]
    fn raco_is_located_next_to_the_runtime() {
        assert_eq!(
            raco_path("/opt/homebrew/bin/racket"),
            PathBuf::from("/opt/homebrew/bin/raco")
        );
    }

    #[test]
    fn raco_falls_back_to_path_lookup() {
        assert_eq!(raco_path("racket"), PathBuf::from("raco"));
    }

    #[test]
    fn info_plist_executable_is_the_stub_script_name() {
        let dir = tempfile::TempDir::new().unwrap();
        let mut spec = AppSpec::from_script_name("hello-window");
        spec.signing_identity = None;
        let path = dir.path().join("Info.plist");
        write_info_plist(&path, &spec).unwrap();

        let value = PlistValue::from_file(&path).unwrap();
        let d = value.as_dictionary().unwrap();
        assert_eq!(
            d.get("CFBundleName").unwrap().as_string(),
            Some("Hello Window")
        );
        assert_eq!(
            d.get("CFBundleExecutable").unwrap().as_string(),
            Some("hello-window")
        );
        assert_eq!(
            d.get("CFBundleIdentifier").unwrap().as_string(),
            Some("com.linkuistics.HelloWindow")
        );
    }

    #[test]
    fn info_plist_overrides_are_folded_in() {
        let dir = tempfile::TempDir::new().unwrap();
        let mut spec = AppSpec::from_script_name("hello-window");
        spec.signing_identity = None;
        spec.info_plist_overrides
            .insert("LSUIElement".to_string(), PlistValue::Boolean(true));
        let path = dir.path().join("Info.plist");
        write_info_plist(&path, &spec).unwrap();

        let value = PlistValue::from_file(&path).unwrap();
        let d = value.as_dictionary().unwrap();
        assert_eq!(d.get("LSUIElement").unwrap().as_boolean(), Some(true));
    }
}
