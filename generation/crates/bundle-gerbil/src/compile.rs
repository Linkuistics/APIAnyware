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

use crate::bundle::BundleError;

/// Environment variable overriding gerbil bottle bin-dir discovery.
pub const DEFAULT_GERBIL_BIN_ENV: &str = "AW_GERBIL_BIN_DIR";

/// On-disk stem of the shared generics declaration module at the package root
/// (`lib/generics.ss`). Must track `emit_generics::GENERICS_MODULE_STEM` in the
/// emitter; kept as a local literal so the bundler does not depend on the
/// emitter crate. Compiled without `-O` (ADR-0023) — see [`compile_app`] step 2.
const GENERICS_MODULE_STEM: &str = "generics";

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
pub fn compile_app(
    entry: &Path,
    lib_root: &Path,
    closure: &[PathBuf],
    build_dir: &Path,
    cache_dir: &Path,
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

    // 2. Compile the closure into the GERBIL_PATH cache, deps-first.
    //
    // The shared `generics.ss` declaration module is compiled on its own pass
    // **without `-O`** (ADR-0023). It is pure `(g:defgeneric …)` declarations —
    // empty generic objects, no methods, no hot code — so optimizing it buys no
    // runtime speed, yet at full-framework scale (6,496 generics → a 94 MB C
    // translation unit) `-O` dominates a *cold* build by hours: both Gambit's
    // `gsc -target C` flow analysis and `gcc -O1` are superlinear in unit size,
    // and `gxc -O` drives both. Compiling it un-optimized first leaves its
    // `.ssi` available for the `-O` importers that follow — mixed-opt linking is
    // sound because the interface is optimization-independent.
    let generics_module = lib_root.join(format!("{GENERICS_MODULE_STEM}.ss"));
    let (generics, optimized): (Vec<PathBuf>, Vec<PathBuf>) = closure
        .iter()
        .cloned()
        .partition(|m| *m == generics_module);

    // 2a. generics.ss — no `-O`.
    if !generics.is_empty() {
        let out = gerbil_command("gxc", &bin_dir, lib_root, cache_dir, &sdkroot)?
            .arg("-ld-options")
            .arg(format!("-lobjc {blk}"))
            .args(&generics)
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
    }

    // 2b. the rest of the closure — `-O`, deps-first (order preserved by
    // `partition`; generics is already cached, so its importers resolve).
    if !optimized.is_empty() {
        let out = gerbil_command("gxc", &bin_dir, lib_root, cache_dir, &sdkroot)?
            .arg("-O")
            .arg("-ld-options")
            .arg(format!("-lobjc {blk}"))
            .args(&optimized)
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
    }

    // 3. gxc -exe -O — link the app exe.
    let script_stem = entry
        .file_stem()
        .map(|s| s.to_string_lossy().into_owned())
        .unwrap_or_else(|| "app".to_string());
    let exe = build_dir.join(&script_stem);
    let frameworks = framework_link_args(closure, lib_root);
    let ld_options = format!("-lobjc {frameworks} {blk}");
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

    Ok(exe)
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
        "runtime" => None,
        "appkit" => Some("AppKit".to_string()),
        "foundation" => Some("Foundation".to_string()),
        "coregraphics" => Some("CoreGraphics".to_string()),
        "quartzcore" => Some("QuartzCore".to_string()),
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
        assert_eq!(framework_link_name(OsStr::new("appkit")).as_deref(), Some("AppKit"));
        assert_eq!(
            framework_link_name(OsStr::new("foundation")).as_deref(),
            Some("Foundation")
        );
        assert_eq!(framework_link_name(OsStr::new("runtime")), None);
    }
}
