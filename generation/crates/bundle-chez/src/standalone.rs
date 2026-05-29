//! Build a self-contained, **open-world** chez `.app` whose
//! `Contents/MacOS/<bin>` embeds the Chez kernel and a whole-program boot
//! image — no system Chez at runtime (ADR-0009; design spec
//! `docs/specs/2026-05-29-chez-standalone-distribution-design.md`).
//!
//! This is the productionised form of the 060/010 spike
//! (`docs/research/2026-05-29-chez-standalone-spike.md`). The pipeline,
//! per app (spec §2):
//!
//! 1. **Generate a top-level-program wrapper** around the app entry. The
//!    `--script` entry is not a valid R6RS top-level program — names
//!    exported by two imported libraries are a hard duplicate-import
//!    error under `compile-program`/`compile-whole-program` (spike F2).
//!    The wrapper has the framework facades **yield** (`(except <facade>
//!    <names>…)`) to `runtime/objc` + `(chezscheme)`, and installs a
//!    `(scheme-start …)` thunk instead of calling `(main)` at top level.
//! 2. **Whole-program compile** the wrapper + its import closure to one
//!    tree-shaken object (`compile-program` + `compile-whole-program`).
//! 3. **`make-boot-file`** with an empty base list, concatenating
//!    `petite.boot` + `scheme.boot` (open-world: compiler present) + the
//!    whole-program object into one self-contained boot.
//! 4. **`cc`-link** the embedding host (`embed_main.c`) with
//!    `libkernel.a` (+ `liblz4.a`/`libz.a`; **not** `main.o`, F9).
//! 5. **Assemble + sign** the `.app`: boot + dylib under
//!    `Contents/Resources/` (F4); sign nested dylib then bundle (F5).
//!
//! # Leaf 010 scope (node 060/030)
//!
//! This leaf ports the spike's **mechanics**. The wrapper's collision set
//! is **hand-coded for `hello-window`** here (the spike's 4-`except` set);
//! leaf 020 replaces it with an automatic `environment-symbols` probe that
//! computes the set for any app. The dylib-search root is seeded by the
//! `embed_main.c` `chdir` expedient; leaf 030 replaces that with a Scheme
//! prelude. Source-exec (`bundle_app`) is untouched — its retirement is
//! node-leaf 040.

use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

use apianyware_macos_stub_launcher::codesign_path;
use plist::Value as PlistValue;

use crate::bundle::{AppSpec, BundleError};
use crate::deps::{absolutize, collect_dependencies, DEFAULT_CHEZ_BIN};

/// The embedding host, compiled and linked into every standalone binary.
const EMBED_MAIN_C: &str = include_str!("resources/embed_main.c");

/// Build a self-contained open-world `.app` for the chez sample app at
/// `source_root/apps/<script_name>/<script_name>.sls` into
/// `output_dir/<App Name>.app`. Returns the path to the new bundle.
///
/// Unlike [`crate::bundle_app`] (source-exec, retained until node-leaf
/// 040), the produced `.app` has **no runtime dependency on a system
/// Chez**: the kernel and a whole-program boot are baked into the binary.
/// The host Chez install is a **build-time** dependency only (the kernel
/// artifacts are discovered from it).
pub fn bundle_app_standalone(
    spec: &AppSpec,
    source_root: &Path,
    output_dir: &Path,
) -> Result<PathBuf, BundleError> {
    let abs_root = absolutize(source_root)
        .map_err(|e| BundleError::ResolveSourceRoot(source_root.to_path_buf(), e))?;
    let entry = abs_root
        .join("apps")
        .join(&spec.script_name)
        .join(format!("{}.sls", spec.script_name));
    if !entry.exists() {
        return Err(BundleError::EntryMissing { entry });
    }

    // Mandatory-dylib precheck (ADR-0005): fail before doing any expensive
    // compile work if the runtime dylib is missing.
    let dylib_src = abs_root.join("lib").join("libAPIAnywareChez.dylib");
    if !dylib_src.exists() {
        return Err(BundleError::DylibMissing {
            source_root: abs_root,
        });
    }

    let kernel = discover_kernel_dir()?;

    // Scratch build dir. Dropped at the end of the function (the bundle is
    // copied out of it); kept on disk only for the duration of the build.
    let build = tempfile::tempdir()?;
    let build = build.path();

    // 1. Stage the import closure into a private tree so the whole-program
    //    compile can write its .so/.wpo artifacts without dirtying the
    //    source. The deps walker returns the exact transitive .sls set.
    let tree = build.join("tree");
    let deps = collect_dependencies(&entry, &abs_root)?;
    for src in &deps {
        let rel = src
            .strip_prefix(&abs_root)
            .expect("dependency validated under source root");
        let dst = tree.join(rel);
        fs::create_dir_all(dst.parent().expect("dep dst has parent"))?;
        fs::copy(src, &dst)?;
    }
    // The dylib lives under the tree too: `compile-imported-libraries`
    // does not load it (load-shared-object is a runtime act), but staging
    // it mirrors the spike's known-good layout.
    let tree_lib = tree.join("lib");
    fs::create_dir_all(&tree_lib)?;
    fs::copy(&dylib_src, tree_lib.join("libAPIAnywareChez.dylib"))?;

    // 1b. Generate the top-level-program wrapper (hand-coded collisions —
    //     leaf 010). The wrapper is the compile entry; it imports the
    //     facades (now yielding) and ends in (scheme-start …).
    let app_source = fs::read_to_string(&entry)?;
    let wrapper_src = generate_wrapper_hello_window(&app_source);
    let wrapper = build.join("app-entry.ss");
    fs::write(&wrapper, &wrapper_src)?;

    // 2. Whole-program compile → one tree-shaken object.
    let whole_so = build.join("whole.so");
    let wpo = build.join("app-entry.wpo");
    run_chez_script(
        build,
        &format!(
            "(generate-wpo-files #t)\n\
             (compile-imported-libraries #t)\n\
             (library-directories {tree})\n\
             (compile-program {wrapper})\n\
             (compile-whole-program {wpo} {whole} #f)\n",
            tree = scheme_string(&tree.to_string_lossy()),
            wrapper = scheme_string(&wrapper.to_string_lossy()),
            wpo = scheme_string(&wpo.to_string_lossy()),
            whole = scheme_string(&whole_so.to_string_lossy()),
        ),
        |stderr| BundleError::WholeProgramCompileFailed { stderr },
    )?;

    // 3. make-boot-file: empty base + petite + scheme (open-world) + app.
    let boot_name = format!("{}.boot", spec.script_name);
    let boot = build.join(&boot_name);
    run_chez_script(
        build,
        &format!(
            "(make-boot-file {boot} '() {petite} {scheme} {whole})\n",
            boot = scheme_string(&boot.to_string_lossy()),
            petite = scheme_string(&kernel.join("petite.boot").to_string_lossy()),
            scheme = scheme_string(&kernel.join("scheme.boot").to_string_lossy()),
            whole = scheme_string(&whole_so.to_string_lossy()),
        ),
        |stderr| BundleError::MakeBootFailed { stderr },
    )?;

    // 4. cc-link the embedding host. BOOTNAME is the boot file's basename;
    //    embed_main.c finds it next to the exe or under ../Resources.
    let embed_c = build.join("embed_main.c");
    fs::write(&embed_c, EMBED_MAIN_C)?;
    let bin = build.join(&spec.script_name);
    let cc_out = Command::new("cc")
        .arg("-O2")
        .arg("-I")
        .arg(&kernel)
        .arg(format!("-DBOOTNAME=\"{boot_name}\""))
        .arg("-o")
        .arg(&bin)
        .arg(&embed_c)
        .arg(kernel.join("libkernel.a"))
        .arg(kernel.join("liblz4.a"))
        .arg(kernel.join("libz.a"))
        .args(["-liconv", "-lncurses", "-lz"])
        .args(["-framework", "Foundation", "-framework", "AppKit"])
        .output()
        .map_err(BundleError::CcNotAvailable)?;
    if !cc_out.status.success() {
        return Err(BundleError::CcLinkFailed {
            stderr: String::from_utf8_lossy(&cc_out.stderr).into_owned(),
        });
    }

    // 5. Assemble the .app and sign.
    fs::create_dir_all(output_dir)?;
    let app_path = output_dir.join(format!("{}.app", spec.app_name));
    if app_path.exists() {
        fs::remove_dir_all(&app_path)?;
    }
    let contents = app_path.join("Contents");
    let macos = contents.join("MacOS");
    let resources = contents.join("Resources");
    let res_lib = resources.join("lib");
    fs::create_dir_all(&macos)?;
    fs::create_dir_all(&res_lib)?;

    fs::copy(&bin, macos.join(&spec.script_name))?;
    // The .boot is a DATA resource: codesign --strict rejects non-Mach-O
    // files in Contents/MacOS/ (spike F4). embed_main.c finds it via
    // ../Resources.
    fs::copy(&boot, resources.join(&boot_name))?;
    fs::copy(&dylib_src, res_lib.join("libAPIAnywareChez.dylib"))?;

    write_info_plist(&contents.join("Info.plist"), spec)?;

    // Sign nested Mach-O (dylib) first, then the whole bundle (F5). Use
    // the persistent identity for a stable, unique CDHash; fall back to
    // ad-hoc so `codesign --verify --strict` still passes when the local
    // identity is absent (CI). install_name_tool is intentionally NOT run:
    // the dylib is dlopen'd by path (resolve-dylib-path), so LC_ID_DYLIB is
    // irrelevant, and the spike proved --strict passes without it.
    let identity = spec.signing_identity.as_deref().unwrap_or("-");
    codesign_path(&res_lib.join("libAPIAnywareChez.dylib"), identity)?;
    codesign_path(&app_path, identity)?;

    tracing::info!(
        app = %spec.app_name,
        path = %app_path.display(),
        deps = deps.len(),
        "bundled standalone chez app"
    );
    Ok(app_path)
}

/// Generate the strict top-level-program wrapper for `hello-window` from
/// its `--script` source (leaf 010 — **hand-coded** collision set).
///
/// Two transforms (spec §3):
/// 1. The framework facades yield to the curated runtime + `(chezscheme)`
///    for the 4 names that collide in hello-window's import closure
///    (`nserror-code`, `nserror-domain`, `reverse`,
///    `nsevent-location-in-window` — spike F2).
/// 2. The trailing top-level `(main)` call becomes a `(scheme-start …)`
///    thunk so the embedding host drives the entry (the run loop must not
///    fire during boot load).
///
/// Leaf 020 replaces this hand-coded function with a generator that
/// computes the collision set for any app via `environment-symbols`.
fn generate_wrapper_hello_window(app_source: &str) -> String {
    // 1. Facade yields (hand-coded for hello-window).
    let body = app_source
        .replace(
            "(apianyware appkit)",
            "(except (apianyware appkit) nsevent-location-in-window)",
        )
        .replace(
            "(apianyware foundation)",
            "(except (apianyware foundation) nserror-code nserror-domain reverse)",
        );

    // 2. Drop the trailing top-level `(main)` (the only `(main)` token at
    //    the tail — `(define-entry-point (main) …)` earlier is untouched)
    //    and install a scheme-start thunk in its place.
    let trimmed = body.trim_end();
    let head = trimmed
        .strip_suffix("(main)")
        .expect("app entry must end in a top-level (main) call");
    format!(
        "{}\n(scheme-start (lambda args (main) 0))\n",
        head.trim_end()
    )
}

/// Locate the Chez kernel artifact directory on the build host. Honours
/// `AW_CHEZ_KERNEL_DIR`; otherwise globs the Homebrew Cellar for a
/// `csv<ver>/<arch>osx` dir containing `libkernel.a`. Build-time only —
/// the shipped `.app` has no Chez dependency (documented for node-leaf
/// 060, the toolchain docs).
fn discover_kernel_dir() -> Result<PathBuf, BundleError> {
    if let Ok(dir) = std::env::var("AW_CHEZ_KERNEL_DIR") {
        let p = PathBuf::from(dir);
        if p.join("libkernel.a").exists() {
            return Ok(p);
        }
        return Err(BundleError::KernelArtifactsNotFound {
            searched: format!("AW_CHEZ_KERNEL_DIR={}", p.display()),
        });
    }

    let cellar = PathBuf::from("/opt/homebrew/Cellar/chezscheme");
    let mut searched = vec![cellar.display().to_string()];
    if let Ok(versions) = fs::read_dir(&cellar) {
        for v in versions.flatten() {
            let lib = v.path().join("lib");
            if let Ok(csvs) = fs::read_dir(&lib) {
                for csv in csvs.flatten() {
                    // csv<ver>/<arch>osx — pick any arch dir with a kernel.
                    if let Ok(arches) = fs::read_dir(csv.path()) {
                        for arch in arches.flatten() {
                            let cand = arch.path();
                            if cand.join("libkernel.a").exists() && cand.join("scheme.h").exists() {
                                return Ok(cand);
                            }
                            searched.push(cand.display().to_string());
                        }
                    }
                }
            }
        }
    }
    Err(BundleError::KernelArtifactsNotFound {
        searched: searched.join(", "),
    })
}

/// Write a script to the build dir and run it via `chez --script`,
/// mapping a non-zero exit to `mk_err(stderr)`.
fn run_chez_script(
    build: &Path,
    body: &str,
    mk_err: impl Fn(String) -> BundleError,
) -> Result<(), BundleError> {
    let script = build.join("_build-step.ss");
    fs::write(&script, body)?;
    let out = Command::new(DEFAULT_CHEZ_BIN)
        .arg("--script")
        .arg(&script)
        .output()
        .map_err(|e| BundleError::ChezNotAvailable {
            chez_bin: DEFAULT_CHEZ_BIN.to_string(),
            source: e,
        })?;
    if !out.status.success() {
        let mut stderr = String::from_utf8_lossy(&out.stderr).into_owned();
        if stderr.trim().is_empty() {
            stderr = String::from_utf8_lossy(&out.stdout).into_owned();
        }
        return Err(mk_err(stderr));
    }
    Ok(())
}

/// Render a Rust string as a Chez string literal (escape `\` and `"`).
fn scheme_string(s: &str) -> String {
    let mut out = String::with_capacity(s.len() + 2);
    out.push('"');
    for c in s.chars() {
        if c == '\\' || c == '"' {
            out.push('\\');
        }
        out.push(c);
    }
    out.push('"');
    out
}

/// Write the standalone bundle's `Info.plist`. The native binary *is* the
/// executable (no Swift stub), so `CFBundleExecutable` names the cc output.
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
    set("LSMinimumSystemVersion", "13.0");
    dict.insert(
        "NSHighResolutionCapable".to_string(),
        PlistValue::Boolean(true),
    );
    // Caller overrides win (matches bundle_app's merge semantics).
    for (k, v) in &spec.info_plist_overrides {
        dict.insert(k.clone(), v.clone());
    }
    plist::to_file_xml(path, &PlistValue::Dictionary(dict))?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    const HELLO_SOURCE: &str = "\
(import (chezscheme)
        (apianyware appkit)
        (apianyware foundation)
        (apianyware runtime cocoa)
        (apianyware runtime objc)
        (apianyware runtime types))

(define-entry-point (main)
  (display \"hi\"))

(main)
";

    #[test]
    fn wrapper_makes_facades_yield() {
        let w = generate_wrapper_hello_window(HELLO_SOURCE);
        assert!(w.contains("(except (apianyware appkit) nsevent-location-in-window)"));
        assert!(w.contains("(except (apianyware foundation) nserror-code nserror-domain reverse)"));
        // The bare facade imports must be gone.
        assert!(!w.contains("        (apianyware appkit)\n"));
        assert!(!w.contains("        (apianyware foundation)\n"));
    }

    #[test]
    fn wrapper_installs_scheme_start_and_drops_trailing_main() {
        let w = generate_wrapper_hello_window(HELLO_SOURCE);
        assert!(w
            .trim_end()
            .ends_with("(scheme-start (lambda args (main) 0))"));
        // The entry-point definition's (main) head is preserved; only the
        // trailing top-level call is removed.
        assert!(w.contains("(define-entry-point (main)"));
        // No leftover top-level (main) call.
        assert!(!w.trim_end().ends_with("(main)\n(main)"));
    }

    #[test]
    fn scheme_string_escapes() {
        assert_eq!(scheme_string("a/b c"), "\"a/b c\"");
        assert_eq!(scheme_string("a\"b"), "\"a\\\"b\"");
        assert_eq!(scheme_string("a\\b"), "\"a\\\\b\"");
    }
}
