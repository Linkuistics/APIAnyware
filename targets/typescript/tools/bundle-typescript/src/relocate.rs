//! Vendor the Homebrew dylibs the compiled launcher transitively links and
//! rewrite every non-system load command to an `@executable_path`-relative
//! path (ADR-0060 §5 — the gerbil/chez vendor-and-relocate precedent, **not**
//! sbcl's runtime relocation, which was forced by an un-editable Lisp image
//! that has no analogue here: the launcher is an ordinary Mach-O).
//!
//! The launcher links exactly two Homebrew dylibs directly — `libnode` and
//! `libuv` (`crate::launcher::discover_node_toolchain`) — but `libnode` itself
//! pulls a wide Homebrew closure (llhttp, ada-url, simdjson, brotli, c-ares,
//! openssl, icu4c, …: this Homebrew `node` build is **not** the minimal,
//! V8+ICU-statically-linked `--shared` build ADR-0060 §2 assumed — a measured
//! premise correction, not a design change; the vendor-and-relocate mechanism
//! already generalizes to it).
//!
//! Homebrew dylibs reference each other three different ways, all of which
//! must be walked and rewritten — an absolute `/opt/homebrew/...` path is the
//! common case, but ICU's own dylibs cross-reference by `@loader_path` (e.g.
//! `libicuuc.dylib` -> `@loader_path/libicudata.dylib`, same directory) and
//! brotli's by `@rpath` (`libbrotlidec.dylib` -> `@rpath/libbrotlicommon.dylib`,
//! resolved through its own `LC_RPATH` — measured first-hand bundling
//! hello-window: a naive absolute-path-only walk silently drops both and the
//! bundled launcher fails at `dyld` load time with a "Library not loaded"
//! error, not a build-time one).

use std::collections::{BTreeMap, BTreeSet};
use std::fs;
use std::os::unix::fs::PermissionsExt;
use std::path::{Path, PathBuf};
use std::process::Command;

use apianyware_stub_launcher::codesign_path;

use crate::bundle::BundleError;

/// The Homebrew prefix every vendored dependency lives under.
const HOMEBREW_PREFIX: &str = "/opt/homebrew/";

/// True when a load-command dependency path should be vendored: a Homebrew
/// absolute path, or a relative reference (`@loader_path`/`@rpath`) — every
/// relative form Homebrew dylibs use only ever points at another vendorable
/// (non-system) dylib in this closure.
fn is_vendorable_dep(path: &str) -> bool {
    path.starts_with(HOMEBREW_PREFIX) || path.starts_with("@loader_path/") || path.starts_with("@rpath/")
}

/// Parse `otool -L` output into the list of dependency load-command paths
/// (verbatim, as they appear in the load command) that should be vendored.
/// The first (header) line — the binary's own path — is not indented and is
/// skipped; dependency lines are tab-indented `<path> (compatibility version
/// …)`.
pub fn homebrew_deps_of(otool_output: &str) -> Vec<String> {
    otool_output
        .lines()
        .filter(|line| line.starts_with([' ', '\t']))
        .filter_map(|line| {
            let trimmed = line.trim();
            let path = trimmed.split(" (").next().unwrap_or(trimmed);
            is_vendorable_dep(path).then(|| path.to_string())
        })
        .collect()
}

/// The `@executable_path`-relative install name a dependency load command is
/// rewritten to: `@executable_path/../Frameworks/<base>` — computed from the
/// basename alone, so it is the same regardless of whether the original was
/// an absolute Homebrew path, an `@loader_path/<name>`, or an `@rpath/<name>`.
pub fn relocated_install_name(old_path: &str) -> String {
    let base = Path::new(old_path)
        .file_name()
        .map(|n| n.to_string_lossy().into_owned())
        .unwrap_or_else(|| old_path.to_string());
    format!("@executable_path/../Frameworks/{base}")
}

/// Resolve a load-command dependency string to the absolute filesystem path
/// it names, given the absolute path of the binary that carries the load
/// command (`referencing_bin`). `@loader_path` is relative to that binary's
/// own directory; `@rpath` is resolved against each of that binary's own
/// `LC_RPATH` entries (which may themselves be `@loader_path`-relative), in
/// order, returning the first that exists on disk — the same search dyld
/// itself performs at load time.
fn resolve_dep_source(referencing_bin: &Path, dep: &str) -> Result<PathBuf, BundleError> {
    let dir = referencing_bin.parent().unwrap_or_else(|| Path::new("."));
    if let Some(name) = dep.strip_prefix("@loader_path/") {
        return Ok(dir.join(name));
    }
    if let Some(name) = dep.strip_prefix("@rpath/") {
        for rpath in lc_rpaths(referencing_bin)? {
            let base = match rpath.strip_prefix("@loader_path/") {
                Some(rest) => dir.join(rest),
                None => PathBuf::from(&rpath),
            };
            let candidate = base.join(name);
            if candidate.exists() {
                return Ok(candidate);
            }
        }
        return Err(BundleError::DylibSourceMissing(dir.join(format!(
            "{dep} (no LC_RPATH entry on {} resolved it)",
            referencing_bin.display()
        ))));
    }
    Ok(PathBuf::from(dep))
}

/// The `LC_RPATH` entries (verbatim, e.g. `@loader_path/../lib`) carried by
/// `bin`, in load-command order — parsed from `otool -l`.
fn lc_rpaths(bin: &Path) -> Result<Vec<String>, BundleError> {
    let out = Command::new("otool")
        .arg("-l")
        .arg(bin)
        .output()
        .map_err(|source| BundleError::ToolNotAvailable { tool: "otool", source })?;
    if !out.status.success() {
        return Err(BundleError::OtoolFailed {
            path: bin.to_path_buf(),
            stderr: String::from_utf8_lossy(&out.stderr).into_owned(),
        });
    }
    let text = String::from_utf8_lossy(&out.stdout);
    let mut rpaths = Vec::new();
    let mut lines = text.lines();
    while let Some(line) = lines.next() {
        if line.trim() != "cmd LC_RPATH" {
            continue;
        }
        // The load command's remaining fields follow on subsequent lines;
        // `path <value> (offset N)` is one of them.
        for l in lines.by_ref() {
            let t = l.trim();
            if let Some(rest) = t.strip_prefix("path ") {
                if let Some((path, _offset)) = rest.rsplit_once(" (offset") {
                    rpaths.push(path.to_string());
                }
                break;
            }
        }
    }
    Ok(rpaths)
}

/// Vendor every Homebrew dylib `exe` transitively depends on into
/// `frameworks_dir`, rewrite all non-system load commands (in the exe and the
/// vendored dylibs) to `@executable_path/../Frameworks/<name>`, and re-sign
/// each vendored dylib. The exe itself is re-signed by the caller when the
/// whole bundle is signed (after its load commands were rewritten).
///
/// Returns the vendored dylib paths (for logging).
pub fn vendor_and_relocate_homebrew_deps(
    exe: &Path,
    frameworks_dir: &Path,
    identity: &str,
) -> Result<Vec<PathBuf>, BundleError> {
    // 1. Transitively discover the dylib *files* reachable from the exe,
    //    keyed by basename (the vendoring identity). Each dependency's
    //    `otool -L` is inspected at its ORIGINAL host location — never the
    //    not-yet-populated vendored copy — so `@loader_path`/`@rpath`
    //    resolution always has real sibling files to check against.
    let mut to_vendor: BTreeMap<String, PathBuf> = BTreeMap::new();
    let mut frontier: Vec<PathBuf> = vec![exe.to_path_buf()];
    let mut inspected: BTreeSet<PathBuf> = BTreeSet::new();
    while let Some(bin) = frontier.pop() {
        if !inspected.insert(bin.clone()) {
            continue;
        }
        for dep in homebrew_deps_of(&otool_l(&bin)?) {
            let source = resolve_dep_source(&bin, &dep)?;
            let base = match source.file_name() {
                Some(n) => n.to_string_lossy().into_owned(),
                None => continue,
            };
            if to_vendor.contains_key(&base) {
                continue;
            }
            if !source.exists() {
                return Err(BundleError::DylibSourceMissing(source));
            }
            to_vendor.insert(base, source.clone());
            frontier.push(source);
        }
    }

    // 2. Copy each into the bundle, made writable so install_name_tool can
    //    edit it (Homebrew dylibs ship read-only).
    fs::create_dir_all(frameworks_dir)?;
    let mut vendored = Vec::new();
    for (base, src) in &to_vendor {
        let dst = frameworks_dir.join(base);
        fs::copy(src, &dst)?;
        let mut perms = fs::metadata(&dst)?.permissions();
        perms.set_mode(0o644);
        fs::set_permissions(&dst, perms)?;
        vendored.push(dst);
    }

    // 3. Rewrite load commands. The exe gets every dep -change'd; each
    //    vendored dylib gets its own -id reset plus its deps -change'd. Old
    //    paths are read from each binary's live otool -L so the exact
    //    load-command strings match (opt vs Cellar vs @loader_path vs @rpath).
    rewrite_changes(exe)?;
    for dylib in &vendored {
        let base = dylib.file_name().unwrap().to_string_lossy().into_owned();
        run_install_name_tool(dylib, &["-id".to_string(), relocated_install_name(&base)])?;
        rewrite_changes(dylib)?;
        // install_name_tool invalidated the signature — re-sign the dylib.
        codesign_path(dylib, identity)?;
    }

    Ok(vendored)
}

/// Rewrite every vendorable load command in `binary` to its
/// `@executable_path` relative form, one `install_name_tool -change` per dep.
fn rewrite_changes(binary: &Path) -> Result<(), BundleError> {
    let deps = homebrew_deps_of(&otool_l(binary)?);
    if deps.is_empty() {
        return Ok(());
    }
    let mut args = Vec::new();
    for old in &deps {
        args.push("-change".to_string());
        args.push(old.clone());
        args.push(relocated_install_name(old));
    }
    run_install_name_tool(binary, &args)
}

/// `otool -L <path>`.
fn otool_l(path: &Path) -> Result<String, BundleError> {
    let out = Command::new("otool")
        .arg("-L")
        .arg(path)
        .output()
        .map_err(|source| BundleError::ToolNotAvailable { tool: "otool", source })?;
    if !out.status.success() {
        return Err(BundleError::OtoolFailed {
            path: path.to_path_buf(),
            stderr: String::from_utf8_lossy(&out.stderr).into_owned(),
        });
    }
    Ok(String::from_utf8_lossy(&out.stdout).into_owned())
}

/// `install_name_tool <args> <path>`.
fn run_install_name_tool(path: &Path, args: &[String]) -> Result<(), BundleError> {
    let out = Command::new("install_name_tool")
        .args(args)
        .arg(path)
        .output()
        .map_err(|source| BundleError::ToolNotAvailable { tool: "install_name_tool", source })?;
    if !out.status.success() {
        return Err(BundleError::InstallNameToolFailed {
            path: path.to_path_buf(),
            stderr: String::from_utf8_lossy(&out.stderr).into_owned(),
        });
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Real `otool -L` of the compiled hello-window launcher (grove leaf
    /// `bundle-typescript-k126`).
    const LAUNCHER_OTOOL: &str = "\
build/hello-window:
\t/opt/homebrew/opt/node/lib/libnode.147.dylib (compatibility version 0.0.0, current version 0.0.0)
\t/opt/homebrew/opt/libuv/lib/libuv.1.dylib (compatibility version 1.0.0, current version 1.0.0)
\t/System/Library/Frameworks/AppKit.framework/Versions/C/AppKit (compatibility version 45.0.0, current version 2685.60.104)
\t/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1356.0.0)
";

    #[test]
    fn homebrew_deps_extracts_only_homebrew_paths() {
        assert_eq!(
            homebrew_deps_of(LAUNCHER_OTOOL),
            vec![
                "/opt/homebrew/opt/node/lib/libnode.147.dylib",
                "/opt/homebrew/opt/libuv/lib/libuv.1.dylib",
            ]
        );
    }

    #[test]
    fn homebrew_deps_skips_the_header_line() {
        let out = "/opt/homebrew/x/bin/thing:\n\t/usr/lib/libSystem.B.dylib (compatibility version 1.0.0)\n";
        assert!(homebrew_deps_of(out).is_empty());
    }

    #[test]
    fn homebrew_deps_handles_cellar_path() {
        // libnode references some deps by their Cellar path, not the opt symlink.
        let out = "\
/path/in/bundle/libnode.147.dylib:
\t@executable_path/../Frameworks/libnode.147.dylib (compatibility version 0.0.0)
\t/opt/homebrew/Cellar/icu4c@78/78.1/lib/libicuuc.78.dylib (compatibility version 78.0.0)
\t/usr/lib/libSystem.B.dylib (compatibility version 1.0.0)
";
        assert_eq!(homebrew_deps_of(out), vec!["/opt/homebrew/Cellar/icu4c@78/78.1/lib/libicuuc.78.dylib"]);
    }

    #[test]
    fn homebrew_deps_includes_loader_path_and_rpath_siblings() {
        // libicuuc -> @loader_path/libicudata (ICU's own convention); libbrotlidec ->
        // @rpath/libbrotlicommon (brotli's own convention) — both are non-system, same-closure
        // sibling references that must be vendored, not just absolute Homebrew paths.
        // (The dylib's own -id load command — its first indented line, matching the header —
        // is itself picked up as a "dep" too; harmless in practice (the caller's `to_vendor`
        // dedup-by-basename skips it as already-vendored), so it is omitted here to keep this
        // fixture focused on the @loader_path/@rpath behaviour under test.
        let out = "\
/opt/homebrew/opt/icu4c@78/lib/libicuuc.78.dylib:
\t@loader_path/libicudata.78.dylib (compatibility version 78.0.0)
\t/usr/lib/libSystem.B.dylib (compatibility version 1.0.0)
";
        assert_eq!(homebrew_deps_of(out), vec!["@loader_path/libicudata.78.dylib"]);

        let out2 = "\
/opt/homebrew/opt/brotli/lib/libbrotlidec.1.dylib:
\t/usr/lib/libSystem.B.dylib (compatibility version 1.0.0)
\t@rpath/libbrotlicommon.1.dylib (compatibility version 1.0.0)
";
        assert_eq!(homebrew_deps_of(out2), vec!["@rpath/libbrotlicommon.1.dylib"]);
    }

    #[test]
    fn relocated_name_is_executable_path_relative() {
        assert_eq!(
            relocated_install_name("/opt/homebrew/opt/node/lib/libnode.147.dylib"),
            "@executable_path/../Frameworks/libnode.147.dylib"
        );
        // Cellar path collapses to the same basename as the opt path.
        assert_eq!(
            relocated_install_name("/opt/homebrew/Cellar/icu4c@78/78.1/lib/libicuuc.78.dylib"),
            "@executable_path/../Frameworks/libicuuc.78.dylib"
        );
        // @loader_path / @rpath forms collapse to the same basename too.
        assert_eq!(
            relocated_install_name("@loader_path/libicudata.78.dylib"),
            "@executable_path/../Frameworks/libicudata.78.dylib"
        );
        assert_eq!(
            relocated_install_name("@rpath/libbrotlicommon.1.dylib"),
            "@executable_path/../Frameworks/libbrotlicommon.1.dylib"
        );
    }

    #[test]
    fn resolve_dep_source_resolves_loader_path_relative_to_referencing_binary() {
        let referencing = Path::new("/opt/homebrew/opt/icu4c@78/lib/libicuuc.78.dylib");
        let resolved = resolve_dep_source(referencing, "@loader_path/libicudata.78.dylib").unwrap();
        assert_eq!(resolved, PathBuf::from("/opt/homebrew/opt/icu4c@78/lib/libicudata.78.dylib"));
    }

    #[test]
    fn resolve_dep_source_passes_through_absolute_paths() {
        let referencing = Path::new("/opt/homebrew/opt/node/lib/libnode.147.dylib");
        let resolved = resolve_dep_source(referencing, "/opt/homebrew/opt/libuv/lib/libuv.1.dylib").unwrap();
        assert_eq!(resolved, PathBuf::from("/opt/homebrew/opt/libuv/lib/libuv.1.dylib"));
    }
}
