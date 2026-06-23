//! Build a self-contained, **open-world** chez `.app` whose
//! `Contents/MacOS/<bin>` embeds the Chez kernel and a whole-program boot
//! image — no system Chez at runtime (ADR-0009; design spec
//! `generation/targets/chez/docs/design/2026-05-29-chez-standalone-distribution-design.md`).
//!
//! This is the productionised form of the 060/010 spike
//! (`generation/targets/chez/docs/research/2026-05-29-chez-standalone-spike.md`). The pipeline,
//! per app (spec §2):
//!
//! 1. **Generate a top-level-program wrapper** around the app entry. The
//!    `--script` entry is not a valid R6RS top-level program — names
//!    exported by two imported libraries are a hard duplicate-import
//!    error under `compile-program`/`compile-whole-program` (spike F2).
//!    The collision set is **computed per app** by a chez probe
//!    (`scripts/standalone-collisions.ss`, via [`compute_collisions`]):
//!    it classifies each imported library as a framework *facade* or a
//!    *curated* library and, for every name a facade shares with the
//!    curated union, has the facade **yield** (`(except <facade>
//!    <names>…)`). The wrapper then installs a `(scheme-start …)` thunk
//!    instead of calling `(main)` at top level.
//! 2. **Whole-program compile** the wrapper + its import closure to one
//!    tree-shaken object (`compile-program` + `compile-whole-program`).
//! 3. **`make-boot-file`** with an empty base list, concatenating
//!    `petite.boot` + `scheme.boot` (open-world: compiler present) + a
//!    `prelude.so` (the dylib-search seed, §4) + the whole-program object
//!    into one self-contained boot.
//! 4. **`cc`-link** the embedding host (`embed_main.c`) with
//!    `libkernel.a` (+ `liblz4.a`/`libz.a`; **not** `main.o`, F9).
//! 5. **Assemble + sign** the `.app`: boot + dylib under
//!    `Contents/Resources/` (F4); sign nested dylib then bundle (F5).
//!
//! # The dylib-search prelude (spec §4)
//!
//! The spec §4 **prelude object** ([`PRELUDE_SS`]) is a tiny Scheme object
//! linked into the boot ahead of the app that sets `(library-directories)`
//! from an exe-relative `../Resources` path, so `ffi.sls`'s
//! `resolve-dylib-path` finds `lib/libAPIAnywareChez.dylib` during boot load
//! without touching the process cwd. The host hands the resource dir to the
//! prelude via the `AW_RESOURCE_DIR` env var (set before `Sbuild_heap`); the
//! prelude reads it with `getenv`. The prelude also suppresses the kernel
//! startup banner via `(suppress-greeting #t)` (F6).

use std::collections::BTreeMap;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

use apianyware_stub_launcher::codesign_path;
use plist::Value as PlistValue;

use crate::bundle::{AppSpec, BundleError};
use crate::deps::{absolutize, collect_dependencies, DEFAULT_CHEZ_BIN};

/// The embedding host, compiled and linked into every standalone binary.
const EMBED_MAIN_C: &str = include_str!("resources/embed_main.c");

/// The boot prelude (spec §4): sets `(library-directories)` from
/// `AW_RESOURCE_DIR` and suppresses the startup banner. Compiled to an
/// object file and concatenated into the boot ahead of the app object so it
/// runs before the apianyware libraries instantiate.
const PRELUDE_SS: &str = include_str!("resources/prelude.ss");

/// The per-app collision probe (computes each facade's `except` list).
const STANDALONE_COLLISIONS_SS: &str = include_str!("../scripts/standalone-collisions.ss");

/// Build a self-contained open-world `.app` for the chez sample app at
/// `source_root/apps/<script_name>/<script_name>.sls` into
/// `output_dir/<App Name>.app`. Returns the path to the new bundle.
///
/// The produced `.app` has **no runtime dependency on a system Chez**: the
/// kernel and a whole-program boot are baked into the binary. The host Chez
/// install is a **build-time** dependency only (the kernel artifacts are
/// discovered from it).
pub fn bundle_app(
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

    // 1b. Compute the duplicate-import collision set for this app from its
    //     import closure (the chez environment-symbols probe — leaf 020),
    //     then generate the top-level-program wrapper. The wrapper is the
    //     compile entry; it imports the facades (now yielding) and ends in
    //     (scheme-start …). The probe runs against the staged tree so the
    //     facade libraries resolve.
    let tree_entry = tree.join(
        entry
            .strip_prefix(&abs_root)
            .expect("entry validated under source root"),
    );
    let collisions = compute_collisions(&tree_entry, &tree)?;
    let app_source = fs::read_to_string(&entry)?;
    let wrapper_src = generate_wrapper(&app_source, &collisions)?;
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

    // 2b. Compile the boot prelude (spec §4) to an object file. It seeds
    //     (library-directories) from AW_RESOURCE_DIR and suppresses the
    //     banner; concatenated ahead of the app object, it runs before the
    //     apianyware libraries instantiate. Cheap (a handful of forms), so a
    //     separate step rather than folding it into the ~160 s whole-program
    //     compile.
    let prelude_ss = build.join("prelude.ss");
    fs::write(&prelude_ss, PRELUDE_SS)?;
    let prelude_so = build.join("prelude.so");
    run_chez_script(
        build,
        &format!(
            "(compile-file {src} {obj})\n",
            src = scheme_string(&prelude_ss.to_string_lossy()),
            obj = scheme_string(&prelude_so.to_string_lossy()),
        ),
        |stderr| BundleError::PreludeCompileFailed { stderr },
    )?;

    // 3. make-boot-file: empty base + petite + scheme (open-world) +
    //    prelude (dylib-search seed, §4) + app.
    let boot_name = format!("{}.boot", spec.script_name);
    let boot = build.join(&boot_name);
    run_chez_script(
        build,
        &format!(
            "(make-boot-file {boot} '() {petite} {scheme} {prelude} {whole})\n",
            boot = scheme_string(&boot.to_string_lossy()),
            petite = scheme_string(&kernel.join("petite.boot").to_string_lossy()),
            scheme = scheme_string(&kernel.join("scheme.boot").to_string_lossy()),
            prelude = scheme_string(&prelude_so.to_string_lossy()),
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

/// The per-facade duplicate-import collision set for an app: each facade
/// library (as written in the entry's import form, e.g.
/// `"(apianyware appkit)"`) mapped to the sorted list of names it must
/// `except` to yield to the curated runtime API + `(chezscheme)`. Facades
/// with no collisions are absent. A `BTreeMap` so iteration (and the
/// resulting wrapper) is deterministic.
pub type Collisions = BTreeMap<String, Vec<String>>;

/// Compute the collision set for the app at `entry` by running the
/// `environment-symbols` probe (`scripts/standalone-collisions.ss`) with
/// `source_root` as the library-directories root.
///
/// The probe is **pure** — it expands the import closure to read each
/// library's bound names but writes no `.so`/`.wpo`, so it is safe to run
/// against a source tree directly. It pays the one-time AppKit-facade
/// expansion (~75 s for a full AppKit app); leaf 020 keeps it a separate
/// step rather than warming the whole-program cache, to avoid scattering
/// compile artifacts into the (possibly source) tree.
pub fn compute_collisions(entry: &Path, source_root: &Path) -> Result<Collisions, BundleError> {
    let dir = tempfile::tempdir()?;
    let script = dir.path().join("standalone-collisions.ss");
    fs::write(&script, STANDALONE_COLLISIONS_SS)?;

    let out = Command::new(DEFAULT_CHEZ_BIN)
        .arg("--script")
        .arg(&script)
        .arg(source_root)
        .arg(entry)
        .output()
        .map_err(|e| BundleError::ChezNotAvailable {
            chez_bin: DEFAULT_CHEZ_BIN.to_string(),
            source: e,
        })?;
    if !out.status.success() {
        return Err(BundleError::CollisionProbeFailed {
            stderr: String::from_utf8_lossy(&out.stderr).into_owned(),
        });
    }
    Ok(parse_collisions(&String::from_utf8_lossy(&out.stdout)))
}

/// Parse the probe's stdout — one `(<facade>)\t<name> <name> …` line per
/// colliding facade — into a [`Collisions`] map.
fn parse_collisions(stdout: &str) -> Collisions {
    let mut map = Collisions::new();
    for line in stdout.lines() {
        let line = line.trim_end();
        if line.is_empty() {
            continue;
        }
        if let Some((facade, names)) = line.split_once('\t') {
            let names: Vec<String> = names.split_whitespace().map(str::to_owned).collect();
            if !names.is_empty() {
                map.insert(facade.to_string(), names);
            }
        }
    }
    map
}

/// Generate the strict top-level-program wrapper from the app's
/// `--script` source and its computed collision set (spec §3).
///
/// Two transforms:
/// 1. Each colliding facade's import spec `(apianyware <fw>)` is rewritten
///    to `(except (apianyware <fw>) <names>…)` so the facade yields to the
///    curated runtime + `(chezscheme)`. The facade spec is matched
///    verbatim (the probe prints it in the same canonical
///    single-space form the generated apps are authored in); a facade the
///    probe named but that is absent from the source is a hard error
///    rather than a silent no-op.
/// 2. The trailing top-level `(main)` call becomes a `(scheme-start …)`
///    thunk so the embedding host drives the entry (the run loop must not
///    fire during boot load). Robust to trailing whitespace/newlines; the
///    earlier `(define-entry-point (main) …)` head is untouched.
pub fn generate_wrapper(app_source: &str, collisions: &Collisions) -> Result<String, BundleError> {
    // 1. Facade yields. Deterministic order (BTreeMap); each facade spec
    //    appears once in the import form. The closing paren in the matched
    //    spec keeps `(apianyware foundation)` from matching a longer name.
    let mut body = app_source.to_string();
    for (facade, names) in collisions {
        let except = format!("(except {} {})", facade, names.join(" "));
        if !body.contains(facade.as_str()) {
            return Err(BundleError::FacadeNotInSource {
                facade: facade.clone(),
            });
        }
        body = body.replacen(facade.as_str(), &except, 1);
    }

    // 2. Drop the trailing top-level `(main)` call and install a
    //    scheme-start thunk in its place.
    let trimmed = body.trim_end();
    let head = trimmed
        .strip_suffix("(main)")
        .ok_or(BundleError::WrapperNoTrailingMain)?;
    Ok(format!(
        "{}\n(scheme-start (lambda args (main) 0))\n",
        head.trim_end()
    ))
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
    // Caller overrides win.
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

    /// The collision set the probe computes for `hello-window` (spike F2);
    /// the regression anchor leaf 020 must reproduce exactly.
    fn hello_window_collisions() -> Collisions {
        Collisions::from([
            (
                "(apianyware appkit)".to_string(),
                vec!["nsevent-location-in-window".to_string()],
            ),
            (
                "(apianyware foundation)".to_string(),
                vec![
                    "nserror-code".to_string(),
                    "nserror-domain".to_string(),
                    "reverse".to_string(),
                ],
            ),
        ])
    }

    #[test]
    fn parse_collisions_reads_tab_delimited_lines() {
        let stdout = "(apianyware appkit)\tnsevent-location-in-window\n\
                      (apianyware foundation)\tnserror-code nserror-domain reverse\n";
        assert_eq!(parse_collisions(stdout), hello_window_collisions());
    }

    #[test]
    fn parse_collisions_ignores_blank_and_malformed_lines() {
        // No tab → not a collision line; blank lines skipped.
        let stdout = "\n(apianyware appkit)\tnsevent-location-in-window\nno-tab-here\n\n";
        let m = parse_collisions(stdout);
        assert_eq!(m.len(), 1);
        assert!(m.contains_key("(apianyware appkit)"));
    }

    #[test]
    fn wrapper_reproduces_hand_coded_010_result() {
        // The exact strings leaf 010 hand-coded for hello-window, now
        // produced from the computed collision set.
        let w = generate_wrapper(HELLO_SOURCE, &hello_window_collisions()).unwrap();
        assert!(w.contains("(except (apianyware appkit) nsevent-location-in-window)"));
        assert!(w.contains("(except (apianyware foundation) nserror-code nserror-domain reverse)"));
        // The bare facade imports must be gone.
        assert!(!w.contains("        (apianyware appkit)\n"));
        assert!(!w.contains("        (apianyware foundation)\n"));
    }

    #[test]
    fn wrapper_installs_scheme_start_and_drops_trailing_main() {
        let w = generate_wrapper(HELLO_SOURCE, &hello_window_collisions()).unwrap();
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
    fn wrapper_handles_no_collisions() {
        // An app importing only curated libraries needs no except clauses;
        // the wrapper is the body with just the scheme-start rewrite.
        let src = "(import (chezscheme) (apianyware runtime objc))\n(main)\n";
        let w = generate_wrapper(src, &Collisions::new()).unwrap();
        assert!(w.contains("(import (chezscheme) (apianyware runtime objc))"));
        assert!(w
            .trim_end()
            .ends_with("(scheme-start (lambda args (main) 0))"));
    }

    #[test]
    fn wrapper_tolerates_trailing_whitespace_before_main() {
        let src = "(import (chezscheme))\n(main)\n\n  \n";
        let w = generate_wrapper(src, &Collisions::new()).unwrap();
        assert!(w
            .trim_end()
            .ends_with("(scheme-start (lambda args (main) 0))"));
    }

    #[test]
    fn wrapper_errs_when_facade_absent_from_source() {
        let collisions =
            Collisions::from([("(apianyware webkit)".to_string(), vec!["foo".to_string()])]);
        let err = generate_wrapper(HELLO_SOURCE, &collisions).unwrap_err();
        assert!(matches!(err, BundleError::FacadeNotInSource { .. }));
    }

    #[test]
    fn wrapper_errs_when_no_trailing_main() {
        let src = "(import (chezscheme))\n(display 'x)\n";
        let err = generate_wrapper(src, &Collisions::new()).unwrap_err();
        assert!(matches!(err, BundleError::WrapperNoTrailingMain));
    }

    #[test]
    fn scheme_string_escapes() {
        assert_eq!(scheme_string("a/b c"), "\"a/b c\"");
        assert_eq!(scheme_string("a\"b"), "\"a\\\"b\"");
        assert_eq!(scheme_string("a\\b"), "\"a\\\\b\"");
    }
}
