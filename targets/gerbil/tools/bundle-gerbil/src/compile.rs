//! Drive the **bottle** gerbil toolchain to build a self-contained app exe.
//!
//! This generalises the per-app `build.sh` (app README, discovered at grove
//! leaf 070/020) into a reusable Rust driver. The exe `gxc -exe` produces
//! already embeds the Gerbil/Gambit runtime (`libgambit.a` is linked
//! statically by default) — there is no static source toolchain and no
//! runtime interpreter to ship (spec §7).
//!
//! The build, per app:
//!
//! 1. **clang companion** — compile the one block-literal translation unit
//!    `runtime/native_block.c` with `-fblocks` (gcc-15, the default gsc
//!    compiler, cannot parse ObjC block literals; ADR-0021). Its `.o` joins
//!    every link line — the runtime's `make-objc-block` references its
//!    `aw_make_block_*` symbols.
//! 2. **`gxc -O` the closure** — compile the topologically-ordered
//!    binding-library closure ([`crate::deps`]) into a persistent
//!    `GERBIL_PATH` cache, since `gxc -exe` does not recursively compile
//!    imports. Every emitted module compiles under the *default* gcc-15 with
//!    no special flags (ADR-0021) — the only non-default compile is the
//!    clang companion above.
//! 3. **`gxc -exe -O`** — link the app exe against the warmed cache, with
//!    `-lobjc`, one `-framework` per framework the closure touches, and the
//!    companion `.o`.
//!
//! Toolchain environment mirrors `build.sh`: the bottle's `bin/` prepended
//! to `PATH` (its `gxc`/`gsc` are multicall symlinks), `GERBIL_HOME` unset,
//! `SDKROOT` exported (gambit needs the SDK framework search paths — it does
//! *not* select a compiler), `GERBIL_LOADPATH` = the package root,
//! `GERBIL_PATH` = the per-build cache.

use std::collections::BTreeSet;
use std::ffi::OsStr;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::sync::Mutex;
use std::time::Instant;

use crate::bundle::BundleError;

/// Environment variable overriding gerbil bottle bin-dir discovery.
pub const DEFAULT_GERBIL_BIN_ENV: &str = "AW_GERBIL_BIN_DIR";

/// On-disk stem of the shared generics declaration module at the package root
/// (`lib/generics.ss`). Must track `emit_generics::GENERICS_MODULE_STEM` in the
/// emitter; kept as a local literal so the bundler does not depend on the
/// emitter crate. Compiled without `-O` (ADR-0023) — see [`compile_app`] step 2.
const GENERICS_MODULE_STEM: &str = "generics";

/// The linker name of the Swift-native trampoline dylib (`-lAPIAnywareGerbil`,
/// ADR-0029). Built by `swift build` from the `APIAnywareGerbil` SwiftPM target;
/// see [`discover_swift_dylib`]. The basename is
/// [`crate::relocate::SWIFT_DYLIB_NAME`].
const SWIFT_DYLIB_LINK_NAME: &str = "APIAnywareGerbil";

/// Locate the built `libAPIAnywareGerbil.dylib` under the repo's
/// `swift/.build/<triple>/{release,debug}/` (ADR-0029). The dylib is the
/// `swift build` artifact for the `APIAnywareGerbil` SwiftPM target; gerbil
/// **links** it (`-lAPIAnywareGerbil`) rather than dlopen'ing it (the chez
/// divergence, ADR-0029 §4), so its directory becomes a `-L`/`-rpath` on the
/// gerbil app link line.
///
/// Prefers `release` over `debug` (a bundled app should ship the optimized
/// build when both exist), and the host triple's build dir over others. Returns
/// `None` when no artifact exists — the caller then omits the link args, so an
/// app with no Swift-native residual still bundles, and one that *does* reference
/// the trampolines fails loudly at the `gxc` link (undefined `aw_gerbil_swift_*`)
/// with the build instruction in the app README. `workspace_root` is the repo
/// root (the parent of `swift/`).
pub fn discover_swift_dylib(workspace_root: &Path) -> Option<PathBuf> {
    let build_root = workspace_root.join("swift").join(".build");
    let base = crate::relocate::SWIFT_DYLIB_NAME;
    // Host triple's conventional dir name (e.g. arm64-apple-macosx); also scan
    // any sibling triple dirs so a cross/older build layout still resolves.
    let mut triple_dirs: Vec<PathBuf> = Vec::new();
    if let Ok(entries) = fs::read_dir(&build_root) {
        for e in entries.flatten() {
            let p = e.path();
            if p.is_dir() {
                let name = p.file_name().and_then(|n| n.to_str()).unwrap_or("");
                // Skip SwiftPM's `release`/`debug` *symlinks* at the .build root;
                // we want the per-triple dirs that contain them.
                if name != "release" && name != "debug" && name != "checkouts" {
                    triple_dirs.push(p);
                }
            }
        }
    }
    triple_dirs.sort();
    for triple in &triple_dirs {
        for profile in ["release", "debug"] {
            let candidate = triple.join(profile).join(base);
            if candidate.is_file() {
                return Some(candidate);
            }
        }
    }
    // Fallback: SwiftPM's profile symlinks directly under .build (older layout).
    for profile in ["release", "debug"] {
        let candidate = build_root.join(profile).join(base);
        if candidate.is_file() {
            return Some(candidate);
        }
    }
    None
}

/// The `-ld-options` fragment that links the Swift trampoline dylib at
/// `dylib_path`: `-L<dir> -lAPIAnywareGerbil -Wl,-rpath,<dir>`. The `@rpath`
/// install name is rewritten to `@executable_path/../Frameworks/` by
/// [`crate::relocate::relocate_swift_dylib`] when the app is assembled, so the
/// build-dir rpath only matters for the unbundled `gxc` link. Empty string when
/// `dylib_path` is `None` (no Swift-native residual built).
fn swift_link_args(dylib_path: Option<&Path>) -> String {
    match dylib_path.and_then(|p| p.parent()) {
        Some(dir) => format!(
            "-L{0} -l{1} -Wl,-rpath,{0}",
            dir.display(),
            SWIFT_DYLIB_LINK_NAME
        ),
        None => String::new(),
    }
}

/// Locate the bottle gerbil's `bin/` directory (the one holding the `gxc`
/// multicall symlink). Honours [`DEFAULT_GERBIL_BIN_ENV`]; otherwise globs
/// the Homebrew Cellar for a `gerbil-scheme/<ver>/bin/gxc`.
pub fn discover_gerbil_bin_dir() -> Result<PathBuf, BundleError> {
    if let Ok(dir) = std::env::var(DEFAULT_GERBIL_BIN_ENV) {
        let p = PathBuf::from(dir);
        if p.join("gxc").exists() {
            return Ok(p);
        }
        return Err(BundleError::GerbilToolchainNotFound {
            searched: format!("{DEFAULT_GERBIL_BIN_ENV}={}", p.display()),
            env: DEFAULT_GERBIL_BIN_ENV,
        });
    }

    let cellar = PathBuf::from("/opt/homebrew/Cellar/gerbil-scheme");
    let mut searched = vec![cellar.display().to_string()];
    if let Ok(versions) = fs::read_dir(&cellar) {
        // Deterministic: prefer the highest version directory name.
        let mut bins: Vec<PathBuf> = versions
            .flatten()
            .map(|v| v.path().join("bin"))
            .filter(|b| b.join("gxc").exists())
            .collect();
        bins.sort();
        if let Some(bin) = bins.pop() {
            return Ok(bin);
        }
        searched.push(format!("{}/*/bin/gxc", cellar.display()));
    }
    Err(BundleError::GerbilToolchainNotFound {
        searched: searched.join(", "),
        env: DEFAULT_GERBIL_BIN_ENV,
    })
}

/// Build the app exe at `entry` (`apps/<script>/<script>.ss`), returning the
/// path to the produced binary inside `build_dir`.
///
/// - `lib_root` — the `gerbil-bindings` package root (`<source_root>/lib`).
/// - `closure` — the topologically-ordered compile closure from
///   [`crate::collect_closure`].
/// - `build_dir` — scratch dir for the companion `.o` and the exe.
/// - `cache_dir` — the persistent `GERBIL_PATH` (warmed across rebuilds).
/// - `swift_dylib` — the built `libAPIAnywareGerbil.dylib` (ADR-0029), or `None`
///   when no `swift build` artifact exists. When present its dir is added as a
///   `-L`/`-rpath` and `-lAPIAnywareGerbil` to the closure-`-O` and exe link
///   lines so the generated `aw_gerbil_swift_*` trampoline references resolve;
///   `ld` records a load command only for an app whose closure actually pulls a
///   trampoline binding (the Swift-native residual), so a plain app is unaffected.
pub fn compile_app(
    entry: &Path,
    lib_root: &Path,
    closure: &[PathBuf],
    build_dir: &Path,
    cache_dir: &Path,
    swift_dylib: Option<&Path>,
) -> Result<PathBuf, BundleError> {
    let bin_dir = discover_gerbil_bin_dir()?;
    let sdkroot = sdk_path()?;
    fs::create_dir_all(build_dir)?;
    fs::create_dir_all(cache_dir)?;

    // 1. clang companion (-fblocks). The one non-default compile.
    let native_block_c = lib_root.join("runtime").join("native_block.c");
    if !native_block_c.is_file() {
        return Err(BundleError::NativeBlockMissing(native_block_c));
    }
    let native_block_o = build_dir.join("native_block.o");
    let clang = Command::new("clang")
        .arg("-fblocks")
        .arg("-isysroot")
        .arg(&sdkroot)
        .arg("-c")
        .arg(&native_block_c)
        .arg("-o")
        .arg(&native_block_o)
        .output()
        .map_err(|source| BundleError::ToolNotAvailable {
            tool: "clang",
            source,
        })?;
    if !clang.status.success() {
        return Err(BundleError::NativeBlockCompileFailed {
            stderr: String::from_utf8_lossy(&clang.stderr).into_owned(),
        });
    }

    let blk = native_block_o.to_string_lossy().into_owned();

    // 2. Compile the closure into the GERBIL_PATH cache, in three passes.
    //
    // The generics declaration modules are compiled **without `-O`** (ADR-0023):
    // they are pure `(g:defgeneric …)` declarations — no methods, no hot code —
    // so optimizing them buys no runtime speed, yet `gsc -target C` is
    // *superlinear in module size* (independent of `-O`), so a large generics
    // unit dominates a cold build by hours. The fix is two-fold: declarations
    // are **sharded** into many small modules (`generics/NNN.ss`, the emitter's
    // `GENERICS_SHARD_SIZE`), each a small `gsc` unit, behind a re-export facade
    // `generics.ss`; and they are compiled un-optimized. Mixed-opt linking is
    // sound — a module's `.ssi` interface is optimization-independent.
    //
    // Order matters: shards → facade (imports them) → the `-O` closure (class
    // modules import the facade). Shards have no cross-shard deps, so the shard
    // pass runs in **parallel** — the lever that keeps the build fast.
    // Framework `-framework <Name>` args derived from the closure. Needed at the
    // exe link AND on the `-O` closure pass (2c), where `functions.ss`'s
    // dynamically-loadable `.oN` makes direct framework C calls (leaf 100/030).
    let frameworks = framework_link_args(closure, lib_root);
    // The Swift-native trampoline dylib (ADR-0029), when built. Joined onto the
    // closure-`-O` and exe link lines so the generated `aw_gerbil_swift_*`
    // references resolve; empty when no `swift build` artifact exists.
    let swift_ld = swift_link_args(swift_dylib);

    let generics_dir = lib_root.join(GENERICS_MODULE_STEM);
    let generics_facade = lib_root.join(format!("{GENERICS_MODULE_STEM}.ss"));
    let mut shards: Vec<PathBuf> = Vec::new();
    let mut facade: Vec<PathBuf> = Vec::new();
    let mut optimized: Vec<PathBuf> = Vec::new();
    for m in closure {
        if *m == generics_facade {
            facade.push(m.clone());
        } else if m.starts_with(&generics_dir) {
            shards.push(m.clone());
        } else {
            optimized.push(m.clone());
        }
    }

    // 2a. generics shards — no `-O`, **in parallel**. Two levers compound here
    //     (ADR-0023): *sharding* makes each a small `gsc` unit (sidestepping the
    //     size-superlinearity that made the monolith pathological), and
    //     *parallelism* overlaps the shards' independent `gsc`/`gcc` work.
    //     Measured cold: serial 809s vs parallel 224s (~3.6×) — `gxc` has no
    //     `-j` and serialises only its cache-metadata write on a build lock, so
    //     the heavy compilation still overlaps. Parallelism is *required* to hit
    //     the `< 15 min` budget (serial cold is ~18 min).
    //     The generics shards/facade reference no framework symbols, so they
    //     link with `-lobjc` alone (extra_ld = "").
    let t = Instant::now();
    compile_shards_parallel(&shards, &bin_dir, lib_root, cache_dir, &sdkroot, &blk)?;
    eprintln!(
        "[bundle-gerbil] generics: {} shards (no -O, parallel) in {:.1}s",
        shards.len(),
        t.elapsed().as_secs_f64()
    );
    // 2b. generics facade — no `-O` (depends on the shards just compiled).
    let t = Instant::now();
    gxc_compile(
        &facade, false, "", &bin_dir, lib_root, cache_dir, &sdkroot, &blk,
    )?;
    eprintln!(
        "[bundle-gerbil] generics facade (no -O) in {:.1}s",
        t.elapsed().as_secs_f64()
    );
    // 2c. the rest of the closure — `-O`, deps-first (order preserved above;
    //     generics is already cached, so its importers resolve). The frameworks
    //     go here: `functions.ss`'s loadable `.oN` calls framework C symbols.
    let t = Instant::now();
    gxc_compile(
        &optimized,
        true,
        format!("{frameworks} {swift_ld}").trim(),
        &bin_dir,
        lib_root,
        cache_dir,
        &sdkroot,
        &blk,
    )?;
    eprintln!(
        "[bundle-gerbil] closure: {} modules (-O) in {:.1}s",
        optimized.len(),
        t.elapsed().as_secs_f64()
    );

    // 3. gxc -exe -O — link the app exe.
    let script_stem = entry
        .file_stem()
        .map(|s| s.to_string_lossy().into_owned())
        .unwrap_or_else(|| "app".to_string());
    let exe = build_dir.join(&script_stem);
    let ld_options = format!("-lobjc {frameworks} {swift_ld} {blk}");
    let t = Instant::now();
    let out = gerbil_command("gxc", &bin_dir, lib_root, cache_dir, &sdkroot)?
        .arg("-exe")
        .arg("-O")
        .arg("-o")
        .arg(&exe)
        .arg("-ld-options")
        .arg(ld_options)
        .arg(entry)
        .output()
        .map_err(|source| BundleError::ToolNotAvailable {
            tool: "gxc",
            source,
        })?;
    if !out.status.success() {
        return Err(BundleError::ExeLinkFailed {
            stderr: stderr_or_stdout(&out),
        });
    }
    eprintln!(
        "[bundle-gerbil] exe link (-exe -O) in {:.1}s",
        t.elapsed().as_secs_f64()
    );

    Ok(exe)
}

/// Run one `gxc` invocation over `modules` (in the given, deps-first order),
/// optionally with `-O`. A no-op when `modules` is empty. Used for the generics
/// facade (no `-O`) and the optimized closure passes.
///
/// `extra_ld` is appended to the `-ld-options` after `-lobjc` — the closure pass
/// passes the `-framework <Name>` args here. `gxc -O` does **not** merely compile
/// to `.o`; it also links each module's dynamically-loadable `.oN`, so a module
/// that makes **direct C calls** to a framework symbol (the generated
/// `functions.ss`: `CGContextStrokePath` et al., vs class modules that only call
/// `objc_msgSend` via `-lobjc`) needs that framework on the pre-compile link line
/// too, not just at the final `-exe` link (leaf 100/030 — `functions.ss` is the
/// first closure member with direct framework symbol references).
fn gxc_compile(
    modules: &[PathBuf],
    optimize: bool,
    extra_ld: &str,
    bin_dir: &Path,
    lib_root: &Path,
    cache_dir: &Path,
    sdkroot: &Path,
    blk: &str,
) -> Result<(), BundleError> {
    if modules.is_empty() {
        return Ok(());
    }
    let mut cmd = gerbil_command("gxc", bin_dir, lib_root, cache_dir, sdkroot)?;
    if optimize {
        cmd.arg("-O");
    }
    let out = cmd
        .arg("-ld-options")
        .arg(format!("-lobjc {extra_ld} {blk}"))
        .args(modules)
        .output()
        .map_err(|source| BundleError::ToolNotAvailable {
            tool: "gxc",
            source,
        })?;
    if !out.status.success() {
        return Err(BundleError::ClosureCompileFailed {
            stderr: stderr_or_stdout(&out),
        });
    }
    Ok(())
}

/// Compile the generics **shards** without `-O`, **in parallel**. Shards have no
/// cross-shard deps (each imports only `:std/generic`), so their `gsc`/`gcc` work
/// overlaps — measured ~3.6× over a sequential pass (809s → 224s cold), the lever
/// that brings the sharded-generics build under budget (ADR-0023). `gxc` has no
/// `-j` and serialises only its cache-metadata write on a build lock, so the
/// effective speedup is below the core count but still large. The shards are
/// round-robined into `workers` groups, each compiled sequentially by one scoped
/// thread (one `gxc` per shard); the first failure is reported.
///
/// **Cold-cache warmup (leaf 100/030).** `gxc`'s per-module `compile-module`
/// does a check-then-`create-directory` of the cache subdirs (`gerbil-cache/lib`,
/// `…/gerbil-bindings/generics`) under a build lock that does NOT cover the
/// directory tree. Against an empty cache all `workers` processes start at once
/// and race to create the shared `lib` dir — the loser aborts with
/// `*** ERROR IN __with-lock -- File exists`. (`ui-controls`, same code, only
/// won the race by timing.) So we compile the **first shard serially** to warm
/// the shared directory tree + cache metadata, *then* fan out the rest: by the
/// parallel pass every shared parent dir already exists, so no two processes
/// ever create the same directory.
fn compile_shards_parallel(
    shards: &[PathBuf],
    bin_dir: &Path,
    lib_root: &Path,
    cache_dir: &Path,
    sdkroot: &Path,
    blk: &str,
) -> Result<(), BundleError> {
    if shards.is_empty() {
        return Ok(());
    }
    // Serial warmup: one shard creates `gerbil-cache/lib`, the shard output dir,
    // and the cache metadata, so the parallel fan-out never races on a mkdir.
    let (warm, rest) = shards.split_first().unwrap();
    gxc_compile(
        std::slice::from_ref(warm),
        false,
        "",
        bin_dir,
        lib_root,
        cache_dir,
        sdkroot,
        blk,
    )?;
    if rest.is_empty() {
        return Ok(());
    }
    let workers = std::thread::available_parallelism()
        .map(|n| n.get())
        .unwrap_or(4)
        .min(rest.len());
    let mut groups: Vec<Vec<PathBuf>> = vec![Vec::new(); workers];
    for (i, shard) in rest.iter().enumerate() {
        groups[i % workers].push(shard.clone());
    }

    let first_err: Mutex<Option<BundleError>> = Mutex::new(None);
    let first_err_ref = &first_err;
    std::thread::scope(|scope| {
        for group in &groups {
            scope.spawn(move || {
                for shard in group {
                    // Stop early if a sibling thread already failed.
                    if first_err_ref.lock().unwrap().is_some() {
                        return;
                    }
                    if let Err(e) = gxc_compile(
                        std::slice::from_ref(shard),
                        false,
                        "",
                        bin_dir,
                        lib_root,
                        cache_dir,
                        sdkroot,
                        blk,
                    ) {
                        let mut slot = first_err_ref.lock().unwrap();
                        if slot.is_none() {
                            *slot = Some(e);
                        }
                        return;
                    }
                }
            });
        }
    });
    match first_err.into_inner().unwrap() {
        Some(e) => Err(e),
        None => Ok(()),
    }
}

/// A `Command` for `<bin_dir>/<tool>` with the bottle toolchain environment
/// (`build.sh`): bottle `bin/` on `PATH`, `GERBIL_HOME` unset,
/// `GERBIL_LOADPATH` = package root, `GERBIL_PATH` = cache, `SDKROOT` set.
fn gerbil_command(
    tool: &str,
    bin_dir: &Path,
    lib_root: &Path,
    cache_dir: &Path,
    sdkroot: &Path,
) -> Result<Command, BundleError> {
    let mut cmd = Command::new(bin_dir.join(tool));
    let existing_path = std::env::var("PATH").unwrap_or_default();
    let path = format!("{}:{}", bin_dir.display(), existing_path);
    cmd.env("PATH", path)
        .env_remove("GERBIL_HOME")
        .env("GERBIL_LOADPATH", lib_root)
        .env("GERBIL_PATH", cache_dir)
        .env("SDKROOT", sdkroot);
    Ok(cmd)
}

/// `xcrun --sdk macosx --show-sdk-path`. gambit needs this for the SDK's
/// framework search paths; it does not select a compiler (ADR-0021).
fn sdk_path() -> Result<PathBuf, BundleError> {
    let out = Command::new("xcrun")
        .args(["--sdk", "macosx", "--show-sdk-path"])
        .output()
        .map_err(|source| BundleError::ToolNotAvailable {
            tool: "xcrun",
            source,
        })?;
    if !out.status.success() {
        return Err(BundleError::ToolNotAvailable {
            tool: "xcrun",
            source: std::io::Error::other(String::from_utf8_lossy(&out.stderr).into_owned()),
        });
    }
    Ok(PathBuf::from(
        String::from_utf8_lossy(&out.stdout).trim().to_string(),
    ))
}

/// Derive the `-framework <Name>` link arguments from the closure: one per
/// distinct framework directory under `lib_root` the closure touches
/// (`runtime` and package-root modules like `generics` are not frameworks).
/// `Foundation` is always linked — the runtime's objc layer references
/// `NSString` and friends even when no Foundation class module is imported.
fn framework_link_args(closure: &[PathBuf], lib_root: &Path) -> String {
    let mut frameworks: BTreeSet<String> = BTreeSet::new();
    frameworks.insert("Foundation".to_string());
    for module in closure {
        if let Ok(rel) = module.strip_prefix(lib_root) {
            // Only a *nested* module (e.g. `appkit/nswindow.ss`) names a
            // framework dir. A top-level file (`generics.ss`) is not a
            // framework — its single component is the file itself.
            let comps: Vec<_> = rel.components().collect();
            if comps.len() < 2 {
                continue;
            }
            if let std::path::Component::Normal(first) = comps[0] {
                if let Some(name) = framework_link_name(first) {
                    frameworks.insert(name);
                }
            }
        }
    }
    frameworks
        .iter()
        .map(|f| format!("-framework {f}"))
        .collect::<Vec<_>>()
        .join(" ")
}

/// Map a `lib/<dir>/` framework directory name to its linker framework name,
/// or `None` for non-framework dirs (`runtime`). The gerbil target currently
/// emits `appkit` and `foundation`; the casing table extends as frameworks
/// are added.
fn framework_link_name(dir: &OsStr) -> Option<String> {
    match dir.to_string_lossy().as_ref() {
        // Non-framework package dirs: the hand-written runtime, and the sharded
        // generics modules (`generics/NNN.ss`). Both are Gerbil modules, not
        // macOS frameworks — emitting `-framework Generics` makes `ld` fail
        // ("framework 'Generics' not found"). The facade `generics.ss` is a
        // top-level *file* (one path component) and is already skipped upstream;
        // this guards the shard *directory*.
        "runtime" | "generics" => None,
        "appkit" => Some("AppKit".to_string()),
        "foundation" => Some("Foundation".to_string()),
        "coregraphics" => Some("CoreGraphics".to_string()),
        "quartzcore" => Some("QuartzCore".to_string()),
        // The sample-app frameworks added at grove leaf 100/020. Each has
        // internal capitalisation the heuristic fallback would mangle
        // (pdfkit→"Pdfkit" etc.), so `ld -framework <Name>` would fail.
        "pdfkit" => Some("PDFKit".to_string()),
        "scenekit" => Some("SceneKit".to_string()),
        "webkit" => Some("WebKit".to_string()),
        // Fallback: a single-component lowercase framework dir not yet in the
        // table. Capitalise the first letter; warn so it can be added.
        other => {
            let mut chars = other.chars();
            let cased = match chars.next() {
                Some(c) => c.to_ascii_uppercase().to_string() + chars.as_str(),
                None => return None,
            };
            tracing::warn!(
                dir = other,
                framework = %cased,
                "framework dir not in casing table; using heuristic capitalisation"
            );
            Some(cased)
        }
    }
}

fn stderr_or_stdout(out: &std::process::Output) -> String {
    let mut s = String::from_utf8_lossy(&out.stderr).into_owned();
    if s.trim().is_empty() {
        s = String::from_utf8_lossy(&out.stdout).into_owned();
    }
    s
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn framework_args_always_include_foundation() {
        let lib = Path::new("/root/lib");
        let args = framework_link_args(&[], lib);
        assert_eq!(args, "-framework Foundation");
    }

    #[test]
    fn framework_args_derive_from_closure_dirs() {
        let lib = Path::new("/root/lib");
        let closure = vec![
            lib.join("runtime/objc.ss"),
            lib.join("appkit/nswindow.ss"),
            lib.join("generics.ss"),
        ];
        let args = framework_link_args(&closure, lib);
        // Sorted (BTreeSet): AppKit before Foundation. runtime + generics
        // contribute no framework.
        assert_eq!(args, "-framework AppKit -framework Foundation");
    }

    #[test]
    fn framework_link_name_known_and_runtime() {
        assert_eq!(
            framework_link_name(OsStr::new("appkit")).as_deref(),
            Some("AppKit")
        );
        assert_eq!(
            framework_link_name(OsStr::new("foundation")).as_deref(),
            Some("Foundation")
        );
        assert_eq!(framework_link_name(OsStr::new("runtime")), None);
        // Sample-app frameworks (leaf 100/020) — internal capitalisation the
        // heuristic fallback would get wrong.
        assert_eq!(
            framework_link_name(OsStr::new("pdfkit")).as_deref(),
            Some("PDFKit")
        );
        assert_eq!(
            framework_link_name(OsStr::new("scenekit")).as_deref(),
            Some("SceneKit")
        );
        assert_eq!(
            framework_link_name(OsStr::new("webkit")).as_deref(),
            Some("WebKit")
        );
    }
}
